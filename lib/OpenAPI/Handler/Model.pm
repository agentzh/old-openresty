package OpenAPI;

use vars qw($Dumper);
use strict;
use warnings;

our %to_native_type = (
    text => 'text',
    integer => 'integer',
    date => 'date',
    serial => 'serial',
    time => 'time',
    timestamp => 'timestamp',
    real => 'real',
    double => 'double precision',
);

sub DELETE_model_list {
    my ($self, $bits) = @_;
    my $res = $self->get_tables();
    if (!$res) {
        return { success => 1 };
    }; # no-op
    my @tables = map { @$_ } @$res;
    #$tables = $tables->[0];

    for my $table (@tables) {
        $self->drop_table($table);
    }
    return { success => 1 };
}

sub GET_model_list {
    my ($self, $bits) = @_;
    my $models = $self->get_models;
    $models ||= [];

    map { $_->{src} = "/=/model/$_->{name}" } @$models;
    $models;
}

sub GET_model {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    #
    # TODO: need to deal with '~'
    #
    return $self->get_model_cols($model);
}

sub POST_model {
    my ($self, $bits) = @_;
    my $data = _HASH($self->{_req_data}) or
        die "The model schema must be a HASH.\n";
    my $model = $bits->[1];

    my $name;
    if ($model eq '~') {
        $model = $data->{name};
    }

    if ($name = delete $data->{name} and $name ne $model) {
        $self->warning("name \"$name\" in POST content ignored.");
    }
    $data->{name} = $model;
    return $self->new_model($data);
}

sub DELETE_model {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $table = $model;
    #$tables = $tables->[0];
    $self->drop_table($table);
    return { success => 1 };
}

sub GET_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];

    my $table_name = $model;

    my $select = SQL::Select->new(qw< name type label >, '"default"')
            ->from('_columns')
            ->where(table_name => Q($table_name))
            ->order_by('id');
    if ($col eq '~') {
        my $list = $self->select("$select", { use_hash => 1 });
        if (!$list or !ref $list) { $list = []; }
        unshift @$list, { name => 'id', type => 'serial', label => 'ID' };
        return $list;
    } else {
        $select->where( name => Q($col) );
        my $res = $self->select("$select", { use_hash => 1 });
        if (!$res or !@$res) {
            die "Column '$col' not found.\n";
        }

        return $res->[0];
    }
}

sub POST_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    my $data = $self->{_req_data};
    my $table_name = $model;

    my $num = $self->column_count;

    if ($num >= $COLUMN_LIMIT) {
        die "Exceeded model column count limit: $COLUMN_LIMIT.\n";
    }

    $data = _HASH($data) or die "column spec must be a HASH.\n";
    if ($col eq 'id') {
        die "Column id is reserved.";
    }
    if ($col eq '~') {
         $col = $data->{name} || die "you must provide the new the column with a name!";
    }

    my $alias = $data->{name};
    my $cols = $self->get_model_col_names($model);
    my $fst = first { $col eq $_ } @$cols;
    if (defined $fst) {
        die "Column '$col' already exists in model '$model'.\n";
    }
    # type defaults to 'text' if not specified.
    my $type = $data->{type} || 'text';
    my $label = $data->{label} or
        die "No 'label' specified for column \"$col\" in model \"$model\".\n";
    my $ntype = $to_native_type{$type};
    if (!$ntype) {
        die "Bad column type: $type\n",
            "\tOnly the following types are available: ",
            join(", ", sort keys %to_native_type), "\n";
    }

    my $insert = SQL::Insert->new('_columns')
        ->cols(qw< name label type native_type table_name >)
        ->values( Q($col, $label, $type, $ntype, $table_name) );

    my $default = delete $data->{default};
    if (defined $default) {
        $default = $self->process_default($default);
        $insert->cols('"default"')->values(Q($default));
    }
    $default ||= 'null';

    my $sql = "alter table \"$table_name\" add column \"$col\" $ntype default $default;\n";
    $sql .= "$insert";

    my $res = $self->do($sql);

    return { success => 1,
             src => "/=/model/$model/$col",
             warning => "Column name \"$alias\" Ignored."
     } if $alias && $alias ne $col;
    return { success => 1, src => "/=/model/$model/$col" };
}

sub PUT_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    my $data = _HASH($self->{_req_data}) or
        die "column spec must be a non-empty HASH.\n";
    my $table_name = $model;

    # discard 'id' column
    if (lc($col) eq 'id') {
        die "Column id is reserved.";
    }
    # type defaults to 'text' if not specified.
    my $sql;
    my $new_col = delete $data->{name};
    my $update_meta = SQL::Update->new('_columns');
    if ($new_col) {
        _IDENT($new_col) or die "Bad column name: ",
                $Dumper->($new_col), "\n";

        #$new_col = $new_col);
        $update_meta->set(name => Q($new_col));
        $sql .= "alter table \"$table_name\" rename column \"$col\" to \"$new_col\";\n";
        #$col = $new_col;
    } else {
        $new_col = $col;
    }
    my $type = delete $data->{type};
    my $ntype;
    if ($type) {
        die "Changing column type is not supported.\n";
        $ntype = $to_native_type{$type};
        if (!$ntype) {
            die "Bad column type: $type\n",
                "\tOnly the following types are available: ",
                join(", ", sort keys %to_native_type), "\n";
        }
        $update_meta->set(type => Q($type))
            ->set(native_type => Q($ntype));
        $sql .= "alter table \"$table_name\" alter column \"$new_col\" type $ntype;\n",
    }

    my $label = delete $data->{label};
    if (defined $label) {
        _STRING($label) or die "Lable must be a non-empty string: ",
            $Dumper->($label);
        $update_meta->set(label => Q($label));
    }

    my $default = delete $data->{default};
    if (defined $default) {
        $default = $self->process_default($default);

        $update_meta->set(QI('default') => Q($default));
        $sql .= "alter table \"$table_name\" alter column \"$new_col\" set default $default;\n",
    }

    $update_meta->where(table_name => Q($table_name))
        ->where(name => Q($col));

    $sql .= $update_meta;

    my $res = $self->do($sql);

    return { success => $res ? 1 : 0 };
}

sub DELETE_model_column {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $col = $bits->[2];
    my $table_name = $model;

    # discard 'id' column
    if (lc($col) eq 'id') {
        die "Column \"id\" is reserved.\n";
    }
    my $sql = '';

    if($col eq '~') {
         $self->warning("Column \"id\" is reserved.");
     my $columns = $self->get_model_col_names($model);
     for my $c (@$columns) {
              $sql .= "delete from _columns where table_name = '$table_name' and name='$c';" .
                      "alter table \"$table_name\" drop column \"$c\" restrict;";
         }
    } else {
        $sql = "delete from _columns where table_name='$table_name' and name='$col'; alter table \"$table_name\" drop column \"$col\" restrict;";
    }
    my $res = $self->do($sql);
    return { success => $res > -1? 1:0 };
}

# alter table $table_name rename column $col TO city;
sub POST_model_row {
    my ($self, $bits) = @_;
    my $data = $self->{_req_data};
    my $model = $bits->[1];

    return $self->insert_records($model, $data);
}

sub GET_model_row {
    my ($self, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];

    if ($column ne '~' and $value ne '~') {
        return $self->select_records($model, $column, $value);
    }
    if ($column ne '~' and $value eq '~') {
        return $self->select_records($model, $column);
    }
    if ($column eq '~' and $value eq '~') {
        return $self->select_all_records($model);
    }
    if ($column eq '~') {
        return $self->select_records($model, $column, $value);
    } else {
        return { success => 0, error => "Unsupported operation." };
    }
}

sub DELETE_model_row {
    my ($self, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];
    if ($column eq '~' and $value eq '~') {
        return $self->delete_all_records($model);
    }

    return $self->delete_records($model, $column, $value);
}

sub PUT_model_row {
    my ($self, $bits) = @_;
    my $model  = $bits->[1];
    my $column = $bits->[2];
    my $value  = $bits->[3];
    my $data = $self->{_req_data};
    return $self->update_records($model, $column, $value, $data);
}

sub PUT_model {
    my ($self, $bits) = @_;
    my $model = $bits->[1];
    my $data = $self->{_req_data};
    return $self->alter_model($model, $data);
}

sub new_model {
    my ($self, $data) = @_;
    my $nmodels = $self->model_count;
    if ($nmodels >= $MODEL_LIMIT) {
        #warn "===================================> $num\n";
        die "Exceeded model count limit $MODEL_LIMIT.\n";
    }
    my $model = delete $data->{name} or
        die "No 'name' field found for the new model\n";
    my $table = $model;

    my $description = delete $data->{description} or
        die "No 'description' specified for model \"$model\".\n";
    die "Bad 'description' value: ", $Dumper->($description), "\n"
        unless _STRING($description);

    # XXX Should we allow 0 column table here?
    if (!ref $data) {
        die "Malformed data. Hash or Array expected.\n";
    }

    my $columns = delete $data->{columns};
    if (_HASH($columns)) { $columns = [$columns] }
    if ($columns && !_ARRAY0($columns)) {
        die "Invalid 'columns' value: ", $Dumper->($columns), "\n";
    } elsif (!$columns) {
        $self->warning("No 'columns' specified for model \"$model\".");
        $columns = [];
    } elsif (!@$columns) {
        $self->warning("'columns' empty for model \"$model\".");
    }
    if (@$columns > $COLUMN_LIMIT) {
        die "Exceeded model column count limit: $COLUMN_LIMIT.\n";
    }

    if (%$data) {
    my @key = sort(keys %$data);
        die "Unrecognized keys in model schema 'TTT': ",
            join(", ", @key),"\n";
    }
    my $i = 1;
    if ($self->has_model($model)) {
        die "Model \"$model\" already exists.\n";
    }
    my $insert = SQL::Insert->new('_models')
        ->cols(qw< name table_name description >)
        ->values( Q($model, $table, $description) );

    my $sql = "$insert";
    $insert->reset('_columns')
        ->cols(QI( qw<name type native_type label table_name> ));
    $sql .=
        "create table \"$table\" (\n\t\"id\" serial primary key";
    my $sql2;
    my $found_id = undef;
    for my $col (@$columns) {
        _HASH($col) or die "Column definition must be a hash: ", $Dumper->($col), "\n";
        my $name = delete $col->{name} or
            die "No 'name' specified for the column $i.\n";
        _STRING($name) or die "Bad column name: ", $Dumper->($name), "\n";
        _IDENT($name) or die "Bad column name: $name\n";
        if (length($name) >= 32) {
            die "Column name too long: $name\n";
        }
        #$name = $name;
        # discard 'id' column
        if (lc($name) eq 'id') {
            $found_id = 1;
            next;
        }
        # type defaults to 'text' if not specified.
        my $type = delete $col->{type} || 'text';
        my $label = $col->{label} or
            die "No 'label' specified for column \"$name\" in model \"$model\".\n";

        my $default = delete $col->{default};
        my $ntype = $to_native_type{$type};
        if (!$ntype) {
            die "Invalid column type: $type\n",
                "\tOnly the following types are available: ",
                join(", ", sort keys %to_native_type), "\n";
        }
        $sql .= ",\n\t\"$name\" $ntype";
        my $ins = $insert->clone
            ->values(Q($name, $type, $ntype, $label, $table));
        if (defined $default) {
            $default = $self->process_default($default);
            # XXX
            $sql .= " default $default";
            $ins->cols(QI('default'))
                ->values(Q($default));
        }
        $sql2 .= $ins;
        $i++;
    }
    $sql .= "\n);\ngrant select on table \"$table\" to anonymous;\n";
   #warn $sql, "\n";

    #register_table($table);
    #register_columns
    eval {
        $self->do($sql2 . $sql);
    };
    if ($@) {
        die "Failed to create model \"$model\": $@\n";
    }
    return {
        success => 1,
        $found_id ? (warning => "Column \"id\" reserved. Ignored.") : ()
    };
}


sub process_default {
    my ($self, $default) = @_;
    if (_STRING($default or $default eq '0')) {
        return Q($default);
    } elsif (_ARRAY($default)) {
        my $func = shift @$default;
        _STRING($func) or
            die "Invalid \"default\" value: ", $Dumper->($default), "\n";
        $func = lc($func);
        if ($func eq 'now') {
            return "now()";
        } else {
            die "Unknown function for \"default\": ", $Dumper->($func), "\n";
        }
    } else {
        die "Invalid \"default\" value: ", $Dumper->($default), "\n";
    }
}

sub has_model {
    my ($self, $model) = @_;
    _IDENT($model) or die "Bad model name: $model\n";
    my $retval;
    my $select = SQL::Select->new('count(name)')
        ->from('_models')
        ->where(name => Q($model))
        ->limit(1);
    eval {
        $retval = $self->select("$select")->[0][0];
    };
    return $retval + 0;
}

sub global_model_check {
    my ($self, $rbits, $meth) = @_;
         #warn "$meth: {@$rbits}\n";

    my ($model, $col);
    if (@$rbits >= 2) {
        $model = $rbits->[1];
        _IDENT($model) or $model eq '~' or die "Bad model name: ", $Dumper->($model), "\n";
        if (length($model) >= 32) {
            die "Model name too long: $model\n";
        }
    }
    if (@$rbits >= 3) {
        # XXX check column name here...
        $col = $rbits->[2];
        (_IDENT($col) || $col eq '~') or die "Bad column name: ", $Dumper->($col), "\n";
    }

    if ($meth eq 'POST') {
            #warn "hello {@$rbits}";
        if (@$rbits >= 3 and $model ne '~') {
            if (!$self->has_model($model)) {
                die "Model \"$model\" not found.\n";
            }
 #(_IDENT($col) || $col eq '~') or die "Column '$col' not found.\n";
        }
    } else {

        if ($model and $model ne '~') {
            if (!$self->has_model($model)) {
                die "Model \"$model\" not found.\n";
            }
        }
        #
        if ($col and $col ne '~') {
            if ($model ne '~' and ! $self->has_model_col($model, $col)) {
                die "Column '$col' not found.\n";
            }
        }
    }
}

1;

