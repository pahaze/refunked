# Friday Night Funkin' ReFunked

[![CodeFactor](https://www.codefactor.io/repository/github/pahaze/refunked/badge/master)](https://www.codefactor.io/repository/github/pahaze/refunked/overview/master) 

This is the repository for the "ReFunked" engine of Friday Night Funkin', an open source rhythm game. The engine was created to attempt to stomp out bugs and make the open source game better as much as possible. Note: MODS MUST BE OPEN SOURCE WHEN USING THE ENGINE. NO EXCEPTIONS. 

## Credits

- [pahaze (me)](https://github.com/pahaze) - Programmer
- [CryptoCANINE](https://github.com/CryptoCANINE) - Programmer
- OG devs (ninjamuffin99, PhantomArcade3K, evilsk8r, and Kawai Sprite)

\- and any other contributors

## Plans

Things that are planned to be added include:

 - Options (Downscroll, botplay, keybindings, FPS, etc)
 - Fixed song names (songs that have spaces will correctly show their name)
 - Kid friendly mode (changes MILF to Mombattle, MM and BG characters are censored in Week 5, removes the Week 5 girlfriend face in the background, and changes the icon for Monster) (keeping things safe for our younger audiences is important)
 - No source editing modding (full on stages/whatnot by text/json files)
 - VS mode (for 2P fun)

For things that are already implemented or changed, go check out the [CHANGELOG](https://github.com/pahaze/refunked/blob/master/CHANGELOG.md)

## Build instuctions (Linux/HTML5)

First things first, you need to install Haxe. Be sure Linux is up to date. Fore experienced users, just be sure you're up to date on each Haxe library and Haxe itself. If not, continue reading on. For this example, we'll be using Pop!_OS 20.04 LTS / Pop!_OS 21.04 (Ubuntu based distribution). 

First, the repository needs to be added and Haxe be installed. (We're using an external repository instead of the one already in apt due to it being outdated.)

```
sudo add-apt-repository ppa:haxe/releases
sudo apt-get update
sudo apt-get install haxe
mkdir ~/haxelib
haxelib setup ~/haxelib
```

This sets up Haxe for us to now install things we need, next thing being HaxeFlixel. Before you can install HaxeFlixel, you need `lime`, `openfl`, and finally `flixel` itself

```
haxelib install lime
haxelib install openfl
haxelib install flixel
```

After those three install, run this:

```
haxelib run lime setup flixel
```

This allows us to easily get addons, ui, demos, templates, tools, or whatever Flixel would ever need. Now, just for convenience, run this:

```
haxelib run lime setup
```

It'll install lime as it's own separate command. You don't HAVE to do this, but it does make things easier in the long run. Now that that's out of the way, there's only a couple more libraries we need to install.

```
haxelib install hscript
haxelib install newgrounds
haxelib git polymod https://github.com/larsiusprime/polymod.git
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
```

After this, you'll be ready to compile the game! In the root of the source code (where Project.xml and such are), you can test for HTML5 (web) or Linux.

For Linux, all you have to do is run `lime test linux`. For HTML5, it's almost the same. `lime test html5`. Super easy stuff.

(By the way, if you're having a(n) build error saying there's an error in Controls.hx, all you have to do is run `git apply webbuildfix.patch` in the root directory ;). Sometimes Haxe likes to break. If you would like to contribute towards the engine, please make sure you have unapplied this patch, all it changes is Controls.hx.)

## Contributing

If you would like to contribute, then please do not hesitate! Give pull requests and we'll look at them as soon as possible. If one doesn't get pulled in, we'll explain why.

## Mods

As per the original game's README, you may NOT be allowed to have mods close-sourced. You MUST open source any mods you create with this engine or the original.

# Original README

This is the repository for Friday Night Funkin, a game originally made for Ludum Dare 47 "Stuck In a Loop".

Play the Ludum Dare prototype here: https://ninja-muffin24.itch.io/friday-night-funkin
Play the Newgrounds one here: https://www.newgrounds.com/portal/view/770371
Support the project on the itch.io page: https://ninja-muffin24.itch.io/funkin

IF YOU MAKE A MOD AND DISTRIBUTE A MODIFIED / RECOMIPLED VERSION, YOU MUST OPEN SOURCE YOUR MOD AS WELL

## Credits / shoutouts

- [ninjamuffin99 (me!)](https://twitter.com/ninja_muffin99) - Programmer
- [PhantomArcade3K](https://twitter.com/phantomarcade3k) and [Evilsk8r](https://twitter.com/evilsk8r) - Art
- [Kawaisprite](https://twitter.com/kawaisprite) - Musician

This game was made with love to Newgrounds and it's community. Extra love to Tom Fulp.

## Build instructions

THESE INSTRUCTIONS ARE FOR COMPILING THE GAME'S SOURCE CODE!!!

IF YOU WANT TO JUST DOWNLOAD AND INSTALL AND PLAY THE GAME NORMALLY, GO TO ITCH.IO TO DOWNLOAD THE GAME FOR PC, MAC, AND LINUX!!

https://ninja-muffin24.itch.io/funkin

IF YOU WANT TO COMPILE THE GAME YOURSELF, CONTINUE READING!!!

### Installing the Required Programs

First you need to install Haxe and HaxeFlixel. I'm too lazy to write and keep updated with that setup (which is pretty simple). 
1. [Install Haxe 4.1.5](https://haxe.org/download/version/4.1.5/) (Download 4.1.5 instead of 4.2.0 because 4.2.0 is broken and is not working with gits properly...)
2. [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/) after downloading Haxe

Other installations you'd need is the additional libraries, a fully updated list will be in `Project.xml` in the project root. Currently, these are all of the things you need to install:
```
flixel
flixel-addons
flixel-ui
hscript
newgrounds
```
So for each of those type `haxelib install [library]` so shit like `haxelib install newgrounds`

You'll also need to install a couple things that involve Gits. To do this, you need to do a few things first.
1. Download [git-scm](https://git-scm.com/downloads). Works for Windows, Mac, and Linux, just select your build.
2. Follow instructions to install the application properly.
3. Run `haxelib git polymod https://github.com/larsiusprime/polymod.git` to install Polymod.
4. Run `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc` to install Discord RPC.

You should have everything ready for compiling the game! Follow the guide below to continue!

At the moment, you can optionally fix the transition bug in songs with zoomed out cameras.
- Run `haxelib git flixel-addons https://github.com/HaxeFlixel/flixel-addons` in the terminal/command-prompt.

### Ignored files

I gitignore the API keys for the game, so that no one can nab them and post fake highscores on the leaderboards. But because of that the game
doesn't compile without it.

Just make a file in `/source` and call it `APIStuff.hx`, and copy paste this into it

```haxe
package;

class APIStuff
{
	public static var API:String = "";
	public static var EncKey:String = "";
}

```

and you should be good to go there.

### Compiling game

Once you have all those installed, it's pretty easy to compile the game. You just need to run 'lime test html5 -debug' in the root of the project to build and run the HTML5 version. (command prompt navigation guide can be found here: [https://ninjamuffin99.newgrounds.com/news/post/1090480](https://ninjamuffin99.newgrounds.com/news/post/1090480))

To run it from your desktop (Windows, Mac, Linux) it can be a bit more involved. For Linux, you only need to open a terminal in the project directory and run 'lime test linux -debug' and then run the executable file in export/release/linux/bin. For Windows, you need to install Visual Studio Community 2019. While installing VSC, don't click on any of the options to install workloads. Instead, go to the individual components tab and choose the following:
* MSVC v142 - VS 2019 C++ x64/x86 build tools
* Windows SDK (10.0.17763.0)
* C++ Profiling tools
* C++ CMake tools for windows
* C++ ATL for v142 build tools (x86 & x64)
* C++ MFC for v142 build tools (x86 & x64)
* C++/CLI support for v142 build tools (14.21)
* C++ Modules for v142 build tools (x64/x86)
* Clang Compiler for Windows
* Windows 10 SDK (10.0.17134.0)
* Windows 10 SDK (10.0.16299.0)
* MSVC v141 - VS 2017 C++ x64/x86 build tools
* MSVC v140 - VS 2015 C++ build tools (v14.00)

This will install about 22GB of crap, but once that is done you can open up a command line in the project's directory and run `lime test windows -debug`. Once that command finishes (it takes forever even on a higher end PC), you can run FNF from the .exe file under export\release\windows\bin
As for Mac, 'lime test mac -debug' should work, if not the internet surely has a guide on how to compile Haxe stuff for Mac.

### Additional guides

- [Command line basics](https://ninjamuffin99.newgrounds.com/news/post/1090480)
