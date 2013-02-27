class nagios::pnp4nagios {
  include nagios::defaults::pnp4nagios

  package { 'pnp4nagios':
            ensure => installed }


  # unfortunatly we can't use the nagios_host and nagios_service
  # definition to define templates, so we need to copy a file here.
  # see http://projects.reductivelabs.com/issues/1180 for this limitation

  file { 'pnp4nagios-templates.cfg':
    path   => "${nagios::defaults::vars::int_cfgdir}/conf.d/pnp4nagios-templates.cfg",
    source => [ 'puppet:///modules/site_nagios/pnp4nagios/pnp4nagios-templates.cfg',
                'puppet:///modules/nagios/pnp4nagios/pnp4nagios-templates.cfg' ],
    mode   => '0644',
    owner  => root,
    group  => root,
    notify => Service['nagios'],
  }

  file { 'apache.conf':
    path    => '/etc/pnp4nagios/apache.conf',
    source  => [ 'puppet:///modules/site_nagios/pnp4nagios/apache.conf',
                 'puppet:///modules/nagios/pnp4nagios/apache.conf' ],
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service['apache'],
    require => Package['pnp4nagios'],
  }

  # run npcd as daemon

  file { '/etc/default/npcd':
    path   => '/etc/default/npcd',
    source => [ 'puppet:///modules/site_nagios/pnp4nagios/npcd',
                'puppet:///modules/nagios/pnp4nagios/npcd' ],
    mode   => '0644',
    owner  => root,
    group  => root,
    notify => Service['npcd'];
  }

  service { 'npcd':
      ensure    => running,
      enable    => true,
      hasstatus => true,
      require   => Package['pnp4nagios'],
  }

  # modify action.gif

  file { '/usr/share/nagios3/htdocs/images/action.gif':
    path   => '/usr/share/nagios3/htdocs/images/action.gif',
    source => [ 'puppet:///modules/site_nagios/pnp4nagios/action.gif',
                'puppet:///modules/nagios/pnp4nagios/action.gif' ],
    mode   => '0644',
    owner  => root,
    group  => root,
    notify => Service['nagios'];
  }
}
