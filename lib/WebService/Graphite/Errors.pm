package WebService::Graphite::Errors;
use Moo::Role;

has warn_on_error => (
    is      => 'ro',
    isa     => sub { $_[0] == 0 || $_[0] == 1 },
    default => sub { 0 },
);

has die_on_error => (
    is      => 'ro',
    isa     => sub { $_[0] == 0 || $_[0] == 1 },
    default => sub { 1 },
);

has stacktrace_on_error => (
    is      => 'ro',
    isa     => sub { $_[0] == 0 || $_[0] == 1 },
    default => sub { 0 },
);

has enable_trace => (
    is      => 'ro',
    isa     => sub { $_[0] == 0 || $_[0] == 1 },
    default => sub { 0 },
);

sub trace {
    my ( $self, $msg ) = @_;
    printf STDERR ">> WebService::Graphite: %s\n", $msg;
}

sub error {
    my ( $self, $error ) = @_;
    carp    $error if ( $self->warn_on_error && ! $self->stacktrace_on_error );
    croak   $error if ( $self->die_on_error  && ! $self->stacktrace_on_error );
    cluck   $error if ( $self->warn_on_error &&   $self->stacktrace_on_error );
    confess $error if ( $self->die_on_error  &&   $self->stacktrace_on_error );
}

1;
