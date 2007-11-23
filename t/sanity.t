use Test::Base;

plan tests => 3 * blocks();

run {
    my $
};

__DATA__

=== TEST 1: Get model list
--- request
GET /=/model.js
--- response
[]



=== TEST 2: Create a model
--- request
POST /=/model.js
{
    name: 'Bookmark',
    description: '我的书签',
    columns: [
        { name: 'id', type: 'serial', label: 'ID' },
        { name: 'title', label: '标题' },
        { name: 'url', label: '网址' },
    ]
}
--- response
{success:'true'}

