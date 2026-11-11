=====================================================================
  ModSweep for The Sims 4 (Mac and Linux edition)
  Clean up your Mods folder: duplicates, old versions, junk and more
  Version 1.1.0, created by Justinimini
=====================================================================

(Deutsche Anleitung weiter unten.)
(Using Windows? Please download the Windows edition instead.)


WHAT IS MODSWEEP?
*****************

ModSweep is a small tool that helps you keep your Sims 4 Mods folder
clean. It searches all subfolders and shows you:

  * duplicate mods (same content, even with a different name)
  * duplicate file names
  * several versions of the same mod (e.g. Mod_v4.1 and Mod_v4.2)
  * all files of a certain type (e.g. .png or .mp4)
  * unneeded files (archives, readmes, preview images, empty files,
    .DS_Store and other system leftovers)
  * empty folders
  * the largest files
  * misplaced mods that are nested too deep for the game to load

Everything you delete goes to the Trash, so nothing is lost by
accident.


=====================================================================
  MAC
=====================================================================

REQUIREMENTS
  * macOS 11 (Big Sur) or newer
  * Python 3 from python.org (free)

INSTALLATION
  1. Install Python: go to https://www.python.org/downloads/macos/,
     download the latest "macOS 64-bit universal2 installer" and
     install it. You only need to do this once.

  2. Extract the ZIP into its own folder, for example in your
     Applications or Documents folder.
     IMPORTANT: Do NOT put it inside your Sims 4 Mods folder.

  3. The first time, macOS blocks the file because it is not from the
     App Store. How to allow it once:
     * macOS 15 (Sequoia) or newer: double click
       "Start ModSweep (Mac).command" and close the warning. Then open
       System Settings > Privacy & Security, scroll down and click
       "Open Anyway" next to the message about ModSweep. Confirm.
     * macOS 14 or older: RIGHT click "Start ModSweep (Mac).command",
       choose "Open" and click "Open" again.
     After that, a normal double click is enough.

  4. A Terminal window opens briefly and ModSweep starts. You can
     close the Terminal window.

PERMISSIONS
  macOS may ask:
  * if ModSweep (Terminal / Python) may access your Documents
    folder: click "Allow", otherwise ModSweep cannot see your mods.
  * if it may control "Finder": click "OK". ModSweep asks Finder to
    move files to the Trash, so you can use "Put Back" later.

Your Mods folder is usually here:
  Documents / Electronic Arts / The Sims 4 / Mods
ModSweep finds it automatically.


=====================================================================
  LINUX
=====================================================================

REQUIREMENTS
  * Python 3 with Tkinter. Most systems have Python already.
    If Tkinter is missing, install it:
      Ubuntu, Debian, Mint:  sudo apt install python3-tk
      Fedora:                sudo dnf install python3-tkinter
      Arch, Manjaro:         sudo pacman -S tk
      openSUSE:              sudo zypper install python3-tk

INSTALLATION
  1. Extract the ZIP into its own folder, e.g. ~/ModSweep
  2. Open a terminal in that folder and run once:
       chmod +x start-modsweep-linux.sh add-to-app-menu-linux.sh
  3. Start ModSweep with:
       ./start-modsweep-linux.sh
  4. Optional: run ./add-to-app-menu-linux.sh to get ModSweep with
     its logo in your app menu.

WHERE IS MY MODS FOLDER?
  On Linux, Sims 4 runs through Steam (Proton) or Wine. ModSweep tries
  to find the Mods folder automatically. If it does not, click
  "Browse ..." and choose it yourself. With Steam it is usually here:
    ~/.local/share/Steam/steamapps/compatdata/1222670/pfx/drive_c/
    users/steamuser/Documents/Electronic Arts/The Sims 4/Mods
  Tip: you can also copy this path and paste it directly into the
  "Folder" field. In the "Browse ..." dialog, tick "Show Hidden Files
  and Directories" to see hidden folders like .local.


=====================================================================
  HOW TO USE (Mac and Linux)
=====================================================================

  1. Folder: ModSweep finds your Mods folder automatically. If you
     have two Sims 4 folders (e.g. "Die Sims 4" and "The Sims 4"),
     it picks the one that really has mods. With "Browse ..." you
     can choose any other folder. ModSweep remembers the folder you
     used last.
  2. Search: choose what you want to find. The red text below
     explains the selected search type.
  3. Click "Search".
  4. Mark files: click the box in the first column. Clicking the box
     of a group row marks or unmarks the whole group.
     The space bar also works.
  5. "Mark (keep newest)" marks all duplicates except the newest
     file of each group. "Mark all" marks everything.
  6. Click "Move marked to Trash".

  Double click a row to show the file in its folder.
  Click a column header (e.g. Size or Modified) to sort.

MORE BUTTONS
  Move marked to correct folder
      For "Misplaced mods". Moves .ts4script files up to 1 subfolder
      deep and .package files up to 5 subfolders deep. For this
      search, choose your Mods folder (or a folder inside it).
  Save list (Excel)
      Saves the current list as a .csv table (Excel, Numbers,
      LibreOffice).
  Check update status online
      Opens Scarlet's Mod List. You choose the SFW edition (no adult
      content) or the SFW + NSFW edition (18+).
  Clear Sims cache
      Moves localthumbcache.package and the cache folders to the
      Trash. Sims 4 must be closed.
  Backup Mods folder
      Packs the selected folder with all subfolders into a ZIP file
      with date and time in its name. You choose where to save it.
      To restore, extract the ZIP and put the Mods folder back.
      Tip: make a backup before you clean up.

LANGUAGES
  English, Deutsch, Español, Français, Polski, Português (Brasil).
  Choose at the top right. ModSweep remembers your choice.

LIGHT AND DARK MODE
  At the bottom right: Theme: System (follows macOS or your Linux
  desktop, default), Theme: Light or Theme: Dark.
  ModSweep remembers your choice.

GOOD TO KNOW
  * Close Sims 4 before deleting or moving files.
  * Script mods (.ts4script) may only be 1 folder deep inside Mods.
    Package files (.package) may be up to 5 folders deep.
  * Only delete archives (.zip, .rar, .7z) if you already extracted
    them.

DISCLAIMER
  ModSweep is a free fan made tool. It is not made by, affiliated
  with or endorsed by Electronic Arts or Maxis. The Sims is a
  trademark of Electronic Arts Inc. Use at your own risk and back up
  your Mods folder first. License: MIT (see LICENSE.txt).



=====================================================================
  DEUTSCHE ANLEITUNG
=====================================================================

WAS IST MODSWEEP?
*****************

ModSweep ist ein kleines Programm, mit dem du deinen Sims 4
Mods-Ordner aufräumen kannst. Es findet doppelte Mods, alte
Versionen, unnötige Dateien (auch .DS_Store und andere System-Reste),
leere Ordner, die größten Dateien und Mods, die zu tief liegen und
deshalb vom Spiel nicht geladen werden.

Alles, was du löschst, landet im Papierkorb. Leere Ordner prüft
ModSweep vor dem Löschen noch einmal.


=====================================================================
  MAC
=====================================================================

VORAUSSETZUNGEN
  * macOS 11 (Big Sur) oder neuer
  * Python 3 von python.org (kostenlos)

INSTALLATION
  1. Python installieren: Auf https://www.python.org/downloads/macos/
     den neuesten "macOS 64-bit universal2 installer" laden und
     installieren. Das musst du nur einmal machen.

  2. Die ZIP-Datei in einen eigenen Ordner entpacken, zum Beispiel in
     Programme oder Dokumente.
     WICHTIG: NICHT in den Sims 4 Mods-Ordner legen.

  3. Beim ersten Mal blockiert macOS die Datei, weil sie nicht aus dem
     App Store kommt. So erlaubst du sie einmalig:
     * macOS 15 (Sequoia) oder neuer: Doppelklick auf
       "Start ModSweep (Mac).command" und die Warnung schließen. Dann
       Systemeinstellungen > Datenschutz & Sicherheit öffnen, nach
       unten scrollen und neben dem Hinweis zu ModSweep auf
       "Dennoch öffnen" klicken. Bestätigen.
     * macOS 14 oder älter: RECHTSKLICK auf
       "Start ModSweep (Mac).command", "Öffnen" wählen und noch einmal
       "Öffnen" klicken.
     Danach reicht ein normaler Doppelklick.

  4. Kurz öffnet sich ein Terminal-Fenster und ModSweep startet. Das
     Terminal-Fenster kannst du schließen.

BERECHTIGUNGEN
  macOS fragt eventuell:
  * ob ModSweep (Terminal / Python) auf deinen Dokumente-Ordner
    zugreifen darf: "Erlauben" klicken, sonst sieht ModSweep deine
    Mods nicht.
  * ob es den "Finder" steuern darf: "OK" klicken. ModSweep lässt den
    Finder die Dateien in den Papierkorb legen. So kannst du sie
    später mit "Zurücklegen" wiederherstellen.

Dein Mods-Ordner liegt normalerweise hier:
  Dokumente / Electronic Arts / Die Sims 4 / Mods
ModSweep findet ihn automatisch.


=====================================================================
  LINUX
=====================================================================

VORAUSSETZUNGEN
  * Python 3 mit Tkinter. Python ist meistens schon installiert.
    Falls Tkinter fehlt:
      Ubuntu, Debian, Mint:  sudo apt install python3-tk
      Fedora:                sudo dnf install python3-tkinter
      Arch, Manjaro:         sudo pacman -S tk
      openSUSE:              sudo zypper install python3-tk

INSTALLATION
  1. Die ZIP-Datei in einen eigenen Ordner entpacken, z. B. ~/ModSweep
  2. Im Terminal in diesem Ordner einmal ausführen:
       chmod +x start-modsweep-linux.sh add-to-app-menu-linux.sh
  3. ModSweep starten mit:
       ./start-modsweep-linux.sh
  4. Optional: ./add-to-app-menu-linux.sh ausführen. Dann ist
     ModSweep mit Logo in deinem App-Menü.

WO IST MEIN MODS-ORDNER?
  Unter Linux läuft Sims 4 über Steam (Proton) oder Wine. ModSweep
  versucht, den Mods-Ordner selbst zu finden. Falls das nicht klappt,
  klick auf "Durchsuchen ..." und wähle ihn selbst aus. Bei Steam liegt
  er meistens hier:
    ~/.local/share/Steam/steamapps/compatdata/1222670/pfx/drive_c/
    users/steamuser/Documents/Electronic Arts/The Sims 4/Mods
  Tipp: Du kannst diesen Pfad auch kopieren und direkt in das Feld
  "Ordner" einfügen. Im Fenster "Durchsuchen ..." den Haken bei
  "Show Hidden Files and Directories" setzen, dann siehst du versteckte Ordner wie
  .local.


=====================================================================
  SO BENUTZT DU MODSWEEP (Mac und Linux)
=====================================================================

  1. Ordner: ModSweep findet deinen Mods-Ordner automatisch. Hast
     du zwei Sims-4-Ordner (z. B. "Die Sims 4" und "The Sims 4"),
     nimmt es den, in dem wirklich Mods liegen. Mit
     "Durchsuchen ..." kannst du einen anderen Ordner wählen.
     ModSweep merkt sich den zuletzt benutzten Ordner.
  2. Suchart: Wähle aus, was du finden willst. Der rote Text darunter
     erklärt die gewählte Suchart.
  3. Klick auf "Suchen".
  4. Dateien markieren: auf das Kästchen in der ersten Spalte klicken.
     Ein Klick auf das Kästchen einer Gruppenzeile markiert die ganze
     Gruppe oder hebt die Markierung auf. Die Leertaste geht auch.
  5. "Markieren (neueste behalten)" markiert alle Duplikate außer der
     neuesten Datei jeder Gruppe. "Alle markieren" markiert alles.
  6. Klick auf "Markierte in den Papierkorb".

  Doppelklick auf eine Zeile zeigt die Datei in ihrem Ordner.
  Klick auf eine Spaltenüberschrift (z. B. Größe oder Geändert)
  sortiert die Liste.

WEITERE KNÖPFE
  Markierte richtig einsortieren
      Für "Falsch einsortierte Mods". Schiebt .ts4script-Dateien auf
      höchstens 1 Unterordner und .package-Dateien auf höchstens 5
      Unterordner Tiefe. Wähle für diese Suche deinen Mods-Ordner
      (oder einen Ordner darin).
  Liste speichern (Excel)
      Speichert die Liste als .csv-Tabelle (Excel, Numbers,
      LibreOffice).
  Update-Status online prüfen
      Öffnet Scarlet's Mod List. Du wählst die SFW-Ausgabe (ohne
      Inhalte für Erwachsene) oder die SFW + NSFW-Ausgabe (ab 18).
  Sims-Cache leeren
      Legt localthumbcache.package und die Cache-Ordner in den
      Papierkorb. Sims 4 muss dafür geschlossen sein.
  Mods-Ordner sichern
      Packt den gewählten Ordner mit allen Unterordnern in eine
      ZIP-Datei mit Datum und Uhrzeit im Namen. Du wählst, wo sie
      gespeichert wird. Zum Wiederherstellen die ZIP entpacken und
      den Mods-Ordner zurücklegen.
      Tipp: Mach vor dem Aufräumen eine Sicherung.

SPRACHEN
  English, Deutsch, Español, Français, Polski, Português (Brasil).
  Oben rechts auswählen. ModSweep merkt sich deine Auswahl.

HELLER UND DUNKLER MODUS
  Unten rechts: Design: System (folgt macOS bzw. deinem
  Linux-Desktop, Standard), Design: Hell oder Design: Dunkel.
  ModSweep merkt sich deine Auswahl.

GUT ZU WISSEN
  * Schließe Sims 4, bevor du Dateien löschst oder verschiebst.
  * Skript-Mods (.ts4script) dürfen nur 1 Ordner tief liegen.
    Package-Dateien (.package) dürfen bis zu 5 Ordner tief liegen.
  * Archive (.zip, .rar, .7z) nur löschen, wenn du sie schon entpackt
    hast.

HAFTUNGSAUSSCHLUSS
  ModSweep ist ein kostenloses Fan-Programm. Es wurde nicht von
  Electronic Arts oder Maxis erstellt und steht in keiner Verbindung
  zu ihnen. The Sims ist eine Marke von Electronic Arts Inc. Nutzung
  auf eigene Gefahr, vorher am besten den Mods-Ordner sichern.
  Lizenz: MIT (siehe LICENSE.txt).
