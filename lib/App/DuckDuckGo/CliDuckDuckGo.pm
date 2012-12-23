package App::DuckDuckGo::CliDuckDuckGo;
# ABSTRACT: Wrap WWW::DuckDuckGo to support the CLI API

use Moo;

use JSON;
use WWW::DuckDuckGo::ZeroClickInfo;
use App::DuckDuckGo::CliInfo;
use App::DuckDuckGo::Deep;

extends 'WWW::DuckDuckGo';

has _uri_builder => (
	is => 'ro',
	default => sub { '_cliinfo_uri' }
);

has _cliinfo_class => (
	is => 'ro',
	lazy => 1,
	default => sub { 'App::DuckDuckGo::CliInfo' }
);

has _deep_class => (
	is => 'ro',
	default => sub { 'App::DuckDuckGo::Deep' }
);

has _duckduckgo_api_url => (
	is => 'ro',
	lazy => 1,
	default => sub { 'http://duckduckgo.com/' },
);

has _duckduckgo_api_url_secure => (
	is => 'ro',
	lazy => 1,
	default => sub { 'https://duckduckgo.com/' },
);

sub _add_cli_params {
	my ( $self, $uri ) = @_;
	$uri->query_param( l => 'us-en' );
	$uri->query_param( p => 1 );
	$uri->query_param( s => 0 );
	$uri->query_param( t => 'cli' );
}

sub cliinfo {
	my ( $self, @query_fields ) = @_;
	return if !@query_fields;
	my $query = join(' ',@query_fields);
	my $res;
	eval {
		$res = $self->_http_agent->request($self->cliinfo_request_secure(@query_fields));
	};
	if (!$self->forcesecure and ( $@ or !$res or !$res->is_success ) ) {
		warn __PACKAGE__." HTTP request failed: ".$res->status_line if ($res and !$res->is_success);
		warn __PACKAGE__." Can't access ".$self->_duckduckgo_api_url_secure." falling back to: ".$self->_duckduckgo_api_url;
		$res = $self->_http_agent->request($self->cliinfo_request(@query_fields));
	}
	return $self->cliinfo_by_response($res);
}

sub _cliinfo_uri {
	my $self = shift;
	my $uri = $self->_zeroclickinfo_uri(@_);
	$self->_add_cli_params($uri);
	return $uri;
}

sub cliinfo_by_response {
	my ( $self, $response ) = @_;
	if ($response->is_success) {
		my $result = decode_json($response->content);
		return $self->_cliinfo_class->by($result);
	} else {
		die __PACKAGE__.' HTTP request failed: '.$response->status_line, "\n";
	}
}

sub cliinfo_request_secure {
	my ( $self, @query_fields ) = @_;
	return if !@query_fields;
	return $self->_request_base($self->_duckduckgo_api_url_secure,@query_fields);
}

sub cliinfo_request {
	my ( $self, @query_fields ) = @_;
	return if !@query_fields;
	return $self->_request_base($self->_duckduckgo_api_url,@query_fields);
}

sub deep {
	my ( $self, $url_path ) = @_;

	my $res;
	eval {
		$res = $self->_http_agent->request(HTTP::Request->new(GET => $self->_duckduckgo_api_url_secure . $url_path));
	};
	if (!$self->forcesecure and ( $@ or !$res or !$res->is_success ) ) {
		warn __PACKAGE__." HTTP request failed: ".$res->status_line if ($res and !$res->is_success);
		warn __PACKAGE__." Can't access ".$self->_duckduckgo_api_url_secure." falling back to: ".$self->_duckduckgo_api_url;
		$res = $self->_http_agent->request(HTTP::Request->new(GET => $self->_duckduckgo_api_url_secure . $url_path));
	}

	my @raw = @{decode_json($res->content)};
	my $json;
	my @return = ();
	foreach $json (@raw) {
		push(@return, $self->_deep_class->by($json));
	}
	@return;
}


1;


=head1 TODO

 * documentation
 * tests
