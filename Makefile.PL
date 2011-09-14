use inc::Module::Install;

name 'Iterator-GroupedRange';
all_from 'lib/Iterator/GroupedRange.pm';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';

auto_set_repository;
auto_include;
WriteAll;
