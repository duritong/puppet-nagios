# manifests/service/ntp.pp

class nagios::service::ntp {
    nagios::service{ "check_ntp_${hostname}":
        check_command => "check_ntp",
        host_name => $fqdn,
    }
}

