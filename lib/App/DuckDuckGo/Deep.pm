package App::DuckDuckGo::Deep;
# ABSTRACT: A DuckDuckGo deep query result

use Moo;
use URI;

use Data::Dumper;


sub by {
	my ( $class, $raw_results ) = @_;
	my ( %params, $result_key, $params_key, $raw_result, @results );
	my %map = (
		   'a' => 'abstract',
		   't' => 'title',
		   'u' => 'url',
		   'n' => 'next'
		  );

	foreach $raw_result (@{$raw_results}) {
		while (($result_key, $params_key) = each %map) {
			$params{$params_key} = $raw_result->{$result_key} if $raw_result->{$result_key};
		}
		push @results, __PACKAGE__->new(%params);
	}
	return @results;
}


has url		=> ( is => 'ro', predicate => 'has_url' );
has abstract	=> ( is => 'ro', predicate => 'has_abstract' );
has title	=> ( is => 'ro', predicate => 'has_title' );
has next	=> ( is => 'ro', predicate => 'has_next' );

1;


=head1 TODO

 * documentation
 * tests
