# manifests/defines.pp

define nagios::host(
    $ensure = present,
    $ip = $fqdn, 
    $nagios_alias = $hostname, 
    $check_command = 'check-host-alive',
    $max_check_attempts = 4,
    $notification_interval = 120,
    $notification_period = '24x7',
    $notification_options = 'd,r',
    $use = 'generic-host', 
    $nagios_contact_groups_in = $nagios_contact_groups,
    $parents = 'localhost' ) 
{
    $real_nagios_contact_groups = $nagios_contact_groups_in ? {
        '' => 'admins',
        default => $nagios_contact_groups_in
    }
    $real_nagios_parents = $parents ? {
        '' => 'localhost',
        default => $parents
    }
    
    @@nagios_host { $name:
        ensure => $ensure,
        address => $ip,
        alias => $nagios_alias,
        check_command => $check_command,
        max_check_attempts => $max_check_attempts,
        notification_interval => $notification_interval,
        notification_period => $notification_period,
        notification_options => $notification_options,
        parents => $real_nagios_parents,
        contact_groups => $real_nagios_contact_groups,
        use => $use,
        notify => Service[nagios],
    }
}

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
        host_name => $name,
        service_description => "check_ping_${nagios_alias}",
   }
}

# just a wrapper to make the notify more easy
define nagios::command(
  $ensure = present,
  $command_line
){
    nagios_command{$name:
        ensure => $ensure,
        command_line => $command_line,
        notify => Service[nagios],
    }
}

define nagios::service(
    $ensure = present,
    $check_command,
    $host_name = $fqdn,
    $use = 'generic-service',
    $notification_period = "24x7",
    $max_check_attempts = 4,
    $retry_check_interval = 1,
    $notification_interval = 960,
    $normal_check_interval = 5,
    $check_period = "24x7",
    $nagios_contact_groups_in = $nagios_contact_groups,
    $service_description = 'absent')
{

    # this ensures nagios internal check, that every 
    # service has it's host
    # temporary disabled.
    # include nagios::target::host

    $real_nagios_contact_groups = $nagios_contact_groups_in ? {
        '' => 'admins',
        default => $nagios_contact_groups_in
    }
    @@nagios_service {$name:
        ensure => $ensure,
        check_command => $check_command,
        use => $use,
        host_name => $host_name,
        notification_period => $notification_period,
        max_check_attempts => $max_check_attempts,
        retry_check_interval => $retry_check_interval,
        notification_interval => $notification_interval,
        normal_check_interval => $normal_check_interval,
        contact_groups => $real_nagios_contact_groups,
        check_period => $check_period,
        notify => Service[nagios],
    }
    case $service_description {
        'absent': {
            Nagios_service[$name]{
                service_description => $name,
            }
        }
        default: {
            Nagios_service[$name]{
                service_description => $service_description,
            }
        }
    }
}

define nagios::service::ping(
    $ensure = present
){
    $real_nagios_ping_rate = $nagios_ping_rate ? {
        '' => '!100.0,20%!500.0,60%',
        default => $nagios_ping_rate
    }

    nagios::service{ "check_ping_${hostname}":
        ensure => $ensure,
        check_command => "check_ping${real_nagios_ping_rate}",
    }
}

# ssl_mode:
#   - false: only check http
#   - true: check http and https
#   - force: http is permanent redirect to https
#   - only: check only https
define nagios::service::http(
    $ensure = present,
    $check_domain = 'absent',
    $check_url = '/',
    $check_code = 'OK',
    $ssl_mode = false
){
    $real_check_domain = $check_domain ? {
        'absent' => $name,
        default => $check_domain
    }
    case $ssl_mode {
        'force',true,'only': {
            nagios::service{"https_${name}_${check_code}_${hostname}":
                ensure => $ensure,
                check_command => "check_https_url_regex!${real_check_domain}!${check_url}!'${check_code}'",
            }
            case $ssl_mode {
                'force': {
                    nagios::service{"httprd_${name}_${hostname}":
                        ensure => $ensure,
                        check_command => "check_http_url_regex!${real_check_domain}!${check_url}!'301'",
                    }
                }
            }
        }
    }
    case $ssl_mode {
        false,true: {
            nagios::service{"http_${name}_${check_code}_${hostname}":
                ensure => $ensure,
                check_command => "check_http_url_regex!${real_check_domain}!${check_url}!'${check_code}'",
            }
        }
    }
}

define nagios::plugin(
    $ensure = present
){
  file{$name:
    path => $hardwaremodel ? {
      'x86_64' => "/usr/lib64/nagios/plugins/$name",
      default => "/usr/lib/nagios/plugins/$name",
    },
    ensure => $ensure,
    source => "puppet://$server/nagios/plugins/$name",
    require => Package['nagios-plugins'],
    owner => root, group => 0, mode => 0755;
  }
}
