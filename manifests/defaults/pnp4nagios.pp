class nagios::defaults::pnp4nagios {
    # performance data cmds
    # http://docs.pnp4nagios.org/de/pnp-0.6/config#bulk_mode_mit_npcd
    nagios_command {
        'process-service-perfdata-file-pnp4nagios-bulk-npcd':
            command_line => '/bin/mv /var/lib/nagios3/service-perfdata /var/spool/pnp4nagios/npcd/service-perfdata.$TIMET$';
        'process-host-perfdata-file-pnp4nagios-bulk-npcd':
            command_line => '/bin/mv /var/lib/nagios3/host-perfdata /var/spool/pnp4nagios/npcd/host-perfdata.$TIMET$'
    }

    # nagios host templates
    # http://docs.pnp4nagios.org/de/pnp-0.6/webfe
    
    # this doesn't work, see manifests/pnp4nagios.pp 
    #nagios_host { 'host-pnp':
    #    action_url => '/pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=_HOST_',
    #    register => 0,
    #    #ensure => absent;
    #}

    #nagios_service { 'service-pnp':
    #    #naginatorname => 'service-pnp',
    #    action_url => '/pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=$SERVICEDESC$',
    #    register => 0,
    #    ensure => absent;
    #}
}
