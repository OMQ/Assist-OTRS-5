# --
# Kernel/System/OMQ/Assist/Util.pm - Helper functions for omq assist
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

package Kernel::System::OMQ::Assist::Util;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
    'Kernel::System::Group'
);

=head1 NAME

Kernel::System::OMQ::Assist::Util - Helper functions for OMQ.

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

    $Self->{LogIsEnabled} = $Kernel::OM->Get('Kernel::Config')->Get('OMQ::Plug-in::Settings::EnableDebugLog');

    return $Self;
}

sub GetBaseUrl {
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $Url          = $ConfigObject->Get('OMQ::Assist::Settings::URL');

    if ( $Url !~ "http://|https://" ) {
        $Url = "https://$Url.omq.de";
    }

    return $Url;
}

sub CheckAssistUserPermission {
    my ( $Self, %Param ) = @_;

    my $UserID = $Param{UserID};
    return 0 if !$UserID;

    my $ConfigObject     = $Kernel::OM->Get('Kernel::Config');
    my $GroupObject      = $Kernel::OM->Get('Kernel::System::Group');
    my $UserGroupEnabled = $ConfigObject->Get('OMQ::Assist::Settings::UserGroupEnabled');

    # if restriction is not enabled, return true
    return 1 if ( !$UserGroupEnabled );

    # get groups of user
    my %Groups = $GroupObject->PermissionUserGet(
        UserID => $UserID,
        Type   => 'ro',
    );

    # if group settings is enabled and user is not in
    # omq-agents group, return false
    return !!( grep {/omq-agents/} values %Groups );
}

sub Log {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    if ( $Param{Priority} eq 'notice' && !$Self->{LogIsEnabled} ) {
        return;
    }

    $LogObject->Log(
        Priority => $Param{Priority},
        Message  => $Param{Message}
    );
}

1;

=back
