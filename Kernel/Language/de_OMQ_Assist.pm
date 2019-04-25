# --
# Copyright (C) 2010-2017 OMQ GmbH, http://www.omq.de
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
package Kernel::Language::de_OMQ_Assist;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    # Kernel/Config/Files/OmqAssistDaemonCronTask.xml
    $Self->{Translation}->{'Synchronize queues with the OMQ Backend.'} = 'Synchronisiert Queues mit dem OMQ Backend.';
    $Self->{Translation}->{'Synchronize users with the OMQ Backend.'} = 'Synchronisiert Benutzer mit dem OMQ Backend.';

    # Kernel/Config/Files/OmqAssistModules.xml
    $Self->{Translation}->{'Frontend module for OMQ administration.'} = 'Frontend Modul für die OMQ Administration.';
    $Self->{Translation}->{'Frontend module for the OMQ session store.'} = 'Frontend Module für den OMQ session store.';

    # Kernel/Config/Files/OmqAssistOutputFilter.xml
    $Self->{Translation}->{'Output filter adds OMQ assist to ticket zoom.'} = 'Fügt OMQ assist zur Ticket Zoom Sicht hinzu.';
    $Self->{Translation}->{'Output filter adds OMQ assist to phone ticket view.'} = 'Fügt OMQ assist zur Telefon Ticket Sicht hinzu.';
    $Self->{Translation}->{'Output filter adds OMQ assist to email ticket view.'} = 'Fügt OMQ assist zur Email Ticket Sicht hinzu.';
    $Self->{Translation}->{'Output filter adds selected answers to answer editor.'} = 'Fügt die ausgewählten Antworten zum Antworteditor hinzu.';

    # Kernel/Config/Files/OmqAssistSettings.xml
    $Self->{Translation}->{'Url of the OMQ account.'} = 'Url des OMQ Kontos.';
    $Self->{Translation}->{'Apikey of OMQ account.'} = 'Apikey des OMQ Kontos.';

    $Self->{Translation}->{'Use groups for OMQ assist. OMQ assist will only be displayed to users of the "omq-agents" group.'} = 'Aktiviert Gruppen Beschränkung für das OMQ plug-in. Das OMQ plug-in wird nur Benutzern der Gruppe "omq-agents" angezeigt.';
    $Self->{Translation}->{'Maximum number of questions to display.'} = 'Maximale Anzahl an Fragen die angezeigt werden sollen.';
    $Self->{Translation}->{'Insert HTML answers as plain text into response emails.'} = 'Fügt HTML Antworten als reinen Text in die Antwort Email.';
    $Self->{Translation}->{'Insert HTML answers without style into response emails.'} = 'Fügt HTML Antworten ohne Stil in die Antwort Email.';

    $Self->{Translation}->{'Url of proxy server.'} = 'Url des Proxy Servers.';
    $Self->{Translation}->{'Username of proxy user.'} = 'Benutzername für den Proxy Zugang.';
    $Self->{Translation}->{'Password for proxy user.'} = 'Passwort für den Proxy Zugang.';

    # Kernel/Config/Files/OmqAssistUserPreferences.xml
    $Self->{Translation}->{'User Apikey for OMQ Backend.'} = 'Benutzer Apikey für das OMQ Backend';


    return 1;
}
1;
