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

TODO
