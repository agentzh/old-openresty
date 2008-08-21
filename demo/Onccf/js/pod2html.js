function pod2html (pod) {
    var html = pod
        .replace(/C<<(.*?)>>/g, '__start_resty_code__$1__end_resty_code__')
        .replace(/C<(.*?)>/g, '__start_resty_code__$1__end_resty_code__')
        .replace(/I<(.*?)>/g, '__start_resty_i__$1__end_resty_i__')
        .replace(/F<(.*?)>/g, '__start_resty_em__$1__end_resty_em__')
        .replace(/B<(.*?)>/g, '__start_resty_b__$1__end_resty_b__')
        .replace(/L<(.*?)>/g, '__start_resty2_a__$1__end_resty2_a__')
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/__start_resty_([A-Za-z0-9]+)__/g, '<$1>')
        .replace(/__end_resty_([A-Za-z0-9]+)__/g, '</$1>')
        .replace(/^=head(\d+)\s+([^\n]*)/g, '<h$1>$2</h$1>')
        .replace(/\n+=head(\d+)\s+([^\n]*)/g, '<h$1>$2</h$1>')
        .replace(/\n+=over([^\n]*)/g, '<ul>')
        .replace(/\n+=item\s+\*\s*/g, '</li><li>')
        .replace(/\n+=item\s+(\S+)\s*/g, '</li><li>$1')
        .replace(/\n+=back([^\n]*)/g, '</li></ul>')
        .replace(/<ul><\/li>/g, '<ul>')
        .replace(/\n+[ \t]+([^\n]+)/g, '<code>&nbsp; &nbsp; $1</code>')
        .replace(/[ \t][ \t]/g, '&nbsp; ')
        .replace(/__start_resty2_a__([^|]+?)\|([^|]*?)__end_resty2_a__/g, '<a href="$1">$2</a>')
        .replace(/__start_resty2_a__(\S+?)__end_resty2_a__/g, '<a href="$1">$1</a>')
    return html;
}

