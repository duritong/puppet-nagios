# manifests/target/host.pp

class nagios::target::host {
    nagios::host { $fqdn: parents => $nagios_parent }
}

