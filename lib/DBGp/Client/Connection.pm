package DBGp::Client::Connection;

use strict;
use warnings;

=head1 NAME

DBGp::Client::Connection - DBGp connection class

=head1 SYNOPSIS

    $connection = $listener->accept;

    $res = $connection->send_command('step_over');
    die $res->message if $res->is_error;

    $res = $connection->send_command('eval', '--', encode_base64('$var'));
    die $res->message if $res->is_error;

    # assumes result is a scalar value, it should check ->children
    print $res->result->value, "\n";

=head1 DESCRIPTION

Simple blocking interface for a DBGp connection.

=head1 METHODS

=cut

use DBGp::Client::Stream;
use DBGp::Client::Parser;

=head2 new

    $connection = DBGp::Client::Connection->new(
        socket  => $connected_socket,
    );

Usually called by L<DBGp::Client::Listener>, not used directly.

Creates a new connection object wrapping the passed-in socket; after
construction, call L</parse_init> to process the initialization message
sent by the debugger.

=cut

sub new {
    my ($class, %args) = @_;
    my $stream = DBGp::Client::Stream->new(socket => $args{socket});
    my $self = bless {
        stream      => $stream,
        sequence    => 0,
        init        => undef,
    }, $class;

    return $self;
}

=head2 parse_init

    $init = $connection->parse_init;

Usually called by L<DBGp::Client::Listener>, not used directly.

Parses the init message sent by the debugger, and returns a
L<DBGp::Client::Response/init> object.

=cut

sub parse_init {
    my ($self) = @_;

    $self->{init} = DBGp::Client::Parser::parse($self->{stream}->get_line);
}

=head2 send_command

    $res = $connection->send_command('step_over');
    $res = $connection->send_command('eval', '--', 'base64-encoded-data');

Sends a command to the debugger, parses the answer and returns it as a
response object (see L<DBGp::Client::Response>).

It automatically adds the DBGp transaction id (C<-i> parameter) to the
command.

Note that this method could block indefinitely.

=cut

sub send_command {
    my ($self, $command, @args) = @_;

    $self->{stream}->put_line($command, '-i', ++$self->{sequence}, @args);
    my $res = DBGp::Client::Parser::parse($self->{stream}->get_line);

    # TODO <stream> and <notify> responses

    die 'Mismatched transaction IDs: got ', $res->transaction_id,
            ' expected ', $self->{sequence}
        if $res && $res->transaction_id != $self->{sequence};

    return $res;
}

1;

__END__

=head1 AUTHOR

Mattia Barbon <mbarbon@cpan.org>

=head1 LICENSE

Copyright (c) 2015 Mattia Barbon. All rights reserved.

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
