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


## v21: Unreal-style Studio, friends, pause menu, engine extras
- **Studio layout**: a flat, dark, Unreal-Engine-style layout (blue accents, uppercase panel headers, status bar with object / selection / script counts). Default is Unreal; switch to Classic in the Studio gear or Settings.
- **Friends**: People page > My friends. Add friends by username (3-20 letters, numbers, _), remove them, and see who is in your server. Friends are saved in this browser (no server yet).
- **Pause menu**: bigger buttons with hover motion, blurred background, a short controls reminder.
- **Lua engine**: `HttpService:JSONEncode / JSONDecode / GenerateGUID`, `CollectionService` tags (`AddTag`, `RemoveTag`, `HasTag`, `GetTagged`, `GetTags`), and Luau helpers `math.sign`, `math.round`, `table.find`, `table.clone`, `table.clear`, `table.create`, `string.split`.

## v20: new faces, models, VFX Pack 2, animation polish
- **6 new faces** (Catalog > Faces): Starry Eyes, Tongue Out, Mad Fury, Peaceful, Sparkle Wink, Skull.
- **6 new models** (Toolbox > Models, Plugins tab, or ask the Assistant): Lighthouse, Windmill, Arch Bridge, Pyramid, Fountain, Market Stall.
- **VFX Pack 2** (Toolbox > Scripts): Lightning, Shield Dome, Whirlwind, Healing Rings, Meteor. Keys 1-5 or the buttons in Play. Frame-budgeted like VFX Pack.
- **Animation polish**: gentle idle breathing and arm sway, and a subtle hip sway while running.

## v19: update checker
- If a newer version is live, a banner appears at the top with an **Update now** button that bypasses the browser cache. GitHub Pages lets browsers keep a page for up to 10 minutes (longer on some phones), which can leave you on an old build. You can also open the site with `?v=NUMBER` on the end to force a fresh copy.

## v18: fix "fn is not a function" on load
- **Fixed**: if your saved outfit had the Dominus hat or a Daily Shop hat, the page crashed on load with `TypeError: fn is not a function`. Those hats were registered after the first avatar was built. The avatar builder now skips an item that is not registered yet (and retries on the next call), and the avatar is rebuilt once everything is loaded, so your hat still shows. Added regression tests that reload with each kind of saved hat.

## v17: VFX Pack, Studio settings gear, graphics presets
- **VFX Pack** (Studio > Toolbox > Scripts, or ask the Assistant for "explosion vfx"): a LocalScript with six effects: explosion, beam, energy wave (charge, then beam and blast), floating particles, impact frames (white / black / white / red screen flashes) and an anime slash. Press 1-6 or click the buttons in Play. Effects are frame-budgeted (at most 90 live parts, 24 updated per frame) so they do not trip the engine's script time limit. Copy the functions into your own scripts.
- **Studio settings gear** (top right in Studio): theme, graphics preset, insert VFX Pack, data backup / restore.
- **Graphics presets** (Settings page or Studio gear): Standard, Vivid (richer colour) and Ultra (sharper shadows, higher resolution, longer view distance).

## v16: body types, group icons, Safe Chat, new home page, GUI drag
- **Avatars**: cartoon proportions (bigger head) and a **Male / Female** body type (Settings). The body type shows on your own avatar; other players still see the default body.
- **Groups**: owners can upload a group icon (PNG, GIF, JPG or WebP; the real file type is checked, SVG is rejected; GIFs up to about 250 KB, big PNG/JPG are shrunk) and edit the description. Icons show in the group list and on the group page.
- **Safe Chat**: Settings > Safe chat limits chat to a menu of friendly phrases. The swearing filter and one-hour ban still apply to normal chat.
- **Home page**: welcome banner with your coins and the shop restock timer, plus quick buttons (Play Battlegrounds, Open Studio, Daily Shop, Groups, Forum, Settings).
- **UI editor**: click a GUI element on the preview to select it, drag it to move it, or drag its bottom-right corner to resize it.

## v15: exit fix, coins and daily shop, themes and settings, Studio Assistant, server search
- **Fixed**: leaving a game left the backpack, health bar, pause menu, fire button and script-drawn GUIs on screen. They are now cleared.
- **Coins**: 100 to start, +50 daily login bonus, +2 every 20 seconds in a game. **Daily Shop** (Catalog): limited-edition hats with FREE / price tags, three COMING SOON items and a restock countdown (new picks every UTC day). Catalog and pages now scroll.
- **Themes**: site-wide themes (Dark, White, Midnight, High contrast, Sunset, Forest). New **Settings** page (gear button, bottom right): theme, avatar outlines, coin counter, max players when hosting, data backup.
- **Studio Assistant**: a chat helper in Studio that builds models, inserts scripts, explains script errors and shows Lua examples. It is an offline rule-based helper, not a language model.
- **Servers**: search box over the public server list. Hosts can raise the player cap up to 200 in Settings. Your browser is the server, so large rooms depend on your connection.

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
