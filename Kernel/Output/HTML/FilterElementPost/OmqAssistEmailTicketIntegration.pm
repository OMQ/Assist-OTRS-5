# --
# Kernel/Output/HTML/FilterElementPost/OmqAssistEmailTicketIntegration.pm - Output filter for assist into Email TicketView.
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

package Kernel::Output::HTML::FilterElementPost::OmqAssistEmailTicketIntegration;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::User',
    'Kernel::System::OMQ::Assist::Util'
);

sub new {
    my ($Type) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $UserObject   = $Kernel::OM->Get('Kernel::System::User');
    my $OmqUtil      = $Kernel::OM->Get('Kernel::System::OMQ::Assist::Util');

    #
    # Very Important. This prevents that this output filter
    # gets called multiple times.
    #
    return $Param{Data} if ${ $Param{Data} } !~ m{ <div [^>]* ContentColumn [^>]* > }xmsi;

    # return it there is no user ID
    my $UserID = $LayoutObject->{UserID};
    return $Param{Data} if ( !$UserID );

    # only display assist if user is allowed
    return $Param{Data} if !$OmqUtil->CheckAssistUserPermission( UserID => $UserID );

    # init script urls
    my $BaseUrl = $OmqUtil->GetBaseUrl();

    my $ScriptUrl = $BaseUrl . '/integration/otrs5/email.min.js';

    # get user preferences
    my %Preferences = $UserObject->GetPreferences( UserID => $UserID );
    my $WidgetPositions = $Preferences{AgentTicketZoomPosition} || '';
    my $UserApikey      = $Preferences{OmqApiKey};
    my $AssistApiKey    = $ConfigObject->Get('OMQ::Assist::Settings::Apikey');

    my $HTML = '
      <script type="text/javascript">//<![CDATA[
        window.omqAssist = {
            account: "' . $BaseUrl . '",
            apiKey: "' . $AssistApiKey . '",
            userApiKey: "' . $UserApikey . '",
            widgetPositions: "' . $WidgetPositions . '"
        };

        function l() {
            var s = document.createElement("script");
            s.type = "text/javascript";
            s.async = true;
            s.src = "' . $ScriptUrl . '";
            var x = document.getElementsByTagName("script")[0];
            x.parentNode.insertBefore(s, x);
        }

        window.attachEvent ? window.attachEvent("onload", l) : window.addEventListener("load", l, false);
      //]]></script>
      ';

    # add content to page
    ${ $Param{Data} } .= $HTML;

    return $Param{Data};
}

1;
