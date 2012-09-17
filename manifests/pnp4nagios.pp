class nagios::pnp4nagios {
  include nagios::defaults::pnp4nagios

  package { pnp4nagios:
            ensure => installed }


  # unfortunatly i didn't find a way to use nagios_host and nagios_service definition, because 
  # imho puppet can't handle the "name" variable needed in these 2 definitions
  # so we need to copy a file here.

  file { 'pnp4nagios-templates.cfg':
    path => "$nagios::nagios_cfgdir/conf.d/pnp4nagios-templates.cfg",
    source => [ "puppet:///modules/site-nagios/pnp4nagios/pnp4nagios-templates.cfg",
                "puppet:///modules/nagios/pnp4nagios/pnp4nagios-templates.cfg" ],
    mode   => 0644, owner => root, group => root;
  }
  
  file { 'apache.conf':
    path => "/etc/pnp4nagios/apache.conf",
    source => [ "puppet:///modules/site-nagios/pnp4nagios/apache.conf",
            "puppet:///modules/nagios/pnp4nagios/apache.conf" ],
    mode   => 0644, owner => root, group => root,
    notify => Service['apache'];
  }

  # run npcd as daemon

  file { '/etc/default/npcd':
    path => "/etc/default/npcd",
    source => [ "puppet:///modules/site-nagios/pnp4nagios/npcd",
            "puppet:///modules/nagios/pnp4nagios/npcd" ],
    mode   => 0644, owner => root, group => root,
    notify => Service['npcd'];
  }

  service { 'npcd':
      ensure => running,
      enable => true,
      hasstatus => true, 
      require => Package['npcd'],
  }
  

}
