package Net::SecurityCenter::API::Policy;

use warnings;
use strict;

use Carp;
use English qw( -no_match_vars );

use parent 'Net::SecurityCenter::API';

use Net::SecurityCenter::Utils qw(:all);

our $VERSION = '0.205';

my $common_template = {

    id => {
        required => 1,
        allow    => qr/^\d+$/,
        messages => {
            required => 'Policy ID is required',
            allow    => 'Invalid Policy ID',
        },
    },

    filter => {
        allow => [ 'usable', 'manageable' ],
    },

    fields => {
        filter => \&sc_filter_array_to_string,
    },

};

#-------------------------------------------------------------------------------
# METHODS
#-------------------------------------------------------------------------------

sub list {

    my ( $self, %args ) = @_;

    my $tmpl = {
        fields => $common_template->{'fields'},
        filter => $common_template->{'filter'},
        raw    => {}
    };

    my $params   = sc_check_params( $tmpl, \%args );
    my $raw      = delete( $params->{'raw'} );
    my $policies = $self->client->get( '/policy', $params );

    return if ( !$policies );
    return $policies if ($raw);
    return sc_merge($policies);

}

#-------------------------------------------------------------------------------

sub get {

    my ( $self, %args ) = @_;

    my $tmpl = {
        fields => $common_template->{'fields'},
        id     => $common_template->{'id'},
    };

    my $params    = sc_check_params( $tmpl, \%args );
    my $policy_id = delete( $params->{'id'} );
    my $raw       = delete( $params->{'raw'} );
    my $policy    = $self->client->get( "/policy/$policy_id", $params );

    return if ( !$policy );
    return $policy if ($raw);
    return sc_normalize_hash($policy);

}

#-------------------------------------------------------------------------------

sub download {

    my ( $self, %args ) = @_;

    my $tmpl = {
        filename => {},
        id       => $common_template->{'id'},
    };

    my $params = sc_check_params( $tmpl, \%args );

    my $policy_id = delete( $params->{'id'} );
    my $filename  = delete( $params->{'filename'} );

    my $policy_data = $self->client->post("/policy/$policy_id/export");

    return $policy_data if ( !$filename );

    open my $fh, '>', $filename
        or croak("Could not open file '$filename': $OS_ERROR");

    print $fh $policy_data;

    close $fh
        or carp("Failed to close file '$filename': $OS_ERROR");

    return 1;

}

#-------------------------------------------------------------------------------

1;

__END__
=pod

=encoding UTF-8


=head1 NAME

Net::SecurityCenter::API::Policy - Perl interface to Tenable.sc (SecurityCenter) Policy REST API


=head1 SYNOPSIS

    use Net::SecurityCenter::REST;
    use Net::SecurityCenter::API::Policy;

    my $sc = Net::SecurityCenter::REST->new('sc.example.org');

    $sc->login('secman', 'password');

    my $api = Net::SecurityCenter::API::Policy->new($sc);

    $sc->logout();


=head1 DESCRIPTION

This module provides Perl scripts easy way to interface the Policy REST API of Tenable.sc
(SecurityCenter).

For more information about the Tenable.sc (SecurityCenter) REST API follow the online documentation:

L<https://docs.tenable.com/sccv/api/index.html>


=head1 CONSTRUCTOR

=head2 Net::SecurityCenter::API::Policy->new ( $client )

Create a new instance of B<Net::SecurityCenter::API::Policy> using L<Net::SecurityCenter::REST> class.


=head1 METHODS

=head2 list

Get list of policies.

Params:

=over 4

=item * C<fields>: Fields array or comma-separated-value string

=item * C<filter>: Filter for:

=over 4

=item * C<manageable>

=item * C<usable>

=back

=item * C<raw>: Return RAW Tenable.sc output without sc_merge C<usable> and C<manageable> array

=back

=head2 get

Gets the policy associated with C<id> param.

Params:

=over 4

=item * C<id>: Policy ID

=back

=head2 download

Download the policy XML associated with C<id> param.

Params:

=over 4

=item * C<id>: Policy ID

=item * C<filename>: Path of file (optional)

=back


=head1 SUPPORT

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at L<https://github.com/giterlizzi/perl-Net-SecurityCenter/issues>.
You will be notified automatically of any progress on your issue.

=head2 Source Code

This is open source software.  The code repository is available for
public review and contribution under the terms of the license.

L<https://github.com/giterlizzi/perl-Net-SecurityCenter>

    git clone https://github.com/giterlizzi/perl-Net-SecurityCenter.git


=head1 AUTHOR

=over 4

=item * Giuseppe Di Terlizzi <gdt@cpan.org>

=back


=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2018-2019 by Giuseppe Di Terlizzi.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
