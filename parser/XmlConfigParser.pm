package Modi::parser::XmlConfigParser;

use strict;

use Path::Class;
use Data::Dumper;
use Modi::Config;
use Modi::object::Mapping;
use Modi::object::Pbean;
use Modi::object::View;
use Modi::parser::PbeanParser;
use Modi::parser::ViewParser;
use XML::LibXML;

sub new {
	my $class = shift;
	my $modiDir = shift;
	my $xmlFile = shift;
	my $modiConfig = shift;
	my $self = {
		modiDir => $modiDir,
		xmlFile => $xmlFile,
		modiConfig => $modiConfig
	};
	return bless $self, $class;
}

sub parse {
	my $self = shift;

	my $leConfig = new Modi::Config();
	my $rootElement = "config";
	my $libXml = new XML::LibXML();
	my $configXml = $libXml->parse_file( $self->{modiDir} . '/' . $self->{xmlFile} );
	my $viewParser = new Modi::parser::ViewParser($self->{modiConfig});
	my $pbeanParser = new Modi::parser::PbeanParser();

	# Base URL
	$leConfig->setBaseUrl($self->{modiDir});

	# Parse Config Options
	foreach my $option ($configXml->findnodes($rootElement . "/option")) {

		# Project Include Path
		foreach ($option->findnodes("./projectincludepath")) {
			$leConfig->setProjectIncludePath($leConfig->getBaseUrl() . "/" . $_->to_literal());
		}

		# Additional Include Paths
		foreach ($option->findnodes("./additionalincludepath")) {
			$leConfig->addIncludePath($_->to_literal());
		}
	}

	# Update @INC Include Path
	push( @INC, $leConfig->getProjectIncludePath );
	push( @INC, @{$leConfig->getIncludePathList()} );

	# Views
	foreach my $viewConf ($configXml->findnodes($rootElement . "/views/view")) {
		my $view = new Modi::object::View();
		$view->setId( $viewConf->getAttribute("id") );
		$view->setPackage( "view::" . $view->getId() );
		my ($url) = $viewConf->findnodes("./url");
		$view->setRelativeUrl( $url->to_literal() );
		$view->setUrl( $leConfig->getBaseUrl() . "/" . $url->to_literal() );
		$view->setObject( $viewParser->eval($view, $leConfig) );

		$leConfig->addView($view);
	}

	# Pbeans
	foreach my $pbeanConf ($configXml->findnodes($rootElement . "/pbeans/pbean")) {
		my $pbean = new Modi::object::Pbean();
		$pbean->setId( $pbeanConf->getAttribute("id") );
		#my ($file) = $pbeanConf->findnodes("./file");
		#if ($file) {
			#$pbean->setUrl( $leConfig->getBaseUrl() . "/" . $file->to_literal() );
			#$pbean->setUrl( $leConfig->getBaseUrl() . "/classes/" . dir(split(/::/, $pbean->getPackage())) . ".pm" );
		#}
		my ($package) = $pbeanConf->findnodes("./package");
		$pbean->setPackage( $package->to_literal() );

		eval("use " . $pbean->getPackage());
		if ($@) {
			 die "Couldn't use package: " . $pbean->getPackage() . ": " . $@;
		}
		my $object = new $pbean->getPackage();

		#my $source = $pbeanParser->source($pbean, $leConfig);
		#print "got source\n";
		#eval($source);
		#die "Error evaling " . $pbean->getId(). "(" . $pbean->getPackage() . "): " . $@ if $@;

		#my $object = new $pbean->getPackage();

		foreach my $property (@{$pbeanConf->findnodes("./property")}) {
			my $name = $property->getAttribute("name");
			my $method = $property->getAttribute("method");

			if ($name) {
				$method = "set" . ucfirst($name);
			}

			my $injector = undef;
			my ($ref) = $property->findnodes("./ref");
			my ($value) = $property->findnodes("./value");
			if ($ref) {
				if ($ref->getAttribute("pbean")) {
					#print "Getting bean: " . $ref->getAttribute("pbean") . "\n";
					$injector = $leConfig->getPbeanById( $ref->getAttribute("pbean") )->getObject();
				} elsif ($ref->getAttribute("view")) {
					$injector = $leConfig->getViewById( $ref->getAttribute("view") )->getObject();
				}
			} elsif ($value) {
				$injector = $value->to_literal();
			}
			eval {
				$object->$method( $injector );
			};
			die "Error injecting $injector via $method: " . $@ if ($@);
		}

		$pbean->setObject($object);
		$leConfig->addPbean($pbean);
	}

	# Mappings
	foreach my $mappingConf ($configXml->findnodes($rootElement . "/mappings/mapping")) {
		my ($requestUrl) = $mappingConf->findnodes("./requesturl");
		my ($pbeanId) = $mappingConf->findnodes("./pbean");
		my $mapping = new Modi::object::Mapping();
		$mapping->setRequestUrl( $requestUrl->to_literal() );
		$mapping->setPbeanId( $pbeanId->to_literal() );
		$leConfig->addMapping($mapping);
	}
	#print $leConfig->getPbeanById("indexController")->getObject()->handleRequest();
	#print $leConfig->getViewById("index")->getObject()->printView();
	#print Dumper( $leConfig->getIncludePathList() );

	return $leConfig;
}

1;
