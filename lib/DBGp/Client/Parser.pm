package DBGp::Client::Parser;

use strict;
use warnings;

use XML::Parser;
use XML::Parser::EasyTree;

use DBGp::Client::Response::Init;
use DBGp::Client::Response::Error;

my $parser = XML::Parser->new(Style => 'XML::Parser::EasyTree');

my %response_map;
BEGIN {
    %response_map = (
        'step_into'         => 'DBGp::Client::Response::Step',
        'step_over'         => 'DBGp::Client::Response::Step',
        'run'               => 'DBGp::Client::Response::Step',
        'step_out'          => 'DBGp::Client::Response::Step',
        'detach'            => 'DBGp::Client::Response::Step',
        'stop'              => 'DBGp::Client::Response::Step',
        'stack_get'         => 'DBGp::Client::Response::StackGet',
        'eval'              => 'DBGp::Client::Response::Eval',
        'typemap_get'       => 'DBGp::Client::Response::Typemap',
        'context_names'     => 'DBGp::Client::Response::ContextNames',
        'context_get'       => 'DBGp::Client::Response::ContextGet',
        'breakpoint_set'    => 'DBGp::Client::Response::BreakpointSet',
        'breakpoint_remove' => 'DBGp::Client::Response::BreakpointRemove',
        'breakpoint_list'   => 'DBGp::Client::Response::BreakpointList',
        'feature_set'       => 'DBGp::Client::Response::FeatureSet',
        'feature_get'       => 'DBGp::Client::Response::FeatureGet',
    );

    my $load = join "\n", map "require $_;", values %response_map;
    eval $load or do {
        die "$@";
    };
}

sub _nodes {
    my ($nodes, $node) = @_;

    return grep $_->{type} eq 'e' && $_->{name} eq $node, @{$nodes->{content}};
}

sub _node {
    my ($nodes, $node) = @_;

    return (_nodes($nodes, $node))[0];
}

sub _text {
    my ($nodes) = @_;
    my $text = '';

    for my $node (@{$nodes->{content}}) {
        $text .= $node->{content}
            if $node->{type} eq 't';
    }

    return $text;
}

sub parse {
    return undef unless defined $_[0];

    my $tree = $parser->parse($_[0]);
    require Data::Dumper, die "Unexpected return value from parse(): ", Data::Dumper::Dumper($tree)
        if !ref $tree || ref $tree ne 'ARRAY';
    die "Unexpected XML"
        if @$tree != 1 || $tree->[0]{type} ne 'e';

    my $root = $tree->[0];
    if ($root->{name} eq 'init') {
        return bless $root->{attrib}, 'DBGp::Client::Response::Init';
    } elsif ($root->{name} eq 'response') {
        if (ref $root->{content} && (my $error = _node($root, 'error'))) {
            return bless [$root->{attrib}, $error], 'DBGp::Client::Response::Error';
        }

        my $cmd = $root->{attrib}{command};
        if (my $package = $response_map{$cmd}) {
            return bless $root, $package;
        } else {
            require Data::Dumper;

            die "Unknown command '$cmd' " . Data::Dumper::Dumper($root);
        }
    } else {
        require Data::Dumper;

        die "Unknown response '$root' " . Data::Dumper::Dumper($root);
    }
}

1;
