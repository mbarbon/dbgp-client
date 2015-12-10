package t::lib::Test;

use strict;
use warnings;
use parent 'Test::Builder::Module';

use Test::More;
use Test::Differences;

our @EXPORT = (
    @Test::More::EXPORT,
    @Test::Differences::EXPORT,
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

sub dbgp_response_cmp {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    require DBGp::Client::Parser;

    my ($xml, $expected) = @_;
    my $res = DBGp::Client::Parser::parse($xml);
    my $cmp = _extract_command_data($res, $expected);

    eq_or_diff($cmp, $expected);
}

sub _extract_command_data {
    my ($res, $expected) = @_;

    if (!ref $expected) {
        return $res;
    } elsif (ref $expected eq 'HASH') {
        return {
            map {
                $_ => _extract_command_data($res->$_, $expected->{$_})
            } keys %$expected
        };
    } elsif (ref $expected eq 'ARRAY') {
        return $res if ref $res ne 'ARRAY';
        return [
            ( map {
                _extract_command_data($res->[$_], $expected->[$_])
            } 0 .. $#$expected ),
            ( ("<unexpected item>") x ($#$res - $#$expected) ),
        ];
    } else {
        die "Can't extract ", ref $expected, "value";
    }
}

1;
