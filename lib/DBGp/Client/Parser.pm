package DBGp::Client::Parser;

use strict;
use warnings;

use XML::Parser;
use XML::Parser::EasyTree;

use DBGp::Client::Response::Init;
use DBGp::Client::Response::Error;
use DBGp::Client::Response::Step;
use DBGp::Client::Response::StackGet;
use DBGp::Client::Response::Eval;
use DBGp::Client::Response::Typemap;
use DBGp::Client::Response::ContextNames;
use DBGp::Client::Response::ContextGet;
use DBGp::Client::Response::BreakpointSet;
use DBGp::Client::Response::BreakpointRemove;
use DBGp::Client::Response::BreakpointList;
use DBGp::Client::Response::FeatureSet;

my $parser = XML::Parser->new(Style => 'XML::Parser::EasyTree');

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

        if ($cmd eq 'step_into' || $cmd eq 'step_over' || $cmd eq 'run' ||
                $cmd eq 'step_out' || $cmd eq 'detach' || $cmd eq 'stop') {
            return bless $root, 'DBGp::Client::Response::Step';
        } elsif ($cmd eq 'stack_get') {
            return bless $root, 'DBGp::Client::Response::StackGet';
        } elsif ($cmd eq 'eval') {
            return bless $root, 'DBGp::Client::Response::Eval';
        } elsif ($cmd eq 'typemap_get') {
            return bless $root, 'DBGp::Client::Response::Typemap';
        } elsif ($cmd eq 'context_names') {
            return bless $root, 'DBGp::Client::Response::ContextNames';
        } elsif ($cmd eq 'context_get') {
            return bless $root, 'DBGp::Client::Response::ContextGet';
        } elsif ($cmd eq 'breakpoint_set') {
            return bless $root, 'DBGp::Client::Response::BreakpointSet';
        } elsif ($cmd eq 'breakpoint_remove') {
            return bless $root, 'DBGp::Client::Response::BreakpointRemove';
        } elsif ($cmd eq 'breakpoint_list') {
            return bless $root, 'DBGp::Client::Response::BreakpointList';
        } elsif ($cmd eq 'feature_set') {
            return bless $root, 'DBGp::Client::Response::FeatureSet';
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
