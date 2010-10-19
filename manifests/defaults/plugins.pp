class nagios::defaults::plugins {

  nagios::plugin { 'check_mysql_health': source => 'nagios/plugins/check_mysql_health'; }

}
