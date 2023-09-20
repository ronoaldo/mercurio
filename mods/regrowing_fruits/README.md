Regrowing Fruits
===
[![ContentDB](https://content.minetest.net/packages/philipmi/regrowing_fruits/shields/title/)](https://content.minetest.net/packages/philipmi/regrowing_fruits/)
[![ContentDB](https://content.minetest.net/packages/philipmi/regrowing_fruits/shields/downloads/)](https://content.minetest.net/packages/philipmi/regrowing_fruits/stats/)
[![Forums](https://img.shields.io/badge/Forums-Regrowing_Fruits-lightgrey)](https://forum.minetest.net/viewtopic.php?t=24986)
[![License](https://img.shields.io/badge/license-MIT-brightgreen)](#license)
![Screenshot](screenshot.png)

Info
----

This mod causes fruits on trees from various other mods to regrow like apples in the 5.0 release of Minetest Game. It also offers a small API to add fruit regrowth quickly.
If the fruit was placed by hand or the tree was chopped down, the fruit won't grow back. There is also a small chance that regrowth will stop randomly, so trees will bear less fruit over time.

Currently supported mods/modpacks are: `default`, `ethereal`, `cool_trees`, `moretrees`, `farming_plus`, `multibiomegen`, `australia` and `aotearoa`. 

The standard regrowth time can be changed in settings (`min_regrow_interval` and `max_regrow_interval`) as well as the chance of regrowth stopping (`regrowth_stop_chance`).

Ideas, bug reports or requests for more mod support are always welcome in the [Minetest Forum topic](https://forum.minetest.net/viewtopic.php?f=9&t=24986) or via the [Git Issue Tracker](https://git.sp-codes.de/minetest/regrowing_fruits/issues)!

API
----

The `regrowing_fruits.add()` function overrides the fruits `after_dig_node` function and registers a placeholder node that will be placed once the fruit is taken and regrows the fruit after a timer expires.

**Definition:**
```
regrowing_fruits.add(fruitname, leafname, param2, multiplier)
```

* `fruitname`: nodename of the fruit to be added.
* `leafname`: nodename of the corresponding leaves (used as a reference whether tree is still alive).
* `param2`: param2 value of fruit when placed naturally (not by player). Defaults to 0; -1 disables param2 checks for fruit regrowth (use this if your fruit has different rotations). If set, overrides `after_place_node` of fruit node to be able to differentiate fruits by param2 when placed by player.
* `multiplier`: multiplier for the standard average regrowth time.

**Examples:**
```
regrowing_fruits.add("default:apple", "default:leaves")
regrowing_fruits.add("ethereal:golden_apple", "ethereal:yellowleaves", nil, 3)
regrowing_fruits.add("cacaotree:pod", "cacaotree:trunk", -1)
```
For more examples see [init.lua](init.lua).

Alternative Mods
----

Consider using [`regrow`](https://notabug.org/TenPlus1/regrow) by TenPlus1. It has similar features, but registers only one placeholder node in total instead of one node for every fruit.

Credits
----

This mod is based on "[endless_apples](https://github.com/Ezhh/endless_apples)" by Shara RedCat (2018).

License
----

Code for this mod is released under [MIT](https://spdx.org/licenses/MIT.html) (see [LICENSE](LICENSE)).
