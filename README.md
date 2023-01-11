# <img src="art/icon64.png" align="center"> Friday Night Funkin' ReFunked </img>

This is the repository for the "ReFunked" engine of Friday Night Funkin' (AKA "FNF RFE"/"Friday Night Funkin' ReFunked"), an open source rhythm game. The engine was created to attempt to stomp out bugs and make the open source game better as much as possible. No competition with other engines is intended.

Note: MODS MUST BE OPEN SOURCE WHEN USING THE ENGINE. NO EXCEPTIONS. 

## Credits

- [pahaze (me)](https://github.com/pahaze) - Programmer
- [CryptoCANINE](https://github.com/CryptoCANINE) - Programmer
- [Junimeek](https://github.com/Junimeek) - Quality Control, Wiki Maintainer
- [AngelDTF](https://github.com/AngelDTF) - Creator of Newgrounds Port (Seriously, this saved me so much time instead of reversing more of 0.2.8 myself)
- [ShadowMario](https://github.com/ShadowMario) - Creator of Pysch Engine (FlxDropDown menu borrowed, some higher FPS code (camera, zooms, icons, etc) borrowed (I plan to move to my own code later))

\- and any other contributors

## Help

None of the main developers are part of the FNF community, nor do we plan to be, as we solely do this for fun and nothing more. However, if you need help, open an issue and we'll gladly assist as much as we can.

## Plans

These will be added later. This rewrite intends on fixing a lot of the bugs in the master branch.

## Build instuctions (Linux/HTML5)

First things first, you need to install Haxe. Be sure Linux is up to date. For experienced users, just be sure you're up to date on each Haxe library and Haxe itself. If not, continue reading on. For this example, we'll be using Ubuntu 22.04 LTS.

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

Check [here](OGREADME.md). 
