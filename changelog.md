# Gorp Changelog

## 1.0.1 (17 Feb 2023)
#### General
* A changelog will now be kept for subsequent updates.

#### Changed
* `backup` has been changed to `backup-world` to alleviate potential confusion.
* `restore` has been changed to `restore-world` to alleviate potential confusion.
* `update` has been changed to `update-jar` to alleviate potential confusion.
* `create-world`, `delete-world`, and `switch-world` now accept the world name as well for more direct action. Ex: `gorp switch-world [server-name] <world-name>`.
* `create-world` now starts the server to generate the files, then shuts it down and takes an initial backup.
* `start` will now take an initial backup of a world when the first-run world generation is done.
* Renamed the `DEST` option in `gorp.conf` to more accurately describe what it does.

#### Added
* `archive-world` in conjunction with the already-existing `delete-world` action.
* `ARCHIVES` option in `gorp.conf`, works similar to the backup destination option
* Use `gorp -v` to check the currently installed version of Gorp.