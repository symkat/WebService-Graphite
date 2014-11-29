package WebService::Graphite::Backend;
use Moo::Role;
use Data::Validate::Domain;
use Data::Validate::IP;
use Scalar::Util qw( looks_like_number );

requires 'write';

has host => (
    is      => 'rw',
    isa     => sub { is_ipv4( $_[0] ) || is_ipv6( $_[0] ) || is_domain($_[0]) },
    default => sub { "127.0.0.1" },
);

has port => (
    is      => 'rw',
    isa     => sub { looks_like_number( $_[0] ) && $_[0] >= 0 && $_[0] <= 65535 },
    default => sub { 2003 },
);

has timeout => (
    is      => 'ro',
    isa     => sub { looks_like_number($_[0]) && $_[0] >= 0 },
    default => sub { 60 },
);

1;
