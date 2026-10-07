# Lardovar

A blocky, Roblox-style browser game: single-file, no build step. Open `index.html`.

## Features
- Third-person avatar (R6-style, rounded blocks) with walk, sprint (E), dash (Q), shift lock (Shift), variable-height jump
- Physics: stairs, pushable crates, bounce pads, death + shatter animation, fall animation
- Avatar **Catalog**: 10 shirts, 8 pants, 12 faces, 11 hats, 7 back items (skateboard, wings, jetpack...) with rendered previews
- Roblox-style home, Games and Catalog pages, per-game thumbnails, local sign-up
- **Lardovar Studio**: place blocks, lava, bounce pads, crates and spawns, save games, playtest with your own avatar
- **Lardovar Engine**: games are scripted in **Lua only** (fengari Lua 5.3 VM, sandboxed, instruction-time limited)
- Settings: sensitivity, FOV, graphics quality, shadows, time of day, name tags, speed effects, invert Y

## Controls
WASD move - Space jump - E sprint - Q dash - Shift shift-lock - Enter chat - R reset - Tab players - Esc settings

## Lua API
```lua
on("start" | "update" | "touch" | "died" | "chat", fn)   -- update(dt), touch(partName), chat(msg)
part(name) -> id        newPart(x,y,z,w,h,d,"#hex",kind)   remove(id)
getPos(id)  setPos(id,x,y,z)  setColor(id,"#hex")
playerPos() teleport(x,y,z)  setSpeed(n)  setJump(n)  kill()
say(text)  print(...)  time()  after(seconds, fn)
-- kinds: block lava bounce crate spawn
```
Example:
```lua
on("touch", function(name)
  if name == "Coin" then say("Coin!") remove(part("Coin")) end
end)
```

## Multiplayer
Servers (up to 15 players, auto room code, public list, chat, ping/FPS HUD) use the claude.ai Artifact `room`
capability, so they work when the page is opened as a claude.ai artifact by signed-in users. Hosted elsewhere
(e.g. GitHub Pages) the game, catalog and Studio work in solo mode; PeerJS cannot be used on claude.ai-hosted
pages because outbound requests are blocked there.

## Notes
Accounts and saved games live in the browser's localStorage only. Third-party libraries (loaded from jsDelivr / cdnjs): three.js r128, fengari-web 0.1.4.
