package Modi::Cookie;

use strict;
use warnings;

sub new {
	my $class = shift;
	my $cookies_from_env = $ENV{'HTTP_COOKIE'} || '';
	#my @cookie = split(/; /,$ENV{'HTTP_COOKIE'});
	my @cookie = split(/; /,$cookies_from_env);
	my %cookie = ();
	foreach my $i (@cookie) {
		my ($cookiename,$cookievalue) = split(/=/,$i);
		$cookie{$cookiename} = $cookievalue;
	}
	my $self = {
		cookie => \%cookie
	};
	return bless $self, $class;
}

sub getCookieValue {
	my $self = shift;
	my $name = shift;
	return $self->{cookie}->{$name};
}

1;

