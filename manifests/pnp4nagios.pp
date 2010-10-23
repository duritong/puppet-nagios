class nagios::pnp4nagios {
    include nagios::defaults::pnp4nagios

    package { [php5, php5-gd, rrdcollect, rrdtool, librrdp-perl, librrds-perl ]:
              ensure => installed }


    # unfortunatly i didn't find a way to use nagios_host and nagios_service definition, because 
    # imho puppet can't handle the "name" variable needed in these 2 definitions
    # so we need to copy a file here.
 
    file { 'pnp4nagios-templates.cfg':
         path => "$nagios::nagios_cfgdir/conf.d/pnp4nagios-templates.cfg",
         source => [ "puppet:///modules/site-nagios/pnp4nagios/pnp4nagios-templates.cfg",
                     "puppet:///modules/nagios/pnp4nagios/pnp4nagios-templates.cfg"    ]
    }
}
