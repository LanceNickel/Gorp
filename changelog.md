# Gorp Changelog

## 1.0.0 (16 Feb 2023)
#### General
* A changelog will now be kept for subsequent updates.

#### Changed
* `backup` has been changed to `backup-world` to alleviate potential confusion.
* `restore` has been changed to `restore-world` to alleviate potential confusion.
* `update` has been changed to `update-jar` to alleviate potential confusion.
* `create-world`, `delete-world`, and `switch-world` now accept the world name as well for more direct action. Ex: `gorp switch-world [server name] <world name>`.

#### Added
* `archive-world` in conjunction with the already-existing `delete-world` action. Accepts a secondary world name parameter to skip a query step.
* Use `gorp -v` to check the currently installed version of Gorp.