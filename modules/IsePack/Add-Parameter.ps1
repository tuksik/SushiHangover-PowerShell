function Add-Parameter {
    <#
    .Synopsis
        Adds a Parameter attribute to the current file in the ISE
    .Description
        Adds a Parameter attribute to the current file in the ISE
    .Example
        Add-Parameter
    #>
    param(
        # If set, will add a ParameterSetName ot the parameter attribute
        [String]$ParameterSet,
        # If set, will add a HelpMessage to the parameter attribute
        [String]$HelpMessage,
        # If Set, the parameter attribute will be marked as mandatory
        [Switch]$Mandatory,
        # If Set, the parameter attribute will be marked to accept pipeline input
        [Switch]$FromPipeline,
        # If set, the parameter attribute will be marked to accept input from
        # the pipeline by property name
        [Switch]$FromPipelineByPropertyName
    )    
    $parameterText = "[Parameter("
    if ($ParameterSet) {
        $ParameterText += "ParameterSetName='$ParameterSet',"
    }
    if ($Mandatory) {
        $ParameterText += 'Mandatory=$true,'
    }
    if ($FromPipeline) { 
        $ParameterText += 'ValueFromPipeline=$true,'
    }
    if ($FromPipelineByPropertyName) { 
        $ParameterText += 'ValueFromPipelineByPropertyName=$true,'
    }    
    if ($HelpMessage) {
        $ParameterText += "HelpMessage='$HelpMessage',"
    }
    $ParameterText = $ParameterText.TrimEnd(",") + ")]"
    $psise.CurrentFile.Editor.InsertText("$ParameterText")
}