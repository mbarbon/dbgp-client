#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;

use_ok('DBGp::Client::Parser');
use_ok('DBGp::Client::Stream');
use_ok('DBGp::Client::Connection');
use_ok('DBGp::Client::Listener');
