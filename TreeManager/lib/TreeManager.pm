package TreeManager;
use Dancer ':syntax';
use Data::Dumper;
use TreeStorage;

our $VERSION = '0.1';

get '/' => sub {

    my $names = TreeStorage->new()->getAllTreeNames();
    template 'index', { tree_name => $names };
};

get '/selectTree' => sub {
    debug "selected tree: " . params->{selectedTree};
    debug "user id: " . config->{user_id};
    redirect '/';
};

get '/orig' => sub {
    template 'index_orig';
};

true;
