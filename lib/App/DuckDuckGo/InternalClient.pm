package App::DuckDuckGo::InternalClient;
# ABSTRACT: Interface to internal DDG APIs

use Moo;

	use DDP;

use JSON;
use App::DuckDuckGo::CliInfo;
use App::DuckDuckGo::Deep;

our $VERSION ||= '0.0development';

has _duckduckgo_api_url => (
	is => 'ro',
	lazy => 1,
	default => sub { 'http://api.duckduckgo.com/' },
);

has _duckduckgo_api_url_secure => (
	is => 'ro',
	lazy => 1,
	default => sub { 'https://api.duckduckgo.com/' },
);

has _deep_class => (
	is => 'ro',
	lazy => 1,
	default => sub { 'App::DuckDuckGo::Deep' },
);

has _http_agent => (
	is => 'ro',
	lazy => 1,
	default => sub {
		my $self = shift;
		my $ua = LWP::UserAgent->new;
		$ua->agent($self->http_agent_name);
		return $ua;
	},
);

has http_agent_name => (
	is => 'ro',
	lazy => 1,
	default => sub { __PACKAGE__.'/'.$VERSION },
);

has forcesecure => (
	is => 'ro',
	default => sub { 0 },
);

has safeoff => (
	is => 'ro',
	default => sub { 0 },
);

sub _request_builders {
	my ( $self, $path ) = @_;
	return (
		sub { HTTP::Request->new(GET => URI->new($self->_duckduckgo_api_url_secure . $path)->as_string); },
		sub { HTTP::Request->new(GET => URI->new($self->_duckduckgo_api_url . $path)->as_string); }
	       );
}

sub deep {
	my ( $self, $path ) = @_;
	my $items = WWW::DuckDuckGo->request($self->_http_agent, $self->forcesecure,
					     $self->_request_builders($path));
	map { $self->_deep_class->by($_) } @$items;
}


1;


=head1 TODO

 * documentation
 * tests
