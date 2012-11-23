define nagios::service::dns_host(
  $host_alias,
  $parent,
  $ip
){
  nagios_host{$name:
    address => $ip,
    alias => $host_alias,
    use => 'generic-host',
    parents => $parent,
  }

  nagios::service::dns{
    $host_name    => $name,
    $comment      => 'public_ns',
    $check_domain => 'glei.ch',
    $ip           => $ip,
  }
}
