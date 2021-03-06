function Get-CommandPlugin {
           
        <#
        .Synopsis
            Finds all of the commands that have a signature similar to command
        .Description
            Searches all of the commands for a similar signature to a base command
            The signature of a command will be considered to be the command name + a keyword + additional text + 
            correct parameter names
            For example, if you have a function, Get-Code -URL, then the plugins to Get-Code -preposition From would be:
            Get-CodeFromSourceA -url
            Get-CodeFromSourceB -url
            etc
            By using this command, it is possible to essential use a script and it's parameters as an ad-hoc interface.
            This means you can write a command which does some operation, and then searches the currently loaded commands
            for any plugins.
        .Example
            # Declares a Get-Code function, which finds all plugins and passes its parameters down to those commands
            # also declares Get-CodeFromA, which will print "hi" and the $url, and Get-CodeFromB, which will prnt "bye" and the $url
             function Get-Code($url) { 
                $myInvocation.MyCommand |
                    Get-CommandPlugin -preposition "From" |
                    Foreach-Object {
                        & $_ @psBoundParameters
                    }
            }

            function Get-CodeFromA($url) {
                "hi"
                $url
            }
            function Get-CodeFromB($url) {
                "bye"
                $url
            }           
        .Link
            Get-Command
                    
        #>
        param(
        [Parameter(ValueFromPipeline=$true,
            Position=0)]
        $command,        
        [Parameter(Position=1)]
        [Alias("Keyword")]
        [string]
        $preposition,
        
        [Parameter(Position=2)]
        [string[]]
        $parameters
        )
process {

            if ($command -isnot [Management.Automation.CommandInfo]) {
                $realC = Get-Command $command | Select-Object -First 1
            } else {
                $realC = $command
            }
            if (-not $parameters) {
                $parameters = $realC.Parameters.Keys
            }
            Get-Command "$realC$preposition*" | Where-Object {
                $potentialPlugin = $_
                $isPlugin = $false
                foreach ($p in $parameters) {
                    if ($potentialPlugin.Parameters.Keys -notcontains $p) {
                        return $false
                    }
                }
                return $true
            }
        
}

}
