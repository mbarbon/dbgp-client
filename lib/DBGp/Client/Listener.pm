package DBGp::Client::Listener;

use strict;
use warnings;

use IO::Socket;

use DBGp::Client::Connection;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        port    => $args{port},
        socket  => undef,
    }, $class;

    return $self;
}

sub listen {
    my ($self) = @_;

    $self->{socket} = IO::Socket::INET->new(
        Listen    => 1,
        LocalAddr => '127.0.0.1',
        LocalPort => $self->{port},
        Proto     => 'tcp',
        ReuseAddr => 1,
        ReusePort => 1,
    );
    die "Unable to start listening: $!" unless $self->{socket};
}

sub accept {
    my ($self) = @_;
    my $sock = $self->{socket}->accept;
    my $conn = DBGp::Client::Connection->new(socket => $sock);

    $conn->parse_init;

    return $conn;
}

1;
