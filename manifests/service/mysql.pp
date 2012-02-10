# Checks a mysql instance via tcp or socket

define nagios::service::mysql(
  $ensure = present,
  $check_host = 'absent',
  $check_port = '3306',
  $check_username = 'nagios',
  $check_password = trocla("mysql_nagios_${::fqdn}",'plain','length: 32'),
  $check_database = 'information_schema',
  $check_warning = undef,
  $check_critical = undef,
  $check_health_mode = $name,
  $check_name = undef,
  $check_name2 = undef,
  $check_regexp = undef,
  $check_units = undef,
  $check_mode = 'tcp' )
{

  if ($check_host == 'absent') {
    fail("Please specify a hostname, ip address or socket to check a mysql instance.")
  }

  case $check_mode {
    'tcp': {
      if ($check_host == 'localhost') {
        $real_check_host = '127.0.0.1'
      }
      else {
        $real_check_host = $check_host
      }
    }
    default: {
      if ($check_host == '127.0.0.1') {
        $real_check_host = 'localhost'
      }
      else {
        $real_check_host = $check_host
      }
    }
  }

  nagios::service { "mysql_health_${name}":
    ensure        => $ensure,
    check_command => "check_mysql_health!${check_host}!${check_port}!${check_username}!${check_password}!${name}!${check_database}",
  }
}
