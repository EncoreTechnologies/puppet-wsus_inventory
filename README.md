# wsus_inventory

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

### Beginning with wsus_inventory

The very basic steps needed for a user to get the module up and running. This can include setup steps, if necessary, or it can be an example of the most basic use of the module.

## Usage

Include usage examples for common use cases in the **Usage** section. Show your users how to use your module to solve problems, and be sure to include code examples. Include three to five examples of the most important or common tasks a user can accomplish with your module. Show users how to accomplish more complex tasks that involve different types, classes, and functions working in tandem.

## Reference

This section is deprecated. Instead, add reference information to your code as Puppet Strings comments, and then use Strings to generate a REFERENCE.md in your module. For details on how to add code comments and generate documentation with Strings, see the Puppet Strings [documentation](https://puppet.com/docs/puppet/latest/puppet_strings.html) and [style guide](https://puppet.com/docs/puppet/latest/puppet_strings_style.html)

If you aren't ready to use Strings yet, manually create a REFERENCE.md in the root of your module directory and list out each of your module's classes, defined types, facts, functions, Puppet tasks, task plans, and resource types and providers, along with the parameters for each.

For each element (class, defined type, function, and so on), list:

  * The data type, if applicable.
  * A description of what the element does.
  * Valid values, if the data type doesn't make it obvious.
  * Default value, if any.

For example:

```
### `pet::cat`

#### Parameters

##### `meow`

Enables vocalization in your cat. Valid options: 'string'.

Default: 'medium-loud'.
```

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

In the Development section, tell other users the ground rules for contributing to your project and how they should submit their work.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should consider using changelog). You can also add any additional sections you feel are necessary or important to include here. Please use the `## ` header.
