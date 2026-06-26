# SQN Shell v1.0.0

**Sine Qua Non Shell** — A portable, SD-card-resident shell ecosystem for Linux.

> *"The essential condition. Your shell. Your rules."*

---

## What is SQN Shell?

SQN Shell is a portable command environment that lives entirely on an SD card. It provides:

- **Consistent vocabulary** across any Linux machine — plain English commands that work the same everywhere
- **Modern tool wrappers** — automatically uses `eza`, `bat`, `ripgrep`, `fd`, `fzf` when available, falls back gracefully
- **Stateless on host** — nothing installs to the host machine; all state lives on your SD card
- **Distro-agnostic** — works on Debian, Arch, Fedora, Alpine, Void, and anything in between
- **Toolchain detection** — auto-detects Python, C, Rust, Node.js availability per host

---

## Quick Start

### 1. Copy to SD Card

Extract the tarball to your SD card's Linux partition:

```bash
tar -xzf sqn-shell-v1.tar.gz -C /media/yourname/Linux/
```

### 2. Enter the Shell

```bash
cd /media/yourname/Linux/sqn_shell
./sqn
```

Or load into your current shell:

```bash
source /media/yourname/Linux/sqn_shell/sqn
```

### 3. Bootstrap (First Run)

```bash
sqn_shell bootstrap    # Create directories, detect environment
sqn_shell update       # Query GitHub for latest tool versions
sqn_shell upgrade      # Download and install tools
```

---

## Command Reference

### Engine Commands

| Command | Description |
|---------|-------------|
| `sqn_shell bootstrap` | Initialize directory structure and environment |
| `sqn_shell update` | Query upstream for latest tool releases |
| `sqn_shell upgrade` | Download and install/update tools |
| `sqn_shell status` | Show current state and environment |
| `sqn_shell doctor` | Run full diagnostics |
| `sqn_shell clean` | Clear download cache |
| `sqn_shell unload` | Restore host shell state (sourced mode) |
| `sqn_shell reload` | Reload SQN Shell |
| `sqn_shell run <cmd>` | Execute command in SQN environment |

### Language Layer (Plain English Commands)

**Navigation**
- `go <path>` — change directory (or `go home`, `go up`, `go back`)
- `where_am_i` — print working directory

**Files**
- `list`, `list_all`, `list_big`, `list_hidden`
- `show <file>` — display with syntax highlighting
- `find_file <name>`, `find_text <pattern>`
- `copy <from> <to>`, `move <from> <to>`, `delete <target>`
- `compress <folder>`, `extract <file> [dest]`

**System**
- `whats_running`, `whats_eating [cpu|ram]`
- `how_full`, `memory`, `sysinfo`, `monitor`
- `kill_process <PID|name>`, `restart_proc <name>`

**Network**
- `my_ip`, `public_ip`, `am_i_online`
- `scan_ports <host> [range]`, `scan_network [subnet]`
- `download <url>`, `grab_page <url>`

**Git**
- `git_save [message]`, `git_push`, `git_pull`, `git_log`
- `git_switch <branch>`, `git_new <branch>`

**Security**
- `make_password [length]`, `hash_this <text> [algo]`
- `encode_b64 <text>`, `decode_b64 <text>`
- `check_ssl <host:port>`

Type `help` in the shell for the full command reference.

---

## Architecture

```
sqn_shell/
├── sqn              # Main engine (this is what you run)
├── manifest.json    # Tool manifest and metadata
├── bin/
│   ├── x86_64/     # Architecture-specific binaries
│   ├── aarch64/
│   └── armv7/
├── lib/
│   ├── language.sh  # Plain-English command layer
│   └── helpers/     # Modular helper scripts
│       ├── core.sh
│       ├── git.sh
│       └── network.sh
├── cache/           # Download cache
└── docs/            # Documentation
```

---

## Core Guarantees

1. **SD card is the only writable state** — host filesystem is never modified
2. **Host machine is execution-only** — no installation, no persistence on host
3. **Tools always latest upstream** — query GitHub releases dynamically
4. **No local version database** — stateless tool tracking
5. **Safe to run repeatedly** — fully idempotent bootstrap

---

## Security Notes

- All downloads are from official GitHub releases (no third-party mirrors)
- Tool extraction uses temporary directories; partial failures are cleaned up
- Lockfiles prevent concurrent fetch operations
- Subshell RC files are created with `chmod 600` before population
- Destructive operations (`delete`, `wipe_drive`) require explicit confirmation
- `take_ownership` refuses system paths (`/usr`, `/etc`, `/bin`, etc.)
- `calculate` uses AST-safe evaluation (no arbitrary code execution)

---

## Requirements

- Bash 4.0+
- `curl` (for tool fetching)
- `tar`, `unzip` (for extraction)
- Standard POSIX utilities (`grep`, `awk`, `sed`, etc.)

Optional but recommended:
- `git` (for helper functionality)
- `sudo` access (for system commands)

---

## Platform Support

| Platform | Status |
|----------|--------|
| Linux (x86_64) | ✅ Primary |
| Linux (aarch64) | ✅ Supported |
| Linux (armv7) | ✅ Supported |
| Windows | 🔜 Planned |
| Termux (Android) | 🔜 Planned |

---

## License

Personal use. Sine Qua Non is a custom-built personal OS ecosystem.

---

## Changelog

### v1.0.0
- Complete rebrand from Anarchist Terminal to SQN Shell
- Fixed `ANARCHIST`/`ANARCHY` variable naming inconsistency
- Added `_sqn_doctor` diagnostics
- Added `sqn_shell unload` to restore host state
- Added lockfile protection for concurrent fetches
- Added writability checks for all SD card operations
- Fixed `list_hidden` to be color-immune
- Fixed `calculate` to use safe AST evaluation
- Fixed `wipe_drive` with block device and mount validation
- Fixed `phone_wifi_adb` with dynamic interface detection and retry logic
- Added `sync_to_dry` / `sync_from_dry` for safe rsync preview
- Added Wayland clipboard support (`wl-clipboard`)
- Added helper allowlist for security
- Subshell RC files now created with restrictive permissions
