# manifests/target.pp

class nagios::target(
  $parents = 'absent',
  $address = $::ipaddress,
  $nagios_alias = $::hostname,
  $hostgroups = 'absent',
){
  @@nagios_host { $::fqdn:
    address => $address,
    alias => $nagios_alias,
    use => 'generic-host',
  }

  if ($parents != 'absent') {
    Nagios_host["${::fqdn}"] { parents => $parents }
  }

  if ($hostgroups != 'absent') {
    Nagios_host["${::fqdn}"] { hostgroups => $hostgroups }  
  }
}
