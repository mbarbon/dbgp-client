package DBGp::Client::Connection;

use strict;
use warnings;

use DBGp::Client::Stream;
use DBGp::Client::Parser;

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

sub parse_init {
    my ($self) = @_;

    $self->{init} = DBGp::Client::Parser::parse($self->{stream}->get_line);
}

sub send_command {
    my ($self, $command, @args) = @_;

    $self->{stream}->put_line($command, '-i', ++$self->{sequence}, @args);
    my $res = DBGp::Client::Parser::parse($self->{stream}->get_line);

    die 'Mismatched transaction IDs: got ', $res->transaction_id,
            ' expected ', $self->{sequence}
        if $res && $res->transaction_id != $self->{sequence};

    return $res;
}

1;
