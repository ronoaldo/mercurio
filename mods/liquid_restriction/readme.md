# Minetest Liquid_Restriction Mod

[![ContentDB](https://content.minetest.net/packages/wsor4035/liquid_restriction/shields/downloads/)](https://content.minetest.net/packages/wsor4035/liquid_restriction/)
![Luacheck](https://github.com/wsor4035/liquid_restriction/workflows/build/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

restricts players from placing liquids via the node or bucket unless they have a the spill priv  

## About

born out of me not being able to find a good public spill mod. mod is ment for creative worlds. licensed under MIT.

## Links

* [Github](https://github.com/wsor4035/liquid_restriction)
* [Contentdb](https://content.minetest.net/packages/wsor4035/liquid_restriction/)
* [forums](not avaible yet)

## Setup

download mod, make sure its named liquid_restriction  

**recommend settings for survival**  
```  
lr_default = "interact"  
lr_advanced = "spill"  
lr_height = 0  
lr_renew = "true"  
```  

\-this config requires players to have the spill priv to use above 0

**recommend settings for creative**  
leave at defaults  

## minetest.conf settings

* lr_default (by default spill): default liquid_restriction priv  
* lr_advanced (by default server): advanced liquid_restriction priv  
* lr_height (by default 30): height for advanced priv use  
* lr_renew (by default false): if liquids are renewable or not  

## FAQ

__buckets don't work(place liquid) when used.__   
please update the mod, this has since been fixed as of commit `1e33fd0`

__how do I use this mod for random liquid__  
this mod supports any liquid with the `liquid` of `flowingliquid` drawtype, 
to disable its override please add the `liquid_blacklist` group to the node. 
As for buckets or other on_place items, please submit a issue or PR at this time.
