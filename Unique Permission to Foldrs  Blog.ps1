function GrantAccessToFolder($FolderName ,$GroupName,$RootFolderName,$ListNames)
 {
 
 Add-Type -Path 'c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll'
 Add-Type -Path 'c:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll'
 #Create a user.txt File on C:Drive and save credentail lik i.e https://siteNam.com,userid@contoso.com,****password
 $Test=Get-Content -Path 'C:\user.txt';
 $SplitString=$Test.Split(',')
 $sPassword=convertto-securestring $SplitString[2] -asplaintext -force
 $Username =$SplitString[1];
 $Password =$sPassword
 $Site =$SplitString[0];
 $ListName=$ListNames
 $RootFolder=$RootFolderName;


$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds
$web = $Context.Web
$Context.Load($web)

#Check the Group Name is there or not
$grpName=$GroupName 
$group = $Context.Web.SiteGroups.getByName($grpName);
$Context.Load($group)
$Context.ExecuteQuery()

$folderur = $web.ServerRelativeUrl + "/" + $ListName + "/" + $RootFolder
$folderur2 ="https://sitename/"+ $folderur
#get the Folder path and full name
Write-Host $folderur2

$root = $web.GetFolderByServerRelativeUrl($folderur2)
$Context.Load($root.Folders)
$Context.ExecuteQuery()

    foreach($folder in $root.Folders){
    Function GetRole
       {
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true, Position = 1)]
            [Microsoft.SharePoint.Client.RoleType]$rType
        )
        $web = $Context.Web
        if ($web -ne $null)
        {
            $roleDefs = $web.RoleDefinitions
            $Context.Load($roleDefs)
            $Context.ExecuteQuery()
            $roleDef = $roleDefs | Where-Object { $_.RoleTypeKind -eq $rType }
            return $roleDef
        }
        return $null
    }
        if ($folder.Name -ne "Forms" )
         {
           if ($folder.Name -eq $FolderName )
            {
                write-host $folder.Name
                #Break inheritance and remove existing permissions
                $folder.ListItemAllFields.BreakRoleInheritance($false, $true)
                #Below are the Role Type
                #$roleType = Read-Host "None, Guest, Reader, Contributor, WebDesigner, #Administrator, Editor"
                $roleType = "Administrator"
                $roleTypeObject = [Microsoft.SharePoint.Client.RoleType]$roleType
                $roleObj = GetRole $roleTypeObject
                #Bind Permission Level to Group
                $RoleDefBind = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Context)
                $RoleDefBind.Add($roleObj)
                $Assignments = $Context.Web.RoleAssignments
                #Apply the permission roles to the list.
                $Context.Load($folder.ListItemAllFields.RoleAssignments.Add($group, $RoleDefBind))
                $folder.Update()
                $Context.ExecuteQuery()
           }#if end small
        }#if end parent

    } #for each end
}
$grpNsame1="MyGroupNAme";
$RootFolderName="Folder A";
$MyListName="ListName";
GrantAccessToFolder -FolderName "Folder AA" -GroupName $grpNsame1  -RootFolderName $RootFolderNames -ListNames 
#This Script Break the Inheritance from the Folder
#Assign the Group which only has acccess to that folder
#If we want to remove acces of other then we have remove all other group or users from that folder.
