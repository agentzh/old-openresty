function pod2html_escape (p) {
    return p.replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;');
}

function pod2html_escape_in_p (p) {
    return p.replace(/C<<(.*?)>>/g, '__start_resty_code__$1__end_resty_code__')
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
        .replace(/__start_resty2_a__([^|]+?)\|([^|]*?)__end_resty2_a__/g, '<a href="$1">$2</a>')
        .replace(/__start_resty2_a__(\S+?)__end_resty2_a__/g, '<a href="$1">$1</a>')
}

function pod2html (pod) {
    pod.replace(/\n[ \t]+\n/g, '\n\n');
    var paras = pod.split(/\n\n+/);
    var htmlBits = [];
    var curListType = [];
    var isFirst;
    var expectTitle = false;
    for (var i = 0; i < paras.length; i++) {
        var p = paras[i];
        var isLast = i == paras.length - 1;
        if (p == null) continue;
        p = p.replace(/^\n+|\n+$/g, '');
        if (p == "") continue;
        //diag(p);
        var match = p.match(/^[ \t]+/);
        if (match) {
            //diag("matched");
            htmlBits.push('<pre>' + pod2html_escape(p) + '</pre>');
            expectTitle = false;
            continue;
        }
        match = p.match(/^=head(\d+) +(.*)/);
        if (match) {
            var level = match[1];
            var title = match[2];
            htmlBits.push('<h' + level + '>' +
                    title + '</h' + level + '>');
            expectTitle = false;
            continue;
        }
        match = p.match(/^=over(?:\s+\d+)?\s*$/);
        if (match && !isLast) {
            var html;
            var next = paras[i+1];
            if (next && /^=item +(\d+)\./.test(next)) {
                curListType.push('ol');
                html = '<ol>';
            } else if (next && /^=item +\*\s*$/.test(next)) {
                curListType.push('ul');
                html = '<ul>';
            } else {
                curListType.push('dl');
                html = '<dl>';
            }
            isFirst = true;
            htmlBits.push(html);
            expectTitle = false;
            continue;
        }
        if (/^=back\s*$/.test(p)) {
            var type = curListType.pop();
            if (type) {
                var html = '';
                if (type == 'ul' || type == 'ol')
                    html += '</li>';
                else
                    html += '</dd>';
                html += '</' + type + '>';
                htmlBits.push(html);
                expectTitle = false;
                continue;
            }
        }
        var match = p.match(/^=item +(?:\*|\d+\.)\s*$/);
        if (match) {
            //var type = curListType.pop();
            //var next = paras[i+1];
            //paras[i+1] = null;
            var html = '';
            if (isFirst)
                isFirst = false;
            else
                html += '</li>';
            htmlBits.push(html + '<li>');
            expectTitle = true;
            continue;
        }

        var match = p.match(/^=item +(.*)/);
        if (match) {
            var title = match[1];
            //var type = curListType.pop();
            var html = '';
            if (isFirst)
                isFirst = false;
            else
                html += '</dd>';
            htmlBits.push(html + '<dt>' + title + '</dt><dd>');
            expectTitle = false;
            continue;
        }
        var match = p.match(/^=image (\S+)/);
        if (match) {
            var url = match[1];
            url = pod2html_escape(url);
            htmlBits.push('<p><img src="' + url + '"/></p>');
            expectTitle = false;
            continue;
        }
        if (/^=(?:cut|pod|encoding|begin|end)\b/.test(p)) continue;
        if (expectTitle) {
            htmlBits.push(pod2html_escape_in_p(p));
            expectTitle = false;
        } else {
            htmlBits.push('<p>' + pod2html_escape_in_p(p) + '</p>');
        }
    }
    //dump(htmlBits);
    return htmlBits.join("\n");
}

