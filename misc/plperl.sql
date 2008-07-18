set search_path to _global;

create or replace function openresty_init () returns boolean as $$
    use OpenResty::Dispatcher;
    use JSON::Syck;
    use OpenResty::Util;
    OpenResty::Dispatcher->init('plperl');
    return true;
$$ language plperlu;

create type openresty_res_type as (content_type text, content text);
drop function if exists openresty_request(text,text,text,text);

create or replace function openresty_request (text, text, text, text) returns
        text as $$
    my ($meth, $url, $content, $raw_cookie) = @_;
    local %ENV;
    $ENV{HTTP_COOKIE} = $raw_cookie;
    $ENV{REQUEST_URI} = $url;
    $ENV{REQUEST_METHOD} = $meth;
    my $cgi = OpenResty::Util::new_mocked_cgi($url, $content);
    my $res = OpenResty::Dispatcher->process_request($cgi, 1);
    # return_next($res);
    return JSON::Syck::Dump($res);
$$ language plperlu;

select openresty_init();
select openresty_request('GET', '/=/view/PrevNextPost/current/5?user=agentzh.Public', '', '');

