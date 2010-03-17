package Modi::SessionHandler;

use strict;
#use warnings;
use Apache::Session::File;
#use Data::Dumper;
use Modi::Session;

sub new {
	my $class = shift;
	my $self = {
	};
	return bless $self, $class;
}

sub le_session_put {
	my $sid = shift;
	my $input = shift || {};
	#warn "Before tie session: $sid";
	unless ($sid && -e "/tmp/sessions/$sid") {
		# No session? I'll assume that you want one.
		$sid = undef;
	}
	tie my %s, 'Apache::Session::File', $sid, {
		Directory	=> '/tmp/sessions',
		LockDirectory	=> '/var/lock/sessions',
		Transaction	=> 1
	};
	$s{reaction} = 'yow';
	foreach my $key (keys %{$input}) {
		$s{$key} = ${$input}{$key};
	}
	$sid = $s{_session_id};
	untie(%s);
	#warn "After tie session: $sid";
	return $sid;
}

sub getSession {
	my $self = shift;
	my $sid = shift;

	unless ($sid && -e "/tmp/sessions/$sid") {
		# No session? I'll assume that you want one.
		$sid = undef;
	}

	tie my %s, 'Apache::Session::File', $sid, {
		Directory	=> '/tmp/sessions',
		LockDirectory	=> '/var/lock/sessions',
		Transaction	=> 1
	};
	#%return_hash = %s;
	#untie(%s);
	#warn "After tie session: $sid";
	#return \%return_hash;

	my $session = new Modi::Session(\%s);
	return $session;
}

1;

