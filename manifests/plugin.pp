define nagios::plugin(
    $source = 'absent',
    $ensure = present
){
  @@file{$name:
    path => $hardwaremodel ? {
      'x86_64' => "/usr/lib64/nagios/plugins/$name",
      default => "/usr/lib/nagios/plugins/$name",
    },
    ensure => $ensure,
    source => $source ? {
      'absent' => "puppet://$server/modules/nagios/plugins/$name",
      default => "puppet://$server/modules/$source"
    },
    tag => 'nagios_plugin',
    require => Package['nagios-plugins'],
    owner => root, group => 0, mode => 0755;
  }
}
