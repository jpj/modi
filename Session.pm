package Modi::Session;

use strict;

sub new {
	my $class = shift;
	my $sessionHash = shift;
	my $self = {
		session => $sessionHash
	};
	return bless $self, $class;
}

sub setAttribute {
	my $self = shift;
	my $name = shift;
	my $val = shift;
	$self->{session}->{$name} = $val;
}

sub getAttribute {
	my $self = shift;
	my $attribute = shift;
	return $self->{session}->{$attribute};
}

sub getId {
	my $self = shift;
	return $self->{session}->{_session_id};
}

1;

