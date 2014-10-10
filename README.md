Password Expire Email
=====================

This is a PowerShell script to email users that their password is about to expire. It also includes a debug mode to send a full parameter list and list of users pending password expiration to another email address.

## Parameters:

Name                  | Description   | Default Value | Required
--------------------- | ------------- | ------------- | :--------:
**ADGroup**           | The active directory group that contains users to check against. | *PasswordExpireEmailNotification* |
**SmtpServer**        | The email server address. This can be an IP address or a computer name. | | **X**
**EmailDomain**       | The email domain name (e.g. *github.com*). | | **X**
**EmailFrom**         | Sender email address. | *donotreply@`$EmailDomain`* |
**SupportUserName**   | Username portion of the SupportEmail parameter. | *support* |
**SupportEmail**      | Full email address where users can receive additional support. | *`$SupportUserName`@`$EmailDomain`* |
**WebMail**           | Website address, without scheme, for email portal. | *mymail.`$EmailDomain`* |
**WebMailURL**        | Full website address, with scheme, for email portal. | *http://`$WebMail`* |
**ExpireWarningDays** | Days left for a password to expire in order to send an email. | *(15,10,5,4,3,2,1)* |
**SendEmail**         | True or false. Setting to false disables sending emails to users. | *$true* |
**DebugEmailTo**      | Email to send debug report to. Setting this value enables debugging. | |

## Usage

This script will search Active Directory and find any members of the group defined in `ADGroup`. It will then
iterate through the members that it found and check their password expiration time. It will skip any users
who are not enabled, passwords never expire, and password have already expired.

Any users who's password is about to expire within the days set in `ExpireWarningDays` will receive an email
that their password is going to expire, with the number of days before it expires. The email will also
contain detailed instructions on how to change their password.

## Prerequisites

The following components are required to run this script:

* Microsoft .NET Framework 4.5 or better: [http://www.microsoft.com/en-us/download/details.aspx?id=30653](http://www.microsoft.com/en-us/download/details.aspx?id=30653)
* Active Directory module for PowerShell
    * From PowerShell, run: `Add-WindowsFeature RSAT-AD-PowerShell`

## Running the script

You must define `SmtpServer` and `EmailDomain` for the script to run. The other parameters are optional.
Here is an example of how to run the script and what the parameter values will be.

    .\PasswordExpireEmail.ps1 -SmtpServer 192.168.0.1 -EmailDomain mydomain.com

The code above will produce the following parameter values:

Parameter             | Value
--------------------- | -------------
**ADGroup**           | PasswordExpireEmailNotification
**SmtpServer**        | 192.168.0.1
**EmailDomain**       | mydomain.com
**EmailFrom**         | donotreply@mydomain.com
**SupportUserName**   | support
**SupportEmail**      | support@mydomain.com
**WebMail**           | mymail.mydomain.com
**WebMailURL**        | http://mymail.mydomain.com
**ExpireWarningDays** | 15,10,5,4,3,2,1
**SendEmail**         | True
**DebugEmailTo**      |

## ADGroup

This is the Active Directory group used to search for users who should receive password expiration notices.

Change using the following:

    .\PasswordExpireEmail.ps1 -SmtpServer 192.168.0.1 -EmailDomain mydomain.com -ADGroup PassExpireAlert

## SmtpServer

This parameter is required. It sets the server address or name to send emails from.
Please see **Running the script** for a usage example.

## EmailDomain

This parameter is required. Please see **Running the script** for a usage example.
`EmailDomain` sets the domain to use for the following parameters:

* `EmailFrom`
* `SupportEmail`
* `WebMail`

You are allowed to override each of the above parameters, see sections for each below.

## EmailFrom

This parameter sets the email address of the sender for each notification email sent.
You can override this by using the following code:

    .\PasswordExpireEmail.ps1 -SmtpServer 192.168.0.1 -EmailDomain mydomain.com -EmailFrom noreply@domain.com

## SupportUserName and SupportEmail

These two parameters are used to define who users can email back for additional support. You can
change `SupportUserName`, which will use the `EmailDomain` for the full email address. Alternatively, you
can override the full email address with `SupportEmail`.

The following:

    .\PasswordExpireEmail.ps1 -SmtpServer 192.168.0.1 -EmailDomain mydomain.com -SupportUserName helpdesk

Will define `SupportEmail` as *helpdesk@mydomain.com*

The following:

    .\PasswordExpireEmail.ps1 -SmtpServer 192.168.0.1 -EmailDomain mydomain.com -SupportEmail helpdesk@support.org

Will define `SupportEmail` as *helpdesk@support.org*

## WebMail and WebMailURL

These parameters define the email portal website address. Changing just `WebMail` will set the URI Scheme
to *http*. If you need to define a URI Scheme of something else, such as *https* then change `WebMailURL`.

The following:

    .\PasswordExpireEmail.ps1 -SmtpServer 192.168.0.1 -EmailDomain mydomain.com -WebMail mail.domain.com

Will define `WebMailURL` as *http://mail.domain.com*

The following:

    .\PasswordExpireEmail.ps1 -SmtpServer 192.168.0.1 -EmailDomain mydomain.com -WebMailURL https://mail.domain.com

Will define `WebMailURL` as *https://mail.domain.com*

## ExpireWarningDays

This is an array of numbers. This parameter informs the script when to email a user that their password is
going to expire. Basically, if a users password has X number of days before it expires and the number X is
included in this list then send the user an email notification.

If you want to only email users 5 days in advance, and each day after, then use the following script:

    .\PasswordExpireEmail.ps1 -SmtpServer 192.168.0.1 -EmailDomain mydomain.com -ExpireWarningDays 5,4,3,2,1

## SendEmail

Setting the `SendEmail` parameter to false will disable sending individual emails to each user. This is useful
if you are debugging he script.

    .\PasswordExpireEmail.ps1 -SmtpServer 192.168.0.1 -EmailDomain mydomain.com -SendEmail $False

Or

    .\PasswordExpireEmail.ps1 -SmtpServer 192.168.0.1 -EmailDomain mydomain.com -SendEmail 0

## DebugEmailTo

Setting the `DebugEmailTo` parameter value will enable Debugging within the script. This will send an email
to `DebugEmailTo` with all of the parameter values and a list of users and when their password will expire.

    .\PasswordExpireEmail.ps1 -SmtpServer 192.168.0.1 -EmailDomain mydomain.com -DebugEmailTo address@domain.com
