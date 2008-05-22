#!perl

use Test::More;
eval { use Test::Perl::Critic (-format => " => [%p] %m at line %l, column %c. %e."); };
plan skip_all => 'Ignore this test';
all_critic_ok();