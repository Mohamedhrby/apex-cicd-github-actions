-- Deployment script run by the GitHub Actions pipeline (see
-- .github/workflows/deploy-apex.yml). Runs non-interactively via SQLcl.
--
-- It (1) applies any schema changes, then (2) imports the APEXLang app.
-- Adjust the paths / application id to match your repo.

whenever sqlerror exit failure rollback
set define off
set serveroutput on

prompt === Applying database changes ===
-- Idempotent DDL for the app's schema objects. No-op if you keep it empty.
@@database/install.sql

prompt === Importing APEX application 100 ===
-- Imports the split (APEXLang) export produced by:  apex export -split -dir app/app100
apex import -dir app/app100 -applicationid 100

prompt === Deploy complete ===
exit
