package Modi::framework::mvc::ModelAndView;

use strict;

sub new {
	my $class = shift;
	my $viewName = shift;
	my $self = {
		viewName => $viewName,
		objectList => {}
	};
	return bless $self, $class;
}

sub setViewName {
	my $self = shift;
	$self->{viewName} = shift;
}

sub getViewName {
	my $self = shift;
	return $self->{viewName};
}

sub addObject {
	my $self = shift;
	my $name = shift;
	my $value = shift;

	$self->{objectList}->{$name} = $value;
}

sub getObject {
	my $self = shift;
	my $name = shift;

	if (defined($self->{objectList}->{$name})) {
		return $self->{objectList}->{$name};
	} else {
		return undef;
	}
}

1;

