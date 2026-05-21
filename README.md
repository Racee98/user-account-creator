# Linux User Account Creator

A Bash script that automates the creation of Linux user accounts with input validation, optional group assignment, forced password reset on first login, and audit logging.

---

## Features

- Validates the username is not empty, doesn't already exist, and follows proper Linux naming conventions
- Prompts for an optional full name (GECOS comment)
- Optionally assigns the new user to an existing group
- Sets a password interactively
- Forces a password change on first login
- Logs every user creation event to `/var/log/user-audit.log`

---

## Requirements

- Linux system
- Must be run as root or with `sudo`

---

## Usage

```bash
sudo bash create_user.sh
```

The script will prompt you through each step:

```
Enter the username to create: jdoe
Enter full name (optional): John Doe
Enter group to assign (leave blank to skip): developers
New password: ••••••••
Retype new password: ••••••••
✅ Added 'jdoe' to group 'developers'
✅ User 'jdoe' created successfully!
Home directory: /home/jdoe
Password will need to be changed at first login.
📋 Logged to /var/log/user-audit.log
```

---

## How It Works

### 1. Root Check
The script exits immediately if not run with root privileges.

### 2. Username Validation
After prompting for a username, three checks run in order:
- **Empty check** — exits if the input is blank
- **Duplicate check** — exits if the user already exists (`id` command)
- **Format check** — enforces the regex `^[a-z_][a-z0-9_-]*$` (must start with a lowercase letter or underscore, followed by lowercase letters, digits, underscores, or hyphens)

### 3. Full Name / Comment
An optional GECOS field (full name or description) passed to `useradd -c`.

### 4. Group Assignment
If a group name is entered, the script checks whether the group exists using `getent group`. If it does, the user is added with `usermod -aG`. If not, a warning is shown and the step is skipped.

### 5. Account Creation
Runs `useradd -m -c "$COMMENT" "$USERNAME"` to create the user with a home directory.

### 6. Password Setup
Uses `passwd` to set the password interactively, then `chage -d 0` to expire it immediately so the user must change it on first login.

### 7. Audit Logging
Appends a timestamped entry to `/var/log/user-audit.log` in the format:

```
2026-05-20 14:32:01 | USER CREATED | jdoe | by adminuser
```

---

## Log File

| Field | Description |
|-------|-------------|
| Timestamp | Date and time of account creation |
| Action | Always `USER CREATED` |
| Username | The account that was created |
| By | The sudo user who ran the script, or `root` if run directly |

---

## Username Format Rules

Valid usernames must:
- Start with a lowercase letter (`a-z`) or underscore (`_`)
- Contain only lowercase letters, digits, underscores, or hyphens
- Examples: `jdoe`, `john_doe`, `user-1`
