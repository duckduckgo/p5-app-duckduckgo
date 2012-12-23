package App::DuckDuckGo::Deep;
# ABSTRACT: A DuckDuckGo deep query result

use Moo;
use URI;


sub by {
	my ( $class, $deep_result ) = @_;
	my ( %params, $result_key, $params_key );
	my %map = (
		   'a' => 'abstract',
		   't' => 'title',
		   'u' => 'url',
		   'n' => 'next'
		  );
	while (($result_key, $params_key) = each %map) {
		$params{$params_key} = $deep_result->{$result_key} if $deep_result->{$result_key};
	}
	__PACKAGE__->new(%params);
}


has url		=> ( is => 'ro', predicate => 'has_url' );
has abstract	=> ( is => 'ro', predicate => 'has_abstract' );
has title	=> ( is => 'ro', predicate => 'has_title' );
has next	=> ( is => 'ro', predicate => 'has_next' );

1;


=head1 TODO

 * documentation
 * tests
