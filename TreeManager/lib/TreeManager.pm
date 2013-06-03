package TreeManager;
use Dancer ':syntax';
use Dancer::Plugin::FlashMessage;
use TreeStorage;

our $VERSION = '0.1';

get '/' => sub {
    my $storage = TreeStorage->new();
    my $names = $storage->getAllTreeNames();
    my $activeTree = $storage->getActiveTree( config->{user_id} );
    template 'index', { treeNames => $names, activeTree => $activeTree };
};

get '/selectTree' => sub {
    if (params->{selectedTree}) {
        TreeStorage->new()->setActiveTree( config->{user_id}, params->{selectedTree} );
    }
    redirect '/';
};

post '/createTree' => sub {
    my $storage = TreeStorage->new();
    if (length (params->{treeName}) > 0) {
        if ($storage->existsTreeName(params->{treeName})) {
            flash error => "Tree name already exists";
        } else {
            $storage->saveNewTreeName(params->{treeName}, config->{user_id});
        }
    } else {
        flash error => "Tree name cannot be empty";
    }
    
    redirect '/';
};

true;
