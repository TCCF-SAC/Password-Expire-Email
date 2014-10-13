Param (
    # Active Directory group to look at
    [string]$ADGroup = "PasswordExpireEmailNotification",
    # Email SMTP Server
    [string]$SmtpServer = "",
    [string]$EmailDomain = "",
    # Email sender
    [string]$EmailFrom = "donotreply@$EmailDomain",
    # Email for support (username)
    [string]$SupportUserName = "support",
    # Email for support
    [string]$SupportEmail = "$SupportUserName@$EmailDomain",
    # Webmail address
    [string]$WebMail = "mymail.$EmailDomain",
    # Webmail URL
    [string]$WebMailURL = "http://$WebMail",
    # Warning peroids
    [array]$ExpireWarningDays = (15,10,5,4,3,2,1),
    # Send Email - true means the email will be sent to users
    [bool]$SendEmail = $true,
    # Debugging stuff:
    [string]$DebugEmailTo = ""
)

# SmtpServer and EmailDomain are required
if ($SmtpServer -eq "" -or $EmailDomain -eq "") { exit 0; }

$crlf = "`r`n";
$DebugMessage = "";

# Disable debugging if Debug Email To was not set.
$Debugging = ($DebugEmailTo -ne "");

Import-Module ActiveDirectory
$users = Get-ADGroupMember $ADGroup -Recursive |
            Get-ADUser -properties Name, SamAccountName, EmailAddress, PasswordLastSet, PasswordNeverExpires, PasswordExpired |
            Where {$_.Enabled -eq "True"} | Where { $_.PasswordNeverExpires -eq $false } | Where { $_.PasswordExpired -eq $false }

# Default AD Policy for maximum password age.
$ADPasswordPolicyAge = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge;

foreach ($user in $users)
{
    # Set user variables
    $Name = $user.Name;
    $UserName = $user.SamAccountName;
    $UserEmail = $user.EmailAddress;
    $PasswordLastSet = $user.PasswordLastSet;

    # Check for Fine Grained Password policy
    $FG_PasswordPolicy = (Get-AduserResultantPasswordPolicy $UserName)
    if ($FG_PasswordPolicy -ne $null)
    {
        $MaxPasswordAge = ($FG_PasswordPolicy).MaxPasswordAge;
    } else {
        $MaxPasswordAge = $ADPasswordPolicyAge;
    }

    # Find out when the password expires and in how many days
    $ExpiresOn = $PasswordLastSet + $MaxPasswordAge;
    $Today = (Get-Date);
    $DaysToExpire = (New-TimeSpan -Start $Today -End $ExpiresOn).Days;

    # Does our ExpireWarningDays contain the value from DaysToExpire?
    if ($ExpireWarningDays.Contains($DaysToExpire))
    {
        # Format the 'expire in X day(s)' message first.
        $MessageDays = $DaysToExpire;
        if ($DaysToExpire -gt "1")
        {
            $MessageDays = "in $DaysToExpire days";
        } else {
            $MessageDays = "today";
        }

        #DEBUG
        if ($Debugging -eq $true)
        {
            $DebugMessage += "        $Name [$UserName] password expires $MessageDays.`n";
            #Write-Output "$Name [$UserName] password expires $MessageDays.`n";
        }

        if ($SendEmail -eq $true)
        {
            # Create the subject
            $Subject = "SUPPORT: Your password will expire $MessageDays.";

            # Generate the email.
            $WarnMsg = "
            <div style='font-family:Verdana'>
                <p>Hi $Name,</p>
                <p>Your login password will expire $MessageDays. Please follow the steps below to change your password.</p>
                <p>You can change your password from Remote Desktop:</p>
                <ol>
                    <li>Start</li>
                    <li>Windows Security</li>
                    <li>Change a Password</li>
                </ol>
                <p>Or you can change your password from Outlook Web App:</p>
                <ol>
                    <li>Using an internet Browser connect to <a href='$WebMailURL'>$WebMailURL</a></li>
                    <li>Click on the Settings Icon in the upper right hand corner which looks like a gear.</li>
                    <li>Change Password</li>
                </ol>
                <p>Keep in mind:</p>
                <ul>
                    <li>Usernames are not case sensitive</li>
                    <li>Passwords are case sensitive</li>
                    <li>Passwords must be 6 characters long</li>
                    <li>Passwords cannot contain any part of your name</li>
                    <li>You cannot use any previously used passwords</li>
                    <li>Passwords will expire after 90 days</li>
                    <li>Passwords must contain 3 of the 4 categories:
                        <ul>
                            <li>Upper Case</li>
                            <li>Lower Case</li>
                            <li>Numbers</li>
                            <li>Special Characters: $ & % @ ! *</li>
                        </ul>
                    </li>
                </ul>
                <p>As a reminder, please also change your password on any DOMAIN connected mobile devices, such as a cell phone or tablet.</p>
                <p>For any assistance, please email <a href='mailto:$($SupportEmail)?subject=Change Password Assistance'>$SupportEmail</a>.</p>
            </div>
            ";

            # For Production
            Send-MailMessage -from $EmailFrom -to $UserEmail -subject $Subject -body $WarnMsg -SmtpServer $SmtpServer -bodyasHTML -priority High
        }
    }
}

#Debugging
if ($Debugging -eq $true -and $DebugMessage -ne "")
{
    # Append params to the top of the email.
    $DebugMessage = "Users:" + $crlf + $crlf +
        $DebugMessage + $crlf + $crlf +
        "Parameters:$crlf
        ADGroup = $ADGroup
        SmtpServer = $SmtpServer
        EmailDomain = $EmailDomain
        EmailFrom = $EmailFrom
        SupportUserName = $SupportUserName
        SupportEmail = $SupportEmail
        WebMail = $WebMail
        WebMailURL = $WebMailURL
        ExpireWarningDays = $ExpireWarningDays
        SendEmail = $SendEmail
        DebugEmailTo = $DebugEmailTo";

    $Subject = "DEBUG: PasswordExpireEmail for $EmailDomain";

    # Debug with emailing out
    Send-MailMessage -from $EmailFrom -to $DebugEmailTo -subject $Subject -body $DebugMessage -SmtpServer $SmtpServer

    # Debug without emailing out
    #Write-Output $DebugMessage
    #Write-Output $DebugMessage | Out-File c:\scripts\test.txt
}
