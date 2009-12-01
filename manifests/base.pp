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
        path => '/etc/nagios',
        source => "puppet://$server/modules/common/empty",
        ensure => directory,
        recurse => true,
        purge => true,
        notify => Service[nagios],
        mode => 0755, owner => root, group => root;
    }
    # this file should contain all the nagios_puppet-paths:
    file {nagios_main_cfg:
            path => "/etc/nagios/nagios.cfg",
      source => [ "puppet://$server/modules/site-nagios/configs/${fqdn}/nagios.cfg",
                        "puppet://$server/modules/site-nagios/configs/${operatingsystem}/nagios.cfg",
                        "puppet://$server/modules/site-nagios/configs/nagios.cfg",
                        "puppet://$server/modules/nagios/configs/${operatingsystem}/nagios.cfg",
                        "puppet://$server/modules/nagios/configs/nagios.cfg" ],
            notify => Service[nagios],
            mode => 0644, owner => root, group => root;
    }
    file { nagios_cgi_cfg:
        path => "/etc/nagios/cgi.cfg",
        source => [ "puppet://$server/modules/site-nagios/configs/${fqdn}/cgi.cfg",
                    "puppet://$server/modules/site-nagios/configs/${operatingsystem}/cgi.cfg",
                    "puppet://$server/modules/site-nagios/configs/cgi.cfg",
                    "puppet://$server/modules/nagios/configs/${operatingsystem}/cgi.cfg",
                    "puppet://$server/modules/nagios/configs/cgi.cfg" ],
        owner => 'root',
        group => 0,
        mode => '0644',
        notify => Service['apache'],
    }

    file {"/etc/nagios/htpasswd.users":
            source => [
                "puppet://$server/modules/site-nagios/htpasswd.users",
                "puppet://$server/modules/nagios/htpasswd.users" ],
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

    nagios::plugin{'check_jabber_login': }

    nagios::command{
        ssh_port:
            command_line => '$USER1$/check_ssh -p $ARG1$ $HOSTADDRESS$';
        # from apache2.pp
        http_port:
            command_line => '$USER1$/check_http -p $ARG1$ -H $HOSTADDRESS$ -I $HOSTADDRESS$';
        # from bind.pp
        check_dig2:
           command_line => '$USER1$/check_dig -H $HOSTADDRESS$ -l $ARG1$ --record_type=$ARG2$';
        check_ntp_time:
            command_line => '$USER1$/check_ntp_time -H $HOSTADDRESS$ -w 0.5 -c 1';
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
        check_silc:
            command_line => '$USER1$/check_tcp -p 706 -H $ARG1$';
        check_sobby:
            command_line => '$USER1$/check_tcp -H $ARG1$ -p $ARG2$';
        check_jabber:
            command_line => '$USER1$/check_jabber -H $ARG1$';
        check_jabber_login:
            command_line => '$USER1$/check_jabber_login $ARG1$ $ARG2$',
            require => Nagios::Plugin['check_jabber_login'];
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

    if $nagios_allow_external_cmd {
        file{'/var/spool/nagios/cmd':
            ensure => 'directory',
            require => Package['nagios'],
            owner => apache, group => nagios, mode => 2660;
        }
    }
}
