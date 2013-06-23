=head1 NAME

Tree

=head1 DESCRIPTION
Data structure representing unary tree (=tree, where every node has the only pointer - to his parent node).

=cut
package Tree;
use warnings;
use strict;
use JSON;
use URI::Escape;
use TreeNode;
use TreeStorage;

sub new {
	my $class = shift;
	my $name = shift || "default";
	my $storage = TreeStorage->new();
	my $self = {
		nodes => [],
		maxId => 0,
		name => $name,
		storage => $storage,
	};
	bless $self, $class;
	return $self;
}

# Adds root node to the tree and stores it to the storage
sub addRoot {
	my $self = shift;
	die ("Node already set") if (scalar @{$self->{nodes}} > 0);
	my $node = TreeNode->new;
	$node->setId(++$self->{maxId});
	$node->setDepth(0);
	push (@{$self->{nodes}}, $node);
	$self->{storage}->saveNode($node, $self->{name});
}

# Returns the root node.
sub getRoot {
    my $self = shift;
    return $self->isEmpty() ? undef : $self->{nodes}->[0];
}

sub getName {
	my $self = shift;
	return $self->{name};
}

# Returns node with given ID or undef
sub getNode {
	my $self = shift;
	my $id = shift;
	die ("ID not set") if (!defined $id);
	
	foreach my $node ( @{$self->{nodes}} ) {
		return $node if ($node->getId() == $id);
	}
	return undef;
}

# Adds new node to the node represented by parentId and stores new node to the storage
sub addNode {
	my $self = shift;
	my $parentId = shift;
	die ("Parent ID not set") if (!defined $parentId);
	my $parentNode = $self->getNode($parentId);
	die ("Parent ID not found") if (!defined $parentNode);
	my $node = TreeNode->new;
	$node->setId(++$self->{maxId});
	$node->setParentId($parentId);
	$node->setDepth($parentNode->getDepth()+1);
	push (@{$self->{nodes}}, $node);
	$self->{storage}->saveNode($node, $self->{name});
}

# Saves tree name to the storage
sub saveNewTreeName {
	my $self = shift;
	$self->{storage}->saveNewTreeName($self->{name});
}

# Loads and re-create tree structure from the storage.
sub loadFromStorage {
	my $self = shift;
	$self->{nodes} = $self->{storage}->getNodes($self->{name});
	foreach my $node (@{$self->{nodes}}) {
		defined $node->getParentId() ? $node->setDepth($self->getNode($node->getParentId())->getDepth()+1) : $node->setDepth(0);
		$self->{maxId} = $node->getId() if ($node->getId() > $self->{maxId});
	}
}

# Return all sub-nodes of given node.
sub getChildren {
    my $self = shift;
    my $node = shift;
    return grep { (defined $_->getParentId() ? $_->getParentId() : -1) == $node->getId() } @{$self->{nodes}};
}

sub toString {
	my $self = shift;
	my $string = "";
	foreach my $node (@{$self->sort()}) {
		$string.= $node->toString . "\n";
	}
	return $string;
}

# Return HMLT representation of the tree.
# Options are table or list, list is default.
sub toHtml {
    my $self = shift;
    my $type = shift || 'list';
    return $self->toHtmlTable() if $type eq 'table';
    return $self->toHtmlList();
 }

# Return graphical representation of the tree as HTML table.
sub toHtmlTable {
	my $self = shift;
    return if $self->isEmpty();
	my $parentId = 0;
	my $depth = 0;
	my $string = "<table>";
	foreach my $node (@{$self->sort()}) {
		if (!defined $node->getParentId()) {
			$string.= "<td>" . $node->toHtml();
		} else {
			my $depthChanged = 0;
			if ($node->getDepth() != $depth) {
				$string.= "</td></tr><tr><td>";
				$depth = $node->getDepth();
				$depthChanged = 1;
			}
			if ($node->getParentId() != $parentId) {
				$string.= "</td><td>" if (!$depthChanged);
				$parentId = $node->getParentId();
			}
			$string.= $node->toHtml() . "&nbsp";
		}
	}
	$string.= "</table>";
	return $string;
}

# Return graphical representation of the tree as HTML list.
sub toHtmlList {
	my $self = shift;
    return if $self->isEmpty();
	my $parentId = 0;
	my $depth = 0;
	my $string = '<ul>';
    $string.= $self->toHtmlListRecursive($self->getRoot());
	$string.= '</ul>';
	return $string;
}
sub toHtmlListRecursive {
    my $self = shift;
    my $node = shift;
    return '' unless $node;
    my $string = '<li>' . $node->getId();
    my @children = $self->getChildren($node);
    if (@children) {
        $string.= '<ul>';
        for (@children) {
            $string.= $self->toHtmlListRecursive($_);
        }
        $string.= '</ul>';
    }
    $string.= '</li>';
    return $string;
}

# Return tree nodes in JSON format.
sub toJSON {
    my $self = shift;
    my $data = [];
    for (@{$self->{nodes}}) {
        push @$data, [ $_->getId(), $_->getParentId() ];
    }
    return uri_escape(encode_json($data));
}

# If has structure any node
sub isEmpty {
	my $self = shift;
    return !defined $self->{nodes}->[0];
}

# sorts nodes by parent ID and node ID
sub sort {
	my $self = shift;
	my @sorted = sort {
		if (!defined $a->getParentId() || $a->getParentId() < $b->getParentId()) { return -1; }
		elsif ($a->getParentId() > $b->getParentId()) { return 1; }
		else { return $a->getId() <=> $b->getId() }
	} @{$self->{nodes}};
	return \@sorted;
}

=head1 AUTHOR

Milos Kukla <m.kukla@centrum.cz>

=cut

1;
