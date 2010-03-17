package Modi::Handler;

use strict;
use warnings;

use Time::HiRes qw(gettimeofday tv_interval);
use Apache2::RequestRec();
use Apache2::RequestUtil();
use Apache2::ServerRec;
use Apache2::RequestIO();
use Apache2::Const -compile => qw(OK DECLINED NOT_FOUND LOG_DEBUG);
use Apache2::Cookie();
use Apache2::Log qw(LOG_MARK);
use APR::Const -compile => qw(ENOTIME);
use APR::Request;
use XML::LibXML;
use Data::Dumper;
use Error qw(:try);

use Modi::Cookie;
use Modi::parser::XmlConfigParser;
use Modi::Request;
use Modi::SessionHandler;
use Modi::framework::mvc::FormController;
use Modi::framework::mvc::Controller;

my $leConfig = {};
my $modiConfigXml = "config.xml";

sub new {
	my $class = shift;
	my $modiDir = shift;
	my $modiConfig = shift;

	if ( !$modiDir ) {
		die "modiDir must be specified as the first argument in Modi::Handler->new";
	}

	if ( !$modiConfig ) {
		die "modiConfig must be specified as the second argument in Modi::Handler->new";
	}

	if ( exists($leConfig->{$modiConfig}) ) {
		die "'$modiConfig' already exists.";
	}

	my $timeBeforeConfigParse = [gettimeofday];

	my $configParser = new Modi::parser::XmlConfigParser( $modiDir, $modiConfigXml, $modiConfig );
	$leConfig->{$modiConfig} = $configParser->parse();

	print "Created config '$modiConfig' in " . tv_interval($timeBeforeConfigParse, [gettimeofday]) . "\n";

	my $self = {
	};
	return bless $self, $class;
}

sub handler {

	my $self = shift;
	my $r = shift; # Apache Request.

	# Set Log Level
	$r->server->loglevel(Apache2::Const::LOG_DEBUG);

	$r->log->debug("Entering Handler with MODI_CONFIG: " . $ENV{MODI_CONFIG});

	#if ( $ENV{MODI_DEBUG} ) {
	#	my $configParser = new Modi::parser::XmlConfigParser( $leConfig->{ $ENV{MODI_CONFIG} }->getBaseUrl(), $modiConfigXml, $ENV{MODI_CONFIG} );
	#	$leConfig->{ $ENV{MODI_CONFIG} } = $configParser->parse();
	#}

	# Start Request
	my $request = new Modi::Request();
	$request->setStartTime( [gettimeofday] );
	$request->setContentType( "text/html" );
	$request->setApacheRequest( $r );

	# Session and Cookies
	my $modiCookie = new Modi::Cookie();
	my $sessionHandler = new Modi::SessionHandler();
	my $session = $sessionHandler->getSession( $modiCookie->getCookieValue("MODISESSIONID") );
	my $modiSessionCookie = Apache2::Cookie->new(
		$r,
		-name  => "MODISESSIONID",
		-expires => "+1Y",
		-path	=> '/',
		-value => $session->getId() );
	$modiSessionCookie->bake($r); # Yum
	$request->setSession( $session );

	$r->log->debug("Request URI: " . $request->getRequestUri() );
	my $mapping = $leConfig->{$ENV{MODI_CONFIG}}->getMappingByRequestUrl( $request->getRequestUri() );
	$r->log->debug("Using Mapping with request URL: " . $mapping->getRequestUrl()) if ($mapping);

	$r->headers_out->set("X-Powered-By" => "Modi Framework");

	if ( $mapping == undef ) {
		$r->log->debug("Couldn't find a mapping for request '".$request->getRequestUri()."'");
		return Apache2::Const::NOT_FOUND;
	} else {
		my $pbean = $leConfig->{$ENV{MODI_CONFIG}}->getPbeanById( $mapping->getPbeanId() );
		$r->log->debug("Using Controller: " . $pbean->getPackage());
		my $modelAndView = undef;

		# Catch any uncaught errors that happened in the controller.
		#
		# TODO
		# Eventually it will be good to have the ability to return html AND a 500
		# status. Think, custom error pages.
		try {
			$modelAndView = $pbean->getObject->handleRequestInternal($request);
		} catch Error with {
			my $e = shift;
			die $e;
		};
		my $view = $leConfig->{$ENV{MODI_CONFIG}}->getViewById($modelAndView->getViewName());

		my $formData = undef;
		eval {
			$formData = $pbean->getObject()->getFormData();
		};

		my $errors = undef;
		eval {
			$errors = $pbean->getObject()->getErrors();
		};
		if ($@) {
			# Squash
			#$r->log->debug("Error getting errors: $@");
		}

		if (!$view) {
			die "No view found for id: '".$modelAndView->getViewName()."'";
		}

		my $buffer;
		eval {
			$buffer = $view->getObject()->printView($request, $modelAndView, $formData, $errors);
		};
		if ($@) {
			die "Error calling printView() on ".$view->getId().": ".$@;
		}

		if ( $request->getForwardUri() ) {
			#$r->internal_redirect # maybe can use this sometime.
			$r->headers_out->set(Location => $request->getForwardUri());
			$request->setForwardUri(undef);
		} else {
			$r->content_type( $request->getContentType() );
			$r->print($buffer);
		}
	}

	return Apache2::Const::OK;
}

1;

