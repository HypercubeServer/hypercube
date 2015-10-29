#hypercube
Minecraft gameserver written in D that has support for plugins written in Lua.

##plan
The current plan for Hypercube is to support the *[1.9](http://wiki.vg/Pre-release_protocol)* protocol, and to keep up to date with any versions after that.

##roadmap
Hypercube can't do much right now, but it will soon function as any other Minecraft server. Here's the roadmap for features:

* Tcp server that can handle a lot of clients and can recieve & send packets
  * Create a class for each different type of packet
  * (un)serialize the packet data into/from bytes
* 1.9 clients joining the game
  * Let 1.9 clients ping server and get response
* World loading & chunk sending
  * Registering world changes
* Entities
  * Dropped items, animals
* Plugin API for [Lua](http://jakobovrum.github.io/LuaD/)
  * and maybe [Assembly](http://dlang.org/iasm.html)? (kind of like NMS, because it can directly interact with the D code)
