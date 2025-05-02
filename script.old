<#
OneCall needs to have a detailed inventory of what folks are doing throughout the day for billing purposes. 
This script helps track time and tasks. 

It will prompt the user for a task and time spent, then log it to a file.
This will pop up in the system tray every hour to remind the user to log their time.
It will also log the time spent on each task to a CSV file transcription into ServiceNow. 
This script will be set up to run every hour using Task Scheduler from 8 AM to 5 PM, and run under the current user's context. 
The file will be saved in the user's Documents folder, and appended to a file named "TimeLog.csv".
#>

# Define the path to the CSV file in the user's Documents folder
$csvPath = Join-Path -Path $env:USERPROFILE -ChildPath "Documents\TimeLog.csv"

# Check if the CSV file exists, if not create it with headers
if (-not (Test-Path -Path $csvPath)) {
    "Date,Task,TimeSpent" | Out-File -FilePath $csvPath -Encoding UTF8
}


# First a functon to pop a toast notification that will remind the user to log their time
function Show-ToastNotification {
    # Wrapper for BurntToast to show a toast notification
    New-BurntToastNotification -Text 'WAKE UP!' -SnoozeAndDismiss

}

# Function to log time and task
function Log-TimeAndTask {
    # Prompt for task and time spent
    $task = Read-Host "Enter the task you worked on"
    $timeSpent = Read-Host "Enter the time spent (in hours)"

    # Get the current date and time
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    # Create a new entry
    $entry = "$date,$task,$timeSpent"

    # Append the entry to the CSV file
    $entry | Out-File -FilePath $csvPath -Append -Encoding UTF8

    Write-Host "Logged: $entry"
}

# Pop the notification 
Show-ToastNotification
# Sleep for 90 seconds to give the user time to read it
Start-Sleep -Seconds 90
# Now log the time and task
Log-TimeAndTask