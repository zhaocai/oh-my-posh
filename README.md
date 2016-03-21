PS-Agnoster
===========

An Agnoster theme for Powershell inspired by the work done by Chris Benti on [PS-Config](https://github.com/chrisbenti/PS-Config).
The downside of PS-Config is that it does not play nicely with the regular Powerline fonts I use on my Linux Vagrant boxes.
This causes it to not have the correct symbols to visualize the paths in either Linux or Windows depending on the font you use.

Tweaks and improvements:
* Powerline fonts work out of the box
* Git status indications in the Agnoster theme
* Current session indications (admin, failed commmand, user)
* Configurable
* Separate settings for PS-Agnoster and Posh-Git

#### Git integration
<img src="http://herebedragons.io/wp-content/uploads/2016/03/agnoster_git.png" width="600">

#### Failed command indication
<img src="http://herebedragons.io/wp-content/uploads/2016/03/agnoster_failed.png" width="600">

#### Admin prompt indication
<img src="http://herebedragons.io/wp-content/uploads/2016/03/agnoster_admin.png" width="400">

Prerequisites
-------------

Make sure you have Posh-Git installed. I do this using [PsGet](http://psget.net/) :

```
Install-Module posh-git
```

You should use ConEmu to have a brilliant terminal experience on Windows. You can install it using [Chocolatey](https://chocolatey.org/) :

```
choco install ConEmu
```

The fonts I use are Powerline fonts, there is a great [repository](https://github.com/powerline/fonts) containing them and a .ps1 file to install.
I use `Meslo LG M for Powerline` in my ConEmu setup together with custom colors You can find my configuration [here](https://gist.github.com/JanJoris/e22a5fa034caa84dd5cb).

Installing
----------

Adjust your `Microsoft.PowerShell_profile.ps1` file to include both Posh-Git and PS-Agnoster
Make sure the Posh-Git module is sourced before you source PS-Agnoster.
This example assumes the location of PS-Agnoster is in the Github folder, adjust to your needs.

```
Import-Module -Name posh-git -ErrorAction SilentlyContinue
. "$env:USERPROFILE\Github\PS-Agnoster\PS-Agnoster.ps1"
```

Configuration
-------------

List the current configuration:

````
$AgnosterPromptSettings
````

<img src="http://herebedragons.io/wp-content/uploads/2016/03/agnosterpromptsettings.png" width="450">

You can tweak the colors and symbols being used by manipulating `$AgnosterPromptSettings`.
This example allows you to tweak the branch symbol using a unicode character:

````
$AgnosterPromptSettings.GitBranchSymbol = [char]::ConvertFromUtf32(0xE0A0)
````

If you want to display the current configured colors you can list them using the helper method `Agnoster-Colors`

<img src="http://herebedragons.io/wp-content/uploads/2016/03/agnoster_colors.png" width="400">

Also do not forget the Posh-Git settings itself (enable the stash indication for example):

````
$GitPromptSettings
````

### Based on work by:

 - Chris Benti, https://github.com/chrisbenti
