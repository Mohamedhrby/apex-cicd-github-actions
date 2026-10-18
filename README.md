# GitHub Actions deploy pipeline for APEX

![License: MIT](https://img.shields.io/badge/License-MIT-informational) [![harby.dev](https://img.shields.io/badge/harby.dev-templates-C74634)](https://harby.dev/templates) ![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white) ![SQLcl](https://img.shields.io/badge/Oracle-SQLcl%2026.1.2%2B-F80000?logo=oracle&logoColor=white)

A ready-to-use workflow that validates and imports an **APEXlang** (file-based)
APEX app into your database on **every push to `main`**, using SQLcl and
encrypted secrets.
Companion to [CI/CD for APEX with GitHub Actions](https://harby.dev/learn/ci-cd-apex-github-actions) on harby.dev.

## Requirements

- **APEX 26.1 or later** in the target database (APEXlang import needs it).
- **SQLcl 26.1.2 or later** on your machine for the export. The workflow always
  downloads the latest SQLcl, so the runner is covered.
- A database the runner can reach (or a self-hosted runner inside your network),
  for example the [Dockerized 26ai + APEX stack](https://github.com/Mohamedhrby/oracle-26ai-apex-docker).

## How it works

1. Push to `main` with a change under `app/` or `database/` (or run it manually
   from the **Actions** tab).
2. The runner checks out your repo and installs Java 25 + the latest SQLcl.
3. **Validate** — `apex validate -input app/<alias>` compiles the APEXlang files
   offline. No database connection needed.
4. **Import** — SQLcl connects with your secrets, runs `database/install.sql`,
   then `apex import -input app/<alias> -id 100`.

> **Why the workflow greps the logs:** SQLcl exits with code 0 even when
> `apex validate` or `apex import` fails (compile errors, bad password,
> unknown options). Each step saves SQLcl's output to a log and fails unless it
> contains `Validation successful.` or `Import successful.`. Keep that check if
> you adapt the workflow, or a broken deploy will show up green.

## Setup

**1. Add three repository secrets** — *Settings → Secrets and variables → Actions*:

| Secret | Example | Notes |
|---|---|---|
| `DB_USER` | `MY_APP` | the app's **parsing schema** — least privilege, not SYS/SYSTEM |
| `DB_PASSWORD` | `••••••••` | its password (passed to SQLcl on stdin, never on the command line) |
| `DB_CONNECT` | `db.example.com:1521/FREEPDB1` | `host:port/service` |

**2. Export your app as APEXlang** (SQLcl 26.1.2+, connected as the parsing schema):

```sql
apex export -applicationid 100 -exptype APEXLANG -skipexportdate -dir app -force
```

SQLcl writes the app to `app/<alias>/`, named after the application alias in
lower case (alias `MY-APP` → `app/my-app/`):

```
app/my-app/
├── application.apx
├── pages/               # one .apx file per page
├── shared-components/
├── supporting-objects/
└── deployments/
    └── default.json     # app id (and optionally workspace / parsing schema)
```

`-skipexportdate` keeps diffs clean; `-force` replaces the previous export.

**3. Point the workflow at your app** — in
[`.github/workflows/deploy-apex.yml`](.github/workflows/deploy-apex.yml) set
`APP_DIR` (e.g. `app/my-app`) and `APP_ID`.

**4. Optional schema changes** go in [`database/install.sql`](database/install.sql);
keep it idempotent. It runs before every import and stops the deploy on the
first SQL error.

**5. Push to `main`.** Watch it run under the **Actions** tab.

### Check it locally first

```sql
-- offline, no connection needed
apex validate -input app/my-app

-- connected as the parsing schema
apex import -input app/my-app -id 100
```

## Security

- Credentials live in **GitHub Actions secrets**, never in the repo.
- Connect as the app's parsing schema with only the privileges it needs.
- `concurrency` serialises deploys so two pushes can't import at once.

## License

MIT © Mohamed Harby — see [LICENSE](LICENSE). Built for [harby.dev](https://harby.dev).
