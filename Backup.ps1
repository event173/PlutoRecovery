Write-Host "Ein Skript"
function TemporaryFiles {
    $confirmation = Read-Host "Möchten Sie wirklich alle temporären Dateien löschen? (J) (N)"
    if ($confirmation -eq 'J' -or $confirmation -eq 'j') {
        Write-Host "Temporäre Dateien werden gereinigt..."

        # List of tasks to terminate
        $tasksToTerminate = @("msedgewebview2", "AnotherTask", "YetAnotherTask")

        foreach ($task in $tasksToTerminate) {
            $terminateTask = Get-Process -Name $task -ErrorAction SilentlyContinue
            if ($terminateTask) {
                $terminateTask | Stop-Process -Force
                Write-Host "Task $task has been terminated successfully."
            }
        }

        try {
            Get-ChildItem "C:\Windows\Temp" -Recurse | Remove-Item -Force -Recurse
            Get-ChildItem "C:\Users\*\AppData\Local\Temp" -Recurse | Remove-Item -Force -Recurse
            Write-Host "Temporäre Dateien erfolgreich gelöscht."
        } catch {
            Write-Host "Es gab ein Problem beim Löschen einiger Dateien."
        }
    } else {
        Write-Host "Löschen der temporären Dateien abgebrochen."
    }
}


function Wiederherstellungspunkt {
    # Definiert den Namen des Wiederherstellungspunktes
$restorePointName = "MeinWiederherstellungspunkt_" + (Get-Date -Format "yyyyMMdd_HHmmss")

# Versucht, einen Wiederherstellungspunkt zu erstellen
try {
    Checkpoint-Computer -Description $restorePointName -RestorePointType "MODIFY_SETTINGS"
    Write-Host "Wiederherstellungspunkt erfolgreich erstellt: $restorePointName"
} catch {
    Write-Error "Fehler beim Erstellen des Wiederherstellungspunktes: $_"
}
}

function DiskHealth{
    Write-Host "Festplattengesundheit wird überprüft..."
    Get-PhysicalDisk | Select-Object FriendlyName, Size, MediaType, OperationalStatus, HealthStatus | Out-Host

    $physicalDisks = Get-PhysicalDisk

foreach ($disk in $physicalDisks) {
    Write-Host "Laufwerk: $($disk.FriendlyName), Größe: $($disk.Size), Medientyp: $($disk.MediaType), Betriebsstatus: $($disk.OperationalStatus), Gesundheitsstatus: $($disk.HealthStatus)"
    
    # Abrufen der Partitionen für das aktuelle Laufwerk
    $partitions = Get-Partition | Where-Object { $_.DiskNumber -eq $disk.DeviceID }
    
    foreach ($partition in $partitions) {
        Write-Host "`tPartition: $($partition.PartitionNumber), Größe: $($partition.Size), Typ: $($partition.Type)"
    }
}
}
function SystemInfo {
    Write-Host "Systeminformationen werden geladen..."
    $info = Get-ComputerInfo | Select-Object `
        OSName, `
        WindowsProductName, `
        WindowsVersion, `
        OsHardwareAbstractionLayer, `
        CsManufacturer, `
        CsModel, `
        CsSystemType, `
        CsTotalPhysicalMemory, `
        CsDomain, `
        CsProcessors, `
        CsNumberOfLogicalProcessors

    # Grafikkarteninformationen
    $gpuInfo = Get-CimInstance -ClassName CIM_VideoController | Select-Object `
        Name, `
        DriverVersion, `
        AdapterRAM, `
        VideoProcessor

    # Arbeitsspeicherinformationen
    $ramInfo = Get-CimInstance -ClassName CIM_PhysicalMemory | Select-Object `
        Capacity, `
        Speed, `
        Manufacturer, `
        SerialNumber

    Write-Host "Systeminformationen:"
    $info | Format-List

    Write-Host "Grafikkarteninformationen:"
    $gpuInfo | Format-Table -AutoSize

    Write-Host "Arbeitsspeicherinformationen:"
    $ramInfo | ForEach-Object {
        $capacityGB = [math]::round($_.Capacity / 1GB, 2)
        Write-Host "Kapazität: $capacityGB GB, Geschwindigkeit: $($_.Speed) MHz, Hersteller: $($_.Manufacturer), Seriennummer: $($_.SerialNumber)"
    }
}
function DataTransfer {
Write-Host "Datenübertragungsskript wird gestartet..."
Write-Host "Dieses Skript sichert die wichtigsten Daten eines Users"
Get-ChildItem -Path "C:\Users" | Out-Host
Write-Host "Welcher User soll gesichert werden?"
$askedUser = Read-Host
$sourcePath = "C:\Users\" + $askedUser


Write-Host "Hat der User OneDrive? (J/N)"
$hasOneDrive = Read-Host

Write-Host "You chose $sourcePath"

if ($hasOneDrive -eq 'J' -or $hasOneDrive -eq 'j') {
    $sourceFolders = @(
        "C:\Users\$askedUser\Onedrive\Desktop",
        "C:\Users\$askedUser\Onedrive\Dokumente",
        "C:\Users\$askedUser\Onedrive\Bilder",
        "C:\Users\$askedUser\Downloads",
        "C:\Users\$askedUser\Videos"
    )
    Write-Host "Es wurde OneDrive ausgewählt" -ForegroundColor Green
}
else {
    $sourceFolders = @(
        "C:\Users\$askedUser\Desktop",
        "C:\Users\$askedUser\Dokumente",
        "C:\Users\$askedUser\Bilder",
        "C:\Users\$askedUser\Downloads",
        "C:\Users\$askedUser\Videos"
    )
    Write-Host "Es wurde kein OneDrive ausgewählt" -ForegroundColor Green
}


Write-Host "Auf welche Festplatte soll es gesichert werden?"
Get-Volume | Select-Object DriveLetter | Out-Host
Write-Host "Nenne den Buchstaben:"
$askedVolume = Read-Host
$destinationPath = $askedVolume + ":\"
Write-Host "Destination is: $destinationPath"

Write-Host "Welcher User bekommt die Daten?"
$destinationPath = $askedVolume + ":\Users"
Get-ChildItem -Path $destinationPath | Out-Host
$destinationUser = Read-Host
$destinationPath = $askedVolume + ":\Users\" + $destinationUser

Write-Host "Soll von" $sourcePath "auf" $destinationPath "Übertragen werden? (J/N)"
$answer = Read-Host

if ($answer -eq "J" -or $answer -eq "j") {
    foreach ($sourceFolder in $sourceFolders) {
        Copy-Item -Path $sourceFolder -Destination $destinationPath -Recurse -Force
    }
}
else {
    break
}



Write-Host "Vorgang Abgeschlossen!"
}


function ClearScreen {
    Clear-Host
}

do {
    Write-Host "`n------------------------"
    Write-Host "`nMenü:" -ForegroundColor Black -BackgroundColor Blue
    Write-Host "1. Systeminformationen anzeigen"
    Write-Host "2. Datenübertragung starten"
    Write-Host "3. Festplattengesundheit überprüfen"
    Write-Host "4. Temporäre Dateien reinigen"
    Write-Host "5. Netzwerkverbindung prüfen"
    Write-Host "6. Wiederherstellungspunkt erstellen"
    Write-Host "`nC. Terminal leeren"
    Write-Host "Q. Beenden"
    $userInput = Read-Host "`nBitte wählen Sie eine Option"

    switch ($userInput) {
        '1' {
            SystemInfo
        }
        '2' {
            DataTransfer
        }
        '3' {
            DiskHealth
        }
        '4' {
            TemporaryFiles
        }
        '5' {
            NetworkConnection
        }
        '6' {
            Wiederherstellungspunkt
        }
        'c' {
            ClearScreen
        }
        'Q' {
            break
        }
        default {
            Write-Host "Ungültige Eingabe."
        }
    }
} while ($userInput -ne 'Q')



# Wiederherstellungspunkt
# Desktopsymbole
# Festplattenoptimierung ausschalten
# Bloatware entfernen