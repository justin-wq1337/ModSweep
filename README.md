<p align="center"><img src="logo.png" alt="ModSweep for The Sims 4" width="320"></p>

# ModSweep for The Sims 4

**Clean up your Mods folder in minutes: find duplicates, old versions, junk files and misplaced mods.**

Big Mods folders get messy fast. Duplicate downloads, three versions of the same mod, forgotten ZIP files, preview images and script mods sitting one folder too deep. ModSweep finds all of that for you and lets you clean it up with a few clicks.

Everything you delete goes to the **Recycle Bin** (Trash on Mac and Linux), so nothing is lost by accident.


## Features

**10 search types**

* **Duplicate files (same content):** finds identical mods, even if they have different names
* **Duplicate file names:** same name in different folders
* **Several versions of the same mod:** e.g. `Mod_v4.1` and `Mod_v4.2` or `Mod (1)`
* **All files of a type:** e.g. `.png`, `.mp4` or any other type you enter
* **Unneeded files:** archives, readmes, preview images, empty files, Thumbs.db
* **Empty folders**
* **Largest files:** see what takes up the most space
* **Misplaced mods:** script mods deeper than 1 subfolder and packages deeper than 5 subfolders, which the game does not load
* **Broken or wrong mod files:** damaged or incomplete downloads, and files for Sims 2 or Sims 3 that do not work in Sims 4
* **Game error reports:** the lastException files the game writes into the Sims 4 folder, so you can open or clean them up

**Tools**

* **Mark (keep newest):** marks all duplicates except one file per group. It keeps the highest version for "Several versions", and always prefers a file the game can actually load
* **Move marked to correct folder:** moves misplaced mods up to the deepest allowed level with one click. Script mods take their settings files (.cfg) with them
* **Clear Sims cache:** deletes localthumbcache.package and the cache folders
* **Check update status online:** opens Scarlet's Mod List (you choose the SFW or SFW + NSFW edition)
* **Save list (Excel):** export any result list as a table
* **Backup Mods folder:** packs your Mods folder into a ZIP file wherever you want, so you can restore it any time
* **Show in Explorer**, sorting by name, folder, size or date

**6 languages:** English, German, Spanish, French, Polish and Portuguese (Brazil). On the first start ModSweep uses your system language.

**Light and dark mode:** follows your system setting, or choose light or dark yourself

**Update check (optional):** if you agree, ModSweep tells you when a new version is out and opens the download page for you. You can switch it off at the bottom right.

**Remembers your folder:** ModSweep remembers the folder you used last. On the first start it picks the Sims 4 folder that really has mods (e.g. "Die Sims 4" instead of an empty "The Sims 4").


## Download

Get the latest version on the **[Releases page](https://github.com/justin-wq1337/ModSweep/releases/latest)**:

* **ModSweep-for-The-Sims-4.zip** for **Windows 10 and 11**. Nothing else to install.
* **ModSweep-for-The-Sims-4-Mac-Linux.zip** for **macOS 11 or newer** and **Linux**. Needs Python 3.8 or newer (free from python.org on Mac).


## Installation (Windows)

1. Extract the ZIP into its own folder, e.g. `Documents\ModSweep`.
   **Do not put it inside your Mods folder.**
2. Double click **Start.bat**.
3. Optional: double click **Create Desktop Shortcut.bat** to get a desktop shortcut with the ModSweep logo.

If Windows shows "Windows protected your PC", click **More info** and then **Run anyway**.
If nothing happens, start **Start (Troubleshooting).bat** to see error messages.


## Installation (Mac and Linux)

Please follow the README.txt inside the Mac and Linux ZIP. In short:

* **Mac:** install Python from python.org. The first time, macOS blocks the starter: on macOS 15 or newer allow it in **System Settings > Privacy & Security > Open Anyway**, on older versions right click **Start ModSweep (Mac).command** and choose **Open**.
* **Linux:** install Tkinter if needed (e.g. `sudo apt install python3-tk`), then run `./start-modsweep-linux.sh`.


## Safety and transparency

* ModSweep is **open source**. `ModSweep.ps1` (Windows) and `modsweep.py` (Mac and Linux) are plain text, so you can read every line.
* It does **not** collect or send any data about you or your mods.
* Internet access only happens in two cases: when you click "Check update status online" (opens Scarlet's Mod List in your browser), and, if you agree on the first start, a short check on GitHub for the newest ModSweep version number. Nothing is downloaded or installed on its own.
* Deleted files go to the **Recycle Bin** or Trash. If Windows cannot use the Recycle Bin (for example on a network drive), Windows asks you before anything is deleted for good.
* Empty folders are checked again right before they are deleted, so nothing that was added in the meantime is lost.
* For duplicates and versions, ModSweep never lets you delete every file of a group.
* ModSweep was made with the help of an AI assistant (Claude by Anthropic).
* Some antivirus programs are suspicious of scripts in general. If yours shows a warning, you can check the code yourself or look at the VirusTotal scans linked below.

VirusTotal scans of version 1.2.1, no security vendor flagged either file:

* Windows ZIP: **0 of 62** ([full report](https://www.virustotal.com/gui/file/145c395cfac17b773d85d5797000c17cac73cde5d22efcbca1a2b5593e4250e1))
* Mac and Linux ZIP: **0 of 62** ([full report](https://www.virustotal.com/gui/file/7430d27e082528bf9b4cf95e8445ba7264be4a4c786cae839cae319db285ab93))


## FAQ

**Does it work with mods from Patreon, CurseForge, MTS etc.?**
Yes. ModSweep works with any `.package` and `.ts4script` files, no matter where they come from.

**Can it update my mods automatically?**
No. There is no common database for Sims 4 mod versions. The "Check update status online" button opens Scarlet's Mod List, where you can look up your mods after a patch.

**Does it work on Mac and Linux?**
Yes, with the Mac and Linux edition. The Mac and Linux edition is new, so please report any problems in the Issues tab.


## What's new in 1.2.1

* New: **optional update check.** On the first start ModSweep asks if it should look for new versions. If you agree, it tells you when a new version is on GitHub and opens the download page. Nothing is downloaded or installed on its own, and no data about you is sent. You can switch it on or off at the bottom right, or check by hand.
* Clearer text in "Several versions": the highest version is listed first
* Small fixes: wider choice lists at the bottom right, safer CSV export


## What's new in 1.2.0

* New search: **Broken or wrong mod files.** Finds damaged or incomplete downloads and Sims 2 or Sims 3 files, which do not work in Sims 4 and can make the game crash
* New search: **Game error reports.** Lists the lastException files in your Sims 4 folder
* ModSweep now starts in your system language
* Fixed (Windows): Mods folders inside OneDrive were not searched completely, and the backup could miss files
* Fixed (Mac and Linux): a single very old file (dated before 1980) stopped the whole backup
* "Mark (keep newest)" keeps the highest version for "Several versions" and prefers files the game can load
* Moving a script mod to the correct folder now moves its settings files (e.g. MCCC's .cfg) along
* Folders that could not be read (links, no access, path too long) are now reported instead of skipped silently
* Faster on very big Mods folders (Windows), faster marking on long lists (Mac and Linux)
* Windows questions about permanent deleting now always open in front of ModSweep
* Small fixes: drive roots like D:\, safer CSV export, clearer error messages


## What's new in 1.1.0

* New: Backup Mods folder button, saves your whole Mods folder as a ZIP file wherever you want
* New: light and dark mode, or follow the system setting (default)
* New: ModSweep remembers the folder you used last
* New: on the first start ModSweep picks the Sims 4 folder that really has mods, if you have more than one (e.g. "Die Sims 4" and "The Sims 4")


## What's new in 1.0.1

* Safer deleting on Windows: Windows now asks before anything would be deleted permanently (e.g. on network drives)
* Double clicking a row no longer marks the file by accident (Windows)
* "Empty folders" never lists folders that could not be read, and every folder is checked again before deleting
* The "keep at least one file" protection now also works after earlier deletions
* "Misplaced mods" always counts from your Mods folder and warns if another folder is selected
* "Clear Sims cache" only works in the real Sims 4 folder
* The Excel list uses the right separator for your language
* Empty files no longer show up as duplicates, system leftovers (Thumbs.db, desktop.ini, .DS_Store) are handled the same on all systems
* New: Start (Troubleshooting).bat for Windows, updated Mac and Linux instructions


## Credits

* **Scarlet's Realm** for maintaining The Mod List
* Created by **Justinimini**


## Disclaimer

ModSweep is a free fan made tool. It is not made by, affiliated with or endorsed by Electronic Arts or Maxis. The Sims is a trademark of Electronic Arts Inc.

Use at your own risk. It is always a good idea to back up your Mods folder before cleaning it.

License: MIT

