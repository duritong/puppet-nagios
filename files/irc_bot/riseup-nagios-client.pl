#!/usr/bin/perl -w

# ##############################################################################
# Infrabot-Client - a simple Infrabot client which sends it's whole command
# line arguments to a local UNIX domain socket.
# ##############################################################################

use strict;
use IO::Socket;


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# >> CONFIGURATION >>

my $SOCKET = '/var/run/nagios/nsa.socket';

# << CONFIGURATION <<
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if (@ARGV == 0) {
	print "Hey - specify a message, sucker!\n";
	exit(1);
}

unless (-S $SOCKET) {
	die "Socket '$SOCKET' doesn't exist or isn't a socket!\n";
}

unless (-r $SOCKET) {
	die "Socket '$SOCKET' can't be read!\n";
}

my $sock = IO::Socket::UNIX->new (
	Peer    => $SOCKET,
	Type    => SOCK_DGRAM,
	Timeout => 10
) || die "Can't open socket '$SOCKET'!\n";

print $sock "@ARGV";
close($sock);
