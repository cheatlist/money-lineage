# Money Lineage — Architecture Notes

A Roblox game in the Rogue Lineage / Deepwoken lineage-roguelike genre: permadeath-ish
progression through Races, Classes (fighting styles/skill trees), and Paths (elemental/thematic
specializations layered on top of a class).

## Tooling: Argon, not Rojo

This repo is synced with **Argon**, not Rojo. `default.project.json` is Argon's project file — the
format is Rojo-compatible (Argon reads/writes the same schema), but the actual sync/build/watch
tooling is Argon's CLI + VS Code extension. Practical implications:

- `/sourcemap.json` is Argon-generated and gitignored — don't hand-edit it, don't expect it to exist.
- **Every directory under a synced service root has its own `init.meta.json` with `"keepUnknowns": true`**
  (as of 2026-07-25 — previously only the top-level `$path` entries in `default.project.json` had
  `$keepUnknowns: true`, which does **not** cascade to nested folders — this is a known upstream
  Rojo/Argon limitation, not a misconfiguration; Argon deletes any instance under a folder that
  isn't `keepUnknowns`-protected and isn't described by a file in `src/` on every sync). Practical
  effect: **binary Roblox instances (Animations, Sounds, Meshes, ParticleEmitters, NPC models,
  dialogue-trigger parts) are NOT tracked in this git repo** — they live only in the live Studio
  place file and now survive syncs. Scripts reference them by sibling/child instance name (e.g.
  `script.Parent.Anim`, `HumanoidRootPart.DragonRoar:Play()`). When a script references an instance
  name that doesn't appear anywhere in `src/`, that's expected — it's a Studio-side asset, not a
  bug. **If you add a new folder under any synced service root, give it an `init.meta.json` with
  `"keepUnknowns": true`** (merge it into the same file as `"className"` if the folder is also a
  non-Folder instance like a `Tool`) — it won't inherit protection from an ancestor folder.
- Wally is set up for packages (`Packages/`, `ServerPackages/`, `DevPackages/` are gitignored) but
  no `wally.toml` exists yet at time of writing — check before assuming it's in use.
- **Consequence for future work**: any feature that needs a *new* sound/mesh/particle asset cannot
  be fully finished by editing files alone — the asset has to be added in Studio by whoever has
  edit access to the live place. Code can be written ahead of the asset (reference it by the name
  it will have), but flag this clearly rather than silently assuming it exists.

## Directory layout

- `src/ReplicatedStorage/` — shared assets, data modules (e.g. `Info/AreaData.luau`), `Names/`, `MainModule.luau`
- `src/ServerScriptService/`
  - `Modules/` — `Commands/` (chat/admin commands; `Commands/GetClasses.luau` is an unused flat
    class→skills copy, kept in place rather than deleted, see Classes section below),
    `HitDetection.luau` (AOE/cone targeting, calls into `TagHumanoid`), `EffectModule.luau` (generic
    VFX helpers: `Lightning`, `QuickLightning`, `Explosion`, `Wings`, `Wings2`, `HeraldWings`, etc.),
    `DataStore2`, `SpellModule`, `ActionCheck.luau` (shared move-guard check, see Moves section),
    `MoveInfoSchema.luau` (documentation-only registry of every `Info` flag `TagHumanoid` reads)
  - `WorldHandler/` — the gameplay brain
    - `ClassData.luau` — **the single source of truth** for class data (`classdata`/`supers`/`ultraclass3`
      tables), required by both `GameLoaded` and `DialogueHandler` (see Classes section below)
    - `ClassDataDriftCheck.luau` — startup warning if another independently-maintained class-name
      list (currently `_G.MageClasses`) references a name `ClassData` doesn't produce
    - `GameLoaded/init.server.luau` — `require()`s `ClassData` for its admin `/class` grant command
    - `Admin/GetClasses.luau` — a second unused flat class→skills copy; `required` into a local that's
      never read, kept in place rather than deleted (see Classes section below)
    - `Dialogues/DialogueHandler/ModuleScript.luau` — **huge** (13k+ lines): the entire dialogue
      engine, `teachskill()` (reads from the shared `ClassData`), and every path-trial NPC
      (`VoiceFromAbove`, `Heretic`, `Fang`, etc.)
    - `Dialogues/DialogueHandler/init.server.luau` — the dialogue *driver* (talking-state machine,
      NPC click wiring, remote events) — thin, doesn't contain content
    - `TagHumanoid/init.server.luau` — **huge** (~3050 lines): the actual damage/stun/knockback/proc
      resolver. Every move's `Info` table flows through here. All passive procs that trigger "on
      hit" live in this one function — except the Storm Herald/Ember Wyrm/Abyssal Wyrm proc block,
      which was split out (see `Procs/` below). `MoveInfoSchema.luau` documents its `Info` contract.
    - `TagHumanoid/Helpers.luau` — the 9 small shared helpers (`create`, `soundplay`, `getCurseCount`,
      etc) `taghumanoid()` uses throughout
    - `TagHumanoid/Procs/DragonSlayerPaths.luau` — the Storm Herald/Ember Wyrm/Abyssal Wyrm on-hit
      proc block, the one genuinely self-contained proc in the whole file (see Refactor session below)
- `src/ServerStorage/`
  - `Classes/<Move Name>/` — one folder per **active move**, synced as a Roblox `Tool`. Despite the
    directory name, this is the move library, not the class library. Most `ActionCheck()` guards here
    now delegate to `Modules/ActionCheck.luau` (see Moves section) — a handful still have their own
    local definition where the shared module's shape doesn't fit, and that's intentional, not
    leftover work.
  - `RacialAbilities/`, `Weapons/`, `Storage/` (items/scrolls), `PlayerData` (live per-player
    instance tree, not present in this repo — created at runtime)
- `src/StarterCharacterScripts/CharacterHandler/`
  - `init.server.luau` — **huge** (~4380 lines, down from ~5800): per-character server logic (class/skill
    grants, boosts, weapon-input handling, path-flag reads for shared systems like Dash). Still mixes
    several concerns — see Refactor priorities for what's still in here vs. what was extracted.
  - `Modules/` — `ApplyInjuries.luau`, `Vampirism.luau`, `RacialFlight.luau` (Seraph/Phoenix flight
    form), `EdictRewards.luau`, `WeaponEquip.luau` (`equipweapon`/`unequipweapon`), `AntiCheat.luau`
    (`CheckForTags`/`TriggerAA`/air-time + position-rollback checks) — self-contained sections pulled
    out of `init.server.luau`; each is a function taking whatever character/player state it needs as
    explicit parameters (some via `getX()`/`setX()` closures where `init.server.luau` reassigns that
    state elsewhere and the module needs to read/write the live value, not a stale copy)
- `src/StarterGui/`, `src/StarterPlayerScripts/` — client UI/input

Much of the codebase reads as decompiled/deobfuscated Lua (generic names like `v1`, `u2`,
`l__Parent__1`) — this is pre-existing style, not something introduced recently. Match it when
editing these files rather than silently "cleaning up" unrelated code in the same diff.

## Core systems

### 1. Classes (fighting styles)

A class is a named skill bundle with a price, a prerequisite class, and (for ultras) a flag. As of
2026-07-25 this lives in **one place**: `ServerScriptService/WorldHandler/ClassData.luau`, exporting
`{classdata, supers, ultraclass3}`. Both real consumers `require()` it:

1. `ServerScriptService/WorldHandler/GameLoaded/init.server.luau` — reads `classdata` for the admin
   `/class` grant command
2. `ServerScriptService/WorldHandler/Dialogues/DialogueHandler/ModuleScript.luau` — reads all three
   tables; `teachskill(p, info, firstcheck)` is what actually grants skills to players

Two more files still exist with their own flat `{ClassName = {skill, skill, ...}}` tables —
`ServerScriptService/Modules/Commands/GetClasses.luau` and `ServerScriptService/WorldHandler/Admin/GetClasses.luau`
— but **neither is a real dependency**: the first has zero requires anywhere in `src/`, the second is
`require()`d into a local (`Admin/init.server.luau`) that's never subsequently read. They were deleted
once during the 2026-07-25 refactor and reappeared via what looked like a live Studio/Argon sync, so
they were left in place rather than fought — if you're touching class data, `ClassData.luau` is the
only file that matters; these two are inert.

`ClassData.luau`'s content was chosen from `DialogueHandler`'s version when the two tables were
unified (they had drifted with real gameplay differences by then — different prices, different
`requiredclass` gates, different skill-list membership). If you need the pre-unification values for
either side, check git history from before commit `5ad8ff2`.

Key naming gotcha (still true): the outer table *key* is the no-space PascalCase form (`DragonSlayer`)
consistently now, but the `class` field (the literal string written to `PlayerData.Class.Value`)
doesn't always match the outer key (e.g. `SuperBlacksmith`'s key vs. its own `class` field can still
diverge from other conventions elsewhere in the codebase — `CharacterHandler`'s `ultraclass3` check
and `_G.MageClasses` both compare against `.Class.Value` directly, so a class string that doesn't
match `ClassData`'s `.class` output for its own entry will silently fail those checks).
`ClassDataDriftCheck.luau` catches exactly this for `_G.MageClasses` at startup — extend it if you
add another independent class-name list.

`teachskill()` grants **one random unowned skill per NPC visit** (for a price), not the whole class
at once — a player must return repeatedly until `ownedskills == #info.skills` ("max").

### 2. Moves (active abilities)

Master move library: `ServerStorage/Classes/<Move Name>/`, one folder per move (a Rojo/Argon-synced
`Tool`). A move script (`Script.server.luau` or `Activator.luau`) typically:
- Calls a per-file `ActionCheck()` guard (stun/blocking/knocked checks) before acting. As of
  2026-07-25, 118 of 130 move files delegate to `ServerScriptService/Modules/ActionCheck.luau` via a
  small local wrapper (`local ActionCheckModule = require(...); local function ActionCheck(Parent)
  return ActionCheckModule(Parent, {presentBlocks = {...}, ...}) end`) instead of a hand-copied body —
  when adding a new universal stun state, add it to each file's `presentBlocks`/`presentTagBlocks`
  list rather than editing a copy-pasted function body. The remaining 12 files intentionally still
  have their own local `ActionCheck` because they don't fit the shared module's shape: several have
  genuine pre-existing logic quirks (e.g. `Elegant Slash`/`Focus Slash`/`Joyous Dance`'s `Activator.luau`
  let `Unconscious`/`Knocked` bypass the `Immortal` check instead of blocking — flagged, not "fixed"),
  a few check something other than instance/tag presence (`Harpoon` checks `IsClimbing.Value == true`
  not just existence; the `Jack o'Lantern Chair` variants and `Wooden Chair` check `FloorMaterial`),
  and `Rising Dragon` has a conditional exception not expressible as a flat check list. Don't assume
  every move file uses the shared module — grep for `function ActionCheck` to check a specific file.
- Manages its own cooldown via a `NumberValue` under `Character.Cooldowns`, auto-cleaned with
  `game.Debris:AddItem(cd, duration)`
- Builds an ad hoc `Info` table (`damage`, `physical`/`mana`, `aoe`, `move`, plus dozens of
  move-specific one-off flags) and either calls `HitDetection.magnitudeCheck`/`SMag` (AOE/cone
  targeting) or fires `ServerStorage.Requests.TagHumanoid` directly
- There is **no enforced schema** for `Info` — whatever flag a move sets, `TagHumanoid/init.server.luau`
  must separately know to check for. `ServerScriptService/Modules/MoveInfoSchema.luau` documents all
  128 known flags by category as a reference (damage-modifying, defense-bypassing, on-hit-proc,
  knockback/stun, weapon dispatch, path-specific) plus a short suspected-dead list
  (`curseshieldit`, `spearmovestack`, `dexthunder`/`nodexsound`, `bell`, the `ReturnStun` guard state)
  — but it's documentation only, not runtime-validated. Adding a new mechanical effect still means
  editing both the move script *and* `TagHumanoid/init.server.luau`, and checking `MoveInfoSchema.luau`
  by eye for name collisions is on you.

Cooldowns/damage are hardcoded per move script; there is no central balance table.

### 3. Passives (flag-only skills)

Most non-move skills (and the "upgrade" skills like `DragonBloodUpgrade`) are **pure strings** — not
Tools. `PlayerData.Skills` is a single comma-separated `StringValue`. A skill only becomes a
clonable Backpack `Tool` if a matching folder exists under `ServerStorage/Classes`; otherwise it's
checked purely via `PlayerData.Skills.Value:find("SkillName")` wherever relevant.

**Known trap**: checking `Backpack:FindFirstChild("SkillName")` for a flag-only skill will always
be `nil` — always check `Skills.Value:find(...)` instead. (This was an actual live bug: see
`ServerStorage/Classes/Dragon Blood/Script.server.luau`, fixed 2026-07-25 — it had been checking
`Backpack:FindFirstChild("DragonBloodUpgrade")` for a skill with no backing Tool.)

### 4. Paths (elemental/thematic specializations) — separate from Classes

**Paths are not part of a class's flat skill list.** They are granted through a gated NPC dialogue
"trial": a specific NPC (`VoiceFromAbove`, `Heretic`, `Fang`, ...), reachable once a stat threshold
is met (`TotalGrips`, `MinutesMeditated`, `SoulRipsAchieved`, ...) and the player is in the
right class, offers a **mutually-exclusive choice** among 2-3 named paths, appends the chosen
skill string(s) directly to `Skills.Value` (bypassing `teachskill` entirely), and usually assigns a
random flavor `UberTitle`. Existing paths (all in `DialogueHandler/ModuleScript.luau`):

| Path skill string | Granting NPC | Gate | Touches |
|---|---|---|---|
| `TheThunderstorm` / `TheCalmbeforethestorm` / `TheLightning` | `VoiceFromAbove` | Class == `DragonSage`, `TotalGrips` | Lightning Elbow, Lightning Drop, Electric Smite, Dash |
| `TheRunemaster` / `TheCursedFlame` / `TheCursedSwordsman` | `Heretic` | Class == `DarkSigilKnight`, `TotalGrips` + extra stat | Fire/rune/sword moves across Sigil Knight → Wraith Knight/Samurai lines, plus grants `True Vision` |
| `StormHerald` / `TheEmberWyrm` / `TheAbyssalWyrm` | `Fang` | Class == `Dragon Slayer` fully learned, `TotalGrips >= 15` | Dragon Roar, Thunder Spear Crash, Dragon Awakening, Wing Soar, Spear Crusher (added 2026-07-25, see below) |
| `TheToxin` (1 of 3 Faceless paths) | `Knight` | Class == `Faceless` fully learned, `TotalGrips >= 20` | Ethereal Strike, Lethality/Chain Lethality (via `TagHumanoid/Procs/FacelessPaths.luau`), Emerald enchant, grants new move `Septic Burst` — see "Faceless poison path" section below |
| `TheBlade` (2 of 3 Faceless paths) | `Knight` | Class == `Faceless` fully learned, `TotalGrips >= 20` | Bane, Shadow Fan, Agility, Ethereal Strike, Lethality, new weapon `Twinfang` (bought, not taught) — see "Faceless blade path" section below |
| `TheMaster` (3 of 3 Faceless paths — all three now built) | `Knight` | Class == `Faceless` fully learned, `TotalGrips >= 20` | Agility, Bane, Ethereal Strike, Lethality, Triple Dagger Throw, Shadow Fan, ShadowDash, `FirstName` — see "Faceless master path" section below |

The dialogue engine itself (`Dialogues/DialogueHandler/init.server.luau`) is a simple state machine:
`talking[Character] = {npc, page, choice}`. Each NPC's `dialogues.<Name>.v1(p, v)` handler is called
on every step; `v.page` starts at 1 and increments by 1 per choice made; `v.choice` holds the last
choice string. Handlers branch on `v.page` for flow position and `v.choice` for which option was
picked — **when adding a page to an existing NPC's flow, disambiguate by `v.choice` content if the
page number can be reached from more than one prior branch**, don't assume page number alone is
unique.

### Faceless poison path (TheToxin) — added 2026-07-25

First of 3 planned Faceless paths (the other 2 are unbuilt — don't assume the `pathoffer` dialogue
page only ever has one choice, it's written to have more `elseif v.choice == ...` branches added
later). Granted by `Knight` — the same NPC that already teaches the base 5 Faceless skills — once
`teachskill(p,classdata.Faceless,true) == "max"` and `data.TotalGrips.Value >= 20` (`TotalGrips` is
reused a third time here, same stat `VoiceFromAbove`/`Fang` already gate on; no new PlayerData field
was introduced). See `dialogues.Knight.v1` in `DialogueHandler/ModuleScript.luau` — page 2 is shared
between the pre-existing "buy a Faceless skill" flow and the new path-offer flow, disambiguated by
`v.choice` per the convention above.

**Design: poison stacks, not tick damage.** Unlike the pre-existing binary "Poisoned" DoT (a single
`Accessory` gate + 20-tick coroutine, still used by everyone else — see `TagHumanoid/init.server.luau`
~line 2636), `TheToxin` owners apply **stacking** poison: each `"ToxinStack"` instance
(`TagHumanoid/Helpers.luau`: `addToxinStack`/`getToxinStackCount`/`clearToxinStacks`, mirroring the
existing `getCurseCount`/`"Cursey"`-counting convention) amplifies damage the target takes from
**anyone** (`+20% per stack`, same code shape as curse amplification, both live at
`TagHumanoid/init.server.luau` ~line 2872) and stacks a `-3 SpeedBoost` slow per stack under
`enemy.Boosts` (existing multi-instance slow idiom, not a new mechanic). Stacks decay individually
after 10s, so sustained pressure — not one big hit — is what snowballs. A new move, **Septic Burst**
(`ServerStorage/Classes/Septic Burst/`), consumes all current stacks on the nearest enemy and deals
`4 + 6*stacks` instant damage (`Helpers.clearToxinStacks`).

**Everything else is centralized in one file**: `TagHumanoid/Procs/FacelessPaths.luau` (same pattern
as `DragonSlayerPaths.luau` — required once in `TagHumanoid/init.server.luau` and called from the
`if info.damage then ... end` block). It: (1) nerfs **all** of a `TheToxin` owner's outgoing damage by
30% except `Septic Burst` itself (`info.move ~= "Septic Burst"`), so the path is damage-negative
without stacks; (2) adds 3 stacks whenever `info.move == "Ethereal Strike"` fires — the actual per-move
rework of Ethereal Strike lives in its own script (`ServerStorage/Classes/Ethereal Strike/Script.server.luau`),
which branches on `data.Skills.Value:find("TheToxin")` to swap its old flat `percent = 20` (20% max
health) burst for a small flat `damage = 6` hit, since the stack injection is what's supposed to
matter now; (3) adds 1 stack per landed **Lethality**/**Chain Lethality** flurry hit (`info.move ==
"Lethality"`) — deliberately **not** edited in `Lethality/Activator.luau` itself, since that file's
6-hit-loop×2-branch structure already fires one `TagHumanoid` event per hit, so the central proc
picks it up for free without touching a risky 266-line decompiled file. Lethality's raw damage is
still cut by the same universal 30% nerf; its `executes = true` finisher behavior was left alone
(the user's ask to "rework or remove Lethality" was explicitly uncertain — this reads as reworking its
role from a damage tool into a stack-applicator without gutting its execute utility, not removing it).

**Emerald enchant compatibility**: the Emerald gem's poison proc
(`TagHumanoid/init.server.luau`, the `val2:find("Emerald")` block) used to self-fire
`TagHumanoid:Fire(enemy,enemy,{poison=true,...})` — note this loses the original attacker's identity
(the self-fire's `character` becomes the *victim*, not whoever landed the gem proc), which is why the
`TheToxin` check has to happen **at the Emerald block itself** (where the real attacker's `playerdata`
is still in scope) rather than inside the generic `info.poison` handler further down. If you add
another poison source that self-fires `{poison=true}` onto `enemy,enemy`, it has the same blind spot —
intercept at the proc's origin, not in the generic handler.

**Asset debt incurred** (same pattern as the 2026-07-25 Ember/Abyssal Wyrm work): `ToxinStack` clones
the existing `game.ServerStorage.Assets.Cursey` prefab and just renames it — it will visually look
identical to a curse stack until someone with Studio access gives poison its own (green-tinted)
stack VFX. `Septic Burst`'s `Script.server.luau` references `script.Parent.Anim` the same way every
other move Tool does, but **no `Anim` instance exists yet** — Septic Burst will run with no animation
until one is added in Studio under `ServerStorage/Classes/Septic Burst/`. Its sounds
(`HumanoidRootPart.DaggerCharge`/`ShineStab`) are reused from Ethereal Strike's existing
generic per-character sounds, so those work today.

### Faceless blade path (TheBlade) — added 2026-07-25

Second of 3 planned Faceless paths (see TheToxin above). Same grant mechanism: `Knight`,
`teachskill(p,classdata.Faceless,true) == "max"`, `TotalGrips >= 20`. `dialogues.Knight.v1`'s
`pathoffer` page now has **two** choices (`"I embrace the venom."` → `TheToxin`, `"Show me the
blade."` → `TheBlade`) — this is the second branch anticipated when `pathoffer` was written, so a
3rd `elseif v.choice == ...` branch is exactly how the last path should be added too. `pathdone`
now checks both `TheToxin` and `TheBlade` so a player can't hold two Faceless paths.

**Design**: dual-dagger identity, not a new move-heavy kit — most of the work is reworking what
Faceless already has, gated on `data.Skills.Value:find("TheBlade")` in each file, mirroring how
`TheToxin` branches the same shared moves:

- **`Twinfang`** (`ServerStorage/Weapons/Twinfang/`) — a new equippable weapon (not a taught
  skill): 8-hit M1 combo vs. `Weapons/Dagger`'s 5, weaker per hit (2.25/3.25 finisher vs. Dagger's
  3.5/5) but faster (base swing gap ~0.23s vs. Dagger's ~0.3s — deliberately just behind
  Dagger-with-Agility's ~0.217s, since Agility still stacks on top via the same
  `Boosts/AttackSpeedBoost`-divides-the-debounce mechanic Dagger already uses, per the design ask
  "you keep the skill Agility"). Registered in `commands.ChangeWeapon`
  (`ServerScriptService/Modules/Commands/init.luau`, both the lightweight `dont`-branch and the
  real clone-and-weld branch — mirrors the `Caestus` two-cosmetic-piece weld pattern, the closest
  existing precedent to a dual-wielded look, since there's no prior true dual-wield mechanic in this
  codebase) with `Weapon.Value = "Dagger"` (category) / `PrimaryWeapon.Value = "Twinfang"`
  (specific) — the `"Dagger"` category keeps `RequiresWeapon == "Dagger"` moves (Dagger Throw,
  Triple Dagger Throw) working while it's equipped. **It is purchased, not taught**:
  `dialogues.shop` (`DialogueHandler/ModuleScript.luau` ~13000) already handles
  `Type.Value == "PrimaryWeapon"` generically via `commands.ChangeWeapon`, so the only code change
  needed was a gate (`display.Item.Value == "Twinfang"` → `Skills.Value:find("TheBlade")`, since
  `RequiresBpSkill`/`RequiresClass` don't fit a path flag) — **the actual shop stall/display object
  (with `Item`/`Price`/`Type`/`Shopkeeper` children) still needs to be placed in Studio**, same as
  any other world object per the Argon caveat at the top of this doc.
- **Bane and Shadow Fan are soft-removed**: both skills are still taught/owned normally (Faceless's
  `ClassData` skill list is untouched), but `Bane/Script.server.luau` and `Shadow Fan/Activator.luau`
  now return immediately if the caster has `TheBlade` — same "leave it in place, just make it inert"
  approach as the dead `GetClasses.luau` files, chosen because ripping skills back out of
  `Skills.Value`/`ClassData` for one path would complicate the other two paths' shared 5-skill list.
- **Agility is buffed instead of Bane**: `Agility/Script.server.luau` now plays a different sound
  for `TheBlade` owners (`HumanoidRootPart.BladeAgility` — **new Studio asset needed**, replacing
  `CrazySound`) and additionally drops a `Boosts/AgilitySprintAttack` marker for the buff's 10s
  duration. That marker is read in exactly one place:
  `CharacterHandler/Input.client.luau`'s `leftclick()`, which unconditionally called `Sprint(false)`
  on every attack (canceling sprint — confirmed by reading the function, this is *the* existing
  "can't run and attack" mechanic) — now skipped when the marker is present. Also fixed the
  `UpgradedAgility`/`p2.Backpack:FindFirstChild` bug while in this file (same class of bug flagged
  as still-open below for `Agility` and `Bane`'s `UpgradedBane`/`Chain Lethality` checks — now fixed
  for `Agility`, `Bane`'s own `UpgradedBane` check was left as-is since Bane is inert for this path
  anyway and touching it further wasn't needed).
- **Lethality** (`ServerStorage/Classes/Lethality/Activator.luau`) branches early for `TheBlade`
  into a new local `BladeLethality(p1,p2,data,buffed)`, entirely separate from the existing
  Chain-Lethality flurry code (left untouched for non-path Faceless players): a fast single-target
  cone check — hit lands a small opener, then a full-body `Transparency=1` invisibility window, a
  6-hit rapid flurry (mirrors the old flurry's shape, not its code) against the same target, then a
  strong `BodyVelocity` knockback to end it. **Miss = heavy endlag** (`Action` folder tag for 1.4s,
  matching the existing block-tag convention every `ActionCheck`-based move already reads). The
  `buffed` flag (auto-target, wider range, no whiff risk, +40% damage) is set when
  `Character/EtherealFollowup` is present — see Ethereal Strike below.
- **Ethereal Strike** (`ServerStorage/Classes/Ethereal Strike/Script.server.luau`) branches into a
  new local `BladeEtherealStrike`: a `BodyVelocity`-driven forward dash (100 studs/s, 0.35s) that
  hits everyone within 6 studs of the moving `HumanoidRootPart` once each (`hitAlready` table, same
  de-dupe idea as `Shadow Fan`'s per-target hit cap), playing
  **`game.ServerStorage.Classes.Shadowrush.Animation3`** — literally the existing Shinobi
  `Shadowrush` aerial spin animation, reused directly per the design ask ("Shadowrush aerial
  animation"). Confirmed safe: `LoadAnimation` just plays an animation asset, multiple Tools playing
  the same `Animation` instance don't interfere with each other or with Shinobi's own use. After the
  dash, two `Character`-parented markers open a ~1.5s window: `EtherealFollowup` (checked by
  `Lethality`'s `buffed` flag above) and `EtherealChain` (a `Direction` `Vector3Value` holding the
  just-dashed direction). Pressing Ethereal Strike again while `EtherealChain` exists **inverts**
  that direction and dashes back — cheap way to get "dash back and forth" without a longer state
  machine — and destroys `EtherealFollowup` in the process (per the design ask: chaining forfeits
  the buffed-Lethality option), then opens a fresh window so the back-and-forth can keep going.
  Using the buffed Lethality instead destroys both markers. Normal (non-`TheBlade`) Ethereal Strike
  behavior, including the `TheToxin` branch added earlier, is untouched — this is a third branch
  alongside those two, not a replacement.

**Interpretive calls worth flagging** (the design brief left these underspecified): the "8-9" hits
became a fixed 8; Twinfang's M2/heavy attack was left as a near-copy of Dagger's (not mentioned in
the design ask, kept only so equipping doesn't leave M2 non-functional); the dash-chain was built as
an unbounded ping-pong (each press just inverts direction and reopens the window) rather than a
capped number of bounces, since "dashing back and forth" read as open-ended; Twinfang's price and
shop NPC were left for whoever places the shop stall in Studio, no number was picked here.

**Update (still 2026-07-25): Twinfang's M1/M2 no longer need any dedicated animations or cosmetic
props** — reworked per follow-up design direction to reuse what already exists instead: hits 1-7 of
the 8-hit combo play a random `CombatAnims.Dagger1`-`Dagger5` swing (`math.random(1,5)` picked fresh
each hit), hit 8 (the knockback finisher) reuses the unarmed `Modules/m1.luau` combo's `Animation5`
(its finishing kick), and the heavy attack (`v1.Active2`) is Dagger's heavy attack unchanged — same
`DaggerHeavyAnim1`/`DaggerHeavyAnim2` animations, same damage. Both dagger props (main-hand and
off-hand) also now clone the existing `script["Mythril Dagger"]` cosmetic instead of needing
dedicated `LeftTwinfang`/`RightTwinfang` assets. This eliminated most of the originally-flagged
asset debt.

**Bug found and fixed**: `commands.ChangeWeapon`'s `Twinfang` branch clones `script["Mythril
Dagger"]` for the main-hand `clone`, but never renamed it — `clone.Name` stayed `"Mythril Dagger"`,
so `WeaponEquip.luau`'s dispatch (`if WEAPON.Name == "Twinfang"then ... elseif WEAPON.Name ==
"Bronze Dagger" or ... "Mythril Dagger" then ...`) matched the *generic* dagger branch instead of
the dedicated `Twinfang` one that actually knows about the `OffhandPiece` link — so the off-hand
blade's `PropWeld`/`Parent` never got set, and any code looking it up (`Weapons/Twinfang/Activator.luau`'s
`offhand` lookup) always got `nil`. Fixed with `clone.Name = "Twinfang"` right after the clone.
**If Twinfang is ever re-templated off a different source prop, remember to re-add this rename** —
nothing else will catch a missing/mismatched `WEAPON.Name` at parse time, it just silently falls
through to the wrong `elseif` branch.

**Asset debt still open**: `Agility`'s `BladeAgility` sound, and the `Twinfang` shop stall/display
object itself (world-placed, per above) — neither can be finished by editing files alone.

### Faceless master path (TheMaster) — added 2026-07-25

Third and final Faceless path — all three are now built. Same grant mechanism as the other two:
`Knight`, `teachskill(p,classdata.Faceless,true) == "max"`, `TotalGrips >= 20`. `pathoffer` now has
a third choice, `"I am beyond a name."`, and `pathdone` checks all three path skill strings so a
player can only ever hold one. Unlike `TheToxin`/`TheBlade`, `TheMaster` does **not** roll a random
`UberTitle` — it directly sets `data.FirstName.Value = "The Faceless"`, overwriting whatever page 3
of the base Faceless-teaching flow set (`"Faceless One"`/`"Fungless One"` for Scroom/Metascroom).

Where `TheToxin` and `TheBlade` each rework the kit around one new mechanic, `TheMaster` is a
synthesis path — every change is a targeted buff/tweak to something Faceless already has, gated on
`data.Skills.Value:find("TheMaster")` in each file, same pattern as the other two paths:

- **Agility + Bane become permanent, both nerfed.** Granted once at character spawn in
  `CharacterHandler/init.server.luau` (alongside the existing Faceless face-decal-removal check) as
  un-Debris'd (never-expiring) `Boosts/SpeedBoost` (2, down from Agility's 4) and
  `Boosts/AttackSpeedBoost` (3, down from 6), plus a permanent `BaneEff` accessory on the character.
  Both `Agility/Script.server.luau` and `Bane/Script.server.luau` now return immediately for
  `TheMaster` (the buttons are redundant since the effect is already always on) — same "leave the
  skill owned but make the button a no-op" approach as `TheBlade`'s Bane/Shadow Fan removal. Bane's
  nerf is two-layered: (1) no bonus free unarmed hit, since there's no "cast" moment to trigger it
  from; (2) `Weapons/Dagger/Activator.luau`'s `BaneEff` blink-behind-target check (hits 2/3/4 of the
  combo) now only has a **25% chance to actually trigger** when the caster has `TheMaster` — a
  normally-cast (temporary) `BaneEff` still procs every time, unchanged. This distinguishes
  "permanent, always-live `BaneEff`" from "the 10-15s window you get from actually pressing Bane"
  entirely by checking `Skills.Value:find("TheMaster")` at the point of the blink decision, not by
  tagging the `BaneEff` instance itself — if a future change ever gives some other path/skill a
  `BaneEff` grant that *isn't* meant to be chance-gated, this check needs to move from
  "does this player have TheMaster" to something on the `BaneEff` instance instead.
- **Ethereal Strike no longer ragdolls.** For `TheMaster`, `hitInfo.knockback` is cleared and
  `percent` drops from 20 to 15 (`Ethereal Strike/Script.server.luau`); the Stun + gentle push that
  replaces the old knockback is applied centrally in `TagHumanoid/Procs/FacelessPaths.luau` (which
  was restructured from a single `TheToxin`-only early-return into a proper per-path `elseif` chain
  to fit this in, alongside the untouched `TheToxin` branch) — reads as a combo starter/extender
  rather than a burst finisher.
- **Lethality lasts long enough to combo into an M1 string.** `Lethality/Activator.luau` computes a
  `master` flag once at the top of `v2.Active` (used across both the Chain Lethality and base
  branches, since `TheMaster` doesn't remove either): every hit's damage ticks up slightly (4→4.5,
  2→2.5), and — the part that actually matters for "you can start another m1 string" — the trailing
  `"Action"` recovery lockout on the base (non-Chain) branch drops from 0.7s to 0.1s. The Chain
  Lethality branch never had an explicit lockout of its own, so it already permitted a fast
  follow-up; only the base branch needed the fix.
- **Triple Dagger Throw becomes "Sixtuple Dagger Throw."** `Triple Dagger Throw/Activator.luau`'s
  3-dagger volley loop was extracted into a local `fireVolley(guaranteedTP)` function; `TheMaster`
  fires it twice (a 0.2s gap between), and only the second volley's `guaranteedTP=true` forces a
  teleport-to-target on hit (mirrors Shadow Fan's existing blink-strike, added inline in the
  `Touched` handler rather than as a new mechanic). "You can walk and throw" needed no code change —
  this move never applied a `WalkSpeed`/root lock to begin with (only `NoJump`/`Disarm`), confirmed
  by reading the file rather than assumed.
- **Shadow Fan's teleport hit guarantees poison and refunds cooldowns.** Still a 50/50 roll
  (`math.random(1,2)==1`) for everyone else, but `poison = master or (math.random(1,2)==1)` for
  `TheMaster`. The cooldown refund is an approximation, not a true "subtract N seconds": cooldowns
  in this codebase are just `NumberValue`s whose removal is a one-shot scheduled
  `game.Debris:AddItem` destroy with no way to query or reduce remaining time, so instead every
  child of `p1.Cooldowns` gets a `task.delay(3, ...)` force-destroy queued the moment the TP lands —
  functionally "no active cooldown can have more than ~3s left after this proc," which reads the
  same as "removes a few seconds" for anything longer than that, and is a no-op for anything that
  would've expired sooner anyway.
- **ShadowDash gets a shorter cooldown, longer range, and a tiny iframe window.**
  `CharacterHandler/init.server.luau`'s `Type == "shadow"` dash branch (a ray-cast-then-teleport,
  not velocity-based — confirmed by reading the code, shared with the `"dragon"`/`"UberDragon"` dash
  types via the same `LDashing`/`tpdashes` spam-limiter pattern): for `TheMaster`, the base
  `LDashing` gate drops from 0.2s to 0.1s, the spam-limiter threshold (dashes-in-3s before a 3.5s
  penalty kicks in) loosens from 5 to 7, dash range goes from 20 to 26 studs, and a `"NoDam"` tag is
  applied for 0.1s right as the teleport resolves — `"NoDam"` already reads game-wide as a
  damage-blocking tag (same tag the `TIMESKIP` effect uses for its own brief invulnerability window,
  `CharacterHandler/init.server.luau` ~3212), so no other file needed touching for the iframe to
  actually do anything.

No asset debt from this path — every change reuses existing tags/mechanics (`Stun`, `NoDam`,
`SpeedBoost`/`AttackSpeedBoost`, the existing Shadow Fan blink), nothing new needs to be built in
Studio.

## Recent work (2026-07-25)

- Fixed `DragonBloodUpgrade` (see Passives section above).
- Added two new Dragon Slayer paths, `TheEmberWyrm` (fire) and `TheAbyssalWyrm` (void/lifesteal),
  alongside the pre-existing but previously ungranted `StormHerald` (lightning). All three are now
  choosable via Fang once Dragon Slayer is fully learned (`ServerStorage/Classes/Dragon Roar`,
  `Thunder Spear Crash`, `Dragon Awakening`, `Wing Soar`, `Spear Crusher`, plus procs now in
  `TagHumanoid/Procs/DragonSlayerPaths.luau` — see the Refactor session note below for why that
  moved out of the old single `TagHumanoid.server.luau` file).
- **Asset debt incurred**: `TheEmberWyrm`/`TheAbyssalWyrm` currently reuse existing generic
  effects (`ThunderZoom`, `LightningS`/`LightningP`, `DragonRoarQuiet`, `WingFlap`/`MegaFlap`)
  recolored via `.Color`/`Color3` where the property allows it, rather than bespoke assets like
  `StormHerald`'s `HeraldZoom`/`LightningHerald`. If dedicated sounds/meshes are wanted for these
  two paths, they need to be added in Studio and wired in by name — the code branches are already
  in place to swap them in.
- Added `TheToxin`, the first of 3 Faceless (poison) paths — see "Faceless poison path"
  section below for the full design (stacking poison, reworked Ethereal Strike/Lethality, a new
  `Septic Burst` move, Emerald-enchant compatibility). Also incurs asset debt (see that section).
- Added `TheBlade`, the second of 3 Faceless (dual-dagger) paths — see "Faceless blade
  path" section below (new purchasable `Twinfang` weapon, Bane/Shadow Fan soft-removed, Agility
  reworked, Lethality/Ethereal Strike reworked into a dash-chain + invisible-flurry combo). Also
  incurs asset debt (see that section).
- Added `TheMaster`, the third and final Faceless path — see "Faceless master path" section below.
  A synthesis path (permanent nerfed Agility+Bane, Ethereal Strike/Lethality/Triple Dagger
  Throw/Shadow Fan/ShadowDash all tuned rather than reworked) — all three Faceless paths now exist.
  No asset debt.

## Refactor session (2026-07-25)

All 6 items below (as originally scoped) were addressed in a single dedicated session — see git log
from `571ea73` through `aac4778` for the incremental commits. What actually landed, and what's still
open, per item:

1. **Class-data unification — done.** `ClassData.luau` is now the single source; see Classes section
   above. The 2 genuinely-dead `GetClasses.luau` copies were left in place (inert, not worth fighting
   the Studio sync over) rather than deleted.
2. **`Info` schema — partial, deliberately.** `MoveInfoSchema.luau` documents all known flags as a
   reference, but is *not* wired into any runtime validation — actually validating live would mean
   touching all 194 move folders and `TagHumanoid` together, judged too risky for this pass. Still
   open: a real typo-catching check (e.g. a Studio-side lint script) would need to parse/grep every
   move file's `Info` table construction and cross-reference it against the schema automatically.
3. **Split `TagHumanoid`/`CharacterHandler` — safe subset only, by design.** Both files' core
   dispatch logic reassigns their central variables wholesale at several points (`TagHumanoid`
   swaps `character`/`enemy`/`humanoid` etc. at 5 counter/reflect points; `CharacterHandler`'s
   `Character.ChildAdded`/`ChildRemoved` and `Remotes.LeftClick`/`RightClick` read/write ~50 shared
   upvalues). Only the genuinely self-contained pieces were extracted — see the Directory layout
   entries for `TagHumanoid/Procs/`, `TagHumanoid/Helpers.luau`, and `CharacterHandler/Modules/`.
   **Still open and still risky**: the ~2900-line remainder of `taghumanoid()` and the
   `ChildAdded`/`ChildRemoved`/`LeftClick`/`RightClick`/`Chatted` handlers in `CharacterHandler` —
   don't attempt further splitting of these without the same care (map every read/write of the
   swapped-at-runtime variables first).
4. **`ActionCheck()` dedup — 118 of 130 files.** See Moves section above for exactly which 12 were
   left on their own local definition and why (each is a genuine behavioral outlier, not an
   oversight). If you add a new move file, prefer the shared module from the start.
5. **`wait()` → `task.wait(1/30)` sweep — scoped, not exhaustive.** Only the ~135 files already touched
   by this session's other changes were swept (444 occurrences). Repo-wide there are roughly 1000+
   remaining `wait()` calls, plus the flagged unused-local hints (`canuse`, `p2`, stray `TweenService`
   requires, etc.) across move scripts — still open, same "batch it when you're already touching the
   file" approach applies.
6. **Drift-check script — done.** `ClassDataDriftCheck.luau` runs at `GameLoaded` startup and warns
   (doesn't block) if `_G.MageClasses` references a class string `ClassData` doesn't produce. Already
   caught two real pre-existing drift cases on that list (a spacing mismatch and a stale `"Druid"`
   entry that was never a real class). No general test runner exists in this repo — this is a
   startup-time check, not CI.

**Known bug found but not fixed**: `ServerStorage/Classes/ModStop/Activator.luau` ends with a stray
trailing backtick after `return v6` — a real syntax error, unrelated to the refactor, found
incidentally while sweeping `ActionCheck`. Confirm with whoever has Studio access before touching it
(it's possible this script is already known-disabled) rather than assuming it's safe to just delete
the character.

Do not attempt further work on items 2/3/5 opportunistically inside unrelated feature work — the
same reasoning that applied before this session (dialogue engine and damage-resolution surface area)
still applies to what's left of them.

## Fixed: spontaneous death while ragdolled/knocked (2026-07-25)

Root cause was **not** `Ragdoll.luau`'s `Humanoid.RequiresNeck` (there's an unrelated, already-uncommitted
fix for a real race there — get-up code re-enables `RequiresNeck` before the Neck `Motor6D`'s `Part0`
is reconnected a few lines later; since Roblox's neck-death check runs off the physics step rather than
being gated by Lua's synchronous execution, that's a genuine bug worth keeping, just not this one) and
**not** the anti-cheat module (was fully disabled in the working tree and the deaths still happened).

Actual chain: getting knocked out sets `Humanoid.Health = 3` and tags the character `Knocked`/
`Unconscious` for 10s (`TagHumanoid/init.server.luau` ~2930), which drives `Ragdoll.luau`'s limp-body
physics. While ragdolled, `HumanoidRootPart.Velocity.y` can swing past `-40` from residual knockback
`BodyVelocity`/`BallSocketConstraint` physics with no relation to an actual fall. The client's fall-height
tracker (`CharacterHandler/Input.client.luau` ~2217, `u99`) had no exemption for that — it triggered
purely off velocity, accumulated a (physics-jitter-inflated) height, and fired `Remotes.ApplyFallDamage`
to the server with client-reported `Value` and no server-side plausibility check beyond `tonumber`.
Server-side, that self-fires `TagHumanoid:Fire(Character,Character,{falldamage=true, downbypass=true,
...})` (`CharacterHandler/init.server.luau` ~2118) — `downbypass=true` deliberately skips the normal
Knocked-state early-return guards, so it reaches `TagHumanoid/init.server.luau`'s `info.falldamage`
block (~2673), which — unlike the main damage path — has **no** clamp keeping a knocked player above
0 HP, and calls `_G.Death(Player)` unconditionally once the (inflated) damage crosses
`humanoid.Health + 100` (trivial when `Health` is already 3). No attacker, no combat log entry — reads
as fully spontaneous.

**Fix** (both applied, not mutually exclusive): (1) `Input.client.luau` ~2217 — don't start fall-height
tracking while `Knocked`/`Unconscious` is present, so the bad reading is never generated. (2)
`TagHumanoid/init.server.luau`'s `info.falldamage` block — both `_G.Death(Player)` branches now check
`not enemy:FindFirstChild("Knocked") and not enemy:FindFirstChild("Unconscious")` first, as a
server-side backstop in case some other path still generates a fall-damage event while a player is
already down. Other fall-damage behavior (injury, extending `Knocked`) is untouched — only the
unconditional-death branches were guarded, since `downbypass` still looks intentional for the softer
tiers.

`ServerScriptService/Modules/TemperatureHandler.luau`'s frostbite branch (~141) had the identical shape
— `humanoid.Health -=`/`_G.Death(player)` on a 0.2s-per-player world tick, completely outside
`TagHumanoid`'s clamp, no Knocked/Unconscious check — fixed the same way (early `return` if already
Knocked/Unconscious). A third instance, the `deathplague` curse DoT (`TagHumanoid/init.server.luau` ~703,
`Humanoid.Health = math.min(MaxHealth, Humanoid.Health - 1.25*curseCount)` over 6 ticks with no lower
bound), has the same "no floor, no Knocked check" shape but **was left alone** — it's DoT damage that
follows a landed hit from a real attacker, which is more plausibly intended than a background/self-fired
system finishing someone off with nobody attacking. If reports of "spontaneous" deaths persist after
this fix, `deathplague` and the void/`FellOutOfWorld` case (couldn't be confirmed or ruled out from
source — check `workspace.FallenPartsDestroyHeight` and whether ragdolled bodies ever clip through
terrain in Studio directly) are the next things to check.

## Additional cleanup found (2026-07-25, poison path session) — not yet addressed

Found while researching Faceless/Lethality for the poison path above; none of this was touched, it's
flagged for whoever picks it up next.

1. **Same `Backpack:FindFirstChild` trap as the already-fixed `DragonBloodUpgrade` bug, still live in
   2 more files.** `ServerStorage/Classes/Agility/Script.server.luau:23,35` checks
   `p2.Backpack:FindFirstChild("UpgradedAgility")`, and `ServerStorage/Classes/Bane/Script.server.luau:23`
   checks `p2.Backpack:FindFirstChild("UpgradedBane")` — both are plain skill strings (granted via
   `teachskill`, see `ClassData.luau` `Spy`/`Assassin`/`Faceless` entries) with no backing `Tool`
   folder, so per the Passives section above these checks are always `nil` and silently disable
   whatever cooldown/speed buff they're gating. `UpgradedBane` is literally in Faceless's own skill
   list — worth fixing alongside any future Faceless work. Same anti-pattern also showed up in
   `Lethality/Activator.luau:41` (`p2.Backpack:FindFirstChild("Chain Lethality")` — `Chain Lethality`
   has no `Tool` folder either), which may mean the "upgraded" 12-hit Chain Lethality flurry branch is
   currently dead code for every Faceless player, not just a balance question — confirm with Studio
   access before assuming it fires. Lower-confidence siblings worth a spot-check with the same lens:
   `MederiUpgrade`, `UpgradedHyperBody`/`UpgradedTitanBody` (naming pattern matches but not confirmed
   as flag-only).
2. **Undocumented god-files** (large, mixed-concern, not among the 3 already called out above):
   `StarterCharacterScripts/CharacterHandler/Input.client.luau` (2384 lines, all client weapon/keybind
   input), `WorldHandler/GameLoaded/init.server.luau` (2285 lines, mixes admin commands + class grants
   + bootstrapping), `ServerScriptService/Modules/Commands/init.luau` (1944 lines, monolithic chat-command
   dispatcher — this is also where `commands.UpdateSkills`/`commands.Learn` live, both touched by the
   poison path work above), `GameLoaded/CharacterCreationGui/CharacterCreationClient.client.luau`
   (1679 lines), `WorldHandler/MonsterControl/DecisionModules/Howler.luau` (1026 lines).
3. **Minor dead code**: `CharacterHandler/Input.client.luau:1872-1874` and `:2290-2296`, small
   commented-out blocks (a fog/ambient check, a stray `wait()`).
4. TODO/FIXME/HACK sweep and a stray-backtick/syntax sweep of `src/` turned up nothing new beyond
   what's already documented above (`ModStop/Activator.luau`) — noted here so nobody re-runs the same
   grep expecting different results.
