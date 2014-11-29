use inc::Module::Install;

# Define metadata
name            'WebService-Graphite';
all_from        'lib/WebService/Graphite';
license         'perl';

# uses Module::Install::Repository
auto_set_repository;

# Specific dependencies
requires 'Module::Runtime'      => 0;
requires 'Moo'                  => 0;
requires 'MooX::ObjectBuilder'  => 0;

#test_requires


WriteAll;
