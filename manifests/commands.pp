class nagios::commands {

    # a set of commonly used commands
    nagios::command{
        ssh_port:
            command_line => '$USER1$/check_ssh -p $ARG1$ $HOSTADDRESS$';
        # from apache2.pp
        http_port:
            command_line => '$USER1$/check_http -p $ARG1$ -H $HOSTADDRESS$ -I $HOSTADDRESS$';
        # from bind.pp
        check_dig2:
           command_line => '$USER1$/check_dig -H $HOSTADDRESS$ -l $ARG1$ --record_type=$ARG2$';
        check_ntp_time:
            command_line => '$USER1$/check_ntp_time -H $HOSTADDRESS$ -w 0.5 -c 1';
        check_http_url:
            command_line => '$USER1$/check_http -H $ARG1$ -u $ARG2$';
        check_http_url_regex:
            command_line => '$USER1$/check_http -H $ARG1$ -u $ARG2$ -e $ARG3$';
        check_https_url:
            command_line => '$USER1$/check_http --ssl -H $ARG1$ -u $ARG2$';
        check_https_url_regex:
            command_line => '$USER1$/check_http --ssl -H $ARG1$ -u $ARG2$ -e $ARG3$';
        check_https:
            command_line => '$USER1$/check_http -S -H $HOSTADDRESS$';
        check_silc:
            command_line => '$USER1$/check_tcp -p 706 -H $ARG1$';
        check_sobby:
            command_line => '$USER1$/check_tcp -H $ARG1$ -p $ARG2$';
        check_jabber:
            command_line => '$USER1$/check_jabber -H $ARG1$';
        check_jabber_login:
            command_line => '$USER1$/check_jabber_login $ARG1$ $ARG2$',
            require => Nagios::Plugin['check_jabber_login'];
    }

}
