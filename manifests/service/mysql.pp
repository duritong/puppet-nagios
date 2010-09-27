# Checks a mysql instance via tcp or socket

define nagios::service::mysql(
    $ensure = present,
    $check_hostname = 'absent',
    $check_port = '3306',
    $check_username = 'nagios',
    $check_password = '',
    $check_database = 'absent',
    $check_mode = 'tcp'
){
    if ($check_hostname == 'absent') {
        fail("Please specify a hostname, ip address or socket to check a mysql instance.")
    }

    case $check_mode {
        'tcp': {
            if ($check_hostname == 'localhost') {
               $real_check_hostname = '127.0.0.1'
            }
            else {
              $real_check_hostname = $check_hostname
            }
        }
        default: {
            if ($check_hostname == '127.0.0.1') {
                $real_check_hostname = 'localhost'
            }
             else {
              $real_check_hostname = $check_hostname
            }
        }
    }

    if ($check_database == 'absent') {
        nagios::service { 'mysql':
            ensure        => $ensure,
            check_command => "check_mysql!${real_check_hostname}!${check_port}!${check_username}!${check_password}",
        }
    }
    else {
        nagios::service { "mysql_${check_database}":
            ensure        => $ensure,
            check_command => "check_mysql_db!${real_check_hostname}!${check_port}!${check_username}!${check_password}!${check_database}",
        }
    }

}

define nagios::service::mysql_health(
  $ensure = present,
  $check_hostname = $fqdn,
  $check_port = '3306',
  $check_username = 'nagios',
  $check_password = $nagios_mysql_password,
  $check_database = 'information_schema',
  $check_warning = undef,
  $check_critical = undef,
  $check_health_mode = $name,
  $check_name = undef,
  $check_name2 = undef,
  $check_regexp = undef,
  $check_units = undef,
  $check_mode = 'tcp'
){

  if ($check_username == '') {
    $real_check_username = 'nagios'
  }
  
  case $check_mode {
    'tcp': {
      if ($check_hostname == 'localhost') {
        $real_check_hostname = '127.0.0.1'
      }
      else {
        $real_check_hostname = $check_hostname
      }
    }
    default: {
      if ($check_hostname == '127.0.0.1') {
        $real_check_hostname = 'localhost'
      }
      else {
        $real_check_hostname = $check_hostname
      }
    }
  }

  nagios::service { 'mysql_health_${check_health_mode}':
    ensure        => $ensure,
    check_command => "check_mysql_health!${check_hostname}!${check_port}!${real_check_username}!${check_password}${check_health_mode}!{check_database}",
  }
}

  


  
