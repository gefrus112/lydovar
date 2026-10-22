live website  https://gefrus112.github.io/lydovar/ # Lardovar

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


## v8 highlights
- **Crossroads** (new game): spawn on a city intersection with a **rocket launcher** (click or F, or the Fire button). Rockets explode with splash damage, knockback and screen shake.
  Buildings take two hits, crumble into debris, and **rebuild themselves after ~14 s**. Parked cars and crates are physics objects you can blast around. Health bar with regeneration, 15-player servers.
- **Studio redesign** in the style of Roblox Studio: top bar (Test / play / stop), ribbon tabs, **Toolbox** (models, parts, skies), **Explorer** (Workspace, Lighting, StarterPlayer, ServerScriptService), **Properties**,
  viewport frame, Select/Move/Scale/Rotate/Transform tools with on-screen gizmos, snapping, a script editor panel with live reload.
- Lighting and graphics: image-based lighting from the sky, ACES tone mapping, glowing building windows at night, metallic car paint, time-of-day sky presets.
- More clothes: 18 shirts, 14 pants. Hair, front accessories, 18 faces, 15 hats, 10 back items.
- Classic web-page style landing page, a sign-up page with starter characters, and a top-navigation home page.
- New Lua: `weapon(true)`, `ui()`, `setSize`, `setRot`, `emote`; new part kinds: building, car, slab.


## v9: Studio v2 and Roblox-compatible scripting
- **Roblox-style Lua API** (Luau-lite). Paste AI-written Roblox scripts: `game:GetService`, `Players.LocalPlayer`, `Instance.new` for
  `ScreenGui / Frame / TextLabel / TextButton / ImageLabel / UICorner / UIStroke`, `Part`, `Fire / Smoke / Sparkles / ParticleEmitter / PointLight / Explosion`,
  `TweenService:Create(...):Play()` with easing, `Touched / MouseEnter / MouseButton1Click / Heartbeat / InputBegan` events, `task.wait / spawn / delay`, `wait()`,
  `Vector3 / CFrame / Color3 / BrickColor / UDim2 / Enum / TweenInfo`, `Humanoid` (Health / WalkSpeed / JumpPower), `Lighting.ClockTime`, `require(ModuleScript)`.
  Luau `x += 1` is converted automatically. The layer is in `rbx-api-layer.lua`.
- **Script / LocalScript / ModuleScript** in ServerScriptService, StarterPlayerScripts, StarterGui and ReplicatedStorage.
- **Studio v2**: Welcome tab with templates and What's New, Explorer with class icons and "+" insert menus, free-fly camera, undo/redo, copy/paste,
  material / transparency / anchored / can-collide / locked properties, **StarterGui editor** (live preview), **StarterPack tools** (backpack hotbar),
  **Terrain editor** (raise, lower, smooth, flatten, paint, water) with real collision, **Animation editor** (keyframe avatar joints and parts, `playAnim("Name")`).
- Hitbox view (Settings > Show hitboxes), narrower player hitbox, rockets hit other players.
- Fixed: black ground (regenerated environment lighting) and a missing `</style>` that blanked the page. An on-screen error banner now shows any load error.


## v14: Dominus hat, outlined avatars
- New hat **Dominus**: a dark spiked crown with glowing red spikes, a gem and a floating ring (Catalog > Hats).
- Avatars now get a cartoon-style outline on their solid parts, including after you change outfit. Turn it off by setting `lyd_outline` to `0` in local storage.

## v13: groups, forum, chat filter, Battlegrounds
- **Groups**: create a group, join / leave, member list, group wall. **Forum**: categories, new threads, replies, delete your own posts. Both are stored in your browser (no server yet) and all text is escaped.
- **Chat filter**: swearing in chat is blocked and the device is banned from the site for **one hour** (browser storage + cookie; the host also kicks players whose client skips the filter). This is not a true hardware ban: a browser game cannot identify hardware, so clearing site data or using another browser gets around it.
- **Battlegrounds** (Studio > Welcome > Battlegrounds): an arena with four skills (Gravity Pull, Repel Blast, Void Beam, Dash Strike), an awakening mode (damage x1.6, cooldowns halved, faster), cooldown HUD, range hitboxes, training dummies and the sword. Keys Z X C V R or the on-screen buttons. Press Host Server to fight friends.

## v12: plugins, themes, smarter script editor, data backup
- **Plugins tab** (Studio): six model generators (Checker Floor, Tower Stairs, Pillar Ring, Obby Course, Pine Forest, Castle Wall), also listed in Toolbox > Models.
  Write your own plugins in JavaScript with a small `studio` API (`studio.add`, `studio.part`, `studio.rand`, `studio.selection`, `studio.parts`); they are saved in your browser.
- **Themes**: Dark, Light, Midnight and High contrast, remembered between visits.
- **Script editor**: Tab / Shift+Tab indent, auto-indent, auto-closing brackets and quotes, Ctrl+/ comments lines, clickable Roblox API suggestions, live Lua syntax check with line and column.
- **Data**: Backup all data / Restore backup (accounts, games, models, plugins as one file); the site redirects `http` to `https` and asks the browser to keep your saved data.

## v11: model building, script library, tools, custom-game multiplayer
- **Studio**: prefab models (House, Tower, Bridge, Grove, Stairs, Fence, Pyramid, Street), multi-select (Shift+click), group / ungroup (Ctrl+G), rotate and duplicate groups,
  **My Models** (save a selection and reuse it), and a **script library** with 10 ready-made snippets (Kill Brick, Spinner, Teleporter, Coin Counter, Fire Trap, Heal Pad ...).
- **Tools** (StarterPack): Rocket Launcher, Sword (hits validated by the host), Gravity Coil, Heal Kit, Speed Coil, Jump Coil. Backpack hotbar (keys 1-7) and a pause menu (Esc).
- **Custom-game multiplayer**: host any Studio game as a server. Joining players download the game in chunks and see parts that scripts move or spawn.
- **Lua**: `workspace:Raycast`, `Players:GetPlayers()`, remote players' `Character` / `Humanoid.Health`, `PlayerAdded` / `PlayerRemoving` and `Touched` for remote players.
- Fixed: `Players:GetPlayers()` crashed with a nil `Players`; parts spawned by scripts never appeared for joining players (off-by-one in the part sync packet);
  the Heal Kit did nothing during the first 15 seconds after page load; removed a duplicate toolbox function.

## v10: new home, safer servers, better graphics
- **Home page** redesigned after a modern sky-style layout: avatar banner, nav bar (My Lardovar, Games, Catalog, Develop, Avatar, Inventory, Trade, Groups, Forum, News),
  "Hello" with your headshot, **Friends** (players you met in servers, shown with their real avatars), **Recently Played**, **My Favorites** (star a game), public servers and a Chat & Party bar.
  The old classic landing page is gone; the login page is a clean sky page.
- **Error dialogs** (Roblox-style, with codes): 277 lost connection / internet down, 279 failed to connect, 524 no server with that code, 529 server full,
  273 account used twice (same account in another tab, or same name already in the server), 268 kicked by anti-cheat.
- **One login per account**: logging in on another tab logs the older tab out. A server rejects a second player with the same account name.
- **Anti-cheat** (the host validates every player): impossible positions, speed/teleport hacks, hovering, chat spam and rocket spam / rockets fired from far away.
- Graphics: gamma-correct (sRGB) lighting, bump-mapped baseplate, softer shadows, noisy terrain colours.
- Fixed: "Cannot read properties of undefined (reading 'toLowerCase')" when a key event has no `key` (browser autofill / IME); duplicate element ids (player count, copy-invite).

## Notes
Accounts and saved games live in the browser's localStorage. Custom games are single-player playtests.
Libraries via CDN: three.js r128, fengari-web 0.1.4, PeerJS 1.5.4.
