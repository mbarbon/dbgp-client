#!/usr/bin/perl

use t::lib::Test;

# standard response
dbgp_response_cmp(<<'EOT'
<?xml version="1.0" encoding="UTF-8" ?>
<response xmlns="urn:debugger_protocol_v1" xmlns:xdebug="http://xdebug.org/dbgp/xdebug" command="run" status="stopped"
                               reason="ok" transaction_id="3" />
EOT
    , {
        transaction_id  => '3',
        command         => 'run',
        is_error        => '0',
        reason          => 'ok',
        status          => 'stopped',
        filename        => undef,
        lineno          => undef,
    },
);

# Xdebug response
dbgp_response_cmp(<<'EOT'
<?xml version="1.0" encoding="UTF-8" ?>
<response xmlns="urn:debugger_protocol_v1" xmlns:xdebug="http://xdebug.org/dbgp/xdebug" command="run" status="stopped"
                               reason="ok" transaction_id="3" ><xdebug:message filename="file:///home/bill/dev/dbgp/plack-middleware-dbgp/t/apps/lib/App/Base.pm" lineno="13" /></response>
EOT
    , {
        transaction_id  => '3',
        command         => 'run',
        is_error        => '0',
        reason          => 'ok',
        status          => 'stopped',
        filename        => 'file:///home/bill/dev/dbgp/plack-middleware-dbgp/t/apps/lib/App/Base.pm',
        lineno          => '13',
    },
);

done_testing();
