# Require admin rights
#Requires -RunAsAdministrator

# Check if the task exists
$taskName = "Time Keeper"
if ( Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue ) {
    Write-Host "Task $taskName exists."
}
else {
    Write-Host "Task $taskName does not exist. Creating it."
    # Import the task from the XML file
    $task = Import-Clixml .\timeKeeper.xml
    # Update the task to run with the current user context
    $task.Principal.UserId = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    # Register the task with the updated principal
    Register-ScheduledTask -TaskName $taskName -InputObject $task -User $env:USERNAME -ErrorAction SilentlyContinue
}

