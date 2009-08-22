package POEx::Role::TCPServer;
our $VERSION = '0.092340';


#ABSTRACT: A Moose Role that provides TCPServer behavior

use MooseX::Declare;

role POEx::Role::TCPServer 
{
    with 'POEx::Role::SessionInstantiation';
    use MooseX::AttributeHelpers;
    use POEx::Types(':all');
    use MooseX::Types::Structured('Dict', 'Tuple', 'Optional');
    use MooseX::Types::Moose(':all');
    use POE::Wheel::ReadWrite;
    use POE::Wheel::SocketFactory;
    use POE::Filter::Line;
    
    use aliased 'POEx::Role::Event';


    requires 'handle_inbound_data';


    has socket_factory =>
    (
        is          => 'rw',
        isa         => Object,
        predicate   => 'has_socket_factory',
        clearer     => 'clear_socket_factory',
    );


    has wheels =>
    (
        metaclass   => 'MooseX::AttributeHelpers::Collection::Hash',
        is          => 'rw',
        isa         => HashRef,
        lazy        => 1,
        default     => sub { {} },
        clearer     => 'clear_wheels',
        provides    =>
        {
            get     => 'get_wheel',
            set     => 'set_wheel',
            delete  => 'delete_wheel',
            count   => 'count_wheels',
            exists  => 'has_wheel',
        }
    );


    has filter =>
    (
        is          => 'rw',
        isa         => Filter,
        default     => sub { POE::Filter::Line->new() }
    );


    has listen_ip => 
    (
        is          => 'ro',
        isa         => Str,
        required    => 1,
    );
    

    has listen_port => 
    (
        is          => 'ro',
        isa         => Int,
        required    => 1,
    );


    after _start(@args) is Event
    {
        my $factory = POE::Wheel::SocketFactory->new
        (
            BindAddress     => $self->listen_ip,
            BindPort        => $self->listen_port,
            Reuse           => 1,
            SuccessEvent    => 'handle_on_connect',
            FailureEvent    => 'handle_listen_error',
        );
        $self->socket_factory($factory);
    }


    method handle_on_connect (GlobRef $socket, Str $address, Int $port, WheelID $id) is Event
    {
        my $wheel = POE::Wheel::ReadWrite->new
        (
            Handle          => $socket,
            Filter          => $self->filter->clone(),
            InputEvent      => 'handle_inbound_data',
            ErrorEvent      => 'handle_socket_error',
            FlushedEvent    => 'handle_on_flushed',
        );
        
        $self->set_wheel($wheel->ID, $wheel);
    }


    method handle_listen_error(Str $action, Int $code, Str $message) is Event
    {
        warn "Received listen error: Action $action, Code $code, Message $message"
            if $self->options->{'debug'};
    }


    method handle_socket_error(Str $action, Int $code, Str $message, WheelID $id) is Event
    {
        warn "Received socket error: Action $action, Code $code, Message $message"
            if $self->options->{'debug'};
    }


    method handle_on_flushed(WheelID $id) is Event
    {
        1;
    }



    method shutdown() is Event
    {
        $self->clear_socket_factory;
        $self->clear_wheels;
        $self->clear_alias;
        $self->poe->kernel->alias_remove($_) for $self->poe->kernel->alias_list();
    }

}

1;



=pod

=head1 NAME

POEx::Role::TCPServer - A Moose Role that provides TCPServer behavior

=head1 VERSION

version 0.092340

=head1 REQUIRES

=head2 METHODS

=head3 handle_inbound_data($data, WheelID $id) is Event

This required method will be passed the data received, and from which wheel 
it came. 



=head1 DESCRIPTION

POEx::Role::TCPServer bundles up the lower level SocketFactory/ReadWrite
combination of wheels into a simple Moose::Role. It builds upon other POEx
modules such as POEx::Role::SessionInstantiation and POEx::Types. 

The events for SocketFactory for and for each ReadWrite instantiated are
methods that can be advised in any way deemed fit. Advising these methods
is actually encouraged and can simplify code for the consumer. 

The only method that must be provided by the consuming class is 
handle_inbound_data.

=head1 ATTRIBUTES

=head2 socket_factory is: rw, isa: Object, predicate: has_socket_factory, clearer: clear_socket_factory

The POE::Wheel::SocketFactory created in _start is stored here.



=head2 wheels metaclass: Collection::Hash, is: rw, isa: HashRef, clearer: clear_wheels

When connections are accepted, a POE::Wheel::ReadWrite object is created and 
stored in this attribute, keyed by WheelID. Wheels may be accessed via the
following provided methods. See MooseX::AttributeHelpers::Collection::Hash
for more details.

    provides    =>
    {
        get     => 'get_wheel',
        set     => 'set_wheel',
        delete  => 'delete_wheel',
        count   => 'count_wheels',
        exists  => 'has_wheel',
    }



=head2 filter is: rw, isa: Filter

This stores the filter that is used when constructing wheels. It will be cloned
for each connection accepted.



=head2 listen_ip is: ro, isa: Str, required

This will be used as the BindAddress to SocketFactory



=head2 listen_port is: ro, isa: Int, required

This will be used as the BindPort to SocketFactory



=head2 after _start(@args) is Event

The _start event is after-advised to do the start up of the SocketFactory.



=head2 handle_on_connect(GlobRef $socket, Str $address, Int $port, WheelID $id) is Event

handle_on_connect is the SuccessEvent of the SocketFactory instantiated in _start. 



=head2 handle_listen_error(Str $action, Int $code, Str $message) is Event

handle_listen_error is the FailureEvent of the SocketFactory



=head2 handle_socket_error(Str $action, Int $code, Str $message, WheelID $id) is Event

handle_socket_error is the ErrorEvent of each POE::Wheel::ReadWrite instantiated.



=head2 handle_on_flushed(WheelID $id) is Event

handle_on_flushed is the FlushedEvent of each POE::Wheel::ReadWrite instantiated.



=head2 shutdown() is Event

shutdown unequivically terminates the TCPServer by clearing all wheels and 
aliases, forcing POE to garbage collect the session.



=head1 AUTHOR

  Nicholas Perez <nperez@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2009 by Nicholas Perez.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=cut 



__END__
