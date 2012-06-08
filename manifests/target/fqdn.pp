class nagios::target::fqdn(
  $hostgroups = 'absent',
  $parents = 'absent'
) {
  class{'nagios::target':
    address => $::fqdn,
    hostgroups => $hostgroups,
    parents => $parents
  }
}
