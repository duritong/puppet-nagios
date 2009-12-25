# this will define a host which isn't managed by puppet. 
# a ping serivce is automatically added
define nagios::extra_host(
    $ensure = present,
    $ip = 'absent',
    $nagios_alias = 'absent',
    $use = 'generic-host',
    $parents = 'localhost'
) {
    if $ensure == 'present' and ($ip == 'absent' or $nagios_alias == 'absent'){
      fail("You need to define \$ip and \$nagios_alias if extra_host should be present!")
    }
    nagios::host{$name:
        ensure => $ensure,
        ip => $ip,
        nagios_alias => $nagios_alias,
        use => $use,
        parents => $parents
    }

    nagios::service { "check_ping_${name}":
        ensure => $ensure,
        host_name => $name,
        check_command => 'check_ping!100.0,20%!500.0,60%',
        service_description => "check_ping_${nagios_alias}",
   }
}
