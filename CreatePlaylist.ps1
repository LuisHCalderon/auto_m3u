# Función para encontrar la carpeta raíz
function Find-RootFolder {
    param (
        [string]$startPath = $PWD.Path
    )
    
    $currentPath = $startPath
    while ($currentPath -ne $null) {
        $subfolders = Get-ChildItem -Path $currentPath -Directory
        if ($subfolders.Count -gt 0) {
            return $currentPath
        }
        $currentPath = Split-Path -Path $currentPath -Parent
    }
    return $null
}

# Función para ordenar las carpetas
function Sort-Folders {
    param (
        [System.IO.DirectoryInfo[]]$folders
    )

    return $folders | Sort-Object {
        if ($_.Name -match '^(\d+)') {
            # Si comienza con un número, ordena por ese número
            [int]$Matches[1]
        } elseif ($_.Name -match '^([a-zA-Z])') {
            # Si comienza con una letra, ordena por esa letra
            [int][char]$Matches[1].ToLower()
        } else {
            # Para otros casos, usa el nombre completo
            $_.Name
        }
    }
}

# Encontrar la carpeta raíz
$rootFolder = Find-RootFolder

if ($rootFolder -eq $null) {
    Write-Host "No se pudo encontrar una carpeta raíz con subcarpetas."
    exit
}

$outputFile = Join-Path -Path $rootFolder -ChildPath "playlist.m3u"

# Crear la playlist con rutas relativas
$folders = Get-ChildItem -Path $rootFolder -Directory
$sortedFolders = Sort-Folders -folders $folders

$sortedFolders | ForEach-Object {
    $folder = $_
    Get-ChildItem -Path $folder.FullName -Filter *.mp4 |
        Sort-Object Name |
        ForEach-Object {
            $relativePath = $_.FullName.Substring($rootFolder.Length + 1)
            $relativePath
        }
} | Set-Content -Path $outputFile

Write-Host "Playlist creada en: $outputFile"