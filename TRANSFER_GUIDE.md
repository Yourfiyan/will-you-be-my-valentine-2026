# 🔄 Repository Transfer Guide

This document describes all prerequisites and steps required to transfer the following repositories from GitHub user **`Yourfiyan`** to GitHub user **`kohlerfelicita`**.

## 📦 Repositories to Transfer

| # | Repository |
|---|---|
| 1 | `spider-man-tm` |
| 2 | `system-prompts-and-models-of-ai-tools` |
| 3 | `VRINDA` |
| 4 | `my-environment-site-Ambrin-s-creation` |
| 5 | `automatic-invention` |
| 6 | `psychic-engine` |
| 7 | `SEO-CHECKER` |

---

## ✅ Prerequisites

Before initiating any transfer, verify the following:

1. **Admin access** — You must have *Owner* or *Admin* role on each repository you want to transfer.
2. **Target account exists** — Confirm that the GitHub account `kohlerfelicita` exists and is active.
3. **Target account acceptance** — The recipient (`kohlerfelicita`) must accept the transfer invitation within **24 hours** or the transfer expires.
4. **No active GitHub Actions runs** — Cancel or wait for any in-progress workflow runs before transferring.
5. **Third-party integrations noted** — Document all connected apps, webhooks, and Actions secrets **before** transfer, as some may need to be re-configured afterward.

---

## 🚀 Transfer Steps (GitHub Web UI)

Repeat the following steps for **each** of the 7 repositories listed above.

### Step 1 — Open Repository Settings
1. Log in to GitHub as **`Yourfiyan`**.
2. Navigate to `https://github.com/Yourfiyan/<repo-name>`.
3. Click **Settings** (top navigation bar).

### Step 2 — Initiate the Transfer
1. Scroll to the bottom of the Settings page to the **Danger Zone** section.
2. Click **Transfer ownership**.
3. In the dialog:
   - Type the repository name to confirm.
   - Enter the new owner: `kohlerfelicita`.
4. Click **I understand, transfer this repository**.

### Step 3 — Accept the Transfer (Recipient)
1. GitHub sends a transfer invitation email to `kohlerfelicita`.
2. The recipient logs in to GitHub and navigates to their **notifications** or clicks the link in the email.
3. Clicks **Accept transfer**.

> ⚠️ If the invitation is not accepted within **24 hours**, the transfer is automatically cancelled and must be re-initiated.

---

## ⚡ Automation Option (GitHub CLI)

If you prefer scripting the transfers, use the [GitHub CLI](https://cli.github.com/) with the REST API. Run the following commands as `Yourfiyan` (you must be authenticated with `gh auth login`):

```bash
#!/usr/bin/env bash
# Transfer all 7 repositories to kohlerfelicita

NEW_OWNER="kohlerfelicita"

REPOS=(
  "spider-man-tm"
  "system-prompts-and-models-of-ai-tools"
  "VRINDA"
  "my-environment-site-Ambrin-s-creation"
  "automatic-invention"
  "psychic-engine"
  "SEO-CHECKER"
)

for REPO in "${REPOS[@]}"; do
  echo "Transferring $REPO → $NEW_OWNER ..."
  gh api \
    --method POST \
    -H "Accept: application/vnd.github+json" \
    "/repos/Yourfiyan/${REPO}/transfer" \
    -f new_owner="${NEW_OWNER}"
  echo "Done: $REPO"
done
```

> **Note:** The recipient still needs to accept each transfer invitation via email or GitHub notifications.

---

## 🔗 Post-Transfer Updates

After each repository is successfully transferred, perform the following updates:

### 1. Update Local Git Remote URLs

For every local clone of a transferred repository, update the `origin` remote:

```bash
# Replace <repo-name> with the actual repository name
git remote set-url origin https://github.com/kohlerfelicita/<repo-name>.git

# Verify
git remote -v
```

### 2. Update GitHub Actions Secrets & Variables

Actions secrets and environment variables are **not** transferred automatically.

1. In the transferred repository (now under `kohlerfelicita`), go to **Settings → Secrets and variables → Actions**.
2. Re-add any secrets that were configured under `Yourfiyan`.
3. Check workflow files (`.github/workflows/*.yml`) for any hard-coded references to `Yourfiyan` and update them to `kohlerfelicita`.

### 3. Re-configure Webhooks & Integrations

Third-party integrations (e.g., CI/CD services, Slack, deployment platforms) may need to be re-authorised or updated:

1. In the transferred repository, go to **Settings → Webhooks** and verify each webhook URL is still valid.
2. Go to **Settings → Integrations & services** (or **GitHub Apps**) and re-authorise any connected apps.
3. Update any external service (Netlify, Vercel, Heroku, etc.) that was pointing to `Yourfiyan/<repo-name>` to use the new path `kohlerfelicita/<repo-name>`.

### 4. Update README / Documentation Links

Search each transferred repository for any hard-coded links pointing to `https://github.com/Yourfiyan/` and update them to `https://github.com/kohlerfelicita/`.

```bash
# Quick search inside a repo
grep -r "Yourfiyan" . --include="*.md" --include="*.html" --include="*.json"
```

### 5. Notify Collaborators & Contributors

Inform existing collaborators that the repository has moved. They will need to:
- Update their local remote URLs (see Step 1 above).
- Re-accept any team/collaborator invitations if permissions are not carried over.

---

## 📋 Transfer Checklist

Use this checklist for each repository:

- [ ] Verified admin access on source repo (`Yourfiyan`)
- [ ] Confirmed `kohlerfelicita` account exists
- [ ] Documented all secrets, webhooks, and integrations
- [ ] Cancelled any in-progress Actions runs
- [ ] Initiated transfer via Settings → Danger Zone (or CLI script)
- [ ] `kohlerfelicita` accepted the transfer invitation
- [ ] Updated local `git remote` URLs
- [ ] Re-added GitHub Actions secrets & variables
- [ ] Re-configured webhooks & third-party integrations
- [ ] Updated hard-coded `Yourfiyan` links in docs/code
- [ ] Notified collaborators of the new repository location

---

## ℹ️ Additional Notes

- **Stars and watchers** are transferred along with the repository.
- **Issues, pull requests, and wiki pages** are preserved.
- **GitHub Pages** configuration is preserved but may need re-deployment.
- **The old URL** (`github.com/Yourfiyan/<repo>`) will redirect to the new location for a limited time, but this redirect is not permanent — update all links promptly.
- For organisations, the transfer process is the same but you must be an *Owner* of the target organisation.

For further help, refer to the [official GitHub documentation on transferring a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/transferring-a-repository).
