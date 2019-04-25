# --
# Kernel/System/OMQ/Assist/Tasks/UserSynchronization.pm - Daemon Cron Task to synchronize users with OMQ Backend
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

package Kernel::System::OMQ::Assist::Tasks::UserSynchronization;

use strict;
use warnings;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Queue',
    'Kernel::System::Group',
    'Kernel::System::User',
    'Kernel::System::OMQ::Assist::Util',
    'Kernel::System::OMQ::Assist::Backend'
);

=head1 NAME

Kernel::System::OMQ::Assist::Tasks::UserSynchronization - Daemon Cron Task to synchronize users with OMQ Backend

=head1 SYNOPSIS

Called every 5 minutes by Daemon

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

=item Install()

Run Task, sync send users to OMQ backend

=cut

sub Run {
    my ($Self) = @_;

    my $UserObject = $Kernel::OM->Get('Kernel::System::User');
    my $OmqUtil    = $Kernel::OM->Get('Kernel::System::OMQ::Assist::Util');
    my $OmqBackend = $Kernel::OM->Get('Kernel::System::OMQ::Assist::Backend');

    my $Categories;
    my %CategoriesHash = ();

    my %Users;
    my @JsonUsers = ();
    my $OmqUsers;

    $OmqUtil->Log(
        Priority => 'notice',
        Message  => "OMQ assist synchronize users.\n"
    );

    $Categories = $OmqBackend->SendRequest(
        URL  => '/api/categories',
        Type => 'GET'
    );

    return if ( !$Categories || $Categories eq '' );

    # store ids in hash with externald id as key
    # used for later lookup
    CATEGORY:
    for my $Category ( @{$Categories} ) {
        next CATEGORY if !$Category->{externalId};

        my $ExtId = $Category->{externalId};
        $CategoriesHash{$ExtId} = {
            id => $Category->{id}
        };
    }

    # get user list
    %Users = $UserObject->UserList( Type => 'Long' );

    # iterate through users
    # and create json object for each user
    KEY:
    for my $Key ( sort keys %Users ) {
        next KEY if !$Key;

        my $JsonUser = $Self->_GetJsonForUser(
            UserID     => $Key,
            Categories => \%CategoriesHash
        );

        push( @JsonUsers, $JsonUser ) if $JsonUser;
    }

    if ( !@JsonUsers ) {
        return;
    }

    $OmqUsers = $OmqBackend->SendRequest(
        URL  => '/api/users/external/sync?source=OTRS',
        Type => 'POST',
        Body => \@JsonUsers
    );

    # iterate users and store api keys
    for my $ExternalUser ( @{$OmqUsers} ) {

        # if id and apikey exists
        if ( $ExternalUser->{id} && $ExternalUser->{apiKey} ) {

            # set ApiKey to user preferences
            $UserObject->SetPreferences(
                UserID => $ExternalUser->{id},
                Key    => 'OmqApiKey',
                Value  => $ExternalUser->{apiKey}
            );
        }
        else {
            $OmqUtil->Log(
                Priority => 'warn',
                Message  => 'Sync result is invalid. UserId: '
                    . $ExternalUser->{id}
                    . ' UserApiKey: '
                    . $ExternalUser->{apiKey}
            );
        }
    }

    $OmqUtil->Log(
        Priority => 'notice',
        Message  => "OMQ assist users synchronized.\n"
    );

    return $Self;
}

=item _GetJsonForUser()

Generate json for user.

=cut

sub _GetJsonForUser {
    my ( $Self, %Param ) = @_;

    my $UserObject  = $Kernel::OM->Get('Kernel::System::User');
    my $GroupObject = $Kernel::OM->Get('Kernel::System::Group');
    my $QueueObject = $Kernel::OM->Get('Kernel::System::Queue');
    my $OmqUtil     = $Kernel::OM->Get('Kernel::System::OMQ::Assist::Util');

    my $Role           = 'AGENT';
    my $UserID         = $Param{UserID};
    my @UserCategories = ();

    my %CategoriesHash = %{ $Param{Categories} };
    my %Queues;

    return if ( !$UserID );

    my %User = $UserObject->GetUserData(
        UserID => $UserID
    );

    return if !%User;

    # Get Groups of user
    my @Groups = $GroupObject->GroupMemberList(
        UserID => $UserID,
        Type   => 'rw',
        Result => 'Name'
    );

    return if !@Groups;

    my %GroupsHash;
    @GroupsHash{@Groups} = ();

    if ( exists $GroupsHash{'omq-editors'} ) {
        $Role = 'EDITOR';
    }

    if ( exists $GroupsHash{'omq-admin'} ) {
        $Role = 'ADMIN';
    }

    my $UserFullname = $User{UserFirstname} . ' ' . $User{UserLastname};

    # add queues only if user is editor
    if ( $Role eq 'EDITOR' ) {

        # get categories for current user
        %Queues = $QueueObject->GetAllQueues( UserID => $User{'UserID'} );
        for my $Queue ( sort keys %Queues ) {
            push( @UserCategories, $CategoriesHash{$Queue} );
        }
    }

    # if role is agent, check if user group enabled settings is set
    # per default, send all otrs users to backend as agent, that are not assigned to one of the
    # omq groups. if 'UserGroupEnabled' is set, only send users that are assigned to any omq group.
    if ( $Role eq 'AGENT' ) {
        return if !$OmqUtil->CheckAssistUserPermission( UserID => $User{'UserID'} );
    }

    # generate JSON
    return {
        id             => int($UserID),
        name           => $UserFullname,
        role           => $Role,
        isApiKeyActive => \1,
        categories     => \@UserCategories
    };
}

1;

=back
