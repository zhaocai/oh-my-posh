oh-my-posh
==========

[![Build status](https://img.shields.io/appveyor/ci/janjoris/oh-my-posh/master.svg?maxAge=2592000)](https://ci.appveyor.com/project/JanJoris/oh-my-posh) [![Gitter](https://badges.gitter.im/oh-my-posh/Lobby.svg)](https://gitter.im/oh-my-posh/general?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)


> If you are migrating from PS-Agnoster to oh-my-posh, remove everything and [reinstall](#installation)

## Table of Contents

* [About](#about)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Configuration](#configuration)
* [Helper functions](#helper)
* [Themes](#themes)

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

### [posh-with](https://github.com/JanJoris/posh-with) prompt indication

<img src="https://herebedragons.io/wp-content/uploads/2016/08/with.png" width="800">

<div id='prerequisites'/>
<details>
<summary>Prerequisites</summary>

You should use ConEmu to have a brilliant terminal experience on Windows. You can install it using [Chocolatey](https://chocolatey.org/) :

```bash
choco install ConEmu
```

The fonts I use are Powerline fonts, there is a great [repository](https://github.com/powerline/fonts) containing them and a .ps1 file to install.
Or, could absuse [PsGet](http://psget.net/) and install them:

```bash
Install-Module -ModuleUrl https://github.com/powerline/fonts/archive/master.zip
```

I use `Meslo LG M for Powerline` in my ConEmu setup together with custom colors You can find my theme [here](https://gist.github.com/JanJoris/71c9f1361a562f337b855b75d7bbfd28).

</details>

<div id='installation'/>
<details>
<summary>Installation</summary>

### PsGet

Use [PsGet](http://psget.net/) to install oh-my-posh:

```bash
Install-Module oh-my-posh
```

### PowerShell Gallery

Use the Powershell Gallery to install posh-git and oh-my-posh:

```bash
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
```

</details>

<div id='configuration'/>
<details>
<summary>Configuration</summary>

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

Also do not forget the Posh-Git settings itself (enable the stash indication for example):

```bash
$GitPromptSettings
```

</details>

<div id='helper'/>
<details>
<summary>Helper functions</summary>

`Set-Theme`:  set a theme from the Themes directory. If no match is found, it will not be changed.

```bash
Set-Theme -theme 'paradox'
```

`Show-ThemeColors`: display the colors used by the theme

<img src="https://herebedragons.io/wp-content/uploads/2016/06/themecolors.png" width="800">

`Show-Colors`: display colors configured in ConEmu

<img src="https://herebedragons.io/wp-content/uploads/2016/06/colors.png" width="800">

`Show-Themes`: list available themes

<img src="https://herebedragons.io/wp-content/uploads/2016/06/themes.png" width="800">

</details>

<div id='themes'/>
<details>
<summary>Themes</summary>

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

### Honukai

<img src="https://herebedragons.io/wp-content/uploads/2016/07/honukai.png" width="800">

### Fish

<img src="https://herebedragons.io/wp-content/uploads/2016/07/fish.png" width="800">

<div id='owntheme'/>
Creating your own theme
-----------------------

If you want to create a theme it can be done rather easily by adding a `mytheme.psm1` file in the Themes folder (replace `mytheme` with your own, awesome theme name).
The only required function is Write-Theme, you can use the following template to get started:

````bash
#requires -Version 2 -Modules posh-git

. "$PSScriptRoot\Tools.ps1"

function Write-Theme
{
    param(
        [bool]
        $lastCommandFailed
    )

    # enter your prompt building logic here
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

</details>

### Based on work by

* [Chris Benti](https://github.com/chrisbenti/PS-Config)
* [Keith Dahlby](https://github.com/dahlbyk/posh-git)
