# SQN Shell Quick Reference Card

## Navigation
```
go <path>          go_back            go_up              go_home
where_am_i
```

## Files
```
list [dir]         list_all [dir]     list_big [dir]     list_hidden [dir]
show <file>        edit <file>        read_file <file>   tail_file <file>
make_file <name>   make_folder <name> make_link <t> <n>  make_exec <file>
copy <from> <to>   move <from> <to>   rename <old> <new> delete <target>
find_file <name>   find_text <pat>    find_big [dir]     find_recent [dir]
compress <folder>  extract <file> [dest]
checksum <file>    count_lines <file> count_words <file> count_size [path]
who_owns <file>    give_access <mode> <file>  make_private <file>
```

## System
```
sysinfo            monitor            memory             how_full
whats_running      whats_eating cpu   whats_eating ram
kill_process <t>   stop <t>           restart_proc <name>
reboot_system      shutdown_now
my_user            who_is_here        last_login
```

## Network
```
my_ip              public_ip          am_i_online
scan_network [sub] scan_ports <host>  scan_all_ports <h> scan_services <h>
open_ports         connections        sniff [iface]      sniff_http [iface]
dns_lookup <host>  trace_route <host> grab_page <url>    download <url>
get_headers <url>  send_request <url> post_data <url> <data>
wifi_scan          wifi_connect <ssid> <pass>
proxy_on <url>     proxy_off
```

## Git
```
git_status         git_save [msg]     git_push           git_pull
git_log            git_branch         git_switch <br>    git_new <br>
git_undo           git_diff           git_stash          git_pop
git_clone <url>    git_tag <name>
```

## Security
```
make_password [len]   hash_this <text> [algo]   hash_file <file>
encode_b64 <text>     decode_b64 <text>         encode_url <text>
decode_url <text>     encode_hex <text>         decode_hex <text>
check_ssl <host:port> listen_on <port>          connect_to <host> <port>
```

## Disk
```
list_drives        mount_drive <dev> <path>  unmount_drive <dev>
disk_health <dev>  recover_files             wipe_drive <dev>
clone_drive <s> <d>  image_drive <dev> <img>
```

## SSH/Remote
```
connect_ssh <u@h>  copy_ssh_key <u@h>    make_ssh_key [label]
tunnel <l> <r> <u@h>  reverse_tunnel <r> <l> <u@h>
copy_to_remote <l> <r>  copy_from_remote <r> <l>
sync_to <l> <r>    sync_from <r> <l>     sync_to_dry <l> <r>  sync_from_dry <r> <l>
```

## Phone/ADB
```
phone_connect      phone_shell        phone_reboot       phone_recovery
phone_push <l> <r> phone_pull <r> [d] phone_install <apk> phone_uninstall <pkg>
phone_screenshot   phone_dump_apps    phone_logs         phone_backup
phone_ip           phone_wifi_adb     phone_sideload <z> phone_wipe
phone_flash <part> <img>
```

## Misc
```
calculate <expr>   note <text>        show_notes         what_is <cmd>
my_history         search_history <t> make_qr <text>     weather [city]
time_this <cmd>    clipboard_copy [file]  clipboard_paste
refresh
```

## Engine Commands
```
sqn_shell bootstrap    sqn_shell update       sqn_shell upgrade
sqn_shell status       sqn_shell doctor       sqn_shell clean
sqn_shell unload       sqn_shell reload       sqn_shell run <cmd>
```
