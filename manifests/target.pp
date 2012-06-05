# manifests/target.pp

class nagios::target(
  $parents = 'absent',
) {

    @@nagios_host { $::fqdn:
        address => $::ipaddress,
        alias => $::hostname,
        use => 'generic-host',
    }

    if ($parents != 'absent') {
        Nagios_host["${::fqdn}"] { parents => $parents }
    }

}
