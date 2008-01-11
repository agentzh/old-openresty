var openapi;

var display = function (res) {
    $("#output").text(JSON.stringify(res));
};

function get_model_list () {
    openapi.callback = 'render_model_list';
    openapi.get('/=/model');
}

function render_model_list (data) {
    display(data);
}

$(document).ready( function () {
    $("#new_model").submit(function () {
        var name = this.elements[0].value;
        //alert("name: " + name);
        var desc = this.elements[1].value;
        //alert("desc: " + desc);
        var data = {
            name: name,
            description: desc
        };
        openapi.post(data, "/=/model/~");
        return false;
    });
    var host = 'http://10.62.136.86';
    openapi = new OpenAPI(
        { server: host, callback: 'display' }
    );
    openapi.user = 'admin';
    openapi.password = '4423037';
    get_model_list();
} );

