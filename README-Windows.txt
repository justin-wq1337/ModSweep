=====================================================================
  ModSweep for The Sims 4
  Clean up your Mods folder: duplicates, old versions, junk and more
  Version 1.0.1, created by Justinimini
=====================================================================

(Deutsche Anleitung weiter unten.)


WHAT IS MODSWEEP?
*****************

ModSweep is a small Windows tool that helps you keep your Sims 4 Mods
folder clean. It searches all subfolders and shows you:

  * duplicate mods (same content, even with a different name)
  * duplicate file names
  * several versions of the same mod (e.g. Mod_v4.1 and Mod_v4.2)
  * all files of a certain type (e.g. .png or .mp4)
  * unneeded files (archives, readmes, preview images, empty files)
  * empty folders
  * the largest files
  * misplaced mods that are nested too deep for the game to load

Everything you delete goes to the Recycle Bin, so nothing is lost
by accident. If Windows cannot use the Recycle Bin (for example on a
network drive), Windows asks you before anything is deleted for good.
Before an empty folder is deleted, ModSweep checks it again.


REQUIREMENTS
************

  * Windows 10 or Windows 11
  * Nothing else to install. ModSweep uses Windows PowerShell,
    which is already part of Windows.


INSTALLATION
************

  1. Extract the ZIP file into a folder of your choice,
     for example: Documents\ModSweep

     IMPORTANT: Do NOT put the ModSweep folder inside your Sims 4
     Mods folder.

  2. Double click "Start.bat".

  3. If Windows shows "Windows protected your PC", click
     "More info" and then "Run anyway". This message appears for
     many small programs that are not from a big company.

  4. Optional: Double click "Create Desktop Shortcut.bat".
     You then get a shortcut with the ModSweep logo on your desktop.


HOW TO USE
**********

  1. Folder: ModSweep finds your Sims 4 Mods folder automatically.
     With "Browse ..." you can choose any other folder.

  2. Search: Choose what you want to find. The red text below
     explains the selected search type.

  3. Click "Search".

  4. Check the results:
       * Double click a row to open the file in Explorer.
       * Click a column header (e.g. Size or Modified) to sort.

  5. Mark the files you want to remove:
       * "Mark (keep newest)" marks all duplicates except the newest
         file of each group.
       * "Mark all" marks everything in the list.

  6. Click "Move marked to Recycle Bin".


MORE BUTTONS
************

  Move marked to correct folder
      For the search type "Misplaced mods". Moves .ts4script files
      up to 1 subfolder deep and .package files up to 5 subfolders
      deep, so Sims 4 loads them again. For this search, choose your
      Mods folder (or a folder inside it).

  Save list (Excel)
      Saves the current list as a table (.csv) that opens in Excel.

  Check update status online
      Opens Scarlet's Mod List in your browser. There you can see
      which mods are broken or updated after a game patch.
      You choose between the SFW edition (no adult content) and the
      SFW + NSFW edition (adult content, 18+).

  Clear Sims cache
      Deletes localthumbcache.package and the cache folders.
      This often fixes problems after mod updates.
      Sims 4 must be closed.


LANGUAGES
*********

Choose your language in the list at the top right:
English, Deutsch, Español, Français, Polski, Português (Brasil).
ModSweep remembers your choice.


GOOD TO KNOW
************

  * Close Sims 4 before deleting or moving files.
  * Script mods (.ts4script) may only be 1 folder deep inside Mods.
    Package files (.package) may be up to 5 folders deep.
  * Only delete archives (.zip, .rar, .7z) if you already extracted
    them.
  * Own icon: Replace "icon.ico" with your own icon file. Please only
    use images you are allowed to use.


TROUBLESHOOTING
***************

  Nothing happens after double clicking Start.bat:
      Double click "Start (Troubleshooting).bat". It starts ModSweep
      with a visible window that shows error messages. Send a
      screenshot of that window to the creator.

  Some files could not be deleted or moved:
      Sims 4 or another program is still using them. Close the game
      and try again.


DISCLAIMER
**********

ModSweep is a free fan made tool. It is not made by, affiliated
with or endorsed by Electronic Arts or Maxis. The Sims is a
trademark of Electronic Arts Inc.

Use at your own risk. Deleted files go to the Recycle Bin, but it
is always a good idea to back up your Mods folder first.

ModSweep is free and open source under the MIT License
(see LICENSE.txt).



=====================================================================
  DEUTSCHE ANLEITUNG
=====================================================================


WAS IST MODSWEEP?
*****************

ModSweep ist ein kleines Windows-Programm, mit dem du deinen
Sims 4 Mods-Ordner aufräumen kannst. Es durchsucht alle Unterordner
und zeigt dir:

  * doppelte Mods (gleicher Inhalt, auch bei anderem Namen)
  * doppelte Dateinamen
  * mehrere Versionen derselben Mod (z. B. Mod_v4.1 und Mod_v4.2)
  * alle Dateien eines Typs (z. B. .png oder .mp4)
  * unnötige Dateien (Archive, Anleitungen, Vorschaubilder,
    leere Dateien)
  * leere Ordner
  * die größten Dateien
  * falsch einsortierte Mods, die zu tief liegen und deshalb vom
    Spiel nicht geladen werden

Alles, was du löschst, landet im Papierkorb. Es geht also nichts
aus Versehen verloren. Kann Windows den Papierkorb nicht nutzen (zum
Beispiel bei einem Netzlaufwerk), fragt Windows nach, bevor etwas
endgültig gelöscht wird. Leere Ordner prüft ModSweep vor dem Löschen
noch einmal.


VORAUSSETZUNGEN
***************

  * Windows 10 oder Windows 11
  * Sonst musst du nichts installieren. ModSweep nutzt die
    Windows PowerShell, die bei Windows schon dabei ist.


INSTALLATION
************

  1. Entpacke die ZIP-Datei in einen Ordner deiner Wahl,
     zum Beispiel: Dokumente\ModSweep

     WICHTIG: Lege den ModSweep-Ordner NICHT in deinen Sims 4
     Mods-Ordner.

  2. Doppelklick auf "Start.bat".

  3. Wenn Windows "Der Computer wurde durch Windows geschützt"
     anzeigt, klick auf "Weitere Informationen" und dann auf
     "Trotzdem ausführen". Diese Meldung kommt bei vielen kleinen
     Programmen, die nicht von einer großen Firma stammen.

  4. Optional: Doppelklick auf "Create Desktop Shortcut.bat".
     Dann bekommst du eine Verknüpfung mit dem ModSweep-Logo auf
     deinem Desktop.


SO BENUTZT DU MODSWEEP
**********************

  1. Ordner: ModSweep findet deinen Sims 4 Mods-Ordner automatisch.
     Mit "Durchsuchen ..." kannst du einen anderen Ordner wählen.

  2. Suchart: Wähle aus, was du finden willst. Der rote Text
     darunter erklärt die gewählte Suchart.

  3. Klick auf "Suchen".

  4. Ergebnisse prüfen:
       * Doppelklick auf eine Zeile öffnet die Datei im Explorer.
       * Klick auf eine Spaltenüberschrift (z. B. Größe oder
         Geändert) sortiert die Liste.

  5. Dateien markieren, die weg sollen:
       * "Markieren (neueste behalten)" markiert alle Duplikate
         außer der neuesten Datei jeder Gruppe.
       * "Alle markieren" markiert alles in der Liste.

  6. Klick auf "Markierte in den Papierkorb".


WEITERE KNÖPFE
**************

  Markierte richtig einsortieren
      Für die Suchart "Falsch einsortierte Mods". Schiebt
      .ts4script-Dateien auf höchstens 1 Unterordner und
      .package-Dateien auf höchstens 5 Unterordner Tiefe, damit
      Sims 4 sie wieder lädt. Wähle für diese Suche deinen
      Mods-Ordner (oder einen Ordner darin).

  Liste speichern (Excel)
      Speichert die aktuelle Liste als Tabelle (.csv), die sich mit
      Excel öffnen lässt.

  Update-Status online prüfen
      Öffnet Scarlet's Mod List im Browser. Dort siehst du, welche
      Mods nach einem Spiel-Update kaputt oder aktualisiert sind.
      Du wählst selbst zwischen der SFW-Ausgabe (ohne Inhalte für
      Erwachsene) und der SFW + NSFW-Ausgabe (ab 18).

  Sims-Cache leeren
      Löscht localthumbcache.package und die Cache-Ordner. Das hilft
      oft bei Fehlern nach Mod-Updates. Sims 4 muss dafür
      geschlossen sein.


SPRACHEN
********

Die Sprache wählst du oben rechts in der Liste:
English, Deutsch, Español, Français, Polski, Português (Brasil).
ModSweep merkt sich deine Auswahl.


GUT ZU WISSEN
*************

  * Schließe Sims 4, bevor du Dateien löschst oder verschiebst.
  * Skript-Mods (.ts4script) dürfen nur 1 Ordner tief im Mods-Ordner
    liegen. Package-Dateien (.package) dürfen bis zu 5 Ordner tief
    liegen.
  * Archive (.zip, .rar, .7z) nur löschen, wenn du sie schon
    entpackt hast.
  * Eigenes Symbol: Ersetze "icon.ico" durch eine eigene Icon-Datei.
    Bitte nur Bilder verwenden, die du nutzen darfst.


HILFE BEI PROBLEMEN
*******************

  Nach dem Doppelklick auf Start.bat passiert nichts:
      Doppelklick auf "Start (Troubleshooting).bat". Damit startet
      ModSweep mit einem sichtbaren Fenster, das Fehlermeldungen
      anzeigt. Schick einen Screenshot davon an den Ersteller.

  Einige Dateien konnten nicht gelöscht oder verschoben werden:
      Sims 4 oder ein anderes Programm benutzt sie noch. Schließe
      das Spiel und versuche es noch einmal.


HAFTUNGSAUSSCHLUSS
******************

ModSweep ist ein kostenloses Fan-Programm. Es wurde nicht von
Electronic Arts oder Maxis erstellt und steht in keiner Verbindung
zu ihnen. The Sims ist eine Marke von Electronic Arts Inc.

Nutzung auf eigene Gefahr. Gelöschte Dateien landen zwar im
Papierkorb, trotzdem ist es immer gut, vorher eine Sicherung deines
Mods-Ordners zu machen.

ModSweep ist kostenlos und quelloffen unter der MIT-Lizenz
(siehe LICENSE.txt).
