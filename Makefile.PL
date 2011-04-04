use inc::Module::Install;
name 'Iterator-Grouped';
all_from 'lib/Iterator/GroupedRange.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
