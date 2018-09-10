 
Function New-GitHubRepository {
  <#
    .SYNOPSIS
    Create remote GitHub repository.

    .DESCRIPTION
    New-GitHubRepository uses a generated OATUH token from your GitHub uuser profile in conjunction with the PowerShell
    Invoke-RestMethod Cmdlet to create a remote GitHub repository with the parameters specified in function call

    .PARAMETER AccessToken
    GitHub Personal Access Token (OAUTH) generated in the develper settings of your GitHub profile

    .PARAMETER Name
    What you want the repository to be named

    .PARAMETER Description
    Description for the new repository

    .PARAMETER License
    Type of license for repository. Defaults to MIT License

    .EXAMPLE
    New-GitHubRepository -AccessToken $token -Name 'Test Repo' -Description 'Description of Test Repo' -License 'MIT'

    .NOTES
    *Eventually add switch for public or private repositories
    *Add more parameters as needed

    .LINK
    Got idea and base code from:
    https://mikefrobbins.com/2018/08/30/powershell-script-module-design-plaster-template-for-creating-modules/

  #>


    [CmdletBinding()]
    Param (

        [Parameter( Mandatory=$true,
                    HelpMessage='Personal access token (OAUTH) from GitHub profile')]
        [string]$AccessToken,

        [Parameter( Mandatory=$true,
                    HelpMessage='Name for the repository')]
        [string]$Name,

        [Parameter( Mandatory=$true,
                    HelpMessage='Description for repository')]
        [String]$Description,

        [String]$License = 'MIT'

    )

    Begin {

        #Use any available TLS security level in case required for REST invocation
        [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

        $Header = @{

            'Accept' = 'application/vnd.github.symmetra-preview+json'
            'Authorization' = "token $AccessToken"

        }

        $uri = 'https://api.github.com/user/repos'

        $body = Get-Content -Path "$PSScriptRoot\Body.json" -Raw

        #Replace variable name place holder in the body content with the received parameter values in function call
        $body = $ExecutionContext.InvokeCommand.ExpandString($body)

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