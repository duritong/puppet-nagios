class nagios::irc_bot::disabled inherits nagios::irc_bot {
    Service['nagios-nsa'] {
        ensure => stopped,
    }
}
