package Modi::Request;

use strict;
use CGI qw(:standard Vars);
use Time::HiRes qw(gettimeofday tv_interval);

sub new {
	my $class = shift;
	my %param = Vars();
	my $self = {
		_param => \%param,
		_attribute => {},
		_env => \%ENV,
		_threadId => 1,
		_startTime => 0,
		_contentType => "",
		apacheRequest => undef,
		session => undef,
		forwardUri => undef
	};
	bless $self, $class;
	return $self;
}

sub getTest {
	my $self = shift;
	return $self->{lol};
}

sub setParameter {
	my $self = shift;
	my $name =  shift;
	$self->{_param}->{$name} = shift;
}
sub getParameter {
	my $self = shift;
	my $param = shift;
	return $self->{_param}->{$param}
}

sub getAllParameters {
	return shift->{_param};
}

sub setAttribute {
	my $self = shift;
	my $name = shift;
	$self->{_attribute}->{$name} = shift;
}
sub getAttribute {
	my $self = shift;
	my $attribute = shift;
	if ( $self->{_attribute}->{$attribute} ) {
		return $self->{_attribute}->{$attribute};
	} else {
		return undef;
	}
}

sub getScriptName {
	my $self = shift;
	return $self->{_env}->{SCRIPT_NAME};
}

sub getRequestUri {
	my $self = shift;
	my $requestUri = $self->{_env}->{REQUEST_URI};
	$requestUri =~ s/\?.*$//g;
	return $requestUri;
}

sub getRequestMethod {
	my $self = shift;
	return $self->{_env}->{REQUEST_METHOD};
}

sub getThreadId {
	return $$;
}

sub setStartTime {
	my $self = shift;
	$self->{startTime} = shift;
}
sub getStartTime {
	my $self = shift;
	return $self->{startTime};
}

sub getTimeElapsed {
	my $self = shift;
	return tv_interval ($self->getStartTime(), [gettimeofday]);
}

sub setContentType {
	my $self = shift;
	$self->{_contentType} = shift;
}
sub getContentType {
	my $self = shift;
	return $self->{_contentType};
}

sub setApacheRequest {
	my $self = shift;
	$self->{apacheRequest} = shift;
}

sub getApacheRequest {
	my $self = shift;
	return $self->{apacheRequest};
}

sub setSession {
	my $self = shift;
	$self->{session} = shift;
}

sub getSession {
	my $self = shift;
	return $self->{session};
}

sub setForwardUri {
	my $self = shift;
	$self->{forwardUri} = shift;
}

sub getForwardUri {
	my $self = shift;
	return $self->{forwardUri} = shift;
}


1;
