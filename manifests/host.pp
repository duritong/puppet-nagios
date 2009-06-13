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
