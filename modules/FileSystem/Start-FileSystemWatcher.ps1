function Start-FileSystemWatcher {
    <#
    .Synopsis
        Starts monitoring for file changes
    .Description
        Starts monitoring for file changes using the events on IO.FileSystemWatcher
    .Parameter File
        The Name of the File or Folder to Watcher
    .Parameter Filter
        The Filter of Files to Watch
    .Parameter Recurse
        If set, will watch the subdirectories of the folder as well as the folder
    .Parameter On
        A list of events to watch for.
        By default, Created, Deleted, Changed, and Renamed are watched for, 
        and Error and Disposed are not watched for.
    .Parameter Do
        The script blocks to run when the event occurs
    .Example
        Get-Item $pwd | Start-FileSystemWatcher -includeSubdirectories
        # Starts a watcher on everything that changes beneath the current directory
    .Example
        Start-FileSystemWatcher \\MyServer\MyShare -do {
            $subject = "$($eventArgs.ChangeType): $($eventArgs.FullPath)"
            $body = (Get-Content $eventArgs.FullPath -errorAction SilentlyContinue | Out-String)
            $email = @{
                From = 'Me@MyCompany.com'
                To = 'MyBoss@MyCompany.com'
                SmtpServer = 'SmtpHost'
                Subject = $subject
            }
            if ($body) { $email+=@{Body = $body }}                        
            Send-MailMessage @email
        }
        # Watches \\MyServer\MyShare and sends an email with the content of files as they change
    #>    
    param(
    [Parameter(ValueFromPipelineByPropertyName=$true,Position=0,Mandatory=$true)]
    [Alias('FullName')]
    [string]$File,
    [string]$Filter = "*",
    [switch]$Recurse,
    
    [ValidateScript({
        if (-not ([IO.FileSystemWatcher].GetEvent($_))) {
            $possibleEvents = [IO.FileSystemWatcher].GetEvents() | 
                ForEach-Object { $_.Name } 
            throw "$_ is not an event on [IO.FileSystemWatcher].  Possible values are: $possibleEvents"
        }
        return $true
    })]    
    [string[]]
    $On = @("Created", "Deleted", "Changed", "Renamed"),
    
    [ScriptBlock[]]
    $Do            
    )
    process {    
        $realItem  =Get-Item $file -ErrorAction SilentlyContinue
        if (-not $realItem) { return } 
        $watcher = New-Object IO.FileSystemWatcher -Property @{
            Path = $realItem.Fullname
            Filter = $filter
            IncludeSubdirectories = $Recurse
        }
        foreach ($o in $on) {
            $null = Register-ObjectEvent $watcher $o
            foreach ($d in $do) {
                if (-not $d) { continue } 
                $null = Register-ObjectEvent $watcher $o -Action $d
            }                
        }        
    }
}