PS-Agnoster
===========

<img src="http://herebedragons.io/wp-content/uploads/2016/03/PS-Agnoster.png" width="300">

A set of PowerShell scripts which provide super fancy Git/PowerShell integration
It uses Posh-Git under the hood to get things done and was inspired by the done by Chris Benti on [PS-Config](https://github.com/chrisbenti/PS-Config).
The downside of PS-Config is that it does not pay nicely with regular Powerline fonts I use on my Linux Vagrant boxes.
This causes it to not have the correct symbols to visualize the paths in either Linux or Windows depending on the font u use.

Fixes and improvements:
* Powerline fonts work out of the boxes
* Git status indications in the Agnoster theme
* Configurable
* Separate settings for PS-Agnoster and Posh-Git

Prerequisites
-------------

Make sure you have Posh-Git installed. I do this using [PsGet](http://psget.net/) :

```
Install-Module posh-git
```

You should use ConEmu to have a brilliant Terminal experience on Windows. You can install it using [Chocolatey](https://chocolatey.org/) :

```
choco install ConEmu
```

The fonts I use are Powerline fonts, there is a great [repository](https://github.com/powerline/fonts) containing them and a ps1 file to install.
I use `Meslo LG M for Powerline` in my ConEmu setup together with custom colors.

Installing
----------

Adjust your `Microsoft.PowerShell_profile.ps1` file to include both Posh-Git and PS-Agnoster
Make sure the Posh-Git module is sourced before you source PS-Agnoster.
This example assumes the location of PS-Agnoster is in my Github folder, adjust to your needs.

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

<img src="http://herebedragons.io/wp-content/uploads/2016/03/AgnosterPromptSettings.png" width="300">

You can tweak the colors and symbols being used by manipulating the `$AgnosterPromptSettings`.
This example allows you to tweak the branch symbol:

````
$AgnosterPromptSettings.GitBranchSymbol = [char]::ConvertFromUtf32(0xE0A0)
````

Also do not forget the Posh-Git settings itself:

````
$GitPromptSettings
````

### Based on work by:

 - Chris Benti, https://github.com/chrisbenti
