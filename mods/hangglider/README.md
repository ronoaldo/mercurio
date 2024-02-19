# Hang Glider [hangglider]

[![luacheck](https://github.com/mt-mods/hangglider/workflows/luacheck/badge.svg)](https://github.com/mt-mods/hangglider/actions)
[![ContentDB](https://content.minetest.net/packages/mt-mods/hangglider/shields/downloads/)](https://content.minetest.net/packages/mt-mods/hangglider/)

Adds a functional hang glider for exploring. Also works as a parachute to save yourself when falling.

Rewritten and improved fork of https://notabug.org/Piezo_/minetest-hangglider.

![](screenshot.png?raw=true)

## Usage

To deploy the hang glider, hold the item in your hand and use it (left-click). The same action also closes the hang glider when it's deployed.

While deployed you can glide around just like walking in the air. Your decent will be slowed until you land on a safe node, which can be any solid node, or a safe liquid like water. Upon landing the hang glider will automatically close.

## Coloring

You can color the hang glider by crafting it with any dye. Also supports all `unifieddyes` colors.

Note that the color will only be visible on the item if you are using Minetest 5.8.0 or above.


## Repairing

The hang glider will wear out every time you use it. The hang glider can be repaired by crafting it with wool or paper, or any other method used to repair tools.

## Area Flak

If the `areas` mod is installed, airspace restrictions can be added to areas using the `/area_flak` command.

When using a hang glider in an area with flak enabled, you will get shot down a few seconds after entering the area, this reduces your HP to 1 and destroys your hang glider.
