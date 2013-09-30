Introduction/Notes
==================

This modules was inspired and based on the work of David Schmitt
The immerda project group adapted and improved this module. 
Mainly we made it using the new native puppet nagios commands
as well we made it more modular to fit for multidistro usage.

In it's current form, this module can be used on CentOS and Debian.


Overview
========

To use the nagios resources, activate storeconfigs on the
puppetmaster.

You need to be running verison 0.25 or later of puppet. 


Monitor
-------

On one node the `nagios` class has to be included. By default this installs
apache using the `apache` module. To use `lighttpd` instead, `include "nagios::lighttpd"`,
or, if the web server is not to be managed by puppet, `include "nagios::headless"`.


Hosts
-----

On a node which shall be monitored with nagios, `include the "nagios::target"`.
This just creates a host declaration for this host's `$::ipaddress` fact. If
the `$::ipaddress` of your target is not the one you wish to modify, you can use
`nagios::target::fqdn` instead, which will use the `$::fqdn` fact of the host instead.

Pass the $parents variable to the target class for enabling the reachability
features of nagios. If a node needs more customisation, use the
native `@@nagios_host` type directly (the double-ampersand declares the object
as an exported resource).

To monitor hosts not managed by puppet, add `nagios_host` objects to the
monitoring node. The required parameters are `alias`, `address` and `use`. If
you don't specify a proper nagios template with the `use` parameter, some extra
parameters are needed. You may look up the nagios documentation for this.


Services
--------

Services can be monitored by using the `nagios::service` component.

The simplest form is:

    nagios::service { 'check_http':
        check_command => 'http_port!80',
    }

The intention being obviously to put such declarations into a component defining
a service, thereby being automatically applied together with all instances of
the service.

Obviously, the check command must either be defined using nagios_command objects
(some are supplied in `nagios::defaults::commands`) or in the nagios configuration
files directly.

NRPE Services 
-------------

Some Nagios services need to be checked via NRPE. The following will make the
nagios server define a service that will check the NRPE command `check_cpu` on
the current node:

    nagios::service { 'CPU Usage':
      use_nrpe => 'true',
      check_command => "check_cpu",
      nrpe_args => "-t 60"
    }

NRPE Commands
-------------

To be able to call NRPE commands on a host, one needs to define that command
and what it is going to execute:

    nagios::nrpe::command { 'debsums':
      check_command => '/usr/lib/nagios/plugins/check_debsums openssh-server'
    }


Upgrade Notes
=============

The `nagios::target` bits have been reworked, the notable changes that
may affect an upgrade are:

  - previous versions had `nagios::target::nat` which used the `$::fqdn` for
the address part of `nagios::target`, this has been renamed to
`nagios::target::fqdn` to be more clear. if you were using
`nagios::target::nat` then you will need to change those references to
`::fqdn`

  - previous versions of this module used `$::fqdn` for the `nagios::target`
address, now it is using `$::ipaddress`. If you need `$::fqdn`, use
`nagios::target::fqdn` instead of `nagios::target`

  - previous versions of `nagios_host` used the parameter named `ip`, that
has been changed to `address`


IRC bot
=======

Notifications can easily be sent to an IRC channel by using a bot. To do so,
simply include `nagios::irc_bot` on the nagios server and define the right
`$nagios_nsa_*` variables (see the 'Variables' section below).

You can then use the notification commands `notify-by-irc` and
`host-notify-by-irc` with service and host definitions to make them report
state changes over IRC.

Caveats
=======


Consistency/Validation/Verification
-----------------------------------

After convergance of the configuration, the system is obviously consistent.
That is, all defined services are monitored. The problem is though, that it is
neither automatically valid - it is not guaranteed that all components declare a
`nagios::service` - and even if the configuration is valid it definitly is
unverified, since that is always a judgment call for an external observer.


Removal of nagios objects
-------------------------

This module does not automatically purge nagios objects such as hosts and
services that become absent from the manifests. One must set `ensure => absent`
to guarantee the removal of nagios objects from the configuration as desired.


Templates not supported using native types
------------------------------------------

Templates of hosts and services cannot yet be defined using native types. In
this module, they are provided using a file resource by the class
`nagios::defaults::templates`

See : http://projects.reductivelabs.com/issues/1180


Variables
=========

Options to change the behavior of the nagios class:

- `allow_external_cmd`: Set to true, if you'd like to ensure that your http
                      daemon can write to the external command file. You 
                      may also need to flip `check_external_commands` in
                      `nagios.cfg` to enable this functionality.

For the irc_bot class:

  - `nsa_socket`: This optional variable can be used to specify the path to
              the socket file that the IRC daemon should use.

  - `nsa_server`: When using the IRC bot, this defines the server address of
              the IRC network on which the bot will connect.

  - `nsa_port`: Defines the port number on the IRC server on which the bot
            should connect. When this variable is not set, the port used
            by default is 6667.

  - `nsa_nickname`: This is the nickname that the IRC bot will take.

  - `nsa_password`: Some networks require a password to connect to them.
                This defines such a password.

  - `nsa_channel`: The name of the channel that the IRC bot will join and
               will post notifications to.

  - `nsa_pidfile`: This optional variable can be used to define the path to
               the file that will contain the process ID of the IRC bot
               daemon.
  - `nsa_realname`: The IRC bot user's real name that will be displayed. By
                default, the real name is 'Nagios'.

  - `nsa_usenotices`: The IRC bot will by default "say" to the channel the
                  nagios message, but you can switch this variable to
                  'notice' if you would prefer them to be sent as IRC
                  NOTICE messages.

PNP4Nagios integration
======================

For PNP4Nagios integration information, please see README.pnp4nagios

Examples
========

Usage example:

    node nagios {

	include nagios::apache
	include nagios::defaults

	    # Declare another nagios command
	    nagios::command { http_port: command_line
		=> /usr/lib/nagios/plugins/check_http -p $ARG1$ -H $HOSTADDRESS$ -I $HOSTADDRESS$

	    # Declare unmanaged hosts
	    nagios_host {
		    'router01.mydomain.com':
			    alias => 'router01',
			notes => 'MyDomain Gateway',
			address => "10.0.0.1",
			use => 'generic-host';
		    "router02.mydomain.com":
			alias => 'router02',
			    address => '192.168.0.1',
			    parents => 'router01',
			use => 'generic-host';
	    }

     }


      node target {

	  # Monitor this host
	  class{'nagios::target':
	    parents = 'router01'
	  }

	  # monitor a service
	  $apache2_port = 8080
	  include apache2

	  # This actually does this somewhere:
	  #nagios::service { "http_${apache2_port}":
	  #       check_command => "http_port!${apache2_port}"
	  #}

      }

TODO
====

  - Provide a default http vhost
  - Add facility to deploy nagios plugins
  - Add more useful commands and services
  - When Puppet will support them, supply nagios templates using native types


License
=======

Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
See the file LICENSE in the top directory for the full license.

Copyright (C) 2010 Riseup Networks <micah@riseup.net>

