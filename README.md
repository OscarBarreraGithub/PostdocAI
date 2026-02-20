# Safe VS Code + LaTeX Starter (macOS)

This repo is for **macOS only**.
Goal: launch from a desktop icon and always enter the same safer containerized workspace.

## Repo Layout

```text
PocketPostdoc/
  .devcontainer/   # Container definition (kept at repo root)
  .vscode/         # Workspace settings/tasks
  setup/           # Setup scripts and starter LaTeX files
  work/            # Your actual project folders (starts empty)
```

`work/` is intentionally empty at start (tracked with `.gitkeep` only).

## First-Time Setup (once per machine)

```bash
git clone git@github.com:OscarBarreraGithub/PocketPostdoc.git
cd PocketPostdoc
./bootstrap.sh
```

`./bootstrap.sh` delegates to `./setup/bootstrap.sh`.
It installs dependencies, creates desktop launchers, and opens this repo directly in the dev container.
If Xcode Command Line Tools are missing, macOS will prompt once; rerun `./bootstrap.sh` after that install completes.
It also installs zsh command guards so `codex` and `claude` fail outside a dev container.
It also removes local host installs of Codex/Claude VS Code extensions.

Desktop launchers created:

`~/Desktop/Open PocketPostdoc Safe.app` (preferred)

`~/Desktop/Open PocketPostdoc Safe.command` (fallback/debug)

App icon source path:

`setup/assets/icons/appicon.png`

After first setup, users can just double-click that icon.

## Daily Use

1. Double-click `Open PocketPostdoc Safe.app` on Desktop.
2. VS Code opens directly in the dev container for this repo.
3. Create/open your projects inside `work/`.

No manual `Reopen in Container` step is required.

If the launcher only opens Docker Desktop and not VS Code:

```bash
bash ./setup/scripts/install-desktop-launcher-macos.sh
bash ./setup/scripts/open-safe-workspace.sh
```

## Updating an Existing Clone

If you already cloned this repo and want new capabilities:

```bash
cd PocketPostdoc
git pull --ff-only
./bootstrap.sh
```

Then open with the desktop launcher again. If VS Code prompts that container config changed, choose rebuild/reopen.

Notes:

- `work/` is intentionally ignored by Git (except `work/.gitkeep`), so personal project files there do not block pulls.
- If you changed tracked setup files (for example under `setup/` or `.devcontainer/`), Git may still ask you to stash/commit before pulling.

## Safe Agent Workflow

Inside the container terminal, run:

```bash
./setup/scripts/run-agent-safe.sh codex
./setup/scripts/run-agent-safe.sh claude
```

Security model:

- `cwd` is not a security boundary. Agents can `cd`.
- Host safety comes from container isolation: only this repo is bind-mounted from host.
- Extra host mounts should not be added to `.devcontainer/devcontainer.json`.
- Wrapper enforcement: Codex is forced to `--sandbox workspace-write`.
- Wrapper enforcement: Claude must support `--sandbox workspace-write` or it is refused.
- Terminal guard: in zsh shells, `codex` and `claude` are blocked unless running in a dev container.
- Extension guard: on each safe launch, host VS Code uninstalls `openai.chatgpt`, `openai.codex`, and `anthropic.claude-code`.
- Those agent extensions are configured in `.devcontainer/devcontainer.json` to install in container context.

Sanity check:

```bash
./setup/scripts/verify-workspace-sandbox.sh
```

## LaTeX Commands

- Build once: `make -C setup pdf`
- Live rebuild: `make -C setup watch`
- Clean: `make -C setup clean`

## Security Scope

- Agents can modify files in this repo (expected).
- Agents can modify container-local files.
- Host paths outside this repo are not writable unless you explicitly mount them.
- If an extension requires a host-side UI component to function, strict container-only policy may limit or disable that extension.
