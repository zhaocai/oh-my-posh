oh-my-posh
==========

> If you are migrating from PS-Agnoster to oh-my-posh, remove everything and install using [PsGet](#installation)

## Table of Contents

* [About](#about)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Configuration](#configuration)
* [Helper functions](#helper)
* [Themes](#themes)
* [Creating your own theme](#owntheme)

<div id='about'/>
About
-----

A theme engine for Powershell in ConEmu inspired by the work done by Chris Benti on [PS-Config](https://github.com/chrisbenti/PS-Config). And [Oh-My-ZSH](https://github.com/robbyrussell/oh-my-zsh) on OSX and Linux (hence the name)
More information about why I made this can be found on my [blog](https://herebedragons.io/shell-shock/).

Features:

* Easy installation
* Awesome prompt themes for PowerShell in ConEmu
* Git status indications
* Current session indications (admin, failed command, user)
* Includes awesome PowerShell modules
* Configurable
* Easily create your own theme
* Separate settings for oh-my-posh and posh-git
* Does not mess with the default Powershell console

### Git integration

<img src="https://herebedragons.io/wp-content/uploads/2016/06/paradox.png" width="800">

### Failed command indication

<img src="https://herebedragons.io/wp-content/uploads/2016/06/failed_command.png" width="800">

### Admin prompt indication

<img src="https://herebedragons.io/wp-content/uploads/2016/06/admin_prompt.png" width="800">

<div id='prerequisites'/>
Prerequisites
-------------

You should use ConEmu to have a brilliant terminal experience on Windows. You can install it using [Chocolatey](https://chocolatey.org/) :

```bash
choco install ConEmu
```

The fonts I use are Powerline fonts, there is a great [repository](https://github.com/powerline/fonts) containing them and a .ps1 file to install.
Or, could absuse [PsGet](http://psget.net/) and install them:

```bash
Install-Module -ModuleUrl https://github.com/powerline/fonts/archive/master.zip
```

I use `Meslo LG M for Powerline` in my ConEmu setup together with custom colors You can find my configuration [here](https://gist.github.com/JanJoris/71c9f1361a562f337b855b75d7bbfd28).

<div id='installation'/>
Installation
------------

Use [PsGet](http://psget.net/) to install oh-my-posh straight from this repository:

```bash
Install-Module -ModuleUrl https://github.com/JanJoris/oh-my-posh/archive/master.zip
```

<div id='configuration'/>
Configuration
-------------

List the current configuration:

```bash
$ThemeSettings
```

<img src="https://herebedragons.io/wp-content/uploads/2016/06/ThemeSettings.png" width="800">

You can tweak the settings by manipulating `$ThemeSettings`.
This example allows you to tweak the branch symbol using a unicode character:

````bash
$ThemeSettings.GitBranchSymbol = [char]::ConvertFromUtf32(0xE0A0)
````

If you want to change the theme, adjust theme by selecting a theme from the Themes directory. If no match is found, it will default back to Agnoster.

```bash
$ThemeSettings.Theme = 'paradox'
```

Also do not forget the Posh-Git settings itself (enable the stash indication for example):

```bash
$GitPromptSettings
```

<div id='helper'/>
Helper functions
----------------

`Show-ThemeColors`: display the colors used by the theme

<img src="https://herebedragons.io/wp-content/uploads/2016/06/themecolors.png" width="800">

`Show-Colors`: display colors configured in ConEmu

<img src="https://herebedragons.io/wp-content/uploads/2016/06/colors.png" width="800">

`Show-Themes`: list available themes

<img src="https://herebedragons.io/wp-content/uploads/2016/06/themes.png" width="800">

<div id='themes'/>
Themes
------

### Agnoster

<img src="https://herebedragons.io/wp-content/uploads/2016/06/agnoster.png" width="800">

### Paradox

<img src="https://herebedragons.io/wp-content/uploads/2016/06/paradox.png" width="800">

### Sorin

<img src="https://herebedragons.io/wp-content/uploads/2016/06/sorin.png" width="800">

### Darkblood

<img src="https://herebedragons.io/wp-content/uploads/2016/06/darkblood.png" width="800">

### Avit

<img src="https://herebedragons.io/wp-content/uploads/2016/06/avit.png" width="800">

<div id='owntheme'/>
Creating your own theme
-----------------------

If you want to create a theme it can be done rather easily by adding a `mytheme.ps1` file in the Themes folder (replace `mytheme` with your own, awesome theme name).
The only required function is Write-Theme, you can use the following template to get started:

````bash
#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Tools.ps1"

function Write-Theme
{
    //enter you prompt building logic here
}

$sl = $global:ThemeSettings #local settings
````

Feel free to use the helper functions in `Tools.ps1` or add your own logic completely.
To test the output in ConEmu, just switch to your theme:

```bash
$ThemeSettings.Theme = 'mytheme'
```

If you want to include your theme in oh-my-posh, send me a PR and I'll try to give feedback ASAP.

Happy theming!

### Based on work by

* Chris Benti, https://github.com/chrisbenti
