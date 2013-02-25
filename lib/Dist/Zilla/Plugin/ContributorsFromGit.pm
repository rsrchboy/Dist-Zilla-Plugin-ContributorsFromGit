package Dist::Zilla::Plugin::ContributorsFromGit;

# ABSTRACT: Populate your 'CONTRIBUTORS' POD from the list of git authors

use Moose;
use namespace::autoclean;
use autobox::Core;
use File::Which 'which';
use List::AllUtils qw{ apply max uniq };
use Syntax::Keyword::Junction 'none';

use autodie 'system';
use IPC::System::Simple ( ); # explict dep for autodie system

use aliased 'Dist::Zilla::Stash::PodWeaver';

has contributor_list => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
);

with
    'Dist::Zilla::Role::BeforeBuild',
    'Dist::Zilla::Role::RegisterStash',
    'Dist::Zilla::Role::MetaProvider',
    ;

# debugging...
#use Smart::Comments '###';

sub before_build {
    my $self = shift @_;

    # skip if we can't find git
    unless (which 'git') {
        $self->log('The "git" executable has not been found');
        return;
    }

    # XXX we should also check here that we're in a git repo, but I'm going to
    # leave that for the git stash (when it's not vaporware)

    ### get our stash, config...
    my $stash   = $self->zilla->stash_named('%PodWeaver');
    do { $stash = PodWeaver->new; $self->_register_stash('%PodWeaver', $stash) }
        unless defined $stash;
    my $config  = $stash->_config;
    my @authors = $self->zilla->authors->flatten;

    ### and get our list from git, filtering: "@authors"
    my @contributors = uniq sort
        grep  { $_ ne 'Your Name <you@example.com>' }
        grep  { none(@authors) eq $_                }
        apply { chomp                               }
        `git log --format="%aN <%aE>"`
        ;

    $self->contributor_list(\@contributors);

    my $i = 0;
    do { $config->{"Contributors.contributors[$i]"} = $_; $i++ }
        for @contributors;

    return;
}

sub metadata {
    my $self = shift @_;
    return { 'x_contributors' => $self->contributor_list };
}

__PACKAGE__->meta->make_immutable;
!!42;
__END__

=for :stopwords zilla BeforeBuild

=for Pod::Coverage before_build

=head1 SYNOPSIS

    ; in your dist.ini
    [ContributorsFromGit]

    ; in your weaver.ini
    [Contributors]

=head1 DESCRIPTION

This plugin makes it easy to acknowledge the contributions of others by
populating a L<%PodWeaver|Dist::Zilla::Stash::PodWeaver> stash with the unique
list of all git commit authors reachable from the current HEAD.

=head1 OVERVIEW

On collecting the unique list of reachable commit authors from git, we search
and remove any git authors from the list of authors L<Dist::Zilla> knows
about.  We then look for a stash named C<%PodWeaver>; if we don't find one
then we create an instance of L<Dist::Zilla::Stash::PodWeaver> and register it
with our zilla instance.  Then we add the list of contributors (the filtered
git authors list) to the stash in such a way that
L<Pod::Weaver::Section::Contributors> can find them.

Note that you do not need to have the C<%PodWeaver> stash created; it will be
added if it is not found.  However, your L<Pod::Weaver> config (aka
c<weaver.ini>) must include the
L<Contributors|Pod::Weaver::Section::Contributors> section plugin.

This plugin runs during the L<BeforeBuild|Dist::Zilla::Role::BeforeBuild>
phase.

The list of contributors is also added to distribution metadata under the custom
C<x_contributors> key.

=head1 SEE ALSO

L<Pod::Weaver::Section::Contributors>

L<Dist::Zilla::Stash::PodWeaver>

=cut
