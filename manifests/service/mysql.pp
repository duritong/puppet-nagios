define nagios::service::mysql(
    $ensure = present,
    $check_hostname = 'localhost',
    $check_socket = 'absent',
    $check_username = 'nagios',
    $check_password = '',
    $check_database = '',
    $check_mode = 'absent'
){

    $real_check_mode = $check_mode ? {
        'absent' => 'tcp',
        default => 'socket',
    }

    case $real_check_mode {
        # Check MySQL using TCP
        'tcp': {
            nagios::service { 'mysql_tcp':
                ensure => $ensure,
                check_command => "check_mysql_tcp!${check_hostname}!${check_username}!${check_password}!${check_database}",
            }
        }
        # Check MySQL using local socket
        'socket': {
            nagios::service { 'mysql_socket':
                ensure => $ensure,
                check_command => $check_socket ? {
                    'absent' => "check_mysql!${check_username}!${check_password}!${check_database}",
                    default => "check_mysql_socket!${check_socket}!${check_username}!${check_password}!${check_database}",
                },
            }
        }
    }
}
