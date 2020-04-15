# wsus_inventory

[![Build Status](https://travis-ci.org/EncoreTechnologies/puppet-wsus_inventory.svg?branch=master)](https://travis-ci.org/EncoreTechnologies/puppet-wsus_inventory)
[![Puppet Forge Version](https://img.shields.io/puppetforge/v/encore/wsus_inventory.svg)](https://forge.puppet.com/encore/wsus_inventory)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/encore/wsus_inventory.svg)](https://forge.puppet.com/encore/wsus_inventory)
[![Puppet Forge Score](https://img.shields.io/puppetforge/f/encore/wsus_inventory.svg)](https://forge.puppet.com/encore/wsus_inventory)
[![Puppet PDK Version](https://img.shields.io/puppetforge/pdk-version/encore/wsus_inventory.svg)](https://forge.puppet.com/encore/wsus_inventory)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/encore-wsus_inventory)


Welcome to your new module. A short overview of the generated parts can be found in the PDK documentation at https://puppet.com/pdk/latest/pdk_generating_modules.html .

The README template below provides a starting point with details about what information to include in your README.

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with wsus_inventory](#setup)
    * [What wsus_inventory affects](#what-wsus_inventory-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with wsus_inventory](#beginning-with-wsus_inventory)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

Briefly tell users why they might want to use your module. Explain what your module does and what kind of problems users can solve with it.

This should be a fairly short description helps the user decide if your module is what they want.

## Setup

### Setup Requirements

This module connects to the WSUS SQL server. To do this we make use of the
[sequel](https://github.com/jeremyevans/sequel) Ruby lubrary and the underlying
[tiny_tds](https://github.com/rails-sqlserver/tiny_tds) adapter, which relies on the
[FreeTDS](https://www.freetds.org/) C library. Below are basic instructions for setting up
FreeTDS on the node you're running bolt from so that this module can communicate
with the WSUS SQL Server and generate inventory. For more instructions on your platform
of choice, checkout the `tiny_tds` and `freetds` instructions for your platform on Google.

#### Setup Requirements: RHEL/CentOS

``` shell
# install freetds
sudo yum -y install freetds freetds-devel
/opt/puppetlabs/bolt/bin/gem install sequel tiny_tds
```

#### Setup Requirements: Debian

``` shell
# install freetds
sudo apt-get -y install freetds-bin freetds-dev
/opt/puppetlabs/bolt/bin/gem install sequel tiny_tds
```

#### Setup Requirements: Windows

``` shell
# freetds is compiled staticly and installed alongside the tiny_tds library on Windows
/opt/puppetlabs/bolt/bin/gem install sequel tiny_tds
```

### Examples

#### Example query all targets from WSUS

Queries ALL computers from WSUS and returns them as a list of Targets for Bolt.

``` yaml
---
version: 2.0

groups:
  - name: windows_wsus
    config:
      transport: winrm
      winrm:
        user: xxx
        password:
          _plugin: pkcs7
          encrypted_value: ENC[PKCS7,xxx]
        ssl: true
        ssl-verify: false
    vars:
      patching_order: 1
    targets:
      # grabs a list of groups from WSUS
      - _plugin: wsus_inventory
        # creds to login to the WSUS MSSQL database
        host: wsus.domain.tld
        database: 'SUSDB'
        username: DOMAIN\svc_wsus_bolt
        password:
          _plugin: pkcs7
          encrypted_value: ENC[PKCS7,xxx]     
        # remove hosts that haven't checked into WSUS in the last N days
        filter_older_than_days: 1
        # return a list of 'targets'
        format: targets'
```

#### Example query targets in specific groups from WSUS

Queries WSUS for computers who are members of specific groups (Servers_A, Servers_B) in
WSUS. It then combines the members from all groups specified into one list and returns
that as a list of Targets to Bolt (ie. a union of the members for groups specified).

``` yaml
---
version: 2.0

groups:
  - name: windows_wsus
    config:
      transport: winrm
      winrm:
        user: xxx
        password:
          _plugin: pkcs7
          encrypted_value: ENC[PKCS7,xxx]
        ssl: true
        ssl-verify: false
    vars:
      patching_order: 1
    groups:
      # grabs a list of groups from WSUS
      - _plugin: wsus_inventory
        # creds to login to the WSUS MSSQL database
        host: wsus.domain.tld
        database: 'SUSDB'
        username: DOMAIN\svc_wsus_bolt
        password:
          _plugin: pkcs7
          encrypted_value: ENC[PKCS7,xxx]     
        # remove hosts that haven't checked into WSUS in the last N days
        filter_older_than_days: 1
        # return a list of 'targets'
        format: targets'
        # Only return targets that are members of the following groups in WSUS
        # Since we are returning format: 'targets' we will return one big list of targets
        # for all computers in all of the following groups (big union)
        groups:
          - Servers_A
          - Servers_B
```

#### Example query all groups from WSUS

Queries WSUS for ALL groups, and returns group structures for each group in WSUS.
For each group in WSUS, we prefix the returned group name with `windows_wsus_` (specified
by the `group_name_prefix` parameter) and then append the WSUS group name.
Note: Bolt is picky about its group naming standards, so all WSUS group names
will be lowercased, and all non alpha-numeric (or `_`) characters will be replaced with `_`.

Example: 

``` shell

# configuration
group_name_prefix: 'windows_wsus'

# WSUS group name
Servers A

# resulting group data
- name: windows_wsus_servers_a
  targets:
    - host1
    - host2
    - host3
```


Below is the inventory to make this happen

``` yaml
---
version: 2.0

groups:
  - name: windows_wsus
    config:
      transport: winrm
      winrm:
        user: xxx
        password:
          _plugin: pkcs7
          encrypted_value: ENC[PKCS7,xxx]
        ssl: true
        ssl-verify: false
    vars:
      patching_order: 1
    groups:
      # grabs a list of groups from WSUS
      - _plugin: wsus_inventory
        # creds to login to the WSUS MSSQL database
        host: wsus.domain.tld
        database: 'SUSDB'
        username: DOMAIN\svc_wsus_bolt
        password:
          _plugin: pkcs7
          encrypted_value: ENC[PKCS7,xxx]
        # remove hosts that haven't checked into WSUS in the last N days
        filter_older_than_days: 1
        # return a list of 'groups', this could also be 'targets'
        format: 'groups'
        # insert windows_wsus_ before the group names we get from WSUS
        # so we will get groups like: windows_wsus_servers_a
        group_name_prefix: 'windows_wsus_'
```

#### Example query specific groups from WSUS

If we only want to return a specific set of groups, they can be specified 
in a list:

``` yaml
---
version: 2.0

groups:
  - name: windows_wsus
    config:
      transport: winrm
      winrm:
        user: xxx
        password:
          _plugin: pkcs7
          encrypted_value: ENC[PKCS7,xxx]
        ssl: true
        ssl-verify: false
    vars:
      patching_order: 1
    groups:
      # grabs a list of groups from WSUS
      - _plugin: wsus_inventory
        # creds to login to the WSUS MSSQL database
        host: wsus.domain.tld
        database: 'SUSDB'
        username: DOMAIN\svc_wsus_bolt
        password:
          _plugin: pkcs7
          encrypted_value: ENC[PKCS7,xxx]
        # remove hosts that haven't checked into WSUS in the last N days
        filter_older_than_days: 1
        # return a list of 'groups', this could also be 'targets'
        format: 'groups'
        # names of groups to extract from WSUS, these need to match exactly what is in WSUS
        # note: this will be downcased when returned because Bolt only allows lowercase names
        groups:
          - Servers_A
          - Servers_B
          - Servers_A_EDR
          - Servers_B_EDR
          - Servers_HV
        # insert windows_wsus_ before the group names we get from WSUS
        # so we will get groups like: windows_wsus_servers_a
        group_name_prefix: 'windows_wsus_'
```
