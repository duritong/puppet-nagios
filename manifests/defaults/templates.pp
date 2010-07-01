class nagios::defaults::templates {
    include nagios::defaults::vars

    file { 'nagios_templates':
            path => "${nagios::defaults::vars::int_nagios_cfgdir}/conf.d/nagios_templates.cfg",
            source => [ "puppet://$server/modules/site-nagios/configs/${fqdn}/nagios_templates.cfg",
                        "puppet://$server/modules/site-nagios/configs/${operatingsystem}/nagios_templates.cfg",
                        "puppet://$server/modules/site-nagios/configs/nagios_templates.cfg",
                        "puppet://$server/modules/nagios/configs/${operatingsystem}/nagios_templates.cfg",
                        "puppet://$server/modules/nagios/configs/nagios_templates.cfg" ],
            notify => Service['nagios'],
            mode => 0644, owner => root, group => root;
    }

}
