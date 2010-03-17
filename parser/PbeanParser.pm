package Modi::parser::PbeanParser;

use strict;

sub new {
	my $class = shift;
	my $self = {
	};
	return bless $self, $class;
}

sub eval {
	my $self = shift;
	my $pbean = shift;
	my $leConfig = shift;
	my $tfile = "";

	if ( $pbean->getUrl() ) {
		#print "Evaling " . $pbean->getId() . "...\n";
		open (FILE, $pbean->getUrl()) or die "couldn't open " . $pbean->getUrl() . "(" . $pbean->getPackage() ."): $!";
		while (<FILE>) {
			$tfile .= $_;
		}
		close(FILE) or die "Couldn't close " . $pbean->getUrl() . ": $!";
		eval($tfile) or die "Error evaling " . $pbean->getId(). "(" . $pbean->getPackage() . "): " . $@; #": \n\n=====================\n$tfile";
		eval($tfile);
		die "Error evaling " . $pbean->getId(). "(" . $pbean->getPackage() . "): " . $@ if $@;
	}

	#return $tfile;
	return new $pbean->getPackage();
}

1;

