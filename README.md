## dbt-materialize

Note, this plugin is a work in progress, and not yet suitable for production.

### Installation
This plugin can be installed via pip:
```
$ pip install dbt-materialize
```

### Configuring your profile

[Materialize](http://materialize.io) is based on the Postgres database protocols, so use the [dbt postgres settings](https://docs.getdbt.com/docs/profile-postgres) in your connection profile, only substitute `type: materialize` for `type: postgres`.
