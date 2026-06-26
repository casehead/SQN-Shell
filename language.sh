#!/bin/bash
# ============================================================
#  SQN Language Layer — Linux
#  Sine Qua Non Shell v1.0.0
#  Plain English. Snake_case. Real bash.
#  Loaded by SQN Shell engine.
# ============================================================
#  TODO: Theme-aware color output per command
#  TODO: Alias persistence — sqn alias save/load
#  TODO: Process chaining — pipe plain commands together
#  TODO: Per-command help strings (sqn explain <cmd>)
#  TODO: Tab completion for plain-English commands
#  TODO: sqn record — record a session as a replayable script
# ============================================================

# ============================================================
# GUARD — must be loaded inside SQN environment
# ============================================================
if [[ -z "${SQN_ROOT:-}" ]]; then
    echo "ERROR: language.sh must be loaded by sqn, not run directly." >&2
    exit 1
fi

# ============================================================
# NAVIGATION
# ============================================================
go()            { cd "${1:-~}" && pwd; }
go_back()       { cd - && pwd; }
go_up()         { cd .. && pwd; }
go_home()       { cd ~ && pwd; }
go_root()       { cd /; }
where_am_i()    { pwd; }

# ============================================================
# FILES & FOLDERS
# ============================================================
list()          { _sqn_ls_smart "${1:-.}"; }
list_all()      { _sqn_ls_smart -a "${1:-.}"; }
list_big()      { _sqn_du_smart "${1:-.}" | head -20; }
list_hidden()   { find "${1:-.}" -maxdepth 1 -name ".*" -not -name "." 2>/dev/null; }

show()          { _sqn_cat_smart "${1:?Usage: show <file>}"; }
edit()          { "${EDITOR:-nano}" "${1:?Usage: edit <file>}"; }
read_file()     { less "${1:?Usage: read_file <file>}"; }
tail_file()     { tail -f "${1:?Usage: tail_file <file>}"; }
head_file()     { head -n "${2:-20}" "${1:?Usage: head_file <file>}"; }

make_file()     { touch "${1:?Usage: make_file <name>}" && echo "Created: $1"; }
make_folder()   { mkdir -p "${1:?Usage: make_folder <name>}" && echo "Created: $1"; }
make_link()     { ln -s "${1:?}" "${2:?Usage: make_link <target> <name>}"; }
make_exec()     { chmod +x "${1:?Usage: make_exec <file>}" && echo "Executable: $1"; }

copy()          { cp -r "${1:?}" "${2:?Usage: copy <from> <to>}" && echo "Copied."; }
move()          { mv "${1:?}" "${2:?Usage: move <from> <to>}" && echo "Moved."; }
rename()        { mv "${1:?}" "${2:?Usage: rename <old> <new>}" && echo "Renamed."; }
delete()        {
    [[ -z "${1:-}" ]] && echo "Delete what?" && return 1
    echo -n "Delete '$1'? [y/N] " && read -r c
    [[ "$c" =~ ^[Yy]$ ]] && rm -rf "$1" && echo "Deleted." || echo "Cancelled."
}

find_file()     { _sqn_find_smart "${1:?Usage: find_file <name>}" "${2:-.}"; }
find_text()     { _sqn_grep_smart -rn "${1:?Usage: find_text <pattern>}" "${2:-.}" 2>/dev/null; }
find_big()      { find "${1:-.}" -type f -size +100M 2>/dev/null | sort; }
find_recent()   { find "${1:-.}" -type f -mtime -1 2>/dev/null | sort; }
find_empty()    { find "${1:-.}" -empty 2>/dev/null; }

compress()      {
    local src="${1:?Usage: compress <folder>}"
    local dest="${src}.tar.gz"
    if [[ -f "$dest" ]]; then
        echo -n "Archive '$dest' exists. Overwrite? [y/N] " && read -r c
        [[ "$c" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }
    fi
    tar -czf "$dest" "$src" && echo "Compressed: $dest"
}

extract()       {
    local f="${1:?Usage: extract <file>}"
    local dest="${2:-}"
    [[ -n "$dest" ]] && mkdir -p "$dest"
    case "$f" in
        *.tar.gz|*.tgz)     tar -xzf "$f" ${dest:+-C "$dest"} ;;
        *.tar.bz2)          tar -xjf "$f" ${dest:+-C "$dest"} ;;
        *.tar.xz)           tar -xJf "$f" ${dest:+-C "$dest"} ;;
        *.zip)              unzip "$f" ${dest:+-d "$dest"} ;;
        *.7z)               7z x "$f" ${dest:+-o"$dest"} ;;
        *.gz)               gunzip "$f" ;;
        *.bz2)              bunzip2 "$f" ;;
        *.rar)              unrar x "$f" ${dest:+"$dest"} 2>/dev/null || echo "Install unrar." ;;
        *)                  echo "Unknown format: $f" ;;
    esac
}

checksum()      { sha256sum "${1:?Usage: checksum <file>}"; }
count_lines()   { wc -l "${1:?Usage: count_lines <file>}"; }
count_words()   { wc -w "${1:?Usage: count_words <file>}"; }
count_size()    { du -sh "${1:-.}"; }

who_owns()      { stat -c '%U:%G %n' "${1:?Usage: who_owns <file>}"; }
give_access()   { chmod "${1:?}" "${2:?Usage: give_access <mode> <file>}"; }
make_private()  { chmod 600 "${1:?Usage: make_private <file>}"; }
take_ownership(){
    local path="${1:?Usage: take_ownership <path>}"
    # Safety: refuse system paths
    case "$path" in
        /|/usr|/usr/*|/etc|/etc/*|/bin|/bin/*|/lib|/lib/*|/sbin|/sbin/*)
            echo "ERROR: Refusing to chown system path: $path" >&2
            return 1
            ;;
    esac
    sudo chown -R "$USER" "$path"
}

# ============================================================
# SYSTEM
# ============================================================
whats_running() { _sqn_ps_smart; }
whats_eating()  {
    case "${1:-cpu}" in
        ram|mem|memory) ps aux --sort=-%mem | head -15 ;;
        *)              ps aux --sort=-%cpu | head -15 ;;
    esac
}
how_full()      { _sqn_df_smart; }
memory()        { free -h 2>/dev/null || vm_stat 2>/dev/null || echo "N/A"; }
sysinfo()       {
    echo "Host:    $(hostname)"
    echo "OS:      $(uname -srm)"
    echo "Distro:  ${SQN_DISTRO:-unknown}"
    echo "Uptime:  $(uptime -p 2>/dev/null || uptime)"
    echo "Disk:    $(df -h / | tail -1)"
    echo "RAM:     $(free -h 2>/dev/null | awk '/Mem/{print $2" total, "$3" used"}' || echo 'N/A')"
    echo "CPU:     $(nproc) cores"
    echo "Display: ${SQN_DISPLAY:-unknown}"
}
monitor()       { btop 2>/dev/null || htop 2>/dev/null || top; }
reboot_system() { sudo reboot; }
shutdown_now()  { sudo shutdown -h now; }
who_is_here()   { who; }
last_login()    { last -n 10; }
my_user()       { whoami && id; }
run_as_root()   { sudo "${@:?}"; }
switch_user()   { su "${1:?Usage: switch_user <username>}"; }

kill_process()  {
    local t="${1:?Usage: kill_process <PID or name>}"
    [[ "$t" =~ ^[0-9]+$ ]] && command kill "$t" || pkill -f "$t"
}
stop()          { kill_process "$@"; }
restart_proc()  {
    local proc="${1:?Usage: restart_proc <name>}"
    stop "$proc"
    # Wait for process to actually die (with timeout)
    local count=0
    while pgrep -f "$proc" >/dev/null 2>&1 && [[ $count -lt 30 ]]; do
        sleep 0.5
        ((count++))
    done
    "$proc" &
    disown
    echo "Restarted: $proc (PID: $!)"
}

# ============================================================
# NETWORK
# ============================================================
my_ip()         { hostname -I | awk '{print $1}'; }
public_ip()     { curl -s https://ipinfo.io/ip && echo; }
am_i_online()   { ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && echo "✓ Online" || echo "✗ Offline"; }

scan_network()  {
    local subnet="${1:-192.168.1.0/24}"
    if command -v nmap >/dev/null; then nmap -sn "$subnet"
    elif command -v arp-scan >/dev/null; then sudo arp-scan "$subnet"
    else echo "Install nmap or arp-scan."; fi
}
scan_ports()    {
    local target="${1:?Usage: scan_ports <host>}" range="${2:-1-1024}"
    command -v nmap >/dev/null && nmap -p "$range" "$target" || echo "Install nmap."
}
scan_all_ports(){ command -v nmap >/dev/null && nmap -p- "${1:?Usage: scan_all_ports <host>}" || echo "Install nmap."; }
scan_services() { nmap -sV "${1:?Usage: scan_services <host>}"; }
scan_vuln()     { nmap --script vuln "${1:?Usage: scan_vuln <host>}"; }
scan_os()       { sudo nmap -O "${1:?Usage: scan_os <host>}"; }

open_ports()    { ss -tulnp; }
connections()   { ss -tunp; }
sniff()         { sudo tcpdump -i "${1:-eth0}" -n "${2:-}" 2>/dev/null || echo "Install tcpdump."; }
sniff_http()    { sudo tcpdump -i "${1:-eth0}" -A -s 0 'tcp port 80 or tcp port 443'; }
dns_lookup()    { nslookup "${1:?Usage: dns_lookup <host>}" && dig "${1}" 2>/dev/null || true; }
trace_route()   { traceroute "${1:?Usage: trace_route <host>}" 2>/dev/null || tracepath "$1"; }
grab_page()     { curl -sL "${1:?Usage: grab_page <url>}"; }
download()      { curl -L -O "${1:?Usage: download <url>}"; }
download_to()   { curl -L -o "${2:?}" "${1:?Usage: download_to <url> <filename>}"; }
get_headers()   { curl -sI "${1:?Usage: get_headers <url>}"; }
send_request()  { curl -s "${1:?Usage: send_request <url>}"; }
post_data()     { curl -s -X POST -d "${2:?}" "${1:?Usage: post_data <url> <data>}"; }

wifi_scan()     { nmcli dev wifi list 2>/dev/null || iwlist scan 2>/dev/null || echo "No wifi tools found."; }
wifi_connect()  { nmcli dev wifi connect "${1:?}" password "${2:?Usage: wifi_connect <ssid> <pass>}"; }
proxy_on()      { export http_proxy="$1" https_proxy="$1" && echo "Proxy set: $1"; }
proxy_off()     { unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY && echo "Proxy cleared."; }

# ============================================================
# SECURITY
# ============================================================
make_password() {
    local len="${1:-20}"
    LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c "$len"; echo
}
hash_this()     {
    case "${2:-sha256}" in
        md5)    echo -n "$1" | md5sum ;;
        sha1)   echo -n "$1" | sha1sum ;;
        sha256) echo -n "$1" | sha256sum ;;
        sha512) echo -n "$1" | sha512sum ;;
    esac
}
hash_file()     { sha256sum "${1:?Usage: hash_file <file>}"; }
encode_b64()    { echo -n "${1:?}" | base64; }
decode_b64()    { echo -n "${1:?}" | base64 -d; }
encode_url()    { python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "${1:?}"; }
decode_url()    { python3 -c "import urllib.parse,sys; print(urllib.parse.unquote(sys.argv[1]))" "${1:?}"; }
encode_hex()    { echo -n "${1:?}" | xxd -p; }
decode_hex()    { echo -n "${1:?}" | xxd -r -p; }
check_ssl()     { echo | openssl s_client -connect "${1:?Usage: check_ssl <host:port>}" 2>/dev/null | openssl x509 -noout -dates -subject; }
listen_on()     { nc -lvnp "${1:?Usage: listen_on <port>}"; }
connect_to()    { nc "${1:?}" "${2:?Usage: connect_to <host> <port>}"; }

# ============================================================
# CODE / DEV — engine-aware, uses detected toolchains
# ============================================================
run_script()    { bash "${1:?Usage: run_script <file>}" "${@:2}"; }

run_python()    {
    [[ "${SQN_PYTHON:-no}" == "no" ]] && echo "Python not found on this system." && return 1
    "$SQN_PYTHON_BIN" "${1:?Usage: run_python <file>}" "${@:2}"
}
run_c()         {
    [[ "${SQN_C:-no}" == "no" ]] && echo "C compiler not found on this system." && return 1
    local src="${1:?Usage: run_c <file.c>}"
    local out="${src%.c}"
    "$SQN_C_BIN" -o "$out" "$src" && echo "Built: $out" && "$out" "${@:2}"
}
build_c()       {
    [[ "${SQN_C:-no}" == "no" ]] && echo "C compiler not found on this system." && return 1
    local src="${1:?Usage: build_c <file.c>}"
    local out="${2:-${src%.c}}"
    "$SQN_C_BIN" -o "$out" "$src" && echo "Built: $out"
}
run_rust()      {
    [[ "${SQN_RUST:-no}" == "no" ]] && echo "Rust not found on this system." && return 1
    "$SQN_RUST_BIN" "${1:?Usage: run_rust <file.rs>}" -o /tmp/sqn_rust_out && /tmp/sqn_rust_out "${@:2}"
}
cargo_run()     {
    [[ -z "${SQN_CARGO_BIN:-}" ]] && echo "Cargo not found on this system." && return 1
    "$SQN_CARGO_BIN" run "${@}"
}
cargo_build()   {
    [[ -z "${SQN_CARGO_BIN:-}" ]] && echo "Cargo not found on this system." && return 1
    "$SQN_CARGO_BIN" build "${@}"
}
run_node()      { node "${1:?Usage: run_node <file>}" "${@:2}"; }

install()       { _sqn_pkg_install "$@"; }
uninstall()     { _sqn_pkg_remove "$@"; }
update_system() { _sqn_pkg_update; }
search_package(){ _sqn_pkg_search "$@"; }

start_server()  { python3 -m http.server "${1:-8080}"; }
start_php()     { php -S "0.0.0.0:${1:-8080}"; }

# ============================================================
# GIT
# ============================================================
git_status()    { git status; }
git_save()      { git add -A && git commit -m "${1:-update}"; }
git_push()      { git push; }
git_pull()      { git pull; }
git_log()       { git log --oneline --graph --decorate -20; }
git_branch()    { git branch -a; }
git_switch()    { git checkout "${1:?Usage: git_switch <branch>}"; }
git_new()       { git checkout -b "${1:?Usage: git_new <branch>}"; }
git_undo()      { git reset HEAD~1; }
git_diff()      { git diff; }
git_stash()     { git stash; }
git_pop()       { git stash pop; }
git_clone()     { git clone "${1:?Usage: git_clone <url>}"; }
git_tag()       { git tag "${1:?Usage: git_tag <name>}"; }

# ============================================================
# DISK & DRIVES
# ============================================================
list_drives()   { lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE; }
mount_drive()   { sudo mount "${1:?}" "${2:?Usage: mount_drive <device> <path>}"; }
unmount_drive() { sudo umount "${1:?Usage: unmount_drive <device or path>}"; }
disk_health()   { sudo smartctl -a "${1:?Usage: disk_health <device>}" 2>/dev/null || echo "Install smartmontools."; }
recover_files() { sudo testdisk 2>/dev/null || echo "Install testdisk."; }
wipe_drive()    {
    local dev="${1:?Usage: wipe_drive <device>}"
    # Safety checks
    if [[ ! -b "$dev" ]]; then
        echo "ERROR: '$dev' is not a block device." >&2
        return 1
    fi
    if grep -q "$dev" /proc/mounts 2>/dev/null; then
        echo "ERROR: '$dev' is currently mounted. Unmount first." >&2
        return 1
    fi
    echo -n "WIPE $dev? IRREVERSIBLE [y/N] " && read -r c
    if [[ "$c" =~ ^[Yy]$ ]]; then
        sudo dd if=/dev/zero of="$dev" bs=4M status=progress
        sync
        echo "Wiped."
    else
        echo "Cancelled."
    fi
}
clone_drive()   { sudo dd if="${1:?}" of="${2:?Usage: clone_drive <src> <dst>}" bs=4M status=progress; }
image_drive()   { sudo dd if="${1:?}" of="${2:?Usage: image_drive <device> <file.img>}" bs=4M status=progress; }

# ============================================================
# LOGS
# ============================================================
show_logs()     { sudo journalctl -n "${1:-50}" --no-pager; }
follow_logs()   { sudo journalctl -f; }
show_errors()   { sudo journalctl -p err -n 50 --no-pager; }
show_auth()     { sudo journalctl -u ssh -n 50 --no-pager 2>/dev/null || sudo tail -50 /var/log/auth.log 2>/dev/null; }
clear_logs()    { sudo journalctl --vacuum-time=1d; }

# ============================================================
# SSH & REMOTE
# ============================================================
connect_ssh()       { ssh "${1:?Usage: connect_ssh <user@host>}"; }
copy_ssh_key()      { ssh-copy-id "${1:?Usage: copy_ssh_key <user@host>}"; }
make_ssh_key()      { ssh-keygen -t ed25519 -C "${1:-sqn}"; }
tunnel()            { ssh -L "${1:?}:localhost:${2:?}" "${3:?Usage: tunnel <lport> <rport> <user@host>}"; }
reverse_tunnel()    { ssh -R "${1:?}:localhost:${2:?}" "${3:?Usage: reverse_tunnel <rport> <lport> <user@host>}"; }
copy_to_remote()    { scp -r "${1:?}" "${2:?Usage: copy_to_remote <local> <user@host:path>}"; }
copy_from_remote()  { scp -r "${1:?}" "${2:?Usage: copy_from_remote <user@host:path> <local>}"; }
sync_to()           { rsync -avh --progress "${1:?}" "${2:?Usage: sync_to <local> <remote>}"; }
sync_from()         { rsync -avh --progress "${1:?}" "${2:?Usage: sync_from <remote> <local>}"; }
sync_to_dry()       { rsync -avh --progress --dry-run --itemize-changes "${1:?}" "${2:?}"; }
sync_from_dry()     { rsync -avh --progress --dry-run --itemize-changes "${1:?}" "${2:?}"; }

# ============================================================
# PHONE / ADB
# ============================================================
phone_connect()     { adb devices; }
phone_shell()       { adb shell; }
phone_reboot()      { adb reboot; }
phone_recovery()    { adb reboot recovery; }
phone_bootloader()  { adb reboot bootloader; }
phone_push()        { adb push "${1:?}" "${2:?Usage: phone_push <local> <remote>}"; }
phone_pull()        { adb pull "${1:?}" "${2:-.}"; }
phone_install()     { adb install "${1:?Usage: phone_install <apk>}"; }
phone_uninstall()   { adb uninstall "${1:?Usage: phone_uninstall <package>}"; }
phone_screenshot()  { adb exec-out screencap -p > "screenshot_$(date +%s).png" && echo "Saved."; }
phone_dump_apps()   { adb shell pm list packages -3; }
phone_logs()        { adb logcat; }
phone_backup()      {
    echo "WARNING: adb backup is deprecated on Android 12+. Consider adb shell + tar instead."
    adb backup -apk -shared -all -f "phone_backup_$(date +%Y%m%d).ab"
}
phone_ip()          { adb shell ip addr show wlan0 2>/dev/null | grep 'inet ' || adb shell ip addr show 2>/dev/null | grep 'inet ' | head -1; }
phone_wifi_adb()    {
    # Detect active interface dynamically
    local ip
    ip=$(adb shell ip route 2>/dev/null | awk '/wlan|eth/{print $5}' | head -1)
    if [[ -z "$ip" ]]; then
        ip=$(adb shell ip addr show wlan0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)
    fi
    if [[ -z "$ip" ]]; then
        echo "ERROR: Could not detect device IP." >&2
        return 1
    fi
    adb tcpip 5555
    sleep 2
    local retries=0
    while [[ $retries -lt 5 ]]; do
        if adb connect "${ip}:5555"; then
            echo "Connected wireless: $ip"
            return 0
        fi
        sleep 1
        ((retries++))
    done
    echo "ERROR: Failed to connect wirelessly after $retries attempts." >&2
    return 1
}
phone_sideload()    { adb sideload "${1:?Usage: phone_sideload <zip>}"; }
phone_wipe()        { fastboot -w && echo "Device wiped."; }
phone_flash()       { fastboot flash "${1:?}" "${2:?Usage: phone_flash <partition> <image>}"; }

# ============================================================
# PROCESSES & JOBS
# ============================================================
run_background()    { "${@:?Usage: run_background <command>}" & echo "PID: $!"; disown $!; }
jobs_running()      { jobs -l; }
bring_forward()     { fg "${1:-}"; }
send_back()         { bg "${1:-}"; }
watch_this()        { watch -n "${2:-2}" "${1:?Usage: watch_this <command>}"; }
wait_for()          { wait "${1:?Usage: wait_for <PID>}"; }

# ============================================================
# MISC
# ============================================================
calculate()         {
    local expr="${*:?Usage: calculate <expression>}"
    # Safe math evaluation using Python's ast
    python3 -c "
import ast, sys
try:
    node = ast.parse('$expr', mode='eval')
    # Only allow numeric operations
    allowed = (ast.Expression, ast.BinOp, ast.UnaryOp, ast.Num, ast.Constant,
               ast.Add, ast.Sub, ast.Mult, ast.Div, ast.Pow, ast.Mod,
               ast.USub, ast.UAdd, ast.FloorDiv)
    for n in ast.walk(node):
        if not isinstance(n, allowed):
            print('ERROR: Only numeric operations allowed', file=sys.stderr)
            sys.exit(1)
    result = eval(compile(node, '<string>', 'eval'))
    print(result)
except Exception as e:
    print(f'ERROR: {e}', file=sys.stderr)
    sys.exit(1)
"
}

note()              {
    if [[ ! -w "$SQN_ROOT" ]]; then
        echo "ERROR: SD card is read-only. Cannot save note." >&2
        return 1
    fi
    echo "[$(date '+%Y-%m-%d %H:%M')] ${*}" >> "$SQN_ROOT/notes.txt" && echo "Saved."
}
show_notes()        { _sqn_cat_smart "$SQN_ROOT/notes.txt" 2>/dev/null || echo "No notes yet."; }
what_is()           { tldr "${1:?}" 2>/dev/null || man "${1}" 2>/dev/null || echo "No docs found for: $1"; }
my_history()        { command history | tail -50; }
search_history()    { command history | grep "${1:?Usage: search_history <term>}"; }
make_qr()           {
    if command -v qrencode >/dev/null; then
        qrencode -t ansiutf8 "${1:?Usage: make_qr <text>}"
    else
        echo "qrencode not found. Install with: install qrencode" >&2
        return 1
    fi
}
weather()           { curl -s "wttr.in/${1:-}" | head -40; }
time_this()         { time "${@:?Usage: time_this <command>}"; }

clipboard_copy()    {
    if command -v wl-copy >/dev/null; then
        cat "${1:-/dev/stdin}" | wl-copy && echo "Copied."
    elif command -v xclip >/dev/null; then
        cat "${1:-/dev/stdin}" | xclip -selection clipboard && echo "Copied."
    elif command -v pbcopy >/dev/null; then
        cat "${1:-/dev/stdin}" | pbcopy && echo "Copied."
    else
        echo "No clipboard tool found. Install wl-clipboard (Wayland) or xclip (X11)." >&2
        return 1
    fi
}

clipboard_paste()   {
    if command -v wl-paste >/dev/null; then wl-paste
    elif command -v xclip >/dev/null; then xclip -selection clipboard -o
    else echo "No clipboard tool found." >&2; return 1; fi
}

refresh()           { source "$SQN_ROOT/sqn" && echo "SQN Shell reloaded."; }

# ============================================================
# HELP — language layer index
# ============================================================
help() {
    echo -e "\033[1;36mSQN Shell v${SQN_VERSION} — Command Reference\033[0m"
    echo ""
    echo -e "\033[1;33mNAVIGATION\033[0m"
    echo "  go <path>          go_back        go_up         go_home"
    echo "  where_am_i"
    echo ""
    echo -e "\033[1;33mFILES\033[0m"
    echo "  list  list_all  list_big  list_hidden  show  edit  read_file"
    echo "  make_file  make_folder  make_link  make_exec"
    echo "  copy  move  rename  delete"
    echo "  find_file  find_text  find_big  find_recent  find_empty"
    echo "  compress  extract  checksum"
    echo "  count_lines  count_words  count_size"
    echo "  who_owns  give_access  make_private  take_ownership"
    echo ""
    echo -e "\033[1;33mSYSTEM\033[0m"
    echo "  sysinfo  monitor  memory  how_full"
    echo "  whats_running  whats_eating [cpu|ram]"
    echo "  kill_process  stop  restart_proc"
    echo "  reboot_system  shutdown_now"
    echo "  my_user  who_is_here  last_login  switch_user  run_as_root"
    echo ""
    echo -e "\033[1;33mNETWORK\033[0m"
    echo "  my_ip  public_ip  am_i_online"
    echo "  scan_network  scan_ports  scan_all_ports  scan_services  scan_vuln  scan_os"
    echo "  open_ports  connections  sniff  sniff_http"
    echo "  dns_lookup  trace_route  grab_page  download  download_to"
    echo "  get_headers  send_request  post_data"
    echo "  wifi_scan  wifi_connect  proxy_on  proxy_off"
    echo ""
    echo -e "\033[1;33mSECURITY\033[0m"
    echo "  make_password  hash_this  hash_file  check_ssl"
    echo "  encode_b64  decode_b64  encode_url  decode_url  encode_hex  decode_hex"
    echo "  listen_on  connect_to"
    echo ""
    echo -e "\033[1;33mCODE / DEV  [Python:${SQN_PYTHON:-?} | C:${SQN_C:-?} | Rust:${SQN_RUST:-?}]\033[0m"
    echo "  run_script  run_python  run_c  build_c  run_rust  cargo_run  cargo_build  run_node"
    echo "  install  uninstall  update_system  search_package"
    echo "  start_server  start_php"
    echo ""
    echo -e "\033[1;33mGIT\033[0m"
    echo "  git_status  git_save  git_push  git_pull  git_log"
    echo "  git_branch  git_switch  git_new  git_undo  git_diff"
    echo "  git_stash  git_pop  git_clone  git_tag"
    echo ""
    echo -e "\033[1;33mDISK\033[0m"
    echo "  list_drives  mount_drive  unmount_drive  disk_health"
    echo "  recover_files  wipe_drive  clone_drive  image_drive"
    echo ""
    echo -e "\033[1;33mLOGS\033[0m"
    echo "  show_logs  follow_logs  show_errors  show_auth  clear_logs"
    echo ""
    echo -e "\033[1;33mSSH / REMOTE\033[0m"
    echo "  connect_ssh  copy_ssh_key  make_ssh_key  tunnel  reverse_tunnel"
    echo "  copy_to_remote  copy_from_remote  sync_to  sync_from"
    echo "  sync_to_dry  sync_from_dry"
    echo ""
    echo -e "\033[1;33mPHONE / ADB\033[0m"
    echo "  phone_connect  phone_shell  phone_reboot  phone_recovery  phone_bootloader"
    echo "  phone_push  phone_pull  phone_install  phone_uninstall  phone_screenshot"
    echo "  phone_dump_apps  phone_logs  phone_backup  phone_ip  phone_wifi_adb"
    echo "  phone_sideload  phone_wipe  phone_flash"
    echo ""
    echo -e "\033[1;33mMISC\033[0m"
    echo "  calculate  note  show_notes  what_is  my_history  search_history"
    echo "  make_qr  weather  time_this  clipboard_copy  clipboard_paste"
    echo "  refresh"
    echo ""
    echo -e "  \033[1;32msqn_shell help\033[0m for engine controls"
}
