#!/usr/bin/perl

use t::lib::Test;

use DBGp::Client::Connection;

my $LISTEN = dbgp_listen();

dbgp_run_fake();

my $socket = $LISTEN->accept;

die "Did not receive any connection from the fake debugger: ", $LISTEN->error
    unless $socket;

my $conn = DBGp::Client::Connection->new(socket => $socket);

my $init = $conn->parse_init;

is($init->language, 'Perl');

my $res1 = $conn->send_command('stack_depth');

is($res1->transaction_id, 1);

my $res2 = $conn->send_command('stack_depth');

is($res2->transaction_id, 2);

done_testing();
