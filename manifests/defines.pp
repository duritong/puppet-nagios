# manifests/defines.pp

define nagios::host(
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
        ensure => present,
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
define nagios::extra_host($ip, $nagios_alias, $use = 'generic-host', $parents = 'localhost' ) {
    nagios::host{$name:
        ip => $ip,
        nagios_alias => $nagios_alias,
        use => $use,
        parents => $parents
    }

    nagios::service { "check_ping_${name}":
        host_name => $name,
        check_command => 'check_ping!100.0,20%!500.0,60%',
        host_name => $name,
        service_description => "check_ping_${nagios_alias}",
   }
}

# just a wrapper to make the notify more easy
define nagios::command( $command_line ){
    nagios_command{$name:
        command_line => $command_line,
        notify => Service[nagios],
    }
}

define nagios::service(
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
    $service_description = ''){

    # this ensures nagios internal check, that every 
    # service has it's host
    # temporary disabled.
    # include nagios::target::host

    $real_nagios_contact_groups = $nagios_contact_groups_in ? {
        '' => 'admins',
        default => $nagios_contact_groups_in
    }
    @@nagios_service {$name:
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
    # if no service_description is set it is a namevar
    case $service_description {
        '': {}
        default: {
            Nagios_service[$name]{
                service_description => $service_description,
            }
        }
    }
}

define nagios::service::ping(){
    $real_nagios_ping_rate = $nagios_ping_rate ? {
        '' => '!100.0,20%!500.0,60%',
        default => $nagios_ping_rate
    }

    nagios::service{ "check_ping_${hostname}":
        check_command => "check_ping${real_nagios_ping_rate}",
    }
}

# ssl_mode:
#   - false: only check http
#   - true: check http and https
#   - force: http is permanent redirect to https
#   - only: check only https
define nagios::service::http(
    $check_url = '/',
    $check_code = 'OK',
    $ssl_mode = 'false'
){
    case $ssl_mode {
        'strict','true','only': {
            nagios::service{"check_https_${name}_code_${check_code}":
                check_command => "check_https_url_regex!${name}!${check_url}!'${check_code}'",
            }
            case $ssl_mode {
                'strict': {
                    nagios::service{"check_http_redirect_${name}":
                        check_command => "check_http_url_regex!${name}!${check_url}!'301'",
                    }
                }
            }
        }
    }
    case $ssl_mode {
        'false,true': {
            nagios::service{"check_http_${name}_code_${check_code}":
                check_command => "check_http_url_regex!${name}!${check_url}!'${check_code}'",
            }
        }
    }
}
