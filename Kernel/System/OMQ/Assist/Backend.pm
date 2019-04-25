# --
# Kernel/System/OMQ/Assist/Backend.pm - Module for OMQ assist to connect to OMQ Backend
# Copyright (C) 2001-2017 OTRS AG, http://otrs.com/
# Extensions Copyright © 2010-2017 OMQ GmbH, http://www.omq.de
#
# written/edited by:
# * info(at)omq(dot)de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::OMQ::Assist::Backend;

use strict;
use warnings;

use MIME::Base64;
use LWP::UserAgent;
use JSON;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::OMQ::Assist::Util'
);

=head1 NAME

Kernel::System::OMQ::Assist::Backend - Module for OMQ Backend.

=head1 SYNOPSIS

Contains some util functions

=cut

=over

=item new()

Constructor

=cut

sub new {
    my ($Type) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=item SendRequest()

Send request to OMQ Backend

=cut

sub SendRequest {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $ApiKey       = $ConfigObject->Get('OMQ::Assist::Settings::Apikey');
    my $OmqUtil      = $Kernel::OM->Get('Kernel::System::OMQ::Assist::Util');

    my $Proxy         = $ConfigObject->Get('WebUserAgent::Proxy');
    my $SkipSSLVerify = $ConfigObject->Get('WebUserAgent::DisableSSLVerification');
    my $TimeOut       = $ConfigObject->Get('WebUserAgent::Timeout') || 30;

    my $Url = $OmqUtil->GetBaseUrl() . $Param{URL};
    my $UserAgent;
    my $Request;

    if ( !$ApiKey || $ApiKey eq '' ) {
        return;
    }

    $UserAgent = LWP::UserAgent->new();

    my %RequestHeader = (
        'Accept'               => 'application/json',
        'X-Omq-Assist-Api-Key' => $ApiKey,
        'Content-Type'         => 'application/json'
    );

    if ( $Param{Header} ) {
        %RequestHeader = ( %RequestHeader, %{ $Param{Header} } );
    }

    if ($Proxy) {
        $UserAgent->proxy( [ 'http', 'https' ], $Proxy );
    }

    if ($SkipSSLVerify) {
        $UserAgent->ssl_opts(
            verify_hostname => 0,
        );
    }

    $UserAgent->timeout($TimeOut);

    # load categories
    $Request = HTTP::Request->new( $Param{Type} => $Url );

    # set request header
    $Request->header(%RequestHeader);

    if ( $Param{Body} ) {
        $Request->content( JSON->new()->utf8()->encode( $Param{Body} ) );
    }

    # send request
    my $Response = $UserAgent->request($Request);

    # do nothing if open tickets couldn't be loaded
    if ( !$Response->is_success() ) {
        my $ErrorMessage = "Could not send request to OMQ Backend.\n";
        $ErrorMessage .= "HTTP ERROR Url: " . $Url . "\n";
        $ErrorMessage .= "HTTP ERROR Code: " . $Response->code() . "\n";
        $ErrorMessage .= "HTTP ERROR Message: " . $Response->message() . "\n";

        if ( $Response->decoded_content() ) {
            $ErrorMessage .= "HTTP ERROR Content: " . $Response->decoded_content() . "\n";
        }

        $OmqUtil->Log(
            Priority => 'error',
            Message  => $ErrorMessage
        );

        return;
    }

    # return if content won't be able to get parsed
    my $Content = $Response->decoded_content();
    if ( !$Content || $Content eq '' ) {
        return $Content;
    }

    # if result is html, no need for json decoding
    if ( $Response->header('Content-Type') =~ /text\/html/ ) {
        return $Content;
    }

    # decode response
    return JSON->new()->utf8()->decode($Content);
}

1;

=back
