# Hint 1: Where to Look for Backdoors in Marketplace Images

Cloud marketplace images are full operating systems. Attackers hide persistence mechanisms in places that legitimate software also uses, making detection harder. Focus on these locations:

| Persistence Location | What to Check | Command |
|---|---|---|
| **Cron jobs** | User and system crontabs | `crontab -l` and `ls /etc/cron.d/` |
| **SSH authorized_keys** | Pre-installed public keys | `find / -name authorized_keys 2>/dev/null` |
| **sshd_config** | PermitRootLogin, extra AuthorizedKeysFile | `cat /etc/ssh/sshd_config` |
| **systemd services** | Hidden services that auto-start | `systemctl list-unit-files --state=enabled` |
| **init.d scripts** | Legacy startup scripts | `ls /etc/init.d/` |
| **Docker ENTRYPOINT** | Commands that run on container start | `docker inspect --format='{{.Config.Entrypoint}}' <image>` |

Start by running the marketplace image and then auditing it from the inside. Compare the running processes, network connections (`ss -tlnp`), and scheduled tasks against what a clean base image would have.

The `docker history` command shows the layer-by-layer build history of the image, which can reveal when backdoors were added.
