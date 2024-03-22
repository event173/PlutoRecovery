
# -------------- Beginn Temporaere Dateien ------------------------------------------------------------
function TemporaryFiles {
    do{
        ClearScreen
        Write-Host "Temporaere Dateien entfernen" -ForegroundColor Yellow
        Write-Host "`n1. Reinigungsprofil anlegen"
        Write-Host "2. Reinigungsprofil ausfuehren"
        Write-Host "Q. Zum Hauptbildschirm zurueckkehren"
        $userInput = Read-Host "`nBitte waehle eine Option"
    
    switch($userInput) {
        '1' {
            CreateCleaningProfile
        } 
        '2' {
            RunCleaningProfile
        }	
    
    }

} while ($userInput -ne 'Q')
}

function CreateCleaningProfile {
    cleanmgr /sageset:1
}
function RunCleaningProfile {
    cleanmgr /sagerun:1
}

#---------------- Ende temporaere Dateien ------------------------------------------------------------




# Funktionen ------------------------------------------------------------
function Wiederherstellungspunkt {
    ClearScreen
    Write-Host "Wiederherstellungspunkt wird erstellt..."

    # Aktiviert die Systemwiederherstellung auf dem Laufwerk C:
    Enable-ComputerRestore -Drive "C:\"

    # Definiert den Namen des Wiederherstellungspunktes
    $restorePointName = "MeinWiederherstellungspunkt_" + (Get-Date -Format "yyyyMMdd_HHmmss")

    # Versucht, einen Wiederherstellungspunkt zu erstellen
try {
    Checkpoint-Computer -Description $restorePointName -RestorePointType "MODIFY_SETTINGS"
    Write-Host "Wiederherstellungspunkt erfolgreich erstellt: $restorePointName"
} catch {
    Write-Error "Fehler beim Erstellen des Wiederherstellungspunktes: $_"   # $_ ist die Fehlermeldung
}
    Read-Host "Druecke Enter..."
}

function DiskHealth{
    ClearScreen
    Write-Host "Festplattengesundheit wird ueberprueft..."

    # Festplatteninformationen abrufen: FriendlyName ist der Name des Laufwerks
    #Size ist die Groesse, MediaType ist der Medientyp, OperationalStatus ist der Betriebsstatus und HealthStatus ist der Gesundheitsstatus
    Get-PhysicalDisk | Select-Object FriendlyName, Size, MediaType, OperationalStatus, HealthStatus | Out-Host

    # Alle physischen Festplatten abrufen und chkdsk ausfuehren
    $physicalDisks = Get-PhysicalDisk
    chkdsk /f /r

    # Informationen zu den einzelnen Festplatten und Partitionen ausgeben
    foreach ($disk in $physicalDisks) {
        Write-Host "Laufwerk: $($disk.FriendlyName), Size: $($disk.Size), Medientyp: $($disk.MediaType), Betriebsstatus: $($disk.OperationalStatus), Gesundheitsstatus: $($disk.HealthStatus)"
    
    # Abrufen der Partitionen fuer das aktuelle Laufwerk
    $partitions = Get-Partition | Where-Object { $_.DiskNumber -eq $disk.DeviceID }
    
    foreach ($partition in $partitions) {
        Write-Host "`tPartition: $($partition.PartitionNumber), Gr??e: $($partition.Size), Typ: $($partition.Type)"
    }

}
        Read-Host "Druecke Enter..."
}


function SystemInfo {
    ClearScreen
    Write-Host "Systeminformationen werden geladen..."

    # Systeminformationen abrufen
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

    # Grafikkarteninformationen abrufen
    $gpuInfo = Get-CimInstance -ClassName CIM_VideoController | Select-Object `
        Name, `
        DriverVersion, `
        AdapterRAM, `
        VideoProcessor

    # Arbeitsspeicherinformationen abrufen
    $ramInfo = Get-CimInstance -ClassName CIM_PhysicalMemory | Select-Object `
        Capacity, `
        Speed, `
        Manufacturer, `
        SerialNumber

    # Ausgabe der Informationen ------------------------------------------------------------
    Write-Host "Systeminformationen:"
    $info | Format-List

    Write-Host "Grafikkarteninformationen:"
    $gpuInfo | Format-Table -AutoSize

    Write-Host "Arbeitsspeicherinformationen:" -ForegroundColor Green
    $ramInfo | ForEach-Object {
        $capacityGB = [math]::round($_.Capacity / 1GB, 2)
        Write-Host "Kapazitaet: $capacityGB GB, Geschwindigkeit: $($_.Speed) MHz, Hersteller: $($_.Manufacturer), Seriennummer: $($_.SerialNumber)"
    }
    playSound
    Read-Host "Druecke Enter..."
}

function DataTransfer {
    ClearScreen
    Write-Host "Datenuebertragungsskript wird gestartet..."
    Write-Host "Dieses Skript sichert die wichtigsten Daten eines Users"


    Write-Host "Von welcher Festplatte soll uebertragen werden?"
    # Alle Laufwerke auflisten ------------------------------------------------------------
    Get-Volume | Select-Object DriveLetter | Out-Host
    Write-Host "Nenne den Buchstaben:"
    $askedVolume = Read-Host
    $sourcePath = $askedVolume + ":\Users\" # Pfad zu den Usern auf der Festplatte hinzufuegen

    # Alle User auflisten ------------------------------------------------------------
    Get-ChildItem -Path $sourcePath | Out-Host
    Write-Host "Welcher User soll gesichert werden?"
    $askedUser = Read-Host
    $sourcePath = $sourcePath + $askedUser

    # Pruefen, ob der User OneDrive hat ------------------------------------------------------------
    Write-Host "Hat der User OneDrive? (J/N)"
    $hasOneDrive = Read-Host



    Write-Host "You chose $sourcePath"  # bsp.: C:\Users\User

    # Pfade zu den zu sichernden Ordnern ------------------------------------------------------------
    if ($hasOneDrive -eq 'J' -or $hasOneDrive -eq 'j') {
        $sourceFolders = @(
            $sourcePath +"\Onedrive\Desktop";
            $sourcePath +"\Onedrive\Dokumente";
            $sourcePath +"\Onedrive\Bilder";
            $sourcePath +"\Downloads";
            $sourcePath +"\Contacts";
            $sourcePath +"\Favorites";
            $sourcePath +"\Links";
            $sourcePath +"\Saved Games";
            $sourcePath +"\Searches";
            $sourcePath +"\Music";
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
            $sourcePath +"\Documents";
            $sourcePath +"\Pictures";
            $sourcePath +"\Downloads";
            $sourcePath +"\Contacts";
            $sourcePath +"\Favorites";
            $sourcePath +"\Links";
            $sourcePath +"\Saved Games";
            $sourcePath +"\Searches";
            $sourcePath +"\Music";
            $sourcePath +"\Videos"
        )
        Write-Host "Es wurde kein OneDrive ausgewaehlt" -ForegroundColor Yellow
        Write-Host "Folgende Ordner werden gesichert:"
        foreach ($folder in $sourceFolders) {
            Write-Host $folder
        }
    }

    # Zielordner festlegen ------------------------------------------------------------
    Write-Host "Auf welche Festplatte soll es gesichert werden?"
    Get-Volume | Select-Object DriveLetter | Out-Host
    Write-Host "Nenne den Buchstaben:"
    $askedVolume = Read-Host
    $destinationPath = $askedVolume + ":\"
    Write-Host "Destination is: $destinationPath"

    # Zieluser festlegen ------------------------------------------------------------
    Write-Host "Welcher User bekommt die Daten?"
    $destinationPath = $askedVolume + ":\Users\"
    Get-ChildItem -Path $destinationPath | Out-Host
    $destinationUser = Read-Host
    $destinationPath = $askedVolume + ":\Users\" + $destinationUser

    # Bestaetigung ------------------------------------------------------------
    Write-Host "Soll von" $sourcePath "auf" $destinationPath "Uebertragen werden? (J/N)"
    $answer = Read-Host

    # Datenuebertragung ------------------------------------------------------------
    if ($answer -eq "J" -or $answer -eq "j") {
        foreach ($sourceFolder in $sourceFolders) {
            try {
                Write-Host "Kopiere $sourceFolder nach $destinationPath"
                Copy-Item -Path $sourceFolder -Destination $destinationPath -Recurse -Force -ErrorAction Stop
            }
            catch {
                Write-Output "Fehler beim Kopieren des Ordners '$sourceFolder': $($_.Exception.Message)"
            }
        }
    }
    else {
        break
    }


    Write-Host "Vorgang Abgeschlossen!"
    playSound
    Read-Host "Druecke Enter..."
}


function ClearScreen { # Funktion zum Loeschen des Bildschirms
    Clear-Host
}

function playSound {    # Funktion zum Abspielen eines Sounds
    [Console]::Beep(293, 125) # D4
    [Console]::Beep(293, 125) # D4
    [Console]::Beep(587, 300) # D5
    [Console]::Beep(440, 400) # A4
    [Console]::Beep(415, 250) # G#4
    [Console]::Beep(392, 250) # G4
    [Console]::Beep(349, 250) # F4
    [Console]::Beep(293, 150) # D4
    [Console]::Beep(349, 150) # F4
    [Console]::Beep(392, 200) # G4
}
function systemIntegrity { # Funktion zur Ueberpruefung der Systemintegritaet
    ClearScreen
    Write-Host "Integritaet der Systemdateien wird ueberprueft..."
    sfc /scannow
    Read-Host "Druecke Enter..."
}


function DISMCheck {    
    ClearScreen
    # ueberpruefen des Systemabbilds
    $checkHealthResult = & DISM /Online /Cleanup-Image /CheckHealth
    DISM /Online /Cleanup-Image /ScanHealth
    # Wenn der CheckHealth-Befehl eine Beschaedigung gefunden hat, fuehrt es den RestoreHealth-Befehl aus
    if ($checkHealthResult -like '*Der Komponentenspeicher ist reparierbar*') {
        & DISM /Online /Cleanup-Image /RestoreHealth
    }
    playSound
    Read-Host "Druecke Enter..."
}


function RAMTest {
    mdsched.exe
}

function RAMResult {
    ClearScreen
    Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-MemoryDiagnostics-Results'} | Select-Object -Property LevelDisplayName, Id, TimeCreated, Message, TaskDisplayName  | Format-List
    Read-Host "Druecke Enter..."
}

function Zusammenfassung {


# Pfad zur Ausgabedatei festlegen
$outputPath = "C:\SystemZusammenfassung.txt"

# Systeminformationen sammeln
$systemInfo = Get-ComputerInfo | Select-Object CsManufacturer, CsModel, WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer

# Installierte Software auflisten
$installedSoftware = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher | Where-Object {$_.DisplayName -ne $null}

# Netzwerkinformationen sammeln
$networkInfo = Get-NetIPConfiguration | Select-Object InterfaceAlias, InterfaceDescription, IPv4Address

# Sicherheitseinstellungen prüfen
# Beispiel: Windows Defender Status
$defenderStatus = Get-Service -Name WinDefend | Select-Object Status



$antivirusStatus = Get-MpComputerStatus | Select-Object AMProductVersion, AMServiceEnabled, NISEnabled, OnAccessProtectionEnabled
$ramergebnis = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-MemoryDiagnostics-Results'} | Select-Object -Property LevelDisplayName, Id, TimeCreated, Message, TaskDisplayName  | Format-List

$cpuInfo = Get-WmiObject -Class Win32_Processor | Select-Object Name, Manufacturer, Description, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
$ramInfo = Get-WmiObject -Class Win32_PhysicalMemory | Select-Object Manufacturer, Capacity, Speed, DeviceLocator, SerialNumber | Measure-Object -Property Capacity -Sum
$totalRAM = $ramInfo.Sum / 1GB
$moboInfo = Get-WmiObject -Class Win32_BaseBoard | Select-Object Manufacturer, Product, SerialNumber
$biosInfo = Get-WmiObject -Class Win32_BIOS | Select-Object Manufacturer, SMBIOSBIOSVersion, ReleaseDate, SerialNumber
$diskInfo = Get-WmiObject -Class Win32_DiskDrive | Select-Object Model, InterfaceType, MediaType, Size | ForEach-Object {
    $_ | Add-Member -NotePropertyName "SizeGB" -NotePropertyValue ([math]::round($_.Size / 1GB, 2)) -PassThru
}
$gpuInfo = Get-WmiObject -Class Win32_VideoController | Select-Object Name, Description, AdapterRAM, DriverVersion | ForEach-Object {
    $_ | Add-Member -NotePropertyName "AdapterRAMGB" -NotePropertyValue ([math]::round($_.AdapterRAM / 1GB, 2)) -PassThru
}
$networkAdapterInfo = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object { $_.NetEnabled -eq $true } | Select-Object Name, NetConnectionID, Speed




# Ausgabe vorbereiten
$report = @"
SYSTEM-BERICHT
--------------------

Systeminformationen:
--------------------
Hersteller: $($systemInfo.CsManufacturer)
Modell: $($systemInfo.CsModel)
Produktname: $($systemInfo.WindowsProductName)
Windows-Version: $($systemInfo.WindowsVersion)
HAL-Version: $($systemInfo.OsHardwareAbstractionLayer)

Hardware-Informationen:
--------------------
Prozessorinformationen
$($cpuInfo | Format-List | Out-String)

Speicher (RAM) Informationen: Gesamt RAM: $($totalRAM) GB
$($ramInfo | Format-List | Out-String)

Motherboard und BIOS-Informationen:
$($moboInfo | Format-List | Out-String)
$($biosInfo | Format-List | Out-String)

Festplatten-Informationen:
$($diskInfo | Format-List | Out-String)

Grafikkarten-Informationen:
$($gpuInfo | Format-List | Out-String)

Netzwerkkarten-Informationen:
$($networkAdapterInfo | Format-List | Out-String)
--------------------

RAM-Testergebnisse:
$($ramergebnis | Out-String)
--------------------
Sicherheitseinstellungen:
Windows Defender Status: $($defenderStatus.Status)
Antivirus-Status: $antivirusStatus



"@

$report | Out-File -FilePath $outputPath
Invoke-Item $outputPath

}


function Win11 {
    ClearScreen
    Write-Host "Windows 11 Upgrade wird gestartet..."
    Get-Volume | Select-Object DriveLetter | Out-Host
    $usbBuchstabe = Read-Host "Bitte geben Sie den Buchstaben des USB-Sticks ein"
    $usbPfad = $usbBuchstabe + ":\Windows11"
    Write-Host "Lade Daten..."
    Copy-Item -Path $usbPfad -Destination "C:\" -Recurse -Force -ErrorAction Stop

    Start-Process -FilePath "C:\Windows11\setup.exe" -ArgumentList "/product server"
}

function Win11info {
    ClearScreen
    Write-Host "Windows 11 Upgrade Information" -ForegroundColor Yellow
    Write-Host "`nUm PlutoRecovery zum Upgraden auf Windows 11 zu verwenden, lege`ndas Programm auf einen USB-Stick in das Rootverzeichnis."
    Write-Host "`nNun lege einen Ordner namens 'Windows11' auf den USB-Stick an."
    Write-Host "`nLade die aktuelle Windows-ISO unter https://www.microsoft.com/de-de/software-download/windows11 herunter."
    Write-Host "`nÖffne die ISO und kopiere alle Dateien in den Ordner 'Windows11' auf dem USB-Stick."
    Write-Host "`nNun kannst du den USB-Stick in den PC stecken und das Programm als Administrator starten."
    Write-Host "Das Upgrade funktioniert nun ueber den Menuepunkt 'U'"
    Write-Host "`nHinweis:" -ForegroundColor Yellow
    Write-Host "Das programm wird anzeigen, dass es sich um ein Upgrade vom Windows Server handelt, dies`nist normal und kann ignoriert werden."
    Write-Host "Es wird Home oder Pro installiert, je nachdem, welche Version du vorher hattest."
    Write-Host "`nEs wird empfohlen, vor dem Upgrade ein Backup zu erstellen."
    Read-Host "`nDruecke Enter..."
}
function tempinfo {
    ClearScreen
    Write-Host "Nicht alle Temporaeren Dateien konnten geloescht werden" -ForegroundColor Yellow
    Write-Host "`n Das ist Normal, keine Sorge."
    Write-Host "Grund dafuer ist, dass einige Dateien von Programmen verwendet werden und nicht geloescht werden koennen."
    Write-Host "PlutoRecovery bemueht sich, so viele Dateien wie moeglich zu loeschen, in dem es Programme beendet, die diese Dateien verwenden."
    Write-Host "Es gibt aber auch Dateien, die von Windows verwendet werden und nicht geloescht werden koennen."
    Read-Host "`nDruecke Enter..."
}
function Information {
    do{
        ClearScreen
        Write-Host "Wie kann ich dir helfen?" -ForegroundColor Yellow
        Write-Host "`n1. Wie kann ich mein System auf Win 11 Upgraden?"
        Write-Host "2. Es konnten nicht alle Temporaeren Dateien geloescht werden"
        Write-Host "Q. Zum Hauptbildschirm zurueckkehren"
        $userInput = Read-Host "`nBitte waehle eine Option"
    

    switch($userInput) {
        '1' {
            Win11info
        } 
        '2' {
            tempinfo
        }	
    
    }

} while ($userInput -ne 'Q')
}


# Hauptmenue ------------------------------------------------------------
do {
    ClearScreen
    Write-Host "
    
    |\_/|                  
    | @ @   Woof! 
    |   <>              _       PlutoRecovery
    |  _/\------____ ((| |))    Made by Nick
    |               `--' |   
____|_       ___|   |___.' 
/_/_____/____/_______|
    " -ForegroundColor Yellow
    Write-Host "`nMenu:" -BackgroundColor black -ForegroundColor Yellow
    Write-Host "1. Systeminformationen anzeigen"

    Write-Host "`nSystemwartung" -BackgroundColor black -ForegroundColor Yellow
    Write-Host "2. Datenuebertragung starten"
    Write-Host "3. Temporaere Dateien reinigen"
    Write-Host "4. Wiederherstellungspunkt erstellen"

    Write-Host "`nSystemchecks" -BackgroundColor black -ForegroundColor Yellow
    Write-Host "`5. Festplattengesundheit ueberpruefen"
    Write-Host "6. Integritaet der Systemdateien ueberpruefen"
    Write-Host "7. Systemabbild ueberpruefen und reparieren"

    Write-Host "`nArbeitsspeicher" -BackgroundColor black -ForegroundColor Yellow
    Write-Host "8. RAM Testen"
    Write-Host "9. RAM Testergebnisse anzeigen"
    Write-Host "`n-------------------"
    Write-Host "`n0. Systemzusammenfassung erstellen" -ForegroundColor Green

    Write-Host "`nU. Windows 11 Upgrade auf nicht kompatibler Hardware starten" -ForegroundColor Cyan

    Write-Host "`ni. Information" -ForegroundColor Yellow

    Write-Host "`nC. Terminal leeren" -ForegroundColor Yellow
    Write-Host "`nQ. Beenden" -ForegroundColor Red
    $userInput = Read-Host "`nBitte waehlen Sie eine Option"

# Menueauswahl ------------------------------------------------------------
    switch ($userInput) {
        '1' {
            SystemInfo
        }
        '2' {
            DataTransfer
        }
        '3' {
            TemporaryFiles
        }
        '4' {
            DiskHealth
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
        '8' {
            RAMTest
        }
        '9' {
            RAMResult
        }
        '0' {
            Zusammenfassung
        }
        'u' {
            Win11
        }
        'i' {
            Information
        }
        'c' {
            ClearScreen
        }
        'q' {
            break
        }
        default {
            Write-Host "Ungueltige Eingabe."
        }
    }
} while ($userInput -ne 'Q')