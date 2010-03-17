package Modi::object::Mapping;

use strict;

sub new {
	my $class = shift;
	my $self = {
		requestUrl => undef,
		pbeanId => undef
	};
	return bless $self, $class;
}

sub setRequestUrl {
	my $self = shift;
	$self->{requestUrl} = shift;
}

sub getRequestUrl {
	my $self = shift;
	return $self->{requestUrl};
}

sub setPbeanId {
	my $self = shift;
	$self->{pbeanId} = shift;
}

sub getPbeanId {
	my $self = shift;
	return $self->{pbeanId};
}

1;

