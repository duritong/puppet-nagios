#!/usr/bin/perl -w

# ##############################################################################
# a simple IRC bot which dispatches messages received via local domain sockets
# ##############################################################################

use strict;
use File::Basename;

BEGIN {
	unshift @INC, dirname($0);
}

my $VERSION = '0.2';
my $running = 1;

# Read a configuration file
#   The arg can be a relative or full path, or
#   it can be a file located somewhere in @INC.
sub ReadCfg
{
    my $file = $_[0];

    our $err;

    {   # Put config data into a separate namespace
        package CFG;

        # Process the contents of the config file
        my $rc = do($file);

        # Check for errors
        if ($@) {
            $::err = "ERROR: Failure compiling '$file' - $@";
        } elsif (! defined($rc)) {
            $::err = "ERROR: Failure reading '$file' - $!";
        } elsif (! $rc) {
            $::err = "ERROR: Failure processing '$file'";
        }
    }

    return ($err);
}

# Get our configuration information
if (my $err = ReadCfg('/etc/nagios_nsa.cfg')) {
    print(STDERR $err, "\n");
    exit(1);
}

use POSIX qw(setsid);
use IO::Socket;
use Net::IRC;

sub new {
	my $self = {
		socket => undef,
		irc => undef,
		conn => undef
	};

	return bless($self, __PACKAGE__);
}

sub daemonize {
	my $self = shift;
	my $pid;

	chdir '/' or die "Can't chdir to /: $!";

	open STDIN, '/dev/null' or die "Can't read /dev/null: $!";
	open STDOUT, '>/dev/null' or die "Can't write to /dev/null: $!";

	defined ($pid = fork) or die "Can't fork: $!";

	if ($pid && $CFG::Nsa{'pidfile'}) { # write pid of child
		open PID, ">$CFG::Nsa{'pidfile'}" or die "Can't open pid file: $!";
		print PID $pid;
		close PID;
	}
	exit if $pid;
	setsid or die "Can't start a new session: $!";

	#open STDERR, '>&STDOUT' or die "Can't dup stdout: $!";
}

sub run {
	my $self = shift;

	$self->{irc}->do_one_loop();
}

sub shutdown {
	my $sig = shift;

	print STDERR "Received SIG$sig, shutting down...\n";
	$running = 0;
}

sub socket_has_data {
    my $self = shift;
    
    $self->{socket}->recv(my $data, 1024);
    $self->{conn}->privmsg($CFG::Nsa{'channel'}, $data);
}

sub irc_on_connect {
	my $self = shift;

	print STDERR "Joining channel '$CFG::Nsa{'channel'}'...\n";
	$self->join($CFG::Nsa{'channel'});
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

my $bot = &new;

if (-e $CFG::Nsa{'socket'}) {
	die "Socket '$CFG::Nsa{'socket'}' exists!\n";
}

$bot->{socket} = IO::Socket::UNIX->new (
	Local  => $CFG::Nsa{'socket'},
	Type   => SOCK_DGRAM,
	Listen => 5
) || die "Can't create socket '$CFG::Nsa{'socket'}'!\n";

$SIG{INT} = $SIG{TERM} = \&shutdown;

$bot->daemonize();
$bot->{irc} = new Net::IRC;

$bot->{conn} = $bot->{irc}->newconn (
	Server   => $CFG::Nsa{'server'},
	Port     => $CFG::Nsa{'port'},
	Nick     => $CFG::Nsa{'nickname'},
	Username => $CFG::Nsa{'nickname'},
	Password => $CFG::Nsa{'password'},
	Ircname  => $CFG::Nsa{'realname'} . " (NSA $VERSION)",
) || die "Can't connect to server '$CFG::Nsa{'server'}'!\n";

$bot->{conn}->add_global_handler(376, \&irc_on_connect);
$bot->{conn}->add_global_handler('nomotd', \&irc_on_connect);
$bot->{irc}->addfh($bot->{socket}, \&socket_has_data, 'r', $bot);

while ($running) {
	$bot->run();
}

close($bot->{socket});
unlink($CFG::Nsa{'socket'});

exit(0);

1;

__END__
