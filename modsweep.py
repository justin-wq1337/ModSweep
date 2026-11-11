#!/usr/bin/env python3
# ModSweep for The Sims 4 (Mac and Linux edition)
# Created by Justinimini, MIT License
#
# Searches a folder including all subfolders for duplicates, old versions,
# unneeded files, empty folders and misplaced mods.
# Deleted files always go to the Trash.
# Languages: English (default), Deutsch, Español, Français, Polski, Português (Brasil)

import csv
import datetime
import glob
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import threading
import urllib.parse
import webbrowser

IS_MAC = sys.platform == 'darwin'
APP_VERSION = '1.0.1'
APP_DIR = os.path.dirname(os.path.abspath(__file__))

LANG_CODES = ['en', 'de', 'es', 'fr', 'pl', 'pt']
LANG_NAMES = ['English', 'Deutsch', 'Español', 'Français', 'Polski', 'Português (Brasil)']

LANG = json.loads(r'''{
 "en": {
  "modes": [
   "Duplicate files: same content (safe)",
   "Duplicate files: same file name (fast)",
   "Several versions of the same mod (e.g. v4.1 and v4.2)",
   "All files of a type (e.g. .png)",
   "Unneeded files (archives, readmes, images, 0 bytes)",
   "Empty folders",
   "Largest files",
   "Misplaced mods (nested too deep)"
  ],
  "hints": [
   "Finds files with exactly the same content, even if they have different names.",
   "Finds files with the same name in different folders. The content may differ.",
   "Finds e.g. \"Mod_v4.1\" and \"Mod_v4.2\" or \"Mod (1)\". Please check before deleting.",
   "Shows all files of the entered types. Separate several types with commas.",
   "Shows archives, readmes, preview images and empty files. Sims 4 does not need them.",
   "Shows folders that no longer contain a single file.",
   "Shows the 200 largest files, so you can see what takes up the most space.",
   "Sims 4 loads .ts4script only 1 subfolder deep and .package up to 5 subfolders deep."
  ],
  "title": "ModSweep for The Sims 4",
  "folder": "Folder:",
  "browse": "Browse ...",
  "mode": "Search:",
  "filetype": "File type:",
  "simsOnly": "Sims files only (.package and .ts4script)",
  "search": "Search",
  "colName": "Name",
  "colFolder": "Subfolder",
  "colSize": "Size",
  "colDate": "Modified",
  "btnExplorer": "Show in folder",
  "btnAuto": "Mark (keep newest)",
  "btnAll": "Mark all",
  "btnClear": "Unmark all",
  "btnDelete": "Move marked to Trash",
  "btnSave": "Save list (Excel)",
  "btnMove": "Move marked to correct folder",
  "btnUpdate": "Check update status online",
  "btnCache": "Clear Sims cache",
  "mainFolder": "(main folder)",
  "folderItem": "Folder",
  "folderNotFound": "The folder was not found.",
  "enterType": "Please enter a file type, e.g. .png",
  "collecting": "Collecting files ...",
  "comparing": "Comparing contents: {0} of {1} files ...",
  "groupDup": "Group {0}: {1}  ({2} files)",
  "groupVer": "Mod {0}: {1}  ({2} files)",
  "groupFolder": "{0}  ({1} files)",
  "hashNone": "No duplicates found ({0} files checked).",
  "hashFound": "{0} groups of identical files found ({1} files checked). Wasted space: {2}",
  "nameNone": "No duplicate file names found ({0} files checked).",
  "nameFound": "{0} file names occur more than once. Note: the content may differ.",
  "verNone": "No mods with several versions found.",
  "verFound": "{0} mods exist in several versions. The newest file is listed first. Please check before deleting.",
  "typeNone": "No files of type {0} found.",
  "typeFound": "{0} files of type {1} found in {2} folders, {3} in total.",
  "junkEmpty": "Empty files (0 bytes)",
  "junkArchive": "Archives (.zip, .rar, .7z)",
  "junkText": "Texts and readmes",
  "junkImage": "Images and previews",
  "junkWin": "System leftovers (.DS_Store, ._ files, Thumbs.db)",
  "junkNone": "No unneeded files found.",
  "junkFound": "{0} unneeded files found, {1} in total. Only delete archives if they are already extracted.",
  "emptyGroup": "Empty folders  ({0})",
  "emptyFound": "{0} empty folders found. Empty subfolders inside them are deleted too.",
  "emptyNone": "No empty folders found.",
  "bigGroup": "The {0} largest files",
  "bigFound": "All {0} files together: {1}. Click a column header to sort.",
  "noFiles": "No files found.",
  "depthScript": "Scripts (.ts4script), at most 1 subfolder allowed",
  "depthPkg": "Packages (.package), at most 5 subfolders allowed",
  "depthNone": "All good: no mod is nested too deep.",
  "depthFound": "{0} files are nested too deep and are not loaded by the game. Mark them and click \"{1}\".",
  "explorerEmpty": "The list is still empty. Please click \"{0}\" first.",
  "explorerSelect": "Please click a row in the list first.",
  "autoMarked": "{0} files marked. The newest file of each group is kept.",
  "allMarked": "{0} entries marked.",
  "nothingMarked": "Nothing is marked.",
  "keepOne": "Everything in \"{0}\" is marked. At least one file should stay.",
  "confirmDelete": "Move {0} entries to the Trash?",
  "deleting": "Moving to Trash: {0} of {1} ...",
  "deleted": "{0} entries moved to the Trash.",
  "deleteFailed": " {0} could not be moved (is the game still running?).",
  "tHint": "Note",
  "tWarn": "Warning",
  "tConfirm": "Confirm",
  "tError": "Error",
  "moveNone": "Please mark the files to be moved first.",
  "moveConfirm": "Move {0} files up so that Sims 4 loads them?",
  "moved": "{0} files moved to the correct folder.",
  "moveSkipped": " {0} skipped (a file with the same name already exists or the game is still running).",
  "listEmpty": "The list is empty. Please search first.",
  "csvFilter": "Excel table (*.csv)|*.csv",
  "csvFile": "Sims4-Report",
  "csvGroup": "Group",
  "csvMarked": "Marked",
  "csvYes": "yes",
  "csvPath": "Path",
  "saved": "List saved: {0}",
  "saveFailed": "Saving failed: {0}",
  "closeSims": "Please close Sims 4 first.",
  "simsNotFound": "The Sims 4 folder was not found.",
  "cacheEmpty": "The cache is already empty.",
  "cacheTitle": "Clear Sims cache",
  "cacheConfirm": "Clear the cache in{2}{0}?{2}({1} files, they go to the Trash){2}{2}Sims 4 rebuilds the cache on the next start.",
  "cacheDone": "Cache cleared: {0} files moved to the Trash.",
  "cacheFail": " {0} could not be deleted.",
  "browseDesc": "Choose a folder, e.g. your Sims 4 Mods folder",
  "updateOpened": "Scarlet's Mod List was opened in your browser. Search for your mod there (Ctrl+F or Cmd+F).",
  "updSfw": "Mod List: SFW only (no adult content)",
  "updNsfw": "Mod List: SFW + NSFW (adult content, 18+)",
  "trashing": "Working ...",
  "notModsFolder": "This search needs your Mods folder (or a folder inside it). The selected folder is not inside a folder named \"Mods\".",
  "skippedNotEmpty": " {0} folders were skipped because they are not empty (anymore)."
 },
 "de": {
  "modes": [
   "Doppelte Dateien: gleicher Inhalt (sicher)",
   "Doppelte Dateien: gleicher Dateiname (schnell)",
   "Mehrere Versionen derselben Mod (z. B. v4.1 und v4.2)",
   "Alle Dateien vom Typ (z. B. .png)",
   "Unnötige Dateien (Archive, Readmes, Bilder, 0 Byte)",
   "Leere Ordner",
   "Größte Dateien",
   "Falsch einsortierte Mods (zu tief verschachtelt)"
  ],
  "hints": [
   "Findet Dateien mit exakt gleichem Inhalt, auch wenn sie anders heißen.",
   "Findet Dateien mit gleichem Namen in verschiedenen Ordnern. Der Inhalt kann abweichen.",
   "Findet z. B. \"Mod_v4.1\" und \"Mod_v4.2\" oder \"Mod (1)\". Vor dem Löschen bitte kurz prüfen.",
   "Zeigt alle Dateien der eingetragenen Typen. Mehrere Typen mit Komma trennen.",
   "Zeigt Archive, Anleitungen, Vorschaubilder und leere Dateien. Sims 4 braucht diese nicht.",
   "Zeigt Ordner, in denen keine einzige Datei mehr liegt.",
   "Zeigt die 200 größten Dateien. So siehst du, was am meisten Platz belegt.",
   "Sims 4 lädt .ts4script nur bis 1 Unterordner tief und .package bis 5 Unterordner tief."
  ],
  "title": "ModSweep for The Sims 4",
  "folder": "Ordner:",
  "browse": "Durchsuchen ...",
  "mode": "Suchart:",
  "filetype": "Dateityp:",
  "simsOnly": "Nur Sims-Dateien (.package und .ts4script)",
  "search": "Suchen",
  "colName": "Name",
  "colFolder": "Unterordner",
  "colSize": "Größe",
  "colDate": "Geändert",
  "btnExplorer": "Im Ordner zeigen",
  "btnAuto": "Markieren (neueste behalten)",
  "btnAll": "Alle markieren",
  "btnClear": "Markierung aufheben",
  "btnDelete": "Markierte in den Papierkorb",
  "btnSave": "Liste speichern (Excel)",
  "btnMove": "Markierte richtig einsortieren",
  "btnUpdate": "Update-Status online prüfen",
  "btnCache": "Sims-Cache leeren",
  "mainFolder": "(Hauptordner)",
  "folderItem": "Ordner",
  "folderNotFound": "Der Ordner wurde nicht gefunden.",
  "enterType": "Bitte einen Dateityp eintragen, z. B. .png",
  "collecting": "Dateien werden gesammelt ...",
  "comparing": "Vergleiche Inhalte: {0} von {1} Dateien ...",
  "groupDup": "Gruppe {0}: {1}  ({2} Dateien)",
  "groupVer": "Mod {0}: {1}  ({2} Dateien)",
  "groupFolder": "{0}  ({1} Dateien)",
  "hashNone": "Keine Duplikate gefunden ({0} Dateien geprüft).",
  "hashFound": "{0} Gruppen mit identischen Dateien gefunden ({1} Dateien geprüft). Unnötig belegt: {2}",
  "nameNone": "Keine doppelten Dateinamen gefunden ({0} Dateien geprüft).",
  "nameFound": "{0} Dateinamen kommen mehrfach vor. Achtung: Der Inhalt kann unterschiedlich sein.",
  "verNone": "Keine Mods mit mehreren Versionen gefunden.",
  "verFound": "{0} Mods liegen in mehreren Versionen vor. Oben steht jeweils die neueste Datei. Bitte vor dem Löschen prüfen.",
  "typeNone": "Keine Dateien vom Typ {0} gefunden.",
  "typeFound": "{0} Dateien vom Typ {1} in {2} Ordnern gefunden, zusammen {3}.",
  "junkEmpty": "Leere Dateien (0 Byte)",
  "junkArchive": "Archive (.zip, .rar, .7z)",
  "junkText": "Texte und Anleitungen",
  "junkImage": "Bilder und Vorschaubilder",
  "junkWin": "System-Reste (.DS_Store, ._-Dateien, Thumbs.db)",
  "junkNone": "Keine unnötigen Dateien gefunden.",
  "junkFound": "{0} unnötige Dateien gefunden, zusammen {1}. Archive nur löschen, wenn sie schon entpackt sind.",
  "emptyGroup": "Leere Ordner  ({0})",
  "emptyFound": "{0} leere Ordner gefunden. Leere Unterordner darin werden mitgelöscht.",
  "emptyNone": "Keine leeren Ordner gefunden.",
  "bigGroup": "Die {0} größten Dateien",
  "bigFound": "Alle {0} Dateien zusammen: {1}. Klick auf eine Spalte zum Sortieren.",
  "noFiles": "Keine Dateien gefunden.",
  "depthScript": "Skripte (.ts4script), erlaubt ist höchstens 1 Unterordner",
  "depthPkg": "Packages (.package), erlaubt sind höchstens 5 Unterordner",
  "depthNone": "Alles in Ordnung: Keine Mod liegt zu tief.",
  "depthFound": "{0} Dateien liegen zu tief und werden vom Spiel nicht geladen. Markieren und auf \"{1}\" klicken.",
  "explorerEmpty": "Die Liste ist noch leer. Bitte zuerst auf \"{0}\" klicken.",
  "explorerSelect": "Bitte zuerst eine Zeile in der Liste anklicken.",
  "autoMarked": "{0} Dateien markiert. Die neueste Datei jeder Gruppe bleibt erhalten.",
  "allMarked": "{0} Einträge markiert.",
  "nothingMarked": "Es ist nichts markiert.",
  "keepOne": "In \"{0}\" ist alles markiert. Mindestens eine Datei sollte bleiben.",
  "confirmDelete": "{0} Einträge in den Papierkorb verschieben?",
  "deleting": "Verschiebe in den Papierkorb: {0} von {1} ...",
  "deleted": "{0} Einträge in den Papierkorb verschoben.",
  "deleteFailed": " {0} konnten nicht verschoben werden (Spiel noch offen?).",
  "tHint": "Hinweis",
  "tWarn": "Achtung",
  "tConfirm": "Bestätigen",
  "tError": "Fehler",
  "moveNone": "Bitte zuerst die Dateien markieren, die verschoben werden sollen.",
  "moveConfirm": "{0} Dateien so weit nach oben verschieben, dass Sims 4 sie lädt?",
  "moved": "{0} Dateien richtig einsortiert.",
  "moveSkipped": " {0} übersprungen (gleichnamige Datei schon vorhanden oder Spiel noch offen).",
  "listEmpty": "Die Liste ist leer. Bitte zuerst suchen.",
  "csvFilter": "Excel-Tabelle (*.csv)|*.csv",
  "csvFile": "Sims4-Bericht",
  "csvGroup": "Gruppe",
  "csvMarked": "Markiert",
  "csvYes": "ja",
  "csvPath": "Pfad",
  "saved": "Liste gespeichert: {0}",
  "saveFailed": "Speichern fehlgeschlagen: {0}",
  "closeSims": "Bitte zuerst Sims 4 beenden.",
  "simsNotFound": "Der Sims 4 Ordner wurde nicht gefunden.",
  "cacheEmpty": "Der Cache ist schon leer.",
  "cacheTitle": "Sims-Cache leeren",
  "cacheConfirm": "Cache in{2}{0}{2}leeren? ({1} Dateien, sie landen im Papierkorb){2}{2}Sims 4 baut den Cache beim nächsten Start neu auf.",
  "cacheDone": "Cache geleert: {0} Dateien in den Papierkorb verschoben.",
  "cacheFail": " {0} konnten nicht gelöscht werden.",
  "browseDesc": "Ordner auswählen, z. B. deinen Sims 4 Mods-Ordner",
  "updateOpened": "Scarlet's Mod List wurde im Browser geöffnet. Dort nach dem Namen deiner Mod suchen (Strg+F oder Cmd+F).",
  "updSfw": "Mod List: nur SFW (ohne Inhalte für Erwachsene)",
  "updNsfw": "Mod List: SFW + NSFW (Inhalte für Erwachsene, ab 18)",
  "trashing": "Wird bearbeitet ...",
  "notModsFolder": "Diese Suche braucht deinen Mods-Ordner (oder einen Ordner darin). Der gewählte Ordner liegt nicht in einem Ordner namens \"Mods\".",
  "skippedNotEmpty": " {0} Ordner wurden übersprungen, weil sie nicht (mehr) leer sind."
 },
 "es": {
  "modes": [
   "Duplicados: mismo contenido (seguro)",
   "Duplicados: mismo nombre de archivo (rápido)",
   "Varias versiones del mismo mod (p. ej. v4.1 y v4.2)",
   "Todos los archivos de un tipo (p. ej. .png)",
   "Archivos innecesarios (comprimidos, léeme, imágenes, 0 bytes)",
   "Carpetas vacías",
   "Archivos más grandes",
   "Mods mal colocados (demasiado profundos)"
  ],
  "hints": [
   "Encuentra archivos con exactamente el mismo contenido, aunque tengan otro nombre.",
   "Encuentra archivos con el mismo nombre en distintas carpetas. El contenido puede ser diferente.",
   "Encuentra p. ej. \"Mod_v4.1\" y \"Mod_v4.2\" o \"Mod (1)\". Revísalos antes de borrar.",
   "Muestra todos los archivos de los tipos indicados. Separa varios tipos con comas.",
   "Muestra comprimidos, léeme, imágenes de vista previa y archivos vacíos. Los Sims 4 no los necesita.",
   "Muestra carpetas que ya no contienen ningún archivo.",
   "Muestra los 200 archivos más grandes para ver qué ocupa más espacio.",
   "Los Sims 4 carga .ts4script como máximo a 1 subcarpeta y .package como máximo a 5 subcarpetas."
  ],
  "title": "ModSweep for The Sims 4",
  "folder": "Carpeta:",
  "browse": "Examinar ...",
  "mode": "Búsqueda:",
  "filetype": "Tipo:",
  "simsOnly": "Solo archivos de Sims (.package y .ts4script)",
  "search": "Buscar",
  "colName": "Nombre",
  "colFolder": "Subcarpeta",
  "colSize": "Tamaño",
  "colDate": "Modificado",
  "btnExplorer": "Mostrar en la carpeta",
  "btnAuto": "Marcar (conservar el más nuevo)",
  "btnAll": "Marcar todo",
  "btnClear": "Desmarcar todo",
  "btnDelete": "Enviar marcados a la papelera",
  "btnSave": "Guardar lista (Excel)",
  "btnMove": "Colocar bien los marcados",
  "btnUpdate": "Comprobar actualizaciones en línea",
  "btnCache": "Vaciar caché de Sims",
  "mainFolder": "(carpeta principal)",
  "folderItem": "Carpeta",
  "folderNotFound": "No se encontró la carpeta.",
  "enterType": "Introduce un tipo de archivo, p. ej. .png",
  "collecting": "Recopilando archivos ...",
  "comparing": "Comparando contenido: {0} de {1} archivos ...",
  "groupDup": "Grupo {0}: {1}  ({2} archivos)",
  "groupVer": "Mod {0}: {1}  ({2} archivos)",
  "groupFolder": "{0}  ({1} archivos)",
  "hashNone": "No se encontraron duplicados ({0} archivos revisados).",
  "hashFound": "{0} grupos de archivos idénticos encontrados ({1} archivos revisados). Espacio desperdiciado: {2}",
  "nameNone": "No se encontraron nombres repetidos ({0} archivos revisados).",
  "nameFound": "{0} nombres de archivo aparecen más de una vez. Ojo: el contenido puede ser diferente.",
  "verNone": "No se encontraron mods con varias versiones.",
  "verFound": "{0} mods tienen varias versiones. El archivo más nuevo aparece arriba. Revísalos antes de borrar.",
  "typeNone": "No se encontraron archivos del tipo {0}.",
  "typeFound": "{0} archivos del tipo {1} encontrados en {2} carpetas, {3} en total.",
  "junkEmpty": "Archivos vacíos (0 bytes)",
  "junkArchive": "Comprimidos (.zip, .rar, .7z)",
  "junkText": "Textos y léeme",
  "junkImage": "Imágenes y vistas previas",
  "junkWin": "Restos del sistema (.DS_Store, archivos ._, Thumbs.db)",
  "junkNone": "No se encontraron archivos innecesarios.",
  "junkFound": "{0} archivos innecesarios encontrados, {1} en total. Borra los comprimidos solo si ya están descomprimidos.",
  "emptyGroup": "Carpetas vacías  ({0})",
  "emptyFound": "{0} carpetas vacías encontradas. Las subcarpetas vacías que contienen también se borran.",
  "emptyNone": "No se encontraron carpetas vacías.",
  "bigGroup": "Los {0} archivos más grandes",
  "bigFound": "Los {0} archivos en total: {1}. Haz clic en una columna para ordenar.",
  "noFiles": "No se encontraron archivos.",
  "depthScript": "Scripts (.ts4script), máximo 1 subcarpeta",
  "depthPkg": "Packages (.package), máximo 5 subcarpetas",
  "depthNone": "Todo bien: ningún mod está demasiado profundo.",
  "depthFound": "{0} archivos están demasiado profundos y el juego no los carga. Márcalos y haz clic en \"{1}\".",
  "explorerEmpty": "La lista está vacía. Haz clic primero en \"{0}\".",
  "explorerSelect": "Haz clic primero en una fila de la lista.",
  "autoMarked": "{0} archivos marcados. Se conserva el archivo más nuevo de cada grupo.",
  "allMarked": "{0} elementos marcados.",
  "nothingMarked": "No hay nada marcado.",
  "keepOne": "En \"{0}\" está todo marcado. Debe quedar al menos un archivo.",
  "confirmDelete": "¿Enviar {0} elementos a la papelera?",
  "deleting": "Enviando a la papelera: {0} de {1} ...",
  "deleted": "{0} elementos enviados a la papelera.",
  "deleteFailed": " {0} no se pudieron mover (¿el juego sigue abierto?).",
  "tHint": "Aviso",
  "tWarn": "Atención",
  "tConfirm": "Confirmar",
  "tError": "Error",
  "moveNone": "Marca primero los archivos que quieres mover.",
  "moveConfirm": "¿Subir {0} archivos para que Los Sims 4 los cargue?",
  "moved": "{0} archivos colocados correctamente.",
  "moveSkipped": " {0} omitidos (ya existe un archivo con el mismo nombre o el juego sigue abierto).",
  "listEmpty": "La lista está vacía. Busca primero.",
  "csvFilter": "Tabla de Excel (*.csv)|*.csv",
  "csvFile": "Sims4-Informe",
  "csvGroup": "Grupo",
  "csvMarked": "Marcado",
  "csvYes": "sí",
  "csvPath": "Ruta",
  "saved": "Lista guardada: {0}",
  "saveFailed": "Error al guardar: {0}",
  "closeSims": "Cierra primero Los Sims 4.",
  "simsNotFound": "No se encontró la carpeta de Los Sims 4.",
  "cacheEmpty": "La caché ya está vacía.",
  "cacheTitle": "Vaciar caché de Sims",
  "cacheConfirm": "¿Vaciar la caché en{2}{0}?{2}({1} archivos, irán a la papelera){2}{2}Los Sims 4 creará la caché de nuevo al iniciarse.",
  "cacheDone": "Caché vaciada: {0} archivos enviados a la papelera.",
  "cacheFail": " {0} no se pudieron borrar.",
  "browseDesc": "Elige una carpeta, p. ej. tu carpeta Mods de Los Sims 4",
  "updateOpened": "La Mod List de Scarlet se abrió en el navegador. Busca allí el nombre de tu mod (Ctrl+F o Cmd+F).",
  "updSfw": "Mod List: solo SFW (sin contenido para adultos)",
  "updNsfw": "Mod List: SFW + NSFW (contenido para adultos, +18)",
  "trashing": "Procesando ...",
  "notModsFolder": "Esta búsqueda necesita tu carpeta Mods (o una carpeta dentro de ella). La carpeta elegida no está dentro de una carpeta llamada \"Mods\".",
  "skippedNotEmpty": " Se omitieron {0} carpetas porque (ya) no están vacías."
 },
 "fr": {
  "modes": [
   "Doublons : même contenu (sûr)",
   "Doublons : même nom de fichier (rapide)",
   "Plusieurs versions du même mod (ex. v4.1 et v4.2)",
   "Tous les fichiers d'un type (ex. .png)",
   "Fichiers inutiles (archives, readme, images, 0 octet)",
   "Dossiers vides",
   "Fichiers les plus volumineux",
   "Mods mal rangés (trop profonds)"
  ],
  "hints": [
   "Trouve les fichiers au contenu identique, même s'ils portent un autre nom.",
   "Trouve les fichiers portant le même nom dans différents dossiers. Le contenu peut différer.",
   "Trouve par ex. \"Mod_v4.1\" et \"Mod_v4.2\" ou \"Mod (1)\". Vérifiez avant de supprimer.",
   "Affiche tous les fichiers des types indiqués. Séparez plusieurs types par des virgules.",
   "Affiche les archives, readme, images d'aperçu et fichiers vides. Sims 4 n'en a pas besoin.",
   "Affiche les dossiers qui ne contiennent plus aucun fichier.",
   "Affiche les 200 plus gros fichiers pour voir ce qui prend le plus de place.",
   "Sims 4 charge les .ts4script à 1 sous-dossier maximum et les .package à 5 sous-dossiers maximum."
  ],
  "title": "ModSweep for The Sims 4",
  "folder": "Dossier :",
  "browse": "Parcourir ...",
  "mode": "Recherche :",
  "filetype": "Type :",
  "simsOnly": "Fichiers Sims uniquement (.package et .ts4script)",
  "search": "Rechercher",
  "colName": "Nom",
  "colFolder": "Sous-dossier",
  "colSize": "Taille",
  "colDate": "Modifié",
  "btnExplorer": "Afficher dans le dossier",
  "btnAuto": "Cocher (garder le plus récent)",
  "btnAll": "Tout cocher",
  "btnClear": "Tout décocher",
  "btnDelete": "Mettre les cochés à la corbeille",
  "btnSave": "Enregistrer la liste (Excel)",
  "btnMove": "Ranger correctement les cochés",
  "btnUpdate": "Vérifier les mises à jour en ligne",
  "btnCache": "Vider le cache Sims",
  "mainFolder": "(dossier principal)",
  "folderItem": "Dossier",
  "folderNotFound": "Le dossier est introuvable.",
  "enterType": "Veuillez saisir un type de fichier, par ex. .png",
  "collecting": "Collecte des fichiers ...",
  "comparing": "Comparaison du contenu : {0} sur {1} fichiers ...",
  "groupDup": "Groupe {0} : {1}  ({2} fichiers)",
  "groupVer": "Mod {0} : {1}  ({2} fichiers)",
  "groupFolder": "{0}  ({1} fichiers)",
  "hashNone": "Aucun doublon trouvé ({0} fichiers vérifiés).",
  "hashFound": "{0} groupes de fichiers identiques trouvés ({1} fichiers vérifiés). Espace gaspillé : {2}",
  "nameNone": "Aucun nom de fichier en double ({0} fichiers vérifiés).",
  "nameFound": "{0} noms de fichiers apparaissent plusieurs fois. Attention : le contenu peut différer.",
  "verNone": "Aucun mod en plusieurs versions trouvé.",
  "verFound": "{0} mods existent en plusieurs versions. Le fichier le plus récent est en haut. Vérifiez avant de supprimer.",
  "typeNone": "Aucun fichier de type {0} trouvé.",
  "typeFound": "{0} fichiers de type {1} trouvés dans {2} dossiers, {3} au total.",
  "junkEmpty": "Fichiers vides (0 octet)",
  "junkArchive": "Archives (.zip, .rar, .7z)",
  "junkText": "Textes et readme",
  "junkImage": "Images et aperçus",
  "junkWin": "Restes du système (.DS_Store, fichiers ._, Thumbs.db)",
  "junkNone": "Aucun fichier inutile trouvé.",
  "junkFound": "{0} fichiers inutiles trouvés, {1} au total. Ne supprimez les archives que si elles sont déjà extraites.",
  "emptyGroup": "Dossiers vides  ({0})",
  "emptyFound": "{0} dossiers vides trouvés. Les sous-dossiers vides qu'ils contiennent seront aussi supprimés.",
  "emptyNone": "Aucun dossier vide trouvé.",
  "bigGroup": "Les {0} plus gros fichiers",
  "bigFound": "Les {0} fichiers au total : {1}. Cliquez sur une colonne pour trier.",
  "noFiles": "Aucun fichier trouvé.",
  "depthScript": "Scripts (.ts4script), 1 sous-dossier maximum",
  "depthPkg": "Packages (.package), 5 sous-dossiers maximum",
  "depthNone": "Tout va bien : aucun mod n'est trop profond.",
  "depthFound": "{0} fichiers sont trop profonds et ne sont pas chargés par le jeu. Cochez-les et cliquez sur \"{1}\".",
  "explorerEmpty": "La liste est vide. Cliquez d'abord sur \"{0}\".",
  "explorerSelect": "Cliquez d'abord sur une ligne de la liste.",
  "autoMarked": "{0} fichiers cochés. Le fichier le plus récent de chaque groupe est conservé.",
  "allMarked": "{0} éléments cochés.",
  "nothingMarked": "Rien n'est coché.",
  "keepOne": "Tout est coché dans \"{0}\". Au moins un fichier doit rester.",
  "confirmDelete": "Mettre {0} éléments à la corbeille ?",
  "deleting": "Mise à la corbeille : {0} sur {1} ...",
  "deleted": "{0} éléments mis à la corbeille.",
  "deleteFailed": " {0} n'ont pas pu être déplacés (le jeu est-il encore ouvert ?).",
  "tHint": "Remarque",
  "tWarn": "Attention",
  "tConfirm": "Confirmer",
  "tError": "Erreur",
  "moveNone": "Cochez d'abord les fichiers à déplacer.",
  "moveConfirm": "Remonter {0} fichiers pour que Sims 4 les charge ?",
  "moved": "{0} fichiers rangés correctement.",
  "moveSkipped": " {0} ignorés (un fichier du même nom existe déjà ou le jeu est encore ouvert).",
  "listEmpty": "La liste est vide. Lancez d'abord une recherche.",
  "csvFilter": "Tableau Excel (*.csv)|*.csv",
  "csvFile": "Sims4-Rapport",
  "csvGroup": "Groupe",
  "csvMarked": "Coché",
  "csvYes": "oui",
  "csvPath": "Chemin",
  "saved": "Liste enregistrée : {0}",
  "saveFailed": "Échec de l'enregistrement : {0}",
  "closeSims": "Veuillez d'abord fermer Sims 4.",
  "simsNotFound": "Le dossier Sims 4 est introuvable.",
  "cacheEmpty": "Le cache est déjà vide.",
  "cacheTitle": "Vider le cache Sims",
  "cacheConfirm": "Vider le cache dans{2}{0} ?{2}({1} fichiers, ils iront à la corbeille){2}{2}Sims 4 reconstruira le cache au prochain démarrage.",
  "cacheDone": "Cache vidé : {0} fichiers mis à la corbeille.",
  "cacheFail": " {0} n'ont pas pu être supprimés.",
  "browseDesc": "Choisissez un dossier, par ex. votre dossier Mods de Sims 4",
  "updateOpened": "La Mod List de Scarlet a été ouverte dans le navigateur. Cherchez-y le nom de votre mod (Ctrl+F ou Cmd+F).",
  "updSfw": "Mod List : SFW uniquement (sans contenu adulte)",
  "updNsfw": "Mod List : SFW + NSFW (contenu adulte, 18+)",
  "trashing": "Traitement en cours ...",
  "notModsFolder": "Cette recherche nécessite votre dossier Mods (ou un dossier à l'intérieur). Le dossier choisi ne se trouve pas dans un dossier nommé \"Mods\".",
  "skippedNotEmpty": " {0} dossiers ont été ignorés car ils ne sont pas (ou plus) vides."
 },
 "pl": {
  "modes": [
   "Duplikaty: ta sama zawartość (bezpieczne)",
   "Duplikaty: ta sama nazwa pliku (szybkie)",
   "Kilka wersji tego samego moda (np. v4.1 i v4.2)",
   "Wszystkie pliki danego typu (np. .png)",
   "Zbędne pliki (archiwa, readme, obrazy, 0 bajtów)",
   "Puste foldery",
   "Największe pliki",
   "Źle umieszczone mody (zbyt głęboko)"
  ],
  "hints": [
   "Znajduje pliki o identycznej zawartości, nawet jeśli mają inne nazwy.",
   "Znajduje pliki o tej samej nazwie w różnych folderach. Zawartość może się różnić.",
   "Znajduje np. \"Mod_v4.1\" i \"Mod_v4.2\" lub \"Mod (1)\". Sprawdź przed usunięciem.",
   "Pokazuje wszystkie pliki podanych typów. Kilka typów oddziel przecinkami.",
   "Pokazuje archiwa, pliki readme, obrazy podglądu i puste pliki. The Sims 4 ich nie potrzebuje.",
   "Pokazuje foldery, w których nie ma już żadnego pliku.",
   "Pokazuje 200 największych plików, aby było widać, co zajmuje najwięcej miejsca.",
   "The Sims 4 wczytuje pliki .ts4script najwyżej 1 podfolder w głąb, a pliki .package najwyżej 5."
  ],
  "title": "ModSweep for The Sims 4",
  "folder": "Folder:",
  "browse": "Przeglądaj ...",
  "mode": "Wyszukaj:",
  "filetype": "Typ pliku:",
  "simsOnly": "Tylko pliki Sims (.package i .ts4script)",
  "search": "Szukaj",
  "colName": "Nazwa",
  "colFolder": "Podfolder",
  "colSize": "Rozmiar",
  "colDate": "Zmodyfikowano",
  "btnExplorer": "Pokaż w folderze",
  "btnAuto": "Zaznacz (zostaw najnowszy)",
  "btnAll": "Zaznacz wszystko",
  "btnClear": "Odznacz wszystko",
  "btnDelete": "Przenieś zaznaczone do kosza",
  "btnSave": "Zapisz listę (Excel)",
  "btnMove": "Przenieś zaznaczone we właściwe miejsce",
  "btnUpdate": "Sprawdź aktualizacje online",
  "btnCache": "Wyczyść pamięć podręczną Sims",
  "mainFolder": "(folder główny)",
  "folderItem": "Folder",
  "folderNotFound": "Nie znaleziono folderu.",
  "enterType": "Wpisz typ pliku, np. .png",
  "collecting": "Zbieranie plików ...",
  "comparing": "Porównywanie zawartości: {0} z {1} plików ...",
  "groupDup": "Grupa {0}: {1}  (plików: {2})",
  "groupVer": "Mod {0}: {1}  (plików: {2})",
  "groupFolder": "{0}  (plików: {1})",
  "hashNone": "Nie znaleziono duplikatów (sprawdzono plików: {0}).",
  "hashFound": "Znaleziono grup identycznych plików: {0} (sprawdzono plików: {1}). Zmarnowane miejsce: {2}",
  "nameNone": "Nie znaleziono powtarzających się nazw (sprawdzono plików: {0}).",
  "nameFound": "Nazwy plików występujące wielokrotnie: {0}. Uwaga: zawartość może się różnić.",
  "verNone": "Nie znaleziono modów w kilku wersjach.",
  "verFound": "Mody w kilku wersjach: {0}. Najnowszy plik jest na górze. Sprawdź przed usunięciem.",
  "typeNone": "Nie znaleziono plików typu {0}.",
  "typeFound": "Znaleziono plików typu {1}: {0} w folderach: {2}, łącznie {3}.",
  "junkEmpty": "Puste pliki (0 bajtów)",
  "junkArchive": "Archiwa (.zip, .rar, .7z)",
  "junkText": "Teksty i instrukcje",
  "junkImage": "Obrazy i podglądy",
  "junkWin": "Pozostałości systemu (.DS_Store, pliki ._, Thumbs.db)",
  "junkNone": "Nie znaleziono zbędnych plików.",
  "junkFound": "Znaleziono zbędnych plików: {0}, łącznie {1}. Usuwaj archiwa tylko wtedy, gdy są już rozpakowane.",
  "emptyGroup": "Puste foldery  ({0})",
  "emptyFound": "Znaleziono pustych folderów: {0}. Puste podfoldery w nich też zostaną usunięte.",
  "emptyNone": "Nie znaleziono pustych folderów.",
  "bigGroup": "{0} największych plików",
  "bigFound": "Wszystkie pliki ({0}) razem: {1}. Kliknij kolumnę, aby posortować.",
  "noFiles": "Nie znaleziono plików.",
  "depthScript": "Skrypty (.ts4script), dozwolony najwyżej 1 podfolder",
  "depthPkg": "Pakiety (.package), dozwolonych najwyżej 5 podfolderów",
  "depthNone": "Wszystko w porządku: żaden mod nie leży za głęboko.",
  "depthFound": "Plików leżących za głęboko: {0}. Gra ich nie wczytuje. Zaznacz je i kliknij \"{1}\".",
  "explorerEmpty": "Lista jest pusta. Najpierw kliknij \"{0}\".",
  "explorerSelect": "Najpierw kliknij wiersz na liście.",
  "autoMarked": "Zaznaczono plików: {0}. Najnowszy plik z każdej grupy zostaje.",
  "allMarked": "Zaznaczono elementów: {0}.",
  "nothingMarked": "Nic nie jest zaznaczone.",
  "keepOne": "W \"{0}\" zaznaczono wszystko. Przynajmniej jeden plik powinien zostać.",
  "confirmDelete": "Przenieść do kosza elementów: {0}?",
  "deleting": "Przenoszenie do kosza: {0} z {1} ...",
  "deleted": "Przeniesiono do kosza elementów: {0}.",
  "deleteFailed": " Nie udało się przenieść: {0} (czy gra jest jeszcze otwarta?).",
  "tHint": "Informacja",
  "tWarn": "Uwaga",
  "tConfirm": "Potwierdź",
  "tError": "Błąd",
  "moveNone": "Najpierw zaznacz pliki do przeniesienia.",
  "moveConfirm": "Przenieść wyżej plików: {0}, aby The Sims 4 je wczytało?",
  "moved": "Prawidłowo przeniesiono plików: {0}.",
  "moveSkipped": " Pominięto: {0} (plik o tej nazwie już istnieje lub gra jest otwarta).",
  "listEmpty": "Lista jest pusta. Najpierw wyszukaj.",
  "csvFilter": "Tabela Excel (*.csv)|*.csv",
  "csvFile": "Sims4-Raport",
  "csvGroup": "Grupa",
  "csvMarked": "Zaznaczone",
  "csvYes": "tak",
  "csvPath": "Ścieżka",
  "saved": "Zapisano listę: {0}",
  "saveFailed": "Zapis nie powiódł się: {0}",
  "closeSims": "Najpierw zamknij The Sims 4.",
  "simsNotFound": "Nie znaleziono folderu The Sims 4.",
  "cacheEmpty": "Pamięć podręczna jest już pusta.",
  "cacheTitle": "Wyczyść pamięć podręczną Sims",
  "cacheConfirm": "Wyczyścić pamięć podręczną w{2}{0}?{2}(plików: {1}, trafią do kosza){2}{2}The Sims 4 utworzy ją ponownie przy następnym uruchomieniu.",
  "cacheDone": "Wyczyszczono pamięć podręczną. Przeniesiono do kosza plików: {0}.",
  "cacheFail": " Nie udało się usunąć: {0}.",
  "browseDesc": "Wybierz folder, np. folder Mods gry The Sims 4",
  "updateOpened": "Mod List od Scarlet otwarto w przeglądarce. Wyszukaj tam nazwę swojego moda (Ctrl+F lub Cmd+F).",
  "updSfw": "Mod List: tylko SFW (bez treści dla dorosłych)",
  "updNsfw": "Mod List: SFW + NSFW (treści dla dorosłych, 18+)",
  "trashing": "Przetwarzanie ...",
  "notModsFolder": "To wyszukiwanie wymaga folderu Mods (lub folderu wewnątrz niego). Wybrany folder nie znajduje się w folderze o nazwie \"Mods\".",
  "skippedNotEmpty": " Pominięto folderów: {0}, ponieważ nie są (już) puste."
 },
 "pt": {
  "modes": [
   "Duplicados: mesmo conteúdo (seguro)",
   "Duplicados: mesmo nome de arquivo (rápido)",
   "Várias versões do mesmo mod (ex. v4.1 e v4.2)",
   "Todos os arquivos de um tipo (ex. .png)",
   "Arquivos desnecessários (compactados, leia-me, imagens, 0 bytes)",
   "Pastas vazias",
   "Maiores arquivos",
   "Mods no lugar errado (muito profundos)"
  ],
  "hints": [
   "Encontra arquivos com exatamente o mesmo conteúdo, mesmo com nomes diferentes.",
   "Encontra arquivos com o mesmo nome em pastas diferentes. O conteúdo pode ser diferente.",
   "Encontra ex. \"Mod_v4.1\" e \"Mod_v4.2\" ou \"Mod (1)\". Confira antes de excluir.",
   "Mostra todos os arquivos dos tipos informados. Separe vários tipos com vírgulas.",
   "Mostra compactados, leia-me, imagens de prévia e arquivos vazios. O The Sims 4 não precisa deles.",
   "Mostra pastas que não contêm mais nenhum arquivo.",
   "Mostra os 200 maiores arquivos para você ver o que ocupa mais espaço.",
   "O The Sims 4 carrega .ts4script no máximo 1 subpasta abaixo e .package no máximo 5 subpastas abaixo."
  ],
  "title": "ModSweep for The Sims 4",
  "folder": "Pasta:",
  "browse": "Procurar ...",
  "mode": "Pesquisa:",
  "filetype": "Tipo:",
  "simsOnly": "Somente arquivos do Sims (.package e .ts4script)",
  "search": "Pesquisar",
  "colName": "Nome",
  "colFolder": "Subpasta",
  "colSize": "Tamanho",
  "colDate": "Modificado",
  "btnExplorer": "Mostrar na pasta",
  "btnAuto": "Marcar (manter o mais novo)",
  "btnAll": "Marcar tudo",
  "btnClear": "Desmarcar tudo",
  "btnDelete": "Mover marcados para a Lixeira",
  "btnSave": "Salvar lista (Excel)",
  "btnMove": "Organizar marcados corretamente",
  "btnUpdate": "Verificar atualizações online",
  "btnCache": "Limpar cache do Sims",
  "mainFolder": "(pasta principal)",
  "folderItem": "Pasta",
  "folderNotFound": "A pasta não foi encontrada.",
  "enterType": "Informe um tipo de arquivo, ex. .png",
  "collecting": "Coletando arquivos ...",
  "comparing": "Comparando conteúdo: {0} de {1} arquivos ...",
  "groupDup": "Grupo {0}: {1}  ({2} arquivos)",
  "groupVer": "Mod {0}: {1}  ({2} arquivos)",
  "groupFolder": "{0}  ({1} arquivos)",
  "hashNone": "Nenhum duplicado encontrado ({0} arquivos verificados).",
  "hashFound": "{0} grupos de arquivos idênticos encontrados ({1} arquivos verificados). Espaço desperdiçado: {2}",
  "nameNone": "Nenhum nome de arquivo repetido ({0} arquivos verificados).",
  "nameFound": "{0} nomes de arquivo aparecem mais de uma vez. Atenção: o conteúdo pode ser diferente.",
  "verNone": "Nenhum mod com várias versões encontrado.",
  "verFound": "{0} mods existem em várias versões. O arquivo mais novo aparece em cima. Confira antes de excluir.",
  "typeNone": "Nenhum arquivo do tipo {0} encontrado.",
  "typeFound": "{0} arquivos do tipo {1} encontrados em {2} pastas, {3} no total.",
  "junkEmpty": "Arquivos vazios (0 bytes)",
  "junkArchive": "Compactados (.zip, .rar, .7z)",
  "junkText": "Textos e leia-me",
  "junkImage": "Imagens e prévias",
  "junkWin": "Restos do sistema (.DS_Store, arquivos ._, Thumbs.db)",
  "junkNone": "Nenhum arquivo desnecessário encontrado.",
  "junkFound": "{0} arquivos desnecessários encontrados, {1} no total. Só exclua compactados que já foram extraídos.",
  "emptyGroup": "Pastas vazias  ({0})",
  "emptyFound": "{0} pastas vazias encontradas. Subpastas vazias dentro delas também serão excluídas.",
  "emptyNone": "Nenhuma pasta vazia encontrada.",
  "bigGroup": "Os {0} maiores arquivos",
  "bigFound": "Todos os {0} arquivos juntos: {1}. Clique em uma coluna para ordenar.",
  "noFiles": "Nenhum arquivo encontrado.",
  "depthScript": "Scripts (.ts4script), no máximo 1 subpasta",
  "depthPkg": "Packages (.package), no máximo 5 subpastas",
  "depthNone": "Tudo certo: nenhum mod está fundo demais.",
  "depthFound": "{0} arquivos estão fundo demais e não são carregados pelo jogo. Marque-os e clique em \"{1}\".",
  "explorerEmpty": "A lista está vazia. Clique primeiro em \"{0}\".",
  "explorerSelect": "Clique primeiro em uma linha da lista.",
  "autoMarked": "{0} arquivos marcados. O arquivo mais novo de cada grupo é mantido.",
  "allMarked": "{0} itens marcados.",
  "nothingMarked": "Nada está marcado.",
  "keepOne": "Tudo está marcado em \"{0}\". Pelo menos um arquivo deve ficar.",
  "confirmDelete": "Mover {0} itens para a Lixeira?",
  "deleting": "Movendo para a Lixeira: {0} de {1} ...",
  "deleted": "{0} itens movidos para a Lixeira.",
  "deleteFailed": " {0} não puderam ser movidos (o jogo ainda está aberto?).",
  "tHint": "Aviso",
  "tWarn": "Atenção",
  "tConfirm": "Confirmar",
  "tError": "Erro",
  "moveNone": "Marque primeiro os arquivos que devem ser movidos.",
  "moveConfirm": "Mover {0} arquivos para cima para que o The Sims 4 os carregue?",
  "moved": "{0} arquivos organizados corretamente.",
  "moveSkipped": " {0} ignorados (já existe um arquivo com o mesmo nome ou o jogo ainda está aberto).",
  "listEmpty": "A lista está vazia. Pesquise primeiro.",
  "csvFilter": "Planilha do Excel (*.csv)|*.csv",
  "csvFile": "Sims4-Relatorio",
  "csvGroup": "Grupo",
  "csvMarked": "Marcado",
  "csvYes": "sim",
  "csvPath": "Caminho",
  "saved": "Lista salva: {0}",
  "saveFailed": "Falha ao salvar: {0}",
  "closeSims": "Feche o The Sims 4 primeiro.",
  "simsNotFound": "A pasta do The Sims 4 não foi encontrada.",
  "cacheEmpty": "O cache já está vazio.",
  "cacheTitle": "Limpar cache do Sims",
  "cacheConfirm": "Limpar o cache em{2}{0}?{2}({1} arquivos, irão para a Lixeira){2}{2}O The Sims 4 recria o cache na próxima vez que iniciar.",
  "cacheDone": "Cache limpo: {0} arquivos movidos para a Lixeira.",
  "cacheFail": " {0} não puderam ser excluídos.",
  "browseDesc": "Escolha uma pasta, ex. sua pasta Mods do The Sims 4",
  "updateOpened": "A Mod List da Scarlet foi aberta no navegador. Procure lá o nome do seu mod (Ctrl+F ou Cmd+F).",
  "updSfw": "Mod List: somente SFW (sem conteúdo adulto)",
  "updNsfw": "Mod List: SFW + NSFW (conteúdo adulto, 18+)",
  "trashing": "Processando ...",
  "notModsFolder": "Esta pesquisa precisa da sua pasta Mods (ou de uma pasta dentro dela). A pasta escolhida não está dentro de uma pasta chamada \"Mods\".",
  "skippedNotEmpty": " {0} pastas foram ignoradas porque não estão (mais) vazias."
 }
}''')

MODE_HASH, MODE_NAME, MODE_VERSION, MODE_TYPE, MODE_JUNK, MODE_EMPTY, MODE_BIG, MODE_DEPTH = range(8)
DUP_MODES = (MODE_HASH, MODE_NAME, MODE_VERSION)
SIMS_ONLY_MODES = (MODE_HASH, MODE_NAME, MODE_VERSION, MODE_BIG)
SIMS_EXTS = ('.package', '.ts4script')

SIMS_FOLDER_NAMES = ['The Sims 4', 'Die Sims 4', 'Les Sims 4', 'Los Sims 4', 'De Sims 4', 'I Sims 4']

URL_SFW = 'https://scarletsrealm.com/the-mod-list-sfw-only-edition/'
URL_NSFW = 'https://scarletsrealm.com/the-mod-list-sfw-nsfw-edition/'

DATE_FORMATS = {
    'en': '%Y-%m-%d %H:%M', 'de': '%d.%m.%Y %H:%M', 'es': '%d/%m/%Y %H:%M',
    'fr': '%d/%m/%Y %H:%M', 'pl': '%d.%m.%Y %H:%M', 'pt': '%d/%m/%Y %H:%M',
}


# =====================================================================
# Settings
# =====================================================================
def settings_dir():
    if IS_MAC:
        return os.path.expanduser('~/Library/Application Support/ModSweep')
    base = os.environ.get('XDG_CONFIG_HOME') or os.path.expanduser('~/.config')
    return os.path.join(base, 'ModSweep')


def load_language():
    try:
        with open(os.path.join(settings_dir(), 'language.txt'), encoding='utf-8') as f:
            code = f.read().strip()
        if code in LANG_CODES:
            return code
    except OSError:
        pass
    return 'en'


def save_language(code):
    try:
        os.makedirs(settings_dir(), exist_ok=True)
        with open(os.path.join(settings_dir(), 'language.txt'), 'w', encoding='utf-8') as f:
            f.write(code)
    except OSError:
        pass


# =====================================================================
# Finding the Sims 4 folder
# =====================================================================
def document_folders():
    home = os.path.expanduser('~')
    docs = [os.path.join(home, 'Documents')]
    if not IS_MAC:
        try:
            out = subprocess.run(['xdg-user-dir', 'DOCUMENTS'], capture_output=True, text=True, timeout=3).stdout.strip()
            if out and out not in docs:
                docs.append(out)
        except (OSError, subprocess.SubprocessError):
            pass
        # Sims 4 through Steam Proton, Flatpak Steam or plain Wine
        steam_roots = [
            os.path.join(home, '.steam', 'steam'),
            os.path.join(home, '.local', 'share', 'Steam'),
            os.path.join(home, '.var', 'app', 'com.valvesoftware.Steam', '.local', 'share', 'Steam'),
        ]
        for root in steam_roots:
            docs += glob.glob(os.path.join(root, 'steamapps', 'compatdata', '*', 'pfx', 'drive_c', 'users', 'steamuser', 'Documents'))
            docs += glob.glob(os.path.join(root, 'steamapps', 'compatdata', '*', 'pfx', 'drive_c', 'users', 'steamuser', 'My Documents'))
        for prefix in [os.path.join(home, '.wine')] + glob.glob(os.path.join(home, 'Games', '*')):
            docs += glob.glob(os.path.join(prefix, 'drive_c', 'users', '*', 'Documents'))
            docs += glob.glob(os.path.join(prefix, 'drive_c', 'users', '*', 'My Documents'))
    return docs


def find_sims_folder(mods_hint=None):
    if mods_hint:
        p = mods_hint.rstrip('/\\')
        if os.path.basename(p).lower() == 'mods':
            parent = os.path.dirname(p)
            # Only accept it if it really is the Sims 4 folder, not e.g. Minecraft/Mods
            if os.path.isdir(parent) and (
                    os.path.basename(parent) in SIMS_FOLDER_NAMES
                    or os.path.exists(os.path.join(parent, 'localthumbcache.package'))
                    or os.path.exists(os.path.join(parent, 'Options.ini'))):
                return parent
    for d in document_folders():
        for n in SIMS_FOLDER_NAMES:
            c = os.path.join(d, 'Electronic Arts', n)
            if os.path.isdir(c):
                return c
    return None


def find_mods_folder():
    sims = find_sims_folder()
    if sims and os.path.isdir(os.path.join(sims, 'Mods')):
        return os.path.join(sims, 'Mods')
    docs = os.path.join(os.path.expanduser('~'), 'Documents')
    return docs if os.path.isdir(docs) else os.path.expanduser('~')


# =====================================================================
# Helpers
# =====================================================================
def format_size(n):
    if n >= 1024 ** 3:
        return '%.2f GB' % (n / 1024 ** 3)
    if n >= 1024 ** 2:
        return '%.2f MB' % (n / 1024 ** 2)
    if n >= 1024:
        return '%.1f KB' % (n / 1024)
    return '%d B' % n


def rel_dir(directory, root, main_label):
    rel = os.path.relpath(directory, root)
    if rel == '.':
        return main_label
    if rel.startswith('..'):
        return directory
    return rel


def depth_of(directory, root):
    rel = os.path.relpath(directory, root)
    if rel == '.' or rel.startswith('..'):
        return 0
    return len([p for p in rel.split(os.sep) if p])


def parse_extensions(text):
    result = []
    for part in re.split(r'[,; ]+', text or ''):
        p = part.strip().strip('*').lower()
        if not p:
            continue
        if not p.startswith('.'):
            p = '.' + p
        result.append(p)
    return result


VERSION_RX = re.compile(r'[\s_\-\.]*((?<![a-z])v(er(sion)?)?[\s_\.]?\d+([\._]\d+)*[a-z]?|\d+\.\d+(\.\d+)*[a-z]?|\(\d+\)|(?<![a-z])(kopie|copy)(?![a-z]))')


def version_key(name):
    base = os.path.splitext(name)[0].lower()
    return VERSION_RX.sub('', base).strip(' _-.')


def is_system_leftover(name):
    low = name.lower()
    return low in ('.ds_store', 'thumbs.db', 'desktop.ini') or name.startswith('._')


def make_entry(path, size, mtime, is_folder=False):
    return {'path': path, 'name': os.path.basename(path), 'dir': os.path.dirname(path),
            'size': size, 'mtime': mtime, 'is_folder': is_folder, 'target': None}


def collect(root):
    """Returns (files, dirs, bad). Files are entries, dirs are folder paths,
    bad are folders that could not be read or are links (never treated as empty)."""
    files, dirs, bad = [], [], set()

    def on_error(e):
        bad.add(getattr(e, 'filename', None) or root)

    for current, subdirs, names in os.walk(root, onerror=on_error):
        # do not follow symbolic links to folders
        links = [d for d in subdirs if os.path.islink(os.path.join(current, d))]
        for d in links:
            bad.add(os.path.join(current, d))
        subdirs[:] = [d for d in subdirs if d not in links]
        for d in subdirs:
            dirs.append(os.path.join(current, d))
        for n in names:
            p = os.path.join(current, n)
            try:
                st = os.lstat(p)
            except OSError:
                continue
            if not os.path.isfile(p) or os.path.islink(p):
                continue
            files.append(make_entry(p, st.st_size, st.st_mtime))
    return files, dirs, bad


def folder_still_empty(path):
    """True if a folder holds nothing but system leftovers and could be read completely."""
    if not os.path.isdir(path) or os.path.islink(path):
        return False
    files, _dirs, bad = collect(path)
    if bad:
        return False
    return all(is_system_leftover(f['name']) for f in files)


def find_mods_base(path):
    """Returns the folder named Mods that contains path (or path itself), else None."""
    p = os.path.abspath(path)
    while True:
        if os.path.basename(p).lower() == 'mods':
            return p
        parent = os.path.dirname(p)
        if not parent or parent == p:
            return None
        p = parent


def file_hash(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


# =====================================================================
# Search (runs without a window, so it can be tested on its own)
# =====================================================================
def run_scan(mode, root, sims_only, exts, T, progress=lambda text: None):
    """Returns {'groups': [{'header': str, 'items': [entry]}], 'msg': str, 'warn': bool}."""
    root = os.path.abspath(root).rstrip(os.sep) or os.sep
    main = T('mainFolder')
    progress(T('collecting'))
    files, dirs, bad = collect(root)
    warn = False
    if mode != MODE_JUNK:
        # Mac and Windows leftovers like ._name or .DS_Store are not real mods
        files = [f for f in files if not is_system_leftover(f['name'])]
    if sims_only and mode in SIMS_ONLY_MODES:
        files = [f for f in files if os.path.splitext(f['name'])[1].lower() in SIMS_EXTS]
    groups = []

    def dup_groups(raw, key):
        out = []
        for n, items in enumerate(raw, 1):
            items = sorted(items, key=lambda e: e['mtime'], reverse=True)
            out.append({'header': T(key).format(n, items[0]['name'], len(items)), 'items': items})
        return out

    if mode == MODE_HASH:
        by_size = {}
        for f in files:
            if f['size'] > 0:   # empty files belong to "unneeded files", not duplicates
                by_size.setdefault(f['size'], []).append(f)
        to_hash = [f for v in by_size.values() if len(v) > 1 for f in v]
        by_hash = {}
        for i, f in enumerate(to_hash, 1):
            if i % 10 == 0:
                progress(T('comparing').format(i, len(to_hash)))
            try:
                h = file_hash(f['path'])
            except OSError:
                continue
            by_hash.setdefault((f['size'], h), []).append(f)
        raw = [v for v in by_hash.values() if len(v) > 1]
        raw.sort(key=lambda v: max(v, key=lambda e: e['mtime'])['name'].lower())
        wasted = sum(v[0]['size'] * (len(v) - 1) for v in raw)
        groups = dup_groups(raw, 'groupDup')
        msg = T('hashNone').format(len(files)) if not groups else T('hashFound').format(len(groups), len(files), format_size(wasted))

    elif mode == MODE_NAME:
        by_name = {}
        for f in files:
            by_name.setdefault(f['name'].lower(), []).append(f)
        raw = [v for k, v in sorted(by_name.items()) if len(v) > 1]
        groups = dup_groups(raw, 'groupDup')
        msg = T('nameNone').format(len(files)) if not groups else T('nameFound').format(len(groups))

    elif mode == MODE_VERSION:
        by_key = {}
        for f in files:
            k = version_key(f['name']) + '|' + os.path.splitext(f['name'])[1].lower()
            by_key.setdefault(k, []).append(f)
        raw = []
        for k, v in sorted(by_key.items()):
            if len(v) < 2 or len(k.split('|')[0]) < 3:
                continue
            if len({f['name'].lower() for f in v}) < 2:
                continue
            raw.append(v)
        groups = dup_groups(raw, 'groupVer')
        msg = T('verNone') if not groups else T('verFound').format(len(groups))

    elif mode == MODE_TYPE:
        found = [f for f in files if os.path.splitext(f['name'])[1].lower() in exts]
        by_dir = {}
        for f in found:
            by_dir.setdefault(f['dir'], []).append(f)
        for d in sorted(by_dir, key=str.lower):
            items = sorted(by_dir[d], key=lambda e: e['name'].lower())
            groups.append({'header': T('groupFolder').format(rel_dir(d, root, main), len(items)), 'items': items})
        typ = ', '.join(exts)
        total = sum(f['size'] for f in found)
        msg = T('typeNone').format(typ) if not found else T('typeFound').format(len(found), typ, len(by_dir), format_size(total))

    elif mode == MODE_JUNK:
        cats = {k: [] for k in ('junkEmpty', 'junkArchive', 'junkText', 'junkImage', 'junkWin')}
        archive = ('.zip', '.rar', '.7z')
        texts = ('.txt', '.pdf', '.url', '.html', '.htm', '.md', '.rtf', '.doc', '.docx')
        images = ('.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp')
        for f in files:
            e = os.path.splitext(f['name'])[1].lower()
            if is_system_leftover(f['name']) or '__MACOSX' in f['path'].split(os.sep):
                cats['junkWin'].append(f)
            elif f['size'] == 0:
                cats['junkEmpty'].append(f)
            elif e in archive:
                cats['junkArchive'].append(f)
            elif e in texts:
                cats['junkText'].append(f)
            elif e in images:
                cats['junkImage'].append(f)
        count = total = 0
        for k in ('junkEmpty', 'junkArchive', 'junkText', 'junkImage', 'junkWin'):
            items = sorted(cats[k], key=lambda e: e['path'].lower())
            if not items:
                continue
            groups.append({'header': T('groupFolder').format(T(k), len(items)), 'items': items})
            count += len(items)
            total += sum(f['size'] for f in items)
        msg = T('junkNone') if not count else T('junkFound').format(count, format_size(total))

    elif mode == MODE_EMPTY:
        # A folder counts as empty if it holds no files except system leftovers like .DS_Store
        with_files = set()
        keep = [f['dir'] for f in files if not is_system_leftover(f['name'])] + list(bad)
        for d in keep:
            while len(d) > len(root) and d not in with_files:
                with_files.add(d)
                d = os.path.dirname(d)
        empty = {d for d in dirs if d not in with_files}
        top = sorted((d for d in empty if os.path.dirname(d) not in empty), key=str.lower)
        if top:
            items = []
            for d in top:
                try:
                    mt = os.stat(d).st_mtime
                except OSError:
                    mt = 0
                items.append(make_entry(d, 0, mt, True))
            groups.append({'header': T('emptyGroup').format(len(items)), 'items': items})
            msg = T('emptyFound').format(len(items))
        else:
            msg = T('emptyNone')

    elif mode == MODE_BIG:
        big = sorted(files, key=lambda e: e['size'], reverse=True)[:200]
        if big:
            groups.append({'header': T('bigGroup').format(len(big)), 'items': big})
            msg = T('bigFound').format(len(files), format_size(sum(f['size'] for f in files)))
        else:
            msg = T('noFiles')

    elif mode == MODE_DEPTH:
        scripts, packages = [], []
        # Depth always counts from the folder named Mods
        base = find_mods_base(root)
        if not base:
            return {'groups': [], 'msg': T('notModsFolder'), 'warn': True}
        for f in sorted(files, key=lambda e: e['path'].lower()):
            e = os.path.splitext(f['name'])[1].lower()
            if e == '.ts4script':
                limit = 1
            elif e == '.package':
                limit = 5
            else:
                continue
            if depth_of(f['dir'], base) <= limit:
                continue
            parts = [p for p in os.path.relpath(f['dir'], base).split(os.sep) if p]
            f['target'] = os.path.join(base, *parts[:limit])
            (scripts if e == '.ts4script' else packages).append(f)
        if scripts:
            groups.append({'header': T('depthScript'), 'items': scripts})
        if packages:
            groups.append({'header': T('depthPkg'), 'items': packages})
        count = len(scripts) + len(packages)
        msg = T('depthNone') if not count else T('depthFound').format(count, T('btnMove'))
    else:
        msg = ''

    return {'groups': groups, 'msg': msg, 'warn': warn}


# =====================================================================
# Trash, folders, processes
# =====================================================================
def _applescript_quote(path):
    return '"' + path.replace('\\', '\\\\').replace('"', '\\"') + '"'


def _run_ok(cmd, timeout=60):
    try:
        return subprocess.run(cmd, capture_output=True, timeout=timeout).returncode == 0
    except (OSError, subprocess.SubprocessError):
        return False


def _unique_target(folder, name):
    target = os.path.join(folder, name)
    base, ext = os.path.splitext(name)
    n = 1
    while os.path.lexists(target):
        n += 1
        target = os.path.join(folder, '%s %d%s' % (base, n, ext))
    return target


def _freedesktop_trash(path):
    """Moves a file into the standard Linux trash (~/.local/share/Trash)."""
    data = os.environ.get('XDG_DATA_HOME') or os.path.expanduser('~/.local/share')
    files_dir = os.path.join(data, 'Trash', 'files')
    info_dir = os.path.join(data, 'Trash', 'info')
    os.makedirs(files_dir, exist_ok=True)
    os.makedirs(info_dir, exist_ok=True)
    target = _unique_target(files_dir, os.path.basename(path))
    name = os.path.basename(target)
    info = os.path.join(info_dir, name + '.trashinfo')
    with open(info, 'w', encoding='utf-8') as f:
        f.write('[Trash Info]\nPath=%s\nDeletionDate=%s\n' % (
            urllib.parse.quote(os.path.abspath(path)),
            datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S')))
    try:
        shutil.move(path, target)
    except OSError:
        os.remove(info)   # do not leave an orphan entry in the trash
        raise
    return True


def move_to_trash(paths, progress=lambda done, total: None):
    """Returns the list of paths that were moved to the Trash."""
    paths = [p for p in paths if os.path.lexists(p)]
    done = []
    total = len(paths)
    if IS_MAC:
        # Finder supports "Put Back". Several files per call keeps it fast.
        for i in range(0, total, 40):
            chunk = paths[i:i + 40]
            script = 'tell application "Finder" to delete {' + ', '.join(
                'POSIX file ' + _applescript_quote(p) for p in chunk) + '}'
            _run_ok(['osascript', '-e', script], timeout=300)
            for p in chunk:
                if os.path.lexists(p):
                    try:
                        shutil.move(p, _unique_target(os.path.expanduser('~/.Trash'), os.path.basename(p)))
                    except OSError:
                        pass
                if not os.path.lexists(p):
                    done.append(p)
            progress(min(i + 40, total), total)
        return done
    for i, p in enumerate(paths, 1):
        for cmd in (['gio', 'trash', '--', p], ['kioclient6', 'move', p, 'trash:/'],
                    ['kioclient5', 'move', p, 'trash:/'], ['trash-put', '--', p]):
            if shutil.which(cmd[0]) and _run_ok(cmd) and not os.path.lexists(p):
                break
        if os.path.lexists(p):
            try:
                _freedesktop_trash(p)
            except OSError:
                pass
        if not os.path.lexists(p):
            done.append(p)
        if i % 10 == 0:
            progress(i, total)
    return done


def show_in_folder(path):
    if IS_MAC:
        subprocess.Popen(['open', '-R', path])
        return
    uri = 'file://' + urllib.parse.quote(path)
    if shutil.which('dbus-send') and _run_ok([
            'dbus-send', '--session', '--dest=org.freedesktop.FileManager1', '--type=method_call',
            '/org/freedesktop/FileManager1', 'org.freedesktop.FileManager1.ShowItems',
            'array:string:' + uri, 'string:'], timeout=5):
        return
    folder = path if os.path.isdir(path) else os.path.dirname(path)
    subprocess.Popen(['xdg-open', folder])


def sims_is_running():
    if not shutil.which('pgrep'):
        return False
    return _run_ok(['pgrep', '-f', r'TS4_x64|TS4_DX9_x64|The Sims 4\.app/Contents/MacOS'], timeout=5)


# =====================================================================
# Window
# =====================================================================
def run_gui():
    import tkinter as tk
    from tkinter import ttk, filedialog, messagebox
    from tkinter import font as tkfont

    class App:
        def __init__(self, root):
            self.root = root
            self.lang = load_language()
            self.entries = {}       # iid -> entry
            self.checked = set()    # iids
            self.groups = []        # [{'header', 'iids'}]
            self.last_mode = -1
            self.sort_col = None
            self.sort_asc = True
            self.busy = False
            self._progress = None
            self._result = None

            root.geometry('1120x720')
            root.minsize(980, 480)
            try:
                self.icon = tk.PhotoImage(file=os.path.join(APP_DIR, 'icon.png'))
                root.iconphoto(True, self.icon)
            except Exception:
                pass

            self.bold_font = tkfont.nametofont('TkDefaultFont').copy()
            self.bold_font.configure(weight='bold')
            style = ttk.Style()
            style.configure('Danger.TButton', foreground='#a01010')
            style.configure('Bold.TButton', font=self.bold_font)

            # Top area
            top = ttk.Frame(root, padding=(10, 10, 10, 4))
            top.pack(fill='x')
            top.columnconfigure(1, weight=1)

            self.lbl_folder = ttk.Label(top)
            self.lbl_folder.grid(row=0, column=0, sticky='w', padx=(0, 8))
            self.var_folder = tk.StringVar(value=find_mods_folder())
            ttk.Entry(top, textvariable=self.var_folder).grid(row=0, column=1, columnspan=3, sticky='ew', pady=3)
            self.btn_browse = ttk.Button(top, command=self.browse, width=20)
            self.btn_browse.grid(row=0, column=4, sticky='ew', padx=(8, 0))

            self.lbl_mode = ttk.Label(top)
            self.lbl_mode.grid(row=1, column=0, sticky='w', padx=(0, 8))
            self.cmb_mode = ttk.Combobox(top, state='readonly', width=58)
            self.cmb_mode.grid(row=1, column=1, sticky='w', pady=3)
            self.cmb_mode.bind('<<ComboboxSelected>>', lambda e: self.update_mode_controls())
            self.lbl_ext = ttk.Label(top)
            self.lbl_ext.grid(row=1, column=2, sticky='e', padx=(10, 4))
            self.var_ext = tk.StringVar(value='.png')
            self.ent_ext = ttk.Entry(top, textvariable=self.var_ext, width=14)
            self.ent_ext.grid(row=1, column=3, sticky='w')
            self.cmb_lang = ttk.Combobox(top, state='readonly', values=LANG_NAMES, width=20)
            self.cmb_lang.grid(row=1, column=4, sticky='ew', padx=(8, 0))
            self.cmb_lang.current(LANG_CODES.index(self.lang))
            self.cmb_lang.bind('<<ComboboxSelected>>', self.change_language)

            self.var_sims = tk.BooleanVar(value=True)
            self.chk_sims = ttk.Checkbutton(top, variable=self.var_sims)
            self.chk_sims.grid(row=2, column=1, sticky='w', pady=3)
            self.btn_scan = ttk.Button(top, command=self.start_scan, style='Bold.TButton')
            self.btn_scan.grid(row=2, column=4, sticky='ew', padx=(8, 0))

            # Description of the selected search type, in red so it stands out
            self.lbl_hint = tk.Label(top, fg='#cd1e2d', font=self.bold_font, anchor='w', justify='left')
            self.lbl_hint.grid(row=3, column=0, columnspan=5, sticky='ew', pady=(6, 0))

            # List
            mid = ttk.Frame(root, padding=(10, 4))
            mid.pack(fill='both', expand=True)
            cols = ('mark', 'name', 'folder', 'size', 'date')
            self.tree = ttk.Treeview(mid, columns=cols, show='headings', selectmode='browse')
            widths = {'mark': 36, 'name': 320, 'folder': 360, 'size': 100, 'date': 150}
            for c in cols:
                self.tree.column(c, width=widths[c], stretch=(c in ('name', 'folder')),
                                 anchor='center' if c == 'mark' else ('e' if c == 'size' else 'w'))
                if c != 'mark':
                    self.tree.heading(c, command=lambda col=c: self.sort_by(col))
            self.tree.tag_configure('group', background='#e6edf2', font=self.bold_font)
            sb = ttk.Scrollbar(mid, orient='vertical', command=self.tree.yview)
            self.tree.configure(yscrollcommand=sb.set)
            self.tree.pack(side='left', fill='both', expand=True)
            sb.pack(side='right', fill='y')
            self.tree.bind('<Button-1>', self.on_click)
            self.tree.bind('<Double-1>', self.on_double)
            self.tree.bind('<space>', self.on_space)

            # Bottom area
            bottom = ttk.Frame(root, padding=(10, 4, 10, 8))
            bottom.pack(fill='x')
            row1 = ttk.Frame(bottom)
            row1.pack(fill='x', pady=2)
            row2 = ttk.Frame(bottom)
            row2.pack(fill='x', pady=2)
            self.btn_explorer = ttk.Button(row1, command=self.show_selected)
            self.btn_auto = ttk.Button(row1, command=self.auto_mark)
            self.btn_all = ttk.Button(row1, command=self.mark_all)
            self.btn_clear = ttk.Button(row1, command=self.clear_marks)
            self.btn_delete = ttk.Button(row1, command=self.delete_checked, style='Danger.TButton')
            for b in (self.btn_explorer, self.btn_auto, self.btn_all, self.btn_clear, self.btn_delete):
                b.pack(side='left', padx=(0, 6))
            self.btn_save = ttk.Button(row2, command=self.save_report)
            self.btn_move = ttk.Button(row2, command=self.move_checked)
            self.btn_update = ttk.Button(row2, command=self.show_update_menu)
            self.btn_cache = ttk.Button(row2, command=self.clear_cache)
            for b in (self.btn_save, self.btn_move, self.btn_update, self.btn_cache):
                b.pack(side='left', padx=(0, 6))
            self.status = ttk.Label(bottom, anchor='w')
            self.status.pack(fill='x', pady=(6, 0))

            # Menu for the update button: users choose SFW or SFW + NSFW themselves
            self.upd_menu = tk.Menu(root, tearoff=0)
            self.upd_menu.add_command(command=lambda: self.open_list(URL_SFW))
            self.upd_menu.add_command(command=lambda: self.open_list(URL_NSFW))

            self.btn_auto.state(['disabled'])
            self.btn_move.state(['disabled'])
            self.apply_language(first=True)

        # ----- language -----
        def T(self, key):
            return LANG[self.lang].get(key, LANG['en'][key])

        def change_language(self, event=None):
            self.lang = LANG_CODES[self.cmb_lang.current()]
            save_language(self.lang)
            self.apply_language()

        def apply_language(self, first=False):
            T = self.T
            self.root.title('%s %s' % (T('title'), APP_VERSION))
            self.lbl_folder.configure(text=T('folder'))
            self.btn_browse.configure(text=T('browse'))
            self.lbl_mode.configure(text=T('mode'))
            self.lbl_ext.configure(text=T('filetype'))
            self.chk_sims.configure(text=T('simsOnly'))
            self.btn_scan.configure(text=T('search'))
            for c, k in (('name', 'colName'), ('folder', 'colFolder'), ('size', 'colSize'), ('date', 'colDate')):
                self.tree.heading(c, text=T(k))
            self.tree.heading('mark', text='')
            for b, k in ((self.btn_explorer, 'btnExplorer'), (self.btn_auto, 'btnAuto'), (self.btn_all, 'btnAll'),
                         (self.btn_clear, 'btnClear'), (self.btn_delete, 'btnDelete'), (self.btn_save, 'btnSave'),
                         (self.btn_move, 'btnMove'), (self.btn_update, 'btnUpdate'), (self.btn_cache, 'btnCache')):
                b.configure(text=T(k))
            self.upd_menu.entryconfigure(0, label=T('updSfw'))
            self.upd_menu.entryconfigure(1, label=T('updNsfw'))
            sel = 0 if first else max(0, self.cmb_mode.current())
            self.cmb_mode.configure(values=LANG[self.lang]['modes'])
            self.cmb_mode.current(sel)
            self.update_mode_controls()
            if self.groups:
                self.render()

        def update_mode_controls(self):
            m = self.cmb_mode.current()
            self.chk_sims.state(['!disabled'] if m in SIMS_ONLY_MODES else ['disabled'])
            self.ent_ext.state(['!disabled'] if m == MODE_TYPE else ['disabled'])
            if m >= 0:
                self.lbl_hint.configure(text=LANG[self.lang]['hints'][m])

        # ----- messages -----
        def info(self, text, title_key='tHint'):
            messagebox.showinfo(self.T(title_key), text, parent=self.root)

        def warn(self, text):
            messagebox.showwarning(self.T('tWarn'), text, parent=self.root)

        def ask(self, text, title_key='tConfirm'):
            return messagebox.askyesno(self.T(title_key), text, parent=self.root)

        # ----- background work -----
        def run_background(self, work, done):
            """Runs work() in a thread and calls done(result) in the window thread."""
            self.busy = True
            self.root.configure(cursor='watch')
            self.btn_scan.state(['disabled'])
            box = {}

            def target():
                try:
                    box['result'] = work()
                except Exception as e:  # show errors instead of failing silently
                    box['error'] = e

            th = threading.Thread(target=target, daemon=True)
            th.start()

            def poll():
                if self._progress:
                    self.status.configure(text=self._progress)
                    self._progress = None
                if th.is_alive():
                    self.root.after(100, poll)
                    return
                self.busy = False
                self.root.configure(cursor='')
                self.btn_scan.state(['!disabled'])
                if 'error' in box:
                    messagebox.showerror(self.T('tError'), str(box['error']), parent=self.root)
                else:
                    done(box.get('result'))
            self.root.after(100, poll)

        # ----- list -----
        def date_text(self, ts):
            if not ts:
                return ''
            return datetime.datetime.fromtimestamp(ts).strftime(DATE_FORMATS.get(self.lang, DATE_FORMATS['en']))

        def render(self):
            self.tree.delete(*self.tree.get_children())
            root_path = self.var_folder.get().strip()
            main = self.T('mainFolder')
            for gi, g in enumerate(self.groups):
                giid = 'g%d' % gi
                self.tree.insert('', 'end', iid=giid, values=('', g['header'], '', '', ''), tags=('group',))
                iids = list(g['iids'])
                if self.sort_col:
                    keyf = {
                        'name': lambda i: self.entries[i]['name'].lower(),
                        'folder': lambda i: self.entries[i]['dir'].lower(),
                        'size': lambda i: self.entries[i]['size'],
                        'date': lambda i: self.entries[i]['mtime'],
                    }[self.sort_col]
                    iids.sort(key=keyf, reverse=not self.sort_asc)
                for iid in iids:
                    e = self.entries[iid]
                    size = self.T('folderItem') if e['is_folder'] else format_size(e['size'])
                    self.tree.insert('', 'end', iid=iid, values=(
                        '☑' if iid in self.checked else '☐', e['name'],
                        rel_dir(e['dir'], root_path, main), size, self.date_text(e['mtime'])))

        def refresh_marks(self):
            for iid in self.entries:
                if self.tree.exists(iid):
                    self.tree.set(iid, 'mark', '☑' if iid in self.checked else '☐')

        def toggle(self, iid):
            if iid.startswith('g'):
                g = self.groups[int(iid[1:])]
                if all(i in self.checked for i in g['iids']):
                    self.checked.difference_update(g['iids'])
                else:
                    self.checked.update(g['iids'])
            elif iid in self.checked:
                self.checked.discard(iid)
            else:
                self.checked.add(iid)
            self.refresh_marks()

        def on_click(self, event):
            iid = self.tree.identify_row(event.y)
            if iid and self.tree.identify_column(event.x) == '#1':
                self.toggle(iid)
                return 'break'

        def on_double(self, event):
            iid = self.tree.identify_row(event.y)
            if iid and not iid.startswith('g') and self.tree.identify_column(event.x) != '#1':
                show_in_folder(self.entries[iid]['path'])

        def on_space(self, event):
            iid = self.tree.focus()
            if iid:
                self.toggle(iid)
            return 'break'

        def sort_by(self, col):
            if self.sort_col == col:
                self.sort_asc = not self.sort_asc
            else:
                self.sort_col = col
                self.sort_asc = col in ('name', 'folder')   # size and date start descending
            self.render()

        # ----- search -----
        def browse(self):
            if not IS_MAC:
                # Let Linux users show hidden folders (Steam and Wine live in hidden folders)
                try:
                    self.root.tk.call('catch', 'tk_getOpenFile -foo bar')
                    self.root.tk.call('set', '::tk::dialog::file::showHiddenBtn', '1')
                    self.root.tk.call('set', '::tk::dialog::file::showHiddenVar', '0')
                except tk.TclError:
                    pass
            d = filedialog.askdirectory(parent=self.root, title=self.T('browseDesc'),
                                        initialdir=self.var_folder.get() or os.path.expanduser('~'))
            if d:
                self.var_folder.set(d)

        def start_scan(self):
            if self.busy:
                return
            mode = self.cmb_mode.current()
            root_path = self.var_folder.get().strip()
            if not root_path or not os.path.isdir(root_path):
                self.warn(self.T('folderNotFound'))
                return
            exts = []
            if mode == MODE_TYPE:
                exts = parse_extensions(self.var_ext.get())
                if not exts:
                    self.info(self.T('enterType'))
                    return
            sims_only = self.var_sims.get()
            lang_T = self.T

            def progress(text):
                self._progress = text

            def done(result):
                self.entries.clear()
                self.checked.clear()
                self.groups = []
                self.sort_col = None
                n = 0
                for g in result['groups']:
                    iids = []
                    for e in g['items']:
                        n += 1
                        iid = 'i%d' % n
                        self.entries[iid] = e
                        iids.append(iid)
                    self.groups.append({'header': g['header'], 'iids': iids})
                self.last_mode = mode
                self.btn_auto.state(['!disabled'] if mode in DUP_MODES else ['disabled'])
                self.btn_move.state(['!disabled'] if mode == MODE_DEPTH else ['disabled'])
                self.render()
                self.status.configure(text=result['msg'])
                if result.get('warn'):
                    self.warn(result['msg'])

            self.status.configure(text=self.T('collecting'))
            self.run_background(lambda: run_scan(mode, root_path, sims_only, exts, lang_T, progress), done)

        # ----- actions -----
        def current_iid(self):
            iid = self.tree.focus()
            if iid and not iid.startswith('g'):
                return iid
            for g in self.groups:
                for i in g['iids']:
                    if i in self.checked:
                        return i
            return None

        def show_selected(self):
            iid = self.current_iid()
            if not iid:
                if not self.entries:
                    self.info(self.T('explorerEmpty').format(self.T('search')))
                else:
                    self.info(self.T('explorerSelect'))
                return
            show_in_folder(self.entries[iid]['path'])

        def auto_mark(self):
            for g in self.groups:
                for idx, iid in enumerate(g['iids']):
                    if idx == 0:
                        self.checked.discard(iid)
                    else:
                        self.checked.add(iid)
            self.refresh_marks()
            self.status.configure(text=self.T('autoMarked').format(len(self.checked)))

        def mark_all(self):
            self.checked = set(self.entries)
            self.refresh_marks()
            self.status.configure(text=self.T('allMarked').format(len(self.checked)))

        def clear_marks(self):
            self.checked.clear()
            self.refresh_marks()

        def remove_entries(self, iids):
            iids = set(iids)
            for g in self.groups:
                g['iids'] = [i for i in g['iids'] if i not in iids]
            for i in iids:
                self.entries.pop(i, None)
                self.checked.discard(i)
            self.render()

        def delete_checked(self):
            if self.busy:
                return
            checked = [i for g in self.groups for i in g['iids'] if i in self.checked]
            if not checked:
                self.info(self.T('nothingMarked'))
                return
            # For duplicates and versions at least one file of each group must stay
            if self.last_mode in DUP_MODES:
                for g in self.groups:
                    if g['iids'] and all(i in self.checked for i in g['iids']):
                        self.warn(self.T('keepOne').format(g['header']))
                        return
            if not self.ask(self.T('confirmDelete').format(len(checked))):
                return
            items = [(self.entries[i]['path'], self.entries[i]['is_folder']) for i in checked]
            T = self.T

            def progress(done_count, total):
                self._progress = T('deleting').format(done_count, total)

            def work():
                # Check folders again right before deleting: something may have been added
                paths, not_empty = [], 0
                for path, is_folder in items:
                    if is_folder and not folder_still_empty(path):
                        not_empty += 1
                    else:
                        paths.append(path)
                return move_to_trash(paths, progress), len(paths), not_empty

            def done(result):
                moved, tried, not_empty = result
                moved = set(moved)
                self.remove_entries([i for i in checked if self.entries[i]['path'] in moved])
                msg = self.T('deleted').format(len(moved))
                if tried > len(moved):
                    msg += self.T('deleteFailed').format(tried - len(moved))
                if not_empty:
                    msg += self.T('skippedNotEmpty').format(not_empty)
                self.status.configure(text=msg)

            self.status.configure(text=self.T('trashing'))
            self.run_background(work, done)

        def move_checked(self):
            if self.busy:
                return
            checked = [i for g in self.groups for i in g['iids'] if i in self.checked and self.entries[i].get('target')]
            if not checked:
                self.info(self.T('moveNone'))
                return
            if not self.ask(self.T('moveConfirm').format(len(checked))):
                return
            moved, skipped = [], 0
            for i in checked:
                e = self.entries[i]
                dest = os.path.join(e['target'], e['name'])
                if os.path.lexists(dest):
                    skipped += 1
                    continue
                try:
                    shutil.move(e['path'], dest)
                    moved.append(i)
                except OSError:
                    skipped += 1
            self.remove_entries(moved)
            msg = self.T('moved').format(len(moved))
            if skipped:
                msg += self.T('moveSkipped').format(skipped)
            self.status.configure(text=msg)

        def save_report(self):
            if not self.entries:
                self.info(self.T('listEmpty'))
                return
            name = '%s_%s.csv' % (self.T('csvFile'), datetime.datetime.now().strftime('%Y-%m-%d_%H-%M'))
            desktop = os.path.join(os.path.expanduser('~'), 'Desktop')
            path = filedialog.asksaveasfilename(
                parent=self.root, initialfile=name, defaultextension='.csv',
                initialdir=desktop if os.path.isdir(desktop) else os.path.expanduser('~'),
                filetypes=[(self.T('csvFilter').split('|')[0], '*.csv')])
            if not path:
                return
            T = self.T
            root_path = self.var_folder.get().strip()
            try:
                with open(path, 'w', newline='', encoding='utf-8-sig') as f:
                    # English Excel expects commas, most other languages semicolons
                    w = csv.writer(f, delimiter=',' if self.lang == 'en' else ';')
                    w.writerow([T('csvGroup'), T('csvMarked'), T('colName'), T('colFolder'), T('colSize'), T('colDate'), T('csvPath')])
                    for g in self.groups:
                        for i in g['iids']:
                            e = self.entries[i]
                            w.writerow([g['header'], T('csvYes') if i in self.checked else '', e['name'],
                                        rel_dir(e['dir'], root_path, T('mainFolder')),
                                        T('folderItem') if e['is_folder'] else format_size(e['size']),
                                        self.date_text(e['mtime']), e['path']])
                self.status.configure(text=T('saved').format(path))
            except OSError as ex:
                messagebox.showerror(T('tError'), T('saveFailed').format(ex), parent=self.root)

        def show_update_menu(self):
            x = self.btn_update.winfo_rootx()
            y = self.btn_update.winfo_rooty() + self.btn_update.winfo_height()
            try:
                self.upd_menu.tk_popup(x, y)
            finally:
                self.upd_menu.grab_release()

        def open_list(self, url):
            webbrowser.open(url)
            self.status.configure(text=self.T('updateOpened'))

        def clear_cache(self):
            if self.busy:
                return
            if sims_is_running():
                self.warn(self.T('closeSims'))
                return
            sims = find_sims_folder(self.var_folder.get().strip())
            if not sims:
                self.info(self.T('simsNotFound'))
                return
            targets = []
            thumb = os.path.join(sims, 'localthumbcache.package')
            if os.path.isfile(thumb):
                targets.append(thumb)
            for sub in ('cache', 'cachestr', 'onlinethumbnailcache'):
                p = os.path.join(sims, sub)
                if os.path.isdir(p):
                    for cur, _dirs, names in os.walk(p):
                        targets += [os.path.join(cur, n) for n in names]
            if not targets:
                self.status.configure(text=self.T('cacheEmpty'))
                return
            if not self.ask(self.T('cacheConfirm').format(sims, len(targets), '\n'), 'cacheTitle'):
                return

            def done(moved):
                msg = self.T('cacheDone').format(len(moved))
                if len(targets) > len(moved):
                    msg += self.T('cacheFail').format(len(targets) - len(moved))
                self.status.configure(text=msg)

            self.status.configure(text=self.T('trashing'))
            self.run_background(lambda: move_to_trash(targets), done)

    root = tk.Tk()
    App(root)
    root.mainloop()


if __name__ == '__main__':
    try:
        run_gui()
    except ImportError:
        print('ModSweep needs Tkinter. See README.txt (Python from python.org on Mac, python3-tk on Linux).')
        sys.exit(1)
