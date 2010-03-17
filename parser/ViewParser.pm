package Modi::parser::ViewParser;

use strict;
use XML::LibXML;

sub new {
	my $class = shift;
	my $modiConfig = shift;
	my $self = {
		libXml => new XML::LibXML(),
		modiConfig => $modiConfig,
		endPrint => "\);\n",
		startPrint => "\n\$modiBuffer .= qq\("
		#endPrint => "\);\n",
		#startPrint => "\nprint qq\("
	};
	return bless $self, $class;
}

my $createPackageString = sub {
	my $self = shift;
	my $relativeUrl = shift;

	$relativeUrl =~ s/\./_/g;
	$relativeUrl =~ s/-/_/g;
	return "_pview::" . $self->{modiConfig} . "::" . join("::", split(/\//, $relativeUrl) );
};

my $getPackagePath = sub {
	my $self = shift;
	my $package = shift;
	my $projectPath = shift;
	my $path = $projectPath;

	$package =~ s/::/\//g;
	my @packageParts = split(/\//, $package);

	for (my $i = 0; $i <= $#packageParts; $i++) {
		if ($i != $#packageParts) {
			$path .= "/" . $packageParts[$i];
			if (! -d $path) {
				mkdir $path or die "Couldn't create directory $path: " . $!;
			}
		}
	}

	$path .= "/" . $packageParts[$#packageParts] . ".pm";
	return $path;
};

sub eval {
	my $self = shift;
	my $view = shift;
	my $leConfig = shift;
	my $tagParser = $self->{libXml};

	#my $endPrint = "\nENDOFVIEW\n";
	#my $startPrint = "\nprint <<ENDOFVIEW;\n";
	#my $endPrint = ");\n";
	#my $startPrint = "\nprint qq(";
	my $endPrint = $self->{endPrint};
	my $startPrint = $self->{startPrint};

	my $tfile ="";
	#my $package = $view->getPackage();
	my $package = $self->$createPackageString($view->getRelativeUrl());
	$view->setPackage($package);
	open (FILE, $view->getUrl()) or die "couldn't open " . $view->getUrl() . ": $!";
	while (<FILE>) {
		$tfile .= $_;
	}
	close(FILE) or die "Couldn't close " . $view->getUrl() . ": $!";

	## Get rid of comments.
	$tfile =~ s/<%--.*?--%>//sg;
	$tfile =~ s/<%=(.*?)%>/$endPrint\$modiBuffer .= $1;$startPrint/sg;

	while ( $tfile =~ m/(<le>.*?<\/le>)/s ) {
		my $le = $tagParser->parse_string($1);
		my $replacement = "";

		foreach my $command ($le->findnodes("le/*")) {
			if ( $command->nodeName() eq "import" ) {
				my $importView = $leConfig->getViewById( $command->getAttribute("view") );
				if ( $importView == undef ) {
					die "Import view '" . $command->getAttribute("view") . "' not found.";
				}
				$replacement .= $endPrint;

				my $scalar = $importView->getId();
				$scalar =~ s/\//_/g;

				$replacement .= "my \$" . $scalar . " = new " . $importView->getPackage() . "();\n";
				foreach my $attribute ( $command->getChildrenByTagName("attribute") ) {
					$replacement .= '$'.$scalar.'->setAttribute("'.$attribute->getAttribute('name').
						'", "'.$attribute->getAttribute('value').'");'."\n";
				}
				#$replacement .= '$' . $scalar . "->printView(\$request);" . $startPrint;
				$replacement .= '$modiBuffer .= $' . $scalar . "->printView(\$request, \$modi_mav, \$modi_formdata);" . $startPrint;
			} elsif ( $command->nodeName() eq "out" ) {
				my $attribute = $command->getAttribute("value");
				$replacement .= $endPrint.'$modiBuffer .= $self->getAttribute("'.$attribute.'");'."\n".$startPrint;
			#} elsif ( $command->nodeName() eq "print" ) {
			} else {
				$replacement = "[Command \"".$command->nodeName()."\" not found]";
			}
		}

		$tfile =~ s/<le>.*?<\/le>/$replacement/s;
	}
	$tfile =~ s/<%/$endPrint/g;
	$tfile =~ s/%>/$startPrint/g;
		
	my $viewFile = <<EOF;
package $package;

use strict;

sub new {
	my \$class = shift;
	my \$self = {
		attributes => {}
	};
	bless \$self, \$class;
	return \$self;
}

sub setAttribute {
	my \$self = shift;
	my \$name = shift;
	my \$value = shift;

	\$self->{attributes}->{\$name} = \$value;
}

sub getAttribute {
	my \$self = shift;
	my \$name = shift;
	return \$self->{attributes}->{\$name};
}

sub printView {
	my \$self = shift;
	my \$request = shift;
	my \$modi_mav = shift;
	my \$modi_formdata = shift;
	my \$modi_formerrors = shift;
	my \$modiBuffer = "";
	$self->{startPrint}$tfile$self->{endPrint}
	return \$modiBuffer;
}

1;
EOF
	open(PVIEW, ">".$self->$getPackagePath($package, $leConfig->getProjectIncludePath())) or die "Couldn't open ".$self->$getPackagePath($package, $leConfig->getProjectIncludePath())." for writing: $!";
	print PVIEW $viewFile;
	close(PVIEW) or die "Couldn't close tmp view file: $!";
	eval("use $package");
	if ($@) {
		die "Couldn't use $package: " . $@;
	}

	#eval($viewFile) or die "Error evaling view \"".$view->getId()."\": \n\n============================\n$viewFile\n";

	return new $package;
}

1;

