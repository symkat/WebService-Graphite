package WebService::Graphite::Backend::IOSocket;
use Moo;
with qw( WebService::Graphite::Backend WebService::Graphite::Errors );
use IO::Socket::INET;
use Scalar::Util qw( looks_like_number );

has connection => (
    is      => 'rwp',
    lazy    => 1,
    builder => 1,
    isa     => sub { ref $_ eq 'IO::Socket::INET' },
);

sub write {
    my ( $self, @args ) = @_;

    $self->trace("Inside _write");

    if ( ! $self->connection->connected ) {
        $self->_set_connection( $self->_build_connection );
    }

    my $payload = join "", map { sprintf( "%s %s %i\n", @$_ ) } @args;

    while ( length $payload ) {
        my $written = $self->connection->send( $payload );
        substr( $payload, 0, $written, "" );
    }
    $self->trace( "Sent records to Graphite." );

    return 1;
}

sub _build_connection {
    my ( $self ) = @_;

    return IO::Socket::INET->new(
        PeerAddr => $self->host,
        PeerPort => $self->port,
        Timeout  => $self->timeout,
        Proto    => 'tcp',
    ) or $self->error( "Error: Failed to connect to %s", $self->host );
}

sub DEMOLISH { shift->connection->shutdown }

1;
