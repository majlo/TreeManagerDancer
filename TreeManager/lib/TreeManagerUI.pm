=head1 NAME

TreeManagerUI

=head1 DESCRIPTION
Web page representing user interface for manipulation multiple instances of Tree data structure. 

=cut
package TreeManagerUI;
use warnings;
use CGI qw(:standard);
use Tree;
use TreeStorage;

# Web application can be accessed by many users at the same time. Modification of the same tree by multiple users can cause problems. My idea is allow access specific tree for one user only at the time. 
# I hadn't enough time to create fully functional multi user web application, so I wanted to show my idea by specification just one user.
use constant USER_ID => 1;

sub handler {
	my $r = shift;
	my $req = Apache2::Request->new($r);

	print header;
	print start_html(
		-title => "TreeManager",
		-style => "css/style.css",
	);

	my $errorControl = "";	# error messages shown on the page in the cause of error
	my $errorView = "";

	my $storage = TreeStorage->new();	# database connection

	# new tree creation
	if ($req->param("createTree")) {
		if (length ($req->param("treeName")) > 0) {
			if ($storage->existsTreeName($req->param("treename"))) {
				$errorControl = "Tree name already exists.";
			} else {
				$storage->saveNewTreeName($req->param("treeName"), USER_ID);
			}
		} else {
			$errorControl = "Tree name cannot be empty.";
		}
	}

	# tree selection
	if ($req->param("selectTree")) {
		$storage->setActiveTree(USER_ID, $req->param("selectedTree"));
	}

	my $treeNames = $storage->getAllTreeNames();
	my $activeTree = $storage->getActiveTree(USER_ID);
	my $tree = undef;
	if (defined $activeTree) {
		$tree = Tree->new($activeTree);
		$tree->loadFromStorage();
	}

	# creation of root node for the active tree
	if ($req->param("createRootNode")) {
		$tree->addRoot();
	}

	# addition of the new node to the active tree
	if ($req->param("addNode")) {
		if ($req->param("nodeId")=~/^\d+$/) {
			if (defined $tree->getNode($req->param("nodeId"))) {
				$tree->addNode($req->param("nodeId"));
			} else {
				$errorView = "Node ID not found.";
			}
		} else {
			$errorView = "Invalid node ID.";
		}
	}

	# headline
	print '<div id="title">';
		print h1 "TreeManager";
	print '</div>';

	# selection and creation of trees
	print '<div id="treecontrol">';
		if (scalar @{$treeNames} > 0) {
			print start_form,
			"Trees in database: ", popup_menu(-name => "selectedTree", -values => $treeNames),
			hidden(-name => "selectTree", -default => 1),
			submit("Select"),
			end_form;
		} else {
			print p "Currently no trees exists in database.";
		}
		print start_form,
		"Create new Tree:", textfield(-name => "treeName", -size => 30, -maxlength => 255, -value => ""), br,
		hidden(-name => "createTree", -default => 1);
		print span({-class => "error"}, $errorControl) if ($errorControl);
		print submit("Create"),
		end_form;
	print '</div>';

	# display of the active tree and new nodes adittion
	print '<div id="treeview">';
		if (defined $tree) {
			print p "Active Tree: ", $tree->getName();
			if ($tree->isEmpty()) {
				print p "Tree is empty.";
				print p start_form,
				hidden(-name => "createRootNode", -default => 1),
				submit("Create root node"),
				end_form;
			} else {
				print p $tree->toHtml();
				print p start_form,
				"Add node to:", textfield(-name => "nodeId", -size => 5, -maxlength => 30, -value => ""), br,
				hidden(-name => "addNode", -default => 1);
				print span({-class => "error"}, $errorView, br) if ($errorView);
				print submit("Add"),
				end_form;
			}
		} else {
			print p "No active tree to display";
		}
	print '</div>';

	print end_html;
	return Apache::Const::OK;
}

=head1 AUTHOR

Milos Kukla <m.kukla@centrum.cz>

=cut

1;
