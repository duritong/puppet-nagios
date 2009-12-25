define nagios::service(
    $ensure = present,
    $check_command = absent,
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

    if $ensure == present and $check_command == absent {
      fail("You have to define \$check_command if nagios::service shoudl be present!")
    }

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

