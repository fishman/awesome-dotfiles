awesome config
==============

Here is my personal configuration of awesome.
Currently I use awesome v3.5.2 (The Fox)

with the following modules:

* [tyrannical](https://github.com/Elv13/tyrannical)
  * dynamic tagging configuration system
* [vicious](https://github.com/Mic92/vicious)
  * modular widget library

WARNING: if you use awesome with lua5.2, you cannot use lognotify and wimpd.
They rely on luasocket, which is not avalaible for lua5.2. Personally I build
awesome with luajit ([awesome-luajit-git]() in AUR, if you are on archlinux)

* [lognotify](https://github.com/Mic92/lognotify) -> depends on inotify and luasocket (read the Readme of lognotify)

* in utils repository:
    - iwlist (wrapper around iwlist to display wifi-networks)
    - wimpd (widget for mpd, depends on luasocket)
    - cal (calendar popup)


Here is a screenshot:
![screen shot](https://github.com/downloads/Mic92/awesome-dotfiles/screenshot.png)