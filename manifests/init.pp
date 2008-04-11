# nagios.pp - everything nagios related
# Copyright (C) 2007 David Schmitt <david@schmitt.edv-bus.at>
# See LICENSE for the full license granted to you.


# the directory containing all nagios configs:
$nagios_cfgdir = "/var/lib/puppet/modules/nagios"
modules_dir{ nagios: }

class nagios {
    case $operatingsystem {
        debian: { include nagios::debian }
        centos: { include nagios::centos }
        default: { include nagios::base }
    }
}

class nagios::debian inherits nagios::base {
    Package [nagios]{
            name => "nagios2",
    }
    package {
        "nagios-plugins-standard":
            ensure => installed,
    }
	Service[nagios] {
			# Current Debian/etch pattern
			pattern => "/usr/sbin/nagios2 -d /etc/nagios2/nagios.cfg",
			subscribe => File [ $nagios_cfgdir ]
	}
    File["$etc_nagios_path/htpasswd.users"]{
        group => www-data,
    }

    file {
        [ "/etc/nagios2/conf.d/localhost_nagios2.cfg",
          "/etc/nagios2/conf.d/extinfo_nagios2.cfg",
          "/etc/nagios2/conf.d/services_nagios2.cfg" ]:
            ensure => absent,
            notify => Service[nagios2];
    }
	# permit external commands from the CGI
    file {
       "/var/lib/nagios2":
            ensure => directory, mode => 751,
            owner => nagios, group => nagios,
            notify => Service[nagios2];
    }
    file{
        "/var/lib/nagios2/rw":
            ensure => directory, mode => 2710,
            owner => nagios, group => www-data,
            notify => Service[nagios2];

    }
	
	# TODO: these are not very robust!
	replace {
		# Debian installs a default check for the localhost. Since VServers
		# usually have no localhost IP, this fixes the definition to check the
		# real IP
		fix_default_config:
			file => "/etc/nagios2/conf.d/localhost_nagios2.cfg",
			pattern => "address *127.0.0.1",
			replacement => "address $ipaddress",
			notify => Service[nagios2];
		# enable external commands from the CGI
		enable_extcommands:
			file => "/etc/nagios2/nagios.cfg",
			pattern => "check_external_commands=0",
			replacement => "check_external_commands=1",
			notify => Service[nagios2];
		# put a cap on service checks
		cap_service_checks:
			file => "/etc/nagios2/nagios.cfg",
			pattern => "max_concurrent_checks=0",
			replacement => "max_concurrent_checks=30",
			notify => Service[nagios2];
	}
    
}
# end nagios::debian

class nagios::centos inherits nagios::base {
    package { [ 'nagios-plugins-smtp','nagios-plugins-http', 'nagios-plugins-ssh', 'nagios-plugins-udp', 'nagios-plugins-tcp', 'nagios-plugins-dig', 'nagios-plugins-nrpe', 'nagios-plugins-load', 'nagios-plugins-dns', 'nagios-plugins-ping', 'nagios-plugins-procs', 'nagios-plugins-users', 'nagios-plugins-ldap', 'nagios-plugins-disk', 'nagios-devel', 'nagios-plugins-swap', 'nagios-plugins-nagios', 'nagios-plugins-perl' ]:
        ensure => 'present',
    }
    Service[nagios]{
        hasstatus => true,
    }
    
}

class nagios::vars {
    case $operatingsystem {
        debian: {
            $etc_nagios_path =  "/etc/nagios2"
            }
        default: {
            $etc_nagios_path =  "/etc/nagios"
        }
    }
}


class nagios::base {

    package { nagios:
        ensure => present,   
    }

    service{nagios:
        ensure => running,
        enable => true,
        #hasstatus => true, #fixme!
        require => Package[nagios],
    }

    include nagios::vars
	
	# import the various definitions
	File <<| tag == 'nagios' |>>

    file {
		"$etc_nagios_path/htpasswd.users":
            source => [
                "puppet://$servername/files/nagios/htpasswd.users",
                "puppet://$servername/nagios/htpasswd.users"
            ],
            mode => 0640, owner => root, group => apache;
    }
    
    file {
        "$nagios_cfgdir/hosts.d":
            ensure => directory,
            owner => root,
            group => root,
            mode => 0755,
    }

	define command($command_line) {
		file { "$nagios_cfgdir/hosts.d/${name}_command.cfg":
				ensure => present, content => template( "nagios/command.erb" ),
				mode => 644, owner => root, group => root,
				notify => Service[nagios2],
		}
	}

	nagios2::command {
		# from ssh.pp
		ssh_port:
			command_line => '/usr/lib/nagios/plugins/check_ssh -p $ARG1$ $HOSTADDRESS$';
		# from apache2.pp
		http_port:
			command_line => '/usr/lib/nagios/plugins/check_http -p $ARG1$ -H $HOSTADDRESS$ -I $HOSTADDRESS$';
		# from bind.pp
		nameserver: command_line => '/usr/lib/nagios/plugins/check_dns -H www.edv-bus.at -s $HOSTADDRESS$';
		# TODO: debug this, produces copious false positives:
		# check_dig2: command_line => '/usr/lib/nagios/plugins/check_dig -H $HOSTADDRESS$ -l $ARG1$ --record_type=$ARG2$ --expected_address=$ARG3$ --warning=2.0 --critical=4.0';
		check_dig2: command_line => '/usr/lib/nagios/plugins/check_dig -H $HOSTADDRESS$ -l $ARG1$ --record_type=$ARG2$'
	}
    
	define host($ip = $fqdn, $short_alias = $fqdn) {
		@@file {
			"$nagios_cfgdir/${name}_host.cfg":
				ensure => present, content => template( "nagios/host.erb" ),
				mode => 644, owner => root, group => root,
				tag => 'nagios'
		}
	}

	define service($check_command = '', 
		$nagios2_host_name = $fqdn, $nagios2_description = '')
	{
		# this is required to pass nagios' internal checks:
		# every service needs to have a defined host
		include nagios2::target
		$real_check_command = $check_command ? {
			'' => $name,
			default => $check_command
		}
		$real_nagios2_description = $nagios2_description ? {
			'' => $name,
			default => $nagios2_description
		}
		@@file {
			"$nagios_cfgdir/${nagios2_host_name}_${name}_service.cfg":
				ensure => present, content => template( "nagios/service.erb" ),
				mode => 644, owner => root, group => root,
				tag => 'nagios'
		}
	}

	define extra_host($ip = $fqdn, $short_alias = $fqdn, $parent = "none") {
		$nagios_parent = $parent
		file {
			"$nagios_cfgdir/${name}_host.cfg":
				ensure => present, content => template( "nagios/host.erb" ),
				mode => 644, owner => root, group => root,
				notify => Service[nagios2],
		}
	}
	#
	# include this class in every host that should be monitored by nagios
	class target {
		nagios2::host { $fqdn: }
		debug ( "$fqdn has $nagios_parent as parent" )
	}
} # end nagios::base

#####################################################################################################
## The main nagios monitor class
#class nagios2 {
#
#	file {
#		"/etc/nagios2/conf.d/hostgroups_nagios2.cfg":
#			source => "puppet://$servername/nagios/hostgroups_nagios2.cfg",
#			mode => 0644, owner => root, group => www-data,
#			notify => Service[nagios2];
#	}
#
##	line { include_cfgdir:
##		file => "/etc/nagios2/nagios.cfg",
##		line => "cfg_dir=$nagios_cfgdir",
##		notify => Service[nagios2],
##	}
#
#	munin::plugin {
#		nagios_hosts: script_path => "/usr/local/bin";
#		nagios_svc: script_path => "/usr/local/bin";
#		nagios_perf_hosts: ensure => nagios_perf_, script_path => "/usr/local/bin";
#		nagios_perf_svc: ensure => nagios_perf_, script_path => "/usr/local/bin";
#	}
#
#	file { "/etc/munin/plugin-conf.d/nagios":
#		content => "[nagios_*]\nuser root\n",
#		mode => 0655, owner => root, group => root,
#		notify => Service[munin-node]
#	}
#
#}

