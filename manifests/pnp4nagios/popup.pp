class nagios::pnp4nagios::popup inherits nagios::pnp4nagios { 
    File['pnp4nagios-templates.cfg']{
         path => "$nagios::nagios_cfgdir/conf.d/pnp4nagios-templates.cfg",
         source => [ "puppet:///modules/site-nagios/pnp4nagios/pnp4nagios-popup-templates.cfg",
                     "puppet:///modules/nagios/pnp4nagios/pnp4nagios-popup-templates.cfg"    ]
    }

    file { "/usr/share/$nagios::nagios_packagename/htdocs/ssi":
        ensure => directory }

    file { 'status-header.ssi':
        path => "/usr/share/$nagios::nagios_packagename/htdocs/ssi/status-header.ssi",
        source => [ "puppet:///modules/site-nagios/pnp4nagios/status-header.ssi",
                    "puppet:///modules/nagios/pnp4nagios/status-header.ssi"    ]
    }

}
