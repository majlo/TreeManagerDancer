=head1 NAME

Node

=head1 DESCRIPTION
Abstract data structure. It is the base class for more complex structures.

=cut
package Node;
use warnings;
use strict;

sub new {
	my $class = shift;
	my $id = shift;
	my $self = {
		id => $id,
	};
	bless $self, $class;
	return $self;
}

sub getId {
	my $self = shift;
	return $self->{id};
}

sub setId {
	my $self = shift;
	my $id = shift;
	die("Id not set") if !defined $id;
	$self->{id} = $id;
}

sub toString {
	my $self = shift;
	return "ID:". $self->{id};
}

=head1 AUTHOR

Milos Kukla <m.kukla@centrum.cz>

=cut

1;
