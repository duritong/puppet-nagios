# nagios.pp - everything nagios related
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.
# adapted and improved by admin(at)immerda.ch
# adapted by Puzzle ITC - haerry+puppet(at)puzzle.ch


# the directory containing all nagios configs:
$nagios_cfgdir = '/var/lib/puppet/modules/nagios'
modules_dir{ nagios: }

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
        mode => 0644, owner => root, group => root;
    }

    # old way of commands to not break the current config
    # TODO: integrate these commands into native nagios types
    file{ "/etc/nagios/legacy/":
        source => "puppet://$server/files/nagios/legacy",
        ensure => directory,
        recurse => true,
        purge => true,
        notify => Service[nagios],
        mode => 0755, owner => root, group => 0;
    }
	
    nagios_command{ssh_port:
			command_line => '$USER1/check_ssh -p $ARG1$ $HOSTADDRESS$';
		# from apache2.pp
		http_port:
			command_line => '$USER1/check_http -p $ARG1$ -H $HOSTADDRESS$ -I $HOSTADDRESS$';
		# from bind.pp
		check_dig2: 
            command_line => '$USER1/check_dig -H $HOSTADDRESS$ -l $ARG1$ --record_type=$ARG2$'
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

    if defined(Class["munin::client"]) {
        include munin::plugins::nagios
    }
} # end nagios::base

class nagios::centos inherits nagios::base {
    package { [ 'nagios-plugins-smtp','nagios-plugins-http', 'nagios-plugins-ssh', 'nagios-plugins-udp', 'nagios-plugins-tcp', 'nagios-plugins-dig', 'nagios-plugins-nrpe', 'nagios-plugins-load', 'nagios-plugins-dns', 'nagios-plugins-ping', 'nagios-plugins-procs', 'nagios-plugins-users', 'nagios-plugins-ldap', 'nagios-plugins-disk', 'nagios-devel', 'nagios-plugins-swap', 'nagios-plugins-nagios', 'nagios-plugins-perl' ]:
        ensure => 'present',
        before => Service[nagios],
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
        notify => Service['apache'],
    }
    file{"/etc/nagios/private/":
        source => "puppet://$server/nagios/empty",
        ensure => directory,
        purge => true,
        recurse => true,
        mode => '0750', owner => root, group => nagios;
    }
    file{"/etc/nagios/private/resource.cfg":
        source => "puppet://$server/nagios/configs/${operatingsystem}/private/resource.cfg.${architecture}",
        owner => root, group => nagios, mode => '0640';
    }
}

class nagios::target {
    include nagios::target::host
    nagios::service::ping{$fqdn:}
}

class nagios::target::host {
    $real_nagios_parent = $nagios_parent ? {
        '' => 'none',
        default => $nagios_parent
    }
    nagios::host { $fqdn: parents => $real_nagios_parent }
}

# defines
define nagios::host(
    $ip = $fqdn, 
    $nagios_alias = $hostname, 
    $use = 'generic-host', 
    $parents = 'none' ) 
{
    @@nagios_host { $name:
        ensure => present,
        alias => $nagios_alias,
        address => $ip,
        use => $use,
    }
    case $parents {
        'none': {}
        default: {
            Nagios_host[$name]{
                parents => $parents,
            }
        }
    }
}

# this will define a host which isn't managed by puppet. 
# a ping serivce is automatically added
# please note:
# - you can use it only on the nagios master (no exported resources)
# - you can not use this host for any other services!
define nagios::extra_host($ip, $nagios_alias, $host_use = 'generic-host', $parents = 'none' ) {
    nagios::host{$name:
        ip => $ip, 
        nagios_alias => $nagios_alias, 
        use => $use, 
        parents => $parents 
    }
    nagios_service { "check_ping_${name}":
        check_command => "check_ping!100.0,20%!500.0,60%",
        use => "generic-service",
        host_name => $ip,
        notification_period => "24x7",
        service_description => "${alias}_check_ping"
   }
}

define nagios::service(
    $check_command, 
	$host_name = $fqdn, 
    $use = 'generic-service',
    $notification_period = "24x7",
    $service_description = ''){


    # this is required to pass nagios' internal checks:
    # every service needs to have a defined host
    include nagios::target::host

    @@nagios_service {$name:
        check_command => $check_command,
        use => $use,
        host_name => $host_name,
        notification_period => $notification_period,
    }
    # if no service_description is set it is a namevar
    case $service_description {
        '': {}
        default: {
            Nagios_service[$name]{
                service_description => $service_description,
            }
        }
    }
}

define nagios::service::ping($host_name = $hostname ){
    nagios::service{ "check_ping_${hostname}":
        check_command => "check_ping!100.0,20%!500.0,60%",
        host_name => $host_name,
    }
}

class nagios::service::ntp {
    nagios::service{ "check_ntp_${hostname}":
        check_command => "check_ntp",
        host_name => $fqdn,
    }
}
