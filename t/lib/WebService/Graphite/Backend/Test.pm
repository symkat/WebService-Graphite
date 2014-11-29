package WebService::Graphite::Backend::Test;
use Moo;
with qw( WebService::Graphite::Backend );

# This testing backend allows us to see the data
# sent to the backend based on our calls to 
# WebService::Graphite->send( )

sub write {
    my ( $self, $arrayref ) = @_;

    return $arrayref;
}

1;
