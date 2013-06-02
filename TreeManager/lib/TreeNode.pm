=head1 NAME

TreeNode

=head1 DESCRIPTION
Data structure, primary for usage as node in data structure Tree.

=cut
package TreeNode;
use strict;
use warnings;

use base 'Node';

sub new {
	my $class = shift;
	my $id = shift;
	my $parentId = shift;
	my $depth = shift;
	my $self = $class->SUPER::new($id);

	$self->{parentId} = $parentId;
	$self->{depth} = $depth;
	return $self;
}

sub getParentId {
        my $self = shift;
        return $self->{parentId};
}

sub getDepth {
	my $self = shift;
	return $self->{depth};
}

sub setParentId {
        my $self = shift;
        my $parentId = shift;
        die ("Parrent ID not set") if (!defined $parentId);
        $self->{parentId} = $parentId;
}

sub setDepth {
	my $self = shift;
	my $depth = shift;
	die ("Depth not set") if (!defined $depth);
	$self->{depth} = $depth;
}

sub toString {
	my $self = shift;
	return $self->Node::toString . ",parentID:" . (defined $self->{parentId} ? $self->{parentId} : "NONE") . ",depth:" . $self->{depth};
}

sub toHtml {
	my $self = shift;
	return "[" . "P: " . (defined $self->{parentId} ? $self->{parentId} : "NONE") . " ID: " . $self->{id} . "]";
}

=head1 AUTHOR

Milos Kukla <m.kukla@centrum.cz>

=cut

1;
