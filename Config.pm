package Modi::Config;

use strict;

sub new {
	my $class = shift;
	my $self = {
		baseUrl => "",
		projectIncludePath => undef,
		includePathList => [],
		viewList => [],
		mappingList => [],
		pbeanList => []
	};
	return bless $self, $class;
}

sub setBaseUrl {
	my $self = shift;
	$self->{baseUrl} = shift;
}

sub setProjectIncludePath {
	my $self = shift;
	$self->{projectIncludePath} = shift;
}

sub addIncludePath {
	my $self = shift;
	push( @{$self->{includePathList}}, shift );
}

sub addView {
	my $self = shift;
	my $view = shift;
	push( @{$self->{viewList}}, $view );
}

sub addMapping {
	my $self = shift;
	push( @{$self->{mappingList}}, shift );
}

sub addPbean {
	my $self = shift;
	push( @{$self->{pbeanList}}, shift );
}

# Get

sub getBaseUrl {
	my $self = shift;
	return $self->{baseUrl};
}

sub getProjectIncludePath {
	my $self = shift;
	return $self->{projectIncludePath};
}

sub getIncludePathList {
	my $self = shift;
	return $self->{includePathList}
}

sub getViewList {
	my $self = shift;
	return $self->{viewList};
}

sub getMappingList {
	my $self = shift;
	return $self->{mappingList};
}

sub getPbeanList {
	my $self = shift;
	return $self->{pbeanList};
}

##

sub getViewById {
	my $self = shift;
	my $id = shift;
	foreach (@{$self->{viewList}}) {
		if ( $_->getId() eq $id ) {
			return $_;
		}
	}
	return undef;
}

sub getPbeanById {
	my $self = shift;
	my $id = shift;
	foreach (@{$self->{pbeanList}}) {
		if ( $_->getId() eq $id ) {
			return $_;
		}
	}
	return undef;
}

sub getMappingByRequestUrl {
	my $self = shift;
	my $requestUrl = shift;
	my $mapping = undef;

	foreach (@{$self->{mappingList}}) {
		if ( !$mapping && $_->getRequestUrl() eq $requestUrl ) {
			$mapping = $_;
		}
	}

	if (!$mapping) {
		foreach (@{$self->{mappingList}}) {
			my $mappingUrl = $_->getRequestUrl();
			if ( $mappingUrl ne '/' && $requestUrl =~ m/$mappingUrl/ ) {
				return $_;
			}
		}
	}

	return $mapping;
}

1;
