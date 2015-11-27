define nagios::plugin(
    $source = 'absent',
    $ensure = present
){
  if ($::operatingsystem == "Ubuntu") {
      $libpath = "/usr/lib/nagios/plugins"
  } else {
     $libpath = $::hardwaremodel ? {
         'x86_64' => "/usr/lib64/nagios/plugins",
         default => "/usr/lib/nagios/plugins",
     }
  }
  file{$name:
    path => "${libpath}/${name}",
    ensure => $ensure,
    source => $source ? {
      'absent' => "puppet:///modules/nagios/plugins/${name}",
      default => "puppet:///modules/${source}"
    },
    tag => 'nagios_plugin',
    require => Package['nagios-plugins'],
    owner => root, group => 0, mode => 0755;
  }
}
