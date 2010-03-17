package Modi::framework::validation::FieldErrors;

use strict;
use Modi::framework::validation::Error;

sub new {
	my $class = shift;
	my $self = {
		errors => []
	};
	return bless $self, $class;
}

sub addFieldError {
	my $self = shift;
	my $error = new Modi::framework::validation::Error(shift, shift);

	push(@{$self->{errors}}, $error);
}

sub hasFieldErrors {
	my $self = shift;

	if ( $self->{errors} == undef || scalar(@{$self->{errors}}) < 1 ) {
		return 0;
	} else {
		return 1;
	}
}

sub getFieldErrors {
	return shift->{errors};
}

1;

