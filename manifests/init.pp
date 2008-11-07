#
# nagios module
# nagios.pp - everything nagios related
#
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# Copyright 2008, admin(at)immerda.ch
# Copyright 2008, Puzzle ITC GmbH
# Marcel Härry haerry+puppet(at)puzzle.ch
# Simon Josi josi+puppet(at)puzzle.ch
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

import 'defines.pp'

class nagios {
    case $operatingsystem {
        centos: { include nagios::centos }
        default: { fail("No such operatingsystem: $operatingsystem yet defined") }
    }
}

class nagios::base {

    # needs apache to work
    include apache

    package { nagios:
        ensure => present,   
    }

    service{nagios:
        ensure => running,
        enable => true,
        #hasstatus => true, #fixme!
        require => Package[nagios],
    }

    # manage nagios cfg files
    file {nagios_cfg_dir:
        path => "/etc/nagios/",
        source => "puppet://$server/nagios/empty",
        ensure => directory,
        recurse => true,
        purge => true,
        notify => Service[nagios],
        mode => 0755, owner => root, group => root;
    }
    # this file should contain all the nagios_puppet-paths:
    file {nagios_main_cfg: 
            path => "/etc/nagios/nagios.cfg",
			source => [ "puppet://$server/files/nagios/configs/${fqdn}/nagios.cfg",
                        "puppet://$server/files/nagios/configs/${operatingsystem}/nagios.cfg",
                        "puppet://$server/files/nagios/configs/nagios.cfg",
                        "puppet://$server/nagios/configs/${operatingsystem}/nagios.cfg",
                        "puppet://$server/nagios/configs/nagios.cfg" ],
            notify => Service[nagios],
            mode => 0644, owner => root, group => root;
    }    
    file { nagios_cgi_cfg:
        path => "/etc/nagios/cgi.cfg",
        source => [ "puppet://$server/files/nagios/configs/${fqdn}/cgi.cfg",
                    "puppet://$server/files/nagios/configs/${operatingsystem}/cgi.cfg",
                    "puppet://$server/files/nagios/configs/cgi.cfg",
                    "puppet://$server/nagios/configs/${operatingsystem}/cgi.cfg",
                    "puppet://$server/nagios/configs/cgi.cfg" ],
        owner => 'root',
        group => 0,
        mode => '0644',
        notify => Service['apache'],
    }
    
	file {"/etc/nagios/htpasswd.users":
            source => [
                "puppet://$server/files/nagios/htpasswd.users",
                "puppet://$server/nagios/htpasswd.users" ],
            mode => 0640, owner => root, group => apache;
    }

    file{[ "/etc/nagios/nagios_command.cfg", 
           "/etc/nagios/nagios_contact.cfg", 
           "/etc/nagios/nagios_contactgroup.cfg",
           "/etc/nagios/nagios_host.cfg",
           "/etc/nagios/nagios_hostextinfo.cfg",
           "/etc/nagios/nagios_hostgroup.cfg",
           "/etc/nagios/nagios_hostgroupescalation.cfg",
           "/etc/nagios/nagios_service.cfg",
           "/etc/nagios/nagios_servicedependency.cfg",
           "/etc/nagios/nagios_serviceescalation.cfg",
           "/etc/nagios/nagios_serviceextinfo.cfg",
           "/etc/nagios/nagios_timeperdiod.cfg" ]:
        ensure => file,
        replace => false,
        notify => Service[nagios],
        mode => 0644, owner => root, group => 0;
    }

    nagios::command{
        ssh_port:
			command_line => '$USER1$/check_ssh -p $ARG1$ $HOSTADDRESS$';
		# from apache2.pp
		http_port:
			command_line => '$USER1$/check_http -p $ARG1$ -H $HOSTADDRESS$ -I $HOSTADDRESS$';
		# from bind.pp
		check_dig2: 
            command_line => '$USER1$/check_dig -H $HOSTADDRESS$ -l $ARG1$ --record_type=$ARG2$';
        check_ntp:
            command_line => '$USER1$/check_ntp -H $HOSTADDRESS$ -w 0.5 -c 1';
        check_http_url:
            command_line => '$USER1$/check_http -H $ARG1$ -u $ARG2$';
        check_http_url_regex:
            command_line => '$USER1$/check_http -H $ARG1$ -u $ARG2$ -e $ARG3$';
        check_https_url:
            command_line => '$USER1$/check_http --ssl -H $ARG1$ -u $ARG2$';
        check_https_url_regex:
            command_line => '$USER1$/check_http --ssl -H $ARG1$ -u $ARG2$ -e $ARG3$';
        check_https:
            command_line => '$USER1$/check_http -S -H $HOSTADDRESS$';
	}

    Nagios_command <<||>>
    Nagios_contact <<||>>
    Nagios_contactgroup <<||>>
    Nagios_host <<||>>
    Nagios_hostextinfo <<||>>
    Nagios_hostgroup <<||>>
    Nagios_hostgroupescalation <<||>>
    Nagios_service <<||>>
    Nagios_servicedependency <<||>>
    Nagios_serviceescalation <<||>>
    Nagios_serviceextinfo <<||>>
    Nagios_timeperiod <<||>>

    if $use_munin {
        include munin::plugins::nagios
    }
} # end nagios::base

class nagios::centos inherits nagios::base {
    package { [ 'nagios-plugins-smtp','nagios-plugins-http', 'nagios-plugins-ssh', 'nagios-plugins-udp', 'nagios-plugins-tcp', 'nagios-plugins-dig', 'nagios-plugins-nrpe', 'nagios-plugins-load', 'nagios-plugins-dns', 'nagios-plugins-ping', 'nagios-plugins-procs', 'nagios-plugins-users', 'nagios-plugins-ldap', 'nagios-plugins-disk', 'nagios-plugins-swap', 'nagios-plugins-nagios', 'nagios-plugins-perl', 'nagios-plugins-ntp', 'nagios-plugins-snmp' ]:
        ensure => 'present',
        notify => Service[nagios],
    }

    Service[nagios]{
        hasstatus => true,
    }

    # default cmd file from rpm
    # don't forget it to add to the puppet paths
    file { nagios_commands_cfg:
        path => "/etc/nagios/commands.cfg",
        source => [ "puppet://$server/files/nagios/configs/${fqdn}/commands.cfg",
                    "puppet://$server/files/nagios/configs/${operatingsystem}/commands.cfg",
                    "puppet://$server/nagios/configs/${operatingsystem}/commands.cfg" ],
        owner => 'root',
        group => 0,
        mode => '0644',
        notify => Service[nagios],
    }
    # default file from rpm
    file { nagios_localhost_cfg:
        path => "/etc/nagios/localhost.cfg",
        source => [ "puppet://$server/files/nagios/configs/${fqdn}/localhost.cfg",
                    "puppet://$server/files/nagios/configs/${operatingsystem}/localhost.cfg",
                    "puppet://$server/nagios/configs/${operatingsystem}/localhost.cfg" ],
        owner => 'root',
        group => 0,
        mode => '0644',
        notify => Service[nagios],
    }
    file{"/etc/nagios/private/":
        source => "puppet://$server/nagios/empty",
        ensure => directory,
        purge => true,
        recurse => true,
        notify => Service[nagios],
        mode => '0750', owner => root, group => nagios;
    }
    file{"/etc/nagios/private/resource.cfg":
        source => "puppet://$server/nagios/configs/${operatingsystem}/private/resource.cfg.${architecture}",
        notify => Service[nagios],
        owner => root, group => nagios, mode => '0640';
    }
}
