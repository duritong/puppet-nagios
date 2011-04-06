class nagios::defaults::plugins {
  nagios::plugin {
    'check_mysql_health':
      source => 'nagios/plugins/check_mysql_health';
    'check_dns2':
      source => 'nagios/plugins/check_dns2';
    'check_dnsbl':
      source => 'nagios/plugins/check_dnsbl';
    'check_jabber_login':
      source => 'nagios/plugins/check_jabber_login';
  }
  # for check_jabber_login
  require rubygems::xmpp4r
}
