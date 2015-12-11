package DBGp::Client::Listener;

use strict;
use warnings;

use IO::Socket;

use DBGp::Client::Connection;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        port    => $args{port},
        path    => $args{path},
        socket  => undef,
    }, $class;

    die "Specify either 'port' or 'path'" unless $self->{port} || $self->{path};

    return $self;
}

sub listen {
    my ($self) = @_;

    if ($self->{port}) {
        $self->{socket} = IO::Socket::INET->new(
            Listen    => 1,
            LocalAddr => '127.0.0.1',
            LocalPort => $self->{port},
            Proto     => 'tcp',
            ReuseAddr => 1,
            ReusePort => 1,
        );
    } elsif ($self->{path}) {
        if (-S $self->{path}) {
            unlink $self->{path} or die "Unable to unlink stale socket: $!";
        }

        $self->{socket} = IO::Socket::UNIX->new(
            Listen    => 1,
            Local     => $self->{path},
        );
    }

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
