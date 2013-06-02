=head1 NAME

TreeStorage

=head1 DESCRIPTION
Class for accessing/inserting Tree data structure to defined storages. Currently MySQL is the only storage but class can be easily extended to other storages (PostgreSQL etc.)

=cut
package TreeStorage;
use warnings;
use strict;
use Dancer::Plugin::Database;
use Switch;
use TreeNode;

sub new {
	my $class = shift;
	my $type = shift || "mysql";
	my $self = {
		type => $type,
		handler => undef,
	};
	bless $self, $class;

	$self->{handler} = database();
	return $self;
}

# save one node to the storaga, if the given node already exists then is updated
sub saveNode {
	my $self = shift;
	my $node = shift;
	my $treeName = shift;
	die ("Node not set") if (!defined $node);
	die ("Tree name not set") if (!defined $treeName);
	switch ($self->{type}) {
		case "mysql" {
			my $sth = $self->{handler}->prepare("INSERT INTO tree(id_tree, id_node, id_parent) VALUES(?, ?, ?) ON DUPLICATE KEY UPDATE id_node = VALUES(id_node), id_parent = VALUES(id_parent)");
			$sth->execute($self->getTreeId($treeName), $node->getId(), $node->getParentId()) or die ("Could not save node: $DBI::errstr");
		}
		else {
			die ("Unknown type: $self->{type}");
		}
	}
}

# returns all nodes for given tree name
sub getNodes {
	my $self = shift;
	my $treeName = shift;
	die ("Tree name not set") if (!defined $treeName);
	switch ($self->{type}) {
		case "mysql" {
			my $sth = $self->{handler}->prepare("SELECT id_node, id_parent FROM tree WHERE id_tree = ? ORDER BY id_parent");
			$sth->execute($self->getTreeId($treeName)) or die ("Could not get nodes: $DBI::errstr");
			my $nodes = [];
			while (my ($nodeId, $parentId) = $sth->fetchrow_array()) {
				push (@{$nodes}, TreeNode->new($nodeId, $parentId));
			}
			return $nodes;
		}
		else {
			die ("Unknown type: $self->{type}");
		}
	}
}

# returns tree id for given tree name
sub getTreeId {
	my $self = shift;
	my $treeName = shift;
	die ("Tree name not set") if (!defined $treeName);
	switch ($self->{type}) {
		case "mysql" {
			my $sth = $self->{handler}->prepare("SELECT id FROM tree_name WHERE name = ?");
			$sth->execute($treeName) or die ("Could not retrieve tree ID: $DBI::errstr");
			my (@treeId) = $sth->fetchrow_array();
			die ("Tree ID not found for tree name: $treeName") if (!defined $treeId[0]);
			return $treeId[0];
		}
		else {
			die ("Unknown type: $self->{type}");
		}
	}
}

# returns all trees existing in storage
sub getAllTreeNames {
	my $self = shift;
	my @treeNames;
	switch ($self->{type}) {
		case "mysql" {
			my $sth = $self->{handler}->prepare("SELECT name FROM tree_name");
			$sth->execute() or die ("Could not retrieve tree names: $DBI::errstr");
			while (my (@treeName) = $sth->fetchrow_array()) {
				push (@treeNames, $treeName[0]);
			}
			return \@treeNames;
		}
		else {
			die ("Unknown type: $self->{type}");
		}
	}
}

# returns active tree for given user (if any)
sub getActiveTree {
	my $self = shift;
	my $userId = shift;
	die ("User ID not set") if (!defined $userId);
	switch ($self->{type}) {
		case "mysql" {
			my $sth = $self->{handler}->prepare("SELECT name FROM active_tree INNER JOIN tree_name ON active_tree.id_tree = tree_name.id WHERE id_user = ?");
			$sth->execute($userId) or die ("Could not retrieve active tree: $DBI::errstr");
			my (@treeName) = $sth->fetchrow_array();
			return $treeName[0];
		}
		else {
			die ("Unknown type: $self->{type}");
		}
	}
}

# sets active tree for given user
sub setActiveTree {
	my $self = shift;
	my $userId = shift;
	my $treeName = shift;
	die ("User ID not set") if (!defined $userId);
	die ("Tree name not set") if (!defined $treeName);
	switch ($self->{type}) {
		case "mysql" {
			my $sth = $self->{handler}->prepare("INSERT INTO active_tree(id_user, id_tree) VALUES(?, ?) ON DUPLICATE KEY UPDATE id_tree = VALUES(id_tree)");
			$sth->execute($userId, $self->getTreeId($treeName)) or die ("Could not set active tree: $DBI::errstr");
		}
		else {
			die ("Unknown type: $self->{type}");
		}
	}
}

# whether tree with given name exists in the storage
sub existsTreeName {
	my $self = shift;
	my $treeName = shift;
	die ("Tree name not set") if (!defined $treeName);
	switch ($self->{type}) {
		case "mysql" {
			my $sth = $self->{handler}->prepare("SELECT name FROM tree_name WHERE name = ?");
			$sth->execute($treeName) or die ("Could not retrieve tree name: $DBI::errstr");
			my (@result) = $sth->fetchrow_array();
			return defined $result[0] ? 1 : 0;
		}
		else {
			die ("Unknown type: $self->{type}");
		}
	}
}

# isnerts new tree name to the storage
sub saveNewTreeName {
	my $self = shift;
	my $treeName = shift;
	my $userId = shift;
	die ("Tree name not set") if (!defined $treeName);
	die ("User ID not set") if (!defined $userId);
	switch ($self->{type}) {
		case "mysql" {
			my $sth = $self->{handler}->prepare("INSERT INTO tree_name(name) VALUES(?)");
			$sth->execute($treeName) or die ("Could not save tree name: $DBI::errstr");
			$self->setActiveTree($userId, $treeName);
		}
		else {
			die ("Unknown type: $self->{type}");
		}
	}
}

=head1 AUTHOR

Milos Kukla <m.kukla@centrum.cz>

=cut

1;
