class nagios::apache inherits ::apache {
    $nagios_httpd = 'apache'
    include nagios
}
