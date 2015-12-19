package DBGp::Client::Response::PropertyValue;

use strict;
use warnings;
use parent qw(DBGp::Client::Response::Simple);

use MIME::Base64 qw(decode_base64);

__PACKAGE__->make_attrib_accessors(qw(
    transaction_id command size
));

sub value {
    my $text = DBGp::Client::Parser::_text($_[0]);
    my $encoding = $_[0]->{attrib}{encoding};

    return $encoding eq 'base64' ? decode_base64($text) : $text;
}

1;
