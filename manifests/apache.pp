class nagios::apache(
  $allow_external_cmd = false,
  $manage_shorewall = false,
  $manage_munin = false
) {
  class{'nagios':
    httpd => 'apache',
    allow_external_cmd => $allow_external_cmd,
    manage_munin => $manage_munin,
    manage_shorewall => $manage_shorewall,
  }

  case $::operatingsystem {
    'debian': {
      file { "${nagios::defaults::vars::int_cfgdir}/apache2.conf":
        ensure => present,
        source => [ "puppet:///site_nagios/configs/${::fqdn}/apache2.conf",
                    "puppet:///site_nagios/configs/apache2.conf",
                    "puppet:///nagios/configs/apache2.conf"],
      }

      apache::config::global { "nagios3.conf":
        ensure => link,
        target => "${nagios::defaults::vars::int_cfgdir}/apache2.conf",
        require => File["${nagios::defaults::vars::int_cfgdir}/apache2.conf"],
      }
    }
  }
}
