import-module ActiveDirectory
$DaysInactive = "90"
$a=get-location
$a = $a.path
$a = $a + "\Report_AD_"
$b = get-addomain
$a = $a + $b.name
$a = $a + ".html"
$report = $a
$Date = Get-Date
$HTMLIntitle = @"
<html> 
<Head>
<Title>Audit AD</title>
<Style>
body
{   font-family: arial, verdana;
    color: #333;
    background-color: #999;
    padding: 10px;
    font-size: 14px;}
h1
{   font-size: 1.7em;
    color: #fff;
    text-align: center;}
h2
{   font-size: 1.7em;
    color: #800;}
h3
{   font-size: 1em;
    color: #000;}
.table_main
{   border-collapse: collapse;
    background-color: #DDD;
    font-size: 1em;
    cellpaddind: 10px;}
.table_sub
{   border-collapse: collapse;
    background-color: #FFF;
    font-size: 1em;
    width: 100%;
    cellpaddind: 10px;}
.table_main th
{   border: 1px solid #AAA;
    background-color: #777;
    padding: 10px;
    color: #FFF;}
.table_main_td3
{   border: 1px solid #AAA;
    background-color: #777;
    padding: 10px;
    color: #FFF;}
.table_main td
{    border: 1px solid #AAA;
     text-align: center;
     padding: 10px;}
.table_fin
{   border: 1px solid #777;
    border-collapse: collapse;
    background-color: #DDD;
    font-size: 1em;
    text-align: left;}
.table_main_td2
{   border: 1px solid #AAA;
    padding: 10px;
    text-align: left;
    vertical-align: top;}
.td_computer
{   background-color: #F5F5F5;
    color: #333;
    font-weight: bold;}
.td_Error
{   background-color: #F1302A;
    color: #FFF;}
.td_OK
{   background-color: #46B810;
    color: #FFF;}
.td_warn
{   background-color:orange;
    color: #FFF;}
.td_empty
{}
.span_Value
{   font-size: 1.6em;}
.span_Unit
{    font-size: 1.2em;}
.span_advert
{   font-size: 0.8em;
    font-weight: bold;
    color: #888;}
</style>
</Head>
<body>
"@
 
 $HTMLfin = @"
<p>
<H2>Recommandations</H2>
<table class=table_fin>
<tr><td><u>AD - Funstional Level</u></td></tr>
<tr><td>Securing Active Directory involves the version of the operating system of its domain controllers. Aiming for the highest functional level helps increase the security level; the most recent versions indeed address the security gaps of previous versions.</td></tr>
</table>
<br>
<table class=table_fin>
<tr><td><u>AD - Inactive accounts</u></td></tr>
<tr><td>- Implement a policy of automatic deactivation of accounts that have not been used for a certain period of time.</td></tr>
<tr><td>- Any deactivated account must have all its rights and privileges revoked and be transferred to an organizational unit intended for this purpose.</td></tr>
<tr><td>- Any deactivated account can be easily reactivated, so it is essential to remove its rights and privileges. However, it is recommended not to delete deactivated accounts, in order to keep a record of user accounts that have been active in the information system.</td></tr>
</table>
<br>
<table class=table_fin>
<tr><td><u>AD - GPO</u></td></tr>
<tr><td>Define a naming convention for group policies to make it appear there
<tr><td>The type of targeted object (Computer or User)</td></tr>
<tr><td>to the targeted population (Geographic site, an application, etc.</td></tr>
<tr><td>For example, a GPO defining Internet Explorer security settings for users (symbolized by the letter U) of a French site could be named GPO-U-Fr-SecurityIE</td></tr>
<tr><td></td></tr>
<tr><td>Limiter le nombre de strat gies de groupe qui s appliquent   un objet Active Directory afin de limiter les incidences sur les performances et le risque de red finition ou d  crasement de param tres.</td></tr>
<tr><td>D sactiver la partie utilisateur ou ordinateur d une GPO si aucun param tre n est configur  et de limiter l utilisation de filtre WMI afin d optimiser le temps de traitement d application de la strat gie.</td></tr>
<tr><td>Limiter l utilisation de la fonctionnalit  de blocage de l h ritage afin de ne pas complexifier l administration.</td></tr>
<tr><td>Ne pas lier une GPO   une m me OU plus d une fois : des comportements impr visibles pourraient survenir.</td></tr>
</table>
<br>
<table class=table_fin>
<tr><td><u>ROLES FSMO</u></td></tr>
<tr><td>Dans un environnement compos  d une for t mono-domaine, il est recommand  de placer tous les r les FSMO sur un m me DC. Dans un environnement multidomaines, il est recommand  de suivre les r gles suivantes lors du placement des r les FSMO :</td></tr>
<tr><td>  placement du PDC sur une machine robuste dans un site AD ayant d autres DC du m me domaine</td></tr>
<tr><td>  placement du contr leur de sch ma sur le PDC du domaine racine</td></tr>
<tr><td>  placement du ma tre d attribution de noms de domaine sur le PDC du domaine racine</td></tr>
<tr><td>  placement du ma tre RID sur le PDC du m me domaine</td></tr>
<tr><td>  placement du ma tre d infrastructure sur un DC non GC sauf si tous les DC sont GC.</td></tr>
</table>

</p>
"@
$HTMLEnding = @"
</body>
</html>
"@

$a = get-addomain
$b = get-adforest

$domcont = get-adgroup -Filter * | where {$_.SID -like "*-516"}
Set-Content -path $report -value " "
add-Content -path $report -value $HTMLIntitle
add-content -path $report -value "<h1>Audit Active Directory - Date: $Date</h1>"
add-Content -path $report -value "<hr>" 
add-Content -path $report -value "<H2>AD Info</H2>" 
add-Content -path $report -value "<table class=table_main>"
$domname = $a.DNSRoot
add-Content -path $report -value "<tr><td>Domain Name</td>"
add-Content -path $report -value "<td>"
add-Content -path $report -value  $a.DNSRoot
add-Content -path $report -value "</td></tr>"
$b = Get-Childitem \\$domname\sysvol\$domname\Policies -Recurse | Measure-Object -property length -sum
add-Content -path $report -value "<tr><td>"
add-Content -path $report -value "Size of the Sysvol folder
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td>"
$totl = [math]::round($b.sum/1024/1024)
add-Content -path $report -value $totl
add-Content -path $report -value " Mo"
add-Content -path $report -value "</td></tr>" 

try
{$ntdsdb = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters" -name "DSA Database file"
 $path = $ntdsdb.'DSA Database file'
 $ntds = Get-Item "D:\NTDS\ntds.dit"
 $totl = [math]::round($ntds.length/1024/1024)}

catch
{ $totl = "N/A" }

finally
{ add-Content -path $report -value "<tr><td>Size of the NTDS folder</td>" 
  add-Content -path $report -value "<td>" 
  add-Content -path $report -value $totl
  add-Content -path $report -value " Mo"
  add-Content -path $report -value "</td></tr>" }

$b = Get-Childitem \\$domname\sysvol\$domname\scripts -Recurse | Measure-Object -property length -sum
add-Content -path $report -value "<tr><td>Size of folder Netlogon</td>" 
add-Content -path $report -value "<td>" 
$totl = [math]::round($b.sum/1024/1024)
add-Content -path $report -value $totl
add-Content -path $report -value " Mo"
add-Content -path $report -value "</td></tr>" 
add-Content -path $report -value "</table><HR>"

# DC

add-Content -path $report -value "<H2>Domain controllers</H2>" 
add-Content -path $report -value "<table class=table_main>"
add-Content -path $report -value "<tr><th>Nom</th><th>Type</th></tr>"

$dclist = New-Object System.Collections.ArrayList
$domcont = get-adgroup -Filter * | where {$_.SID -like "*-516"}
$domdc = Get-ADGroupMember -identity $domcont
foreach ($dc in $domdc)
{
$dc = $dc.name
$dclist.add("$dc")
}
foreach ($dc in $dclist)
{
add-Content -path $report -value "<tr><td>$dc</td><td>DC</td></tr>"
}

$dclist2 = New-Object System.Collections.ArrayList
$domcont = get-adgroup -Filter * | where {$_.SID -like "*-521"}
$domdc = Get-ADGroupMember -identity $domcont
foreach ($rodc in $domdc)
{
$rodc = $rodc.name
$dclist2.add("$rodc")
}
foreach ($rodc in $dclist2)
{
add-Content -path $report -value "<tr><td>$dc</td><td>RODC</td></tr>"
}
write-host "dc " $dclist
if ($dclist2){
write-host "rodc " $dclist2
}

if ($dclist2){
$dclist.add($dclist2)
}

add-Content -path $report -value "</table><HR>"

#
# FSMO ROLES
# 

$a = get-addomain
$b = get-adforest
add-Content -path $report -value "<H2>Roles FSMO</H2>"
add-Content -path $report -value "<table class=table_main>"
add-Content -path $report -value "<tr><th>Role</th>"
add-Content -path $report -value "<th>Server</th></tr>"
add-Content -path $report -value "<tr><td>Infrastructure Master</td>" 
add-Content -path $report -value "<td><p text-align: center;>"
add-Content -path $report -value $a.InfrastructureMaster
add-Content -path $report -value "</p></td></tr>"
add-Content -path $report -value "<tr><td>PDC Emulator</td>" 
add-Content -path $report -value "<td>"
add-Content -path $report -value $a.PDCEmulator
add-Content -path $report -value "</td></tr>"
add-Content -path $report -value "<tr><td>Master RID</td>"
add-Content -path $report -value "<td>"
add-Content -path $report -value $a.RIDMaster
add-Content -path $report -value "</td></tr>"
add-Content -path $report -value "<tr><td>Operation Master</td>" 
add-Content -path $report -value "<td>"
add-Content -path $report -value $b.DomainNamingMaster
add-Content -path $report -value "</td></tr>"
add-Content -path $report -value "<tr><td>Schema Master</td>"
add-Content -path $report -value "<td>"
add-Content -path $report -value $b.SchemaMaster
add-Content -path $report -value "</td></tr>"
add-Content -path $report -value "</table>"
add-Content -path $report -value "<HR>"
write-host "FSMO roles ok"

#
# FUNCTIONAL LEVEL
# 

$a = get-addomain
$b = get-adforest
add-Content -path $report -value "<H2>Functional level</H2>"
add-Content -path $report -value "<table class=table_main>"
add-Content -path $report -value "<tr><td>Domaine</td>" 
add-Content -path $report -value "<td "
if ($a.DomainMode -like '*2016*')
{ $comment = $comment + @("Domain fucntional level is")
  add-Content -path $report -value "class=td_ok"}
if ($a.DomainMode -like '*2012*')
{ $comment = $comment + @("Domain fucntional level is")
  add-Content -path $report -value "class=td_ok"}
if ($a.DomainMode -like '*2008*')
{ $comment = $comment + @("The functional level of the domain is not up to date")
  add-Content -path $report -value "class=td_warn"}
if ($a.DomainMode -like '*2003*')
{ $comment = $comment + @("The functional level of the domain is outdated")
  add-Content -path $report -value "class=td_Error"}
add-Content -path $report -value ">"
add-Content -path $report -value $a.DomainMode
add-Content -path $report -value "</td>" 
add-Content -path $report -value "<tr><td>For t</td>"
add-Content -path $report -value "<td "

if ($b.ForestMode -like '*2016*')
{ $comment = $comment + @("The functional level of the forest is up to date")
  add-Content -path $report -value "class=td_ok"}

if ($b.ForestMode -like '*2012*')
{ $comment = $comment + @("The functional level of the forest is up to date")
  add-Content -path $report -value "class=td_ok"}

if ($b.ForestMode -like '*2008*')
{ $comment = $comment + @("The functional level of the domain is not up to date")
  add-Content -path $report -value "class=td_warn"}

if ($b.ForestMode -like '*2003*')
{ $comment = $comment + @("The functional level of the domain is outdated")
  add-Content -path $report -value "class=td_Error"
}
add-Content -path $report -value ">"
add-Content -path $report -value $b.ForestMode
add-Content -path $report -value "</td></tr>"
add-Content -path $report -value "</table>"
add-Content -path $report -value "<HR>"
write-host "niveau fonctionnel ok"

#
# OBJECTS
# 

add-Content -path $report -value "<H2>Objets</H2>"

#
# COMPUTERS
#

write-host "----------------------------"
write-host "Computers"
write-host "----------------------------"

add-Content -path $report -value "<table class=table_main>"
add-Content -path $report -value "<tr><th>Computers</th>"
add-Content -path $report -value "<th>Groups</th>"
add-Content -path $report -value "<th>Users</th>"
add-Content -path $report -value "<th>GPO</th></tr>"
add-Content -path $report -value "<tr>"
add-Content -path $report -value "<td class=table_main_td2>"
add-Content -path $report -value "<table class=table_sub>"

$a = Get-ADComputer -Filter 'ObjectClass -eq "Computer"' | measure
add-Content -path $report -value "<tr><td>Comptes</td>" 
add-Content -path $report -value "<td>" 
add-Content -path $report -value $a.count
add-Content -path $report -value "</td></tr>"
$cnt = $a.count
write-host $cnt " Computers"

# $DaysInactive = 100
# $time = (Get-Date).Adddays(-($DaysInactive)) 
# $a = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time -and enabled -eq $true} -Properties LastLogonTimeStamp

$a = Search-ADAccount -AccountInactive -TimeSpan $DaysInactive -ComputersOnly
$cnt = $a | measure
$cnt = $cnt.count

$loc = get-location
$loc = $loc.path
$loc = $loc + "\_InactiveComputers.txt"
Set-Content -path $loc -value "Computers inactive after $DaysInactive days"
Add-Content -path $loc -value "--------------------------------------------"
add-Content -path $loc -value $a.SamAccountName

add-Content -path $report -value  "<tr><td>stations not connected for more than "
add-Content -path $report -value  $DaysInactive
add-Content -path $report -value  " days</td>"
add-Content -path $report -value "<td>" 
add-Content -path $report -value $cnt
add-Content -path $report -value "</td></tr>"
write-host $cnt " Computers inactive after $DaysInactive days"

$a = Get-ADComputer -Filter {enabled -eq $false}

$loc = get-location
$loc = $loc.path
$loc = $loc + "\_DisabledComputers.txt"
Set-Content -path $loc -value "Computers disabled"
Add-Content -path $loc -value "----------------------"
add-Content -path $loc -value $a.SamAccountName

$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td>Computers disabled</td>"
add-Content -path $report -value "<td>" 
add-Content -path $report -value $cnt
add-Content -path $report -value "</td></tr>" 
add-Content -path $report -value "</table>"
add-Content -path $report -value "</td>"
write-host $cnt " Computers disabled"
write-host "-> ordinateurs ok"

#
# GROUPS
#

write-host "----------------------------"
write-host "Groups"
write-host "----------------------------"

add-Content -path $report -value "<td class=table_main_td2>"
add-Content -path $report -value "<table class=table_sub>"
$a = Get-ADGroup -Filter 'GroupCategory -eq "Security"'
$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td>Security groups</td>"
add-Content -path $report -value "<td>" 
add-Content -path $report -value $cnt
add-Content -path $report -value "</td></tr>" 
write-host $cnt "Security groups"

$count = 0
$compteur = 0
$A = Get-ADGroup -Filter 'GroupCategory -eq "Security"'

$loc = get-location
$loc = $loc.path
$loc = $loc + "\_EmptySecurityGroups.txt"
Set-Content -path $loc -value " Empty security groups"
Add-Content -path $loc -value "-------------------------"

#foreach ($grp in $A.samaccountname)
#{
#$cnt = Get-ADGroupMember -Identity "$grp" | measure
#if ($cnt.count -eq '0')
#{
#$count = $count + 1
#add-Content -path $loc -value $grp
#}
#$compteur = $compteur + 1
#write-host "v rification du groupe " $compteur
#}
#add-Content -path $report -value "<tr><td> Empty security groups</td>"
#add-Content -path $report -value "<td>" 
#add-Content -path $report -value $count
#add-Content -path $report -value "</td></tr>" 
#write-host $count "->  Empty security groups OK"

$a = Get-ADGroup -Filter 'GroupCategory -eq "Distribution"'
$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td>Distribution groups</td>"
add-Content -path $report -value "<td>" 
add-Content -path $report -value $cnt
add-Content -path $report -value "</td></tr>"
write-host $cnt "Distribution groups"

$a = Get-ADGroup -Filter 'GroupScope -eq "DomainLocal"'
$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td>Local GRoups</td>"
add-Content -path $report -value "<td>" 
add-Content -path $report -value $cnt
add-Content -path $report -value "</td></tr>"
write-host $cnt "Local GRoups"

$a = Get-ADGroup -Filter 'GroupScope -eq "Global"'
$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td>Global Group</td>"
add-Content -path $report -value "<td>" 
add-Content -path $report -value $cnt
add-Content -path $report -value "</td></tr>"
write-host $cnt "Global Groups"

$a = Get-ADGroup -Filter 'GroupScope -eq "Universal"'
$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td>Groupes universels</td>"
add-Content -path $report -value "<td>$cnt</td></tr>"
add-Content -path $report -value "</table>"
add-Content -path $report -value "</td>"
write-host $cnt "Groupes universels"
write-host "-> Groupes ok"

#
# USERS
#

write-host "----------------------------"
write-host "Users"
write-host "----------------------------"

add-Content -path $report -value "<td class=table_main_td2>"
add-Content -path $report -value "<table class=table_sub>"
$a = Get-ADUser -Filter *
$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td>Comptes</td>"
add-Content -path $report -value "<td>$cnt</td></tr>"
write-host $cnt " users"

# $DaysInactive = 100

#$time = (Get-Date).Adddays(-($DaysInactive)) 
#$a = Get-ADUser -Filter {LastLogonTimeStamp -lt $time -and enabled -eq $true} -Properties LastLogonTimeStamp

$a = Search-ADAccount -AccountInactive -TimeSpan $DaysInactive -UsersOnly

$loc = get-location
$loc = $loc.path
$loc = $loc + "\_InactiveUsers.txt"
Set-Content -path $loc -value "Users no connection after $DaysInactive days"
Add-Content -path $loc -value "-----------------------------------------"
add-Content -path $loc -value $a.SamAccountName


$cnt = $a | measure
$cnt = $cnt.count

add-Content -path $report -value "<tr><td>Users no connection after $DaysInactive days</td>"
add-Content -path $report -value "<td>$cnt</td></tr>"
write-host $cnt " Users no connection after $DaysInactive days"

# DISABLED USERS

$loc = get-location
$loc = $loc.path
$loc = $loc + "\_DisabledUsers.txt"
Set-Content -path $loc -value "Disabled users"
Add-Content -path $loc -value "-----------------------"
$a = Get-ADUser -Filter {enabled -eq $false}
add-Content -path $loc -value $a.SamAccountName
$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td>D sactiv s</td>"
add-Content -path $report -value "<td>$cnt</td></tr>"
write-host $cnt "Disabled users ok"
$a = Get-ADUser -Properties * -Filter * | select name, scriptpath | Where-Object {$_.scriptpath -ne $null} | measure
#$cnt = $a | measure
$cnt = $a.count
add-Content -path $report -value "<tr><td>Avec login script</td>"
add-Content -path $report -value "<td>$cnt</td></tr>"
write-host $cnt "Users avec login script"
$a = get-aduser -filter {PasswordNeverExpires -eq $True} -properties passwordneverexpires
$loc = get-location
$loc = $loc.path
$loc = $loc + "\_UsersPasswordNeverExpire.txt"
Set-Content -path $loc -value "Password never expires"
Add-Content -path $loc -value "----------------------------"
add-Content -path $loc -value $a.SamAccountName
$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td>Password never expires</td>"
add-Content -path $report -value "<td>$cnt</td></tr>"
write-host $cnt "Password never expires"
$a = Get-ADUser -filter * -Properties Name,pwdLastSet | select SamAccountName,pwdLastSet
$loc = get-location
$loc = $loc.path
$loc = $loc + "\_UsersPasswordLastSet365Days.txt"
Set-Content -path $loc -value "Password never expires"
Add-Content -path $loc -value "----------------------------"
add-Content -path $loc -value $a.SamAccountName
$cnt = 0
ForEach ($usr in $a) 
{
$samaccountname = $usr.SamAccountName 
$today = Get-Date 
$lastchange = [datetime]::FromFileTime($usr.pwdlastset[0])
$timediff = New-TimeSpan $lastchange $(Get-Date) 
$last = $timediff.days
if ($last -gt 365)
	{
	$cnt = $cnt + 1
	add-Content -path $loc -value $samaccountname
	}
} 
add-Content -path $report -value "<tr><td>Password unchanged for more than 365 days</td>"
add-Content -path $report -value "<td>$cnt</td></tr>"
write-host $cnt "Password unchanged for more than 365 days ok"
$a = Get-ADUser -filter * -Properties profilepath | Where-Object {$_.profilepath -ne $null}  | measure
#$cnt = $a | measure
$cnt = $a.count
add-Content -path $report -value "<tr><td>Avec un profil itin rant</td>"
add-Content -path $report -value "<td>$cnt</td></tr>"
write-host $cnt "Users with a roaming profile"
add-Content -path $report -value "</table>"
write-host "-> Users ok"

#
# GPO
#

write-host "----------------------------"
write-host "GPO"
write-host "----------------------------"
add-Content -path $report -value "<td class=table_main_td2>"
add-Content -path $report -value "<table class=table_sub>"
$a = Get-GPO -All
$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td># GPO</td>"
add-Content -path $report -value "<td>" 
add-Content -path $report -value $cnt
add-Content -path $report -value "</td></tr>"
write-host $cnt "GPO"
$a = Get-GPO -All | where{ $_.GpoStatus -ne "AllSettingsDisabled" }
$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td>Activ es</td>"
add-Content -path $report -value "<td>" 
add-Content -path $report -value $cnt
add-Content -path $report -value "</td></tr>"
write-host $cnt "GPO active"
$a = Get-GPO -All | where { $_.GpoStatus -eq "AllSettingsDisabled" }
$loc = get-location
$loc = $loc.path
$loc = $loc + "\_DisabledGPO.txt"
Set-Content -path $loc -value "GPO disabled"
Add-Content -path $loc -value "---------------"
add-Content -path $loc -value $a.DisplayName
$cnt = $a | measure
$cnt = $cnt.count
add-Content -path $report -value "<tr><td>Disabled</td>"
add-Content -path $report -value "<td>" 
add-Content -path $report -value $cnt
add-Content -path $report -value "</td></tr>"
write-host $cnt "GPO Disabled"
function IsNotLinked($xmldata){ 
    If ($xmldata.GPO.LinksTo -eq $null) { 
        Return $true 
    } 
    Return $false 
} 
$unlinkedGPOs = @() 
Get-GPO -All | ForEach { $gpo = $_ ; $_ | Get-GPOReport -ReportType xml | ForEach { If(IsNotLinked([xml]$_)){$unlinkedGPOs += $gpo} }} 
add-Content -path $report -value "<tr><td>Unlinked</td>"
add-Content -path $report -value "<td>" 
add-Content -path $report -value $unlinkedGPOs.count
add-Content -path $report -value "</td></tr>"
$unlink = $unlinkedGPOs.count
$loc = get-location
$loc = $loc.path
$loc = $loc + "\_UnlinkedGPO.txt"
Set-Content -path $loc -value "GPO Unlinked"
Add-Content -path $loc -value "------------"
add-Content -path $loc -value $UnlinkedGPOs.DisplayName
add-Content -path $report -value "</table>"
add-Content -path $report -value "</table>"
add-Content -path $report -value "</td></tr>"
add-Content -path $report -value "<hr>"
write-host "-> GPO ok"

#
# Members of Privileged Groups
#

write-host "------------------------------------"
write-host "Members of Administrative groups"
write-host "--------------------------------"

add-Content -path $report -value "<H2>Privileged groups</H2>"
add-Content -path $report -value "<table class=table_main>"
add-Content -path $report -value "<tr><th>Group</th>"
add-Content -path $report -value "<th>Users<p>membres</th>"
add-Content -path $report -value "<th>Groups<p>membres</th>"
add-Content -path $report -value "<th>Users<p>Disabled</th></tr>"

$adm_sch = get-adgroup -Filter * | where {$_.SID -like "*-518"}
$adm_ent = get-adgroup -Filter * | where {$_.SID -like "*-519"}
$cer_pub = get-adgroup -Filter * | where {$_.SID -like "*-517"}
$dom_adm = get-adgroup -Filter * | where {$_.SID -like "*-512"}
$srv_ope = get-adgroup -Filter * | where {$_.SID -like "*-549"}
$srv_acc = get-adgroup -Filter * | where {$_.SID -like "*-548"}
$blt_adm = get-adgroup -Filter * | where {$_.SID -like "*-544"}
$ope_bak = get-adgroup -Filter * | where {$_.SID -like "*-551"}
#$rodc = get-adgroup -Filter * | where {$_.SID -like "*-521"}
#$privileg = @($domcont,$adm_sch,$adm_ent,$cer_pub,$dom_adm,$srv_ope,$srv_acc,$rodc)
$privileg = @($adm_sch,$adm_ent,$cer_pub,$dom_adm,$srv_ope,$srv_acc,$blt_adm,$ope_bak)

foreach ($mem in $privileg)
{$a = Get-ADGroupMember -Identity $mem -errorvariable err | Where-Object {$_.objectclass -eq "User"}
#{
#$a = Get-ADGroupMember -Identity $mem -errorvariable err
$dis = 0
foreach ($usr in $a)
{ $res = Get-ADUser -identity "$usr" 
  if ($res.enabled -eq $False){$dis ++}
}
$cnt = $a | measure
$cnt = $cnt.count
$loc = get-location
$loc = $loc.path
$loc = $loc + "\_Group-" + $mem.name + ".txt"
Set-Content -path $loc -value $mem.name
Add-Content -path $loc -value "------------"
$grp = Get-ADGroupMember -Identity $mem -errorvariable err | Where-Object {$_.objectclass -eq "Group"} | measure
if ($err.count -gt '0') { $cnt = 'N/A' }
$group = $mem.name
add-Content -path $report -value "<tr><td>$group</td><td "
add-Content -path $loc -value $a.SamAccountName
write-host $mem.name "Ok"
if ($cnt -eq 'N/A') {add-Content -path $report -value "class=td_ok"}
if ($cnt -lt '10') {add-Content -path $report -value "class=td_ok"}
if ($cnt -gt '9' -and $cnt -lt '20') {add-Content -path $report -value "class=td_warn"}
if ($cnt -gt '19') {$comment = $comment + @("Too many members in the security group<u>$group</u> ")
add-Content -path $report -value "class=td_Error"}
add-Content -path $report -value ">$cnt</td>"
add-Content -path $report -value "<td "
if ($grp.count -gt 0) {add-Content -path $report -value "class=td_warn>"}
if ($grp.count -eq 0) {add-Content -path $report -value "class=td_ok>"}
add-Content -path $report -value $grp.count
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td "
if ($dis -gt 0) {add-Content -path $report -value "class=td_error>"}
if ($dis -eq 0) {add-Content -path $report -value "class=td_ok>"}
add-Content -path $report -value "$dis</td></tr>"
}
add-Content -path $report -value "</table>"
add-Content -path $report -value "<hr>"
write-host "-> Privileged groups --> ok"

#
# PASSWORD POLICY
#

write-host "---------------"
write-host "PASSWORD POLICY"
write-host "---------------"

add-Content -path $report -value "<H2>Password Policy</H2>"
$a = Get-ADDefaultDomainPasswordPolicy
add-Content -path $report -value "<table class=table_main>"
add-Content -path $report -value "<tr><th>Param tre</th>"
add-Content -path $report -value "<th>Configured</th>"
add-Content -path $report -value "<th>Recommended </tr>"

add-Content -path $report -value "<tr><td>Complex password</td>"
add-Content -path $report -value "<td "
if ($a.ComplexityEnabled -like '*False*')
{ $comment = $comment + @("Password complexity not enabled<br>")
  add-Content -path $report -value "class=td_error" }
if ($a.ComplexityEnabled -like '*True*') {add-Content -path $report -value "class=td_ok"}
add-Content -path $report -value ">"
add-Content -path $report -value $a.ComplexityEnabled
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td class=td_ok>Activ </td>"
add-Content -path $report -value "</tr>"

add-Content -path $report -value "<tr><td>Minimun password lenght</td><td "
if ($a.MinPasswordLength -lt '6')
{
$comment = $comment + @("Increase password lenght<br>")
add-Content -path $report -value "class=td_error"
}
if ($a.MinPasswordLength -gt '5') {add-Content -path $report -value "class=td_ok"}
add-Content -path $report -value ">"
add-Content -path $report -value $a.MinPasswordLength
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td class=td_ok>8</td>"
add-Content -path $report -value "</tr>"

add-Content -path $report -value "<tr><td>Password history</td>"
add-Content -path $report -value "<td "
if ($a.PasswordHistoryCount -lt '4') {add-Content -path $report -value "class=td_error"}
if ($a.PasswordHistoryCount -gt '3') {add-Content -path $report -value "class=td_warning"}
if ($a.PasswordHistoryCount -gt '5') {add-Content -path $report -value "class=td_ok"}
add-Content -path $report -value ">"
add-Content -path $report -value $a.PasswordHistoryCount
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td class=td_ok>5</td>"
add-Content -path $report -value "</tr>"

add-Content -path $report -value "<tr><td>Password age</td>"
add-Content -path $report -value "<td "
if ($a.MaxPasswordAge -lt '60.0:0:0') {add-Content -path $report -value "class=td_ok"}
if ($a.MaxPasswordAge -eq '0.0:0:0') {add-Content -path $report -value "class=td_ok"}
if ($a.MaxPasswordAge -gt '59.0:0:0' -and $a.MaxPasswordAge -lt '100.0:0:0') {add-Content -path $report -value "class=td_warning"}
if ($a.MaxPasswordAge -gt '99.0:0:0') {add-Content -path $report -value "class=td_error"}
add-Content -path $report -value ">"
add-Content -path $report -value $a.MaxPasswordAge.days
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td class=td_ok>90</td>"
add-Content -path $report -value "</tr>"

add-Content -path $report -value "<tr><td>Minimun password age</td>"
add-Content -path $report -value "<td "
if ($a.MinPasswordAge -lt '7.0:0:0') {add-Content -path $report -value "class=td_error"}
if ($a.MinPasswordAge -gt '6.0:0:0' -and $a.MaxPasswordAge.days -lt '10') {add-Content -path $report -value "class=td_warning"}
if ($a.MinPasswordAge -gt '9.0:0:0') {add-Content -path $report -value "class=td_ok"}
add-Content -path $report -value ">"
add-Content -path $report -value $a.MinPasswordAge.days
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td class=td_ok>3</td>"
add-Content -path $report -value "</tr>"

add-Content -path $report -value "<tr><td>Reverse crypto</td>"
add-Content -path $report -value "<td>"

$cryp = $a.ReversibleEncryptionEnabled
write-host "Cryptage : " $cryp
#if($cryp="False"){$cryp="Disabled"}
#if($cryp="True"){$cryp="Enabled"}
add-Content -path $report -value $cryp
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td class=td_ok>Disabled</td>"
add-Content -path $report -value "</tr>"


add-Content -path $report -value "</table>"
add-Content -path $report -value "<hr>"
write-host "-> Password policy ok"

#
# PASSWORD POLICY : PSO
#

write-host "---------------"
write-host "PASSWORD POLICY : PSO"
write-host "---------------"

add-Content -path $report -value "<H2>Password Policy : PSO</H2>"
add-Content -path $report -value "<table class=table_main>"
$a = Get-ADFineGrainedPasswordPolicy -Filter *

$psofields = @("Nom","Complexite","Age maximum","Age minimum","Longueur minimum","Cryptage reversible")

add-Content -path $report -value "<tr>"
foreach ($fields in $psofields)
{
add-Content -path $report -value "<th>"
add-Content -path $report -value $fields
add-Content -path $report -value "</th>"
}
add-Content -path $report -value "</tr>"

$psofields = @("Name","ComplexityEnabled","MaxPasswordAge","MinPasswordAge","MinPasswordLength","ReversibleEncryptionEnabled")

add-Content -path $report -value "<tr>"
foreach ($pso in $a) 
{
foreach ($fields in $psofields)
{
add-Content -path $report -value "<td>"
add-Content -path $report -value $pso.$fields
add-Content -path $report -value "</td>"
}
$ctpso = Get-ADFineGrainedPasswordPolicySubject -Identity $pso.name
$ctpso = $ctpso.count
add-Content -path $report -value "<td>"
add-Content -path $report -value $ctpso
add-Content -path $report -value "</td>"

add-Content -path $report -value "</tr>"
}
add-Content -path $report -value "</table>"
add-Content -path $report -value "<hr>"
write-host "-> Password policy ok"

#
# Les controleurs de domaine
#

write-host "--------------------------------"
write-host "Domain controllers"
write-host "--------------------------------"

write-host "DC :"
$dclist
$dclist.count


add-Content -path $report -value "<H2>Domain controllers</H2>"
#$dc=get-addomain
#$a =  $dc.ReplicaDirectoryServers
#$a =  $a + $dc.ReadOnlyReplicaDirectoryServers
#$cnt = $a | measure
$cnt = $dclist.count

add-Content -path $report -value "<table class=table_main>"
add-Content -path $report -value "<tr><td># DC</td>"
add-Content -path $report -value "<td" 
if ($cnt -eq '1') 
{
add-Content -path $report -value "class=td_Error"
$comment = $comment + @("Add at least one domain controller<br>")
}
if ($cnt -gt '1') {add-Content -path $report -value "class=td_OK"}
add-Content -path $report -value ">$cnt</td></tr>"
add-Content -path $report -value "</table><br><br>"
add-Content -path $report -value "<table class=table_main>"
add-Content -path $report -value "<tr><th>Nom</th>"
add-Content -path $report -value "<th>RAM</th>"
add-Content -path $report -value "<th>Adresse IP</th>"
add-Content -path $report -value "<th>Site AD</th>"
add-Content -path $report -value "<th>Correctifs</th>"
add-Content -path $report -value "<th>Syst me d'exploitation</th>"
add-Content -path $report -value "<th>Processeur</th>"
add-Content -path $report -value "<th>Disque</th>"
add-Content -path $report -value "<th>HW Info.</th>"
add-Content -path $report -value "</tr>"

foreach ($srv in $dclist)
{
 $b = Get-ADDomainController -Identity $srv
 $dsk = get-WmiObject win32_logicaldisk -Computername $srv
 add-Content -path $report -value "<tr><td>"
 add-Content -path $report -value $srv
 add-Content -path $report -value "</td>"

 $a = Get-WmiObject -class "Win32_PhysicalMemory" -computername $srv
 $ram = '0'
 foreach ($mem in $a)
 { $totl = [math]::round($mem.Capacity/1024/1024/1024)
   $ram = [int]$ram + $totl }

 add-Content -path $report -value "<td "
 if ($ram -lt '4')
 {
 $serveur = $srv.name
 $comment = $comment + @("Add more memory $serveur : 4 Go min.")
 add-Content -path $report -value "class=td_Error"
 }
 if ($ram -gt '3'){add-Content -path $report -value "class=td_OK"}
 add-Content -path $report -value ">$ram Go</td>"
 add-Content -path $report -value "<td>"
 add-Content -path $report -value $b.ipv4address
 add-Content -path $report -value "</td>"
 add-Content -path $report -value "<td>"
 add-Content -path $report -value $b.site
 add-Content -path $report -value "</td>"
 $c = get-hotfix -computername $srv | measure
 $server = $srv.name
 add-Content -path $report -value "<td "
 if ($c.count -lt '10'){
 $comment = $comment + @("Controller $server is not up to date with patches<br>")
 add-Content -path $report -value "class=td_error"}
 if ($c.count -lt '50' -and $c.count -gt '9'){
 $comment = $comment + @("Controller $server is not up to date with patches<br>")
 add-Content -path $report -value "class=td_warn"}
 if ($c.count -gt '49'){add-Content -path $report -value "class=td_ok"}
 add-Content -path $report -value ">"
 add-Content -path $report -value $c.count 
 add-Content -path $report -value "</td>"
 add-Content -path $report -value "<td "
 if ($b.operatingsystem -like '*2012*'){add-Content -path $report -value "class=td_ok"}
 if ($b.operatingsystem -like '*2008*'){add-Content -path $report -value "class=td_warn"}
 if ($b.operatingsystem -like '*2003*'){add-Content -path $report -value "class=td_Error"}
 add-Content -path $report -value ">"
 add-Content -path $report -value $b.operatingsystem
 add-Content -path $report -value "</td>"
 $proc = Get-WmiObject win32_processor -computername $srv
 add-Content -path $report -value "<td>"
 add-Content -path $report -value $proc.name
 add-Content -path $report -value "</td>"
 add-Content -path $report -value "<td>"
 add-Content -path $report -value "<table class=table_main>"
 add-Content -path $report -value "<tr><th>Lecteur</th>"
 add-Content -path $report -value "<th>Taille</th>"
 add-Content -path $report -value "<th>Libre</th>"
 add-Content -path $report -value "<th>% Libre</th></tr>"

 foreach ($disks in $dsk)
 {
  IF ($disks.drivetype -eq 3)
  {
   $id = $disks.deviceID
   $free = [math]::round($disks.FreeSpace/1024/1024/1024)
   $totl = [math]::round($disks.Size/1024/1024/1024)
   $percent = [math]::round($free * 100 / $totl)
   add-Content -path $report -value "<tr>"
   add-Content -path $report -value "<td>"
   add-Content -path $report -value $id
   add-Content -path $report -value "</td>"
   add-Content -path $report -value "<td "
   if ($totl -lt '51' -and $totl -gt '20'){add-Content -path $report -value "class=td_Warn"}
   if ($totl -lt '21'){add-Content -path $report -value "class=td_Error"}
   if ($totl -gt '50'){add-Content -path $report -value "class=td_OK"}
   add-Content -path $report -value ">"
   add-Content -path $report -value "$totl Go</td>"
   add-Content -path $report -value "<td "
   if ($free -lt '21' -and $free -gt '9') {add-Content -path $report -value "class=td_Warn"}
   if ($free -lt '10') {add-Content -path $report -value "class=td_Error"}
   if ($free -gt '20') {add-Content -path $report -value "class=td_OK"}
   add-Content -path $report -value ">"
   add-Content -path $report -value $free
   add-Content -path $report -value " Go"
   add-Content -path $report -value "</td>"
   add-Content -path $report -value "<td "
   if ($percent -lt '51' -and $percent -gt '20'){add-Content -path $report -value "class=td_Warn"}
   if ($percent -lt '21'){add-Content -path $report -value "class=td_Error"}
   if ($percent -gt '50'){add-Content -path $report -value "class=td_OK"}
   add-Content -path $report -value ">"
  add-Content -path $report -value $percent
  add-Content -path $report -value " %</td>"
 }
  add-Content -path $report -value "</tr>"
}
add-Content -path $report -value "</td>" 
add-Content -path $report -value "</table>"

#
# HW INFO
#

add-Content -path $report -value "<td>"
add-Content -path $report -value "<table class=table_main>"
$a = Get-WmiObject win32_computersystem -computername $srv
add-Content -path $report -value "<tr><td class=table_main_td3>Fabricant</td><td>"
add-Content -path $report -value $a.Manufacturer
add-Content -path $report -value "</td></tr>"
add-Content -path $report -value "<tr><td class=table_main_td3>Mod le</td><td>"
add-Content -path $report -value $a.Model
add-Content -path $report -value "</td></tr>"
$a = Get-WmiObject win32_bios -computername $srv
add-Content -path $report -value "<tr><td class=table_main_td3>Num ro de s rie</td><td>"
add-Content -path $report -value $a.SerialNumber
add-Content -path $report -value "</td></tr></table></td>"
}
add-Content -path $report -value "</table>"
add-Content -path $report -value "<hr>"
write-host "-> Controleurs de domaine ok"
  
#
# SERVERS INFORMATIONS
#
  
write-host "--------------------------------"
write-host "HW INFO"
write-host "--------------------------------"


# sysdir

$a = Get-CimInstance Win32_OperatingSystem
$sysdir = $a.SystemDirectory

write-host "SRV : " $domcont
add-Content -path $report -value "<H2>Information: DC</H2>"
add-Content -path $report -value "<table class=table_main>"
$a =  Get-ADGroupMember $domcont
$gc = get-adforest
add-Content -path $report -value "<tr><th>Name</th>"
add-Content -path $report -value "<th>Firewall</th>"
add-Content -path $report -value "<th>Uptime</th>"
add-Content -path $report -value "<th>Services<p>d marr s</th>"
add-Content -path $report -value "<th>Shared Folders</th>"
add-Content -path $report -value "<th>Mode<p>core</th>"
add-Content -path $report -value "<th>Language</th>"
add-Content -path $report -value "<th>NTP</th>"
add-Content -path $report -value "<th>Free<p>Memory</th>"
add-Content -path $report -value "<th>GC</th></tr>"
foreach ($members in $dclist)
{
write-host "DC : " $members

$fw = Get-Service -Name "MpsSvc" -ComputerName $members
if ($fw.status -eq "Running")
{$fire = Get-NetFirewallProfile -Name domain -CimSession $members
$fire = $fire.enabled}
else
{$fire = "svc disabled"}

# UPTIME
$uptime = Get-WmiObject win32_operatingsystem -ComputerName $members | select csname, @{LABEL='LastBootUpTime' ;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
$jour = get-date
$b = $jour - $uptime.LastBootUpTime
$upt = $b.days
# RUNNING SERVICES
$service = Get-Service -ComputerName $members | where {$_.status -eq "running"}
$share = Get-WmiObject -Class win32_share -ComputerName $members
# CORE
$co1 = get-windowsfeature -ComputerName $members | Where-Object {$_.Name -eq 'Server-Gui-Mgmt-Infra'}
$co1 = $co1.installstate
if ($co1 -eq "Installed") {$core = "No"}
if ($co1 -ne "Installed") {$core = 'Yes'}
write-host "core " $members $core
# LANG
$lng = get-wmiobject win32_OperatingSystem -property OSLanguage -ComputerName $members
if ($lng.OSLanguage -eq 1033) {$lang="English"}
if ($lng.OSLanguage -eq 1036) {$lang="French"}
# TIME SOURCE
$reg=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$members)
$regkey = $reg.OpenSubKey("SYSTEM\CurrentControlSet\Services\W32Time\Parameters")
$ntp = $regKey.GetValue("NtpServer")
# FREE MEM
$free = Get-WmiObject Win32_OperatingSystem -ComputerName $members
$free = [math]::round($free.FreePhysicalMemory/1024)
# GC
$cat = "Non"
foreach ($glob in $gc.globalcatalogs)
{
$lf = $glob.Indexof('.')
$c = $glob.substring(0,$lf)
if ($members -eq $c)
{$cat = "Oui"}
} 
add-Content -path $report -value "<tr>"
add-Content -path $report -value "<td>"
add-Content -path $report -value $members
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td>"
add-Content -path $report -value $fire
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td>"
add-Content -path $report -value $upt
add-Content -path $report -value " jours</td>"
add-Content -path $report -value "<td>"
add-Content -path $report -value $service.count
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td>"
add-Content -path $report -value $share.count
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td>"
add-Content -path $report -value $core
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td>$lang</td>" 
add-Content -path $report -value "<td>$ntp</td>"
add-Content -path $report -value "<td>$free Mo</td>"
add-Content -path $report -value "<td>$cat</td></tr>"
}

add-Content -path $report -value "</table>"
add-Content -path $report -value "<hr>"

#
# DNS
#

add-Content -path $report -value "<H2>DNS Configuration</H2>"
add-Content -path $report -value "<table class=table_main>"
add-Content -path $report -value "<tr><th>Zone</th>"
add-Content -path $report -value "<th>Cleaning Zone</th>"
add-Content -path $report -value "<th>Zone Type</th></tr>"
$a = Get-DnsServerZone | Where-Object {$_.zonename -ne "TrustAnchors" -and $_.IsAutoCreated -eq $False -and $_.zonename -notlike "*msdcs*" -and $_.zoneType -eq "Primary" }
foreach ($zone in $a)
{
$b = Get-DnsServerZoneAging -name $zone.zoneName
add-Content -path $report -value "<tr>"
add-Content -path $report -value "<td>"
add-Content -path $report -value $zone.zoneName
add-Content -path $report -value "</td>"
if ($b.AgingEnabled -eq $true) {$clean = "<td class=td_OK>Oui"}
if ($b.AgingEnabled -eq $false) {$clean = "<td class=td_warn>Non"}
add-Content -path $report -value $clean
add-Content -path $report -value "</td>"
add-Content -path $report -value "<td>"
add-Content -path $report -value $zone.zoneType
add-Content -path $report -value "</td>"
add-Content -path $report -value "</tr>"
}
$a = Get-DnsServerZone | Where-Object {$_.zonename -ne "TrustAnchors" -and $_.IsAutoCreated -eq $False -and $_.zonename -notlike "*msdcs*"}
foreach ($zone in $a)
{write-host "Direct Search : " $zone.zonename}
$a = Get-DnsServerZone
foreach ($zone in $a)
{
$b = Get-DnsServerZone $zone.ZoneName
if ($b.IsReverseLookupZone -eq $true -and $b.zonename -ne "0.in-addr.arpa" -and $b.zonename -ne "127.in-addr.arpa" -and $b.zonename -ne "255.in-addr.arpa" -and $b.IsReverseLookupZone -ne $true )
{write-host "Reverse search:" $b.zonename}
}
add-Content -path $report -value "</table>"
add-Content -path $report -value "<hr>"

#
# COMMENTS
#

add-Content -path $report -value "<H2>Comments</H2>"
add-Content -path $report -value "<table class=table_fin>"
foreach ($a in $comment) {add-Content -path $report -value "<tr><td>$a</td></tr>"}
add-Content -path $report -value "</table>"
add-Content -path $report -value "<br>"
add-Content -path $report -value "<br>"
add-Content -path $report -value "<hr>"
add-Content -path $report -value $HTMLfin
add-Content -path $report -value $HTMLEnding

