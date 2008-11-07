# manifests/target.pp

class nagios::target {
    include nagios::target::host
    nagios::service::ping{$fqdn:}
}
