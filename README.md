# Chatwoot Local Setup Guide

## Project overview
You will be running a local fork of **Chatwoot**, an open‑source customer‑communication platform.  
These steps help a novice engineer

* install every prerequisite  
* configure both backend (Ruby on Rails) and frontend (Vue + Vite)  
* launch the full stack on **http://localhost:3000**  
* verify that core features work, including the website widget.

---

## 1. Prerequisites

| Tool | Version | Install command (Ubuntu / WSL2) |
|------|---------|---------------------------------|
| Git, build tools | latest | `sudo apt update && sudo apt upgrade -y && sudo apt install -y git curl gnupg2 build-essential libssl-dev libreadline-dev zlib1g-dev libpq-dev` |
| **Ruby 3.4.4** (via rbenv) | 3.4.4 | see commands in §2 |
| **Bundler** | latest | `gem install bundler` |
| **Node 18** + pnpm 10 | 18.x / 10.2.0 | `curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt install -y nodejs && corepack enable && sudo corepack prepare pnpm@10.2.0 --activate` |
| PostgreSQL 16 + pgvector | 16 | `sudo apt install -y postgresql postgresql-contrib postgresql-16-pgvector` |
| Redis 6 | latest | `sudo apt install -y redis-server` |
| dos2unix | latest | `sudo apt install -y dos2unix` |
| Foreman (Procfile runner) | latest | `gem install foreman` |

> **Why WSL2 or native Linux?** Running Chatwoot inside the Linux filesystem avoids Windows file‑permission and line‑ending issues you will otherwise have to fix later.

---

## 2. Install language runtimes

```bash
# rbenv + ruby-build
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init - bash)"'           >> ~/.bashrc
exec $SHELL

git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
rbenv install 3.4.4
rbenv global 3.4.4

gem install bundler
```

Verify installation:

```bash
ruby -v      # ruby 3.4.4
bundler -v   # Bundler 2.x
node -v      # v18.x
pnpm -v      # 10.2.0
```

---

## 3. Clone the project

```bash
mkdir -p ~/projects
cd ~/projects
git clone https://github.com/<your-github-user>/chatwoot.git
cd chatwoot
```

Avoid cloning to `/mnt/c/...`; staying inside `~/projects` prevents `EPERM` and line‑ending errors.

---

## 4. Fix Windows line endings once

```bash
find . -type f \( -name "*.rb" -o -name "*.js" -o -name "*.vue" -o -name "*.sh" -o -name "Procfile*" \) -exec dos2unix {} +
dos2unix bin/*
chmod +x bin/*
```

---

## 5. Install project dependencies

```bash
# Backend gems
bundle install

# Frontend packages
pnpm install
```

---

## 6. Database and cache setup

1. **Start services**

   ```bash
   sudo service postgresql start
   sudo service redis-server start
   ```

2. **Create a PostgreSQL role that matches your Linux user**

   ```bash
   sudo -u postgres createuser --superuser "$USER"
   createdb "$USER"
   ```

3. **Copy and edit environment variables**

   ```bash
   cp .env.example .env
   nano .env
   ```

   Change only:

   ```dotenv
   POSTGRES_HOST=localhost
   POSTGRES_PORT=5432
   POSTGRES_USERNAME=<your-linux-user>
   POSTGRES_PASSWORD=
   REDIS_URL=redis://localhost:6379
   ```

---

## 7. Initialise the database

```bash
bundle exec rails db:setup
bundle exec rails db:seed   # optional demo data
```

---

## 8. Launch every service

```bash
foreman start -f Procfile.dev
```

You should see three green processes: `backend.1`, `worker.1`, `vite.1`.  
Open **http://localhost:3000** and run through onboarding.

If onboarding is skipped, create an admin user manually:

```bash
bundle exec rails console
user = User.new(email: 'admin@example.com', password: 'Password1!', name: 'Admin')
user.skip_confirmation!
user.save!
```

---

## 9. Smoke‑test core functionality

1. **Log in** with the admin credentials.  
2. Go to **Settings → Inboxes** and create a **Website Inbox**.
3. After the inbox is created, open the **Configure** tab.
4. **Copy the `<script>` snippet provided there** — it contains your unique `websiteToken`.
5. Paste that snippet into a blank `.html` file on your computer (e.g. `test-chatwoot.html`), like this:

    ```html
    <!DOCTYPE html>
    <html>
      <head></head>
      <body>
        <!-- Paste the script here -->
      </body>
    </html>
    ```

6. Open the file in your browser.  
   If the widget loads in the corner of the page, your setup works

---

## 10. Common troubleshooting

| Symptom | Quick fix |
|---------|-----------|
| `'ruby\r': No such file or directory` | Run the **dos2unix** and **chmod** commands in §4, then restart Foreman. |
| `fe_sendauth: no password supplied` | Ensure PostgreSQL role matching your Linux user exists and has superuser privileges. |
| Vite crashes with “port 3036 already in use” | `lsof -ti :3036 | xargs kill -9` then restart Foreman. |
| Redis errors (`ECONNREFUSED`) | `sudo service redis-server restart` then verify with `redis-cli ping`. |
| Yarn vs pnpm conflict | Remove Yarn (`sudo apt remove yarn`) and keep pnpm only. |
| Windows file paths mixed with Linux | Always run the app from the Linux side (`/home/...`), not from `/mnt/c/...`. |

---

## 11. Optional helpers

* **Capture a full terminal log**: `script session.log`, run commands, type `exit`, then convert `session.log` to PDF with `a2ps` or `enscript | ps2pdf`.  
* **Export just your command history**: `history > ~/terminal_history.txt`.

