class nagios::plugin::scriptpaths {
    if ($::operatingsystem == 'Ubuntu') {
        $script_path = "/usr/lib/nagios/plugins"
    } else {
        case $::hardwaremodel {
          x86_64: { $script_path =  "/usr/lib64/nagios/plugins/" }
          default: { $script_path =  "/usr/lib/nagios/plugins" }
        }
    }
}
