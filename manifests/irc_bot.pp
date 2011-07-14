class nagios::irc_bot {
  if ( ! ($nagios_nsa_server and $nagios_nsa_nickname and $nagios_nsa_channel) ) {
    fail("Please provide values at least for \$nagios_nsa_server, \$nagios_nsa_nickname and \$nagios_nsa_channel")
  }

  case $operatingsystem {
    centos: {
      $nagios_nsa_default_socket = '/var/run/nagios-nsa/nsa.socket'
      $nagios_nsa_default_pidfile = '/var/run/nagios-nsa/nsa.pid'
      include nagios::irc_bot::centos
    }
    default: {
      $nagios_nsa_default_socket = '/var/run/nagios3/nsa.socket'
      $nagios_nsa_default_pidfile = '/var/run/nagios3/nsa.pid'
      include nagios::irc_bot::base
    }
  }

  if $use_shorewall {
    include shorewall::rules::out::irc
  }
}
