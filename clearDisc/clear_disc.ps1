Function DeleteUser{
    param (
        $ParamUserName
    )

    Write-Host "Removing user $ParamUserName..."

    Get-CimInstance -ClassName Win32_UserProfile |
    Where-Object { $_.LocalPath.EndsWith($ParamUserName) } |
    Remove-CimInstance

    Write-Host "User $ParamUserName removed..." -ForegroundColor Green 
}

$CurrentUser = Read-Host "What the login name of the actual user?"

#Declaring paths to the folders based on the user informed
$UserTemp = "C:\Users\$CurrentUser\AppData\Local\Temp"
$LocalAppDataPath = "C:\Users\$CurrentUser\AppData\Local"
$AppDataPath = "C:\Users\$CurrentUser\AppData\Roaming"

$Now = (Get-Date).Date

Write-Host "Starting the Clear Disc script..." -ForegroundColor Blue
Start-Sleep -Seconds 1

#Temp Folders Session
Write-Host "Startin the temp files clear." -ForegroundColor Yellow
Start-Sleep -Seconds 1

#Start cleaning the Temp folders
#On the Local folder
IF(Test-Path -Path $UserTemp){
    try{
        Get-ChildItem -Path $UserTemp | Where-Object { ($_.LastWriteTime).Date -lt $Now } | Remove-Item -Recurse -Force -Confirm:$false
        Write-Host "Directory $($UserTemp) cleared" -ForegroundColor Green
    } catch {
        Write-Host $_
    }
} ELSE {
    Write-Host "Directory $($UserTemp) not found, please look again the login informed on the start." -ForegroundColor Blue
}
Start-Sleep -Seconds 2

#On the C: Drive
IF(Test-Path -Path "C:\Temp"){
    try {
        Get-ChildItem -Path "C:\temp" | Where-Object { ($_.LastWriteTime).Date -lt $Now } | Remove-Item -Recurse -Force -Confirm:$false
        Write-Host "Directory C:\temp cleared" -ForegroundColor Green
    } catch {
        Write-Host $_
    }
} else {
    Write-Host "Directory C:\temp or C:\Temp not found, proceeding with the clear process." -ForegroundColor Blue
}
Start-Sleep -Seconds 2

#Google Chrome Session
Write-Host "Starting Google Chrome clear cache..." -ForegroundColor Blue
Start-Sleep -Seconds 2

#Search for Chrome process
if(Get-Process -ProcessName Chrome -ErrorAction SilentlyContinue){
        Write-Host "Stoping Google Chrome process." -ForegroundColor Yellow
        try{
            Get-Process -ProcessName Chrome | Stop-Process -Force
            Start-Sleep -Seconds 3
            Write-Host "Google Chrome process was killed." -ForegroundColor Green
        }catch{
            Write-Host $_
        }
    }
#Start clearing the Google Chrome folders and files cache
Write-Host "Realizing cache clear of the Google Chrome" -ForegroundColor Yellow
Start-Sleep -Seconds 2

try {
    #All folders path to remove of the Google Chrome Cache
    $ChromeFolders = @('\Google\Chrome\User Data\Default\Cache',
                       '\Google\Chrome\User Data\Default\Web Data')

    Foreach($folder IN $ChromeFolders){
        #Concat AppData variable with actual Folder on Foreach
        $FullPath = "$($LocalAppDataPath+$folder)"
        #If folder exists, remove her childs, else just proceed
        switch(Test-Path -LiteralPath "$FullPath"){
            True {
                Start-Sleep -Seconds 1
                Get-ChildItem -Path "$FullPath" | Remove-Item -Recurse -Confirm:$false;
                Write-Host "Directory $FullPath cleared." -ForegroundColor Green
            }
            False {
                Write-Host "Directory $FullPath not found, proceeding with the clear process." -ForegroundColor Blue
            }
        }
    }
    Start-Sleep -Seconds 2
    Write-Host "Google Chrome cache was cleared." -ForegroundColor Green
} catch {
    Write-Host $_
}

#Start Teams clear process
#If process exist, stop them
if(Get-Process -ProcessName Teams -ErrorAction SilentlyContinue){
    Write-Host "Stopping Microsoft Teams Process" -ForegroundColor Yellow
    
    try{
        Get-Process -ProcessName Teams | Stop-Process -Force
        Start-Sleep -Seconds 3
        Write-Host "Microsoft Teams process was killed." -ForegroundColor Green
    }catch{
        echo $_
    }
}
#Start clearing the Microsoft Teams folders and files cache
Write-Host "Clearing Microsoft Teams cache files" -ForegroundColor Yellow
try{
    #All folders path to remove of the Teams Cache
    $TeamsFolders = @('\Microsoft\teams\blob_storage',
                      '\Microsoft\teams\databases',
                      '\Microsoft\teams\cache',
                      '\Microsoft\teams\gpucache',
                      '\Microsoft\teams\Indexeddb',
                      '\Microsoft\teams\Local Storage',
                      '\Microsoft\teams\tmp',
                      '\Microsoft\teams\application cache\cache')
    
    Foreach($folder IN $TeamsFolders){
        #Concat AppData variable with actual Folder on Foreach
        $FullPath = "$($AppDataPath+$folder)"
        #If folder exists, remove her childs, else just proceed
        switch(Test-Path -LiteralPath "$FullPath"){
            True {
                Get-ChildItem -Path "$FullPath" | Remove-Item -Recurse -Confirm:$false;
                Write-Host "Directory $FullPath was cleared." -ForegroundColor Green

                Start-Sleep -Seconds 1
            }
            False {
                Write-Host "Directory $FullPath not found, proceeding with the clean process." -ForegroundColor Yellow

                Start-Sleep -Seconds 1
            }
        }
    }
    Write-Host "Microsoft Teams cache files was cleared." -ForegroundColor Green
}catch{
    echo $_
}

# Start delete users section
# Users that cannot be deleted
$UsersNotDelete = @("user1","user2","etc...");
$CurrentYear = (Get-Date).Year

# Get the folder of the users
$LookForUsers = 'Get-ChildItem -Path "C:\Users\"'

# Init the deletable users array, inserting his names after
$DeletableUsers = @()

# Insert the conditions on the search of the folders based on users that cannot be found and can't be modified on actual year
ForEach($User IN $UsersNotDelete){
    $LookForUsers += " | Where-Object { `$_.Name -ne `"$($User)`" -and (`$_.LastWriteTime).Year -lt $($CurrentYear)}"
}

# Invoke the search string maked before to take the users folders
$AvailUsersResults = Invoke-Expression $LookForUsers

# Insert the name of the users folders founded, on the array DeletableUsers
ForEach ($FolderUser IN $AvailUsersResults){
    $DeletableUsers += $FolderUser.Name
}

Write-Host "Users to delete:"

$Counter = 0
ForEach ($UserName IN $DeletableUsers){
    Write-Host "$Counter = $UserName"
    $Counter += 1
}

$DeleteChallenge = Read-Host "All users above have your folder at C:\Users with last modified date on the last year, you want delete them? (Y/N)"

SWITCH($DeleteChallenge){
    'Y' {
        ForEach($User IN $DeletableUsers){
            DeleteUser -ParamUserName $User
        }
            Break
    }
    'N' {
        $UnitDeleteOptionChallenge = Read-Host "You want to select wich users remove unitary? (Y/N)"
            Break
    }
    DEFAULT {
        Write-Host "Invalid Option!" -ForegroundColor Red
            Break
    }
}

$ValidsInputedIndexesArray = @()
$UsersCounter = 0

IF($UnitDeleteOptionChallenge -eq 'Y'){
    Write-Host ""
    $IndexesUsersToDelete = Read-Host "Put the number of the users to delete, separated by a comma without spaces (Ex.: num1,num2,...) "
    
    $InputedIndexesArray = $IndexesUsersToDelete -split (",")
    $InputedIndexesArray = $InputedIndexesArray | Sort-Object

    Write-Host "Selected users:"

    ForEach($IndexOnArray IN $InputedIndexesArray){
        IF($NULL -eq $($DeletableUsers[$IndexOnArray])){
            Write-Host "User on the index $IndexOnArray not found..." -ForegroundColor Yellow
        } ELSE {
            Write-Host "$IndexOnArray = $($DeletableUsers[$IndexOnArray])"
            $ValidsInputedIndexesArray += $IndexOnArray
            $UsersCounter += 1
        }
    }

    IF($ValidsInputedIndexesArray.count -eq 0){
        Write-Host "Any user selected, proceeding with the clear process..." -ForegroundColor Blue
    } ELSE{
        Write-Host ""
        Write-Host "Resume of the selected user:"

        ForEach ($ValidIndex IN $ValidsInputedIndexesArray){
            Write-Host "$ValidIndex = $($DeletableUsers[$ValidIndex])"
        }
        
        $ConfirmDeleteChallenge = Read-Host "A total of $($ValidsInputedIndexesArray.count) users are select, confirm the exclusion? (Y/N)"
    }
} ELSEIF ($UnitDeleteOptionChallenge -eq 'N'){
    Write-Host "Proceeding with the clear process..." -ForegroundColor Blue
} ELSEIF ($NULL -ne $UnitDeleteOptionChallenge) {
    Write-Host "Invalid Option!" -ForegroundColor Red
}

IF($ConfirmDeleteChallenge -eq 'Y'){
    ForEach($ValidIndex IN $ValidsInputedIndexesArray){
        DeleteUser -ParamUserName $($DeletableUsers[$ValidIndex])
    }
}

#Start Disk Cleaner
try{
    Start-Process "C:\windows\SYSTEM32\cleanmgr.exe"
} catch {
    Write-Host $_
}

Start-Sleep -Seconds 1
Write-Host "Waiting the Clean Disk Software process will be killed..." -ForegroundColor Yellow

Start-Sleep -Seconds 2
Wait-Process -Name cleanmgr

Write-Host "Clean Disk Software process has been killed." -ForegroundColor Green
Write-Host "Staring Disk Defragmenter..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

#Start Disk Defrag
try{
    defrag C: /U /D
} catch {
    Write-Host $_
}

Start-Sleep -Seconds 2

Wait-Process -Name defrag
Write-Host "Defragmentation has been terminated." -ForegroundColor Green

Write-Host "The clear process has been terminated! =]" -ForegroundColor Green
