# Gorp Changelog

## 1.1.0 (23 Feb 2023)
#### General
* Fixes and updates to documentation site.

#### Added
* `reset-world`: Delete and regenerate the world files for a server. Good for wanting a world "mulligan" when joining a freshly generated world.
* `list-servers`: List all server instances in the /minecraft/servers/ directory.

#### Changed
* `create-server` now accepts an optional paramter to override the default world name. To create a server named "public" with the world "base", run `gorp create-server public base`.

## 1.0.3 (20 Feb 2023)
#### General
* The documentation site has been overhauled. It's now much easier to navigate and now has an improved experience on mobile. [Check it out](https://gorp.lanickel.com/)!

#### Changed
* Help text updated to reflect command updates.



## 1.0.2 (17 Feb 2023)
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