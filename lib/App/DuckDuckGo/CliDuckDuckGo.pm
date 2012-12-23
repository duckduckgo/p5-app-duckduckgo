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

sub cliinfo { shift->zeroclickinfo(@_); }

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
