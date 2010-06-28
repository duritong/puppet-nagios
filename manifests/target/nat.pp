class nagios::target::nat inherits nagios::target {

    Nagios_host["${fqdn}"] { address => "${fqdn}" }

}
