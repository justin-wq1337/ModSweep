# ModSweep for The Sims 4
# Searches a folder including all subfolders for duplicates, old versions,
# unneeded files, empty folders and misplaced mods.
# Deleted files always go to the Recycle Bin.
# Languages: English (default), Deutsch, Español, Français, Polski, Português (Brasil)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName Microsoft.VisualBasic
[System.Windows.Forms.Application]::EnableVisualStyles()

if (-not ('ModEntry' -as [type])) {
    Add-Type -ReferencedAssemblies 'System.Windows.Forms', 'System.Drawing' -TypeDefinition @'
using System;
using System.Collections;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public static class Recycler {
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
    private struct SHFILEOPSTRUCT {
        public IntPtr hwnd;
        [MarshalAs(UnmanagedType.U4)] public int wFunc;
        public string pFrom;
        public string pTo;
        public short fFlags;
        [MarshalAs(UnmanagedType.Bool)] public bool fAnyOperationsAborted;
        public IntPtr hNameMappings;
        public string lpszProgressTitle;
    }
    [DllImport("shell32.dll", CharSet = CharSet.Unicode)]
    private static extern int SHFileOperation(ref SHFILEOPSTRUCT op);

    // Moves a file or folder to the Recycle Bin.
    // FOF_WANTNUKEWARNING: Windows asks first if the item cannot go to the Recycle Bin
    // and would be deleted permanently (e.g. network drives), instead of deleting silently.
    public static bool Send(string path) {
        SHFILEOPSTRUCT op = new SHFILEOPSTRUCT();
        op.wFunc = 3;                       // FO_DELETE
        op.pFrom = path + "\0\0";
        op.fFlags = (short)(0x0040 | 0x0010 | 0x0004 | 0x0400 | 0x4000);
        // ALLOWUNDO | NOCONFIRMATION | SILENT | NOERRORUI | WANTNUKEWARNING
        int r = SHFileOperation(ref op);
        return r == 0 && !op.fAnyOperationsAborted;
    }
}

public class ModEntry {
    public string Path;
    public long Size;
    public DateTime Date;
    public bool IsFolder;
    public string Target;
    public ModEntry(string path, long size, DateTime date, bool isFolder) {
        Path = path; Size = size; Date = date; IsFolder = isFolder; Target = null;
    }
}

public class ModSorter : IComparer {
    public int Column = 0;
    public bool Ascending = true;
    public int Compare(object x, object y) {
        ListViewItem a = (ListViewItem)x;
        ListViewItem b = (ListViewItem)y;
        ModEntry ea = a.Tag as ModEntry;
        ModEntry eb = b.Tag as ModEntry;
        int r;
        if (Column == 2 && ea != null && eb != null) r = ea.Size.CompareTo(eb.Size);
        else if (Column == 3 && ea != null && eb != null) r = ea.Date.CompareTo(eb.Date);
        else r = String.Compare(a.SubItems[Column].Text, b.SubItems[Column].Text, StringComparison.CurrentCultureIgnoreCase);
        return Ascending ? r : -r;
    }
}
'@
}

# =====================================================================
# Languages
# =====================================================================
$LangCodes = @('en', 'de', 'es', 'fr', 'pl', 'pt')
$LangNames = @('English', 'Deutsch', 'Español', 'Français', 'Polski', 'Português (Brasil)')

$Lang = @{}

$Lang['en'] = @{
    title = 'ModSweep for The Sims 4'
    folder = 'Folder:'; browse = 'Browse ...'; mode = 'Search:'; filetype = 'File type:'
    simsOnly = 'Sims files only (.package and .ts4script)'; search = 'Search'
    colName = 'Name'; colFolder = 'Subfolder'; colSize = 'Size'; colDate = 'Modified'
    btnExplorer = 'Show in Explorer'; btnAuto = 'Mark (keep newest)'; btnAll = 'Mark all'
    btnClear = 'Unmark all'; btnDelete = 'Move marked to Recycle Bin'; btnSave = 'Save list (Excel)'
    btnMove = 'Move marked to correct folder'; btnUpdate = 'Check update status online'; btnCache = 'Clear Sims cache'
    modes = @(
        'Duplicate files: same content (safe)',
        'Duplicate files: same file name (fast)',
        'Several versions of the same mod (e.g. v4.1 and v4.2)',
        'All files of a type (e.g. .png)',
        'Unneeded files (archives, readmes, images, 0 bytes)',
        'Empty folders',
        'Largest files',
        'Misplaced mods (nested too deep)')
    hints = @(
        'Finds files with exactly the same content, even if they have different names.',
        'Finds files with the same name in different folders. The content may differ.',
        'Finds e.g. "Mod_v4.1" and "Mod_v4.2" or "Mod (1)". Please check before deleting.',
        'Shows all files of the entered types. Separate several types with commas.',
        'Shows archives, readmes, preview images and empty files. Sims 4 does not need them.',
        'Shows folders that no longer contain a single file.',
        'Shows the 200 largest files, so you can see what takes up the most space.',
        'Sims 4 loads .ts4script only 1 subfolder deep and .package up to 5 subfolders deep.')
    mainFolder = '(main folder)'; folderItem = 'Folder'
    folderNotFound = 'The folder was not found.'
    enterType = 'Please enter a file type, e.g. .png'
    collecting = 'Collecting files ...'
    comparing = 'Comparing contents: {0} of {1} files ...'
    groupDup = 'Group {0}: {1}  ({2} files)'; groupVer = 'Mod {0}: {1}  ({2} files)'; groupFolder = '{0}  ({1} files)'
    hashNone = 'No duplicates found ({0} files checked).'
    hashFound = '{0} groups of identical files found ({1} files checked). Wasted space: {2}'
    nameNone = 'No duplicate file names found ({0} files checked).'
    nameFound = '{0} file names occur more than once. Note: the content may differ.'
    verNone = 'No mods with several versions found.'
    verFound = '{0} mods exist in several versions. The newest file is listed first. Please check before deleting.'
    typeNone = 'No files of type {0} found.'
    typeFound = '{0} files of type {1} found in {2} folders, {3} in total.'
    junkEmpty = 'Empty files (0 bytes)'; junkArchive = 'Archives (.zip, .rar, .7z)'; junkText = 'Texts and readmes'
    junkImage = 'Images and previews'; junkWin = 'System leftovers (Thumbs.db, desktop.ini, .DS_Store)'
    junkNone = 'No unneeded files found.'
    junkFound = '{0} unneeded files found, {1} in total. Only delete archives if they are already extracted.'
    emptyGroup = 'Empty folders  ({0})'
    emptyFound = '{0} empty folders found. Empty subfolders inside them are deleted too.'
    emptyNone = 'No empty folders found.'
    bigGroup = 'The {0} largest files'
    bigFound = 'All {0} files together: {1}. Click a column header to sort.'
    noFiles = 'No files found.'
    depthScript = 'Scripts (.ts4script), at most 1 subfolder allowed'
    depthPkg = 'Packages (.package), at most 5 subfolders allowed'
    depthNone = 'All good: no mod is nested too deep.'
    depthFound = '{0} files are nested too deep and are not loaded by the game. Mark them and click "{1}".'
    explorerEmpty = 'The list is still empty. Please click "{0}" first.'
    explorerSelect = 'Please click a row in the list first.'
    autoMarked = '{0} files marked. The newest file of each group is kept.'
    allMarked = '{0} entries marked.'
    nothingMarked = 'Nothing is marked.'
    keepOne = 'Everything in "{0}" is marked. At least one file should stay.'
    confirmDelete = 'Move {0} entries to the Recycle Bin?'
    deleting = 'Moving to Recycle Bin: {0} of {1} ...'
    deleted = '{0} entries moved to the Recycle Bin.'
    deleteFailed = ' {0} could not be moved (is the game still running?).'
    tHint = 'Note'; tWarn = 'Warning'; tConfirm = 'Confirm'; tError = 'Error'
    moveNone = 'Please mark the files to be moved first.'
    moveConfirm = 'Move {0} files up so that Sims 4 loads them?'
    moved = '{0} files moved to the correct folder.'
    moveSkipped = ' {0} skipped (a file with the same name already exists or the game is still running).'
    listEmpty = 'The list is empty. Please search first.'
    csvFilter = 'Excel table (*.csv)|*.csv'; csvFile = 'Sims4-Report'
    csvGroup = 'Group'; csvMarked = 'Marked'; csvYes = 'yes'; csvPath = 'Path'
    saved = 'List saved: {0}'; saveFailed = 'Saving failed: {0}'
    closeSims = 'Please close Sims 4 first.'
    simsNotFound = 'The Sims 4 folder was not found.'
    cacheEmpty = 'The cache is already empty.'
    cacheTitle = 'Clear Sims cache'
    cacheConfirm = 'Clear the cache in{2}{0}?{2}({1} files, they go to the Recycle Bin){2}{2}Sims 4 rebuilds the cache on the next start.'
    cacheDone = 'Cache cleared: {0} files moved to the Recycle Bin.'
    cacheFail = ' {0} could not be deleted.'
    browseDesc = 'Choose a folder, e.g. your Sims 4 Mods folder'
    updateOpened = 'Scarlet''s Mod List was opened in your browser. Search for your mod there (Ctrl+F).'
    updSfw = 'Mod List: SFW only (no adult content)'; updNsfw = 'Mod List: SFW + NSFW (adult content, 18+)'
    notModsFolder = 'This search needs your Mods folder (or a folder inside it). The selected folder is not inside a folder named "Mods".'
    skippedNotEmpty = ' {0} folders were skipped because they are not empty (anymore).'
}

$Lang['de'] = @{
    title = 'ModSweep for The Sims 4'
    folder = 'Ordner:'; browse = 'Durchsuchen ...'; mode = 'Suchart:'; filetype = 'Dateityp:'
    simsOnly = 'Nur Sims-Dateien (.package und .ts4script)'; search = 'Suchen'
    colName = 'Name'; colFolder = 'Unterordner'; colSize = 'Größe'; colDate = 'Geändert'
    btnExplorer = 'Im Explorer zeigen'; btnAuto = 'Markieren (neueste behalten)'; btnAll = 'Alle markieren'
    btnClear = 'Markierung aufheben'; btnDelete = 'Markierte in den Papierkorb'; btnSave = 'Liste speichern (Excel)'
    btnMove = 'Markierte richtig einsortieren'; btnUpdate = 'Update-Status online prüfen'; btnCache = 'Sims-Cache leeren'
    modes = @(
        'Doppelte Dateien: gleicher Inhalt (sicher)',
        'Doppelte Dateien: gleicher Dateiname (schnell)',
        'Mehrere Versionen derselben Mod (z. B. v4.1 und v4.2)',
        'Alle Dateien vom Typ (z. B. .png)',
        'Unnötige Dateien (Archive, Readmes, Bilder, 0 Byte)',
        'Leere Ordner',
        'Größte Dateien',
        'Falsch einsortierte Mods (zu tief verschachtelt)')
    hints = @(
        'Findet Dateien mit exakt gleichem Inhalt, auch wenn sie anders heißen.',
        'Findet Dateien mit gleichem Namen in verschiedenen Ordnern. Der Inhalt kann abweichen.',
        'Findet z. B. "Mod_v4.1" und "Mod_v4.2" oder "Mod (1)". Vor dem Löschen bitte kurz prüfen.',
        'Zeigt alle Dateien der eingetragenen Typen. Mehrere Typen mit Komma trennen.',
        'Zeigt Archive, Anleitungen, Vorschaubilder und leere Dateien. Sims 4 braucht diese nicht.',
        'Zeigt Ordner, in denen keine einzige Datei mehr liegt.',
        'Zeigt die 200 größten Dateien. So siehst du, was am meisten Platz belegt.',
        'Sims 4 lädt .ts4script nur bis 1 Unterordner tief und .package bis 5 Unterordner tief.')
    mainFolder = '(Hauptordner)'; folderItem = 'Ordner'
    folderNotFound = 'Der Ordner wurde nicht gefunden.'
    enterType = 'Bitte einen Dateityp eintragen, z. B. .png'
    collecting = 'Dateien werden gesammelt ...'
    comparing = 'Vergleiche Inhalte: {0} von {1} Dateien ...'
    groupDup = 'Gruppe {0}: {1}  ({2} Dateien)'; groupVer = 'Mod {0}: {1}  ({2} Dateien)'; groupFolder = '{0}  ({1} Dateien)'
    hashNone = 'Keine Duplikate gefunden ({0} Dateien geprüft).'
    hashFound = '{0} Gruppen mit identischen Dateien gefunden ({1} Dateien geprüft). Unnötig belegt: {2}'
    nameNone = 'Keine doppelten Dateinamen gefunden ({0} Dateien geprüft).'
    nameFound = '{0} Dateinamen kommen mehrfach vor. Achtung: Der Inhalt kann unterschiedlich sein.'
    verNone = 'Keine Mods mit mehreren Versionen gefunden.'
    verFound = '{0} Mods liegen in mehreren Versionen vor. Oben steht jeweils die neueste Datei. Bitte vor dem Löschen prüfen.'
    typeNone = 'Keine Dateien vom Typ {0} gefunden.'
    typeFound = '{0} Dateien vom Typ {1} in {2} Ordnern gefunden, zusammen {3}.'
    junkEmpty = 'Leere Dateien (0 Byte)'; junkArchive = 'Archive (.zip, .rar, .7z)'; junkText = 'Texte und Anleitungen'
    junkImage = 'Bilder und Vorschaubilder'; junkWin = 'System-Reste (Thumbs.db, desktop.ini, .DS_Store)'
    junkNone = 'Keine unnötigen Dateien gefunden.'
    junkFound = '{0} unnötige Dateien gefunden, zusammen {1}. Archive nur löschen, wenn sie schon entpackt sind.'
    emptyGroup = 'Leere Ordner  ({0})'
    emptyFound = '{0} leere Ordner gefunden. Leere Unterordner darin werden mitgelöscht.'
    emptyNone = 'Keine leeren Ordner gefunden.'
    bigGroup = 'Die {0} größten Dateien'
    bigFound = 'Alle {0} Dateien zusammen: {1}. Klick auf eine Spalte zum Sortieren.'
    noFiles = 'Keine Dateien gefunden.'
    depthScript = 'Skripte (.ts4script), erlaubt ist höchstens 1 Unterordner'
    depthPkg = 'Packages (.package), erlaubt sind höchstens 5 Unterordner'
    depthNone = 'Alles in Ordnung: Keine Mod liegt zu tief.'
    depthFound = '{0} Dateien liegen zu tief und werden vom Spiel nicht geladen. Markieren und auf "{1}" klicken.'
    explorerEmpty = 'Die Liste ist noch leer. Bitte zuerst auf "{0}" klicken.'
    explorerSelect = 'Bitte zuerst eine Zeile in der Liste anklicken.'
    autoMarked = '{0} Dateien markiert. Die neueste Datei jeder Gruppe bleibt erhalten.'
    allMarked = '{0} Einträge markiert.'
    nothingMarked = 'Es ist nichts markiert.'
    keepOne = 'In "{0}" ist alles markiert. Mindestens eine Datei sollte bleiben.'
    confirmDelete = '{0} Einträge in den Papierkorb verschieben?'
    deleting = 'Verschiebe in den Papierkorb: {0} von {1} ...'
    deleted = '{0} Einträge in den Papierkorb verschoben.'
    deleteFailed = ' {0} konnten nicht verschoben werden (Spiel noch offen?).'
    tHint = 'Hinweis'; tWarn = 'Achtung'; tConfirm = 'Bestätigen'; tError = 'Fehler'
    moveNone = 'Bitte zuerst die Dateien markieren, die verschoben werden sollen.'
    moveConfirm = '{0} Dateien so weit nach oben verschieben, dass Sims 4 sie lädt?'
    moved = '{0} Dateien richtig einsortiert.'
    moveSkipped = ' {0} übersprungen (gleichnamige Datei schon vorhanden oder Spiel noch offen).'
    listEmpty = 'Die Liste ist leer. Bitte zuerst suchen.'
    csvFilter = 'Excel-Tabelle (*.csv)|*.csv'; csvFile = 'Sims4-Bericht'
    csvGroup = 'Gruppe'; csvMarked = 'Markiert'; csvYes = 'ja'; csvPath = 'Pfad'
    saved = 'Liste gespeichert: {0}'; saveFailed = 'Speichern fehlgeschlagen: {0}'
    closeSims = 'Bitte zuerst Sims 4 beenden.'
    simsNotFound = 'Der Sims 4 Ordner wurde nicht gefunden.'
    cacheEmpty = 'Der Cache ist schon leer.'
    cacheTitle = 'Sims-Cache leeren'
    cacheConfirm = 'Cache in{2}{0}{2}leeren? ({1} Dateien, sie landen im Papierkorb){2}{2}Sims 4 baut den Cache beim nächsten Start neu auf.'
    cacheDone = 'Cache geleert: {0} Dateien in den Papierkorb verschoben.'
    cacheFail = ' {0} konnten nicht gelöscht werden.'
    browseDesc = 'Ordner auswählen, z. B. deinen Sims 4 Mods-Ordner'
    updateOpened = 'Scarlet''s Mod List wurde im Browser geöffnet. Dort nach dem Namen deiner Mod suchen (Strg+F).'
    updSfw = 'Mod List: nur SFW (ohne Inhalte für Erwachsene)'; updNsfw = 'Mod List: SFW + NSFW (Inhalte für Erwachsene, ab 18)'
    notModsFolder = 'Diese Suche braucht deinen Mods-Ordner (oder einen Ordner darin). Der gewählte Ordner liegt nicht in einem Ordner namens "Mods".'
    skippedNotEmpty = ' {0} Ordner wurden übersprungen, weil sie nicht (mehr) leer sind.'
}

$Lang['es'] = @{
    title = 'ModSweep for The Sims 4'
    folder = 'Carpeta:'; browse = 'Examinar ...'; mode = 'Búsqueda:'; filetype = 'Tipo:'
    simsOnly = 'Solo archivos de Sims (.package y .ts4script)'; search = 'Buscar'
    colName = 'Nombre'; colFolder = 'Subcarpeta'; colSize = 'Tamaño'; colDate = 'Modificado'
    btnExplorer = 'Mostrar en el Explorador'; btnAuto = 'Marcar (conservar el más nuevo)'; btnAll = 'Marcar todo'
    btnClear = 'Desmarcar todo'; btnDelete = 'Enviar marcados a la papelera'; btnSave = 'Guardar lista (Excel)'
    btnMove = 'Colocar bien los marcados'; btnUpdate = 'Comprobar actualizaciones en línea'; btnCache = 'Vaciar caché de Sims'
    modes = @(
        'Duplicados: mismo contenido (seguro)',
        'Duplicados: mismo nombre de archivo (rápido)',
        'Varias versiones del mismo mod (p. ej. v4.1 y v4.2)',
        'Todos los archivos de un tipo (p. ej. .png)',
        'Archivos innecesarios (comprimidos, léeme, imágenes, 0 bytes)',
        'Carpetas vacías',
        'Archivos más grandes',
        'Mods mal colocados (demasiado profundos)')
    hints = @(
        'Encuentra archivos con exactamente el mismo contenido, aunque tengan otro nombre.',
        'Encuentra archivos con el mismo nombre en distintas carpetas. El contenido puede ser diferente.',
        'Encuentra p. ej. "Mod_v4.1" y "Mod_v4.2" o "Mod (1)". Revísalos antes de borrar.',
        'Muestra todos los archivos de los tipos indicados. Separa varios tipos con comas.',
        'Muestra comprimidos, léeme, imágenes de vista previa y archivos vacíos. Los Sims 4 no los necesita.',
        'Muestra carpetas que ya no contienen ningún archivo.',
        'Muestra los 200 archivos más grandes para ver qué ocupa más espacio.',
        'Los Sims 4 carga .ts4script como máximo a 1 subcarpeta y .package como máximo a 5 subcarpetas.')
    mainFolder = '(carpeta principal)'; folderItem = 'Carpeta'
    folderNotFound = 'No se encontró la carpeta.'
    enterType = 'Introduce un tipo de archivo, p. ej. .png'
    collecting = 'Recopilando archivos ...'
    comparing = 'Comparando contenido: {0} de {1} archivos ...'
    groupDup = 'Grupo {0}: {1}  ({2} archivos)'; groupVer = 'Mod {0}: {1}  ({2} archivos)'; groupFolder = '{0}  ({1} archivos)'
    hashNone = 'No se encontraron duplicados ({0} archivos revisados).'
    hashFound = '{0} grupos de archivos idénticos encontrados ({1} archivos revisados). Espacio desperdiciado: {2}'
    nameNone = 'No se encontraron nombres repetidos ({0} archivos revisados).'
    nameFound = '{0} nombres de archivo aparecen más de una vez. Ojo: el contenido puede ser diferente.'
    verNone = 'No se encontraron mods con varias versiones.'
    verFound = '{0} mods tienen varias versiones. El archivo más nuevo aparece arriba. Revísalos antes de borrar.'
    typeNone = 'No se encontraron archivos del tipo {0}.'
    typeFound = '{0} archivos del tipo {1} encontrados en {2} carpetas, {3} en total.'
    junkEmpty = 'Archivos vacíos (0 bytes)'; junkArchive = 'Comprimidos (.zip, .rar, .7z)'; junkText = 'Textos y léeme'
    junkImage = 'Imágenes y vistas previas'; junkWin = 'Restos del sistema (Thumbs.db, desktop.ini, .DS_Store)'
    junkNone = 'No se encontraron archivos innecesarios.'
    junkFound = '{0} archivos innecesarios encontrados, {1} en total. Borra los comprimidos solo si ya están descomprimidos.'
    emptyGroup = 'Carpetas vacías  ({0})'
    emptyFound = '{0} carpetas vacías encontradas. Las subcarpetas vacías que contienen también se borran.'
    emptyNone = 'No se encontraron carpetas vacías.'
    bigGroup = 'Los {0} archivos más grandes'
    bigFound = 'Los {0} archivos en total: {1}. Haz clic en una columna para ordenar.'
    noFiles = 'No se encontraron archivos.'
    depthScript = 'Scripts (.ts4script), máximo 1 subcarpeta'
    depthPkg = 'Packages (.package), máximo 5 subcarpetas'
    depthNone = 'Todo bien: ningún mod está demasiado profundo.'
    depthFound = '{0} archivos están demasiado profundos y el juego no los carga. Márcalos y haz clic en "{1}".'
    explorerEmpty = 'La lista está vacía. Haz clic primero en "{0}".'
    explorerSelect = 'Haz clic primero en una fila de la lista.'
    autoMarked = '{0} archivos marcados. Se conserva el archivo más nuevo de cada grupo.'
    allMarked = '{0} elementos marcados.'
    nothingMarked = 'No hay nada marcado.'
    keepOne = 'En "{0}" está todo marcado. Debe quedar al menos un archivo.'
    confirmDelete = '¿Enviar {0} elementos a la papelera?'
    deleting = 'Enviando a la papelera: {0} de {1} ...'
    deleted = '{0} elementos enviados a la papelera.'
    deleteFailed = ' {0} no se pudieron mover (¿el juego sigue abierto?).'
    tHint = 'Aviso'; tWarn = 'Atención'; tConfirm = 'Confirmar'; tError = 'Error'
    moveNone = 'Marca primero los archivos que quieres mover.'
    moveConfirm = '¿Subir {0} archivos para que Los Sims 4 los cargue?'
    moved = '{0} archivos colocados correctamente.'
    moveSkipped = ' {0} omitidos (ya existe un archivo con el mismo nombre o el juego sigue abierto).'
    listEmpty = 'La lista está vacía. Busca primero.'
    csvFilter = 'Tabla de Excel (*.csv)|*.csv'; csvFile = 'Sims4-Informe'
    csvGroup = 'Grupo'; csvMarked = 'Marcado'; csvYes = 'sí'; csvPath = 'Ruta'
    saved = 'Lista guardada: {0}'; saveFailed = 'Error al guardar: {0}'
    closeSims = 'Cierra primero Los Sims 4.'
    simsNotFound = 'No se encontró la carpeta de Los Sims 4.'
    cacheEmpty = 'La caché ya está vacía.'
    cacheTitle = 'Vaciar caché de Sims'
    cacheConfirm = '¿Vaciar la caché en{2}{0}?{2}({1} archivos, irán a la papelera){2}{2}Los Sims 4 creará la caché de nuevo al iniciarse.'
    cacheDone = 'Caché vaciada: {0} archivos enviados a la papelera.'
    cacheFail = ' {0} no se pudieron borrar.'
    browseDesc = 'Elige una carpeta, p. ej. tu carpeta Mods de Los Sims 4'
    updateOpened = 'La Mod List de Scarlet se abrió en el navegador. Busca allí el nombre de tu mod (Ctrl+F).'
    updSfw = 'Mod List: solo SFW (sin contenido para adultos)'; updNsfw = 'Mod List: SFW + NSFW (contenido para adultos, +18)'
    notModsFolder = 'Esta búsqueda necesita tu carpeta Mods (o una carpeta dentro de ella). La carpeta elegida no está dentro de una carpeta llamada "Mods".'
    skippedNotEmpty = ' Se omitieron {0} carpetas porque (ya) no están vacías.'
}

$Lang['fr'] = @{
    title = 'ModSweep for The Sims 4'
    folder = 'Dossier :'; browse = 'Parcourir ...'; mode = 'Recherche :'; filetype = 'Type :'
    simsOnly = 'Fichiers Sims uniquement (.package et .ts4script)'; search = 'Rechercher'
    colName = 'Nom'; colFolder = 'Sous-dossier'; colSize = 'Taille'; colDate = 'Modifié'
    btnExplorer = 'Afficher dans l''Explorateur'; btnAuto = 'Cocher (garder le plus récent)'; btnAll = 'Tout cocher'
    btnClear = 'Tout décocher'; btnDelete = 'Mettre les cochés à la corbeille'; btnSave = 'Enregistrer la liste (Excel)'
    btnMove = 'Ranger correctement les cochés'; btnUpdate = 'Vérifier les mises à jour en ligne'; btnCache = 'Vider le cache Sims'
    modes = @(
        'Doublons : même contenu (sûr)',
        'Doublons : même nom de fichier (rapide)',
        'Plusieurs versions du même mod (ex. v4.1 et v4.2)',
        'Tous les fichiers d''un type (ex. .png)',
        'Fichiers inutiles (archives, readme, images, 0 octet)',
        'Dossiers vides',
        'Fichiers les plus volumineux',
        'Mods mal rangés (trop profonds)')
    hints = @(
        'Trouve les fichiers au contenu identique, même s''ils portent un autre nom.',
        'Trouve les fichiers portant le même nom dans différents dossiers. Le contenu peut différer.',
        'Trouve par ex. "Mod_v4.1" et "Mod_v4.2" ou "Mod (1)". Vérifiez avant de supprimer.',
        'Affiche tous les fichiers des types indiqués. Séparez plusieurs types par des virgules.',
        'Affiche les archives, readme, images d''aperçu et fichiers vides. Sims 4 n''en a pas besoin.',
        'Affiche les dossiers qui ne contiennent plus aucun fichier.',
        'Affiche les 200 plus gros fichiers pour voir ce qui prend le plus de place.',
        'Sims 4 charge les .ts4script à 1 sous-dossier maximum et les .package à 5 sous-dossiers maximum.')
    mainFolder = '(dossier principal)'; folderItem = 'Dossier'
    folderNotFound = 'Le dossier est introuvable.'
    enterType = 'Veuillez saisir un type de fichier, par ex. .png'
    collecting = 'Collecte des fichiers ...'
    comparing = 'Comparaison du contenu : {0} sur {1} fichiers ...'
    groupDup = 'Groupe {0} : {1}  ({2} fichiers)'; groupVer = 'Mod {0} : {1}  ({2} fichiers)'; groupFolder = '{0}  ({1} fichiers)'
    hashNone = 'Aucun doublon trouvé ({0} fichiers vérifiés).'
    hashFound = '{0} groupes de fichiers identiques trouvés ({1} fichiers vérifiés). Espace gaspillé : {2}'
    nameNone = 'Aucun nom de fichier en double ({0} fichiers vérifiés).'
    nameFound = '{0} noms de fichiers apparaissent plusieurs fois. Attention : le contenu peut différer.'
    verNone = 'Aucun mod en plusieurs versions trouvé.'
    verFound = '{0} mods existent en plusieurs versions. Le fichier le plus récent est en haut. Vérifiez avant de supprimer.'
    typeNone = 'Aucun fichier de type {0} trouvé.'
    typeFound = '{0} fichiers de type {1} trouvés dans {2} dossiers, {3} au total.'
    junkEmpty = 'Fichiers vides (0 octet)'; junkArchive = 'Archives (.zip, .rar, .7z)'; junkText = 'Textes et readme'
    junkImage = 'Images et aperçus'; junkWin = 'Restes du système (Thumbs.db, desktop.ini, .DS_Store)'
    junkNone = 'Aucun fichier inutile trouvé.'
    junkFound = '{0} fichiers inutiles trouvés, {1} au total. Ne supprimez les archives que si elles sont déjà extraites.'
    emptyGroup = 'Dossiers vides  ({0})'
    emptyFound = '{0} dossiers vides trouvés. Les sous-dossiers vides qu''ils contiennent seront aussi supprimés.'
    emptyNone = 'Aucun dossier vide trouvé.'
    bigGroup = 'Les {0} plus gros fichiers'
    bigFound = 'Les {0} fichiers au total : {1}. Cliquez sur une colonne pour trier.'
    noFiles = 'Aucun fichier trouvé.'
    depthScript = 'Scripts (.ts4script), 1 sous-dossier maximum'
    depthPkg = 'Packages (.package), 5 sous-dossiers maximum'
    depthNone = 'Tout va bien : aucun mod n''est trop profond.'
    depthFound = '{0} fichiers sont trop profonds et ne sont pas chargés par le jeu. Cochez-les et cliquez sur "{1}".'
    explorerEmpty = 'La liste est vide. Cliquez d''abord sur "{0}".'
    explorerSelect = 'Cliquez d''abord sur une ligne de la liste.'
    autoMarked = '{0} fichiers cochés. Le fichier le plus récent de chaque groupe est conservé.'
    allMarked = '{0} éléments cochés.'
    nothingMarked = 'Rien n''est coché.'
    keepOne = 'Tout est coché dans "{0}". Au moins un fichier doit rester.'
    confirmDelete = 'Mettre {0} éléments à la corbeille ?'
    deleting = 'Mise à la corbeille : {0} sur {1} ...'
    deleted = '{0} éléments mis à la corbeille.'
    deleteFailed = ' {0} n''ont pas pu être déplacés (le jeu est-il encore ouvert ?).'
    tHint = 'Remarque'; tWarn = 'Attention'; tConfirm = 'Confirmer'; tError = 'Erreur'
    moveNone = 'Cochez d''abord les fichiers à déplacer.'
    moveConfirm = 'Remonter {0} fichiers pour que Sims 4 les charge ?'
    moved = '{0} fichiers rangés correctement.'
    moveSkipped = ' {0} ignorés (un fichier du même nom existe déjà ou le jeu est encore ouvert).'
    listEmpty = 'La liste est vide. Lancez d''abord une recherche.'
    csvFilter = 'Tableau Excel (*.csv)|*.csv'; csvFile = 'Sims4-Rapport'
    csvGroup = 'Groupe'; csvMarked = 'Coché'; csvYes = 'oui'; csvPath = 'Chemin'
    saved = 'Liste enregistrée : {0}'; saveFailed = 'Échec de l''enregistrement : {0}'
    closeSims = 'Veuillez d''abord fermer Sims 4.'
    simsNotFound = 'Le dossier Sims 4 est introuvable.'
    cacheEmpty = 'Le cache est déjà vide.'
    cacheTitle = 'Vider le cache Sims'
    cacheConfirm = 'Vider le cache dans{2}{0} ?{2}({1} fichiers, ils iront à la corbeille){2}{2}Sims 4 reconstruira le cache au prochain démarrage.'
    cacheDone = 'Cache vidé : {0} fichiers mis à la corbeille.'
    cacheFail = ' {0} n''ont pas pu être supprimés.'
    browseDesc = 'Choisissez un dossier, par ex. votre dossier Mods de Sims 4'
    updateOpened = 'La Mod List de Scarlet a été ouverte dans le navigateur. Cherchez-y le nom de votre mod (Ctrl+F).'
    updSfw = 'Mod List : SFW uniquement (sans contenu adulte)'; updNsfw = 'Mod List : SFW + NSFW (contenu adulte, 18+)'
    notModsFolder = 'Cette recherche nécessite votre dossier Mods (ou un dossier à l''intérieur). Le dossier choisi ne se trouve pas dans un dossier nommé "Mods".'
    skippedNotEmpty = ' {0} dossiers ont été ignorés car ils ne sont pas (ou plus) vides.'
}

$Lang['pl'] = @{
    title = 'ModSweep for The Sims 4'
    folder = 'Folder:'; browse = 'Przeglądaj ...'; mode = 'Wyszukaj:'; filetype = 'Typ pliku:'
    simsOnly = 'Tylko pliki Sims (.package i .ts4script)'; search = 'Szukaj'
    colName = 'Nazwa'; colFolder = 'Podfolder'; colSize = 'Rozmiar'; colDate = 'Zmodyfikowano'
    btnExplorer = 'Pokaż w Eksploratorze'; btnAuto = 'Zaznacz (zostaw najnowszy)'; btnAll = 'Zaznacz wszystko'
    btnClear = 'Odznacz wszystko'; btnDelete = 'Przenieś zaznaczone do kosza'; btnSave = 'Zapisz listę (Excel)'
    btnMove = 'Przenieś zaznaczone we właściwe miejsce'; btnUpdate = 'Sprawdź aktualizacje online'; btnCache = 'Wyczyść pamięć podręczną Sims'
    modes = @(
        'Duplikaty: ta sama zawartość (bezpieczne)',
        'Duplikaty: ta sama nazwa pliku (szybkie)',
        'Kilka wersji tego samego moda (np. v4.1 i v4.2)',
        'Wszystkie pliki danego typu (np. .png)',
        'Zbędne pliki (archiwa, readme, obrazy, 0 bajtów)',
        'Puste foldery',
        'Największe pliki',
        'Źle umieszczone mody (zbyt głęboko)')
    hints = @(
        'Znajduje pliki o identycznej zawartości, nawet jeśli mają inne nazwy.',
        'Znajduje pliki o tej samej nazwie w różnych folderach. Zawartość może się różnić.',
        'Znajduje np. "Mod_v4.1" i "Mod_v4.2" lub "Mod (1)". Sprawdź przed usunięciem.',
        'Pokazuje wszystkie pliki podanych typów. Kilka typów oddziel przecinkami.',
        'Pokazuje archiwa, pliki readme, obrazy podglądu i puste pliki. The Sims 4 ich nie potrzebuje.',
        'Pokazuje foldery, w których nie ma już żadnego pliku.',
        'Pokazuje 200 największych plików, aby było widać, co zajmuje najwięcej miejsca.',
        'The Sims 4 wczytuje pliki .ts4script najwyżej 1 podfolder w głąb, a pliki .package najwyżej 5.')
    mainFolder = '(folder główny)'; folderItem = 'Folder'
    folderNotFound = 'Nie znaleziono folderu.'
    enterType = 'Wpisz typ pliku, np. .png'
    collecting = 'Zbieranie plików ...'
    comparing = 'Porównywanie zawartości: {0} z {1} plików ...'
    groupDup = 'Grupa {0}: {1}  (plików: {2})'; groupVer = 'Mod {0}: {1}  (plików: {2})'; groupFolder = '{0}  (plików: {1})'
    hashNone = 'Nie znaleziono duplikatów (sprawdzono plików: {0}).'
    hashFound = 'Znaleziono grup identycznych plików: {0} (sprawdzono plików: {1}). Zmarnowane miejsce: {2}'
    nameNone = 'Nie znaleziono powtarzających się nazw (sprawdzono plików: {0}).'
    nameFound = 'Nazwy plików występujące wielokrotnie: {0}. Uwaga: zawartość może się różnić.'
    verNone = 'Nie znaleziono modów w kilku wersjach.'
    verFound = 'Mody w kilku wersjach: {0}. Najnowszy plik jest na górze. Sprawdź przed usunięciem.'
    typeNone = 'Nie znaleziono plików typu {0}.'
    typeFound = 'Znaleziono plików typu {1}: {0} w folderach: {2}, łącznie {3}.'
    junkEmpty = 'Puste pliki (0 bajtów)'; junkArchive = 'Archiwa (.zip, .rar, .7z)'; junkText = 'Teksty i instrukcje'
    junkImage = 'Obrazy i podglądy'; junkWin = 'Pozostałości systemu (Thumbs.db, desktop.ini, .DS_Store)'
    junkNone = 'Nie znaleziono zbędnych plików.'
    junkFound = 'Znaleziono zbędnych plików: {0}, łącznie {1}. Usuwaj archiwa tylko wtedy, gdy są już rozpakowane.'
    emptyGroup = 'Puste foldery  ({0})'
    emptyFound = 'Znaleziono pustych folderów: {0}. Puste podfoldery w nich też zostaną usunięte.'
    emptyNone = 'Nie znaleziono pustych folderów.'
    bigGroup = '{0} największych plików'
    bigFound = 'Wszystkie pliki ({0}) razem: {1}. Kliknij kolumnę, aby posortować.'
    noFiles = 'Nie znaleziono plików.'
    depthScript = 'Skrypty (.ts4script), dozwolony najwyżej 1 podfolder'
    depthPkg = 'Pakiety (.package), dozwolonych najwyżej 5 podfolderów'
    depthNone = 'Wszystko w porządku: żaden mod nie leży za głęboko.'
    depthFound = 'Plików leżących za głęboko: {0}. Gra ich nie wczytuje. Zaznacz je i kliknij "{1}".'
    explorerEmpty = 'Lista jest pusta. Najpierw kliknij "{0}".'
    explorerSelect = 'Najpierw kliknij wiersz na liście.'
    autoMarked = 'Zaznaczono plików: {0}. Najnowszy plik z każdej grupy zostaje.'
    allMarked = 'Zaznaczono elementów: {0}.'
    nothingMarked = 'Nic nie jest zaznaczone.'
    keepOne = 'W "{0}" zaznaczono wszystko. Przynajmniej jeden plik powinien zostać.'
    confirmDelete = 'Przenieść do kosza elementów: {0}?'
    deleting = 'Przenoszenie do kosza: {0} z {1} ...'
    deleted = 'Przeniesiono do kosza elementów: {0}.'
    deleteFailed = ' Nie udało się przenieść: {0} (czy gra jest jeszcze otwarta?).'
    tHint = 'Informacja'; tWarn = 'Uwaga'; tConfirm = 'Potwierdź'; tError = 'Błąd'
    moveNone = 'Najpierw zaznacz pliki do przeniesienia.'
    moveConfirm = 'Przenieść wyżej plików: {0}, aby The Sims 4 je wczytało?'
    moved = 'Prawidłowo przeniesiono plików: {0}.'
    moveSkipped = ' Pominięto: {0} (plik o tej nazwie już istnieje lub gra jest otwarta).'
    listEmpty = 'Lista jest pusta. Najpierw wyszukaj.'
    csvFilter = 'Tabela Excel (*.csv)|*.csv'; csvFile = 'Sims4-Raport'
    csvGroup = 'Grupa'; csvMarked = 'Zaznaczone'; csvYes = 'tak'; csvPath = 'Ścieżka'
    saved = 'Zapisano listę: {0}'; saveFailed = 'Zapis nie powiódł się: {0}'
    closeSims = 'Najpierw zamknij The Sims 4.'
    simsNotFound = 'Nie znaleziono folderu The Sims 4.'
    cacheEmpty = 'Pamięć podręczna jest już pusta.'
    cacheTitle = 'Wyczyść pamięć podręczną Sims'
    cacheConfirm = 'Wyczyścić pamięć podręczną w{2}{0}?{2}(plików: {1}, trafią do kosza){2}{2}The Sims 4 utworzy ją ponownie przy następnym uruchomieniu.'
    cacheDone = 'Wyczyszczono pamięć podręczną. Przeniesiono do kosza plików: {0}.'
    cacheFail = ' Nie udało się usunąć: {0}.'
    browseDesc = 'Wybierz folder, np. folder Mods gry The Sims 4'
    updateOpened = 'Mod List od Scarlet otwarto w przeglądarce. Wyszukaj tam nazwę swojego moda (Ctrl+F).'
    updSfw = 'Mod List: tylko SFW (bez treści dla dorosłych)'; updNsfw = 'Mod List: SFW + NSFW (treści dla dorosłych, 18+)'
    notModsFolder = 'To wyszukiwanie wymaga folderu Mods (lub folderu wewnątrz niego). Wybrany folder nie znajduje się w folderze o nazwie "Mods".'
    skippedNotEmpty = ' Pominięto folderów: {0}, ponieważ nie są (już) puste.'
}

$Lang['pt'] = @{
    title = 'ModSweep for The Sims 4'
    folder = 'Pasta:'; browse = 'Procurar ...'; mode = 'Pesquisa:'; filetype = 'Tipo:'
    simsOnly = 'Somente arquivos do Sims (.package e .ts4script)'; search = 'Pesquisar'
    colName = 'Nome'; colFolder = 'Subpasta'; colSize = 'Tamanho'; colDate = 'Modificado'
    btnExplorer = 'Mostrar no Explorador'; btnAuto = 'Marcar (manter o mais novo)'; btnAll = 'Marcar tudo'
    btnClear = 'Desmarcar tudo'; btnDelete = 'Mover marcados para a Lixeira'; btnSave = 'Salvar lista (Excel)'
    btnMove = 'Organizar marcados corretamente'; btnUpdate = 'Verificar atualizações online'; btnCache = 'Limpar cache do Sims'
    modes = @(
        'Duplicados: mesmo conteúdo (seguro)',
        'Duplicados: mesmo nome de arquivo (rápido)',
        'Várias versões do mesmo mod (ex. v4.1 e v4.2)',
        'Todos os arquivos de um tipo (ex. .png)',
        'Arquivos desnecessários (compactados, leia-me, imagens, 0 bytes)',
        'Pastas vazias',
        'Maiores arquivos',
        'Mods no lugar errado (muito profundos)')
    hints = @(
        'Encontra arquivos com exatamente o mesmo conteúdo, mesmo com nomes diferentes.',
        'Encontra arquivos com o mesmo nome em pastas diferentes. O conteúdo pode ser diferente.',
        'Encontra ex. "Mod_v4.1" e "Mod_v4.2" ou "Mod (1)". Confira antes de excluir.',
        'Mostra todos os arquivos dos tipos informados. Separe vários tipos com vírgulas.',
        'Mostra compactados, leia-me, imagens de prévia e arquivos vazios. O The Sims 4 não precisa deles.',
        'Mostra pastas que não contêm mais nenhum arquivo.',
        'Mostra os 200 maiores arquivos para você ver o que ocupa mais espaço.',
        'O The Sims 4 carrega .ts4script no máximo 1 subpasta abaixo e .package no máximo 5 subpastas abaixo.')
    mainFolder = '(pasta principal)'; folderItem = 'Pasta'
    folderNotFound = 'A pasta não foi encontrada.'
    enterType = 'Informe um tipo de arquivo, ex. .png'
    collecting = 'Coletando arquivos ...'
    comparing = 'Comparando conteúdo: {0} de {1} arquivos ...'
    groupDup = 'Grupo {0}: {1}  ({2} arquivos)'; groupVer = 'Mod {0}: {1}  ({2} arquivos)'; groupFolder = '{0}  ({1} arquivos)'
    hashNone = 'Nenhum duplicado encontrado ({0} arquivos verificados).'
    hashFound = '{0} grupos de arquivos idênticos encontrados ({1} arquivos verificados). Espaço desperdiçado: {2}'
    nameNone = 'Nenhum nome de arquivo repetido ({0} arquivos verificados).'
    nameFound = '{0} nomes de arquivo aparecem mais de uma vez. Atenção: o conteúdo pode ser diferente.'
    verNone = 'Nenhum mod com várias versões encontrado.'
    verFound = '{0} mods existem em várias versões. O arquivo mais novo aparece em cima. Confira antes de excluir.'
    typeNone = 'Nenhum arquivo do tipo {0} encontrado.'
    typeFound = '{0} arquivos do tipo {1} encontrados em {2} pastas, {3} no total.'
    junkEmpty = 'Arquivos vazios (0 bytes)'; junkArchive = 'Compactados (.zip, .rar, .7z)'; junkText = 'Textos e leia-me'
    junkImage = 'Imagens e prévias'; junkWin = 'Restos do sistema (Thumbs.db, desktop.ini, .DS_Store)'
    junkNone = 'Nenhum arquivo desnecessário encontrado.'
    junkFound = '{0} arquivos desnecessários encontrados, {1} no total. Só exclua compactados que já foram extraídos.'
    emptyGroup = 'Pastas vazias  ({0})'
    emptyFound = '{0} pastas vazias encontradas. Subpastas vazias dentro delas também serão excluídas.'
    emptyNone = 'Nenhuma pasta vazia encontrada.'
    bigGroup = 'Os {0} maiores arquivos'
    bigFound = 'Todos os {0} arquivos juntos: {1}. Clique em uma coluna para ordenar.'
    noFiles = 'Nenhum arquivo encontrado.'
    depthScript = 'Scripts (.ts4script), no máximo 1 subpasta'
    depthPkg = 'Packages (.package), no máximo 5 subpastas'
    depthNone = 'Tudo certo: nenhum mod está fundo demais.'
    depthFound = '{0} arquivos estão fundo demais e não são carregados pelo jogo. Marque-os e clique em "{1}".'
    explorerEmpty = 'A lista está vazia. Clique primeiro em "{0}".'
    explorerSelect = 'Clique primeiro em uma linha da lista.'
    autoMarked = '{0} arquivos marcados. O arquivo mais novo de cada grupo é mantido.'
    allMarked = '{0} itens marcados.'
    nothingMarked = 'Nada está marcado.'
    keepOne = 'Tudo está marcado em "{0}". Pelo menos um arquivo deve ficar.'
    confirmDelete = 'Mover {0} itens para a Lixeira?'
    deleting = 'Movendo para a Lixeira: {0} de {1} ...'
    deleted = '{0} itens movidos para a Lixeira.'
    deleteFailed = ' {0} não puderam ser movidos (o jogo ainda está aberto?).'
    tHint = 'Aviso'; tWarn = 'Atenção'; tConfirm = 'Confirmar'; tError = 'Erro'
    moveNone = 'Marque primeiro os arquivos que devem ser movidos.'
    moveConfirm = 'Mover {0} arquivos para cima para que o The Sims 4 os carregue?'
    moved = '{0} arquivos organizados corretamente.'
    moveSkipped = ' {0} ignorados (já existe um arquivo com o mesmo nome ou o jogo ainda está aberto).'
    listEmpty = 'A lista está vazia. Pesquise primeiro.'
    csvFilter = 'Planilha do Excel (*.csv)|*.csv'; csvFile = 'Sims4-Relatorio'
    csvGroup = 'Grupo'; csvMarked = 'Marcado'; csvYes = 'sim'; csvPath = 'Caminho'
    saved = 'Lista salva: {0}'; saveFailed = 'Falha ao salvar: {0}'
    closeSims = 'Feche o The Sims 4 primeiro.'
    simsNotFound = 'A pasta do The Sims 4 não foi encontrada.'
    cacheEmpty = 'O cache já está vazio.'
    cacheTitle = 'Limpar cache do Sims'
    cacheConfirm = 'Limpar o cache em{2}{0}?{2}({1} arquivos, irão para a Lixeira){2}{2}O The Sims 4 recria o cache na próxima vez que iniciar.'
    cacheDone = 'Cache limpo: {0} arquivos movidos para a Lixeira.'
    cacheFail = ' {0} não puderam ser excluídos.'
    browseDesc = 'Escolha uma pasta, ex. sua pasta Mods do The Sims 4'
    updateOpened = 'A Mod List da Scarlet foi aberta no navegador. Procure lá o nome do seu mod (Ctrl+F).'
    updSfw = 'Mod List: somente SFW (sem conteúdo adulto)'; updNsfw = 'Mod List: SFW + NSFW (conteúdo adulto, 18+)'
    notModsFolder = 'Esta pesquisa precisa da sua pasta Mods (ou de uma pasta dentro dela). A pasta escolhida não está dentro de uma pasta chamada "Mods".'
    skippedNotEmpty = ' {0} pastas foram ignoradas porque não estão (mais) vazias.'
}

# Remember the chosen language between starts
$settingsDir = Join-Path $env:APPDATA 'ModSweep'
$settingsFile = Join-Path $settingsDir 'language.txt'
$script:curLang = 'en'
try {
    if (Test-Path -LiteralPath $settingsFile) {
        $saved = (Get-Content -LiteralPath $settingsFile -ErrorAction Stop | Select-Object -First 1).Trim()
        if ($LangCodes -contains $saved) { $script:curLang = $saved }
    }
} catch { }

function T([string]$key) {
    $v = $Lang[$script:curLang][$key]
    if ($null -eq $v) { $v = $Lang['en'][$key] }
    return $v
}

function Show-Msg([string]$text, [string]$titleKey = 'tHint', [string]$icon = 'None') {
    [System.Windows.Forms.MessageBox]::Show($text, (T $titleKey), 'OK', $icon) | Out-Null
}

function Ask-YesNo([string]$text, [string]$titleKey = 'tConfirm') {
    return ([System.Windows.Forms.MessageBox]::Show($text, (T $titleKey), 'YesNo', 'Question') -eq 'Yes')
}

# =====================================================================
# Helpers
# =====================================================================
$AppVersion = '1.0.1'
$script:lastMode = -1
$script:sorter = New-Object ModSorter

$MODE_HASH = 0; $MODE_NAME = 1; $MODE_VERSION = 2; $MODE_TYPE = 3
$MODE_JUNK = 4; $MODE_EMPTY = 5; $MODE_BIG = 6; $MODE_DEPTH = 7

$simsFolderNames = @('The Sims 4', 'Die Sims 4', 'Les Sims 4', 'Los Sims 4', 'De Sims 4', 'I Sims 4')

function Find-SimsModsFolder {
    $docs = [Environment]::GetFolderPath('MyDocuments')
    foreach ($n in $simsFolderNames) {
        $c = Join-Path $docs "Electronic Arts\$n\Mods"
        if (Test-Path -LiteralPath $c) { return $c }
    }
    return $docs
}

function Find-SimsFolder {
    $p = $txtFolder.Text.Trim().TrimEnd('\')
    if ($p -and (Split-Path $p -Leaf) -ieq 'Mods') {
        $parent = Split-Path $p -Parent
        # Only accept it if it really is the Sims 4 folder, not e.g. Minecraft\Mods
        if ($parent -and (Test-Path -LiteralPath $parent) -and (
                ($simsFolderNames -contains (Split-Path $parent -Leaf)) -or
                (Test-Path -LiteralPath (Join-Path $parent 'localthumbcache.package')) -or
                (Test-Path -LiteralPath (Join-Path $parent 'Options.ini')))) {
            return $parent
        }
    }
    $docs = [Environment]::GetFolderPath('MyDocuments')
    foreach ($n in $simsFolderNames) {
        $c = Join-Path $docs "Electronic Arts\$n"
        if (Test-Path -LiteralPath $c) { return $c }
    }
    return $null
}

function Format-Size([long]$bytes) {
    if ($bytes -ge 1GB) { return ('{0:N2} GB' -f ($bytes / 1GB)) }
    if ($bytes -ge 1MB) { return ('{0:N2} MB' -f ($bytes / 1MB)) }
    if ($bytes -ge 1KB) { return ('{0:N1} KB' -f ($bytes / 1KB)) }
    return "$bytes B"
}

function Get-RelativeDir([string]$dir, [string]$root) {
    if ($dir.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) {
        $rel = $dir.Substring($root.Length).TrimStart('\')
    } else { $rel = $dir }
    if (-not $rel) { $rel = T 'mainFolder' }
    return $rel
}

function Get-Depth([string]$dir, [string]$root) {
    if (-not $dir.StartsWith($root, [System.StringComparison]::OrdinalIgnoreCase)) { return 0 }
    $rel = $dir.Substring($root.Length).Trim('\')
    if (-not $rel) { return 0 }
    return ($rel -split '\\').Count
}

function Get-Extensions([string]$text) {
    $result = @()
    foreach ($part in ($text -split '[,; ]+')) {
        $p = $part.Trim().Trim('*').ToLowerInvariant()
        if (-not $p) { continue }
        if (-not $p.StartsWith('.')) { $p = '.' + $p }
        $result += $p
    }
    return $result
}

$versionRegex = '[\s_\-\.]*((?<![a-z])v(er(sion)?)?[\s_\.]?\d+([\._]\d+)*[a-z]?|\d+\.\d+(\.\d+)*[a-z]?|\(\d+\)|(?<![a-z])(kopie|copy)(?![a-z]))'
function Get-VersionKey($f) {
    $b = $f.BaseName.ToLowerInvariant()
    $s = [regex]::Replace($b, $versionRegex, '')
    return $s.Trim(' ', '_', '-', '.')
}

function Test-Leftover([string]$name) {
    $low = $name.ToLowerInvariant()
    return ($low -eq 'thumbs.db' -or $low -eq 'desktop.ini' -or $low -eq '.ds_store' -or $name.StartsWith('._'))
}

# Walks a folder tree. Skips junctions and symbolic links and remembers folders
# that could not be read, so they are never mistaken for empty folders.
function Get-Tree([string]$root) {
    $files = New-Object System.Collections.Generic.List[System.IO.FileInfo]
    $dirs = New-Object System.Collections.Generic.List[System.IO.DirectoryInfo]
    $bad = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $stack = New-Object System.Collections.Generic.Stack[System.IO.DirectoryInfo]
    $stack.Push((New-Object System.IO.DirectoryInfo($root)))
    while ($stack.Count -gt 0) {
        $d = $stack.Pop()
        try { $entries = $d.GetFileSystemInfos() } catch { [void]$bad.Add($d.FullName); continue }
        foreach ($en in $entries) {
            if ($en -is [System.IO.DirectoryInfo]) {
                if ($en.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { [void]$bad.Add($en.FullName); continue }
                $dirs.Add($en)
                $stack.Push($en)
            } else {
                $files.Add($en)
            }
        }
    }
    return @{ Files = $files.ToArray(); Dirs = $dirs.ToArray(); Bad = $bad }
}

# True if a folder still holds nothing but system leftovers and could be read completely
function Test-FolderStillEmpty([string]$path) {
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { return $false }
    $t = Get-Tree $path
    if ($t.Bad.Count -gt 0) { return $false }
    foreach ($f in $t.Files) { if (-not (Test-Leftover $f.Name)) { return $false } }
    return $true
}

# Finds the folder named "Mods" that contains $path (or $path itself)
function Find-ModsBase([string]$path) {
    $p = $path
    while ($p) {
        if ((Split-Path $p -Leaf) -ieq 'Mods') { return $p }
        $parent = Split-Path $p -Parent
        if (-not $parent -or $parent -eq $p) { break }
        $p = $parent
    }
    return $null
}

# =====================================================================
# Window
# =====================================================================
$form = New-Object System.Windows.Forms.Form
$form.Size = New-Object System.Drawing.Size(980, 700)
$form.MinimumSize = New-Object System.Drawing.Size(940, 460)
$form.StartPosition = 'CenterScreen'
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)

# App icon: uses icon.ico next to the script if present, otherwise draws its own logo
function New-AppIcon {
    $custom = Join-Path $PSScriptRoot 'icon.ico'
    if (Test-Path -LiteralPath $custom) {
        try { return New-Object System.Drawing.Icon($custom) } catch { }
    }
    $bmp = New-Object System.Drawing.Bitmap(64, 64)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)

    # Rounded purple background
    $r = 14
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddArc(2, 2, $r * 2, $r * 2, 180, 90)
    $path.AddArc(62 - $r * 2, 2, $r * 2, $r * 2, 270, 90)
    $path.AddArc(62 - $r * 2, 62 - $r * 2, $r * 2, $r * 2, 0, 90)
    $path.AddArc(2, 62 - $r * 2, $r * 2, $r * 2, 90, 90)
    $path.CloseFigure()
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        (New-Object System.Drawing.Point(0, 0)), (New-Object System.Drawing.Point(64, 64)),
        [System.Drawing.Color]::FromArgb(124, 77, 255), [System.Drawing.Color]::FromArgb(64, 40, 160))
    $g.FillPath($bg, $path)

    # White folder
    $g.FillRectangle([System.Drawing.Brushes]::White, 12, 20, 18, 8)
    $g.FillRectangle([System.Drawing.Brushes]::White, 12, 25, 40, 26)

    # Check mark on the folder
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 55, 200), 5)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $check = [System.Drawing.Point[]]@(
        (New-Object System.Drawing.Point(22, 38)),
        (New-Object System.Drawing.Point(29, 45)),
        (New-Object System.Drawing.Point(42, 31)))
    $g.DrawLines($pen, $check)

    # Golden sparkle
    $star = [System.Drawing.PointF[]]@(
        (New-Object System.Drawing.PointF(50, 4)),  (New-Object System.Drawing.PointF(53, 11)),
        (New-Object System.Drawing.PointF(60, 14)), (New-Object System.Drawing.PointF(53, 17)),
        (New-Object System.Drawing.PointF(50, 24)), (New-Object System.Drawing.PointF(47, 17)),
        (New-Object System.Drawing.PointF(40, 14)), (New-Object System.Drawing.PointF(47, 11)))
    $g.FillPolygon([System.Drawing.Brushes]::Gold, $star)

    $g.Dispose()
    return [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
}
try { $form.Icon = New-AppIcon } catch { }

# Top area (width set first so right anchored controls sit correctly)
$top = New-Object System.Windows.Forms.Panel
$top.Dock = 'Top'
$top.Size = New-Object System.Drawing.Size(964, 142)
$rx = 780   # left edge of the right column

$lblFolder = New-Object System.Windows.Forms.Label
$lblFolder.Location = New-Object System.Drawing.Point(10, 14)
$lblFolder.AutoSize = $true

$txtFolder = New-Object System.Windows.Forms.TextBox
$txtFolder.Location = New-Object System.Drawing.Point(80, 10)
$txtFolder.Width = 690
$txtFolder.Anchor = 'Top, Left, Right'
$txtFolder.Text = Find-SimsModsFolder

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Location = New-Object System.Drawing.Point($rx, 8)
$btnBrowse.Size = New-Object System.Drawing.Size(170, 27)
$btnBrowse.Anchor = 'Top, Right'

$lblMode = New-Object System.Windows.Forms.Label
$lblMode.Location = New-Object System.Drawing.Point(10, 48)
$lblMode.AutoSize = $true

$cmbMode = New-Object System.Windows.Forms.ComboBox
$cmbMode.DropDownStyle = 'DropDownList'
$cmbMode.Location = New-Object System.Drawing.Point(80, 44)
$cmbMode.Width = 380
$cmbMode.DropDownWidth = 540

$lblExt = New-Object System.Windows.Forms.Label
$lblExt.Location = New-Object System.Drawing.Point(475, 48)
$lblExt.AutoSize = $true

$txtExt = New-Object System.Windows.Forms.TextBox
$txtExt.Location = New-Object System.Drawing.Point(545, 44)
$txtExt.Width = 140
$txtExt.Text = '.png'

$cmbLang = New-Object System.Windows.Forms.ComboBox
$cmbLang.DropDownStyle = 'DropDownList'
$cmbLang.Location = New-Object System.Drawing.Point($rx, 44)
$cmbLang.Width = 170
$cmbLang.Anchor = 'Top, Right'
foreach ($n in $LangNames) { $cmbLang.Items.Add($n) | Out-Null }

$chkSims = New-Object System.Windows.Forms.CheckBox
$chkSims.Location = New-Object System.Drawing.Point(80, 78)
$chkSims.AutoSize = $true
$chkSims.Checked = $true

$btnScan = New-Object System.Windows.Forms.Button
$btnScan.Location = New-Object System.Drawing.Point($rx, 74)
$btnScan.Size = New-Object System.Drawing.Size(170, 30)
$btnScan.Anchor = 'Top, Right'
$btnScan.Font = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)

# Description of the selected search type, in red so it stands out
$lblHint = New-Object System.Windows.Forms.Label
$lblHint.Location = New-Object System.Drawing.Point(10, 112)
$lblHint.Size = New-Object System.Drawing.Size(944, 24)
$lblHint.Anchor = 'Top, Left, Right'
$lblHint.ForeColor = [System.Drawing.Color]::FromArgb(205, 30, 45)
$lblHint.Font = New-Object System.Drawing.Font('Segoe UI', 9.5, [System.Drawing.FontStyle]::Bold)

$top.Controls.AddRange(@($lblHint, $lblFolder, $txtFolder, $btnBrowse, $lblMode, $cmbMode, $lblExt, $txtExt, $cmbLang, $chkSims, $btnScan))

# List
$list = New-Object System.Windows.Forms.ListView
$list.Dock = 'Fill'
$list.View = 'Details'
$list.FullRowSelect = $true
$list.CheckBoxes = $true
$list.ShowGroups = $true
$list.HideSelection = $false
$list.Columns.Add('', 320) | Out-Null
$list.Columns.Add('', 340) | Out-Null
$list.Columns.Add('', 90) | Out-Null
$list.Columns.Add('', 140) | Out-Null

# Bottom area: buttons flow and wrap automatically, so longer translations fit
$bottom = New-Object System.Windows.Forms.Panel
$bottom.Dock = 'Bottom'
$bottom.Height = 110

$flow = New-Object System.Windows.Forms.FlowLayoutPanel
$flow.Dock = 'Fill'
$flow.WrapContents = $true
$flow.Padding = New-Object System.Windows.Forms.Padding(6, 6, 6, 0)

$status = New-Object System.Windows.Forms.Label
$status.Dock = 'Bottom'
$status.Height = 26
$status.Padding = New-Object System.Windows.Forms.Padding(10, 4, 10, 0)

function New-FlowButton {
    $b = New-Object System.Windows.Forms.Button
    $b.AutoSize = $true
    $b.AutoSizeMode = 'GrowAndShrink'
    $b.MinimumSize = New-Object System.Drawing.Size(90, 30)
    $b.Padding = New-Object System.Windows.Forms.Padding(6, 0, 6, 0)
    $flow.Controls.Add($b)
    return $b
}

$btnExplorer = New-FlowButton
$btnAuto     = New-FlowButton
$btnAll      = New-FlowButton
$btnClear    = New-FlowButton
$btnDelete   = New-FlowButton
$btnDelete.ForeColor = [System.Drawing.Color]::DarkRed
$flow.SetFlowBreak($btnDelete, $true)
$btnSave     = New-FlowButton
$btnMove     = New-FlowButton
$btnUpdate   = New-FlowButton
$btnCache    = New-FlowButton

# Menu for the update button: users choose SFW or SFW + NSFW themselves
$updMenu = New-Object System.Windows.Forms.ContextMenuStrip
$miSfw = $updMenu.Items.Add('')
$miNsfw = $updMenu.Items.Add('')

$bottom.Controls.Add($flow)
$bottom.Controls.Add($status)
$flow.BringToFront()

$form.Controls.Add($list)
$form.Controls.Add($top)
$form.Controls.Add($bottom)
$list.BringToFront()
$form.AcceptButton = $btnScan

function Update-BottomLayout {
    $w = [Math]::Max(200, $bottom.ClientSize.Width)
    $pref = $flow.GetPreferredSize((New-Object System.Drawing.Size($w, 0)))
    $bottom.Height = $pref.Height + $status.Height + 6
}

function Update-TopLayout {
    $x = [Math]::Max($lblFolder.PreferredWidth, $lblMode.PreferredWidth) + 18
    $txtFolder.Left = $x
    $txtFolder.Width = [Math]::Max(100, $btnBrowse.Left - 10 - $x)
    $cmbMode.Left = $x
    $chkSims.Left = $x
    $lblExt.Left = $cmbMode.Right + 12
    $txtExt.Left = $lblExt.Left + $lblExt.PreferredWidth + 4
    $txtExt.Width = [Math]::Max(60, $cmbLang.Left - 12 - $txtExt.Left)
}

# =====================================================================
# Language switching
# =====================================================================
function Update-ModeControls {
    $m = $cmbMode.SelectedIndex
    $chkSims.Enabled = ($m -in @($MODE_HASH, $MODE_NAME, $MODE_VERSION, $MODE_BIG))
    $txtExt.Enabled = ($m -eq $MODE_TYPE)
    $lblExt.Enabled = $txtExt.Enabled
    if ($m -ge 0) { $lblHint.Text = $Lang[$script:curLang]['hints'][$m] }
}

function Apply-Language {
    $form.Text = "$(T 'title') $AppVersion"
    $lblFolder.Text = T 'folder'
    $btnBrowse.Text = T 'browse'
    $lblMode.Text = T 'mode'
    $lblExt.Text = T 'filetype'
    $chkSims.Text = T 'simsOnly'
    $btnScan.Text = T 'search'
    $list.Columns[0].Text = T 'colName'
    $list.Columns[1].Text = T 'colFolder'
    $list.Columns[2].Text = T 'colSize'
    $list.Columns[3].Text = T 'colDate'
    $btnExplorer.Text = T 'btnExplorer'
    $btnAuto.Text = T 'btnAuto'
    $btnAll.Text = T 'btnAll'
    $btnClear.Text = T 'btnClear'
    $btnDelete.Text = T 'btnDelete'
    $btnSave.Text = T 'btnSave'
    $btnMove.Text = T 'btnMove'
    $btnUpdate.Text = T 'btnUpdate'
    $btnCache.Text = T 'btnCache'
    $miSfw.Text = T 'updSfw'
    $miNsfw.Text = T 'updNsfw'

    $sel = [Math]::Max(0, $cmbMode.SelectedIndex)
    $cmbMode.BeginUpdate()
    $cmbMode.Items.Clear()
    foreach ($m in $Lang[$script:curLang]['modes']) { $cmbMode.Items.Add($m) | Out-Null }
    $cmbMode.EndUpdate()
    $cmbMode.SelectedIndex = $sel

    Update-TopLayout
    Update-BottomLayout
    Update-ModeControls
}

# =====================================================================
# List helpers
# =====================================================================
function Update-Ui { [System.Windows.Forms.Application]::DoEvents() }

function New-Group([string]$header) {
    $g = New-Object System.Windows.Forms.ListViewGroup($header)
    $list.Groups.Add($g) | Out-Null
    return $g
}

function Add-FileItem($f, [string]$root, $lvg) {
    $entry = New-Object ModEntry -ArgumentList $f.FullName, ([long]$f.Length), $f.LastWriteTime, $false
    $item = New-Object System.Windows.Forms.ListViewItem($f.Name)
    $item.SubItems.Add((Get-RelativeDir $f.DirectoryName $root)) | Out-Null
    $item.SubItems.Add((Format-Size $f.Length)) | Out-Null
    $item.SubItems.Add($f.LastWriteTime.ToString('g')) | Out-Null
    $item.Tag = $entry
    $item.Group = $lvg
    $list.Items.Add($item) | Out-Null
    return $entry
}

function Add-FolderItem($d, [string]$root, $lvg) {
    $entry = New-Object ModEntry -ArgumentList $d.FullName, ([long]0), $d.LastWriteTime, $true
    $item = New-Object System.Windows.Forms.ListViewItem($d.Name)
    $item.SubItems.Add((Get-RelativeDir $d.Parent.FullName $root)) | Out-Null
    $item.SubItems.Add((T 'folderItem')) | Out-Null
    $item.SubItems.Add($d.LastWriteTime.ToString('g')) | Out-Null
    $item.Tag = $entry
    $item.Group = $lvg
    $list.Items.Add($item) | Out-Null
}

function Add-DuplicateGroups($groups, [string]$root, [string]$headerKey) {
    $n = 0
    foreach ($g in $groups) {
        $n++
        $sorted = @($g | Sort-Object LastWriteTime -Descending)
        $lvg = New-Group ((T $headerKey) -f $n, $sorted[0].Name, $sorted.Count)
        foreach ($f in $sorted) { Add-FileItem $f $root $lvg | Out-Null }
    }
    return $n
}

# =====================================================================
# Search
# =====================================================================
function Start-Scan {
    $mode = $cmbMode.SelectedIndex
    $rootInput = $txtFolder.Text.Trim()
    if (-not $rootInput -or -not (Test-Path -LiteralPath $rootInput -PathType Container)) {
        Show-Msg (T 'folderNotFound') 'tWarn' 'Warning'
        return
    }
    $root = (Resolve-Path -LiteralPath $rootInput).ProviderPath.TrimEnd('\')

    $exts = @()
    if ($mode -eq $MODE_TYPE) {
        $exts = @(Get-Extensions $txtExt.Text)
        if ($exts.Count -eq 0) { Show-Msg (T 'enterType'); return }
    }

    $list.ListViewItemSorter = $null
    $list.Items.Clear()
    $list.Groups.Clear()
    $btnScan.Enabled = $false
    $flow.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $status.Text = T 'collecting'
    Update-Ui

    try {
        $tree = Get-Tree $root
        $files = @($tree.Files)
        if ($mode -ne $MODE_JUNK) {
            # System leftovers like Thumbs.db or ._name are not real mods
            $files = @($files | Where-Object { -not (Test-Leftover $_.Name) })
        }
        $simsOnly = $chkSims.Checked -and ($mode -in @($MODE_HASH, $MODE_NAME, $MODE_VERSION, $MODE_BIG))
        if ($simsOnly) {
            $files = @($files | Where-Object { $_.Extension -in @('.package', '.ts4script') })
        }
        $msg = ''
        $list.BeginUpdate()

        switch ($mode) {

            0 {  # same content
                # Only files of equal size can be identical, this saves a lot of time
                $toHash = New-Object System.Collections.Generic.List[object]
                foreach ($g in ($files | Where-Object { $_.Length -gt 0 } | Group-Object Length)) {
                    if ($g.Count -gt 1) { foreach ($f in $g.Group) { $toHash.Add($f) } }
                }
                $byHash = @{}
                $i = 0
                foreach ($f in $toHash) {
                    $i++
                    if ($i % 10 -eq 0) {
                        $status.Text = (T 'comparing') -f $i, $toHash.Count
                        Update-Ui
                    }
                    try {
                        $h = (Get-FileHash -LiteralPath $f.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
                    } catch { continue }
                    $key = "$($f.Length)|$h"
                    if (-not $byHash.ContainsKey($key)) {
                        $byHash[$key] = New-Object System.Collections.Generic.List[object]
                    }
                    $byHash[$key].Add($f)
                }
                $groups = New-Object System.Collections.Generic.List[object]
                $wasted = 0
                foreach ($k in $byHash.Keys) {
                    if ($byHash[$k].Count -gt 1) {
                        $groups.Add($byHash[$k])
                        $wasted += [long]$byHash[$k][0].Length * ($byHash[$k].Count - 1)
                    }
                }
                $n = Add-DuplicateGroups $groups $root 'groupDup'
                if ($n -eq 0) { $msg = (T 'hashNone') -f $files.Count }
                else { $msg = (T 'hashFound') -f $n, $files.Count, (Format-Size $wasted) }
            }

            1 {  # same name
                $groups = New-Object System.Collections.Generic.List[object]
                foreach ($g in ($files | Group-Object { $_.Name.ToLowerInvariant() })) {
                    if ($g.Count -gt 1) { $groups.Add($g.Group) }
                }
                $n = Add-DuplicateGroups $groups $root 'groupDup'
                if ($n -eq 0) { $msg = (T 'nameNone') -f $files.Count }
                else { $msg = (T 'nameFound') -f $n }
            }

            2 {  # versions
                $groups = New-Object System.Collections.Generic.List[object]
                foreach ($g in ($files | Group-Object { (Get-VersionKey $_) + '|' + $_.Extension.ToLowerInvariant() })) {
                    if ($g.Count -lt 2) { continue }
                    $keyName = $g.Name.Split('|')[0]
                    if ($keyName.Length -lt 3) { continue }
                    $distinct = @($g.Group | ForEach-Object { $_.Name.ToLowerInvariant() } | Select-Object -Unique)
                    if ($distinct.Count -lt 2) { continue }
                    $groups.Add($g.Group)
                }
                $n = Add-DuplicateGroups $groups $root 'groupVer'
                if ($n -eq 0) { $msg = T 'verNone' }
                else { $msg = (T 'verFound') -f $n }
            }

            3 {  # file type
                $found = @($files | Where-Object { $exts -contains $_.Extension.ToLowerInvariant() })
                $total = 0
                $folders = 0
                foreach ($g in ($found | Group-Object DirectoryName | Sort-Object Name)) {
                    $folders++
                    $lvg = New-Group ((T 'groupFolder') -f (Get-RelativeDir $g.Name $root), $g.Count)
                    foreach ($f in ($g.Group | Sort-Object Name)) {
                        Add-FileItem $f $root $lvg | Out-Null
                        $total += $f.Length
                    }
                }
                $typText = $exts -join ', '
                if ($found.Count -eq 0) { $msg = (T 'typeNone') -f $typText }
                else { $msg = (T 'typeFound') -f $found.Count, $typText, $folders, (Format-Size $total) }
            }

            4 {  # unneeded files
                $catKeys = @('junkEmpty', 'junkArchive', 'junkText', 'junkImage', 'junkWin')
                $cats = @{}
                foreach ($k in $catKeys) { $cats[$k] = New-Object System.Collections.Generic.List[object] }
                $archive = @('.zip', '.rar', '.7z')
                $texts = @('.txt', '.pdf', '.url', '.html', '.htm', '.md', '.rtf', '.doc', '.docx')
                $images = @('.png', '.jpg', '.jpeg', '.gif', '.webp', '.bmp')
                foreach ($f in $files) {
                    $e = $f.Extension.ToLowerInvariant()
                    if (Test-Leftover $f.Name) { $cats['junkWin'].Add($f) }
                    elseif ($f.Length -eq 0) { $cats['junkEmpty'].Add($f) }
                    elseif ($archive -contains $e) { $cats['junkArchive'].Add($f) }
                    elseif ($texts -contains $e) { $cats['junkText'].Add($f) }
                    elseif ($images -contains $e) { $cats['junkImage'].Add($f) }
                }
                $count = 0; $total = 0
                foreach ($k in $catKeys) {
                    $items = $cats[$k]
                    if ($items.Count -eq 0) { continue }
                    $lvg = New-Group ((T 'groupFolder') -f (T $k), $items.Count)
                    foreach ($f in ($items | Sort-Object FullName)) {
                        Add-FileItem $f $root $lvg | Out-Null
                        $count++; $total += $f.Length
                    }
                }
                if ($count -eq 0) { $msg = T 'junkNone' }
                else { $msg = (T 'junkFound') -f $count, (Format-Size $total) }
            }

            5 {  # empty folders
                $dirs = @($tree.Dirs)
                $withFiles = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
                # Folders with real files, and folders that could not be read completely, are never empty
                $keep = New-Object System.Collections.Generic.List[string]
                foreach ($f in $files) { $keep.Add($f.DirectoryName) }
                foreach ($b in $tree.Bad) { $keep.Add($b) }
                foreach ($d in $keep) {
                    while ($d -and $d.Length -gt $root.Length -and $withFiles.Add($d)) {
                        $d = Split-Path $d -Parent
                    }
                }
                $empty = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
                foreach ($d in $dirs) { if (-not $withFiles.Contains($d.FullName)) { $empty.Add($d.FullName) | Out-Null } }
                # Only show the top most empty folders, empty subfolders are deleted with them
                $topEmpty = @($dirs | Where-Object { $empty.Contains($_.FullName) -and -not $empty.Contains($_.Parent.FullName) } | Sort-Object FullName)
                if ($topEmpty.Count -gt 0) {
                    $lvg = New-Group ((T 'emptyGroup') -f $topEmpty.Count)
                    foreach ($d in $topEmpty) { Add-FolderItem $d $root $lvg }
                    $msg = (T 'emptyFound') -f $topEmpty.Count
                } else { $msg = T 'emptyNone' }
            }

            6 {  # largest files
                $big = @($files | Sort-Object Length -Descending | Select-Object -First 200)
                if ($big.Count -gt 0) {
                    $sum = 0; foreach ($f in $files) { $sum += $f.Length }
                    $lvg = New-Group ((T 'bigGroup') -f $big.Count)
                    foreach ($f in $big) { Add-FileItem $f $root $lvg | Out-Null }
                    $msg = (T 'bigFound') -f $files.Count, (Format-Size $sum)
                } else { $msg = T 'noFiles' }
            }

            7 {  # nested too deep
                $lvgScript = $null; $lvgPkg = $null
                $count = 0
                # Depth always counts from the folder named "Mods"
                $base = Find-ModsBase $root
                if (-not $base) {
                    $msg = T 'notModsFolder'
                    Show-Msg $msg 'tWarn' 'Warning'
                    break
                }
                foreach ($f in ($files | Sort-Object FullName)) {
                    $e = $f.Extension.ToLowerInvariant()
                    if ($e -eq '.ts4script') { $max = 1 }
                    elseif ($e -eq '.package') { $max = 5 }
                    else { continue }
                    $depth = Get-Depth $f.DirectoryName $base
                    if ($depth -le $max) { continue }
                    $parts = $f.DirectoryName.Substring($base.Length).Trim('\') -split '\\'
                    $target = $base
                    for ($k = 0; $k -lt $max; $k++) { $target = Join-Path $target $parts[$k] }
                    if ($e -eq '.ts4script') {
                        if (-not $lvgScript) { $lvgScript = New-Group (T 'depthScript') }
                        $lvg = $lvgScript
                    } else {
                        if (-not $lvgPkg) { $lvgPkg = New-Group (T 'depthPkg') }
                        $lvg = $lvgPkg
                    }
                    $entry = Add-FileItem $f $root $lvg
                    $entry.Target = $target
                    $count++
                }
                if ($count -eq 0) { $msg = T 'depthNone' }
                else { $msg = (T 'depthFound') -f $count, (T 'btnMove') }
            }
        }

        $script:lastMode = $mode
        $btnAuto.Enabled = ($mode -in @($MODE_HASH, $MODE_NAME, $MODE_VERSION))
        $btnMove.Enabled = ($mode -eq $MODE_DEPTH)
        $status.Text = $msg
    }
    finally {
        $list.EndUpdate()
        $btnScan.Enabled = $true
        $flow.Enabled = $true
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
    }
}

# =====================================================================
# Actions
# =====================================================================
function Show-InExplorer {
    $item = $null
    if ($list.SelectedItems.Count -gt 0) { $item = $list.SelectedItems[0] }
    elseif ($list.CheckedItems.Count -gt 0) { $item = $list.CheckedItems[0] }
    if (-not $item) {
        if ($list.Items.Count -eq 0) { Show-Msg ((T 'explorerEmpty') -f (T 'search')) }
        else { Show-Msg (T 'explorerSelect') }
        return
    }
    Start-Process explorer.exe -ArgumentList "/select,`"$($item.Tag.Path)`""
}

function Set-AutoMark {
    foreach ($grp in $list.Groups) {
        $first = $true
        foreach ($it in $grp.Items) {
            $it.Checked = -not $first
            $first = $false
        }
    }
    $status.Text = (T 'autoMarked') -f $list.CheckedItems.Count
}

function Set-AllMark {
    foreach ($it in $list.Items) { $it.Checked = $true }
    $status.Text = (T 'allMarked') -f $list.CheckedItems.Count
}

function Remove-Checked {
    $checked = @($list.CheckedItems)
    if ($checked.Count -eq 0) { Show-Msg (T 'nothingMarked'); return }
    # For duplicates and versions at least one file of each group must stay
    if ($script:lastMode -in @($MODE_HASH, $MODE_NAME, $MODE_VERSION)) {
        foreach ($grp in $list.Groups) {
            if ($grp.Items.Count -gt 0) {
                $all = $true
                foreach ($it in $grp.Items) { if (-not $it.Checked) { $all = $false; break } }
                if ($all) {
                    Show-Msg ((T 'keepOne') -f $grp.Header) 'tWarn' 'Warning'
                    return
                }
            }
        }
    }
    if (-not (Ask-YesNo ((T 'confirmDelete') -f $checked.Count))) { return }

    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $flow.Enabled = $false
    $btnScan.Enabled = $false
    $list.BeginUpdate()
    $ok = 0; $fail = 0; $notEmpty = 0
    try {
        foreach ($it in $checked) {
            $path = $it.Tag.Path
            # Check folders again right before deleting: something may have been added
            if ($it.Tag.IsFolder -and -not (Test-FolderStillEmpty $path)) { $notEmpty++; continue }
            $null = [Recycler]::Send($path)
            if (Test-Path -LiteralPath $path) { $fail++ }
            else {
                $list.Items.Remove($it)
                $ok++
            }
            if (($ok + $fail) % 25 -eq 0) {
                $status.Text = (T 'deleting') -f ($ok + $fail), $checked.Count
                Update-Ui
            }
        }
    }
    finally {
        $list.EndUpdate()
        $flow.Enabled = $true
        $btnScan.Enabled = $true
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
    }
    $msg = (T 'deleted') -f $ok
    if ($fail -gt 0) { $msg += (T 'deleteFailed') -f $fail }
    if ($notEmpty -gt 0) { $msg += (T 'skippedNotEmpty') -f $notEmpty }
    $status.Text = $msg
}

function Move-Checked {
    $checked = @($list.CheckedItems | Where-Object { $_.Tag.Target })
    if ($checked.Count -eq 0) { Show-Msg (T 'moveNone'); return }
    if (-not (Ask-YesNo ((T 'moveConfirm') -f $checked.Count))) { return }
    $ok = 0; $skip = 0
    foreach ($it in $checked) {
        $dest = Join-Path $it.Tag.Target (Split-Path $it.Tag.Path -Leaf)
        if (Test-Path -LiteralPath $dest) { $skip++; continue }
        try {
            [System.IO.File]::Move($it.Tag.Path, $dest)
            $list.Items.Remove($it)
            $ok++
        } catch { $skip++ }
    }
    $msg = (T 'moved') -f $ok
    if ($skip -gt 0) { $msg += (T 'moveSkipped') -f $skip }
    $status.Text = $msg
}

function Save-Report {
    if ($list.Items.Count -eq 0) { Show-Msg (T 'listEmpty'); return }
    $dlg = New-Object System.Windows.Forms.SaveFileDialog
    $dlg.Filter = T 'csvFilter'
    $dlg.FileName = "$(T 'csvFile')_$(Get-Date -Format 'yyyy-MM-dd_HH-mm').csv"
    $dlg.InitialDirectory = [Environment]::GetFolderPath('Desktop')
    if ($dlg.ShowDialog() -ne 'OK') { return }
    $rows = foreach ($it in $list.Items) {
        $o = [ordered]@{}
        $o[(T 'csvGroup')]  = $(if ($it.Group) { $it.Group.Header } else { '' })
        $o[(T 'csvMarked')] = $(if ($it.Checked) { T 'csvYes' } else { '' })
        $o[(T 'colName')]   = $it.Text
        $o[(T 'colFolder')] = $it.SubItems[1].Text
        $o[(T 'colSize')]   = $it.SubItems[2].Text
        $o[(T 'colDate')]   = $it.SubItems[3].Text
        $o[(T 'csvPath')]   = $it.Tag.Path
        [pscustomobject]$o
    }
    try {
        $rows | Export-Csv -LiteralPath $dlg.FileName -UseCulture -NoTypeInformation -Encoding UTF8
        $status.Text = (T 'saved') -f $dlg.FileName
    } catch {
        Show-Msg ((T 'saveFailed') -f $_.Exception.Message) 'tError' 'Error'
    }
}

function Clear-SimsCache {
    if (Get-Process -Name 'TS4_x64', 'TS4', 'TS4_DX9_x64' -ErrorAction SilentlyContinue) {
        Show-Msg (T 'closeSims') 'tWarn' 'Warning'
        return
    }
    $sims = Find-SimsFolder
    if (-not $sims) { Show-Msg (T 'simsNotFound'); return }
    $targets = New-Object System.Collections.Generic.List[string]
    $thumb = Join-Path $sims 'localthumbcache.package'
    if (Test-Path -LiteralPath $thumb) { $targets.Add($thumb) }
    foreach ($sub in @('cache', 'cachestr', 'onlinethumbnailcache')) {
        $p = Join-Path $sims $sub
        if (Test-Path -LiteralPath $p) {
            foreach ($f in (Get-Tree $p).Files) { $targets.Add($f.FullName) }
        }
    }
    if ($targets.Count -eq 0) { $status.Text = T 'cacheEmpty'; return }
    if (-not (Ask-YesNo ((T 'cacheConfirm') -f $sims, $targets.Count, "`n") 'cacheTitle')) { return }
    $ok = 0; $fail = 0
    foreach ($t in $targets) {
        $null = [Recycler]::Send($t)
        if (Test-Path -LiteralPath $t) { $fail++ } else { $ok++ }
    }
    $msg = (T 'cacheDone') -f $ok
    if ($fail -gt 0) { $msg += (T 'cacheFail') -f $fail }
    $status.Text = $msg
}

# =====================================================================
# Events
# =====================================================================
$btnBrowse.Add_Click({
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = T 'browseDesc'
    if (Test-Path -LiteralPath $txtFolder.Text) { $dlg.SelectedPath = $txtFolder.Text }
    if ($dlg.ShowDialog() -eq 'OK') { $txtFolder.Text = $dlg.SelectedPath }
})
$cmbMode.Add_SelectedIndexChanged({ Update-ModeControls })
$cmbLang.Add_SelectedIndexChanged({
    if ($cmbLang.SelectedIndex -lt 0) { return }
    $script:curLang = $LangCodes[$cmbLang.SelectedIndex]
    Apply-Language
    try {
        if (-not (Test-Path -LiteralPath $settingsDir)) { New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null }
        Set-Content -LiteralPath $settingsFile -Value $script:curLang -ErrorAction Stop
    } catch { }
})
$btnScan.Add_Click({ Start-Scan })
$btnExplorer.Add_Click({ Show-InExplorer })
$list.Add_DoubleClick({ Show-InExplorer })
# A double click in a ListView with check boxes would also toggle the box. Prevent that.
$script:dblClickTime = [DateTime]::MinValue
$list.Add_MouseDown({ param($s, $e) if ($e.Clicks -gt 1) { $script:dblClickTime = [DateTime]::Now } })
$list.Add_ItemCheck({
    param($s, $e)
    if (([DateTime]::Now - $script:dblClickTime).TotalMilliseconds -lt 400) { $e.NewValue = $e.CurrentValue }
})
$list.Add_ColumnClick({
    param($s, $e)
    if ($script:sorter.Column -eq $e.Column) {
        $script:sorter.Ascending = -not $script:sorter.Ascending
    } else {
        $script:sorter.Column = $e.Column
        # Size and date start descending, names start ascending
        $script:sorter.Ascending = ($e.Column -lt 2)
    }
    $list.ListViewItemSorter = $script:sorter
    $list.Sort()
})
$btnAuto.Add_Click({ Set-AutoMark })
$btnAll.Add_Click({ Set-AllMark })
$btnClear.Add_Click({ foreach ($it in $list.Items) { $it.Checked = $false } })
$btnDelete.Add_Click({ Remove-Checked })
$btnSave.Add_Click({ Save-Report })
$btnMove.Add_Click({ Move-Checked })
$btnCache.Add_Click({ Clear-SimsCache })
$btnUpdate.Add_Click({
    # Scarlet's Mod List shows which mods are broken or updated after a patch
    $updMenu.Show($btnUpdate, (New-Object System.Drawing.Point(0, $btnUpdate.Height)))
})
$miSfw.Add_Click({
    Start-Process 'https://scarletsrealm.com/the-mod-list-sfw-only-edition/'
    $status.Text = T 'updateOpened'
})
$miNsfw.Add_Click({
    Start-Process 'https://scarletsrealm.com/the-mod-list-sfw-nsfw-edition/'
    $status.Text = T 'updateOpened'
})
$form.Add_Resize({ Update-TopLayout; Update-BottomLayout })
$form.Add_Shown({ Update-TopLayout; Update-BottomLayout })

$btnAuto.Enabled = $false
$btnMove.Enabled = $false
$cmbLang.SelectedIndex = [Array]::IndexOf($LangCodes, $script:curLang)   # also calls Apply-Language
[void]$form.ShowDialog()
