class nagios::defaults {

    # include some default nagios objects

    include nagios::defaults::commands
    include nagios::defaults::contactgroups
    include nagios::defaults::contacts
    include nagios::defaults::hostgroups
    include nagios::defaults::host_templates
    include nagios::defaults::service_templates
    include nagios::defaults::timeperiods

}
