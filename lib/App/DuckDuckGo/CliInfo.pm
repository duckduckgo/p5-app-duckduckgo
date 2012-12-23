package App::DuckDuckGo::CliInfo;
# ABSTRACT: DuckDuckGo CLI API response definition

use Moo;
use WWW::DuckDuckGo::ZeroClickInfo;
use JSON;

extends 'WWW::DuckDuckGo::ZeroClickInfo';


has deep_query => (
		   is => 'ro',
		   predicate => 'has_deep_query',
		  );

has spelling_query => (
		       is => 'ro',
		       predicate => 'has_spelling_query'
		      );

around '_build_params' => sub {
	my ( $orig, $class, $result ) = @_;
	my %params = $class->$orig($result);
	$params{deep_query} = $result->{'Calls'}->{'deep'} if $result->{'Calls'}->{'deep'};
	$params{spelling_query} = $result->{'Calls'}->{'spelling'} if $result->{'Calls'}->{'spelling'};
	return %params;
};

sub by {
	my ( $class, $result ) = @_;
	my %params = $class->_build_params($result);
	__PACKAGE__->new(%params);
}


1;


=head1 TODO

 * documentation
 * tests
