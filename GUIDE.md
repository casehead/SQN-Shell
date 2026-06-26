# SQN Shell User Guide

## Table of Contents
1. [Installation](#installation)
2. [First Run](#first-run)
3. [Daily Usage](#daily-usage)
4. [Command Categories](#command-categories)
5. [Tool Management](#tool-management)
6. [Customization](#customization)
7. [Troubleshooting](#troubleshooting)
8. [Advanced Topics](#advanced-topics)

---

## Installation

### SD Card Setup

1. Format an SD card with a Linux-compatible filesystem (ext4 recommended)
2. Mount it (e.g., `/media/yourname/Linux`)
3. Extract SQN Shell:

```bash
cd /media/yourname/Linux
tar -xzf sqn-shell-v1.tar.gz
```

Your directory structure should look like:

```
/media/yourname/Linux/
└── sqn_shell/
    ├── sqn
    ├── manifest.json
    ├── bin/
    ├── lib/
    └── cache/
```

### Optional: Add to PATH

For quick access without typing the full path:

```bash
# Add to your host ~/.bashrc or ~/.bash_profile
alias sqn='/media/yourname/Linux/sqn_shell/sqn'
```

---

## First Run

### Bootstrap

The first time you run SQN Shell on a new machine:

```bash
cd /media/yourname/Linux/sqn_shell
./sqn
```

You'll see a prompt to bootstrap. Type `y`:

```
System not bootstrapped or no tools found.

First-time setup:
  1. sqn_shell bootstrap   - initialize directories
  2. sqn_shell update      - check for latest tools
  3. sqn_shell upgrade     - download and install

Run bootstrap now? [y/N] y
```

### Fetch Tools

After bootstrap, fetch the modern tools:

```bash
sqn_shell update    # Query GitHub for latest releases
sqn_shell upgrade   # Download and install
```

This downloads static binaries for your architecture into `bin/x86_64/` (or `aarch64/`, `armv7/`).

**Note:** This requires internet access and `curl`. It may take a few minutes.

---

## Daily Usage

### Enter the Subshell

```bash
./sqn
```

This launches a clean bash subshell with:
- SQN prompt showing current directory, git branch, and exit code
- All plain-English commands available
- Modern tools in PATH

Type `exit` to return to your host shell.

### Source Mode (Load into Current Shell)

```bash
source ./sqn
```

This loads SQN into your existing shell without launching a subshell. Useful when you want to keep your host shell history and environment.

**To unload:**
```bash
sqn_shell unload
```

### Run a Single Command

```bash
sqn_shell run "go /var/log && list"
```

Or just use the full path:
```bash
/media/yourname/Linux/sqn_shell/sqn_shell run sysinfo
```

---

## Command Categories

### Navigation

```bash
go /var/log        # cd to /var/log
go home            # cd ~
go up              # cd ..
go back            # cd -
where_am_i         # pwd
```

### File Operations

```bash
list                    # ls -la with eza if available
list_hidden             # Show hidden files (color-safe)
show config.txt         # cat with bat syntax highlighting
find_file "*.log"       # Find files by pattern
find_text "ERROR"       # Search file contents

compress myfolder       # Create myfolder.tar.gz
extract archive.tar.gz  # Extract archive
extract file.zip ./dest # Extract to specific directory

checksum file.iso       # sha256sum
count_lines script.sh   # wc -l
count_size /var         # du -sh
```

### System Information

```bash
sysinfo                 # Host, OS, uptime, disk, RAM, CPU
whats_running           # Process list
whats_eating cpu        # Top CPU consumers
whats_eating ram        # Top memory consumers
how_full                # Disk usage (dust if available)
memory                  # RAM usage
monitor                 # btop → htop → top fallback
```

### Network

```bash
my_ip                   # Local IP address
public_ip               # Public IP via ipinfo.io
am_i_online             # Connectivity check

scan_ports 192.168.1.1  # Scan ports 1-1024
scan_all_ports target   # Full port scan
scan_services target    # Service detection

download https://example.com/file.zip
grab_page https://example.com | head
```

### Git

```bash
git_save "Fix login bug"    # git add -A && git commit
git_push                    # git push
git_pull                    # git pull
git_log                     # Pretty log
git_switch main             # git checkout
git_new feature-branch      # git checkout -b
```

### Security

```bash
make_password 32          # Generate strong password
hash_this "secret" sha512 # Hash text
encode_b64 "hello"        # Base64 encode
decode_b64 "aGVsbG8="     # Base64 decode
check_ssl google.com:443  # Check SSL certificate
```

---

## Tool Management

### Check Status

```bash
sqn_shell status
```

Shows:
- SQN version
- Architecture
- Number of installed tools
- SD card free space
- Writable status

### Update Tools

```bash
sqn_shell update   # Build upgrade plan (checks GitHub)
sqn_shell upgrade  # Apply the plan
```

### Diagnostics

```bash
sqn_shell doctor
```

Runs comprehensive checks:
- Environment variables
- Toolchain detection
- Dependency availability
- Smart wrapper integrity
- Installed tools and helpers

### Clean Cache

```bash
sqn_shell clean
```

Removes downloaded archives from `cache/`.

---

## Customization

### Adding Your Own Commands

Edit `lib/language.sh` and add functions:

```bash
my_backup() {
    local dest="${1:-backup_$(date +%Y%m%d).tar.gz}"
    tar -czf "$dest" ~/Documents ~/Pictures
    echo "Backed up to $dest"
}
```

Then reload:
```bash
refresh
```

### Creating Helpers

Add a new file to `lib/helpers/`:

```bash
# lib/helpers/myhelper.sh
my_helper_func() {
    echo "Hello from helper!"
}
```

**Note:** Only known helpers are auto-sourced. Add your helper name to the allowlist in the engine (or the engine will warn and skip it).

### Aliases

Define aliases in your helper files:

```bash
alias sqn_backup='my_backup'
alias sqn_update_dots='git -C ~/.dotfiles pull'
```

---

## Troubleshooting

### "SD card is read-only"

Check mount options:
```bash
mount | grep /media/yourname/Linux
```

If mounted read-only, remount:
```bash
sudo mount -o remount,rw /media/yourname/Linux
```

### "curl not found"

Install curl on the host:
```bash
sudo apt install curl      # Debian/Ubuntu
sudo pacman -S curl        # Arch
sudo dnf install curl      # Fedora
```

### "No tools found for x86_64"

Run the bootstrap and fetch sequence:
```bash
sqn_shell bootstrap
sqn_shell update
sqn_shell upgrade
```

### GitHub API Rate Limit

If you see "API rate limit exceeded":

1. Wait one hour (unauthenticated limit is 60 requests/hour)
2. Or set a GitHub token:
   ```bash
   export GITHUB_TOKEN=your_token_here
   ```
   (Future versions will support this natively)

### Slow Prompt on SD Card

The prompt checks git status. If your SD card is slow:
- Avoid running SQN from inside large git repositories
- Or source the engine instead of using subshell mode

### Conflicts with Host Shell

If SQN overrides something you need:
```bash
sqn_shell unload    # Restore host shell completely
```

---

## Advanced Topics

### Session Logging (Optional)

Set before sourcing:
```bash
export SQN_SESSION_LOG=1
source ./sqn
```

This logs all interactive commands to `sessions/` on your SD card.

### Force Upgrade

To re-download all tools even if they exist:
```bash
SQN_FORCE_UPGRADE=1 sqn_shell upgrade
```

### Custom Architecture Binaries

If you compile tools manually, place them in:
```
bin/x86_64/     # or bin/aarch64/, bin/armv7/
```

SQN will use them automatically.

### Multi-Machine Sync

Your SD card is portable. Just:
1. Plug into new machine
2. Mount the Linux partition
3. Run `./sqn`

Your environment, tools, notes, and custom commands travel with you.

---

## Tips

1. **Use tab completion** where available — bash will complete filenames and some commands
2. **Type `help`** anytime for the full command reference
3. **Use `sqn_shell doctor`** when something seems wrong
4. **Keep notes** with the `note` command: `note Remember to update kernel`
5. **Check `show_notes`** to review your notes

---

## Support

SQN Shell is a personal project. For issues, check:
1. `sqn_shell doctor` output
2. `sqn_shell status` output
3. The log file: `sqn.log` in your SQN root

---

*Sine Qua Non — The essential condition.*
