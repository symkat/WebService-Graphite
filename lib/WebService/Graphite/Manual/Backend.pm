package WebService::Graphite::Manual::Backend;
1;

=head1 Manual for backend modules

This document describes the process for implementing a backend module
for WebService::Graphite.

=head1 What is a backend module?

The backend module provides a transport from the Perl code to the graphite
server.

A backend module is responsible for three things:

=over 4

=item * Translating a multi-dimensional array into a payload for graphite

=item * Sending that payload to graphite over the Internet

=item * Implementing a function C<write> as the entry point to the module.

=back

The backend module is given three pieces of information at instantiation,
these are provided by using the WebService::Graphite::Backend Moo role.

=over 4

=item * host - An IPv4, IPv6 or hostname

=item * port - The port number to connect on, 0-65355 

=item * timeout - The timeout the user expects to be respected

=back

=head1 How do I write one?

Your module should probably start off looking something like this:

    package WebService::Graphite::Backend::MyModuleName
    use Moo;
    with qw( WebService::Graphite::Backend WebService::Graphite::Errors );

    sub write {
        my ( $self, $payload ) = @_;
    }

    1;
WebService::Graphite::Backend gives you access to $self->host, $self->port, and $self->timeout.

WebService::Graphite::Errors gives you access to the methods $self->trace and $self->error
for debug tracing and error reporting.

$payload is an array reference of array references which each contain the path, value and time
stamp.

=head1 How can I add more construction arguments?

WebService::Graphite itself has an attribute _backend that uses make_builder to construct
backend objects.  Add additional arguments to the list of arguments fed into make_builder().

Patches to simply copy the entire argument list given to WebService::Graphite are welcome,
in the interim patches that give your backend arguments it needs from the user are welcome.

=head1 Can I add my module to your distribution?

It’s probably a better idea to make your own WebService::Graphite::Backend::YourModule
distribution and have it depend on WebService::Graphite.  Ideally I’d like to not include modules
in the core distribution that depend on larger networking/event packages like POE or AnyEvent.
