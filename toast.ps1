# This is a burnt toast notification script. 

# Build a choice box that has the following options:
# CIS hardening
# General meeting 
# Support work 
# Axonius 

$btChoices = @(
    New-BTSelectionBoxItem -Id 'Item1' -Content 'CIS Hardening' 
    New-BTSelectionBoxItem -Id 'Item2' -Content 'General Meeting'
    New-BTSelectionBoxItem -Id 'Item3' -Content 'Support Work'
    New-BTSelectionBoxItem -Id 'Item4' -Content 'Axonius'
)

$InputSplat = @{
    Id                        = 'WorkItem'
    Title                     = 'Select Work Category'
    DefaultSelectionBoxItemId = 'Item1'
    Items                     = $btChoices
}
$BTInput = New-BTInput @InputSplat
# BTinput is ToastTextBox / ToastSelectionBox 

$Submit = New-BTButton -Content 'Submit' -Arguments 'SubmitButton' -ActivationType Foreground
# Submit is Microsoft.Toolkit.Uwp.Notifications.ToastButton
$Dismiss = New-BTButton -Dismiss
# Dismiss is Microsoft.Toolkit.Uwp.Notifications.ToastButtonDismiss subclass 
$Buttons = @($Submit, $Dismiss)
# Buttons is an array of Microsoft.Toolkit.Uwp.Notifications.ToastButton


#$Binding1 = New-BTBinding -Children $Text1 -AppLogoOverride $Image1
$Binding1 = New-BTBinding 
$Visual1 = New-BTVisual -BindingGeneric $Binding1

#$Actions1 = New-BTAction -Inputs $BTInput -Buttons $Submit, $Dismiss
# Actions1 is Microsoft.Toolkit.Uwp.Notifications.IToastActions

$Actions1 = New-BTAction -Inputs $BTInput -Buttons $Buttons 
$Content1 = New-BTContent -Actions $Actions1 -Visual $Visual1

#New-BTBinding -ToastBinding -Content 'Please select the work item you are working on.' -Actions $Actions1 -Buttons $Buttons -SelectionBox $BTInput -SnoozeAndDismiss

#$Toast1 = New-BurntToastNotification -Text 'Time Tracker', 'Please select the work item you are working on.' -Actions $Actions1 -Button $Buttons

#New-BurntToastNotification -Text "Log your time" -Button $Buttons 

# Now run the action 
