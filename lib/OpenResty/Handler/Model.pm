package OpenResty::Handler::Model;

use strict;
use warnings;

#use Smart::Comments '###';
use OpenResty::Util;
use List::Util qw( first );
use Params::Util qw( _STRING _ARRAY0 _ARRAY _HASH );
use JSON::Syck ();
use OpenResty::Limits;
use Clone 'clone';
use Encode qw(is_utf8);
use OpenResty::QuasiQuote::SQL;
use OpenResty::QuasiQuote::Validator;

#%OpenResty::AccountFiltered = %OpenResty::AccountFiltered;
#$OpenResty::OpMap = $OpenResty::OpMap;

sub check_type {
    my $type = shift;
    if ($type !~ m{^ \s*
                (
                    bigint |
                    cidr |
                    inet |
                    ip4r |
                    macaddr |
                    tsquery |
                    tsvector |
                    bit \s* \( \s* \d+ \s* \) |
                    boolean |
                    text |
                    varchar \s* \( \s* \d+ \s* \) |
                    char \s* \( \s* \d+ \s* \) |
                    integer |
                    serial |
                    real |
                    double precision |
                    ltree |
                    line |
                    point |
                    lseg |
                    path |
                    date |
                    (?:timestamp|time) (?: \s* \( \s* \d+ \s* \) )?
                        (?: \s* with(?:out)? \s+ time \s+ zone)? |
                    interval (?: \s* \( \s* \d+ \s* \) )?
                ) \s* $
            }x) {
        die "Bad column type: $type\n";
    }
    $1;
}

sub DELETE_model_list {
    my ($self, $openresty, $bits) = @_;
    my $user = $openresty->current_user;
    my $res = $self->get_tables($openresty);
    if (!$res) {
        return { success => 1 };
    }; # no-op
    my @tables = map { @$_ } @$res;
    #$tables = $tables->[0];

    my $sql;
    for my $table (@tables) {
        $OpenResty::Cache->remove_has_model($user, $table);
        $sql .= $self->drop_table($openresty, $table);
    }
    if ($sql) {
        $openresty->do($sql);
    }
    return { success => 1 };
}

sub GET_model_list {
    my ($self, $openresty, $bits) = @_;
    my $models = $self->get_models($openresty);
    $models ||= [];

    map { $_->{src} = "/=/model/$_->{name}" } @$models;
    $models;
}

sub GET_model {
    my ($self, $openresty, $bits) = @_;
    my $model = $bits->[1];
    #
    # TODO: need to deal with '~'
    #
    return $self->get_model_cols($openresty, $model);
}

sub POST_model {
    my ($self, $openresty, $bits) = @_;
    my $data = _HASH($openresty->{_req_data}) or
        die "The model schema must be a HASH.\n";
    my $model = $bits->[1];

    my $name;
    if ($model eq '~') {
        $model = $data->{name};
    }

    if ($name = delete $data->{name} and $name ne $model) {
        $openresty->warning("name \"$name\" in POST content ignored.");
    }
    $data->{name} = $model;
    return $self->new_model($openresty, $data);
}

sub DELETE_model {
    my ($self, $openresty, $bits) = @_;
    my $model = $bits->[1];
    if ($model eq '~') {
        return $self->DELETE_model_list($openresty);
    }
    if (!$openresty->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    #$tables = $tables->[0];
    my $sql = $self->drop_table($openresty, $model);
    $openresty->do($sql);
    return { success => 1 };
}

sub GET_model_column {
    my ($self, $openresty, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];

    if ($col eq '~') {
        my $sql = [:sql|
            select name, type, label, "default"
            from _columns
            where table_name = $model
            order by id |];
        my $list = $openresty->select($sql, { use_hash => 1 });
        if (!$list or !ref $list) { $list = []; }

        for my $row (@$list) {
            if (my $json_default = $row->{default}) {
                $row->{default} = $OpenResty::JsonXs->decode($json_default);
            }
        }

        if (!@$list or $list->[0]->{name} ne 'id') {
            unshift @$list, { name => 'id', type => 'serial', label => 'ID' };
        }

        return $list;
    } else {
        my $sql = [:sql|
            select name, type, label, "default"
            from _columns
            where table_name = $model and name = $col
            order by id |];
        my $res = $openresty->select($sql, { use_hash => 1 });
        if (!$res or !@$res) {
            die "Column '$col' not found.\n";
        }
        my $row = $res->[0];
        if (my $json_default = $row->{default}) {
            $row->{default} = $OpenResty::JsonXs->decode($json_default);
        }

        return $row;
    }
}

sub POST_model_column {
    my ($self, $openresty, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    my $data = $openresty->{_req_data};

    my $num = $self->column_count($openresty, $model);

    if ($num >= $COLUMN_LIMIT) {
        die "Exceeded model column count limit: $COLUMN_LIMIT.\n";
    }

    if ($col eq 'id') {
        die "Column id is reserved.";
    }

    my $alias;
    if ($col ne '~') {
        $alias = $data->{name};
         $data->{name} = $col || die "you must provide the new column with a name!";
    }

    my ($label, $type, $default, $unique);

    [:validator|
        $data ~~ {
            name: IDENT :required :to($col),
            label: STRING :nonempty :required :to($label),
            type: STRING :nonempty :required :to($type),
            default: ANY :to($default),
            unique: BOOL :to($unique),
        } :required :nonempty
    |]

    my $cols = $self->get_model_col_names($openresty, $model);
    my $fst = first { $col eq $_ } @$cols;
    if (defined $fst) {
        die "Column '$col' already exists in model '$model'.\n";
    }
    $type = check_type($type);
    my $json_default;
    if (defined $default) {
        $json_default = $OpenResty::JsonXs->encode($default);
        $default = $self->process_default($openresty, $default);
    }
    $default ||= 'null';

    my $sql = [:sql|
        insert into _columns (name, label, type, table_name, "default")
            values( $col, $label, $type, $model, $json_default);
        alter table $sym:model
            add column $sym:col $kw:type default ($kw:default); |];

    my $res = $openresty->do($sql);

    return { success => 1,
             src => "/=/model/$model/$col",
             warning => "Column name \"$alias\" Ignored."
     } if $alias && $alias ne $col;
    return { success => 1, src => "/=/model/$model/$col" };
}

sub PUT_model_column {
    my ($self, $openresty, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    my $data = $openresty->{_req_data};

    # discard 'id' column
    if (lc($col) eq 'id') {
        die "Column id is reserved.";
    }

    my ($new_col, $type, $label, $unique);

    [:validator|
        $data ~~ {
            name: IDENT :to($new_col),
            label: STRING :nonempty :to($label),
            type: STRING :nonempty :to($type),
            default: ANY,
            unique: BOOL :to($unique),
        } :required :nonempty
    |]

    my $sql;
    my $update_meta = OpenResty::SQL::Update->new('_columns');
    if ($new_col) {
        #$new_col = $new_col);
        $update_meta->set(name => Q($new_col));
        $sql .= [:sql|
            alter table $sym:model rename column $sym:col to $sym:new_col;
        |];
    } else {
        $new_col = $col;
    }
    if ($type) {
        #die "Changing column type is not supported.\n";
        $type = check_type($type);
        $update_meta->set(type => Q($type));
        $sql .= [:sql|
            alter table $sym:model alter column $sym:new_col type $kw:type;
        |];
    }

    if (defined $label) {
        _STRING($label) or die "Lable must be a non-empty string: ",
            $OpenResty::Dumper->($label);
        $update_meta->set(label => Q($label));
    }

    if (exists $data->{default}) {
        my $default = $data->{default};
        if (defined $default) {
            #warn "DEFAULT: $default\n";
            my $json_default = $OpenResty::JsonXs->encode($default);
            $default = $self->process_default($openresty, $default);

            $update_meta->set(QI('default') => Q($json_default));
            $sql .= "alter table \"$model\" alter column \"$new_col\" set default ($default);\n",
        } else {
            $update_meta->set(QI('default') => Q("null"));
            $sql .= "alter table \"$model\" alter column \"$new_col\" set default null;\n",
        }
    }

    $update_meta->where(table_name => Q($model))
        ->where(name => Q($col));

    # XXX TODO: add support for updating column's uniqueness
    if (defined $unique) {
        die "Updating column's uniqueness is not implemented yet.\n";
    }

    $sql .= $update_meta;
    #warn "SQL:: $sql\n";

    my $res = $openresty->do($sql);

    return { success => $res ? 1 : 0 };
}

sub DELETE_model_column {
    my ($self, $openresty, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];

    # discard 'id' column
    if (lc($col) eq 'id') {
        die "Column \"id\" is reserved.\n";
    }
    my $sql = '';

    if($col eq '~') {
         $openresty->warning("Column \"id\" is reserved.");
     my $columns = $self->get_model_col_names($openresty, $model);
     for my $c (@$columns) {
        $sql .= "delete from _columns where table_name = '$model' and name='$c';" .
                      "alter table \"$model\" drop column \"$c\" restrict;";
         }
    } else {
        $sql = "delete from _columns where table_name='$model' and name='$col'; alter table \"$model\" drop column \"$col\" restrict;";
    }
    my $res = $openresty->do($sql);
    return { success => $res > -1? 1:0 };
}

# alter table $model rename column $col TO city;
sub POST_model_row {
    my ($self, $openresty, $bits) = @_;
    my $data = $openresty->{_req_data};
    my $model = $bits->[1];

    ### POST_model_row
    return $self->insert_records($openresty, $model, $data);
}

sub GET_model_row {
    my ($self, $openresty, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];

    if ($column ne '~' and $value ne '~') {
        return $self->select_records($openresty, $model, $column, $value);
    }
    if ($column ne '~' and $value eq '~') {
        return $self->select_records($openresty, $model, $column);
    }
    if ($column eq '~' and $value eq '~') {
        return $self->select_all_records($openresty, $model);
    }
    if ($column eq '~') {
        return $self->select_records($openresty, $model, $column, $value);
    } else {
        return { success => 0, error => "Unsupported operation." };
    }
}

sub DELETE_model_row {
    my ($self, $openresty, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];
    if ($value eq '~') {
        return $self->delete_all_records($openresty, $model);
    }

    return $self->delete_records($openresty, $model, $column, $value);
}

sub PUT_model_row {
    my ($self, $openresty, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];
    my $data = $openresty->{_req_data};
    return $self->update_records($openresty, $model, $column, $value, $data);
}

sub PUT_model {
    my ($self, $openresty, $bits) = @_;
    my $model = $bits->[1];
    my $data = $openresty->{_req_data};
    #warn "Model: $model";
    return $self->alter_model($openresty, $model, $data);
}

sub new_model {
    my ($self, $openresty, $data) = @_;
    my $nmodels = $self->model_count($openresty);
    if ($nmodels >= $MODEL_LIMIT) {
        #warn "===================================> $num\n";
        die "Exceeded model count limit $MODEL_LIMIT.\n";
    }

    my ($model, $desc, $columns);
    [:validator|
        $data ~~
        {
            name: IDENT :to($model),
            description: STRING :nonempty :required :to($desc),
            columns: [
                {
                    name: IDENT :required,
                    label: STRING :nonempty :required,
                    type: STRING :nonempty :required,
                    default: ANY,
                    unique: BOOL,
                }
            ] :to($columns)
        } :required :nonempty
    |]

    # XXX Should we allow 0 column table here?

    if (!$columns) {
        $openresty->warning("No 'columns' specified for model \"$model\".");
        $columns = [];
    } elsif (!@$columns) {
        $openresty->warning("'columns' empty for model \"$model\".");
    }
    if (@$columns > $COLUMN_LIMIT) {
        die "Exceeded model column count limit: $COLUMN_LIMIT.\n";
    }

    if ($openresty->has_model($model)) {
        die "Model \"$model\" already exists.\n";
    }
    my $sql = [:sql|
        insert into _models (name, table_name, description)
        values ($model, $model, $desc); |];

    $sql .=
        [:sql| create table $sym:model (id serial primary key |];
    my $sql2 = '';
    my $found_id = undef;
    for my $col (@$columns) {
        my $name = $col->{name};
        my $label = $col->{label};
        my $type = $col->{type};
        if (length($name) >= 32) {
            die "Column name too long: $name\n";
        }
        #$name = $name;
        # discard 'id' column
        if (lc($name) eq 'id') {
            $found_id = 1;
            next;
        }

        my $default = $col->{default};
        $type = check_type($type);
        $sql .= [:sql| , $sym:name $kw:type |];

        my $json_default;
        if (defined $default) {
            $json_default = $OpenResty::JsonXs->encode($default);
            $default = $self->process_default($openresty, $default);
            # XXX
            $sql .= " default ($default)";
        }

        my $col_sql = [:sql|
            insert into _columns (name, type, label, table_name, "default")
            values ($name, $type, $label, $model, $json_default); |];
        #warn Q($json_default);

        my $unique = delete $col->{unique};
        if ($unique) {
            #warn "Unique found: $unique\n";
            # XXX FIXME: use alter table ... add constraint instead here...
            $sql .= " unique";
        }

        $sql2 .= $col_sql;
    }
    $sql .= "\n);\ngrant select on table \"$model\" to anonymous;\n";
   #warn $sql, "\n";

    #register_columns
    eval {
        $openresty->do($sql2 . $sql);
    };
    if ($@) {
        die "Failed to create model \"$model\": $@\n";
    }
    return {
        success => 1,
        $found_id ? (warning => "Column \"id\" reserved. Ignored.") : ()
    };
}

sub check_default_expr {
    my $expr = shift;
    if ($expr !~ m{^ \s*
                (
                    now \s* \( \s* \)
                        (?: \s+ at \s+ time \s+ zone \s+ '[^']+' )?
                ) \s* $
            }x) {
        die "Bad default expression: $expr\n";
    }
    $1;
}

sub process_default {
    my ($self, $openresty, $default) = @_;
    if ($default eq '' or _STRING($default or $default eq '0')) {
        return Q($default);
    } elsif (_ARRAY($default)) {
        my $expr = join ' ', @$default;
        check_default_expr($expr);
        return $expr;
    } else {
        die "Invalid \"default\" value: ", $OpenResty::Dumper->($default), "\n";
    }
}

sub global_model_check {
    my ($self, $openresty, $rbits, $meth) = @_;
         #warn "$meth: {@$rbits}\n";

    my ($model, $col);
    if (@$rbits >= 2) {
        $model = $rbits->[1];
        _IDENT($model) or $model eq '~' or die "Bad model name: ", $OpenResty::Dumper->($model), "\n";
        if (length($model) >= 32) {
            die "Model name too long: $model\n";
        }
    }
    if (@$rbits >= 3) {
        # XXX check column name here...
        $col = $rbits->[2];
        (_IDENT($col) || $col eq '~') or die "Bad column name: ", $OpenResty::Dumper->($col), "\n";
    }

    if ($meth eq 'POST') {
            #warn "hello {@$rbits}";
        if (@$rbits >= 3 and $model ne '~') {
            if (!$openresty->has_model($model)) {
                die "Model \"$model\" not found.\n";
            }
 #(_IDENT($col) || $col eq '~') or die "Column '$col' not found.\n";
        }
    } else {

        if ($model and $model ne '~') {
            if (!$openresty->has_model($model)) {
                die "Model \"$model\" not found.\n";
            }
        }
        #
        if ($col and $col ne '~') {
            if ($model ne '~' and ! $self->has_model_col($openresty, $model, $col)) {
                die "Column '$col' not found.\n";
            }
        }
    }
}

sub get_tables {
    #my ($self, $openresty, $user) = @_;
    my ($self, $openresty) = @_;
    my $sql = [:sql| select name from _models |];
    return $openresty->select("$sql");
}

sub model_count {
    my ($self, $openresty) = @_;
    return $openresty->select(
        [:sql| select count(*) from _models |]
    )->[0][0];
}

sub column_count {
    my ($self, $openresty, $model) = @_;
    return $openresty->select(
        [:sql| select count(*) from _columns where table_name = $model |]
    )->[0][0];
}

sub row_count {
    my ($self, $openresty, $model) = @_;
    return $openresty->select(
        [:sql| select count(*) from $sym:model |]
    )->[0][0];
}

sub get_models {
    my ($self, $openresty) = @_;
    my $sql = [:sql| select name, description from _models order by id |];
    return $openresty->select($sql, { use_hash => 1 });
}

sub get_model_cols {
    my ($self, $openresty, $model) = @_;
    if (!$openresty->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $sql = [:sql|
        select description
        from _models
        where name = $model |];
    my $list = $openresty->select($sql);
    my $desc = $list->[0][0];
    $sql = [:sql|
        select name, type, label, "default"
        from _columns
        where table_name = $model
        order by id |];
    $list = $openresty->select($sql, { use_hash => 1 });
    if (!$list or !ref $list) { $list = []; }

    for my $row (@$list) {
        if (my $json_default = $row->{default}) {
            $row->{default} = $OpenResty::JsonXs->decode($json_default);
        }
    }

    #### model handler: $list
    if (!@$list or $list->[0]->{name} ne 'id') {
        unshift @$list, { name => 'id', type => 'serial', label => 'ID' };
    }
    return { description => $desc, name => $model, columns => $list };
}

sub get_model_col_names {
    my ($self, $openresty, $model) = @_;

    if (!$openresty->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $sql = [:sql|
        select name
        from _columns
        where table_name = $model |];

    my $list = $openresty->select($sql);
    if (!$list or !ref $list) { return []; }
    return [map { @$_ } @$list];
}

sub has_model_col {
    my ($self, $openresty, $model, $col) = @_;
    _IDENT($model) or die "Bad model name: $model\n";
    _IDENT($col) or die "Bad model column name: $col\n";

    return 1 if $col eq 'id';
    my $res;
    my $select = [:sql|
        select id
        from _columns
        where table_name = $model and name = $col
        limit 1 |];
    eval {
        $res = $openresty->select("$select")->[0][0];
    };
    return $res;
}

sub drop_table {
    my ($self, $openresty, $model) = @_;
    my $user = $openresty->current_user;
    $OpenResty::Cache->remove_has_model($user, $model);
    return [:sql|
        drop table if exists $sym:model;
        delete from _models where table_name = $model;
        delete from _columns where table_name = $model;
    |];
}

sub insert_records {
    my ($self, $openresty, $model, $data) = @_;
    if (!ref $data) {
        die "Malformed data: Hash or Array expected\n";
    }
    ### Data: $data
    if ($self->row_count($openresty, $model) >= $RECORD_LIMIT) {
        die "Exceeded model row count limit: $RECORD_LIMIT.\n";
    }
    ### HERE 2...

    my $cols = $self->get_model_col_names($openresty, $model);
    my $sql;
    my $insert = OpenResty::SQL::Insert->new(QI($model));

    ### HERE 3...

    my $user = $openresty->current_user;
    if ($OpenResty::AccountFiltered{$user}) {
        my $str = $OpenResty::Dumper->(clone($data));
        #die $val;
        #die "aaaa";
        OpenResty::Filter::QP->filter($str);
    }

    ### HERE 4...

    if (ref $data eq 'HASH') { # record found
        my $with_explicit_id = 0;
        my $sql = $self->insert_record($openresty, $insert, $data, $cols, 1, \$with_explicit_id);
        if ($with_explicit_id) {
            $sql .= [:sql|
                select setval(pg_get_serial_sequence('$sym:model', 'id'), temp.max_id)
                from (select max(id) as max_id from $sym:model) temp;
            |];
        }
        # XXX This is a hack...
        my $num = $openresty->do($sql);
        my $last_id = $openresty->last_insert_id($model);

        return { rows_affected => $num, last_row => "/=/model/$model/id/$last_id", success => $num?1:0 };
    } elsif (ref $data eq 'ARRAY') {
        if (@$data > $INSERT_LIMIT) {
            die "You can only insert $INSERT_LIMIT rows at a time.\n";
        }
        my $with_explicit_id = 0;
        my $i = 0;
        my $sql;
        ### For loop...
        for my $row_data (@$data) {
            ++$i;
            _HASH($row_data) or
                die "Bad data in row $i: ", $OpenResty::Dumper->($row_data), "\n";
            $sql .= $self->insert_record($openresty, $insert, $row_data, $cols, $i, \$with_explicit_id);
        }
        ### HERE HANG...
        if ($with_explicit_id) {
            $sql .= [:sql|
                select setval(pg_get_serial_sequence('$sym:model', 'id'), temp.max_id)
                from (select max(id) as max_id from $sym:model) temp;
            |];
        }

        my $success = $openresty->do($sql);
        my $rows_affected = 0;
        if ($success) {
            $rows_affected = @$data;
        }
        # This is a hack...
        my $last_id = $openresty->last_insert_id($model);
        return { rows_affected => $rows_affected, last_row => "/=/model/$model/id/$last_id", success => $rows_affected?1:0 };
    } else {
        die "Malformed data: Hash or Array expected.\n";
    }
}

sub insert_record {
    my ($self, $openresty, $insert, $row_data, $cols, $row_num, $ref_with_explicit_id) = @_;
    $insert = $insert->clone;
    #die $user;
    ### inserting record...
    my $found = 0;
    while (my ($col, $val) = each %$row_data) {
        _IDENT($col) or
            die "Bad column name in row $row_num: ", $OpenResty::Dumper->($col), "\n";
        # XXX croak on column "id"
        if (lc($col) eq 'id') {
            $col = 'id';
            if ($ref_with_explicit_id) {
                $$ref_with_explicit_id = 1;
            }
        }
        $insert->cols(QI($col));
        $insert->values(Q($val));
        $found = 1;
    }
    if (!$found) {
        die "No column specified in row $row_num.\n";
    }
    return "$insert";
}

sub process_order_by {
    my ($self, $openresty, $select, $model) = @_;
    my $order_by = $openresty->builtin_param('_order_by');
    return unless defined $order_by;
    die "No column found in order_by.\n" if $order_by eq '';
    my @sub_order_by = split ',', $order_by;
    if (!@sub_order_by and $order_by) {
        die "Invalid order_by value: $order_by\n";
    }
    foreach my $item (@sub_order_by){
        my ($col, $dir) = split ':', $item, 2;
        die "No column \"$col\" found in order_by.\n"
            unless $self->has_model_col($openresty, $model, $col);
        $dir = lc($dir) if $dir;
        die "Invalid order_by direction: $dir\n"
            if $dir and $dir ne 'asc' and $dir ne 'desc';
        $select->order_by($col => $dir || ());
    }
}

sub process_offset {
    my ($self, $openresty, $select) = @_;
    my $offset = $openresty->{_offset};
    if ($offset) {
        $select->offset($offset);
    }
}

sub process_limit {
    my ($self, $openresty, $select) = @_;
    my $limit = $openresty->{_limit};
    if (defined $limit) {
        $select->limit($limit);
    }
}

sub select_records {
    my ($self, $openresty, $model, $user_col, $val) = @_;
    my $cols = $self->get_model_col_names($openresty, $model);

    if (lc($user_col) ne 'id' and $user_col ne '~') {
        my $found = 0;
        for my $col (@$cols) {
            if ($col eq $user_col) { $found = 1; last; }
        }
        if (!$found) { die "Column $user_col not available.\n"; }
    }
    my $select = OpenResty::SQL::Select->new;
    $select->from(QI($model));
    #warn "VAL: $val\n";
    #warn "IS UTF8???";
    if (defined $val and $val ne '~') {
        my $op = $openresty->builtin_param('_op') || 'eq';
        $op = $OpenResty::OpMap{$op};
        if ($op eq 'like') {
            $val = "%$val%";
        }
        $select->select('id', QI(@$cols));
        if ($user_col eq '~') {
            # XXX
            $select->op('or');
            for my $col (@$cols) {
                $select->where($col => $op => Q($val));
            }
        } else {
            $select->where(QI($user_col) => $op => Q($val));
        }
    } else {
        $select->select($user_col);
    }
    $self->process_order_by($openresty, $select, $model, $user_col);
    $self->process_offset($openresty, $select);
    $self->process_limit($openresty, $select);

    #use Data::Dumper;
    #warn Dumper($select->{where});
    #warn "SQL: ", $select->generate, "\n";
    my $res = $openresty->select("$select", { use_hash => 1 });
    if (!$res and !ref $res) { return []; }
    return $res;
}

sub select_all_records {
    my ($self, $openresty, $model) = @_;
    my $order_by = $openresty->{'_order_by'};

    if (!$openresty->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }

    my $select = OpenResty::SQL::Select->new('*')->from(QI($model));

    $self->process_order_by($openresty, $select, $model);
    $self->process_offset($openresty, $select);
    $self->process_limit($openresty, $select);

    my $list = $openresty->select("$select", { use_hash => 1 });
    if (!$list or !ref $list) { return []; }
    return $list;
}

sub delete_all_records {
    my ($self, $openresty, $model) = @_;
    if (!$openresty->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $retval = $openresty->do("delete from \"$model\"");
    return {success => 1,rows_affected => $retval+0};
}

sub delete_records {
    my ($self, $openresty, $model, $user_col, $val) = @_;
    if (!$openresty->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }
    my $cols = $self->get_model_col_names($openresty, $model);
    if (lc($user_col) ne 'id') {
        my $found = 0;
        for my $col (@$cols) {
            if ($col eq $user_col) { $found = 1; last; }
        }
        if (!$found) { die "Column $user_col not available.\n"; }
    }
    #my $flds = join(",", @$cols);
    my $sql;
    if (defined $val) {
        $sql = "delete from \"$model\" where \"$user_col\"=" . Q($val);
    } else {
        $sql = "delete from \"$model\"";
    }

    my $retval = $openresty->do($sql);
    return {success => 1,rows_affected => $retval+0};
}

sub update_records {
    my ($self, $openresty, $model, $user_col, $val, $data) = @_;
    my $cols = $self->get_model_col_names($openresty, $model);
    if ($user_col ne 'id' && $user_col ne '~') {
        my $found = 0;
        for my $col (@$cols) {
            if ($col eq $user_col) { $found = 1; last; }
        }
        #my $flds = join(",", @$cols);
        if (!$found) { die "Column $user_col not available.\n"; }
    }
    if (!ref $data || ref $data ne 'HASH') {
        die "HASH data expected in the content body.\n";
    }
    my $update = OpenResty::SQL::Update->new(QI($model));
    while (my ($key, $val) = each %$data) {
        my $col = $key;
        if (lc($col) eq 'id') {
            die "Column \"id\" reserved.\n";
        }
        #warn "is_utf8(val):", is_utf8($val), "\n";
        #warn "is_utf8:", is_utf8($col), "\n";
        $update->set(QI($col) => Q($val));
    }

    if (defined $val and $val ne '~') {
        # XXX SQL injection point
        $update->where(QI($user_col) => Q($val));
    }
    #warn "VAL:  $val";
    #warn "is_utf8:", is_utf8($val), "\n";
    #warn "is_utf8:", is_utf8($user_col), "\n";
    ### SQL: "$update"
    #warn "X<<<<>>>> $update";
    my $retval = $openresty->do("$update") + 0;
    return {success => $retval ? 1 : 0,rows_affected => $retval};
}

sub alter_model {
    my $self = shift;
    my $openresty = $_[0];
    my $model = _IDENT($_[1]) or die "Invalid model name \"$_[1]\".\n";
    my $data = $_[2];
    my $user = $openresty->current_user;
    if (!$openresty->has_model($model)) {
        die "Model \"$model\" not found.\n";
    }

    my ($new_model, $desc);

    [:validator|
        $data ~~
        {
            name: IDENT :to($new_model),
            description: STRING :nonempty :required :to($desc),
        } :required :nonempty
    |]

    my $sql;
    if ($new_model) {
        if ($openresty->has_model($new_model)) {
            die "Model \"$new_model\" already exists.\n";
        }
        $OpenResty::Cache->remove_has_model($user, $model);
        $sql .= [:sql|
            update _models set table_name=$new_model, name=$new_model where name=$model;
            update _columns set table_name=$new_model where table_name=$model;
            alter table $sym:model rename to $sym:new_model;
        |];
    }
    $new_model ||= $model;
    if ($desc) {
        $sql .= [:sql|
            update _models
            set description = $desc
            where name = $new_model;
        |];
    }
    #warn "SQL: $sql";
    my $retval = $openresty->do($sql);

    return {success => $retval+0 >= 0};
}

1;
__END__

=head1 NAME

OpenResty::Handler::Model - The model handler for OpenResty

=head1 SYNOPSIS

=head1 DESCRIPTION

This OpenResty handler class implements the Model API, i.e., the C</=/model/*> stuff.

=head1 METHODS

=head1 AUTHOR

Agent Zhang (agentzh) C<< <agentzh@yahoo.cn> >>

=head1 SEE ALSO

L<OpenResty::Handler::View>, L<OpenResty::Handler::Role>, L<OpenResty::Handler::Action>, L<OpenResty::Handler::Feed>, L<OpenResty::Handler::Version>, L<OpenResty::Handler::Captcha>, L<OpenResty::Handler::Login>, L<OpenResty>.

