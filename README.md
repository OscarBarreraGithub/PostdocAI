# Safe VS Code + LaTeX Starter (macOS)

This repo is for **macOS only**.
Goal: a user can launch from a desktop icon and always enter the same safer containerized workspace.

## First-Time Setup (once per machine)

```bash
git clone <your-repo-url>
cd PostdocAI
./bootstrap.sh
```

`./bootstrap.sh` installs dependencies, creates a desktop launcher icon, and opens this repo directly in the dev container.
If Xcode Command Line Tools are missing, macOS will prompt once; rerun `./bootstrap.sh` after that install completes.
It also installs zsh command guards so `codex` and `claude` fail outside a dev container.
It also removes local host installs of Codex/Claude VS Code extensions.

Desktop icon created:

`~/Desktop/Open PostdocAI Safe.command`

After first setup, users can just double-click that icon.

## Daily Use

1. Double-click `Open PostdocAI Safe.command` on Desktop.
2. VS Code opens directly in the dev container for this repo.

No manual `Reopen in Container` step is required.

## Safe Agent Workflow

Inside the container terminal, run:

```bash
./scripts/run-agent-safe.sh codex
./scripts/run-agent-safe.sh claude
```

Security model:

- `cwd` is not a security boundary. Agents can `cd`.
- Host safety comes from container isolation:
  - only this repo is bind-mounted from host.
  - no extra host mounts should be added to `.devcontainer/devcontainer.json`.
- Wrapper enforcement:
  - Codex is forced to `--sandbox workspace-write`.
  - Claude must support `--sandbox workspace-write` or it is refused.
- Terminal guard:
  - In zsh shells, `codex` and `claude` are blocked unless running in a dev container.
- Extension guard:
  - On each safe launch, host VS Code uninstalls `openai.chatgpt`, `openai.codex`, and `anthropic.claude-code`.
  - These extensions are configured in `.devcontainer/devcontainer.json` so they install in container context.

Sanity check:

```bash
./scripts/verify-workspace-sandbox.sh
```

## LaTeX Commands

- Build once: `make pdf`
- Live rebuild: `make watch`
- Clean: `make clean`

## Security Scope

- Agents can modify files in this repo (expected).
- Agents can modify container-local files.
- Host paths outside this repo are not writable unless you explicitly mount them.
- If an extension requires a host-side UI component to function, strict container-only policy may limit or disable that extension.
