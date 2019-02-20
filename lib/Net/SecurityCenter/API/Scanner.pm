package Net::SecurityCenter::API::Scanner;

use warnings;
use strict;

use Carp;

use parent 'Net::SecurityCenter::API';

use Net::SecurityCenter::Utils qw(:all);

our $VERSION = '0.100_10';

my $common_template = {

    id => {
        required => 1,
        allow    => qr/^\d+$/,
        messages => {
            required => 'Scanner ID is required',
            allow    => 'Invalid Scanner ID',
        },
    },

    filter => {
        allow => [ 'usable', 'manageable' ],
    },

    fields => {
        filter => \&filter_array_to_string,
    }

};

#-------------------------------------------------------------------------------
# METHODS
#-------------------------------------------------------------------------------

sub list {

    my ( $self, %args ) = @_;

    my $tmpl = {
        fields => $common_template->{'fields'},
        filter => $common_template->{'filter'},
    };

    my $params = check( $tmpl, \%args );
    return $self->rest->get( '/scanner', $params );

}

#-------------------------------------------------------------------------------

sub get {

    my ( $self, %args ) = @_;

    my $tmpl = {
        fields => $common_template->{'fields'},
        id     => $common_template->{'id'},
    };

    my $params     = check( $tmpl, \%args );
    my $scanner_id = delete( $params->{'id'} );

    return $self->rest->get( "/scanner/$scanner_id", $params );
}

#-------------------------------------------------------------------------------

sub get_status {

    my ( $self, %args ) = @_;

    my $tmpl = { id => $common_template->{'id'}, };

    my $params     = check( $tmpl, \%args );
    my $scanner_id = delete( $params->{'id'} );

    my $scanner = $self->get( id => $scanner_id, fields => [ 'id', 'status' ] );

    return decode_nessus_scanner_status( $scanner->{'status'} );

}

#-------------------------------------------------------------------------------

1;

__END__
=pod

=encoding UTF-8


=head1 NAME

Net::SecurityCenter::API::Scanner - Perl interface to Tenable.sc (SecurityCenter) Scanner REST API


=head1 SYNOPSIS

    use Net::SecurityCenter::REST;
    use Net::SecurityCenter::API::Scanner;

    my $sc = Net::SecurityCenter::REST->new('sc.example.org');

    $sc->login('secman', 'password');

    my $api = Net::SecurityCenter::API::Scanner->new($sc);

    $sc->logout();


=head1 DESCRIPTION

This module provides Perl scripts easy way to interface the Scanner REST API of Tenable.sc
(SecurityCenter).

For more information about the Tenable.sc (SecurityCenter) REST API follow the online documentation:

L<https://docs.tenable.com/sccv/api/index.html>


=head1 FUNCTIONS

=head2 decode_nessus_scanner_status ( $status_int )

Decode Nessus scanner status.

    print decode_scanner_status(16384); #  Scanner disabled by user


=head1 CONSTRUCTOR

=head2 Net::SecurityCenter::API::Scanner->new ( $rest )

Create a new instance of B<Net::SecurityCenter::API::Scanner> using L<Net::Security::Center::REST> class.


=head1 METHODS

=head2 list

Get the scanner list.

=head2 get

Get the scanner associated with C<id>.

=head2 get_status

Get the decoded scanner status associated with C<scanner_id>.


=head1 SUPPORT

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at L<https://github.com/LotarProject/perl-Net-SecurityCenter/issues>.
You will be notified automatically of any progress on your issue.

=head2 Source Code

This is open source software.  The code repository is available for
public review and contribution under the terms of the license.

L<https://github.com/LotarProject/perl-Net-SecurityCenter>

    git clone https://github.com/LotarProject/perl-Net-SecurityCenter.git


=head1 AUTHOR

=over 4

=item * Giuseppe Di Terlizzi <gdt@cpan.org>

=back


=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2018-2019 by Giuseppe Di Terlizzi.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
