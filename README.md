## dbt-materialize

[dbt](https://www.getdbt.com/) adapter for [Materialize](http://materialize.io). 

Note, this plugin is a work in progress, and not yet suitable for production.

### Installation
This plugin can be installed via pip:
```
$ pip install dbt-materialize
```

### Configuring your profile

[Materialize](http://materialize.io) is based on the Postgres database protocols, so use the
[dbt postgres settings](https://docs.getdbt.com/docs/profile-postgres) in your connection profile,
only substitute `type: materialize` for `type: postgres`.

## Supported Features

### Materializations

Type | Supported? | Form in Materialize
-----|------------|----------------
table | :white_check_mark: | [materialized view](https://materialize.com/docs/sql/create-materialized-view/#main)
view | :white_check_mark: | [view](https://materialize.com/docs/sql/create-view/#main)
incremental | :x: |:x:
ephemeral | :white_check_mark: | cte

TL;DR: Use tables instead of incremental models when using Materialize as your data warehouse.

Longer explanation:

dbt's incremental models are valuable because they only spend your time and money transforming *new data*
that has arrived in your data source. Luckily, this is exactly what Materialize's materialized views were
built to do! Better yet, our materialized views will always return up-to-date results without manual or
configured refreshed. For more information, check out [our documentation](https://materialize.com/docs/).

### Seeds

[`dbt seed`](https://docs.getdbt.com/reference/commands/seed/) will create a static materialized
view from a csv file. You will not be able to add to or update this view after it has been created.

### Hooks

Not tested.

### Custom Schemas

Not tested.

### Sources

Not tested.

### Testing and Documentation

[`dbt docs` commands](https://docs.getdbt.com/reference/commands/cmd-docs) are supported.

[`dbt test`](https://docs.getdbt.com/reference/commands/test) is untested.

### Snapshots

Not supported, will likely not be supported in the near term.  

