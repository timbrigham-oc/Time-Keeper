# This is a burnt toast notification script. 

# First see if there is a "Time Keeper" scheduled task configured. 
# If not, create one.


$Activated = {
    if ($Event.SourceArgs[1].Arguments -eq 'dismiss') {
        Write-Host "Toast was dismissed"
        $lockFile = Join-Path -Path $env:OneDrive -ChildPath "TimeLog-Output.lock"
        New-Item -Path $lockFile -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null
        continue 
    }
    #write-host "Activated"
    Write-host $Event.SourceArgs[1].UserInput.value    

    # Append the user input to a file in the user's Documents folder using the shell folder path 
    #$csvPath = Join-Path -Path $env:OneDrive -ChildPath "TimeLog-Output.csv"
    $thisWeek = (Get-Date).AddDays(-1 * (Get-Date).DayOfWeek.value__)
    $startOfWeek = $thisWeek.ToString("yyyy-MM-dd")    
    $csvPath = Join-Path -Path $env:OneDrive -ChildPath "TimeLog-Output-$startOfWeek.csv"
    
    # create a psobject with the user input and the current date and time
    $userInput = $Event.SourceArgs[1].UserInput.value
    # If userImput is an array, join it into a string with a comma separator
    if ($userInput -is [array]) {
        $userInput = $userInput -join ' | '
    }
    $currentDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    # Now the object 
    $userInputObject = [PSCustomObject]@{
        DateTime  = $currentDate
        UserInput = $userInput
    }
    # Write the object to a CSV file
    Write-Host "Writing to $csvPath"
    Write-Host "User input: $userInput"
    Write-Host "Current date: $currentDate"
    $userInputObject | Export-Csv -Path $csvPath -Append -NoTypeInformation -Encoding UTF8
    $lockFile = Join-Path -Path $env:OneDrive -ChildPath "TimeLog-Output.lock"
    # Touch the lock file to indicate that the script has run
    New-Item -Path $lockFile -ItemType File -Force -ErrorAction SilentlyContinue | Out-Null
}

$btChoices = @(
    New-BTSelectionBoxItem -Id 'General Support' -Content 'General Support' 
)

Start-Transcript "C:\Temp\transcript.txt"  -ErrorAction SilentlyContinue
# Read a file named "WorkCategories.txt" in the same directory as this script and add the contents to the choices
#$workCategoriesFile = Join-Path -Path $PSScriptRoot -ChildPath 'WorkCategories.txt'
$workCategoriesFile = Join-Path -Path $env:OneDrive -ChildPath 'WorkCategories.txt'
Write-Output "Reading work categories from $workCategoriesFile"
# Read the file into an array of strings
$workCategories = Get-Content -Path $workCategoriesFile -ErrorAction Stop

# Write the category to the output file "C:\Temp\debug.txt"
#$debugFile = Join-Path -Path "C:\Temp\debug.txt"


# If there are more then 5 items in the array, throw a warning and exit the script
if ($workCategories.Count -gt 5) {
    Write-Host "Warning: More than 5 items in the work item array, not supported."
    # Write-Output "Warning: More than 5 items in the array. Exiting script." | Out-File -FilePath $debugFile -Append -Encoding UTF8
    exit 
}

# Loop through the array and add each item to the choices
foreach ($category in $workCategories) {
    # Add the category to the choices, if it is not empty or null
    if ([string]::IsNullOrWhiteSpace($category)) {
        continue 
    }
    Write-Output "Adding category: $category" #| Out-File -FilePath $debugFile -Append -Encoding UTF8

    $btChoices += New-BTSelectionBoxItem -Id $category -Content $category 
}

$InputSplat = @{
    Id                        = 'WorkItem'
    Title                     = 'Select Work Category'
    DefaultSelectionBoxItemId = 'General Support'
    Items                     = $btChoices
}
$BTTextBox = New-BTInput -Id 'Notes' -Title 'Add optional notes (optional)'

$BTInput = @( 
    ( New-BTInput @InputSplat ), 
    $BTTextBox 
)


$text1 = New-BTText -Content 'Work Tracker'
$Submit = New-BTButton -Content 'Submit' -Arguments 'SubmitButton' -ActivationType Foreground
# Submit is Microsoft.Toolkit.Uwp.Notifications.ToastButton
$Dismiss = New-BTButton -Dismiss
# Dismiss is Microsoft.Toolkit.Uwp.Notifications.ToastButtonDismiss subclass 
$Buttons = @($Submit, $Dismiss)
# Buttons is an array of Microsoft.Toolkit.Uwp.Notifications.ToastButton
$Binding1 = New-BTBinding -Children $text1
$Visual1 = New-BTVisual -BindingGeneric $Binding1
$Actions1 = New-BTAction -Inputs $BTInput -Buttons $Buttons  
#$Content1 = New-BTContent -Actions $Actions1 -Visual $Visual1 -Duration Long -ActivationType Foreground
$Content1 = New-BTContent -Actions $Actions1 -Visual $Visual1  -ActivationType Foreground -Scenario Reminder 

# We want to make the CSV file path dynamic and include the date this week started on
$thisWeek = (Get-Date).AddDays(-1 * (Get-Date).DayOfWeek.value__)
$startOfWeek = $thisWeek.ToString("yyyy-MM-dd")

$csvPath = Join-Path -Path $env:OneDrive -ChildPath "TimeLog-Output-$startOfWeek.csv"
$lockFile = Join-Path -Path $env:OneDrive -ChildPath "TimeLog-Output.lock"
Submit-BTNotification -Content $Content1 -ActivatedAction $Activated 

$locked = $false
for ( $i = 0; $( $i -lt 10 ) -and $( $locked -eq $false ) ; $i++ ) {
    if (Test-Path $lockFile) {
        $locked = $true
        Write-Host "File exists: $lockFile"
        # Remove the lock file
        Remove-Item $lockFile -Force #-Verbose #-WhatIf
        break 
    }
    Write-Host "Locked value is $locked"
    Write-Host "Index: $i, File does not exist: $lockFile"
    Test-Path $lockFile 
    Start-Sleep 5; 
}

Stop-Transcript