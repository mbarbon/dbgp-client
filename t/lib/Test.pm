package t::lib::Test;

use strict;
use warnings;
use parent 'Test::Builder::Module';

use Test::More;
use Test::DBGp;

our @EXPORT = (
    @Test::More::EXPORT,
    @Test::DBGp::EXPORT,
    qw(
        dbgp_response_cmp
    )
);

sub import {
    unshift @INC, 't/lib';

    strict->import;
    warnings->import;

    goto &Test::Builder::Module::import;
}

1;
