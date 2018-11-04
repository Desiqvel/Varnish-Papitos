# puppet-varnish

# [![Forge Downloads](https://img.shields.io/puppetforge/dt/claranet/varnish.svg)](https://forge.puppetlabs.com/claranet/varnish)

#### Table of Contents

1. [Overview - What is the puppet-varnish module?](#overview)
1. [Module Description - What does the module do?](#module-description)
1. [Setup - The basics of getting started with puppet-varnish](#setup)
1. [Usage - Configuration options and additional functionality](#usage)
    * [Examples](#examples)
    * [Parameter Reference](#parameter-reference)
    * [Major Varnish version and Varnish package](#varnish-package)
1. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This module Installs and configures Varnish. Further built from diffrent Puppetforge modules.

## Puppet 3 Support

**Please note that the master branch of this module does not support Puppet 3!**

On 31st December 2016, support for Puppet 3.x was withdrawn. As such, this
module no longer supports Puppet 3.

## Module Description

This module Supports Varnish versions 3.0, 4.0, 4.1, 5.0, 5.1, 5.2, 6.0 and 6.1 across
Ubuntu 14.04/16.04/18.04, Debian 7/8 and RedHat derivates 6/7.

This module will install Varnish, **by default version 4.1** from the official
Packagecloud repositories, adding EPEL for RedHat-like systems and working
around a SELinux policy bug in RHEL/CentOS 6 for Varnish 4.0 and above.

It will also install and configure a Systemd service for certain OS/Varnish
combinations.

If necessary, you can specify any of the Varnish versions above, although there
are imcompatibilities with some versions of Varnish and some OS versions, see
[Limitations](#limitations).

## Setup

To accept all default parameters -

```puppet
  class { '::varnish':
  }
```

It is suggested at minimum you set a
secret (if not explicitly set, one will be created via
`/proc/sys/kernel/random/uuid`) and overwrite the packaged `default.vcl`.

```puppet
  class { '::varnish':
    secret => '6565bd1c-b6d1-4ba3-99bc-3c7a41ffd94f',
  }

  ::varnish::vcl { '/etc/varnish/default.vcl':
    content => template('data/varnish/default.vcl.erb'),
  }
```

### Multiple Listen Interfaces

Varnish supports listening on multiple interfaces. The module implements this
by exposing a `listen` parameter, which can either be set to a String value for
one interface (e.g. `127.0.0.1` or `0.0.0.0`), or an array of values.

By default, the the module will append `listen_port` to each element of the
array - however to set a different port for each interface, just append it
using standard notation, for example: `127.0.0.1:8080`.

## Usage

### Examples

To use a static file with `varnish::vcl` rather than a template:

```puppet
  ::varnish::vcl { '/etc/varnish/default.vcl':
   content => file('data/varnish/default.vcl'),
   # Equivalent to: source => 'puppet:///modules/data/varnish/default.vcl'
  }
```

To pin Varnish to a specific version - you may also provide `varnish_version`
as long as it matches the major and minor version in `package_ensure`, however
the module will automatically calculate `varnish_version` if not set:

```puppet
  class { '::varnish':
    package_ensure => '6.0.1-1~xenial',
    varnish_version => '6.0',
  }
```

To configure Varnish to listen on port 8080 on localhost and port 6081 on
`172.16.100.10`:

```puppet
  class { '::varnish':
    listen => ['127.0.0.1:8080','172.16.100.10:6081'],
  }
```

To configure Varnish to listen on port 80, specifically on localhost and
`192.168.1.195`:

```puppet
  class { '::varnish':
    listen      => ['127.0.0.1','192.168.1.195'],
    listen_port => '80',
  }
```

To use multiple storage backends in varnish for example a primary `4GB memory backend` and a `50GB file backend`:

```puppet
  class { '::varnish':
    storage_type => 'malloc',
    storage_size => '4G',
    storage_additional => [
      'file,/var/lib/varnish/varnish_additional.bin,50G',

    ]
  }
```

### Parameter Reference

|Parameter|Description|
|---------|-----------|
|addrepo|Whether to add the official Varnish repos|
|varnish_version|Major Varnish version, eg 4.1|
|package_ensure|Version of Varnish package to install, eg 4.1.10-1~xenial|
|secret|Secret for admin access|
|secret_file|File to store the secret|
|vcl_conf|Varnish vcl config file path|
|listen|IP to bind to in system/varnish.service|
|listen_port|TCP port to listen on|
|admin_listen|Admin interface IP to bind to|
|admin_port|TCP port for admin interface to listen on|
|min_threads|Minimum Varnish worker threads|
|max_threads|Maximum Varnish worker threads|
|thread_timeout|Terminate threads after this long idle|
|storage_type|malloc or file|
|storage_file|File to mmap on disk for cache storage|
|storage_size|Size of storage file or RAM, eg 10G or 50%|
|storage_additional|Hash of additional storage backends, passed plainly to varnishd -s after the normal configured storage backends|
|runtime_params|hash of run-time parameters to be specified at startup|
|noops|Module dry run|


### Major Varnish version and Varnish package (version minor)

|Version Major|version minor|
| --: | :-- |
|6.1|6.1.1|
|6.0|6.0.1|
|5.2|5.2.1|
|5.1|5.1.3|
|5.0|5.0.0|
|4.1|4.1.10|
|4.0|4.0.5|
|3.0|3.0.7|

## Limitations

There are several limitations with various Varnish and OS combinations. The
module will attempt to flag known issues, however:

* Varnish 3.0 is not supported on Ubuntu 16.04 and 18.04
* Varnish 4.0 supports **only** Debian Enterprice Linux 6/7, Debian 7/8/9 and Ubuntu 14.04
* Varnish 5.0 supports **only** Debian 8 and Ubuntu 16.04
* Varnish 6.0 and 6.1 supports **only** Enterprice Linux 7, Debian 9, Ubuntu 16.04 and 18.04
