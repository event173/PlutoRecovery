
#Script itself
function TemporaryFiles {
    $confirmation = Read-Host "Moechten Sie wirklich alle temporaeren Dateien loeschen? (J) (N)"
    if ($confirmation -eq 'J' -or $confirmation -eq 'j') {
        Write-Host "Temporaere Dateien werden gereinigt..."

        # List of tasks to terminate
        $tasksToTerminate = @("msedgewebview2", "Creative Cloud", "msedge", "CoreSync", "OfficeClickToRun", "steam", "steamwebhelper", "steamservice", "Discord", "Spotify")

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
            Write-Host "Temporaere Dateien erfolgreich geloescht."
        } catch {
            Write-Host "Es gab ein Problem beim Loeschen einiger Dateien."
        }
    } else {
        Write-Host "Loeschen der temporaeren Dateien abgebrochen."
    }
}


function Wiederherstellungspunkt {

Enable-ComputerRestore -Drive "C:\"
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
    Write-Host "Festplattengesundheit wird ueberprueft..."
    Get-PhysicalDisk | Select-Object FriendlyName, Size, MediaType, OperationalStatus, HealthStatus | Out-Host

    $physicalDisks = Get-PhysicalDisk
    chkdsk /f /r

foreach ($disk in $physicalDisks) {
    Write-Host "Laufwerk: $($disk.FriendlyName), Size: $($disk.Size), Medientyp: $($disk.MediaType), Betriebsstatus: $($disk.OperationalStatus), Gesundheitsstatus: $($disk.HealthStatus)"
    
    # Abrufen der Partitionen f?r das aktuelle Laufwerk
    $partitions = Get-Partition | Where-Object { $_.DiskNumber -eq $disk.DeviceID }
    
    foreach ($partition in $partitions) {
        Write-Host "`tPartition: $($partition.PartitionNumber), Gr??e: $($partition.Size), Typ: $($partition.Type)"
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
        Write-Host "Kapazit?t: $capacityGB GB, Geschwindigkeit: $($_.Speed) MHz, Hersteller: $($_.Manufacturer), Seriennummer: $($_.SerialNumber)"
    }
}
function DataTransfer {
Write-Host "Datenuebertragungsskript wird gestartet..."
Write-Host "Dieses Skript sichert die wichtigsten Daten eines Users"

Write-Host "Von welcher Festplatte soll uebertragen werden?"
Get-Volume | Select-Object DriveLetter | Out-Host
Write-Host "Nenne den Buchstaben:"
$askedVolume = Read-Host
$sourcePath = $askedVolume + ":\Users\"

Get-ChildItem -Path $sourcePath | Out-Host
Write-Host "Welcher User soll gesichert werden?"
$askedUser = Read-Host
$sourcePath = $sourcePath + $askedUser


Write-Host "Hat der User OneDrive? (J/N)"
$hasOneDrive = Read-Host


Write-Host "You chose $sourcePath"

if ($hasOneDrive -eq 'J' -or $hasOneDrive -eq 'j') {
    $sourceFolders = @(
        $sourcePath +"\Onedrive\Desktop";
        $sourcePath +"\Onedrive\Dokumente";
        $sourcePath +"\Onedrive\Bilder";
        $sourcePath +"\Downloads";
        $sourcePath +"\Videos"
    )
    Write-Host "Es wurde OneDrive ausgewaehlt" -ForegroundColor Yellow
    Write-Host "Folgende Ordner werden gesichert:"
    foreach ($folder in $sourceFolders) {
        Write-Host $folder
    }
}
else {
    $sourceFolders = @(
        $sourcePath +"\Desktop";
        $sourcePath +"\Dokumente";
        $sourcePath +"\Bilder";
        $sourcePath +"\Downloads";
        $sourcePath +"\Videos"
    )
    Write-Host "Es wurde kein OneDrive ausgewaehlt" -ForegroundColor Yellow
    Write-Host "Folgende Ordner werden gesichert:"
    foreach ($folder in $sourceFolders) {
        Write-Host $folder
    }
}


Write-Host "Auf welche Festplatte soll es gesichert werden?"
Get-Volume | Select-Object DriveLetter | Out-Host
Write-Host "Nenne den Buchstaben:"
$askedVolume = Read-Host
$destinationPath = $askedVolume + ":\"
Write-Host "Destination is: $destinationPath"

Write-Host "Welcher User bekommt die Daten?"
$destinationPath = $askedVolume + ":\Users\"
Get-ChildItem -Path $destinationPath | Out-Host
$destinationUser = Read-Host
$destinationPath = $askedVolume + ":\Users\" + $destinationUser

Write-Host "Soll von" $sourcePath "auf" $destinationPath "Uebertragen werden? (J/N)"
$answer = Read-Host

if ($answer -eq "J" -or $answer -eq "j") {
    foreach ($sourceFolder in $sourceFolders) {
        Write-Host "Kopiere $sourceFolder nach $destinationPath"
        Copy-Item -Path $sourceFolder -Destination $destinationPath -Recurse -Force
    }
}
else {
    break
}


Write-Host "Vorgang Abgeschlossen!"
playSound
}


function ClearScreen {
    Clear-Host
}

function playSound {
    [Console]::Beep(658, 125)
    [Console]::Beep(1320, 500)
    [Console]::Beep(990, 250)
    [Console]::Beep(1056, 250)
    [Console]::Beep(1188, 250)
    [Console]::Beep(1320, 125)
    [Console]::Beep(1188, 125)
    [Console]::Beep(1056, 250)
    [Console]::Beep(990, 250)
    [Console]::Beep(880, 500)
    [Console]::Beep(880, 250)
    [Console]::Beep(1056, 250)
    [Console]::Beep(1320, 500)
    [Console]::Beep(1188, 250)
    [Console]::Beep(1056, 250)
    [Console]::Beep(990, 750)
    [Console]::Beep(1056, 250)
    [Console]::Beep(1188, 500)
    [Console]::Beep(1320, 500)
    [Console]::Beep(1056, 500)
    [Console]::Beep(880, 500)
    [Console]::Beep(880, 500)
}
function systemIntegrity {
    Write-Host "Integritaet der Systemdateien wird ueberprueft..."
    sfc /scannow
    playSound
}

function DISMCheck {
    # ?berpr?fen Sie die Gesundheit des Systemabbilds
    $checkHealthResult = & DISM /Online /Cleanup-Image /CheckHealth
    DISM /Online /Cleanup-Image /ScanHealth
    # Wenn der CheckHealth-Befehl eine Besch?digung gefunden hat, f?hren Sie den RestoreHealth-Befehl aus
    if ($checkHealthResult -like '*Die Komponentenspeicher ist reparierbar*') {
        & DISM /Online /Cleanup-Image /RestoreHealth
    }
}
do {
    Write-Host "
    
    &&&                
&    &&&               
&&&&&&&&               
 &&&&&&&&              
      &&&&&            
        &&&&&                   PlutoRecovery
          &&&&&                 Made by Nick
            &&&&&      
              &&&&&&&& 
               &&&&&&&&
               &&&    &
                &&&    
    " -ForegroundColor Yellow
    Write-Host "`nMenu:" -ForegroundColor Blue
    Write-Host "1. Systeminformationen anzeigen"
    Write-Host "2. Datenuebertragung starten"
    Write-Host "3. Festplattengesundheit ueberpruefen"
    Write-Host "4. Temporaere Dateien reinigen"
    Write-Host "5. Wiederherstellungspunkt erstellen"
    Write-Host "6. Integritaet der Systemdateien ueberpruefen"
    Write-Host "7. Systemabbild ueberpruefen und reparieren"
    Write-Host "`nC. Terminal leeren"
    Write-Host "Q. Beenden"
    $userInput = Read-Host "`nBitte waehlen Sie eine Option"


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
            Wiederherstellungspunkt
        }
        '6' {
            SystemIntegrity
        }
        '7' {
            DISMCHeck
        }
        'c' {
            ClearScreen
        }
        'Q' {
            break
        }
        default {
            Write-Host "Ungueltige Eingabe."
        }
    }
} while ($userInput -ne 'Q')



# Wiederherstellungspunkt
# Desktopsymbole
# Festplattenoptimierung ausschalten
# Bloatware entfernen