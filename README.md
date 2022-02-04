# ![RFE logo](art/icon64.png) Friday Night Funkin' ReFunked

[![CodeFactor](https://www.codefactor.io/repository/github/pahaze/refunked/badge/master)](https://www.codefactor.io/repository/github/pahaze/refunked/overview/master) 

This is the repository for the "ReFunked" engine of Friday Night Funkin' (AKA "FNF RFE"/"Friday Night Funkin' ReFunked"), an open source rhythm game. The engine was created to attempt to stomp out bugs and make the open source game better as much as possible. No competition with other engines is intended.

Note: MODS MUST BE OPEN SOURCE WHEN USING THE ENGINE. NO EXCEPTIONS. 

## Credits

- [pahaze (me)](https://github.com/pahaze) - Programmer
- [CryptoCANINE](https://github.com/CryptoCANINE) - Programmer
- [Johnny Redwick](https://github.com/JohnnyRedwick) - Artist
- [KadeDev](https://github.com/KadeDev) - creator of Kade Engine (themes based off of engine in game, some code from engine used for accuracy)
- [ShadowMario](https://github.com/ShadowMario) - creator of Pysch Engine (themes based off of engine in game, some code from engine used for accuracy)
- [Verwex](https://github.com/Verwex) - creator of the Mic'd Up Engine (themes based off of engine in game, some code used from engine for accuracy)
- [Tr1NgleDev](https://github.com/Tr1NgleDev) - creator of Tr1ngle Engine (themes based off of engine in game)
- [Yoshubs](https://github.com/Yoshubs) - creator of Forever Engine (themes based off of engine in game)
- OG devs (ninjamuffin99, PhantomArcade3K, evilsk8r, and Kawai Sprite)

\- and any other contributors

## Changes

Some big things (or little things) that we have added and/or changed are

 - Lua support! Very limited right now though, and only for desktop at the moment.
 - Themes!!! ReFunked can look like your favorite engine, whether it be Forever Engine, Kade Engine (1.2 and older, 1.3-1.4.2, 1.5-1.7, and even 1.8 soon), Psych Engine, Mic'd Up, Tr1ngle, or even vanilla if you dig that! 
 - Unhardcoded characters, songs, stages, and themes on desktop!
 - Unhardcoded songs (no characters/stages) on web!
 - Some easter eggs are around the engine. Have fun finding them if you want.

## Help

None of the main developers are part of the FNF community, nor do we plan to be, as we solely do this for fun and nothing more. However, if you need help, open an issue and we'll gladly assist as much as we can.

## Plans

Things that are planned to be added include:

 * Options (Downscroll, botplay, keybindings, FPS, etc) [WIP]\
  \- Downscroll is complete\
  \- FPS is complete\
  \- Middlescroll is complete\
  \- Themes are complete

 * Fixed song names (songs that have spaces will correctly show their name) [Finished]
 
 * Kid friendly mode (changes MILF to Mombattle, MM and BG characters are censored in Week 5, removes the Week 5 girlfriend face in the background, and removes Monster's songs) (keeping things safe for our younger audiences is important) (not available in settings yet) [WIP]\
  \- MM's car assets have a SFW version [WIP]\
  \- DD's assets have a SFW version [DONE]\
  \- Parents (week 5) have a SFW(-ish) version [DONE]\
  \- M.I.L.F. is Mombattle, Satin Panties is Chillflow [DONE]\
  \- Monster's songs removed [DONE]
 
 * No source-code editing modding (full on stages/whatnot by Lua/JSON files) [WIP]
 
 * VS mode (for 2P fun) [WIP]

For things that are already implemented or changed, go check out the [CHANGELOG](https://github.com/pahaze/refunked/blob/master/CHANGELOG.md)

### ADD GHOST TAPPING!!!

No. Sorry. Why? More of a little challenge :)

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
haxelib install polymod
haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc
```

If you're compiling for desktop.... Also install linc_luajit!

```
haxelib install linc_luajit
```

After this, you'll be ready to compile the game! In the root of the source code (where Project.xml and such are), you can test for HTML5 (web) or Linux.

For Linux, all you have to do is run `lime test linux`. For HTML5, it's almost the same. `lime test html5`. Super easy stuff.

(By the way, if you're having a(n) build error saying there's an error in Controls.hx, all you have to do is run `git apply webbuildfix.patch` in the root directory ;). Sometimes Haxe likes to break. If you would like to contribute towards the engine, please make sure you have unapplied this patch, all it changes is Controls.hx.)

## Contributing

If you would like to contribute, then please do not hesitate! Give pull requests and we'll look at them as soon as possible. If one doesn't get pulled in, we'll explain why.

## Mods

As per the original game's README, you may NOT be allowed to have mods close-sourced. You MUST open source any mods you create with this engine or the original.

# Original README

Check [here](OGREADME.md). 