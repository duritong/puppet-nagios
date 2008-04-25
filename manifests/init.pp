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
        debian: { include nagios::debian }
        centos: { include nagios::centos }
        default: { include nagios::base }
    }
}

class nagios::vars {
    case $operatingsystem {
        debian: {
            $etc_nagios_path =  '/etc/nagios2'
            }
        default: {
            $etc_nagios_path =  '/etc/nagios'
        }
    }
}

class nagios::base {

    include nagios::vars

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
        path => "$etc_nagios_path",
        source => "puppet://$server/nagios/empty",
        ensure => directory,
        recurse => true,
        purge => true,
        notify => Service[nagios],
        mode => 0755, owner => root, group => root;
    }
    # this file should contain _only_ the nagios_puppet_template-path:
    # cfg_file=/etc/nagios/puppet_cfgpaths.cfg
    file {nagios_main_cfg: 
            path => "$etc_nagios_path/nagios.cfg",
			source => [ "puppet://$server/files/nagios/${fqdn}/nagios.cfg",
                    "puppet://$server/files/nagios/$operatingsystem/nagios.cfg.$lsbdistrelease",
                    "puppet://$server/files/nagios/$operatingsystem/nagios.cfg",
                    "puppet://$server/files/nagios/nagios.cfg",
                    "puppet://$server/nagios/$operatingsystem/nagios.cfg.$lsbdistrelease",
                    "puppet://$server/nagios/$operatingsystem/nagios.cfg",
                    "puppet://$server/nagios/nagios.cfg" ],
            notify => Service[nagios],
            mode => 0644, owner => root, group => root;
    }    
    # here is this magic file containing all relevant paths
    file {nagios_puppet_cfg_paths:
        path => "$etc_nagios_path/puppet_cfgpaths.cfg",
        source => [ "puppet://$server/files/nagios/${fqdn}/puppet_cfgpaths.cfg",
                    "puppet://$server/files/nagios/$operatingsystem/puppet_cfgpaths.cfg.$lsbdistrelease",
                    "puppet://$server/files/nagios/$operatingsystem/puppet_cfgpaths.cfg",
                    "puppet://$server/files/nagios/puppet_cfgpaths.cfg",
                    "puppet://$server/nagios/$operatingsystem/puppet_cfgpaths.cfg.$lsbdistrelease",
                    "puppet://$server/nagios/$operatingsystem/puppet_cfgpaths.cfg",
                    "puppet://$server/nagios/puppet_cfgpaths.cfg" ],
        notify => Service[nagios],
        mode => 0644, owner => root, group => root;
    }
    file { nagios_cgi_cfg:
        path => "$etc_nagios_path/cgi.cfg",
        source => [ "puppet://$server/files/nagios/${fqdn}/cgi.cfg",
                    "puppet://$server/files/nagios/$operatingsystem/cgi.cfg.$lsbdistrelease",
                    "puppet://$server/files/nagios/$operatingsystem/cgi.cfg",
                    "puppet://$server/files/nagios/cgi.cfg",
                    "puppet://$server/nagios/$operatingsystem/cgi.cfg.$lsbdistrelease",
                    "puppet://$server/nagios/$operatingsystem/cgi.cfg",
                    "puppet://$server/nagios/cgi.cfg" ],
        owner => 'root',
        group => 0,
        mode => '0644',
        notify => Service['apache'],
    }
    
	file {"$etc_nagios_path/htpasswd.users":
            source => [
                "puppet://$server/files/nagios/htpasswd.users",
                "puppet://$server/nagios/htpasswd.users"
            ],
            mode => 0640, owner => root, group => apache;
    }

    file{[ "$etc_nagios_path/nagios_command.cfg", 
           "$etc_nagios_path/nagios_contact.cfg", 
           "$etc_nagios_path/nagios_contactgroup.cfg",
           "$etc_nagios_path/nagios_host.cfg",
           "$etc_nagios_path/nagios_hostextinfo.cfg",
           "$etc_nagios_path/nagios_hostgroup.cfg",
           "$etc_nagios_path/nagios_hostgroupescalation.cfg",
           "$etc_nagios_path/nagios_service.cfg",
           "$etc_nagios_path/nagios_servicedependency.cfg",
           "$etc_nagios_path/nagios_serviceescalation.cfg",
           "$etc_nagios_path/nagios_serviceextinfo.cfg",
           "$etc_nagios_path/nagios_timeperdiod.cfg" ]:
        ensure => file,
        replace => false,
        notify => Service[nagios],
        mode => 0644, owner => root, group => root;
    }

    # old way of commands to not break the current config
    # TODO: integrate these commands into native nagios types
    file{ "$etc_nagios_path/legacy":
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
        path => "$etc_nagios_path/commands.cfg",
        source => [ "puppet://$server/nagios/$operatingsystem/commands.cfg.$lsbdistrelease",
                    "puppet://$server/nagios/$operatingsystem/commands.cfg" ],
        owner => 'root',
        group => 0,
        mode => '0644',
        notify => Service['apache'],
    }
    file{"$etc_nagios_path/private/":
        source => "puppet://$server/nagios/empty",
        ensure => directory,
        purge => true,
        recurse => true,
        mode => '0750', owner => root, group => nagios;
    }
    file{"$etc_nagios_path/private/resource.cfg":
        source => "puppet://$server/nagios/$operatingsystem/private/resource.cfg.$architecture",
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
define nagios::service::ntp($host_name = $hostname ){
    nagios::service{ "check_ntp_${hostname}":
        check_command => "check_ntp",
        host_name => $host_name,
    }
}
