package Modi::framework::validation::Error;

use strict;

sub new {
	my $class = shift;
	my $self = {
		field => shift,
		message => shift
	};
	return bless $self, $class;
}

sub setField {
	my $self = shift;
	$self->{field} = shift;
}

sub getField {
	return shift->{field};
}

sub setMessage {
	my $self = shift;
	$self->{message} = shift;
}

sub getMessage {
	return shift->{message};
}

1;

