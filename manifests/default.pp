define nagios::default {

    file { "nagios_default_${name}" :
        path => "${nagios::nagios_cfg_dir}/defaults/${name}.cfg",
        source => [ "puppet://$server/files/nagios/configs/${fqdn}/defaults/${name}.cfg",
                    "puppet://$server/files/nagios/configs/${operatingsystem}/defaults/${name}.cfg",
                    "puppet://$server/files/nagios/configs/defaults/${name}.cfg",
                    "puppet://$server/nagios/configs/${operatingsystem}/defaults/${name}.cfg",
                    "puppet://$server/nagios/configs/defaults/${name}.cfg" ],
        notify => Service['nagios'],
        ensure => absent,
        mode => 0644, owner => root, group => root;
    }

}
