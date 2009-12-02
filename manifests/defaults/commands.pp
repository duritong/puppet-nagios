class nagios::defaults::commands {

    # common service commands

    nagios_command {
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
    }

    # notification commands

    nagios_command {
        'notify-host-by-email':
            command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\nHost: $HOSTNAME$\nState: $HOSTSTATE$\nAddress: $HOSTADDRESS$\nInfo: $HOSTOUTPUT$\n\nDate/Time: $LONGDATETIME$\n" | /usr/bin/mail -s "** $NOTIFICATIONTYPE$ Host Alert: $HOSTNAME$ is $HOSTSTATE$ **" $CONTACTEMAIL$';
	    'notify-service-by-email':
        	command_line => '/usr/bin/printf "%b" "***** Nagios *****\n\nNotification Type: $NOTIFICATIONTYPE$\n\nService: $SERVICEDESC$\nHost: $HOSTALIAS$\nAddress: $HOSTADDRESS$\nState: $SERVICESTATE$\n\nDate/Time: $LONGDATETIME$\n\nAdditional Info:\n\n$SERVICEOUTPUT$" | /usr/bin/mail -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" $CONTACTEMAIL$'

	}

}
