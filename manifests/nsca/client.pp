class nagios::nsca::client {

  package { 'nsca': ensure => installed }
  
  file { '/etc/send_nsca.cfg':
    source => [ "puppet:///modules/site-nagios/nsca/{$fqdn}/send_nsca.cfg",
                "puppet:///modules/site-nagios/nsca/send_nsca.cfg",
                "puppet:///modules/nagios/nsca/send_nsca.cfg" ],
    owner  => 'nagios',
    group  => 'nogroup',
    mode   => '400',
  }

}
