
Function New-GitHubRepository {
  <#
    .SYNOPSIS
    Describe purpose of "New-GitHubRepository" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER AccessToken
    Describe parameter -AccessToken.

    .PARAMETER Name
    Describe parameter -Name.

    .PARAMETER Description
    Describe parameter -Description.

    .PARAMETER License
    Describe parameter -License.

    .EXAMPLE
    New-GitHubRepository -AccessToken Value -Name Value -Description Value -License Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online New-GitHubRepository

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
  #>


    [CmdletBinding()]
    Param (

        [Parameter( Mandatory=$true,
                    HelpMessage='Add help message for user')]
        [string]$AccessToken,

        [Parameter( Mandatory=$true,
                    HelpMessage='Add help message for user')]
        [string]$Name,

        [Parameter( Mandatory=$true,
                    HelpMessage='Add help message for user')]
        [String]$Description,

        [String]$License = 'MIT'

    )

    Begin {

       $Header = @{

            'Accept' = 'application/vnd.github.symmetra-preview+json'
            'Authorization' = "token $AccessToken"

        }

        $uri = 'https://api.github.com/user/repos'

        $body = @"
        {
        "name" : "$Name",
        "description" : "$Description",
        "auto_init" : "true",
        "license_template" : "$License"
        }
"@

    }

    Process {

        Try {
            
            $Result = Invoke-RestMethod -Uri $uri -Method POST -Headers $header -Body $body

            $ObjProps = @{
    
                'Name' = $Result.Name;
                'Description' = $Result.Description;
                'Owner' = $Result.Owner;
                'URL' = $Result.Html_Url;
                'SSH' = $Result.SSH_URL;
                'Private' = $Result.Private
    
            }
    
            $Obj = New-Object -TypeName PSObject -Property $ObjProps
            $Obj.psobject.typenames.insert(0, 'GitHub.Repo')
            Write-output -InputObject $Obj

        } Catch {

            # get error record
            [Management.Automation.ErrorRecord]$e = $_

            # retrieve information about runtime error
            $info = [PSCustomObject]@{

              Exception = $e.Exception.Message
              Reason    = $e.CategoryInfo.Reason
              Target    = $e.CategoryInfo.TargetName
              Script    = $e.InvocationInfo.ScriptName
              Line      = $e.InvocationInfo.ScriptLineNumber
              Column    = $e.InvocationInfo.OffsetInLine

            }
            
            # output information. Post-process collected info, and log info (optional)
            $info

        }

    }

    End {}

}