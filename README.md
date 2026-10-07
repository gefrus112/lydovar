# Lardovar

A blocky, Roblox-style browser game in a single file. No build step, no Claude artifact needed:
open `index.html` (or the GitHub Pages site) in any modern browser.

## Multiplayer (PeerJS, runs in any browser)
- **Create server**: type a server name; a random 5-character room code is generated for you.
- **Join**: enter the code, use an invite link (`...#ABCDE`), or pick a server from the public list.
- Up to **15 players** per server, chat, player list, FPS and ping, synced crates and avatars (outfit + emotes).
- The host's browser is the server (peer-to-peer over WebRTC). Signalling uses the free PeerJS cloud.
- The public server list uses a lobby peer: the first browser online claims `lardovar-lobby-v1` and acts as the registry.

## Gameplay
WASD move, Space jump (hold for higher), **E** sprint (stamina), **Q** dash, **Shift** shift-lock, **G** emotes (1-7), **Enter** chat,
**R** reset, **Tab** player list, **Esc** settings. Falling off the baseplate plays a fall animation and a shatter death.

## Avatar catalog
Shirts (10), pants (8), faces (18), hats (15), back items (10, incl. skateboard), hair (8), front accessories (8),
all with rendered previews. Profile page has animations: wave, dance, cheer, flex, salute, spin, sit.

## Lardovar Studio + Lua engine
Explorer panel (parts + scripts), place/select tools, move/scale/rotate (90-degree steps for solids, 15-degree for decor),
duplicate, decorations (tree, rock, lamp), kinds: block, lava, bounce, crate, spawn.
Multiple Lua scripts per game, **live reload** while playtesting (Ctrl+Enter, or auto while typing), save games,
upload a custom thumbnail or use an automatic screenshot, export/import `.lardovar.json` files.

### Lua API
```lua
on("start" | "update" | "touch" | "died" | "chat", fn)   -- update(dt), touch(partName), chat(msg)
part(name) -> id    newPart(x,y,z,w,h,d,"#hex",kind)   remove(id)
getPos(id)  setPos(id,x,y,z)  setSize(id,w,h,d)  setRot(id,deg)  setColor(id,"#hex")
playerPos()  teleport(x,y,z)  setSpeed(n)  setJump(n)  kill()  emote(1-7)
ui(id,text)  -- HUD label, nil removes      say(text)  print(...)  time()  after(sec, fn)
-- kinds: block lava bounce crate spawn tree rock lamp
```
Scripts run in a sandboxed Lua 5.3 VM (fengari) with no `os`, `io`, `require` and an execution time limit.

## Notes
Accounts and saved games live in the browser's localStorage. Custom games are single-player playtests.
Libraries via CDN: three.js r128, fengari-web 0.1.4, PeerJS 1.5.4.
