# this will define a host which isn't managed by puppet. 
# a ping serivce is automatically added
define nagios::extra_host(
    $ensure = present,
    $ip,
    $nagios_alias,
    $use = 'generic-host',
    $parents = 'localhost'
) {
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
