#!/usr/bin/env ruby

task_helper = [
  # During a real bolt call, ruby_task_helper modules is installed in same directory as this module
  File.join(__dir__, '..', '..', 'ruby_task_helper', 'files', 'task_helper.rb'),
  # During development the ruby_task_helper module will be in the test module fixtures
  File.join(__dir__, '..', 'spec', 'fixtures', 'modules', 'ruby_task_helper', 'files', 'task_helper.rb'),
].find { |helper_path| File.exist?(helper_path) }
raise 'Could not find the Bolt ruby_task_helper' if task_helper.nil?
require_relative task_helper

require 'date'
require 'sequel'
require 'tiny_tds'

# Retrieves hosts from the WSUS SQL server
class WsusInventory < TaskHelper

  def resolve_reference(opts)
    db = connect(opts)
    format = opts[:format] || 'groups'
    group_name_prefix = opts[:group_name_prefix] || ''
    table = build_query(db, opts)
    dataset = table.all
    parse_dataset(dataset, format, group_name_prefix)
  end

  def connect(opts)
    Sequel.connect(
      adapter: 'tinytds',
      host:     opts[:host],
      port:     opts[:port] || 1433,
      database: opts[:database] || 'SUSDB',
      user:     opts[:username],
      password: opts[:password],
    )
  end

  def build_query(db, opts)
    # Get computers and their group memberships
    # Executes the following SQL query:
    # SELECT t.[TargetID]
    #       ,[ComputerID]
    #       ,[SID]
    #       ,[LastSyncTime]
    #       ,[LastReportedStatusTime]
    #       ,[LastReportedRebootTime]
    #       ,[IPAddress]
    #       ,[FullDomainName]
    #       ,[IsRegistered]
    #       ,[LastInventoryTime]
    #       ,[LastNameChangeTime]
    #       ,[EffectiveLastDetectionTime]
    #       ,[ParentServerTargetID]
    #       ,[LastSyncResult]
    # FROM [SUSDB].[dbo].[tbComputerTarget] as t
    # LEFT JOIN [SUSDB].[dbo].[tbTargetInTargetGroup] as ttg
    #   ON t.TargetID = ttg.TargetID
    # LEFT JOIN [SUSDB].[dbo].[tbTargetGroup] as tg
    #   ON tg.TargetGroupID = ttg.TargetGroupID
    # WHERE tg.Name = <your group name here>
    # ORDER BY t.FullDomainName
    table = db[:tbComputerTarget]
            .left_join(:tbTargetInTargetGroup, targetid: :targetid)
            .left_join(:tbTargetGroup, targetgroupid: :targetgroupid)
            .order(:fulldomainname)
    if opts[:groups]
      table = table.where(Sequel[:tbTargetGroup][:name] => opts[:groups])
    end

    # filter out hosts that haven't synced in the last N days using
    # the LastReportedStatusTime field
    if opts[:filter_older_than_days]
      # compute absolute time based on our "older than" offset
      filter_older_than_time = (DateTime.now - opts[:filter_older_than_days].to_i).to_time
      # convert the absolute time to a SQL compatible string
      filter_older_than_time_s = filter_older_than_time.strftime('%Y-%m-%d %H:%M:%S.%L')
      # add in our "older than" filter into our WHERE clause
      table = table.where { lastreportedstatustime > filter_older_than_time_s }
    end

    # ignore hosts that match a list of hostnames that the user passed us
    # this is good when troubleshooting problem hosts, they can be explicitly
    # excluded and revisited later
    if opts[:ignore_dns_hostnames]
      table = table.exclude(fulldomainname: opts[:ignore_dns_hostnames])
    end

    table
  end

  def parse_dataset(dataset, format, group_name_prefix)
    if format == 'groups'
      groups = {}
      dataset.each do |row|
        group_name = normalize_group_name(group_name_prefix + row[:name])
        unless groups.key?(group_name)
          groups[group_name] = {
            name: group_name,
            targets: [],
          }
        end
        groups[group_name][:targets] << { uri: row[:fulldomainname] }
      end
      groups.values
    elsif format == 'targets'
      targets = dataset.map do |row|
        { uri: row[:fulldomainname] }
      end
      targets
    else
      raise TaskHelper::Error.new("Unknown format: #{format}", 'bad/data')
    end
  end

  def normalize_group_name(name)
    name.downcase!
  end

  def task(opts)
    data = resolve_reference(opts)
    return { value: data }
  rescue TaskHelper::Error => e
    # ruby_task_helper doesn't print errors under the _error key, so we have to
    # handle that ourselves
    return { _error: e.to_h }
  end
end

if $PROGRAM_NAME == __FILE__
  WsusInventory.run
end
