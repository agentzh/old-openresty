var openresty;

var display = function (res) {
    $("#output").text(JSON.stringify(res));
};

function get_model_list (res) {
    //alert("Res: " + JSON.stringify(res));
    if (res) display(res);
    //return;
    openresty.callback = render_model_list;
    openresty.get('/=/model');
}

function delete_model (model) {
    if (confirm("Do you really want to remove model " + model + "?")) {
        //alert("Deleting...");
        openresty.callback = 'get_model_list';
        openresty.del("/=/model/" + model);
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
        openresty.callback = 'handle_put_model';
        openresty.purge();
        openresty.put({ description: new_desc }, '/=/model/' + model_name);
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
        openresty.callback = 'handle_put_model';
        openresty.purge();
        openresty.put({ name: new_name }, '/=/model/' + old_name);
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
        openresty.callback = get_model_list;
        openresty.purge();
        openresty.post(data, "/=/model/~");
        return false;
    });
    var host = 'http://10.62.136.86';
    openresty = new OpenAPI.Client(
        { server: host, callback: 'display' }
    );
    openresty.formId = 'new_model';
    openresty.callback = init;
    openresty.login('admin', '4423037');
} );

function init (data) {
    //alert("Hey!");
    get_model_list(data);
}

