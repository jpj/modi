package Modi::object::View;

use strict;

sub new {
	my $class = shift;
	my $self = {
		id => undef,
		relativeUrl => undef,
		url => undef,
		package => undef,
		object => undef
	};
	return bless $self, $class;
}

sub setId {
	my $self = shift;
	$self->{id} = shift;
}

sub getId {
	my $self = shift;
	return $self->{id};
}

sub setRelativeUrl {
	my $self = shift;
	$self->{relativeUrl} = shift;
}

sub getRelativeUrl {
	my $self = shift;
	return $self->{relativeUrl};
}

sub setUrl {
	my $self = shift;
	$self->{url} = shift;
}

sub getUrl {
	my $self = shift;
	return $self->{url};
}

sub setPackage {
	my $self = shift;
	$self->{package} = shift;
}

sub getPackage {
	my $self = shift;
	return $self->{package};
}

sub setObject {
	my $self = shift;
	$self->{object} = shift;
}

sub getObject {
	my $self = shift;
	return $self->{object};
}

1;
	
