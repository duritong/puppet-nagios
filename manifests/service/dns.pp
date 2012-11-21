define nagios::service::dns(
  $comment = $name,
  $check_domain  = $name,
  $ip
){
  if $name != $comment {
    $check_name = "${comment}_${name}_${::hostname}"
  } else {
    $check_name = "${name}_${::hostname}"
  }

  nagios::service{
    $check_name:
      check_command       => "check_dns2!${check_domain}!${ip}",
      host_name           => $::fqdn,
      service_description => "check if ${::fqdn} is resolving ${check_domain}";
  }
}
