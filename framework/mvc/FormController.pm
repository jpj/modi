package Modi::framework::mvc::FormController;

use strict;
use Modi::framework::mvc::ModelAndView;
use Modi::framework::validation::FieldErrors;

sub new {
	my $class = shift;
	my $self = {
		formViewName => undef,
		successViewName => undef,
		formData => undef,
		errors => undef,
		validator => undef,
		contentType => "text/html"
	};
	return bless $self, $class;
}

sub handleRequestInternal {
	my $self = shift;
	my $request = shift;
	my $log = $request->getApacheRequest()->log();
	my $mav = undef;

	#$request->setContentType( $self->{contentType} );

	$self->{errors} = new Modi::framework::validation::FieldErrors();

	$mav = $self->formBackingObject($request);

	if ( $self->isFormSubmission($request) ) {
		$self->bindFormData($request);
		# TODO: VALIDATE
		if ($self->{validator} != undef) {
			#$self->{errors} = $self->{validator}->validate($self->{formData}, $self->{errors});
			$self->{validator}->validate($self->{formData}, $self->{errors});
		}
		$mav = $self->onSubmit($request, $self->{formData}, $mav);
	}

	$log->debug("Checking if no \$mav exists.");
	if (!$mav) {
		$mav = new Modi::framework::mvc::ModelAndView($self->getFormViewName());
	}

	return $mav;
}

# This will return a map which will be added to the ModelAndView
# It wil be called by showForm(). To get it in onSubmit it must
# be called explicitly and the returned map must be added to the
# ModelAndView, if desired.
#sub referenceData

sub formBackingObject {
	my $self = shift;
	return new Modi::framework::mvc::ModelAndView($self->getFormViewName());
}

sub onSubmit {
	my $self = shift;
	my $formData = shift;
	my $mav = shift;
	return new Modi::framework::mvc::ModelAndView($self->getSuccessViewName());
}

sub isFormSubmission {
	my $self = shift;
	my $request = shift;

	if ( $request->getRequestMethod() eq "POST" ) {
		return 1;
	} else {
		return 0;
	}
}

# TODO
# Make this work with multiple params like multi selects and checkboxes.
sub bindFormData {
	my $self = shift;
	my $request = shift;
	my $log = $request->getApacheRequest()->log();
	my $params = $request->getAllParameters();

	$log->debug("bindFormData: " . ref($self->{formData}));

	foreach my $key (keys %{$params}) {
		$log->debug("\tKey: $key");

		my $setter = "set" . ucfirst($key);
		eval{ $self->{formData}->$setter( $params->{$key} ) };
	}
}

sub setFormViewName {
	my $self = shift;
	$self->{formViewName} = shift;
}

sub getFormViewName {
	my $self = shift;
	return $self->{formViewName};
}

sub setSuccessViewName {
	my $self = shift;
	$self->{successViewName} = shift;
}

sub getSuccessViewName {
	my $self = shift;
	return $self->{successViewName};
}

sub setFormData {
	my $self = shift;
	$self->{formData} = shift;
}

sub getFormData {
	return shift->{formData};
}

sub getErrors {
	return shift->{errors};
}

sub setValidator {
	my $self = shift;
	$self->{validator} = shift;
}

sub setContentType {
	my $self = shift;
	$self->{contentType} = shift;
}

1;

