#!/usr/bin/perl

use t::lib::Test;

dbgp_response_cmp(<<'EOT'
<?xml version="1.0" encoding="UTF-8" ?>
<response xmlns="urn:debugger_protocol_v1" xmlns:xdebug="http://xdebug.org/dbgp/xdebug" command="feature_set" feature_name="max_depth"
                                    success="1" transaction_id="2" />
EOT
    , {
        transaction_id  => '2',
        command         => 'feature_set',
        is_error        => '0',
        feature         => 'max_depth',
        success         => '1',
    },
);

done_testing();
