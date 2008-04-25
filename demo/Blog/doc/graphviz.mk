blog.agentzh.org: index.html blog.js jquery.js JSON.js openresty.js jemplates.js

index.html: header.tt index.tt footer.tt sidebar.tt
	tpage $| > $@

jemplates.js: pager.tt nav.tt calendar.tt post.tt comments.tt ...
	jemplate --compile

