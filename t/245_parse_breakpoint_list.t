#!/usr/bin/perl

use t::lib::Test;

dbgp_response_cmp(<<'EOT'
<?xml version="1.0" encoding="UTF-8" ?>
<response xmlns="urn:debugger_protocol_v1" xmlns:xdebug="http://xdebug.org/dbgp/xdebug" command="breakpoint_list"
                                        transaction_id="5" ><breakpoint
                             id="1"
                             type="line" filename="file:///home/bill/dev/dbgp/plack-middleware-dbgp/t/apps/lib/App/Base.pm" line="13" lineno="13" state="enabled" temporary="0" hit_count ="1" hit_value ="0"><expression>require Data::Dumper; print Data::Dumper::Dumper($env); 0</expression></breakpoint>

</response>
EOT
    , {
        transaction_id  => '5',
        command         => 'breakpoint_list',
        is_error        => '0',
        breakpoints     => [
            {
                type          => 'line',
                filename      => 'file:///home/bill/dev/dbgp/plack-middleware-dbgp/t/apps/lib/App/Base.pm',
                lineno        => '13',
                state         => 'enabled',
                function      => undef,
                hit_count     => '1',
                hit_value     => '0',
                hit_condition => undef,
                exception     => undef,
                expression    => 'require Data::Dumper; print Data::Dumper::Dumper($env); 0',
            },
        ],
    },
);

done_testing();
