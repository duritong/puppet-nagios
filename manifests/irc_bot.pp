class nagios::irc_bot {
    if ( ! ($nagios_nsa_server and $nagios_nsa_nickname and $nagios_nsa_channel) ) {
        fail("Please provide values at least for \$nagios_nsa_server, \$nagios_nsa_nickname and \$nagios_nsa_channel")
    }

    $nagios_nsa_socket = $nagios_nsa_socket ? {
        '' => $operatingsystem ? {
          centos => '/var/run/nagios-nsa/nsa.socket',
          default => '/var/run/nagios3/nsa.socket'
        },
        default => $nagios_nsa_socket,
    }
    $nagios_nsa_pidfile = $nagios_nsa_pidfile ? {
        '' => $operatingsystem ? {
          centos => '/var/run/nagios-nsa/nsa.pid',
          default => '/var/run/nagios3/nsa.pid'
        },
        default => $nagios_nsa_pidfile,
    }
    $nagios_nsa_port = $nagios_nsa_port ? {
        '' => '6667',
        default => $nagios_nsa_port,
    }
    $nagios_nsa_realname = $nagios_nsa_realname ? {
        '' => 'Nagios',
        default => $nagios_nsa_realname,
    }

    if (! $nagios_nsa_password) {
        $nagios_nsa_password = ''
    }

    file { "/usr/local/bin/riseup-nagios-client.pl":
        owner => root, group => root, mode => 0755,
        source => "puppet:///modules/nagios/irc_bot/riseup-nagios-client.pl",
    }
    file { "/usr/local/bin/riseup-nagios-server.pl":
        owner => root, group => root, mode => 0755,
        source => "puppet:///modules/nagios/irc_bot/riseup-nagios-server.pl",
    }
    file { "/etc/init.d/nagios-nsa":
        owner => root, group => root, mode => 0755,
        content => template("nagios/irc_bot/${operatingsystem}/nagios-nsa.sh.erb"),
        require => File["/usr/local/bin/riseup-nagios-server.pl"],
    }
    file { "/etc/nagios_nsa.cfg":
        ensure => present,
        owner => nagios, group => root, mode => 0400,
        content => template('nagios/irc_bot/nsa.cfg.erb'),
    }

    package { "libnet-irc-perl":
        ensure => present,
    }

    service { "nagios-nsa":
        ensure => "running",
        hasstatus => true,
        require => [File["/etc/nagios_nsa.cfg"],
                    Package["libnet-irc-perl"],
                    Service['nagios'] ],
    }

    case $operatingsystem {
      centos: {
        Package['libnet-irc-perl']{
          name => 'perl-Net-IRC',  
        }
        Service['nagios-nsa']{
          enable => true,
        }
      }  
      debian,ubuntu: {
        exec { "nagios_nsa_init_script":
          command => "/usr/sbin/update-rc.d nagios-nsa defaults",
          unless => "/bin/ls /etc/rc3.d/ | /bin/grep nagios-nsa",
          require => File["/etc/init.d/nagios-nsa"],
          before => Service['nagios-nsa'],
        }
      }
    }

    nagios_command {
        "notify-by-irc":
            command_line => '/usr/local/bin/riseup-nagios-client.pl "$HOSTNAME$ ($SERVICEDESC$) $NOTIFICATIONTYPE$ n.$SERVICEATTEMPT$ $SERVICESTATETYPE$ $SERVICEEXECUTIONTIME$s $SERVICELATENCY$s $SERVICEOUTPUT$ $SERVICEPERFDATA$"';
        "host-notify-by-irc":
            command_line => '/usr/local/bin/riseup-nagios-client.pl "$HOSTNAME$ ($HOSTALIAS$) $NOTIFICATIONTYPE$ n.$HOSTATTEMPT$ $HOSTSTATETYPE$ took $HOSTEXECUTIONTIME$s $HOSTOUTPUT$ $HOSTPERFDATA$ $HOSTLATENCY$s"';
    }

    if $use_shorewall {
      include shorewall::rules::out::irc
    }
}
