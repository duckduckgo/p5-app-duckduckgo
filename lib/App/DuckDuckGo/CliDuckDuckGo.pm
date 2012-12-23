package App::DuckDuckGo::CliDuckDuckGo;
# ABSTRACT: Wrap WWW::DuckDuckGo to support the CLI API

use Moo;

use JSON;
use WWW::DuckDuckGo::ZeroClickInfo;
use App::DuckDuckGo::CliInfo;
use App::DuckDuckGo::Deep;

extends 'WWW::DuckDuckGo';

has _deep_class => (
	is => 'ro',
	default => sub { 'App::DuckDuckGo::Deep' }
);

sub _add_cli_params {
	my ( $self, $uri ) = @_;
	$uri->query_param( l => 'us-en' );
	$uri->query_param( p => 1 );
	$uri->query_param( s => 0 );
	$uri->query_param( t => 'cli' );
}

sub _cliinfo_uri {
	my $self = shift;
	my $uri = $self->_zeroclickinfo_uri(@_);
	$self->_add_cli_params($uri);
	return $uri;
}

sub _deep_uri {
	my ( $self, $base_uri, $deep_uri ) = @_;
	return URI->new($base_uri . $deep_uri);
}

sub cliinfo { shift->zeroclickinfo(@_); }

has deep => (
	is => 'ro',
	lazy => 1,
	builder => '_build_deep_accessor'
);

sub _build_deep_accessor {
	my $self = shift;
	__PACKAGE__->new( http_agent_name => $self->http_agent_name,
			  forcesecure => $self->forcesecure,
			  _zeroclickinfo_class => $self->_deep_class,
			  _duckduckgo_api_url => $self->_duckduckgo_api_url,
			  _duckduckgo_api_url_secure => $self->_duckduckgo_api_url_secure,
			  _uri_builder => '_deep_uri'
			);
}


1;


=head1 TODO

 * documentation
 * tests
