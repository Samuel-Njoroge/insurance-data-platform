# Coverhouse

This project uses dbt v2.0.9, distributed as the `dbt` Python package.
Install the repository's `requirements.txt` in a clean virtual environment.
Do not install `dbt-core` v1 or `dbt-duckdb` alongside it: v2 includes
the DuckDB adapter, and overlapping Python packages can break the CLI.

From the repository root, verify the installation with:

```bash
dbt --version
cd dbt/coverhouse
dbt debug
```

Configure a `coverhouse` profile in your dbt `profiles.yml` before running
the project. The `version` field in `dbt_project.yml` is the Coverhouse
project version; `require-dbt-version` constrains the dbt engine version.

### Using the starter project

Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
