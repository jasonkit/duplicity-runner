# duplicity-runner

A Makefile for running duplicity.

## Dependency

- duplicity
- GNU Make
- fzf
- jq

## Usage

- `make backup`
  - Run backup on all backup entry defined in setting.json
- `make backup-single`
  - Select and run backup on specific backup entry defined in setting.json
- `make restore-file [to=PATH_FOR_RESTORE_DESTINATION]`
  - Select and backup and file to restore

## setting.json

```js
{
  "encrypt_key_id": "Your GPG Key ID for encryption",
  "sign_key_id": "Your GPG Key ID for signing",
  "default_restore_target": "/tmp/",
  "backups": [
    {
      "name": "My Backup",
      "source": "Path to direction you want to backend",
      "target": "duplicity backend url for backup target"
    }
    // More backup ...
  ]
}
```
