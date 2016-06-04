package DBGp::Client::Response::Stream;

use strict;
use warnings;
use parent qw(DBGp::Client::Response::Simple);

use MIME::Base64 qw(decode_base64);

__PACKAGE__->make_attrib_accessors(qw(
    type
));

sub content {
    my $text = DBGp::Client::Parser::_text($_[0]);
    my $encoding = $_[0]->{attrib}{encoding};

    return $encoding eq 'base64' ? decode_base64($text) : $text;
}

sub is_oob { '1' }
sub is_stream { '1' }
sub is_notification { '0' }

1;
