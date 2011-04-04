use inc::Module::Install;
name 'Iterator-Grouped';
all_from 'lib/Iterator/Grouped.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
