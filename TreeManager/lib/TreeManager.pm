package TreeManager;
use Dancer ':syntax';
use Dancer::Plugin::FlashMessage;
use Tree;
use TreeStorage;
use Data::Dumper;

our $VERSION = '0.1';

get '/' => sub {
    my $storage = TreeStorage->new();
    my $names = $storage->getAllTreeNames();
    my $tree;
    if (session->{activeTree}) {
        $tree = Tree->new(session->{activeTree});
        $tree->loadFromStorage();
    }

    template 'index', {
        treeNames => $names,
        activeTree => session->{activeTree},
        tree => $tree && !$tree->isEmpty() ? $tree->toHtml() : '',
    };
};

get '/selectTree' => sub {
    if (params->{selectedTree}) {
        TreeStorage->new()->setActiveTree( config->{user_id}, params->{selectedTree} );
        session activeTree => params->{selectedTree};
    }
    redirect '/';
};

post '/createTree' => sub {
    my $storage = TreeStorage->new();
    if (length (params->{treeName}) > 0) {
        if ($storage->existsTreeName(params->{treeName})) {
            flash errorTreeCreate => "Tree name already exists";
        } else {
            $storage->saveNewTreeName(params->{treeName}, config->{user_id});
        }
    } else {
        flash errorTreeCreate => "Tree name cannot be empty";
    }
    
    redirect '/';
};

post '/createRootNode' => sub {
    Tree->new(session->{activeTree})->addRoot() if defined session->{activeTree};
    redirect '/';
};

get '/addNode/:nodeId' => sub {
    redirect '/' unless defined session->{activeTree};
    my $tree = Tree->new(session->{activeTree});
    if (
        params->{addNode} &&
        params->{addNode} =~ /^\d+$/ &&
        defined $tree->getNode(params->{nodeId})
    ) {
        $tree->addNode(params->{nodeId});
    } else {
        flash errorAddNode => "Node ID not found";
    }
    redirect '/';
};

post '/addNode' => sub {
    redirect '/' unless defined session->{activeTree};
    my $tree = Tree->new(session->{activeTree});
    $tree->loadFromStorage();
    if (
        params->{nodeId} &&
        params->{nodeId} =~ /^\d+$/ &&
        defined $tree->getNode(params->{nodeId})
    ) {
        $tree->addNode(params->{nodeId});
    } else {
        flash errorAddNode => "Node ID not found";
    }
    redirect '/';
};

true;
