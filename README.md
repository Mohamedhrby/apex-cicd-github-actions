# GitHub Actions deploy pipeline for APEX

![License: MIT](https://img.shields.io/badge/License-MIT-informational) [![harby.dev](https://img.shields.io/badge/harby.dev-templates-C74634)](https://harby.dev/templates) ![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white) ![SQLcl](https://img.shields.io/badge/Oracle-SQLcl-F80000?logo=oracle&logoColor=white)

A ready-to-use workflow that imports an **APEXLang** (file-based) APEX app into
your database on **every push to `main`** — using SQLcl and encrypted secrets.
Companion to [CI/CD for APEX with GitHub Actions](https://harby.dev/learn/ci-cd-apex-github-actions) on harby.dev.

## How it works

1. Push to `main` (or run it manually from the **Actions** tab).
2. The runner checks out your repo, installs Java + SQLcl.
3. SQLcl connects with your secrets and runs [`deploy.sql`](deploy.sql), which
   applies `database/install.sql` then imports the app under `app/app100`.

## Setup

**1. Add three repository secrets** — *Settings → Secrets and variables → Actions*:

| Secret | Example | Notes |
|---|---|---|
| `DB_URL` | `db.example.com:1521/FREEPDB1` | `host:port/service` |
| `DB_USER` | `DEPLOY` | a **least-privilege** deploy user, not SYS |
| `DB_PWD` | `••••••••` | its password |

**2. Put your app in the repo** as a split export:

```sql
apex export -applicationid 100 -split -dir app/app100
```

**3. Adjust `deploy.sql`** if your application id or directory differ.

**4. Push to `main`.** Watch it run under the **Actions** tab.

## Security

- Credentials live in **GitHub Actions secrets**, never in the repo.
- Use a dedicated deploy user with only the privileges it needs (import into its
  own workspace/parsing schema).
- `concurrency` serialises deploys so two pushes can't import at once.

## Requires

A reachable Oracle Database + ORDS/APEX (e.g. the
[Dockerized 26ai + APEX stack](https://github.com/Mohamedhrby/oracle-26ai-apex-docker),
exposed to the runner or on a self-hosted runner inside your network).

## License

MIT © Mohamed Harby — see [LICENSE](LICENSE). Built for [harby.dev](https://harby.dev).
