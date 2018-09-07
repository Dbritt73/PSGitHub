
Function New-GitHubRepository {
    [CmdletBinding()]
    Param (

        [string]$AccessToken,

        [string]$Name,

        [String]$Description,

        [String]$License = 'MIT'

    )

    Begin {

       $Header = @{
            'Accept' = 'application/vnd.github.symmetra-preview+json'
            "Authorization" = "token $AccessToken"
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

        $Result = Invoke-RestMethod $uri -Method POST -header $header -body $body

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
        
    }

    End {}

}