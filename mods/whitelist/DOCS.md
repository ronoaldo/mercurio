# Whitelist Docs

## 1. How it works

Whitelisted players and whitelist status are both saved into the mod storage, and they're updated every time one of the core functions below succeeds. The end (?)

## 2. Functions
### 2.1 Core

> The `sender` field in here is optional. If specified, the sender will receive an output message

* `whitelist.enable(<sender>)`: enables the whitelist
* `whitelist.disable(<sender>)`: disables the whitelist
* `whitelist.add_player(p_name, <sender>)`: adds `p_name` to the whitelist (not case sensitive)
* `whitelist.remove_player(p_name, <sender>)`: removes `p_name` from the whitelist (not case sensitive)

### 2.2 Utils
* `whitelist.print_list(sender)`: prints a message to `sender` containing all the whitelisted players
* `whitelist.is_player_whitelisted(p_name)`: returns whether `p_name` is whitelisted, as a boolean. If true, it also returns the name as it appears in the whitelist (as it's not case sensitive)
* `whitelist.is_whitelist_enabled()`: returns whether the whitelist is enabled, as a boolean

## 3. About the author
I'm Zughy (Marco), a professional Italian pixel artist who fights for FOSS and digital ethics. If this mod spared you some time and you want to support me somehow, please consider donating on [LiberaPay](https://liberapay.com/Zughy/)
