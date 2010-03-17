package Modi::framework::mvc::Controller;

use strict;
use Modi::framework::mvc::ModelAndView;

sub new {
	my $class = shift;
	my $self = {
		viewName => undef
	};
	return bless $self, $class;
}

sub handleRequestInternal {
	my $self = shift;
	my $request = shift;
	my $log = $request->getApacheRequest()->log();

	my $modelAndView = $self->handleRequest($request);

	return $modelAndView;
}

sub handleRequest {
	my $self = shift;
	my $request = shift;
	my $log = $request->getApacheRequest()->log();
	my $mav = new Modi::framework::mvc::ModelAndView($self->{viewName});

	$log->debug("Created new ModelAndView with '" . $self->{viewName} . "', mav has '" . $mav->getViewName() . "'");

	return $mav;
}

sub setViewName {
	my $self = shift;
	$self->{viewName} = shift;
}

sub getViewName {
	my $self = shift;
	return $self->{viewName};
}

1;

