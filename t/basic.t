use strict;
use warnings;
use utf8;

use autodie 'system';
use autobox::Core;

use Test::More;
use Test::TempDir 'scratch';
use Test::DZil;
use Directory::Scratch;
use File::chdir;
use File::Which 'which';
use IPC::System::Simple (); # explicit dep for autodie system
use Path::Class;
use Path::Tiny;

use lib 't/lib';

plan skip_all => 'git not found'
    unless which 'git';

$ENV{GIT_AUTHOR_EMAIL}    = 'Test Ing <test@test.ing>';
$ENV{GIT_COMMITTER_EMAIL} = 'Test Ing <test@test.ing>';

my $ds        = scratch;
my $dist_root = $ds->base;

my @AUTHORS = (
    'Some One <one@some.org>',
    'Another One <two@some.org>',
    'James "宮川達彦" Salmoń <woo@bip.com>',
    'E. Xavier Ample <example@EXAMPLE.ORG>'
);

{
    local $CWD = "$dist_root";
    system 'git init';
    path('foo')->touch;
    system 'git add foo';
    system qq{git commit --author "$AUTHORS[0]" -m "one"};
    path('bar')->touch;
    system 'git add bar';
    system qq{git commit --author "$AUTHORS[1]" -m "two"};
    path('baz')->touch;
    system 'git add baz';
    system qq{git commit --author "$AUTHORS[2]" -m "three"};
    path('biff')->touch;
    system 'git add biff';
    system qq{git commit --author "$AUTHORS[3]" -m "four"};
    path('aack')->touch;
    system 'git add aack';
    system 'git commit --author "Your Name <you@example.com>" -m "two"';
}

my $STASH_NAME = '%PodWeaver';
my @dist_ini   = qw(ContributorsFromGit FakeRelease);

my $tzil = Builder->from_config(
    { dist_root => "$dist_root" },
    {
        add_files => {
            'source/dist.ini' => simple_ini(@dist_ini),
        },
    },
);

isa_ok $tzil, 'Dist::Zilla::Dist::Builder';
ok $tzil->plugin_named('ContributorsFromGit'), 'tzil has our test plugin';

ok !$tzil->stash_named($STASH_NAME), 'tzil does not yet have the stash';
$tzil->release;

is_deeply
    [ sort @{$tzil->distmeta->{x_contributors}} ],
    [ sort @AUTHORS[0..2] ],
    "x_contributors metadata"
    ;

my $stash = $tzil->stash_named($STASH_NAME);
isa_ok $stash, 'Dist::Zilla::Stash::PodWeaver';

my $cleanup_ok = is_deeply
    [
        sort
        map  { $stash->_config->{$_}                }
        grep { /^Contributors\.contributors\[\d+\]/ }
        $stash->_config->keys->flatten
    ],
    [ sort @AUTHORS[0..2] ],
    'contributors and git authors match up',
    ;

$ds->cleanup if $cleanup_ok;

done_testing;
