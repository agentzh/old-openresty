var openapi;

var display = function (res) {
    $("#output").text(JSON.stringify(res));
};

function get_model_list (res) {
    if (res) display(res);
    //return;
    openapi.callback = 'render_model_list';
    openapi.get('/=/model');
}

function delete_model (model) {
    if (confirm("Do you really want to remove model " + model + "?")) {
        //alert("Deleting...");
        openapi.callback = 'get_model_list';
        openapi.del("/=/model/" + model);
    }
}

function render_model_list (data) {
    var html = Jemplate.process('model-list.tt2', { model_list: data });
    //alert(html);
    var model_list = $("#model-list");
    model_list.html(html);
    var links = $("a.del-model", model_list[0]);
    //alert(links.length);
    $(".editModelDesc").editable( function (value, settings) {
        var model_name = $(this).parent()[0].id;
        //alert(model_name);
        //alert(JSON.stringify(this));
        //var old_desc = this.revert;
        var new_desc = value;
        //alert("New desc: " + new_desc);
        //alert(new_desc);
        //alert("Changing model desciption from " + old_desc + " to " + new_desc);
        openapi.callback = 'handle_put_model';
        openapi.put({ description: new_desc }, '/=/model/' + model_name);
        return "Saving...";
    }, {
        //type    : "textarea",
        style   : "display: inline",
        submit  : "Save",
        width : "132",
        height: "26",
        tooltop: "Click to edit"
    });

    $(".editModelName").editable( function (value, settings) {
        //console.log(settings);
        //alert("Renaming model " + old_val + " to " + new_val);
        //alert($(this).html());
        //alert(settings);
        //alert(blah);
        var old_name = this.revert;
        var new_name = value;
        //alert("Changing model name from " + old_name + " to " + new_name);
        openapi.callback = 'handle_put_model';
        openapi.put({ name: new_name }, '/=/model/' + old_name);
        return "Saving...";
    }, {
        //type    : "textarea",
        style   : "display: inline",
        submit  : "Save",
        width : "132",
        height: "26",
        tooltop: "Click to edit"
    });
    //display(data);
}

function handle_put_model (res) {
    display(res);
    //alert("handle put model: " + JSON.stringify(res));
    get_model_list();
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
        openapi.callback = 'get_model_list';
        openapi.true_post(data, "/=/model/~");
        return false;
    });
    var host = 'http://10.62.136.86';
    openapi = new OpenAPI(
        { server: host, callback: 'display' }
    );
    openapi.callback = 'init';
    openapi.login('admin', '4423037');
} );

function init () {
    get_model_list();
}

