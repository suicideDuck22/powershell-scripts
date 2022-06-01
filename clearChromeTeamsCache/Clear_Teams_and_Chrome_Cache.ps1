#Set AppData path env into a variable to use later
$LocalAppDataPath = $env:LOCALAPPDATA
$AppDataPath = $env:APPDATA

#Start the question to the user
$challenge = Read-Host "Clear Microsoft Teams and Chrome Cache? (Y/N)?"
$challenge = $challenge.ToUpper()
if ($challenge -eq "N"){
    Stop-Process -Id $PID
}elseif ($challenge -eq "Y"){
    #Start Teams clear process
    #If process exist, stop them
    if(Get-Process -ProcessName Teams -ErrorAction SilentlyContinue){
        Write-Host "Stopping Teams Process" -ForegroundColor Yellow

        try{
            Get-Process -ProcessName Teams | Stop-Process -Force
            Start-Sleep -Seconds 3
            Write-Host "Teams Process Sucessfully Stopped" -ForegroundColor Green
        }catch{
            echo $_
        }
    }
    #Start clearing the Microsoft Teams folders and files cache
    Write-Host "Clearing Teams cache files" -ForegroundColor Yellow
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
                    Write-Host "Folder $FullPath cleared." -ForegroundColor Green
                }
                False {
                    Write-Host "Path $FullPath not found, proceeding with the clean process." -ForegroundColor Yellow
                }
            }
        }
        Write-Host "Teams Cache files cleared" -ForegroundColor Green
    }catch{
        echo $_
    }
    #Start Google Chrome clear process
    #If process exist, stop them
    if(Get-Process -ProcessName Chrome -ErrorAction SilentlyContinue){
        Write-Host "Stopping Chrome Process" -ForegroundColor Yellow
        try{
            Get-Process -ProcessName Chrome| Stop-Process -Force
            Start-Sleep -Seconds 3
            Write-Host "Chrome Process Sucessfully Stopped" -ForegroundColor Green
        }catch{
            echo $_
        }
    }
    #Start clearing the Google Chrome folders and files cache
    Write-Host "Clearing Chrome Cache" -ForegroundColor Yellow
    try{
        #All folders path to remove of the Google Chrome Cache
        $ChromeFolders = @('\Google\Chrome\User Data\Default\Cache',
                           '\Google\Chrome\User Data\Default\Web Data')

        Foreach($folder IN $ChromeFolders){
            #Concat AppData variable with actual Folder on Foreach
            $FullPath = "$($LocalAppDataPath+$folder)"
            #If folder exists, remove her childs, else just proceed
            switch(Test-Path -LiteralPath "$FullPath"){
                True {
                    Get-ChildItem -Path "$FullPath" | Remove-Item -Recurse -Confirm:$false;
                    Write-Host "Folder $FullPath cleared." -ForegroundColor Green
                }
                False {
                    Write-Host "Path $FullPath not found, continuing the clean process." -ForegroundColor Yellow
                }
            }
        }
        Write-Host "Google Chrome cache cleared" -ForegroundColor Green
    }catch{
        echo $_
    }
}
