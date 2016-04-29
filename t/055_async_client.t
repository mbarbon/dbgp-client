#!/usr/bin/perl

use t::lib::Test;

use IO::Select;
use DBGp::Client::AsyncConnection;

my $LISTEN = dbgp_listen();

dbgp_run_fake();

my $socket = $LISTEN->accept;

die "Did not receive any connection from the fake debugger: ", $LISTEN->error
    unless $socket;
$socket->blocking(0);

my $conn = DBGp::Client::AsyncConnection->new(socket => $socket);

pull_data_while($socket, sub { !$conn->init });

is($conn->init->language, 'Perl');

my $res1;
$conn->send_command(sub { $res1 = $_[0] }, 'stack_depth');
pull_data_while($socket, sub { !$res1 });

is($res1->transaction_id, 1);

my $res2;
$conn->send_command(sub { $res2 = $_[0] }, 'stack_depth');
pull_data_while($socket, sub { !$res2 });

is($res2->transaction_id, 2);

done_testing();

sub pull_data_while {
    my ($socket, $test) = @_;

    my $fds = IO::Select->new;

    $fds->add($socket);

    while ($test->()) {
        my ($rd, undef, $err) = $fds->select($fds, undef, $fds, 10);

        die "There was an error" if $err && @$err;

        # uses 1 to test the buffering/parsing logic
        sysread $socket, my $buf, 1;
        $conn->add_data($buf);
    }
}
