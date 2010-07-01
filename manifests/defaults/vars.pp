class nagios::defaults::vars {
  case $nagios_cfgdir {
    '': { $int_nagios_cfgdir = $operatingsystem ? {
            centos => '/etc/nagios/',
            default => '/etc/nagios3'
          }
    }
    default: { $int_nagios_cfgdir = $nagios_cfgdir }
  }
}
