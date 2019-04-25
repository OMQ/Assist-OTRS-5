# --
# Kernel/Modules/OmqAssistAdministration.pm - Module to display OMQ admin UI.
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

package Kernel::Modules::OmqAssistAdministration;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::User',
    'Kernel::System::OMQ::Assist::Util'
);

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{UserID} = $Param{UserID};

    return $Self;
}

sub Run {
    my ($Self) = @_;

    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $OmqUtil      = $Kernel::OM->Get('Kernel::System::OMQ::Assist::Util');

    my $Output = '';

    return $Output if !$Self->{UserID};

    #get user data
    my %User = $UserObject->GetUserData(
        UserID => $Self->{UserID}
    );

    # render default otrs page
    # header and navigation
    $Output .= $LayoutObject->Header();
    $Output .= $LayoutObject->NavigationBar();

    my $BaseUrl = $OmqUtil->GetBaseUrl();

    # add OmqAssistAdministration template
    $Output .= $LayoutObject->Output(
        TemplateFile => 'OmqAssistAdministration',
        Data         => {
            UserApiKey => $User{OmqApiKey},
            BaseUrl    => $BaseUrl
        },
    );

    # render footer
    $Output .= $LayoutObject->Footer();
    return $Output;
}
1;
