package WebService::Graphite;
use Moo;
use MooX::ObjectBuilder;
use Module::Runtime qw( use_module );
use Data::Dumper;
with qw( WebService::Graphite::Errors );

has key => (
    is      => 'rw',
);

has host => (
    is => 'ro',
);

has _backend => ( 
    is  => make_builder( sub {
            my ( $args ) = @_;

            $args->{backend} = "IOSocket" unless $args->{backend};
            
            my $backend = index($args->{backend}, '+') != -1
                ? $args->{backend} 
                : 'WebService::Graphite::Backend::' . $args->{backend};

            delete $args->{backend};

            return use_module($backend)->new($args)
        }, [  
            qw( host port timeout backend warn_on_error die_on_error 
                stacktrace_on_error enable_trace 
            ) 
        ],
    ),
);

has send_buffer => (
    is      => 'rwp',
    default => sub { "" },
);

# Valid Uses:
#
#       ( $key, $value, $timestamp )
#       ( $key, $value )
#       ( $value )
#       Also, arrayref of arrayrefs of those values.

sub send {
    my ( $self, @args ) = @_;

    if ( ref $args[0] eq 'ARRAY' ) {
        return $self->_backend->write( $self->_handle_arrayrefs( $args[0] ) );
    } elsif ( ref $args[0] eq 'HASH' ) {
        # Handle Hashes
    }

    # Okay, we just have a list of strings,
    # treat it like a single element of an
    # array ref
    return $self->_backend->write(
        $self->_handle_arrayrefs( [ [ @args ] ] )
    );
}

sub _handle_arrayrefs {
    my ( $self, $refs ) = @_;

    my @results;

    for my $ref ( @$refs ) {
        if ( @$ref == 3 ) {
            push @results, [ $ref->[0], $ref->[1], $ref->[2] ];
        } elsif ( @$ref == 2 ) {
            push @results, [ $ref->[0], $ref->[1], time ];
        } elsif ( @$ref == 1 ) {
            if ( ! $self->key ) { 
                return $self->error( "You must set key() to call write() with one argument." );
            }
            push @results, [ $self->key, $ref->[0], time ];
        } else {
            return $self->error( "Too Many Arguments, or no Arguments");
        }
    }

    return @results;
}

1;

=encoding UTF-8

=head1 NAME

WebService::Graphite - Perl Graphite Library

=head1 DESCRIPTION

WebService::Graphite provides a client to send data to a graphite node.

=head1 SYNOPSIS

    #!/usr/bin/perl
    use warnings;
    use strict;
    use WebService::Graphite;

    my $Graphite = WebService::Graphite->new(
        host    => 'http://my.graphite_server.com',
        port    => 2003,
        timeout => 60,
        backend => 'IOSocket',
    );

    # Send one metric per call to send(),
    # if time is ommited the current time is used

    $Graphite->send( 'my.metric.path' 60 time );
    $Graphite->send( 'my.metric.path' 60 );

    # Set the attribute key and you can send one
    # value at a time.

    $Graphite->key( 'my.metric.path' );
    $Graphite->send( 65 );
    $Graphite->send( 70 );

    # Send multiple values at once by using array
    # references.

    $Graphite->send( 
        [ 'my.metric.path.b', 70, time ],
        [ 'my.metric.path.a', 60 ], 
        [ 30 ], # ->key must be set before hand.
    );

=head1 CONSTRUCTOR

The constructor takes the following arguments as a list or a hash ref.

=head2 host

The hostname to your graphite server.

=over 4 

=item * Accepts: IPv4 address, IPv6 address, or hostname.

=item * Default: 127.0.0.1

=back

=head2 port

The port to connect to graphite on.

=over 4 

=item * Accepts: Port number between 0 and 65535

=item * Default: 2003

=back

=head2 timeout

The timeout to use for the connection to graphite.

=over 4 

=item * Accepts: Integer equal to or greater than 0.

=item * Default: 0

=back

=head2 backend

The backend to use for sending data to graphite.  By default this
library uses B<IOSocket>, which uses the popular IO::Socket::INET
connection for TCP connections to Graphite.

=over 4 

=item * Accepts:

=over 4

=item * "+Full::Path::To::Backend" - A string prefixed with + will 
use that as the fully qualified path to the library.

=item * ModuleName - A string without the + prefix will use a library
based on the prefix WebService::Graphite::Backend::ModuleName

=back

=item * Default: IOSocket

=back

=head2 key

When supplied, this is the path to a metric for Graphite, it will be used when
using C<send> in single-argument mode through C<-E<gt>send( int )> or 
C<-E<gt>send( [ [ int ], [ int ] ] )>

=over 4 

=item * Accepts: A graphite path

=item * Default: Not set by default 

=back

=head1 AUTHOR

=over 4 

=item * Kaitlyn Parkhurst (SymKat) I<E<lt>symkat@symkat.comE<gt>>

=back

=head1 CONTRIBUTORS

=head1 COPYRIGHT AND LICENSE

This library is free software and may be distributed under the same terms
as perl itself.

=head1 AVAILABILITY

The latest version of this software is available at
L<https://github.com/symkat/WebService-Graphite>

1;
