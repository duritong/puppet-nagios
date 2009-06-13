# just a wrapper to make the notify more easy
define nagios::command(
  $ensure = present,
  $command_line
){
    nagios_command{$name:
        ensure => $ensure,
        command_line => $command_line,
        notify => Service[nagios],
    }
}
