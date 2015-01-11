use Test::Most;

use lib 't/lib';

use_ok 'Foo';

subtest 'oo' => sub {
  my $f = Foo->new;
  is $f->bar, 1;
  is $f->baz, 2;
  is $f->bar(3), 3;
  is $f->baz, 4;
  is_deeply [ $f->boop ], [ 3, 4 ];
};

subtest 'non-oo' => sub {
  is bar(), 5;
  is baz(), 6;
  is bar(3), 3;
  is baz(), 4;
  is_deeply [ boop() ], [ 3, 4 ];
};

done_testing;


