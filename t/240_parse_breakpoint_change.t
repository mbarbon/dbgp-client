#!/usr/bin/perl

use t::lib::Test;

dbgp_response_cmp(<<'EOT'
<?xml version="1.0" encoding="UTF-8" ?>
<response xmlns="urn:debugger_protocol_v1" xmlns:xdebug="http://xdebug.org/dbgp/xdebug" command="breakpoint_set"
                                    state="enabled" id="1" transaction_id="2" />
EOT
    , {
        transaction_id  => '2',
        command         => 'breakpoint_set',
        is_error        => '0',
        state           => 'enabled',
        id              => '1',
    },
);

dbgp_response_cmp(<<'EOT'
<?xml version="1.0" encoding="UTF-8" ?>
<response xmlns="urn:debugger_protocol_v1" xmlns:xdebug="http://xdebug.org/dbgp/xdebug" command="breakpoint_remove"
                                         transaction_id="4" />
EOT
    , {
        transaction_id  => '4',
        command         => 'breakpoint_remove',
        is_error        => '0',
    },
);

done_testing();
