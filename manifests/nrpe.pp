class nagios::nrpe {

    case $operatingsystem {
        'FreeBSD': {
            if $nagios_nrpe_cfgdir == '' { $nagios_nrpe_cfgdir = '/usr/local/etc' }

            include nagios::nrpe::freebsd
        }
        default: {
            case $kernel {
                linux: { include nagios::nrpe::linux }
                default: { include nagios::nrpe::base }
            }
        }
    }

}
