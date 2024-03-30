# GD4-Prototype
I intend for this to be a movement shooter with Celeste-like dashing & movement

## How to run this project
### Prerequisites:
An operating system and CPU Architecture (AMD & ARM) supporting [Godot 4.2](https://github.com/godotengine/godot/releases/tag/4.2-stable)  (Linux, Windows, Android, MacOS, [*BSD + UNIX](https://docs.godotengine.org/en/latest/contributing/development/compiling/compiling_for_linuxbsd.html), or the [Web Editor](https://editor.godotengine.org/releases/4.2.stable/)) and Godot 4.2

if you're a weirdo and not on any of those operating systems. [Compile from source](https://docs.godotengine.org/en/latest/contributing/development/compiling/index.html)

execute in a terminal  
``` sh
git clone https://github.com/fortunef/GD4-Prototype.git
cd GD4-Prototype
godot project.godot # omit if you have Godot installed on flatpak or steam
```

if that doesn't work install git (or just download zip extract that and run it)

# How to install Git on most operating systems (Skip if already installed)

### !! MOST OF THE LINUX DISTROS HERE HAVE GIT PREINSTALLED CHECK BY TYPING "git" INTO A TERMINAL !!

https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

on Debian and Debian-based systems (Ubuntu, SteamOS 2.x, Pop!_OS, VanillaOS etc)
``` sh
apt install git-all
```
on RHEL and RHEL-based systems (CentOS, Fedora, etc)
``` sh
dnf install git-all
```
on Arch and Arch based systems (Artix, EndeavourOS, ALARM, SteamOS 3.x)
``` sh 
pacman -S git
```
winget (Windows)
``` powershell
winget install --id Git.Git -e --source winget
```
Gentoo and Gentoo-based systems (Funtoo, Calculate Linux, Macaroni Linux, Xenia Linux, etc)

setup USEFLAGS according to [the wiki](https://wiki.gentoo.org/wiki/Git) if you want an optimised package
``` sh
emerge git
```

# How to launch

Launch Godot 4.2 click import and select the project.godot file

# Personal Checklist in order of priority & completion
- [x] Simple Raycasting Shooting
- [x] Reloading
- [ ] Enemy AI
- [ ] Enemy Knockback
- [ ] Rogue-like Mechanics
- [ ] A movement system I like (getting closer to that goal)
- [ ] Weapon Switching System like the one in Half Life
- [ ] Visual and actual recoil
- [ ] HUD
- [ ] Art
- [ ] Gore System

# License
GD4-Prototype is licensed under the [GNU General Public License v3.0](https://github.com/fortunef/GD4-Prototype/blob/main/LICENSE) this license allows anyone to copy, modify and distribute this software in verbatim or in modified form, but with absolutely **ZERO** warranty. More info on the License can be found at the [GNU Official Website](https://www.gnu.org/licenses/gpl-3.0.en.html)
