package DBGp::Client::Response::InternalError;

use strict;
use warnings;

sub is_error { '1' }
sub is_internal_error { '1' }

sub transaction_id { $_[0]->{transaction_id} }
sub command { $_[0]->{command} }

sub code { $_[0]->{code} }
sub apperr { $_[0]->{apperr} }

sub message { $_[0]->{message} }

1;
