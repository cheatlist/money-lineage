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
| `HandOfGod` (1 of 3 Ronin paths so far) | `Linari` | Class == `Ronin` fully learned, `TotalGrips >= 15` | Katana M1, Swallow Reversal, sword-draw sound, Flowing Counter, Triple Slash — see "Ronin: Hand of God path" section below |
| `Shura` (2 of 3 Ronin paths so far) | `Linari` | Class == `Ronin` fully learned, `TotalGrips >= 15` | Triple Slash, Flowing Counter, Blade Flash (both M1 and M2), Swallow Reversal, Katana M2 — see "Ronin: Shura path" section below |
| `Selftaught` (3 of 3 Ronin paths so far) | `Linari` | Class == `Ronin` fully learned, `TotalGrips >= 15` | Katana M1 and M2, sword-draw sound, Flowing Counter, Calm Mind (renamed Arrogance), Triple Slash, Blade Flash (M1 only), Swallow Reversal — see "Ronin: Selftaught path" section below |

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

## New artifact: Exoskeleton (added 2026-07-27)

A movement-focused artifact, granted the same way as `Lannis`/`Unwavering Focus`: a consumable
`Tool` at `ServerStorage/Storage/Exoskeleton/Script.server.luau`, `Activated`-triggered, sets
`PlayerData.Artifact.Value = "Exoskeleton"` and drops an `Accessory` named `Exoskeleton` into
`Character.Artifacts` (same single-slot `Artifact` system as every other artifact — see Directory
layout / artifact notes above — so it competes with Lannis/Unwavering Focus/etc. for the one slot,
same as they compete with each other). **Asset debt**: the `Accessory` has no `Handle` mesh yet —
needs one added in Studio, same caveat as every other Argon-tracked binary asset in this repo.

Three of its four mechanical effects live entirely client-side in
`StarterCharacterScripts/CharacterHandler/Input/init.client.luau`, gated on
`FindFirstChild(Character.Artifacts, "Exoskeleton")` — no server-side changes were needed since
jump and the "normal" dash were already 100% client-trusted before this (see Dash/Acrobat notes
above; the `shadow`/`dragon`/`UberDragon` dash types remain server-gated as before and are
untouched):

- **Double jump, stacks with Whisper's `Acrobat` skill for a triple jump.** The old Acrobat-only
  jump block (`Enum.KeyCode.Space` handler, ~line 1462) used a boolean `JumpCool` marker (4s) as a
  crude "already used" gate, since only one extra jump was ever possible. That's now
  `MaxExtraJumps` (0-2, one from `Backpack:FindFirstChild("Acrobat")`, one from the Exoskeleton
  artifact) checked against a new `ExtraJumpsUsed` counter (declared ~line 939) that resets to 0
  on landing via a new `Humanoid.StateChanged` connection — so `JumpCool`'s duration was shortened
  4s → 0.15s (now just a same-frame debounce; the counter is what actually prevents over-use, and
  correctly allows a second extra jump within the same air time when both sources are owned).
  Acrobat's original "must press again within 0.5s of the last jump" feel (`AcrobatCD`) is
  preserved and re-used for the Exoskeleton jump too — both extra jumps chain off the same
  quick-press timing, not a state-based "still airborne" check.
  **Bug found and fixed (2026-07-27): the shortened `JumpCool` removed the real cooldown between
  separate uses.** `ExtraJumpsUsed` resetting on landing only caps extra jumps *within one airborne
  period* — it does nothing to stop immediately re-triggering on the very next jump/land cycle
  (bunny-hopping with a free double jump on every hop, no real cooldown at all). Fixed with a new
  `NextExtraJumpAt` timestamp (declared next to `ExtraJumpsUsed`), set to `tick() + 4` only when
  `ExtraJumpsUsed` goes from 0 → 1 (the first extra jump of a new air cycle) and checked only when
  `ExtraJumpsUsed == 0`, so it restores Acrobat's original 4s gate between separate jumps without
  blocking a second stacked jump (Acrobat + Exoskeleton both owned) from still chaining within the
  same air time.
- **Double dash, separate cooldown from the normal dash.** `Dash()` (~line 972) already gated
  re-use with a single `CanDash` boolean (client-only debounce — the "normal" dash type has no
  server-side cooldown enforcement at all, only `shadow`/`dragon`/`UberDragon` do). Added a second
  independent `CanDash2` charge (declared next to `CanDash`, ~line 444): if `CanDash` is false but
  the player owns Exoskeleton and `CanDash2` is true, the dash proceeds using the second charge
  instead of being blocked. Which charge was spent is tracked in a local `UsingSecondDash` flag set
  once per `Dash()` call and consulted at both of the function's cooldown-restore points (the
  early-return for `shadow`/`dragon` types and the end of the normal-dash roll); `CanDash2` restores
  after a flat 2s via `task.delay`, independent of `CanDash`'s own (type-dependent, ~0.2s-2.4s)
  restore timing — so the two dashes are back-to-back-capable but the second one is on its own
  clock, not just "the same cooldown twice."
- **Hold Space midair to fall faster, only after 0.5s airborne.** A new persistent loop (`sub(...)`,
  ~line 952, started once at script load, not per-keypress) tracks `SpaceHeld` (set on Space
  `InputBegan`/`InputEnded`) and `AirborneSince` (set by the same new `StateChanged` connection used
  for the jump counter, cleared on landing). Once `Humanoid.JumpPower ~= 0`, Exoskeleton is owned,
  the player isn't `Knocked`/`Climbing`, and `tick() - AirborneSince >= 0.5`, it holds a
  `BodyVelocity` named `FastFallVel` under `HumanoidRootPart` (Y-axis-only `MaxForce`, matching the
  `DodgeVel`/`Acrobat` convention of only forcing the axes you mean to override, tagged
  `"AllowedBM"` like every other player-applied `BodyVelocity`/`BodyPosition` in this file) at a
  flat `-90` studs/s downward velocity for as long as the hold+airborne conditions keep holding;
  releasing Space, landing, or losing the gate destroys it next tick. No existing "how long have I
  been airborne" timer existed anywhere in the codebase before this — it's new, reusable if a future
  feature needs the same signal.

The fourth effect, **reduced fall damage**, is server-side (added after the three above, since fall
damage is computed server-side and can't be client-trusted): `CharacterHandler/init.server.luau`'s
`Remotes.ApplyFallDamage` handler (~line 2153) already computed a `FallDamageReduction` multiplier
for `FeatherFall` owners (0.25, though the very next line clamps the whole multiplier to
`[0.4, 1]` — so `FeatherFall`'s *effective* floor is actually 0.4/60% reduction, not the 0.25/75% the
raw literal implies; worth knowing if you touch this block again). Exoskeleton adds its own
`math.min(FallDamageReduction, 0.5)` check ahead of that clamp — 50% reduction on its own (weaker
than dedicated `FeatherFall`, intentional: Exoskeleton is a general kit with this as one perk among
several, not a purpose-built fall-negation item), and if a character somehow has both (`FeatherFall`
is a Backpack Tool from certain classes, Exoskeleton is the separate `Artifact` slot — nothing stops
one character having both), the `min()` means the stronger reduction wins, still bottoming out at the
same shared 0.4 floor. `TagHumanoid/init.server.luau`'s separate `FeatherFall`-keyed sound/injury-
severity thresholds (~line 2725-2769) were deliberately left untouched — they branch on the
already-reduced `damage` value this handler produces, so Exoskeleton's reduction naturally shows up
there for free without needing its own parallel branch.

## New artifact: Charming Stone (added 2026-07-27)

Same single-slot artifact grant pattern as Lannis/Unwavering Focus/Exoskeleton:
`ServerStorage/Storage/Charming Stone/Script.server.luau`, sets `PlayerData.Artifact.Value =
"Charming Stone"`, drops an `Accessory` named `Charming Stone` into `Character.Artifacts` (no
`Handle` mesh yet — same asset debt as Exoskeleton's Accessory).

**On-hit proc** — `TagHumanoid/init.server.luau`, right after the Lannis block (~line 1064, inside
the same `if info.damage then` scope every other on-hit proc in that region reads from, e.g. the
`info.curse`/`info.gelidusfreeze` Lannis checks immediately above it): if the attacker
(`character`) owns the artifact, the target (`enemy`) isn't the attacker themself, and the target
doesn't already have a `CharmCD` marker, there's a flat 10% ( `math.random(1,10) == 1` ) chance per
landed hit to slap a `Charmed` marker (5s, via the shared `create(name, duration, parent)` helper
already used for every other timed marker in this file) and a `CharmCD` marker (10s) onto the
target **together, in the same proc** — not one triggered by the other firing later.

**Move-blocking** — a `Charmed` child on a move's caster now unconditionally blocks the move.
Rather than touching each of the ~130 individual move files, this was added as a hardcoded check
inside the shared `ServerScriptService/Modules/ActionCheck.luau` module itself (see that file's
top comment) — so it covers the 118 of 130 move files that already route through
`ActionCheckModule(Parent, options)` for free, with no other file needing to change. **The 12
files that keep their own local `ActionCheck` (see Moves section above) are not covered** — if
`Charmed` needs to be airtight, those 12 need their own `Parent:FindFirstChild("Charmed")` check
added by hand.

**Interpretive call on the two timers** (the design brief described them from the player's-eye
view — "a move fails once, can't fail again for 10s" — not in terms of which marker gates what):
implemented as `Charmed` (5s) and `CharmCD` (10s) being created **together** by the same proc, with
`CharmCD` gating whether a *new* proc can re-apply `Charmed` at all (the `not
FindFirstChild(enemy,"CharmCD")` guard above), rather than `CharmCD` being created reactively at
the moment a move actually fails. Since `Charmed` (5s) is always shorter than `CharmCD` (10s), the
observable result is the same either way — at most one "activation window" of failed move attempts
per proc, no back-to-back re-triggering for 10s — but this reading needed no state mutation inside
the otherwise side-effect-free `ActionCheck` module (which is called from every move script,
sometimes more than once per input, so any "clear Charmed / start cooldown" mutation living inside
it would have double-fired unpredictably). If a future change wants the cooldown to start exactly
at the failed-move moment instead, it has to move that `create("CharmCD", 10, ...)` call into
`ActionCheck.luau` itself, accepting that per-call-site risk.

## New artifact: Playful Stone (added 2026-07-27, revised same day after design feedback)

Same single-slot artifact grant pattern as the others (`ServerStorage/Storage/Playful Stone/Script.server.luau`,
`data.Artifact.Value = "Playful Stone"`, `Accessory` marker in `Character.Artifacts`, no `Handle`
mesh yet — same asset debt as Exoskeleton/Charming Stone). A "luck" artifact with five small,
independent probability nudges, each hooked into a different existing system rather than built as
one new mechanic. Two of the five (#2 and #4 below) were redesigned after the first pass
misread the brief — the original "iframe on move use" and "server-wide scroll odds" versions are
gone, replaced by what's described here.

1. **Randomly bigger hitboxes** — `ServerScriptService/Modules/HitDetection.luau`, top of both
   `Module.magnitudeCheck` and `Module.magnitudeCheckNew` (the two real chokepoints every move's
   `Range` argument flows through — confirmed `Info.aoe` is a boolean cone-skip flag, *not* a size
   value, so the multiplier has to apply to the raw `Range` positional argument itself): 1-in-5
   chance per hit-check call to multiply `Range` by 1.3 for that call. Guarded with
   `FindFirstChild(Character,"Artifacts")` before dot-indexing into it (unlike the Bloodring/Charming
   Stone attacker-side precedent elsewhere, which assumes `character.Artifacts` always exists) since
   `Character` here can in principle be a monster/NPC caller through the same shared function, not
   only a rigged player character. `Module.SMag` (a separate, less-used AoE path for a handful of
   monster moves like Terra Serpent) was left untouched — different calling convention
   (`info.range`/`info.length`/`info.width`), not worth the same treatment for its narrow caller set.
2. **Sometimes nulls incoming damage outright, 20s cooldown** — `TagHumanoid/init.server.luau`,
   inside the `if not blocked then ... local dodged = false` section (~line 1706), right before the
   existing `WindDodges` (Fischeran racial) check — the closest real precedent for "fully no-sell a
   landed hit": `WindDodges` sets `info.damage = 0` and `dodged = true` rather than an early
   `return`, so the rest of the function's downstream processing treats it as a zero-damage hit
   instead of skipping everything else outright; Playful Stone's version does exactly the same thing.
   Gated on the defender (`enemy`) owning the artifact, `info.damage > 0`, not `info.nododge`
   (respects moves that are meant to be undodgeable), and not already having a `LuckDodgeCD` marker;
   1-in-10 roll, and on success creates `LuckDodgeCD` for 20s (via the file's existing
   `create(name,deletetime,parent)` helper) so it can't retrigger before then. This replaced an
   earlier "iframe on move activation" version that was a misread of the brief — the ask was about
   *getting hit*, not *using* a move, so that version (which lived in
   `CharacterHandler/init.server.luau`'s `RightClick` dispatcher) was removed outright.
3. **Sometimes just doesn't backfire** — `ServerScriptService/Modules/SpellModule.luau`,
   `module.cast` (the classic spellcasting path with a real backfire concept; `module.castnew`, used
   by `Rework`-tagged tools, has no mana-window check at all, so there's nothing to save from there):
   right before the existing `mana >= info.lowerbound and mana <= info.upperbound` window check,
   a 1-in-5 roll for `Playful Stone` owners returns `true` (successful cast) outright, independent of
   whether the mana window would've been missed — mirrors the already-dead-but-real `Boosts:FindFirstChild("GuaranteedCast")`
   bypass on the same line, and the same shape as commented-out `Philo`-artifact code a few lines
   above it (left alone, unrelated artifact).
4. **Better odds at the existing scroll-gambling NPC, Xenyari.** The first pass invented a brand
   new NPC ("Fortuna") for this, wrongly assuming no gambling NPC existed — it did, and has since
   been removed. The real one is `dialogues.Xenyari` in
   `ServerScriptService/WorldHandler/Dialogues/DialogueHandler/ModuleScript.luau`
   (`function dialogues.Xenyari.v1(p,v)`, ~line 11559): a once-per-in-game-day roll
   (`data.LastGacha.Value ~= data.DaysSurvived.Value`) for 250 Money that already had its own pity
   system — `data.GachaLuck.Value` is a persistent per-player counter that increases (+10 normally,
   +30 on the `MageShield` path) every time the roll *doesn't* land the rare scroll(s), temporarily
   added to those entries' weight in the shared `rolling`/`magerolling` tables (file-top locals,
   ~line 12) right before calling the file's own `ChooseWeightedItem` (a separate, simpler
   implementation of the same idea as `TrinketsHandler`'s function of the same name — no relation,
   don't confuse the two), then subtracted back out afterward so the base tables are never
   permanently mutated, and reset to 0 the moment the rare scroll actually lands. `Playful Stone`
   hooks into this pity math directly rather than adding a parallel roll: a new local `luck` is
   captured from `data.GachaLuck.Value` *before* the persistent `+= 10`/`+= 30` pity increment, with
   `+100` added on top if the player owns the artifact, and that `luck` value (not
   `data.GachaLuck.Value` itself) is what gets temporarily added to/subtracted from the rare-scroll
   weight(s) for this roll. This only biases the current roll — the persistent pity counter and its
   reset-on-success behavior are completely untouched, so Playful Stone stacks with pity rather than
   interfering with it. (The original code computed the "value before the +10/+30" by subtracting
   10/30 back off the mutated `data.GachaLuck.Value` after the fact, a quirky-but-correct trick;
   capturing `luck` up front before the mutation is equivalent for non-owners and was necessary once
   a second source needed to feed into the same before/after pair.)
5. **Rarer world spawns, server-wide, scaling with online Playful Stone users** —
   `ServerScriptService/WorldHandler/Trinkets/TrinketsHandler.server.luau`. Confirmed there's no
   per-player roll moment in this system (trinkets are decided at spawn time, not at pickup — see
   `#4` above for why that ruled out a *personal* reading here), so this is intentionally a shared,
   whole-server effect: the main spawn loop (`while task.wait(10) do`) counts currently-online
   players whose `PlayerData.Artifact.Value == "Playful Stone"` once per tick and derives
   `LuckBonus = count * 500`, passed into every `ChooseWeightedItem(tables, luck)` call that tick.
   `ChooseWeightedItem` (via a cloned copy of the relevant `spawnrates` sub-table, so the shared
   table itself is never mutated) now does two things with that number, not just one: shrinks the
   `"Nothing"` (no-drop filler) entry's weight by the flat `luck` amount (same as before), **and**
   separately scales up every non-junk entry's weight by `+ (luck/1000)` proportionally — junk being
   a new `CommonJunk` lookup table (`Nothing`, the various `Amulet`/`Ring`/`Goblet`/`Idol` filler
   entries, and the gem tier `Opal`/`Sapphire`/`Emerald`/`Ruby`/`Diamond`) so the boost only touches
   the genuinely rare stuff (scrolls, essences, the named artifacts) rather than inflating already-common
   junk drops too. This is the piece the brief specifically called out as "server-wide, not per
   individual" — it applies to every spawn roll everyone sees, not gated to only benefit the artifact
   holder's own pickups.

## Ronin: Hand of God path (added 2026-07-27)

First of three Ronin paths (see "Ronin: Shura path" and "Ronin: Selftaught path" below for the
other two, both added the same day) — mirrors
how `TheToxin` was written to anticipate `TheBlade`/`TheMaster` later, see the Faceless-path notes
above. Granted by **`Linari`** — already the existing NPC that teaches Samurai then Ronin
(`dialogues.Linari.v1`, `ModuleScript.luau` ~line 10063 pre-edit — teaches `classdata.Samurai` to
`"max"`, then `classdata.Ronin` one skill at a time) — once `teachskill(p,classdata.Ronin,true) ==
"max"` and `data.TotalGrips.Value >= 15` (same stat/threshold Fang already gates the Dragon Slayer
paths on, reused rather than inventing a new one, per the established convention). `pathoffer` has
three choices — `"I am the Hand of God."`, `"I embrace the way of the Shura."`, and (added same day
for Selftaught) `"I am Selftaught."`; all three branches live on `v.page == 2`, disambiguated by
`v.choice` from each other *and* from the pre-existing "buy a Ronin skill" flow that also lands on
page 2, same pattern as every other Faceless/Dragon-Slayer path page-sharing case documented above.
`pathdone` checks all three skill strings so a player can only ever hold one. Grants the flat skill
string `HandOfGod` (`data.Skills.Value ..= ",HandOfGod"` + `commands.UpdateSkills(p)`), no random
flavor `UberTitle` this time (none was asked for, and the six mechanical reworks below already do a
lot — didn't want to pad this with invented title lists). Same for Shura's `"Shura"` and
Selftaught's `"Selftaught"` skill strings.

Every mechanical change is gated on `data.Skills.Value:find("HandOfGod")` (or the equivalent
Backpack/Skills check available at that call site), in the file already responsible for the thing
being changed — no new central "Ronin path" module, matching how Faceless paths are just scattered
`data.Skills.Value:find("TheX")` branches through existing files rather than a new abstraction:

1. **Katana M1 — less spammable, faster, harder-hitting, longer stun.**
   `ServerStorage/Weapons/Katana/Activator.luau`, `v1.Active`. "Less spammable" is a genuinely new
   gate, not a tweak to the existing combo-timer math (`v4`/`ComboTimer`/the `0.5+v4`/`0.8+v4`
   dead-zone) — that logic is shared with every non-HandOfGod Katana user and was left completely
   untouched to avoid destabilizing it. Instead, a brand new `HandOfGodCD` Folder marker (0.4s, via
   `Debris:AddItem`) is created every swing and checked at the top of `v1.Active` as an independent
   hard floor — the vanilla combo timer alone allows near-continuous mashing (`wait(0.1/v12)` between
   swings, ~0.04-0.07s typically), so a 0.4s floor is a real, noticeable slowdown in *repeat rate*
   even though each individual swing now plays and resolves faster: animation speed gets an extra
   `*1.4`, the pre-damage `wait(0.1/v12)` gets cut to `*0.6`, damage gets `*1.4`, and `hitInfo.stun =
   0.6` overrides the katana-hit default of `0.35` (confirmed via `TagHumanoid/init.server.luau:2128`,
   `if info.stun then stun = info.stun end` — a real, already-supported per-hit override, not
   something new). The M1 slash sound (`HumanoidRootPart.KatanaSlash`, a per-character Sound reused
   by every Katana move in every file) gets `PlaybackSpeed = 0.75` set **in-place** right before
   `:Play()` for HandOfGod, `1` (the known-safe absolute normal) otherwise — safe specifically because
   every call site that plays this shared instance now stamps an absolute value immediately before
   playing, so there's no cross-file drift regardless of call order. (Volume was **not** touched here
   — the brief only asked to pitch M1 audio, not make it louder; contrast with Triple Slash and the
   draw sound below, which explicitly asked for both.)
2. **Swallow Reversal replaced outright (M1 only) — stationary 10x10 AoE burst.**
   `ServerStorage/Classes/Swallow Reversal/Activator.luau`, `v1.Active`. A new branch at the very top
   returns before reaching any of the vanilla dash-multihit code, so non-HandOfGod Ronins (and
   Samurai, which also owns this move) are completely unaffected. Plays
   `game.ServerStorage.Classes["Blade Flash"].M1Anim` (cross-move Studio-asset reuse, same pattern as
   `TheBlade`'s reuse of `Shadowrush.Animation3` documented above) instead of loading its own
   `Windup`/`BladeDance`/`Finisher` animation set. Spawns a `10,10,10` white `Neon` `Part`
   (`Anchored = true`, `CanCollide = false`, matching this codebase's one consistent VFX-part
   convention — see `EffectModule.luau`'s `sakuraeffect`), positioned 8 studs in front of the caster,
   hit-tested via a `part.CFrame:inverse() * target.HumanoidRootPart.CFrame` box-overlap check
   (**not** `HitDetection.magnitudeCheck`, since that function only does spherical/magnitude checks
   and this needed to be box-shaped "everyone inside" — the box-check math itself isn't new, it's the
   same idiom this same move's own vanilla `Active2` already uses a few dozen lines down), dealing a
   flat 22 `blockbreak`/`noparry`/`manabreaker` hit, then `TweenService`-fades `Transparency` to `1`
   over 2 seconds and gets `Debris`-cleaned. Reuses the move's existing 15s cooldown unchanged.
   **Scope note**: only `Active` (M1) was replaced — `Active2` (the vanilla dash-lunge M2) was left
   completely untouched, since the brief described one new ability, not two; if Hand of God is meant
   to lose the M2 lunge as well, that's a follow-up.
3. **Sword-draw sound — louder and lower-pitched.**
   `StarterCharacterScripts/CharacterHandler/Modules/WeaponEquip.luau`. All four call sites that
   played `HumanoidRootPart.KatanaUnsheathe:Play()` directly (equip ×2 for Katana/Murasama, unequip
   ×2 for the same) now route through one new local `playKatanaDraw()` helper (defined once, top of
   the module's returned closure, alongside the existing `eqstackcheck` local — every call site
   already had `PlayerData`/`HumanoidRootPart` in scope as closure parameters, so no signature
   changes were needed anywhere). Unlike the M1 slash sound above, this **clones** the Sound instead
   of mutating it in place — Volume's baseline isn't a known-safe absolute the way `PlaybackSpeed`'s
   `1.0` is, so reading the *live, always-untouched* `draw.Volume`/`draw.PlaybackSpeed` off the real
   instance and multiplying onto a throwaway clone (`Debris`-cleaned after 3s) avoids ever needing to
   know or restore a true baseline.
4. **Flowing Counter reworked — punish instead of a fixed 10-damage counter.**
   `TagHumanoid/init.server.luau`, the `enemy:FindFirstChild("FlowingParry")` block (~line 729) —
   **not** the move's own `ServerStorage/Classes/Flowing Counter/Activator.luau`, which still only
   sets the `FlowingParry` stance marker and is completely unchanged; the actual counter-hit resolution
   was always here, same file/pattern as the neighboring (and structurally distinct) `FULLPARRY` block
   just below it. The vanilla path here has a real quirk worth knowing if you touch this block again:
   it overrides `info` to a fixed table and reassigns `enemy`/`enemydata`/`ehumanoid`/`eroot` to the
   *original attacker's* own data, but **never reassigns `character`** — so after this runs,
   `character` and `enemy` both end up pointing at the original attacker, and any later code in this
   same pass that reads `character` (e.g. the `character.Boosts:FindFirstChild("MeleeDamageMultiplier")`
   check a few lines below) is reading the attacker's boosts, not the parrier's, even though this is
   supposed to be the parrier's counter-hit. This is the same "self-fire loses the original identity"
   shape flagged in the Faceless-poison-path notes above for the Emerald gem proc — not something this
   session fixed (out of scope), but it's exactly why the Hand of God branch below sidesteps the
   whole swap instead of extending it. When `enemydata` (the parrier, before any reassignment) has
   `HandOfGod`: captures `parrier = enemy` and `victim = character` into locals first (so their
   identities survive regardless of what the vanilla path below would have done), plays a random
   one of two dodge animations (`script.Dodge[math.random(1,2)]` — `Dodge` is a folder of real
   Animation instances parented directly under the `TagHumanoid` script itself, not
   `ReplicatedStorage.CombatAnims`; **note this was corrected from an earlier draft of this session
   that guessed `combatanims.Dodge1`/`Dodge2`, which didn't exist**), waits 0.2s, applies an explicit
   `create("Stun", 1, victim)`, plays `combatanims.MonkPunch5` (reused from the existing Monk
   unarmed-combo animation family — see `ServerScriptService/Modules/m1.luau`'s `combatanims["MonkPunch"..combo.Value]`
   — **also corrected from an earlier guess of a nonexistent `combatanims.AdvancedPunch5`**), then
   fires a **brand new independent** `TagHumanoid:Fire(parrier, victim, {damage = math.random(15,20),
   fist = true, blockbreak = true, manabreaker = true, ...})` and `return`s — deliberately not
   falling through to the vanilla self-fire swap at all, so the parrier is correctly credited as the
   attacker for this hit (this file already fires itself recursively elsewhere, e.g. the
   `{poison=true,...}` self-fires documented above, so re-entering `TagHumanoid` from inside itself
   is an established, safe pattern here). No remaining asset debt — both animations now reference
   real, already-existing assets.
5. **Triple Slash — slower, harder-hitting, longer stun, "fully true," pitched/louder slashes.**
   `ServerStorage/Classes/Triple Slash/Activator.luau`, `v1.Active`. Animation speed drops from a
   flat `1.3` to `0.9` for HandOfGod (genuinely slower, unlike Katana M1 above which got faster — the
   brief was explicit these are opposite designs). Base per-slash damage `7 → 10`, finishing-hit
   damage `10 → 15` (the finishing-hit override already existed per-combo-index at `u3 == 3`/`u3 == 4`
   depending on `TripleSlashTraining` ownership — both branches were updated identically). **"Fully
   true" has no prior formal concept anywhere in this codebase** (confirmed — grepped for
   "true combo"/"truecombo" project-wide, zero hits) so it's implemented here as the closest
   approximation using flags that already exist and are already read by `TagHumanoid`:
   `nododge = true`, `noparry = true`, `blockbreak = true` added to the combo's shared `u4` info
   table for HandOfGod, so once a slash starts landing, nothing in the existing defensive-interaction
   vocabulary (WindDodges, Playful Stone's own dodge, FlowingParry/FULLPARRY, Blocking) can escape the
   rest of the combo. `u4.stun = 0.6` is the "Stun longer" the brief called out as tied to this same
   change, same `info.stun` override mechanism as Katana M1. The per-slash `KatanaSlash` sound uses
   the **clone-and-boost** approach (not Katana M1's in-place mutation) since this needed both pitch
   *and* volume changed and Volume's baseline isn't a safe absolute to assume, same reasoning as the
   draw-sound helper in item 3.

**Interpretive calls worth flagging**: exact numbers throughout (0.4s M1 cooldown floor, `1.4x`/`1.5x`
damage and speed multipliers, `0.6`/`0.75`/`0.8` pitch factors, 15-20 counter damage, `TotalGrips >=
15` gate) were picked to feel like a coherent "heavier, more deliberate, punishes mistakes harder"
kit per the brief's overall direction, not derived from any balance spec — flag for tuning. "Fully
true" specifically is a judgment call on how to express a combo-mechanics concept this codebase has
never had before; if a future path wants the same idea, `nododge`/`noparry`/`blockbreak` together is
the pattern to reuse rather than inventing a new flag.

## Ronin: Shura path (added 2026-07-27)

Second Ronin path, granted the same way as Hand of God: `Linari`, `teachskill(p,classdata.Ronin,true)
== "max"`, `data.TotalGrips.Value >= 15`, mutually exclusive with `HandOfGod` via `pathdone`. Skill
string `Shura`. Where Hand of God is "heavier and more deliberate," Shura is the opposite read of the
same brief — extended combos, stealth, tempo tricks — so every file below branches on
`data.Skills.Value:find("Shura")` as a sibling to (never combined with) the existing `HandOfGod`
branches, same files, same pattern, no new abstraction:

1. **Triple Slash → Sixtuple Slash.** `ServerStorage/Classes/Triple Slash/Activator.luau`,
   `v1.Active`. For Shura, always uses the plain `Anim` (never `Anim2`, and never stacks with the
   `TripleSlashTraining` 4th-hit variant — deliberately kept to a clean 2×3=6 rather than an awkward
   2×4=8 edge case, since a Shura Ronin plausibly also owns `TripleSlashTraining`). "Play the
   animation twice" is implemented literally: an `AnimationTrack.Stopped` connection (registered
   after `local u3 = 0` is declared — an ordering bug caught and fixed during this same session, since
   a closure referencing `u3` before its `local` declaration would've captured a phantom global
   instead) replays `v7:Play(...)` whenever it finishes and `u3 < 6`, so the same animation's 3
   baked-in `"slash"` marker keyframes fire twice, taking the hit counter from 3 to 6 instead of
   requiring new animation assets. The finisher check (`u3 == 3`/`u3 == 4` in vanilla) becomes
   `u3 == 6` for Shura. Client VFX reuses the existing `TriSlash1`/`TriSlash2`/`TriSlash3` assets for
   *both* passes via `fxIndex = ((u3-1) % 3) + 1` — deliberately not firing `"TriSlash4"` etc., which
   don't exist client-side. "Recolor the slashes" sets `p4.TestTrail.Color` (the weapon prop's Trail,
   already toggled on/off by this move) to a fixed crimson `ColorSequence` for the duration, restored
   from a captured `originalTrailColor` right before the function's own `en = true` — safe to mutate
   in place (unlike the Sound pitch/volume cases elsewhere in this session) because there's a single
   clear "before/after the whole move" bracket to restore within, no cross-call drift risk.
2. **Flowing Counter uses Spite.** `TagHumanoid/init.server.luau`, same `FlowingParry` block as Hand
   of God's rework, a sibling `elseif enemydata.Skills.Value:find("Shura")` branch. `Spite`
   (`ServerStorage/Classes/Spite/Script.server.luau`) turned out to **not** be a requireable
   `Activator` module like every other move referenced in this session — it's a bare `Tool.Activated`
   listener Script with no exported function and no `p2`/`p3`/`p4` argument convention, so there was
   no clean way to call into it from another script. Its short self-contained logic (a
   ~13.5-stud-radius circular blink-spin over 0.3s in 0.05s ticks, physically relocating the caster's
   `HumanoidRootPart` each tick and AoE-hitting via `HitDetection.magnitudeCheck`) was adapted inline
   into the `Shura` branch instead — required a new top-of-file `local HitDetection =
   require(game.ServerScriptService.Modules.HitDetection)` in `TagHumanoid/init.server.luau` (wasn't
   needed there before; every other hit in this file is either an incoming `info` table or a
   self-fire, never a fresh `magnitudeCheck` call). Plays `Spite`'s own `Animation3` and
   `HumanoidRootPart.DaggerCharge` sound (both already-existing Spite assets, reused directly).
3. **Blade Flash M1 is instant.** `ServerStorage/Classes/Blade Flash/Activator.luau`, `v1.Active`.
   For Shura, skips `M1Anim`/the `"handle"` marker wait entirely — the exact same forward target-scan
   loop the vanilla code runs (LastName/team-check, `CFrame:inverse()` box test, 29-stud range) is
   copied inline and resolved synchronously, so damage lands the instant the button is pressed.
   "High pitched slash sound reused from existing assets": clones `HumanoidRootPart.KatanaSlash`
   (already used by every other Katana move in this session, guaranteed to exist) with
   `PlaybackSpeed * 1.8`, instead of the vanilla `SwordCharge`/delayed-`KatanaUnsheathe`/cloned-`Sheathe`
   sequence — no new sound asset needed.
4. **Swallow Reversal — both M1 and M2 faster, lower cooldown.** `ServerStorage/Classes/Swallow
   Reversal/Activator.luau`. Both `Active` and `Active2` already shared one cooldown key
   (`"Swallow Reversal"`, confirmed by reading both — not something this session needed to unify), so
   lowering it once (`shura and 10 or 15`, both the `CD.Value` and matching `Debris:AddItem` calls,
   plus the functions' own trailing `wait(15)`s at the end) covers "both variations" together. Applies
   only to the **vanilla** body in each function — Hand of God's M1 already fully replaces `Active`
   and returns early before reaching any of this, so the two paths' changes can never collide.
   "Faster": windup/dance/M2 animation speeds bumped (`1 → 1.4`, `1.3 → 1.7`), M1's dash-traversal
   speed increased (divisor `85 → 130` studs/s), M2's forward-lunge `BodyVelocity` increased
   (`250 → 350`).
5. **Blade Flash M2 — invisibility toggle instead of an immediate dash-strike.** Same file, `v1.Active2`
   was restructured: the entire vanilla dash-strike body was extracted into a new `local function
   runBladeFlashM2(p4,p5,p6,p7)` (verbatim, unchanged), and `v1.Active2` became a thin dispatcher.
   **First Shura press**: consumes the 20s cooldown, grants invisibility (a `NumberValue` named
   literally `"Transparency"` under `Character.Boosts`, `Value = 1` — it *must* be named exactly that
   to be picked up by `CharacterHandler/init.server.luau`'s `Boosts.ChildAdded` listener, the actual
   game-wide render trigger for invisibility documented in this session's research; every other
   invisibility effect in this codebase — Lethality, the vanilla Blade Flash M2 dash-window, The
   Shadow — already goes through this same convention), plus a `"ShuraStealth"` Folder marker on the
   Character, and returns *without* attacking. Because `Boosts` can hold multiple same-named
   `"Transparency"` children simultaneously (summed together — confirmed from the listener's own
   code), the specific instance created here can't be found again later by name alone if the player
   happens to be under some other transparency effect too — so a small `ObjectValue` named
   `"TransparencyRef"` pointing at it is parented under the `ShuraStealth` folder, giving later code
   an unambiguous reference to destroy. **Second Shura press on M2** ("double down"): finds
   `ShuraStealth`, destroys it and the referenced Transparency instance, then calls
   `runBladeFlashM2(...)` directly — deliberately *not* re-checking or re-consuming the cooldown,
   since press #1 already did. **Pressing M1 instead** ("surprise attack"): a new check at the very
   top of `v1.Active`, before even `ActionCheck`, unconditionally clears `ShuraStealth` and its
   Transparency reference if present, then falls through into Blade Flash's own (already-instant, per
   item 3) M1 — composes for free, no extra code needed for the "surprise attack" itself. Scoped
   deliberately narrow: only *this Tool's own* M1 breaks stealth this way, not Katana's separate M1
   weapon Activator or any other move — touching every possible source of an M1 press was judged out
   of scope for one path. A 8-second `Debris` safety timeout on all three instances
   (`ShuraStealth`/`Transparency`/`TransparencyRef`) guarantees a player can never get stuck invisible
   forever by simply not pressing anything again.
6. **Katana M2 stuns instead of knocking back.** `ServerStorage/Weapons/Katana/Activator.luau`,
   `v1.Active2`'s 3-iteration hit-attempt loop: `knockback = not shura` (was unconditionally `true`)
   and a new `stun = shura and 1.2 or nil` added to the same `Info` table passed to
   `HitDetection.magnitudeCheck` — same `info.stun` override mechanism used throughout this session
   (`TagHumanoid/init.server.luau:2128`). `nil` as a table value is equivalent to omitting the key
   entirely, so non-Shura players see no change to the `Info` table shape at all.

**Interpretive calls worth flagging**: exact numbers (10 studs, 1.8x/1.4x speed multipliers, 8s
stealth-safety timeout, 1.2s M2 stun, the crimson trail color, `RADIUS`/`DURATION`/`TICK` inherited
directly from Spite's own values) are again feel-based, not spec-derived — flag for tuning. The
Spite-adaptation (item 2) and the Sixtuple replay mechanism (item 1) are the two genuinely novel
techniques introduced this session — neither move-reuse-without-a-clean-API nor animation-replay
had prior precedent anywhere in this codebase to copy from.

## Ronin: Selftaught path (added 2026-07-27)

Third Ronin path, same grant mechanism as the other two (`Linari`, `TotalGrips >= 15`, mutually
exclusive via `pathdone`), skill string `Selftaught`. Where Hand of God is disciplined/heavier and
Shura is stealthy/tempo-based, Selftaught is the "no formal style, borrows from everywhere,
gambler's payoff" read of the brief — every effect either mixes in an unarmed technique that
doesn't belong to Katana at all, or trades a defensive/safety property (invisibility, aim-lock,
predictable output) for more damage or a new risk. Two genuinely new mechanics were built this
session with no prior codebase precedent to reuse (documented in full below): a server-loaded
default-Roblox emote (item 4) and a live-steerable server hit-line (item 8).

1. **Katana M1 mixes in MonkPunch animations.** `ServerStorage/Weapons/Katana/Activator.luau`,
   `v1.Active`: a new module-level `local combatanims = game.ReplicatedStorage.CombatAnims` (wasn't
   previously required in this file — Hand of God/Shura's earlier edits to this same file never
   needed it, since Shura's Katana M2 change uses `combatanims.MonkPunch5` inline via the module
   already required in `TagHumanoid`, not here) backs a 50/50 `math.random(1,2)` swap: each swing
   plays either the vanilla `p3["Katana"..Combo.Value]` or `combatanims["MonkPunch"..Combo.Value]`,
   re-rolled fresh every hit. Purely a visual swing-animation substitution — damage, stun, the combo
   counter, and every other Katana M1 mechanic (all untouched by this path) still apply exactly as
   the weapon's own hit resolution already computes them; this doesn't turn any hit into an actual
   unarmed one.
2. **Slower katana draw, lower pitch.** `WeaponEquip.luau`'s `playKatanaDraw()` helper (added for
   Hand of God, reused here): a new `elseif` branch clones the shared `KatanaUnsheathe` Sound with
   `PlaybackSpeed * 0.6` (a bigger drop than Hand of God's own `* 0.8`). Read "slower... but lower
   pitch" as the same single knob rather than two separate asks — lowering `PlaybackSpeed` both
   extends a Sound's playback duration and drops its pitch simultaneously, so one multiplier covers
   both halves of the brief.
3. **Flowing Counter kicks the attacker away.** `TagHumanoid/init.server.luau`, same `FlowingParry`
   block as the other two paths' reworks, a third sibling branch: plays
   `game.ServerStorage.Classes["Spin Kick"].Anim` (the existing Spin Kick move's own local
   animation — confirmed via the same research pass that covered Spite, `Spin Kick` is a real Tool
   with its own bespoke `Anim` child, not a `combatanims` entry) on the parrier, applies a
   `BodyVelocity` launching the original attacker away from the parrier (`(victim.Position -
   parrier.Position).Unit * 90`, plus upward `Vector3.new(0,25,0)`, `AllowedBM`-tagged, 0.3s), then
   fires an independent `TagHumanoid` hit for `math.random(25,30)` damage — the biggest of the three
   paths' counter-punishes, matching "for great damage."
4. **Calm Mind → Arrogance, stronger but risky.** `ServerStorage/Classes/Calm Mind/Activator.luau`:
   the skill string and `ClassData`/`teachskill` entry are **untouched** (renaming those would break
   every `classdata.Ronin`/`Samurai` reference system-wide) — this is a display/flavor rename plus a
   real mechanical branch on `data.Skills.Value:find("Selftaught")`. For Selftaught, the existing
   `SpeedBoost`/`AttackSpeedBoost` values scale up (`4→7`, `1.5→2.5`) and the move **still** grants
   the `"CalmMind"` Character marker unchanged, so `SamuraiModule.isCalm()` keeps returning `true` —
   every other Katana move's `isCalm`-driven behavior (execute-eligibility, `noparry`/`manabreaker`,
   shortened cooldowns, FX variants — the full scope was enumerated during this session's research
   across Blade Flash/Triple Slash/Flowing Counter/Swallow Reversal) still applies, just from a
   stronger buff. A second, separate `"Arrogance"` Character marker (same 15s lifetime) is what
   `TagHumanoid/init.server.luau` checks for the drawback: on the Selftaught player's own landed hit
   (`FindFirstChild(character,"Arrogance")`, gated by a same-shaped `"ArrogantDance"` 1s
   re-trigger-guard, mirroring the `Charming Stone`/`CharmCD` pattern right above it), a 10% roll
   forces a **genuinely new mechanic for this codebase**: this project's only `/e` emote system
   (`StarterCharacterScripts/Animate.client.luau`) is entirely client-local with no server-callable
   hook of any kind (confirmed by dedicated research — no `commands.Emote`, no `Humanoid:PlayEmote`
   calls anywhere in `src/`), so rather than invent a new RemoteEvent plumbed through that script,
   this loads Roblox's own standard default **"dance2"** catalog animation directly
   (`rbxassetid://507776043` — a stable, public, platform-level asset used by literally every
   Roblox game's default avatar, not something specific to this project) via a fresh
   `Instance.new("Animation")`, playing it at `Enum.AnimationPriority.Action4` for 1 second.
   "Not cancellable" is enforced the same way every other locked-in move animation in this codebase
   already is — a `create("Action", 1, character)` tag, the same `ActionCheck`-gated convention
   Axe Kick/every other move already uses to lock a player through a windup, not some
   emote-specific mechanism (none exists).
5. **Triple Slash → one heavy bleeding slash.** `ServerStorage/Classes/Triple Slash/Activator.luau`,
   a new early-return branch (same shape as Hand of God's Swallow Reversal replacement): plays the
   plain `Anim`, but a one-shot `GetMarkerReachedSignal("slash")` connection disconnects itself and
   calls `anim:Stop()` immediately after the *first* of the animation's 3 baked-in slash keyframes,
   so only one hit resolves. That hit sets a new `bleed = true` Info flag, handled by a **new
   generic `info.bleed` block added to `TagHumanoid/init.server.luau`** (placed right after the
   Arrogance dance-proc, within the same `if info.damage then` scope) — deliberately built as a
   reusable flag any future move could set, rather than one-off logic living inside Triple Slash
   itself. Its tick loop is a direct copy of the *existing* Bloodprism ring-enchant's own bleed
   effect (`TagHumanoid/init.server.luau`, the `val2:find("Bloodprism")` proc block, confirmed via
   direct file read — not the research summary's slightly-off paraphrase of one of the two Blood-
   asset references it uses) — same `script.Blood["blood-drip0"<N>]` sounds and
   `script.Blood.Blood.Attachment`/`.Blood:Emit(40)` particle burst per tick, satisfying "reuse
   assets and sounds" literally. Tuned "heavier" than the Bloodprism original: 6 ticks at 0.5s
   (vs. 3) and 4 damage/tick (vs. 3) — **deliberately kept floor-clamped** (`Humanoid:TakeDamage`,
   only above 3 HP) rather than an unclamped raw-`Health` assignment like `deathplague` uses,
   specifically *because* this project's own history includes a real spontaneous-death bug traced to
   an unclamped tick-DoT with no floor (documented earlier in this file) — Bleed was built to not
   repeat that mistake. The single slash and its bleed-tick both reuse `KatanaSlash`/`SwordCharge`
   clone-and-boost sound treatment (louder + pitched down) for "loud low pitched sound on use and on
   hit."
6. **Blade Flash → teleport-strike, M1 only.** `ServerStorage/Classes/Blade Flash/Activator.luau`.
   Unlike Shura's version, Selftaught keeps the **entire vanilla windup** (`M1Anim`, the delayed
   `KatanaUnsheathe`, the `Sheathe` sound clone on the `"handle"` marker — none of it touched,
   matching "sheathes like normal" exactly) — only the target-scan range (`v16`/`v17`, `29 → 100`
   studs) and what happens once a target is found changed: instead of striking from wherever the
   caster is already standing (which would mean a 100-stud detection range mostly produces whiffs,
   since the vanilla hit box is centered on the caster, not the target), the caster's
   `HumanoidRootPart.CFrame` is set directly to `target.HumanoidRootPart.CFrame * CFrame.new(0,0,4)`
   right before the hit fires — an actual teleport-to-target, which is what makes the wider range
   mean anything. `info.stun = 1.3` added for "does good stun" (the vanilla hit has no explicit stun
   override, just the katana-hit default of `0.35`). **"No m2 variant"**: a single unconditional
   `return` at the very top of `v1.Active2`, before even Shura's own dispatcher logic runs — since
   the three paths are mutually exclusive this ordering is only a stylistic choice, not a
   correctness requirement.
7. **Katana M2 → unarmed heavy punch, no damage/knockback, 1s stun only.** `ServerStorage/Weapons/Katana/Activator.luau`,
   `v1.Active2`: a new early-return branch (before the vanilla dash-windup logic) plays
   `combatanims.MonkPunch5` (the same "big finishing punch" reference this session already
   established twice, for Hand of God's Flowing Counter and now reused a third time) with no
   `BodyVelocity` forward lunge at all, then a single `magnitudeCheck` with `damage = 0,
   knockback = false, stun = 1` — `damage = 0` is safe to pass through the normal hit pipeline
   since Lua only treats `nil`/`false` as falsy (`0` is truthy), so `info.damage`-gated logic
   elsewhere in `TagHumanoid` still runs and `info.stun` still applies correctly.
8. **Swallow Reversal → slower, steerable, no invisibility, more damage.** `ServerStorage/Classes/Swallow Reversal/Activator.luau`,
   the vanilla `v1.Active` body (Hand of God still fully replaces this function per its own section
   above; Selftaught branches only within what HandOfGod skips). "Slower": traversal-speed divisor
   drops from `85` to `55` (larger `v22` = the dash takes longer overall) and the `BladeDance`
   animation speed drops from `1.3` to `1.0`. "Doesn't make you go invisible": the
   `Boosts.Transparency` NumberValue (`v24`) is skipped entirely for Selftaught (now conditionally
   `nil`, with the later `v24:Destroy()` guarded accordingly) — the `Immortal` i-frame folder next to
   it is untouched, so Selftaught keeps invulnerability during the dash without the visual
   invisibility. "More damage": per-tick `7.5 → 12`, finisher `16 → 24`. **"Fully aimable, change
   directions" is the one genuinely new mechanic built this session with no reusable server-side
   precedent** (confirmed via dedicated research: every existing Class move computes its hit-line
   from a single CFrame captured once at cast time; the only *live-steering* precedents in the whole
   codebase are client-only — `ClimbFunc`'s per-frame `IsKeyDown` polling and the Seraph flight
   script's `repeat wait() ... humanoid.MoveDirection` loop). Adapted the `MoveDirection`-polling
   idea server-side: the tick loop now accumulates `pos`/`facing` incrementally instead of always
   offsetting from the fixed starting CFrame, re-reading `p9.Humanoid.MoveDirection` each iteration
   and steering `facing` toward it whenever the player is actively holding a movement key. **Known,
   disclosed limitation**: this only steers the *server's* hit-detection line. The client's own
   cosmetic dash visual is driven by a single one-shot `KatanaSkillFX:FireAllClients(...)` call with
   fixed `distance`/`time`/`rootcf` parameters sent at cast time — extending that to also steer live
   would mean touching the client VFX handler script, which wasn't in scope for this pass (not
   researched, and blind-editing unresearched client code was judged too risky) — so a
   Selftaught player who steers hard will see their hit-line curve correctly but their own visible
   character model dash in a straight line, a real, disclosed visual/mechanical mismatch. Whoever
   picks this up next should treat extending the client FX handler to match as the natural
   follow-up, not a bug in this implementation.

**Interpretive calls worth flagging**: exact numbers throughout (0.6x draw pitch, 90 stud/s kick
velocity, 25-30 counter damage, +3/+1 Arrogance boost deltas, 10% dance chance, 6-tick/4-dmg bleed,
100-stud Blade Flash range, 1.3s stun, 55 stud/s dash speed, 12/24 Swallow Reversal damage) are again
feel-based per this path's "borrows from everywhere, higher risk/reward" identity, not a balance
spec — flag for tuning. The hardcoded `rbxassetid://507776043` for the dance emote is the one
genuine deviation from this codebase's "reference a named Studio asset, flag it as debt if missing"
convention used everywhere else in this session — it was a deliberate choice (a stable public
platform asset needs no Studio placement, unlike every other asset-debt item flagged across the
three Ronin paths) but is still worth knowing about if this project ever migrates away from
depending on Roblox's default catalog content.

## Morvid ascension (added 2026-07-27)

First race added to the `Ascended`/As'endo system since the Azael/Madrasian/Dzin/Gaian batch —
Morvid previously had no `MorvidQuest`/`As'endoMorvid`/`MorvidDialogue` entries at all (confirmed by
grep before starting; it also isn't in `NoAscensionRaces`, so it was always meant to get one
eventually, it just hadn't been built). Both the narrative trial and the mechanical payoff were
built this session — everything below lives in `WorldHandler/Dialogues/DialogueHandler/ModuleScript.luau`
and `ServerStorage/RacialAbilities/Flock/Activator.luau`.

**Trial structure — copied exactly from the Madrasian/Dzin shape** (`AscensionQuests["MorvidQuest"]`,
`["As'endoMorvid"]` dialogue table, `AscendedDialogues["MorvidDialogue"]`): As'endo sends the player
to a new trial-giver NPC, **Corvax** (`["Corvax"]` dialogue table + `dialogues.Corvax.v1`, same shape
as `Vessimer`/`Ilventhe` — a single-purpose NPC that only ever progresses the trial for a Morvid who
already said "I will not fail" to As'endo, turns everyone else away with `notready`), who flips
`StoryMarker["Ascension"]["Morvid"]` from `"Started"` to `"CorvaxDone"` on `"I accept."`. Back at
As'endo, `"Let's do it"` spends 20 insight and sets `data.Ascended.Value = true`, same
insight-cost/pity-free flow every other race's trial uses. Ascended title is **"Shepherd of the
Flock"** (`As'endoMorvid.ascended`/`.shepherdoftheflock`), picked to read as a natural title for a
Morvid whose racial ability literally is the flock, mirroring how "Overclocked One"/"Ruler of Fire"
name-drop each race's own signature mechanic.

**Asset debt**: **Corvax is a brand-new NPC with no placed instance yet** — same Argon caveat as
every other feature in this doc that needs a world object: the dialogue logic is real and wired, but
whoever has Studio access needs to actually place an NPC named `Corvax` (with the usual
click-trigger/dialogue-hookup every other named NPC in this file has) before the trial is reachable
in-game. As'endo itself needs no placement work since it's the existing shared ascension-giver NPC
every race's trial already routes through.

**Mechanical payoff — `ServerStorage/RacialAbilities/Flock/Activator.luau`**: everything gated on a
new `isAscendedMorvid(data)` helper (`data.Ascended.Value == true and data.Race.Value == "Morvid"`),
same shape as the Gaian/Dzin/Madrasian ascension checks scattered through `RacialAbilities/`.

1. **Flock (M1) is buffed for ascended Morvid.** `SpeedBoost` during the dash goes `13 → 20`, and the
   cooldown drops `30s → 20s` (both the `Cooldowns` `NumberValue` and the trailing `wait()` that
   resets the `u1` debounce). Nothing else about vanilla M1 (the crow-particle VFX, the
   `Immortal`/`NoAttack`/`canmanashield` 2s iframe window, the black-silhouette-fade effect) changed —
   this is a numbers-only buff, not a rework.
2. **New Flock M2 (`v1.Active2`) — ascended-only, no prior M2 existed.** Finds the nearest player
   within 50 studs (`findFlockTarget`), then: you go invisible (the same `Boosts.Transparency`
   `NumberValue` idiom used throughout this codebase, e.g. Shura's stealth toggle), and the normal
   Flock crow-swarm VFX/sound (`playFlockVfx`, factored out of the M1 body so both share it) plays
   **on the target's `HumanoidRootPart` instead of your own** — the "swarm" reads as landing on them,
   not you. After a 1.5s delay you reappear 4 studs in front of the target
   (`targetRoot.CFrame * CFrame.new(0,0,-4) * CFrame.Angles(0,math.rad(180),0)`, facing back toward
   them) and a `TagHumanoid` hit fires for 15 damage with `stun = 0.5` (the "still stunned for .5s"
   ask, using the same `info.stun` override every other move in this session uses rather than a raw
   `Stun` tag). **Deliberately grants no `Immortal`/`NoAttack`/`canmanashield` markers at any point**
   — the explicit "doesn't give iframes" ask — unlike M1, which keeps its existing iframe window
   untouched. Own independent cooldown key (`"Flock Swarm"`, 25s) rather than sharing M1's `"Flock"`
   cooldown, since the two are different buttons with different risk profiles; a `u2` boolean
   debounce mirrors M1's own `u1` pattern.
3. **Proximity punish — `watchFlockProximity`, M1 only.** While an ascended Morvid is mid-Flock-M1
   (the 2s dash/invisibility window), a background loop checks every 0.1s whether any other real
   player has come within 8 studs. If so: the effect is cancelled immediately (invisibility and the
   `Immortal`/`NoAttack`/`canmanashield` markers are all destroyed early via an `onCancelled`
   callback), the player who got close is knocked back (a small `AllowedBM`-tagged `BodyVelocity`,
   matching this codebase's established tag for player-applied knockback), and **5% of that player's
   max health is transferred**: `math.max(health - 5%, 1)` on them, `math.min(health + 5%, max)` on
   the Morvid. The 1-HP floor (rather than an unclamped subtraction) was a deliberate choice given
   this project's own history with unclamped tick-damage causing spontaneous deaths (see the
   "Fixed: spontaneous death while ragdolled/knocked" section above) — this is a single instant
   transfer rather than a DoT, so the risk is much smaller, but the floor costs nothing and removes
   the failure mode entirely. **Deliberately not wired into M2** — M2 already requires ending up
   right next to its target on purpose (that's the whole "reappear in front of them" beat), so the
   same "caught getting close" punish would either always self-trigger or need a target-exclusion
   special case; the request narrowed this to M1 only, so `v1.Active2` never calls
   `watchFlockProximity` at all.

**Interpretive calls worth flagging**: every exact number (20 SpeedBoost, 20s/25s cooldowns, 50-stud
M2 target range, 1.5s vanish delay, 15 damage, 0.5s stun, 4-stud reappear offset, 8-stud proximity
radius, 5% steal) was picked to feel proportionate to a racial ability (weaker than a dedicated
Class move, since every player of a race gets it for free) rather than derived from a balance spec —
flag for tuning. Whether the proximity punish should also apply to monsters/NPCs (currently
`game.Players:GetPlayers()`-only, matching the literal "any player" wording) or should team-check
before triggering (it currently doesn't — no team filter exists on this proc, matching how e.g. Soul
Rip's own AOE also doesn't team-check) are both judgment calls that went with the simpler reading;
revisit if either turns out to matter in practice.

## Ashiin ascension (added 2026-07-27)

Second race added to the `Ascended`/As'endo system this session (after Morvid above) — same
situation: Ashiin already had *scattered* ascended-only checks (`CharacterHandler/init.server.luau`'s
faster heavy-punch-animation branch at `PlayerData.Race.Value == "Ashiin" and PlayerData.Ascended.Value
== true`, and `Shoulder Throw`'s own ascended-cooldown branch) but no `AshiinQuest`/`As'endoAshiin`/
`AshiinDialogue` trial existed to actually reach `Ascended.Value == true` as an Ashiin through normal
play. Built both halves this session, same shape as Morvid's.

**Trial structure — identical shape to Madrasian/Dzin/Morvid** (`AscensionQuests["AshiinQuest"]`,
`["As'endoAshiin"]` dialogue table, `AscendedDialogues["AshiinDialogue"]`): As'endo sends the player to
a new trial-giver NPC, **Doyen** (`["Doyen"]` dialogue table + `dialogues.Doyen.v1`, same
only-progresses-a-Started-trial/turns-everyone-else-away shape as `Vessimer`/`Ilventhe`/`Corvax`), who
flips `StoryMarker["Ascension"]["Ashiin"]` from `"Started"` to `"DoyenDone"` on `"I accept."`. Ascended
title is **"The Unseen Fist"** (`As'endoAshiin.ascended`/`.theunseenfist`), picked to cover both new
abilities below (a hit you don't see coming, and a move that was never really there).

**Asset debt**: **Doyen is a brand-new NPC with no placed instance yet**, same as Corvax before it —
the dialogue logic is real and wired, but needs an actual NPC instance placed in Studio (with the
usual click-trigger/dialogue-hookup) before the trial is reachable in-game.

**Mechanical payoff — two new ascended-Ashiin-only Tools under `ServerStorage/RacialAbilities/`**,
granted the same way `Rocket Launcher`/`Overclock` are granted to ascended Gaian: a
`if data.Ascended.Value == true then ... end` block added to the (previously ascension-blind) Ashiin
branch of `commands["RacialAbilities"]` in `Modules/Commands/init.luau`. Both Tools also re-check
`data.Ascended.Value == true and data.Race.Value == "Ashiin"` themselves at activation time (defense
in depth, matching every other race-gated racial ability in this codebase), and both reuse existing
Monk unarmed-combo animations (`ReplicatedStorage.CombatAnims.MonkPunch3`/`MonkPunch4` — the same
animation family this session's Ronin paths already reused as `MonkPunch5` for their own finishers, so
no new assets needed for either move) rather than needing anything built in Studio.

1. **Blinding Knee** (`RacialAbilities/Blinding Knee/`) — a forward cone-check (mirrors `Shoulder
   Throw`'s own `Nearest()` helper: `HumanoidRootPart.CFrame:inverse()` local-space box test) that
   lands 10 `blockbreak` damage with a 0.4s stun, then — the actual point of the move — fires the
   *existing* injury-blindness `RemoteEvent` (`ReplicatedStorage.Requests.Blind`, the same one
   `ApplyInjuries.luau` already fires for a permanent "blind" `Injuries` entry) at the target for 7s.
   Uses the shared `ActionCheck.luau` module with a normal `presentBlocks` list (including `"Action"`)
   — this is an ordinary move, blocked like any other while something else has you locked. 12s
   cooldown. **The 7s timeout guards against stomping a real injury**: it only fires `Blind → false`
   if the target's `PlayerData.Injuries.Value` doesn't *also* contain `"blind"` by then, so knocking
   someone temporarily blind can't accidentally cure (or prematurely end) a permanent blindness
   injury they picked up in the meantime.
2. **Fakeout** (`RacialAbilities/Fakeout/`) — the interesting one. "If used during a move, cancel it,
   and deliver a fast punch that guardbreaks, otherwise just does the fast punch" was read as: the
   fast punch always happens, but it only guardbreaks when it *also* cancelled something. Its
   `ActionCheck` is a **deliberate departure from every other move in this codebase**: it calls the
   shared module with a `presentBlocks` list that excludes `"Action"` (every other move's list,
   including Blinding Knee's above, always includes it) — since Fakeout's entire premise is being
   usable *while* `"Action"` is present, blocking on it the normal way would make the move
   unusable exactly when it's supposed to work. It still blocks on genuine incapacitation
   (`Stun`/`Knocked`/`Grabbed`/etc. — being hit-stunned by an opponent still stops you; only your
   *own* move-lock is escapable). At activation: `cancelling = Character:FindFirstChild("Action") ~=
   nil`, and if true, that `Action` instance is destroyed outright (`Action` is the one universal
   move-lock tag basically every other `ActionCheck` in this codebase — shared module and the dozen
   local ones alike — checks for, so destroying it is what "cancels" whatever move was in progress;
   no per-move special-casing needed for this to work against any move written before or after it).
   The follow-up punch then fires with `blockbreak = cancelling` — a plain jab normally, a guardbreak
   only when it was also an escape. 6s cooldown, independent of Blinding Knee's.

**Interpretive calls worth flagging**: exact numbers (12s/6s cooldowns, 8/7-stud ranges, 10/6 damage,
0.4s stun, 7s blind duration) are feel-based, not spec-derived — flag for tuning. Fakeout's
`"Action"`-only carve-out (it still blocks on `Blocking`/`SpellBlocking`/`ActiveCast`/etc.) was a
judgment call: the request said "during a move," which was read as specifically the generic move-lock
rather than every self-imposed state — revisit if Fakeout is meant to also cancel out of blocking or
spellcasting stances.

## Fixed: ascension pity flag exploit (2026-07-27)

Reported as "Ashiin and Morvid quests give ascension too soon (without paying the insight fee)."
Root cause was **not** a bug in `AscensionQuests["AshiinQuest"]`/`["MorvidQuest"]` themselves — diffed
both byte-for-byte against `MadrasianQuest` (normalizing only the race/trial-giver names) and they're
structurally identical, including the `commands.ChangeInsight(p,data,-20)` gate every race's "Let's do
it" branch requires before `Ascended.Value = true` is ever set.

The actual bug was `StarterCharacterScripts/CharacterHandler/init.server.luau`, a block that ran on
**every single character spawn**: `if PlayerData.Ascended.Value == true then
GlobalQuests["Ascensions"][PlayerData.Race.Value] = true end` — unconditionally trusting whatever
`Ascended.Value` happened to be at spawn time as proof that the *current* race's ascension was
legitimately earned, and baking that into the permanent, account-wide pity flag every
`AscensionQuests[...]` function checks first (`if GlobalQuests["Ascensions"][Race] == true then` -
skip straight to `.ascended`, no insight cost). This is a real exploit surface for **any** race with a
quest, not just the two just built: the moment `Ascended.Value` is `true` for *any* reason other than
having gone through that race's own "Let's do it" branch - most plausibly toggling it directly in
Studio's Explorer to test ascended-only content, which is exactly how Ashiin's and Morvid's abilities
(Flock M2, Blinding Knee, Fakeout) were being tested this session - the next spawn silently and
permanently grants free future ascension for that race on that account.

**Fix**: deleted the block outright rather than gating it more tightly. It was pure redundancy to
begin with — the pity flag is already written correctly, explicitly, at the one moment it's actually
earned (inside each `AscensionQuests[...]` function's own "Let's do it" branch, right after
`commands.ChangeInsight` succeeds) — so removing the passive spawn-time sync closes the exploit with
no loss of legitimate behavior. **This does not retroactively clean already-corrupted data** — any
account whose `GlobalQuests["Ascensions"]` already has a stale `true` for a race it never paid for
(e.g. from this session's own testing) needs that entry cleared by hand.

## Vind ascension (added 2026-07-27)

Third race added to the `Ascended`/As'endo system this session (after Morvid and Ashiin above),
same shape throughout. The user's brief called the racial ability "Tempest Wind" — the actual move
in this codebase is **`Tempest Soul`** (`RacialAbilities/Tempest Soul/Activator.luau`), Vind's only
racial ability, a spell-cast (not a plain Tool `Activated`) that opens a 5.75s counter-field window:
any incoming hit flagged `info.canspellcounter` that lands on a `CounterSpell`-tagged character gets
redirected back onto its own caster via `TagHumanoid/init.server.luau`'s `character`/`enemy` swap
trick (~line 343) — same identity-swap idiom flagged elsewhere in this doc (Flowing Counter, the
Emerald gem proc) as losing the original attacker unless captured first. Read "Tempest Wind" as this
ability throughout.

**Trial structure — identical shape to Morvid/Ashiin**: `AscensionQuests["VindQuest"]`,
`["As'endoVind"]` dialogue table, `AscendedDialogues["VindDialogue"]`, a new trial-giver NPC
**Zephyra** (`["Zephyra"]` dialogue table + `dialogues.Zephyra.v1`, turns away anyone whose
`StoryMarker["Ascension"]["Vind"]` isn't `"Started"`, same as `Vessimer`/`Ilventhe`/`Corvax`/`Doyen`).
Ascended title: **"Warden of the Tempest"**. **Asset debt**: Zephyra needs an NPC instance placed in
Studio, same caveat as Corvax/Doyen before it.

**Mechanical payoff**, all gated on `Ascended.Value == true and Race.Value == "Vind"` except item 5
(explicitly a base-race, non-ascension trait):

1. **Tempest Soul M1 stores instead of instantly reflecting.** `TagHumanoid/init.server.luau`'s
   `canspellcounter`/`CounterSpell` block (~line 343): for ascended Vind, the attacker/victim swap is
   skipped entirely - instead the hit is banked as a `TempestHit` Folder (an `Attacker` `ObjectValue`
   + `Damage` `NumberValue`) under a new `Character.StoredTempest` Folder, capped at 5 stored hits,
   and the function `return`s immediately with `info.damage = 0` so the Vind still takes zero damage
   from the countered hit, same as vanilla - it just doesn't return fire yet. Non-ascended Vind (and
   every other race using `canspellcounter` effects, if any exist) are completely unaffected - this
   branch only triggers inside the existing `CounterSpell`-tag check, gated on the *defender's* race,
   and returns before reaching the original swap code. Replays the existing `CounterSpell` sound on
   the Vind as a "banked" cue, reusing the M1 activation's own asset.
2. **New Tool, `Tempest Release` (M2) — releases every stored hit at once.**
   `RacialAbilities/Tempest Release/Script.server.luau`, a plain `Activated`-triggered Tool (not
   layered onto Tempest Soul's own RightClick - see the file's own header comment for why: RightClick
   on a spell Tool already drives the unrelated "Snap" quick-cast system in
   `CharacterHandler/init.server.luau`, gated on owning a Snap for that spell and a Studio-side
   `SnapCD` child this session can't add - a separate Tool needed nothing placed in Studio beyond the
   Tool itself, granted the same way every other racial ability Tool is). Iterates
   `Character.StoredTempest`, firing one `TagHumanoid` hit per stored entry back at its *original*
   attacker (`blockbreak/nododge/noparry = true` - these already "landed" once, so treated as a
   guaranteed counter-punish, not a fresh dodgeable hit) rather than one combined burst, then clears
   the folder. Reuses the `CounterField` asset for a release-moment VFX flourish, no new asset needed.
   3s cooldown (a safety debounce, not a real balance lever), no-ops without consuming it if nothing's
   stored. Granted alongside `Tempest Soul` in `commands.RacialAbilities`'s Vind branch, same pattern
   as Gaian's `Rocket Launcher`/`Overclock`.
3. **Exoskeleton's hold-Space-to-fall-faster perk, and only that perk.** A new
   `Character`-parented Accessory, `AscendedVindFall`, granted once at spawn
   (`CharacterHandler/init.server.luau`, alongside the existing `TheMaster` permanent-boosts block -
   same "grant once at spawn, no Debris timer, lasts the character's life" pattern).
   `CharacterHandler/Input/init.client.luau`'s fast-fall condition (~line 956) now checks
   `FindFirstChild(Character.Artifacts,"Exoskeleton") or FindFirstChild(Character,"AscendedVindFall")`
   - **deliberately a new, distinctly-named marker rather than reusing `"Exoskeleton"` itself**: that
   exact accessory-presence check is *also* what gates Exoskeleton's double-jump (~line 1467) and
   double-dash (~line 998) perks, and the brief only asked for the fall-faster half. Doesn't touch
   `PlayerData.Artifact.Value` at all, so it doesn't compete with the player's real Artifact slot.
4. **Extra passive regen on top of base Vind's own bonus.** `StarterCharacterScripts/Health.server.luau`'s
   regen tick already has `if race == "Vind" or race == "Fischeran" then baseregen *= 1.1 end`; added
   `if race == "Vind" and PlayerData.Ascended.Value == true then baseregen *= 1.3 end` immediately
   after it, so ascended Vind get both multipliers (~1.43x base) rather than one replacing the other.
5. **Blocking pushes the attacker back slightly (non-ascension is item 6, this one's ascension-only
   per the request's placement).** `TagHumanoid/init.server.luau`'s generic (`not info.slash`)
   successful-block branch: if the blocker is ascended Vind, a small `AllowedBM`-tagged
   `BodyVelocity` (`-12` along the attacker's look vector, `+4` up, 0.3s) nudges the attacker back -
   deliberately much weaker than the existing `MonShield` block-break push a few lines above it
   (`-35`), which is a real punish for a different case (breaking a Monk shield), not a "tiny bit."
   Scoped to only the generic block path, not the separate `info.slash` weapon-clash branch a few
   lines down (which has its own established per-weapon FX/counter logic) - extending it there wasn't
   asked for and is a larger, riskier surface.
6. **(Non-ascension) Vind get innate fall resistance.** `CharacterHandler/init.server.luau`'s
   `Remotes.ApplyFallDamage` handler, same `FallDamageReduction` pipeline Exoskeleton/FeatherFall
   already use: `if PlayerData.Race.Value == "Vind" then FallDamageReduction = math.min(FallDamageReduction, 0.7) end`,
   placed before the existing `math.clamp(...,0.4,1)` floor so it composes correctly with
   FeatherFall/Exoskeleton if a character somehow has both (strongest reduction wins, same `math.min`
   idiom Exoskeleton's own reduction already uses). No `Ascended` check - applies to every Vind.

**Interpretive calls worth flagging**: exact numbers (5-stored-hit cap, 3s M2 cooldown, -12/+4 block
push, 1.3x regen multiplier, 0.7 fall-damage multiplier) are feel-based, not spec-derived - flag for
tuning. M2 firing one hit per original attacker (rather than combining all stored damage into a
single burst at whoever's nearest) was a judgment call reading "releases all the stored up spells at
once" as "release all of them, at once" rather than "release one combined spell" - revisit if a
single merged burst was intended instead.

## New artifact: Black Pill (added 2026-07-27)

Same single-slot artifact grant pattern as Exoskeleton/Charming Stone/Playful Stone:
`ServerStorage/Storage/Black Pill/Script.server.luau`, `Activated`-triggered, sets
`PlayerData.Artifact.Value = "Black Pill"`, drops an `Accessory` marker named `Black Pill` into
`Character.Artifacts` (no `Handle` mesh yet — same asset debt as every other artifact's
`Accessory` marker in this doc).

**Revised same day: `Humanoid.BodyHeightScale`/`BodyWidthScale`/`BodyDepthScale`/`HeadScale` don't
exist on this game's Humanoid** — confirmed live, not just unused (this isn't an R15-only-feature
situation either; the properties themselves error on this rig). Scaling is done manually instead,
via a new small shared module, `ServerScriptService/Modules/CharacterScale.luau`
(`module.scaleR6(character, factor)`): resizes every named R6 `BasePart`
(`Head`/`Torso`/`Left Arm`/`Right Arm`/`Left Leg`/`Right Leg`/`HumanoidRootPart`) directly via
`Part.Size = Part.Size * factor`, then rescales every `Motor6D`'s `C0`/`C1` **position only**
(rotation preserved) by the same factor so the joints stay lined up instead of the limbs drifting
apart or overlapping — the pre-scale-API technique this style of R6 resizing has always used.
Scans `character:GetDescendants()` for `Motor6D`s rather than hardcoding joint names/locations, so
an accessory welded on via its own `Motor6D` (rare, but some do this for animation) gets its offset
scaled too instead of ending up floating at the old distance.

- **1.2x bigger than everyone else**: `CharacterScale.scaleR6(character, 1.2)`.
- **The face texture is stretched out a little bit**: same as before this revision — the Head's own
  `SpecialMesh.Scale` (the mesh the face `Decal` actually renders on, a separate multiplier layered
  on top of whatever `Head.Size` already did via the resize above, since `MeshType.Head` auto-fits
  to `Part.Size` and `SpecialMesh.Scale` multiplies further on top of that fit) gets an additional
  **non-uniform** nudge, `Vector3.new(1, 1.08, 1)` (8% taller, unchanged in the other two axes) —
  this is what actually warps the face decal's proportions, since a uniform resize alone can only
  make the head proportionally bigger, not asymmetrically distorted. Guarded with
  `FindFirstChildWhichIsA("SpecialMesh")`, no-ops if the Head doesn't have one.

**Also fixed same day: the effect didn't survive respawn.** The Tool's `Activated` handler only ever
scales whichever `Character` instance is alive at the moment of pickup - a fresh `Character` on
respawn starts back at normal size, and `PlayerData.Artifact.Value == "Black Pill"` alone doesn't
do anything by itself, it's just a persisted flag. Fixed by adding a spawn-time re-application block
to `CharacterHandler/init.server.luau` (right next to the `AscendedVindFall` grant, same "apply a
persisted per-life effect once at spawn" pattern): if `PlayerData.Artifact.Value == "Black Pill"`,
re-runs `CharacterScale.scaleR6(Character, 1.2)` and the same head-mesh stretch, and re-creates the
`Character.Artifacts` marker if it's missing. The Tool script itself still applies the effect
immediately on pickup (for the life you're in when you find it) - the two are complementary, not
duplicated: the spawn hook only ever runs on a freshly-created `Character`, which hasn't been scaled
yet, so there's no double-scaling risk between them.

**Interpretive calls worth flagging**: `1.2` for the body scale was given directly by the request;
`1.08` for the extra head-stretch factor and which axis to stretch (vertical) were not specified -
picked to read as "a little bit," not a cartoonish distortion - flag for tuning if a different axis
or amount was intended.

**Follow-up (still 2026-07-27): Clavicular recognizes Black Pill holders.** Clavicular is the
`Bounty Officer` NPC (`DialogueHandler/ModuleScript.luau` - the speaking name `"Clavicular"` and the
dialogue-content table key `"Bounty Officer"` have always been decoupled in this file, not something
introduced here) who hands out player-hunting bounties. Its driver, `dialogues["Clavicular"].v1`, had
three separate `return dialogues["Bounty Officer"].p1` call sites (the fresh-conversation start, and
two "your target left/despawned, resetting" cases) - all three now go through a new local
`firstMessage()` closure that returns a new `dialogues["Bounty Officer"].smirk` entry
(`"*smirks* i knew you were different"` / choice `"damn right"`) instead of the normal `"Are you
looking for a job?"` / `"Yeah."` when `data.Artifact.Value == "Black Pill"`, and falls through to the
same `.p1` otherwise - purely a re-skin, page 2's bounty-list logic is untouched and doesn't care
which choice text got clicked. Separately, page 2's `stringgreat` loop (the "here's who's online and
where" list Clavicular recites) now skips any candidate player whose own `Artifact.Value ==
"Black Pill"` - a Black Pill holder simply never appears as an assignable bounty target for anyone
else. Both changes read the target/candidate's own `PlayerData` directly, no new state needed.

## Security fix: spoofable Character/Backpack passive checks (2026-07-27)

Reported live: exploiters can get a spoofed Instance (e.g. a Folder named `"SlashResistance"`) to
appear under their own `Character`/`Backpack`, and any server script that grants a real gameplay
effect by scanning for that name (`Character:FindFirstChild(...)`, `Player.Backpack:FindFirstChild(...)`,
`Character.Artifacts:FindFirstChild(...)`) ends up trusting it. Both are replicated to the owning
client, so a spoofed Instance there reads identically to a legitimate server-created one to any
`FindFirstChild` scan. **The fix, applied everywhere below**: check `game.ServerStorage.PlayerData`
instead (`Race.Value`/`Skills.Value`/`Class.Value`/`Artifact.Value`/`Ascended.Value`) - `ServerStorage`
is never sent to any client, so nothing stored there can be spoofed this way.

An `Explore` agent ran a full-codebase survey for this exact pattern (not just the reported
`SlashResistance` case) and categorized every finding by whether it grants a real, standing
race/class/artifact passive (fixable, fix below) vs. self-set transient combat state like
`Stun`/`Blocking`/`Action`/cooldown tags, or something gated behind a real Tool's own
`Activated`-connected server Script (where a fake Instance can't do anything since no server Script
is listening on it) - those don't grant an unearned advantage the same way and were left alone.

**Fixed** (file:line references are to the check that was rewritten, not necessarily still accurate
after the edits above it in the same file):

- **`SlashResistance`** (`TagHumanoid/init.server.luau`, blade damage ×0.75 + chestgash-injury
  immunity) - now `enemydata.Race.Value` in `{Gaian, Lich, Metascroom, Kasparan}` (the exact races
  `commands.RacialAbilities` grants it to; the chestgash check additionally excludes Kasparan,
  unchanged from before).
- **`Playful Stone`** (`HitDetection.luau` hitbox-size roll, `TagHumanoid` full-damage-negation
  dodge) - now `PlayerData.Artifact.Value == "Playful Stone"`. (`SpellModule.luau` and
  `TrinketsHandler.server.luau`'s own Playful Stone checks were already correct - written against
  `PlayerData.Artifact.Value` from the start.)
- **`Exoskeleton`** (`CharacterHandler` fall-damage reduction) - now `PlayerData.Artifact.Value == "Exoskeleton"`.
- **`FeatherFall`** (`CharacterHandler` fall-damage reduction, `TagHumanoid` fall sound/severity/death
  threshold - the same block the spontaneous-death fix above lives in, so this one actually gated
  survivability, not just cosmetics) - now `PlayerData.Race.Value == "Morvid"`, matching this check's
  *actual* current behavior: FeatherFall is also a Shinobi/Whisper/Wanderer class skill, but that
  version is flag-only (`Skills.Value` string, no `ServerStorage/Classes/FeatherFall` folder to clone
  into Backpack) and was never reachable through this Backpack-presence check either way - this fix
  preserves exactly what already worked rather than also silently extending the reduction to those
  three classes for the first time during a security pass.
- **`WindDodges`** (`TagHumanoid` full-damage-negation dodge charges, also read into `iswindamount`
  for a ChiBlock-immunity check) - both now require `enemydata.Race.Value` in
  `{DullahanBawa, Fischeran}` before trusting the Character `NumberValue` at all. **Residual, lower-
  severity gap**: the counter itself still lives on `Character`, not `PlayerData`, so a genuine
  DullahanBawa/Fischeran player could still tamper with their own `.Value` (e.g. set it far above 4) -
  closing that fully means moving the whole regen system into `ServerStorage`, judged too large a
  change for this pass; what's fixed is any *other* race gaining dodges at all via a spoofed Instance.
- **`ChiBlock`** (`CharacterHandler` free block-shield stance, `TagHumanoid` auto-stun-counter) - now
  `data.Skills.Value:find("ChiBlock")` / `playerdata.Skills.Value:find("ChiBlock")`.
- **`CurseShield`** (`CharacterHandler`, upgrades a spell-parry into full curse immunity) - now
  `PlayerData.Skills.Value:find("CurseShield")`.
- **`CurseAllow`** (`Classes/Nocere/Activator.luau`, `Classes/Tenebris/Activator.luau` - lets a
  non-Mage class cast curse spells) - now `Skills.Value:find("CurseAllow")` on the caster's own
  already-resolved PlayerData local in each file.
- **`MentalBlock`** (`RequestHandler.server.luau` injury immunity, `Classes/Hystericus/Activator.luau`
  and `Classes/Trickstus/Activator.luau` AoE-confuse immunity - 4 call sites total) - now
  `Skills.Value:find("MentalBlock")` against each site's already-resolved target PlayerData.
- **`WiseCasting`/`RemTraining`** (`SpellModule.luau`, widen the mana-roll window for a successful
  cast) - now `data.Skills.Value:find(...)` for each.
- **`ShriekerHeal`** (`TagHumanoid` + all four Shrieker/Zombie-Scroom/Evil-Eye monster
  `DecisionModules` - 9 call sites total, heals the necromancer's summoned monster on every hit it
  lands) - now `masterdata.Skills.Value:find("ShriekerHeal")` against the summon's master's
  freshly-resolved PlayerData at each site.
- **`Solan's Will`** (`TagHumanoid`, fist damage ×0.8 and blade damage ×0.9 - a Templar-only skill
  granted via the Regnier dialogue) - both now `enemydata.Skills.Value:find("Solan's Will")`.
- **`IronRes`** (`TagHumanoid`, blade damage `/3`, not even gated to `info.blade` specifically) -
  **removed outright**, not rewritten - an exhaustive search found no script anywhere in `src/` that
  ever creates an `"IronRes"` Instance (the similarly-named `IronBody` `ObjectValue` Gaian/Lich/
  Metascroom actually get is unrelated). Every legitimate player has always had this check evaluate
  false; it was a pure, currently-live exploit surface with nothing to preserve. If some race/skill
  was meant to grant this and the wiring never landed, that's a separate, deliberate feature gap to
  pick up on purpose, not something to guess a value for here.
- **`ObserveBlock`** (`Classes/Observe/Script.server.luau`, hides a player from the Illusionist
  Observe target list) - now `vdata.Skills.Value:find("ObserveBlock")`. Same shape as `FeatherFall`:
  `ObserveBlock` is a flag-only skill with no matching `Backpack`/`Boosts` Instance ever created for
  it anywhere in `src/`, so this fix also makes the skill actually do something for the first time,
  not just closes the exploit. (`StarterPlayerScripts/ObserveThing.client.luau`'s mirrored check is
  client-side UI only - a client that already trusts itself isn't a new exploit surface, left as-is.)
- **`VanguardT`** (`Weapons/Greatsword/Activator.luau`, reclassifies a hit as sword/slash and changes
  its knockback) - now `p2data.Skills.Value:find("VanguardT")` on the wielder's own freshly-resolved
  PlayerData. Checked on the attacker's own Backpack, so this is nominally a "self" check, but unlike
  pure self-buffs it changes how the *target's* other resistance checks read the hit (bladed vs.
  not), which is why it was fixed despite the self-check shape.
- **`ChargeMastery`** (`Classes/Azure Ignition/Activator.luau`, skips the ~1s cast windup) - now
  `p3data.Skills.Value:find("ChargeMastery")`.
- **`Respirare`/`Mederi`** (`CharacterHandler`, lets a mid-cast player end their own channel slightly
  early) - now `PlayerData.Race.Value == "Kasparan"` (Respirare has no `Skills.Value` trace at all -
  it's a Kasparan-only racial `Tool`, never a skill string) or `PlayerData.Skills.Value:find("Mederi")`
  (granted via the `EdictRewards` quest-reward system). Lowest severity of everything in this pass -
  only changes *your own* cast-cancel timing, not a damage/immunity gate - fixed for consistency
  rather than because it was independently flagged as dangerous.
- **`MeleeDamageMultiplier`** (`TagHumanoid`, `info.damage *= character.Boosts.MeleeDamageMultiplier.Value`) -
  a different shape of the same problem: not a presence check but an *arbitrary attacker-controlled
  number* read straight off a replicated `Boosts` child with zero bounds, so a spoofed instance with
  an oversized `Value` could multiply outgoing damage by anything. Every real grantor (`Rage`,
  `Overclock`, `Plasticity`, `Dragon Blood`, `Dragon Awakening`, `True Vision`, `Soul Rip` - 7 files)
  uses a value in the 1.1-1.4 range, so this is now `math.clamp(...,0,2.5)` rather than trusted
  outright - a bound, not a full PlayerData rebuild, since correctly re-deriving the true value would
  mean summing across however many of those 7 sources happen to be simultaneously active, a larger
  change than this pass covers.

**Deliberately not touched** (self-set transient state or gated behind a real Tool's own script,
confirmed during the survey to not grant an unearned advantage the way the above did): `Blocking`,
`Stun`, `SpellBlocking`, `CurseBlocking`, `MonShield`, `Action`, `ActiveCast`, `Casting`,
`ManaParry`/`ManaParryCD`, `STOPBLOCKING`, `canmanashield`, `FallDamageBypass`, `HyperArmor`,
`VanguardBuff`, and the various cooldown/state tags (`InjuryCooldown`, `ImpaleCD`, `LuckDodgeCD`,
etc.) - all created only by the player's own real-time action or a real server ability script in
direct response to it, not a standing passive that a spoofed marker could grant for free.

## New system: Workout / Hypertrophy (added 2026-07-28)

A new progression system layered on top of the existing Class/Race/Path stack: players spend
real-time minutes exercising to earn small, permanent combat/movement buffs per body-part
category. Built as 5 new Tools (`ServerStorage/Classes/Pushups|Squats|Situps|Russian
Twists|Bent Over Row/`) plus a new shared module, `ServerScriptService/Modules/WorkoutModule.luau`,
rather than hooking into the existing `/e` chat-emote system — confirmed during this session that
`StarterCharacterScripts/Animate.client.luau`'s `/e` emotes are entirely client-local with no
server-callable hook (no `commands.Emote`, no server `Humanoid:PlayEmote` anywhere in `src/`), the
same finding documented for the `TheMaster` Ronin path's dance-emote workaround elsewhere in this
file — so a system that grants real, persistent stat gains can't be driven by it. Instead this
mirrors the existing `MinutesMeditated` pattern: a `Character.Meditating`-style flag
(`Character.Exercising`, a StringValue naming the active exercise) ticked once per real minute
from `StarterCharacterScripts/Health.server.luau`'s existing per-player `wait(60)` loop, which
already increments `MinutesMeditated`/`MinutesSurvived`/`DaysSurvived` the same way.

**Data model**: 5 new `PlayerData` NumberValues (0-30 raw points each, hypertrophy level =
`math.floor(points/3)`, so 30 points = 10 hypertrophy = fully maxed): `WorkoutChestPoints`,
`WorkoutLegsPoints`, `WorkoutCorePoints`, `WorkoutShouldersPoints`, `WorkoutBackPoints`, plus one
`WeightsOwned` BoolValue. **These do not exist yet and can't be added by editing files alone** -
per this repo's Argon convention (see top of this doc), new `PlayerData` defaults are registered
through a Studio-only `Setup` folder (`script.Setup` under `GameLoaded`, consumed by
`GameLoaded/init.server.luau` and `CharacterCreationGui/Script.server.luau`) that isn't part of
the `src/` tree — all 6 fields need to be added there in Studio before this system does anything;
every other line of code here already trusts they exist, matching how `MinutesMeditated`/
`TotalGrips` are read with no defensive nil-checks elsewhere in this codebase.

**Exercise → category mapping** (`WorkoutModule.EXERCISE_CATEGORIES`): Pushups → Chest **and**
Shoulders (+1 each per completed session, not split); Squats → Legs; Situps and Russian Twists
both feed the same Core pool (either exercise works); Bent Over Row → Back, and additionally
requires `PlayerData.WeightsOwned.Value == true` before it'll even start - gated as a server-truth
PlayerData flag rather than a Backpack-presence check, per this session's own spoofable-check
security fix earlier in this doc. Weights (`ServerStorage/Storage/Weights/`) is a new
find-or-buy-separately consumable, same one-shot pickup shape as Black Pill
(`ServerStorage/Storage/Black Pill/Script.server.luau`) - sets the flag, then
`Commands.RemoveFromInventory` + destroys itself.

**Mechanics** (`WorkoutModule.toggleExercise`/`tickMinute`): pressing an exercise Tool toggles a
`Character.Exercising` marker + a `Character.ExerciseMinutes` counter, plays the Tool's own
`Anim` on loop (no `Anim` asset exists yet for any of the 5 - see asset debt below, same
"references it by name, Studio has to add it" situation as every other new move Tool in this
doc), and starts a `task.wait(0.2)` poll loop that cancels the session (matching
`Meditating`'s own cancel-on-move check) if the player moves
(`Humanoid.MoveDirection.Magnitude > 0.6`), unequips the Tool, or (Bent Over Row only) somehow
loses `WeightsOwned`. Every real minute this ticks 3 times before rolling over into +1 point per
mapped category (capped at 30) and re-running `applyHypertrophyBoosts`. Pressing the *same*
Tool again while already exercising cancels early instead of starting a second session - a
different exercise Tool is a no-op while one is already active (this session did not build a way
to switch exercises mid-session without stopping first). Startup is gated through the existing
shared `ServerScriptService/Modules/ActionCheck.luau` module (same `presentBlocks` shape every
other move already uses), so e.g. `Charming Stone`'s `Charmed` status blocks starting a workout
for free.

**Combat/movement effects, all in `WorkoutModule.applyHypertrophyBoosts`** (re-run at spawn and
on every point-gain, so mid-life level-ups apply immediately, not just next spawn):
- **Legs**: standing `Boosts.SpeedBoost` (`hypertrophy * 0.3`, so +3 WalkSpeed at 10) for "run
  slightly faster." Kick damage ("kicks dealing more damage") is a separate mechanism: a new
  `info.kick` flag (added to `Axe Kick`'s and `Spin Kick`'s own `Info` tables - the only 2 kick
  moves found in `ServerStorage/Classes/`) read centrally at
  `TagHumanoid/init.server.luau` (~line 897, right after the existing `MeleeDamageMultiplier`
  block) against the *attacker's* `PlayerData.WorkoutLegsPoints` directly (not a
  Character/Backpack marker - server-truth, same reasoning as the security-fix pass), `1 +
  hypertrophy*0.04` (so +40% at 10).
- **Core**: `ServerScriptService/Modules/m1.luau`'s hardcoded `attackspeed = 0.475` local now
  divides by `1 + corehypertrophy*0.05` (~33% faster unarmed M1 at 10) - m1 didn't read any
  `Boosts` multiplier before this, so this is a direct, m1-only speed-up. Core *also* (along with
  Chest, see below) contributes to a standing `Boosts.AttackSpeedBoost` for "some of your moves
  faster" - this is the same NumberValue every weapon Activator already divides its own debounce
  by (e.g. `Weapons/Dagger/Activator.luau:66-74`), so it only speeds up moves/weapons that already
  read that Boost, not literally every move in the game.
- **"The faster they get, the more damage they deal" (Core) / "minor attack speed and damage
  boost" (Chest)**: implemented as two numbers both scaled off the same hypertrophy stats, not a
  literal runtime speed measurement feeding into damage - a new `Boosts.HypertrophyDamageMultiplier`
  (`1 + core*0.02 + chest*0.01`, so up to +30% at both maxed), read/clamped (0-2, same
  spoofable-Boosts-value reasoning as `MeleeDamageMultiplier`) right next to that existing block.
  Deliberately a distinctly-named NumberValue rather than folding into `MeleeDamageMultiplier`
  itself, since a second system creating another same-named instance there would silently
  overwrite/fight the existing one (only one `FindFirstChild` match is ever read).
- **`Boosts.SpeedBoost`/`Boosts.AttackSpeedBoost` are shared, summed/stacked names** other systems
  also create instances of (`Agility`, `TheMaster`'s permanent grant, etc. - `Input/init.client.luau`
  sums every child literally named `SpeedBoost`, and every weapon Activator divides by every child
  named `AttackSpeedBoost` in turn). Re-finding "my" instance by name alone on every recompute
  would risk grabbing and overwriting an unrelated system's instance of the same name, so
  `applyHypertrophyBoosts` tags its own instances (`CollectionService`, tag `"HypertrophyBoost"`)
  and destroys+recreates only those every time it runs, instead of mutating in place.
- **Chest's "push Creature more easily" is explicitly stubbed** - confirmed during this session's
  research that no monster-push/resistance mechanic exists anywhere in this codebase (`Shove`
  applies identical knockback regardless of target type; monsters are only ever distinguished via
  `enemy:FindFirstChild("MonsterInfo")` for injury/status-immunity purposes, never knockback
  scaling) and the user chose not to build one this session - only Chest's attack-speed/damage
  contribution above is implemented.
- **Shoulders / Back have no combat effect at all** - pure point/hypertrophy tracking, reserved
  for the user's described future "heightmogging"/frame system, which doesn't exist yet (same
  "data tracked now, mechanic built later" shape as every ascension system's pity flag before its
  trial existed). The one thing both categories maxed *does* do right now: talking to
  `Clavicular` (`dialogues["Clavicular"].v1`,
  `WorldHandler/Dialogues/DialogueHandler/ModuleScript.luau`) with `WorkoutShouldersPoints >= 30
  and WorkoutBackPoints >= 30` calls `_G.Death(p)` immediately instead of any normal dialogue -
  the requested joke.

**Asset debt** (same Argon caveat as every other feature in this doc needing a world/Studio-side
addition): the 6 `PlayerData` `Setup`-folder fields above; 5 new exercise Animations (`Anim`
under each of the 5 Tool folders - none exist yet, so each Tool's `LoadAnimation(tool.Anim)` call
will run with no animation until Studio adds one, same "will error/no-op until the asset exists"
situation already true of `Septic Burst`'s own `script.Parent.Anim` reference elsewhere in this
doc); the Weights item's actual world placement/shop entry and mesh (like every other new
`Storage` item in this repo); and Tool icons/models for all 5 exercise Tools (functional without
one, but no bespoke model exists).

**Interpretive calls worth flagging**: exact numbers throughout (0.3 SpeedBoost/point, 0.04
kick-damage/point, 0.05 m1-speed/point, 0.04/0.02 AttackSpeedBoost per Core/Chest point, 0.02/0.01
HypertrophyDamageMultiplier per Core/Chest point, the 0.6 MoveDirection-magnitude cancel
threshold, the 0.2s poll interval) are feel-based, not spec-derived, matching this repo's own
established practice of flagging tunable numbers rather than deriving them from a balance spec -
flag for tuning. Pushups awarding a full point to *both* Chest and Shoulders (not split between
them), Bent Over Row's Weights requirement being a permanent find/buy-once unlock rather than
something that must be equipped simultaneously, and Chest's push-creature effect being stubbed
entirely were all explicit user decisions made during this session's planning, not assumptions.

## New system: Supplements (added 2026-07-28)

A second new consumable category, layered on top of both the pre-existing Alchemy potion
convention and the workout system above. Starts with one item, **Preworkout**
(`ServerStorage/Storage/Preworkout/`), plus a new shared module,
`ServerScriptService/Modules/SupplementModule.luau`, so future supplements reuse the same
buff-application/Fischeran-bonus logic instead of each hardcoding it (same shape as
`WorkoutModule` for the workout Tools).

**Built on the existing Alchemy potion shape, not the Storage-artifact shape**: confirmed during
this session's research that `ServerStorage/Alchemy/Tools/<Potion>/` (Health Potion, Ice
Protection, Liquid Wisdom, etc.) is a distinct, already-established convention from the
Black-Pill-style one-shot artifact Tools used elsewhere in this doc - a `Script.server.luau` +
`LocalScript.client.luau` pair driven by a Tool-owned `RemoteEvent` with a `"Self"`/`"Pour"`
`dtype` (left-click drinks it yourself, `P` pours it on whoever your mouse is over), consumed via
`require(game.ServerScriptService.ToolHandler).RemoveTool(...)`, and costing `Toxicity` on use.
`Preworkout` copies this shape exactly (including the same junk boilerplate header every existing
potion script has - matched for consistency, not because it does anything) but lives under
`ServerStorage/Storage/` (cloned by `commands.AddToInventory`, the same dialogue-purchase path
Health Potion's own `Storage/Health Potion` copy uses) rather than also duplicating into
`Alchemy/Tools/` - this session didn't build a crafting-recipe hookup for it, so Preworkout is
buy/find-only for now; a brewable `Alchemy/Tools/Preworkout` mirror could be added later following
Health Potion's own dual-location precedent if that's wanted.

**`SupplementModule.applyBuff(character, buffName, speedBoost, atkSpeedBoost, duration,
toxicity)`**: creates a Debris-timed marker named `buffName` on the Character (this is what
Haseldan's rage checks below key off), an equivalent-shaped `Boosts.SpeedBoost`/
`Boosts.AttackSpeedBoost` pair (not tagged/recreated like `WorkoutModule`'s hypertrophy boosts,
since supplement buffs are always temporary/Debris-timed rather than standing recomputed values -
a plain new instance each dose is fine here), and a `Toxicity` cost. **Preworkout's own numbers**:
`SpeedBoost = 3`, `AttackSpeedBoost = 1.15`, `duration = 600` (10 minutes), `toxicity = 40` -
feel-based, flagged for tuning like every other number in this doc.

**Fischeran: "become part supplement" (per the design brief - they're liquid)** - built directly
into `SupplementModule.applyBuff` itself (not Preworkout-specific), so every future supplement
gets this for free: if the drinker's `PlayerData.Race.Value == "Fischeran"`, both `SpeedBoost` and
`AttackSpeedBoost` are scaled `1.5x` before being applied, `Toxicity` cost is halved, and an
additional `SupplementFischeran` marker (same Debris duration) is dropped on the Character -
currently pure flavor/a hook for future Fischeran-specific content, not read anywhere else yet.
No existing Fischeran lore ties them to liquid/water mechanically (confirmed via this session's
research - their only prior racial hooks are the shared `Vind`/`Fischeran` regen bonus in
`Health.server.luau` and the `WindDodges` dodge-charge mechanic shared with DullahanBawa) - this
is new flavor established by this request, not an extension of something pre-existing.

**Haseldan: Preworkout boosts their racial rage, in two places**:
- **Automatic rage** (`StarterCharacterScripts/Health.server.luau`'s `haseldanrage()`, triggered
  when a non-immune Haseldan's health drops low): if a `Preworkout` marker is present on the
  Character at the moment rage triggers, `HaseldanDamageMultiplier` goes 45s→65s, `SuperStrength`
  goes 50s→70s, and the shared `RageCooldown` (which blocks re-triggering either this or the
  manual ability below) shortens 300s→240s. Doesn't consume the Preworkout dose - the automatic
  proc can fire again with the same dose still active if health drops low a second time before it
  expires.
- **Manual "Supplement Rage"** (`ServerStorage/RacialAbilities/Bloodline/Script.server.luau`, the
  existing player-activated "rise from Unconscious" Tool) - a genuinely new conditional *variant*
  of the same rage rather than a separate Tool, since the request called it a "conditional
  bloodline variant" and `Bloodline` is literally this ability's existing name. Checked once at
  the top of the existing `Unconscious`-gated block: if `Preworkout` is present, it's consumed
  immediately (one variant-trigger per dose) and the whole rest of the block reads a
  `supplementRage` local instead of hardcoded numbers - `HaseldanDamageMultiplier`/`SuperStrength`
  30s→45s, `RageCooldown` 300s→240s (same shortened value as the automatic rage above, for
  consistency), health-back `+40`→`+60`, and - the biggest behavioral difference - **the vanilla
  version's own drawback (a forced `Unconscious`/`Knocked` collapse 30s later for a non-Ascended
  Haseldan) is skipped entirely** for the supplement-fueled variant, on the reading that a
  controlled, supplement-assisted rise back up should be safer than an unstable racial outburst,
  not just numerically stronger.

**Asset debt**: Preworkout's Tool-owned `RemoteEvent` (a Studio-side child every existing potion
Tool already has and isn't tracked in `src/`, same as their `Handle`/`Handle.Cork`/
`Handle.Drinking` props - this session added no new asset requirement here, it's the same
pre-existing gap every Alchemy potion already has); no shop/NPC purchase wiring exists yet for
Preworkout specifically (same "world placement is on whoever has Studio access" caveat as every
other new `Storage` item in this doc, e.g. Weights).

**Interpretive calls worth flagging**: all exact numbers above (buff magnitudes, the 1.5x/0.5x
Fischeran scale, the 65/70/240 and 45/45/240/60 Haseldan numbers, the 600s duration) are
feel-based, not spec-derived, per this repo's own established practice. Reading "conditional
bloodline variant" as a branch inside the existing `Bloodline` Tool (rather than a new Tool) and
building the Fischeran bonus as a generic `SupplementModule` feature (rather than something
Preworkout-only) were both judgment calls made to fit the brief's wording and this session's
established "shared module for repeated logic" pattern, not things the brief specified outright.

**Follow-up (still 2026-07-28): Preworkout is now craftable at the Alchemy Table.** Confirmed via
research that potion crafting is a wholly separate system from both the artifact-Storage and
supplement mechanics above: `ServerScriptService/Alchemy/init.server.luau`'s crucible logic
(`concoct`, ~line 164) reads a flat, unordered, set-compared recipe table from
`ServerScriptService/Alchemy/list_alchemy.luau` (`module.recipes`), and on a match clones the
resulting Tool from **`ServerStorage/Alchemy/Tools/<Name>`** specifically (via
`ToolHandler.GiveAlchemy`, `ServerScriptService/ToolHandler.luau:91`) - a completely different
folder from the `ServerStorage/Storage/<Name>` copy dialogue-purchases clone from
(`commands.AddToInventory`). Health Potion (and every other existing potion) already has both
copies for this reason - one per acquisition method, not a dead duplicate - so making Preworkout
craftable meant adding a matching `ServerStorage/Alchemy/Tools/Preworkout/` (identical
`Script.server.luau`/`LocalScript.client.luau`/`init.meta.json` to the `Storage` copy built
earlier) rather than moving/reusing the existing one.

**Recipe**: `list_alchemy.luau`'s `module.recipes["Preworkout"] = {recipe =
{"Vile Seed","Vile Seed","Scroom"}}` - two `Vile Seed` (whose existing in-game tooltip is "It's
actually a bean," a pre-existing joke this recipe leans on for a stimulant/caffeine reading) plus
one `Scroom` (already tagged `hot = true` in the ingredients table, i.e. thematically "energetic").
Checked against every existing recipe for an exact-multiset collision (recipes are matched as an
unordered set, first match wins) - distinct from `Kingsbane`'s `{Crown Flower, Vile Seed, Vile
Seed}` and `Health Potion`'s `{Scroom, Scroom, Lava Flower}`, the two closest existing recipes.

**Nothing else needed touching**: the crucible's matching loop, the `Potion Efficiency`
double-yield skill check, and the miscraft-explosion logic are all fully data-driven off
`list_alchemy.luau`/`Alchemy/Tools` - adding the one recipe entry plus the one Tool folder is a
complete, working addition with no other file changes required. `Vile Seed` already appears in the
crucible's volatile-ingredient miscraft-explosion list, but that only triggers on a *failed*
(non-matching) combination - crafting the correct `Preworkout` recipe is a normal, safe brew.

**"...and supplements" scope note**: confirmed there is no engine-level "supplements" grouping in
the Alchemy system (every recipe maps 1:1 to one Tool name, no category concept exists) - so this
follow-up request is satisfied by Preworkout now following the exact same dual-location
(`Storage/` + `Alchemy/Tools/`) plus `list_alchemy.luau` recipe pattern as every other potion.
Any future supplement built the same way (a `SupplementModule.applyBuff` call in its
`potionEffect`) is automatically "craftable at the Alchemy Table" the moment someone adds its own
`Alchemy/Tools/<Name>` copy and `list_alchemy.luau` recipe entry - no further system-level work is
needed, just repeating this same two-step pattern per future supplement.

No new asset debt: Preworkout's `Alchemy/Tools` copy relies on exactly the same pre-existing
Studio-side `RemoteEvent`/`Handle` props every other potion Tool already needs (see the asset-debt
note above) - nothing new was introduced by making it craftable.

## New supplement: Creatine (added 2026-07-28)

Second supplement, built purchasable *and* craftable from the start (both
`ServerStorage/Storage/Creatine/` and `ServerStorage/Alchemy/Tools/Creatine/`, plus a
`list_alchemy.luau` recipe) following the two-step pattern the Preworkout follow-up just
established above, rather than needing a separate crafting request this time.

**Deliberately a different lane from Preworkout, not a reskin.** Preworkout is speed/energy
(stimulant flavor); Creatine is strength/mass (real-world creatine flavor: more power output,
water-retention bulk), so `SupplementModule.applyBuff` gained three new optional trailing
parameters (`damageMult`, `healthBoost`, `superStrength`) rather than Creatine just calling the
existing speed/attack-speed params with different numbers:

- **`damageMult`** creates a new, distinctly-named `Boosts.SupplementDamageMultiplier` -
  deliberately *not* another `Boosts.MeleeDamageMultiplier` instance, since that name is already
  shared by 7 existing grantors (Rage/Overclock/Plasticity/Dragon Blood/Dragon Awakening/True
  Vision/Soul Rip per the earlier security-fix section) and `TagHumanoid` only reads *one* such
  instance via `FindFirstChild` - a same-named second source would silently overwrite/lose
  whichever isn't found first rather than stacking. Read/clamped (0-2) at
  `TagHumanoid/init.server.luau` right next to the workout system's own `HypertrophyDamageMultiplier`
  block, same collision-avoidance reasoning.
- **`healthBoost`** reuses the *existing* `Boosts.HealthBoost` name on purpose - confirmed via
  `Health.server.luau`'s `applyHealth()` that this one already sums every matching Boosts child
  (a `for`-loop, not `FindFirstChild`), so it was already safe to stack and needed no new name.
- **`superStrength`** reuses the existing knockback-doubling mechanic
  (`TagHumanoid/init.server.luau:342`, `character.Boosts:FindFirstChild("SuperStrength")`), parented
  to `Boosts` specifically (not directly to Character) so it can never collide with Haseldan's own
  Character-parented rage version of the same name.

**Creatine's own numbers**: `damageMult = 1.15` (+15%), `healthBoost = 0.08` (+8% max health,
"water retention"), `superStrength = true` (doubled knockback for the duration), `duration = 600`
(10 minutes, same as Preworkout), `toxicity = 25` (lower than Preworkout's 40 - creatine's
real-world reputation as one of the more benign supplements). Fischeran get the usual amplified/
discounted treatment for all of this automatically, since it's all still routed through the same
`SupplementModule.applyBuff` - no Creatine-specific Fischeran code was needed.

**Recipe**: `{"Potato","Potato","Trote"}` - two `Potato` (existing tooltip "I can't eat this raw,"
a bulk/mass pun fitting creatine's bodybuilding association) plus `Trote` (already flavored as "a
binding agent," read here as "binds/builds the body"). Checked for exact-multiset collisions
against every existing recipe (none - `Bone Grow`/`Fire Protection`/`Ice Protection` are the only
other recipes using `Trote`, all with different other two ingredients).

**Interpretive calls worth flagging**: this request didn't ask for a Haseldan/Fischeran-style
racial hook like Preworkout's follow-up did, so none was added beyond the automatic generic
Fischeran bonus every supplement already gets for free - if Creatine is meant to interact with a
specific race's ability the way Preworkout ties into Haseldan's rage, that's still open. All exact
numbers (1.15/0.08/25/600, the ingredient choice) are feel-based, not spec-derived, per this
repo's established practice.

## Fixed: Black Pill accessories didn't scale with the rig (2026-07-28)

`ServerScriptService/Modules/CharacterScale.luau`'s `scaleR6` (used by the Black Pill artifact,
see that section above) resized the 7 named R6 BaseParts and rescaled every `Motor6D`'s C0/C1
*position* so joints stay lined up - but accessories (hats, hair, etc.) kept their original
physical size, just moving out to a rescaled attachment point. Two fixes, both in the same
function:

1. **The join-scan now also covers `Weld`** (`joint:IsA("Motor6D") or joint:IsA("Weld")`), not
   just `Motor6D`. Confirmed most accessories in this game attach via a plain `Weld` baked in at
   authoring time in Studio, not `Motor6D` - the original comment's "rare, but some do this"
   framing had it backwards; Motor6D-attached accessories are the rare case. This means most
   accessories' attachment offsets were **never actually being rescaled** before this fix, not
   just under-scaled - a real, if quiet, bug in the original Black Pill work.
2. **New: every `Accessory`'s `Handle` (a direct child of Character, standard Roblox layout) has
   its own `Size` multiplied by the same factor, plus its `SpecialMesh.Scale` if it has one** -
   this is the actual "accessories scale with the rig" fix the Weld/Motor6D change above doesn't
   provide on its own (that only moves the attachment point; this makes the object itself bigger).

Both changes are inside the same `scaleR6(character, factor)` call, so nothing else needed
touching - Black Pill's own Tool script and `CharacterHandler/init.server.luau`'s spawn-time
re-application both already call this function and get the fix automatically.

## New system: Chad rank / MogPoints (added 2026-07-29)

A persistent, cross-server competitive leaderboard layered on top of the existing Mogging Tool
(see the Mogging/Rage-Squeamish section elsewhere in this doc) - "spawning in with higher
attractiveness starts you out with a higher base mog points but it scales linearly... whenever you
mog a target you gain mog points, getting mogged loses you mog points... the mog ranking should
appear in the leaderboard and replace the current grippoints system, which doesn't work."

**Real bug found and fixed while wiring this in**: `MoggingModule.resolve()`'s "outclassed"
reversal and its whole weighted-coinflip QTE branch were nested as the `elseif`/`else` of an
*inner* `if diff >= TERMINATION_THRESHOLD` check, which itself only runs inside the *outer*
`if diff >= ATTRACTIVENESS_THRESHOLD` block. Since `diff` can't simultaneously be `>= 8` and
`<= -8`, that `elseif diff <= -ATTRACTIVENESS_THRESHOLD` (and the QTE `else` hanging off the same
chain) was mathematically unreachable - **mogging had only ever done anything when the caster was
clearly more attractive (`diff >= 8`) since this module was written; the "outclassed" reversal and
the entire QTE coin-flip case had never actually fired once, silently.** Found because MogPoints
needs to transfer on every resolution outcome, not just the one that happened to be reachable -
flattened into three proper sibling branches (`diff >= ATTRACTIVENESS_THRESHOLD` /
`diff <= -ATTRACTIVENESS_THRESHOLD` / else) with identical behavior to what each branch's own code
already said it should do, just actually reachable now.

### MogPoints - seeding and transfer (`ServerScriptService/Modules/MoggingModule.luau`)

New `PlayerData.MogPoints` NumberValue (needs adding to the Studio Setup folder, default `0` - the
"not yet seeded" sentinel, same lazy-roll convention as `AttractivenessBase`/`HeightMultiplier`).

- **`module.seedMogPoints(data)`**, called once at every spawn from `CharacterHandler/init.server.luau`
  (right after the existing `AttractivenessModule.compute()` call, so a fresh `Attractiveness`
  value is already on hand): if `MogPoints.Value == 0`, seeds it to
  `floor(Attractiveness * 10)`, floored at `1` (never `0`, so the sentinel can never
  recur from natural gameplay loss - MogPoints reaching a genuine 0 by losing mogs would otherwise
  incorrectly re-trigger a reseed on next spawn). **Deliberately seeded once ever, not re-rolled
  per character** - unlike `AttractivenessBase` itself, which the height/attractiveness
  carry-over rule (see that section above) can leave un-reset - MogPoints is a persistent,
  account-level competitive stat that only ever changes via mogging duels from here on; a new
  character must not reset a player's rank progress.
- **`transferMogPoints(winnerPlayer, winnerData, loserPlayer, loserData)`** (local, called from
  all three branches of the now-fixed `resolve()`): steals
  `clamp(5 + gap * 0.1, 5, 100)` points, where `gap = abs(winnerPoints - loserPoints)` - read
  literally per the request ("higher mog points difference losing you more points, while being
  similarly ranked will not steal as many points"), not an ELO-style "upset size" calculation.
  Zero-sum - the winner only ever gains what's actually removed from the loser (respecting the
  floor of `1`), never points from nowhere. Sends the requested
  `"You have gained/lost X mog points."` alert to both sides via `AlertModule.send`, and fires
  `MogRankHandler`'s `UpdateMogPoints` BindableEvent for both players so their global Chad rank
  resyncs immediately rather than waiting on a periodic resort. All four constants
  (`MOG_POINTS_PER_ATTRACTIVENESS = 10`, steal base `5`/gap-factor `0.1`/min `5`/max `100`, floor
  `1`) are feel-based, not spec-derived, per this repo's established practice.
- `Mogging/Script.server.luau`'s call site now passes both `Player` instances
  (`MoggingModule.resolve(player, character, casterData, casterAttr, targetPlayer, validTarget,
  targetData, targetAttr)`) so `transferMogPoints` can alert them directly - `resolve()`'s
  signature changed accordingly. `AttractivenessModule.compute()`'s own low-Attractiveness
  self-trigger (which calls `applyMogDebuffs` directly, not `resolve()`) is untouched and does NOT
  transfer MogPoints - there's no "opponent" in that self-trigger case, and the request only
  described the Mogging-Tool interaction between two players.

### Chad rank replaces Grip-based Prestige (`ServerScriptService/WorldHandler/MogRankHandler.server.luau`, new)

Reuses the **exact same** `PlayerData.Prestige` / `leaderstats.Prestige` field the existing
`StarterGui/LeaderboardGui/LeaderboardClient.client.luau` already renders as a `"#N"` prefix next
to a player's name - confirmed via that client script that it's purely a generic rank-number
display with no Grip-specific text baked in, so repurposing what feeds `Prestige` server-side was
enough; **no client/GUI changes were needed** to satisfy "I want the mog ranking to appear in the
leaderboard."

Mirrors `MoneyRankHandler.server.luau`'s existing OrderedDataStore-rank shape (an
already-established, presumably-working pattern in this codebase, unlike the Grip one being
replaced) but:
- Keyed on `PlayerData.MogPoints.Value` directly rather than a parallel `ServerStorage.RankData`
  folder counter - MogPoints already lives on `PlayerData` (persisted independently via
  DataStore2), so there's no separate live counter to keep in sync the way Grips/Money need one.
- **Paginates up to 250 entries** (`GetSortedAsync` + `AdvanceToNextPageAsync` stitched together),
  not the 100 Grip/Money rank settle for - "the mog leaderboard should go from 1 to 250," per the
  request.
- **No AFK-decay routine** - not requested, and one of the more complex, harder-to-verify parts of
  the system being replaced; left out rather than risk reproducing whatever made the original
  "not work."
- **Explicitly zeroes `Prestige` for any online player who drops out of the top 250** entirely,
  which the original Grip/Money handlers' own `UpdateRankData` never did (they only ever set a
  rank for entries actually found in the current sorted page, silently leaving a stale rank number
  forever once a player fell out of it) - a real staleness bug in the pattern being copied from,
  fixed here rather than reproduced, since "doesn't work" was the whole reason for this rewrite.
- **"#1 Ranked Chad ... has arrived to Gaia"**: broadcast via the new `AlertModule.broadcast(text,
  duration)` (added alongside this - just `module.send` looped over `game.Players:GetPlayers()`,
  no new RemoteEvent needed) from `PlayerAdded`, only when the just-joined player's freshly-looked-up
  rank is exactly `1`.

**`RankHandler.server.luau` (the old Grip-rank system) was NOT deleted or fully disabled** - only
its two `PlayerData.Prestige.Value = ...` assignments (in `UpdateRankData` and `PlayerAdded`) were
removed, with the rest of the file (the `RankData/<Player>/Grips` NumberValue creation, the
`UpdateGrips` BindableEvent increment, the `GripRank` OrderedDataStore sync) left completely
untouched. This was a deliberate, confirmed-necessary choice, not caution for its own sake:
`GameLoaded/init.server.luau` (an Edict-legitimacy check) and the character-recreation reset flow
both directly read/write `game.ServerStorage.RankData[Player.Name].Grips.Value` as a bare
`FindFirstChild`-free index - fully disabling `RankHandler.server.luau` would have stopped that
Instance from ever being created and thrown a runtime error the first time either of those other
two files ran, breaking character creation entirely. Grips itself keeps counting and syncing to
its own (now purely informational) OrderedDataStore; it's only the derived "your rank is N"
write to `Prestige` that stopped.

**Side effect flagged, then resolved by request**: `GameLoaded/init.server.luau`'s Edict-legitimacy
check originally read `if data.Prestige.Value <= 5 and data.Prestige.Value > 0 and
RankData[p.Name].Grips.Value >= 250 then ... AddTag("LegitEdict") ...` - a compound gate mixing
the new and old systems, since `Prestige`'s meaning changed to Chad rank but the separate raw
`Grips.Value >= 250` half (a leftover grip-kill requirement from when Prestige was Grip-rank
itself) wasn't touched. **Follow-up (still 2026-07-29): the `Grips.Value >= 250` clause was removed
outright**, per direct request ("remove the grip kills requirement") - this gate is now just
`data.Prestige.Value <= 5 and data.Prestige.Value > 0` (top-5 Chad rank, full stop). Confirmed via
a repo-wide grep that this was the only place `Prestige.Value` and `Grips.Value` were checked
together, so no parallel copy needed the same fix.

**Asset debt**: `MogRankHandler.server.luau` needs a Studio-placed `UpdateMogPoints` BindableEvent
child (same situation as `RankHandler`/`MoneyRankHandler`'s own pre-existing `script.UpdateGrips`
- a plain Instance under a synced Script, not something a `.luau` file alone can create). One new
`PlayerData` field, `MogPoints` (NumberValue, default `0`), needs adding to the Studio Setup
folder, same as every other new `PlayerData` field in this doc.

### "#1 Ranked Chad has gated to ..." (`ServerStorage/Classes/Gate/Activator.luau`)

Checked right after the teleport portal opens (`v66.Prestige.Value == 1`, `v66` being the caster's
already-resolved PlayerData local): broadcasts `"#1 Ranked Chad <FirstName> <LastName> has gated
to <location>"` via `AlertModule.broadcast`. Fires for **any** successful teleport, including a
randomized backcast/miscast destination - from every other player's perspective the #1 Chad still
visibly gated somewhere, backfired or not. Location label is `lower(u14.Name .. (u15 or ""))` -
`u14` is the resolved destination `WarpPoints` folder, `u15` the sub-location identifier if the
cast picked one - built to roughly match the request's own `"desert1"`-style example.

**The 30-second cooldown is a single module-level local (`lastChadGateAnnounce`)**, not a per-player
one - since `Activator.luau` is required once and shared by every Gate cast from every player, this
is a genuine server-wide cooldown on the *announcement itself* ("with a 30 second cooldown," as
worded in the request), completely independent of Gate's own existing per-player `SnapCD` cooldown
mechanic.

### Interpretive calls worth flagging

The MogPoints seed/steal constants (`*10` scale, steal `5 + gap*0.1` clamped `[5,100]`, floor `1`)
are feel-based, not spec-derived. Reading the steal formula as "absolute point gap, zero-sum
transfer" rather than an ELO-style "beating a stronger opponent gains more" curve was a literal
reading of the request's own wording, not an attempt at a more sophisticated rating system.
Reusing `Prestige` instead of introducing a new `ChadRank`/`MogPrestige` field name was a
deliberate low-risk choice - every existing consumer (the `Changed` listener that mirrors it onto
`leaderstats`, `LeaderboardGui`, `ServerBrowseBeta`'s ranked-player count) keeps working unchanged,
agnostic to what the number means. Not tested in Studio (no Studio access this session, same
limitation noted throughout this doc) - the OrderedDataStore pagination and the two BindableEvent-
dependent asset-debt items above especially need a live check once possible.

## New: race-based skin color (2026-07-28)

Character skin color was previously read from the *player's own Roblox account avatar*
(`game.Players:GetCharacterAppearanceInfoAsync(Player.UserId).bodyColor3s.torsoColor3`, in the
character-appearance setup inside `Commands/init.luau`'s big per-character-load function) - so
two players of the same race could look completely different, and a player's chosen race had no
visual bearing on their skin tone at all.

**Corrected mid-session**: the first pass wrongly assumed no per-race skin color data existed and
built a brand new `ReplicatedStorage/Info/RaceSkinColors.luau` data module to hold one. That
module has since been **deleted** - `ReplicatedStorage.Info.Races.<Race>.SkinColor` (a
`Color3Value`) already exists in Studio as a sibling of the `HairColor`/`EyeColor` values this same
function already reads (confirmed by the user, not discoverable from `src/` alone since, like the
rest of `Info.Races`, it's a Studio-only Instance tree with no corresponding files in git - same
asset-debt situation as every other Studio-side data tree in this doc). The actual fix is a
one-line swap in `Commands/init.luau`'s character-appearance `task.spawn` block: `local SkinColor
= RaceInfo.SkinColor.Value` in place of the `GetCharacterAppearanceInfoAsync` call - `RaceInfo` is
already resolved earlier in the same function (~line 102-108: base race folder, swapped for
`"Ascended"..Race` if ascended, then descended into `RaceInfo[RaceVariant]` if a variant folder by
that name exists - e.g. `Dinakeri.Deep`), so reading `RaceInfo.SkinColor.Value` at the point
`HairColor`/`EyeColor` are already being read from the same resolved `RaceInfo` automatically picks
up a variant's own `SkinColor` too, with no extra code needed for that.

The Vampire-specific desaturation logic immediately below the color lookup (`SkinColor:ToHSV()`
halving saturation) was left completely untouched - it now desaturates the race-data color instead
of the old account-based one, same mechanic either way.

No asset debt: every race's `SkinColor`/`HairColor`/`EyeColor` already exists in Studio today (this
data predates this session entirely) - this change only swaps which source the code reads from.

**Bug noticed but not touched** (pre-existing, unrelated to this change): `Commands/init.luau`
~line 121, `if Race.Value == "Rigan"or Race.Value == "Fischeran" then` - `Race` here is a plain
string local (`local Race = Data.Race.Value`, line 102), not a `Value`-holding Instance, so
`Race.Value` silently evaluates to `nil` (Lua doesn't error on indexing a string with a
nonexistent field) and this branch's condition is always `false`. The special Rigan/Fischeran
face-lookup it guards (`ReplicatedAssets.Faces.Rigan`) appears to never actually run. Flagged per
this doc's own convention for incidentally-found bugs (see the `ModStop` stray-backtick note
above) rather than fixed, since it's unrelated to the skin-color change that surfaced it.

## New: Termination, Mirror self-image death, and the "self image misunderstanding" injury (2026-07-28)

Three linked pieces, all built around a single new shared module.

**`ServerScriptService/Modules/TerminationModule.luau`** (new) - `module.trigger(character)`:
guards on `Immortal`/an existing `Terminating` marker/already-dead, then applies `Terminating`
(3s, a dedicated re-trigger guard) plus the standard `Knocked`+`Unconscious` accessories (also 3s),
plays the existing `HumanoidRootPart.SCREAM1` sound (reused from `Bloodline`, no new asset needed),
and after a `task.delay(3, ...)` calls `_G.Death(player)` - guarded by re-checking the character
still exists and has `Health > 0`, so it can't double-kill someone who already died some other way
in the meantime. Built as a shared module rather than two copies (or trying to simulate a Tool
`Activated` from a non-Tool script) because it needed two independent callers - same "one place,
multiple callers" shape as `WorkoutModule`/`SupplementModule` elsewhere in this doc.

**`ServerStorage/Classes/Termination/`** (new Tool) - a thin `Activated` handler: the usual shared
`ActionCheck.luau` guard (`presentBlocks` list matching every other move Tool's shape), then calls
`TerminationModule.trigger` on `script.Parent.Parent` (self, not a target - this is a self-directed
move, never something you use on an enemy). Granted to every player at spawn
(`CharacterHandler/init.server.luau`, right after the workout Tools' own spawn-grant block, same
`Backpack:FindFirstChild`/`Character:FindFirstChild` persists-across-respawns guard). No cooldown -
using it kills you, so there's nothing to gate re-use of beyond the next respawn.

**Mirror `ClickDetector`s** (`WorldHandler/Touched.server.luau`, inside the existing
`workspace.Seats.MirrorPair.Mirror` loop that already wires up the `In`/`Out` `Touched` events for
the Dark Sigil Knight/`WraithTraining` teleport mechanic): a `ClickDetector` is now created and
parented to each `Mirror` instance **entirely in code**, at the same point the existing Touched
connections are wired - no Studio placement needed for the detector itself, since (unlike a new Tool
folder) this is just an `Instance.new` call inside an already-live, already-running world script,
same pattern this file already uses to wire up the `In`/`Out` `Touched` events on those same
pre-existing Mirror objects. `MouseClick` resolves the clicking player's `PlayerData` and branches:
- **Self-image death**: if `Data.Injuries.Value:find("self image misunderstanding")`, OR the
  player has *any* injury at all (`Data.Injuries.Value ~= ""`), OR they have an existing facial
  scar (`Data.FacialMark.Value ~= "None" and ~= ""` - see below, this is nearly universal by
  default for most races already) - looking in the mirror calls `TerminationModule.trigger`
  on themselves instead of anything else.
- **Otherwise, Black Pill holders get a "Confidence" buff**: seeing their artificially-enlarged
  reflection grants a temporary `Boosts.SpeedBoost` (+2) and `Boosts.AttackSpeedBoost` (+10%, 5
  minutes, plus a `Confidence` marker Accessory for flavor/future checks) - reuses the same
  additive `Boosts` idiom as every other standing buff in this doc rather than inventing a new
  mechanism.
- A `MirrorLookCD` Character marker (2s) debounces rapid re-clicking - independent of the
  teleport side's own `NoMirror` marker, since the two guards serve different purposes (one
  prevents click-spam on this new interaction, the other prevents repeat teleportation).

**"Scars" already existed, no new system needed**: confirmed via `CharacterHandler/init.server.luau`
(~line 2610-2615, ~2795-2801) that `PlayerData.FacialMark.Value` already holds a randomly-assigned
facial scar name (from `Assets.FacialMarkings.Scars`) for every character of most races at creation
time (a handful of races - Fischeran, Seraph, Gaian, Scroom, Vind, Phoenix - are blacklisted from
getting one) - so "having scars" for the mirror check is simply reading that existing value, not
new content.

**"self image misunderstanding" is a new injury string**, added to the existing random-injury pool
both `info.torture`/`info.torture2` already draw from (`TagHumanoid/init.server.luau` ~lines 1174
and 1195 - two separate literal arrays, not a shared list, so both needed the same edit) - the same
mechanism that already grants `brokenleg`/`brokenarm`/`heat`/`chestgash`/`Frostbite`/`blind`/`dizzy`
from a torture-flagged hit. This was the closest existing "list of grantable injuries" in the
codebase, and thematically fits (torture inflicting a psychological/body-image injury alongside the
physical ones). Like `BrokenRib`/`rib cage` elsewhere in this same system, it's a pure flag with no
dedicated visual effect in `ApplyInjuries.luau` - its only mechanical effect right now is enabling
the Mirror's Termination trigger above. Spaces inside the injury name are fine - `"rib cage"` is an
existing precedent for the same comma-separated `Injuries.Value` storage tolerating them.

**Asset debt**: none. Unlike most new content in this doc, this required no new Studio-side
placement at all - the `ClickDetector`s are code-created on existing world objects, `Termination`
reuses an existing sound, and the injury is just a new string in an existing array.

**Interpretive calls worth flagging**: exact numbers (3s knockout/death delay, 2s `MirrorLookCD`
debounce, +2/+10%/5-minute Confidence buff) are feel-based, not spec-derived, per this repo's
established practice. "Termination... make players spawn with it by default" was read as
self-targeted only (no enemy-targeting variant was built, consistent with how it's used from the
Mirror) - if a combat/offensive version was also wanted, that's a separate follow-up. The Confidence
buff's exact shape (`SpeedBoost`/`AttackSpeedBoost`, matching the existing standing-buff idiom) was
picked since no specific mechanical ask was given beyond the name.

## New stat: Attractiveness (added 2026-07-28)

`ServerScriptService/Modules/AttractivenessModule.luau` (new). Two new `PlayerData` fields:
`AttractivenessBase` (a random 10-20, rolled **once ever** - `CharacterHandler/init.server.luau`
checks `if PlayerData.AttractivenessBase.Value == 0 then` at spawn, the same "0 as an unrolled
sentinel" idiom already used for `FacialMark`'s own lazy roll-if-empty check further down that
same file) and `Attractiveness` (the current computed value, cached for display - **not** the
source of truth; `AttractivenessModule.compute(player, data)` is recomputed at every spawn and can
be called again any time a fresh read is needed, since nothing hooks recomputation into every
possible mid-life class/race-changing event). Both fields need adding to the Studio `Setup`
folder like every other new `PlayerData` default in this doc - same asset debt, same convention.

**Formula**: `AttractivenessBase * classMultiplier * raceMultiplier`, both multiplier tables
living in `AttractivenessModule.CLASS_MULTIPLIERS`/`RACE_MULTIPLIERS`, exactly the values given in
the request; anything not listed falls back to a neutral `1`. Two special cases pulled out of the
flat tables since they're conditional, not fixed per-class/race numbers:
- **SigilKnight**: `1.75`, or `1.95` if the player has `Solan's Will`
  (`data.Skills.Value:find("Solan's Will")` - the same skill flagged elsewhere in this doc as a
  Templar-only grant via the Regnier dialogue; implemented exactly as literally requested, not
  second-guessed, since whether a Sigil-classed character can also hold it is a game-design
  question outside this change's scope).
- **Morvid** (race): `0.9` if `Alignment.Value >= 0` (orderly), `1.3` if `< 0` (chaotic) - same
  orderly/chaotic threshold `Randomize/init.luau`'s own `module.Spawn` already uses.

**Madrasian's "you can shift into other races for attractiveness"**: confirmed via
`RacialAbilities/Shift/Script.server.luau` that Shift (Madrasian's racial ability) does **not**
change `PlayerData.Race.Value` - it only overwrites cosmetic appearance
(`ServerScriptService/Modules/ShiftAppearance.luau`), recording the shifted-to **player's name**
(not a race) on a `Shifted` StringValue parented to the `Player` instance itself. A Madrasian's
race multiplier therefore resolves that name back to a `PlayerData` entry and uses **that
player's** race multiplier (including their own Alignment for a Morvid target) instead of
Madrasian's own `1.2x`, falling back to `1.2x` if there's no active shift or the target can't be
resolved anymore (e.g. they've left).

**Known limitation, inherited rather than fixed**: `Shifted` is not cleared anywhere in this
codebase when a player reverts to their original appearance (`ShiftAppearance.restoreOriginal`) -
it only gets overwritten the *next* time Shift is used on a new target. This means a Madrasian who
shifted once and later reverted may still read as "currently shifted" here, using the stale
target's race multiplier instead of falling back to Madrasian's own `1.2x`, until they shift again.
Fixing this would mean adding new state-clearing to the Shift ability itself, which felt like scope
creep for a stat-formula request - flagged here rather than silently worked around.

**Corrected mid-session**: the first pass read "Druid"/"Bard"/"Blacksmith" from the request as
literal `ClassData.luau` keys - `Druid` isn't a real class at all (already flagged elsewhere in
this doc, `ClassDataDriftCheck.luau`'s section, as "a stale 'Druid' entry that was never a real
class"), and `Bard`/base `Blacksmith` have no `class` field in `ClassData.luau` at all, so
`teachskill` (`if info.class then ... data.Class.Value = info.class ... end`,
`DialogueHandler/ModuleScript.luau` ~line 133) never actually writes those strings to
`PlayerData.Class.Value` - those three entries would have been permanently unreachable. The user
clarified these were flavor names for this codebase's real classes: **Florist** (the Botanist
line's ultra tier) for "Druid," **Candence** (an existing ultra class - `Joyous Dance`/`Song of
Lethargy`/`Sweet Soothing`, genuinely bard-flavored) for "Bard," and **Lapidarist**
(`SuperBlacksmith`'s ultra tier) for "Blacksmith." `CLASS_MULTIPLIERS` now uses these three real
keys instead, all correctly reachable through normal play.

**Abysswalker's "dependent on race and height, base stat is 1x"**: only the "base stat is 1x" and
"race" halves are implemented - `Abysswalker`'s own class multiplier is a flat `1`, and the normal
race multiplier still applies on top via the usual formula. The "height" half cannot be built yet -
no height/scale stat is tracked anywhere in this codebase today (the closest existing concept,
"frame," is explicitly reserved for a future "heightmogging" update per the workout system's
Shoulders/Back notes elsewhere in this doc, and still has no mechanical implementation). Revisit
once that system exists.

**Interpretive calls worth flagging**: "Sigil"/"DSK"/"Necro"/"Dragon Slayer"/"Deep Knight" were
mapped to their real `ClassData.luau` key spellings (`SigilKnight`, `DarkSigilKnight`,
`Necromancer`, `DragonSlayer`, `DeepKnight`) rather than used as literal string keys, since those
shorthand forms don't match anything `Class.Value` would ever actually hold. Only the exact classes
named in the request got entries - prerequisite/ultra tiers not explicitly named (e.g.
`DragonKnight`, `Master Necromancer`, `Master Illusionist`, `Whisper`, `SigilKnightCommander`) fall
back to the neutral `1x` default rather than inheriting their line's other tier's multiplier, which
reads as intentional given the request specifically picked certain tiers over others (e.g.
`DragonSlayer` the ultra, not `DragonKnight` the base). Every numeric value is exactly what was
given in the request, not independently chosen.

## New: Mogging, Rage/Squeamish, and 3 eating injuries (added 2026-07-28)

A full "mogging" social-combat loop built on the Attractiveness stat above: a `Mogging` Tool every
player spawns with, two new debuff injuries it (and low Attractiveness itself) can inflict, three
new food-related injuries only reachable through mogging, and a global NPC-dialogue gate that
ignores unattractive players.

**Locked in via user confirmation before building**: this codebase has no QTE (quick-time event)
system anywhere - the "mogging battle" for comparable-Attractiveness players is a **weighted
instant resolution**, not a real interactive minigame (which would need a new client GUI, a
RemoteEvent round-trip, a timing window, and its own exploit surface - a separate undertaking).
Squeamish's "unable to run and mana climb" was read as **three separate lockouts** - Sprint,
spellcasting (mana), and climbing - not one combined mechanic.

### New shared modules

**`ServerScriptService/Modules/FoodModule.luau`** - centralizes eating for `Turnip`/`Meat`
(`module.eat(character, data, itemName, hungerAmount)`, now called from both items' scripts in
place of their own inline `Stomach.Value` math): blocks eating entirely if `AnythingEater` is
present (food is the one thing an AnythingEater *can't* eat - plays the same `Handle.Cough` cue
both items already use for other blocked races/conditions), enforces `LackEater`'s daily caps (3
Turnip / 1 Meat - two new `PlayerData` NumberValues, `TurnipsEatenToday`/`MeatEatenToday`, reset
alongside the existing `CameoCD` reset at `Health.server.luau`'s day-rollover check rather than
building new day-tracking from scratch), and - if `VomitForcer` is present - schedules a
`task.delay(120, ...)` that applies a 2s Stun and zeroes `Stomach.Value` ("vomit everything out").
`module.eatAnything(player, character, data, itemName)` is the `AnythingEater` path: consumes a
non-food Backpack Tool for a flat `+10` hunger ("way less than normal food"), triggered by a new
`eat <item>` chat command in `CharacterHandler/init.server.luau` (mirroring the existing
`meditate` chat-command parsing already in that file, `table.concat`-ing everything after `"eat"`
so multi-word item names like "Health Potion" still work) rather than retrofitting all ~239
`Storage` items individually.

**Incidental fix while centralizing**: `Meat/Script.server.luau`'s own `Stomach.Value` clamp was
commented out (`--//local stomach = math.clamp(...)`, an unclamped `+= 50` in its place) - routing
through `FoodModule.eat` (which always clamps, matching `Turnip`'s own behavior) fixes this as a
side effect, not a separately-requested change.

**`ServerScriptService/Modules/MoggingModule.luau`** - the shared mog-consequence logic, called by
both the `Mogging` Tool and `AttractivenessModule.compute`'s own low-Attractiveness self-trigger
(one implementation, not two copies):
- `applyMogDebuffs(character, data)`: three **independent** rolls - 10% one of the 3 new eating
  injuries (`VomitForcer`/`LackEater`/`AnythingEater`, picked among whichever aren't already
  owned), 30% `Squeamish`, 40% `Rage` - read literally as three separate chances per the request's
  phrasing, not a mutually-exclusive 100%-summing pick, so 0-3 can land from one mog. Each lasts
  900 real seconds (one in-game day, matching `Health.server.luau`'s own day length - no existing
  "debuff for N in-game days" precedent was found anywhere in this codebase, confirmed by research,
  so this is a flat real-time Debris/task.delay window rather than tracking actual day-boundaries).
  `Rage`/`Squeamish` each separately roll a further 15% chance to immediately call
  `TerminationModule.trigger` when granted ("may auto trigger termination").
- `resolve(casterCharacter, casterData, casterAttr, targetCharacter, targetData, targetAttr)`: the
  `Mogging` Tool's actual branch logic (numbers below).
- **Rage/Squeamish are real `PlayerData.Injuries.Value` entries** (consistent with the request's
  own "injuries" framing, and matching how last session's Mirror "any injury" check already reads
  `Injuries.Value ~= ""` generically) **but are also mirrored as a Character-parented Accessory
  marker** with the same lifetime - a technical necessity, not redundancy: the two client-side
  consumers (`Sprint()`/`ClimbFunc()` in `CharacterHandler/Input/init.client.luau`) run on the
  client and can never read `game.ServerStorage.PlayerData` at all (`ServerStorage` never
  replicates to clients), so only a replicated Character Instance is visible to them. Both the
  string entry and the marker are granted and expired together
  (`task.delay`/`game.Debris:AddItem`, respectively).

### `ServerStorage/Classes/Mogging/` (new Tool, granted at spawn like `Termination`)

20s cooldown. Targets by mouse-aim, reusing the exact "find the player my mouse is over"
resolution already solved in `RacialAbilities/Shift/Script.server.luau`
(`_G.MouseData(Player)` + `HumanoidRootPart` + `PlayerData` validation) rather than inventing new
targeting - Mogging reads as a targeted social interaction, not an AOE attack. On a valid target
within 20 studs, both sides' Attractiveness is computed fresh
(`AttractivenessModule.compute` - so a live Madrasian shift/Sigil Solans-Will bonus/current
Morvid Alignment is reflected, not a possibly-stale cached value) and `diff = casterAttr -
targetAttr`:
- `diff >= 8`: caster clearly wins - `applyMogDebuffs` on the **target**.
- `diff <= -8`: the target actually outclasses the caster - **not explicitly described in the
  request** (which only covers "clearly ahead" and "comparable"), but leaving this direction a
  no-op would make mogging someone more attractive than you risk-free, which read as an
  unintended gap rather than an intended asymmetry - `applyMogDebuffs` is applied to the
  **caster** instead, symmetrically. Flagged as an interpretive completion.
- Otherwise (`|diff| < 8`, "within your range"): the weighted "QTE" - `P(caster wins) =
  clamp(0.5 + diff * 0.03, 0.1, 0.9)` - loser gets `applyMogDebuffs`, winner takes nothing (the
  "boost" is the tilted win probability itself, not a separate reward). No dedicated clash
  sound/VFX exists (asset debt) - none is played rather than reusing something that wouldn't fit
  a winning outcome.

### Rage - `TagHumanoid/init.server.luau` and `m1.luau`

- **Less damage dealt**: `info.damage *= 0.8`, checked on the *attacker's* own `Injuries.Value`
  (`playerdata`, not `enemydata`) right next to the existing `chestgash` damage-taken modifier -
  the first injury-driven modifier in this file to affect outgoing rather than incoming damage.
- **Longer cooldowns - partial, flagged as such**: confirmed via research that no
  global-cooldown-multiplier mechanism exists anywhere to hook into, and editing all ~130
  individual move Tool cooldowns individually was judged out of scope for this request. Only
  unarmed M1 is centrally reachable (the same `attackspeed` local already touched for Core
  hypertrophy) - Rage multiplies it `* 1.3` (slower). Per-move Tool cooldowns are untouched.

### Squeamish - three lockouts plus one NPC block

- **Sprint**: `CharacterHandler/Input/init.client.luau`'s `Sprint(Value)` function, right next to
  its existing `LegBroken` early-return.
- **Mana (spellcasting)**: `SpellModule.luau` - both `module.cast` and `module.castnew` (the
  `Rework`-tagged-tool path with no mana-window check, per earlier session notes) now return
  `nil` if `Squeamish` is present, next to the existing `SpellBlocking`/`CurseBlocking` check.
- **Climbing**: `ClimbFunc(p10)` in the same `Input/init.client.luau`, next to its existing
  `SpellBlocking` early-exit.
- **NPC interaction**: `DialogueHandler/init.server.luau` - both dialogue-start entry points
  (`npcclick`, the `ClickDetector`-driven path, and the `DialogueCreate` bindable event a few
  lines below it - confirmed both are near-identical guard chains for starting a conversation)
  now return early if `Squeamish` is present, same as the Attractiveness gate below.
- **May auto trigger Termination**: handled in `MoggingModule.applyMogDebuffs` (15% chance),
  shared with Rage.

### NPCs ignore low-Attractiveness players

Same two `DialogueHandler/init.server.luau` entry points as Squeamish's NPC block: if
`AttractivenessModule.compute(...)` is below `30` (the requested 25-35 range's midpoint), the NPC
simply never responds - no dialogue opens, no rejection message (nothing beyond "npcs don't talk
to you" was asked for). Gated once at the shared choke point rather than per-NPC, so it applies
universally with no other file needing to change.

**Follow-up (still 2026-07-28): only applies once the player has achieved an ultra class.** Both
gate locations now additionally require `data.IsUltra.Value == true` (the same flag `teachskill`
already sets the first time any ultra class is learned, `ModuleScript.luau:142`, and the same
check other ultra-gated logic in this file already uses verbatim, e.g. `ModuleScript.luau:14655`)
before the low-Attractiveness check even runs. An ugly player who hasn't reached an ultra class
yet is completely unaffected - NPCs talk to them normally regardless of Attractiveness.

### Interpretive calls worth flagging

All exact numbers (the 8-point mogging threshold, 0.03 QTE scale, 20-stud range/20s cooldown, the
10%/30%/40% debuff rolls, 15% auto-Termination chance, 900s duration, 0.8x Rage damage/1.3x Rage
M1 slowdown, the 12-point low-Attractiveness threshold and its 300s recheck debounce, the 30-point
NPC-ignore threshold, `+10` AnythingEater hunger) are feel-based, not spec-derived, per this
repo's established practice. The reversed "target outclasses caster" branch, treating all three
independent debuff rolls as expiring together after one in-game day (rather than the 3 eating
injuries being permanent), and Rage's cooldown effect being partial (M1 only) rather than global
were the three biggest interpretive completions - all flagged inline above where they're
implemented, not silently assumed.

**Follow-up (2026-07-29): the 5 mog-related injuries now play the standard injure sound/particle.**
`MoggingModule.luau`'s shared `grantTimedInjury(character, data, name, duration)` helper (used by
all 5 - `VomitForcer`/`LackEater`/`AnythingEater`/`Rage`/`Squeamish`) previously only edited
`Injuries.Value` and dropped the Character marker - no feedback at all, unlike a normal injury.
Now plays `HumanoidRootPart.Injury` and clones/emits `ReplicatedStorage.Assets.Injure`, the same
two effects `RequestHandler.server.luau`'s real `Injure()` function plays, so getting one of these
via a mog reads identically to any other injury. **Also mirrors `Injure()`'s own dedup guard**
(`if Data.Injuries.Value:match(Injury) then return end`) via a new `isNew` check - the sound/
particle (and the `Injuries.Value` CSV append) only fire the first time an injury is actually
granted, not on every refresh/re-trigger while already owned (e.g. getting mogged into Squeamish
again while already Squeamish just extends the duration silently, same as a normal injury would).

**Follow-up (2026-07-29): "AnythingEater injury doesn't work" - two real bugs fixed in
`FoodModule.eatAnything`, plus scope widened per direct request.**

1. **Case-sensitive item lookup was the main reported failure** ("you can't eat various trinkets
   such as goblets and amulets"): `player.Backpack:FindFirstChild(itemName)` required an exact-case
   match against the Tool's real name - a player typing the natural lowercase `"eat goblet"`/
   `"eat amulet"` (real `ServerStorage/Storage` items, confirmed via `TrinketsHandler.server.luau`'s
   own loot tables) against Tools actually named `"Goblet"`/`"Amulet"` would silently fail to match
   at all. Fixed by scanning `Character`/`Backpack` children directly and matching
   `child.Name:lower() == itemName:lower()`, then using the resolved item's own real `.Name`
   (correct casing) for every subsequent check and for `RemoveFromInventory`.
2. **"You cannot eat food" wasn't actually true for everything called food.** `eatAnything` only
   ever excluded `"Turnip"`/`"Meat"` by exact name - `Pizza`/`Pork Bun` (which never went through
   `FoodModule.eat` at all - see below) and the whole Meat-quality-tier family/4 crafted
   Cooked-mushroom foods weren't blocked. Replaced with a full `FOOD_ITEMS` table (Turnip, Meat and
   every quality/poison tier of it, Vint, Pizza, Pork Bun, the 4 Cooked-mushroom foods) checked
   against the resolved item's real name.

**Scope widened, per "all non food/non potion items should be eatable which includes artifacts"**:
added a `POTION_ITEMS` table (the 13 real potions/brews under `ServerStorage/Alchemy/Tools`,
confirmed by listing that directory - `Bone Grow`, `Creatine`, `Feather Feet`, `Fire Protection`,
`Health Potion`, `Ice Protection`, `Kingsbane`, `Liquid Wisdom`, `Lordsbane`, `Preworkout`,
`Silver Sun`, `Switch Witch`, `Tespian Elixir`) excluded the same way as food - everything else
(ores, gems, cures, poisons, candy, scrolls, misc items, trinkets, and now artifacts) is eatable.

**Artifacts get a special rule** ("You only eat them if you already have an artifact and have the
injury, otherwise it will give the player the artifact alert"): a new `ARTIFACT_ITEMS` table (the
same 13 artifacts enumerated in the Alert-popups section above) is checked before consuming - if
the player does NOT already hold an artifact (`data.Artifact.Value` is `"None"`/`""`), the item is
too valuable to trivially convert into +10 hunger, so the eat is blocked and
`AlertModule.send(player, "This is a real artifact - use it properly instead of eating it.")` fires
instead (no consumption, item stays in inventory). If the player already holds a different
artifact - meaning a second one is genuinely dead weight, since only one can ever be active - it's
eaten normally like any other item. **Interpretive call flagged**: the exact alert wording (reusing
the artifact-alert *mechanism*, not literally the pre-existing "You already have an artifact..."
text, which wouldn't make sense for a player who has none) was written fresh for this context since
no exact string was specified - flag if different wording was intended.

**Also fixed while here**: `Pizza`/`Pork Bun` (`ServerStorage/Storage/Pizza|Pork Bun/Script.server.luau`)
previously did their own inline `Stomach.Value += 50` with no `FoodModule.eat` call at all - unlike
Turnip/Meat, an AnythingEater player could still eat them normally. Both now route through
`FoodModule.eat` the same way Turnip already does (check first, play `Handle.Cough` and return on
block), so "you cannot eat food" is now actually enforced for every real food item, not just two
of them.

## New NPC: Therapist (added 2026-07-28)

Heals all 5 injuries added alongside Mogging (`VomitForcer`/`LackEater`/`AnythingEater`/`Rage`/
`Squeamish`) in one visit - 90% chance of working, a 1-in-game-day cooldown that applies either
way (a therapy session took place whether or not it helped). `dialogues.Therapist.v1` and its
content table both live in `DialogueHandler/ModuleScript.luau`, right after `Xenyari`'s gacha
dialogue and `Corvax`'s ascension-trial dialogue respectively, which supplied the two conventions
this reuses directly:

- **The cooldown is the same `LastX ~= DaysSurvived.Value` snapshot idiom `Xenyari`'s once-per-day
  gacha roll already uses** (`ModuleScript.luau` ~line 12017/12023), not a new real-time timer -
  `page == 1` shows the offer or an `onCooldown` rejection depending on whether
  `data.LastTherapist.Value == data.DaysSurvived.Value`; `page == 2` (reached only via the single
  "Help me." choice, same "no `v.choice` check needed, reaching this page already means they
  chose it" shape `Xenyari`'s own page 2 uses) sets the cooldown snapshot **before** rolling
  success/failure, then does a `string.split`/`table.find`/rejoin over `Injuries.Value` to strip
  out any of the 5 healable names the player currently has (silently a no-op for whichever they
  don't).
- **No new driver wiring needed**: both dialogue-start entry points already dispatch to any NPC
  name present in the `dialogues` table generically (`v1[v.Name]`/`v1[v]`, confirmed while adding
  the Attractiveness NPC-gate above) - the same pattern already true for every other NPC added
  this session (Corvax/Doyen/Zephyra) - so adding the content table and function here is a complete,
  working addition.
- **Emergent interaction, not separately built**: the low-Attractiveness NPC-ignore gate added
  alongside Squeamish above already applies universally to both entry points, so a player too
  unattractive to be worth talking to also can't be helped by the Therapist - an intentional-
  feeling irony that falls out of the existing gate for free, not new code.

**Asset debt**: `Therapist` is a brand-new NPC with no placed instance yet (same caveat as every
other new NPC this session - Corvax/Doyen/Zephyra - needs an actual NPC placed in Studio with the
usual click-trigger/dialogue-hookup before reachable in-game). One new `PlayerData` field,
`LastTherapist` (NumberValue), needs adding to the Studio `Setup` folder - **must default to `-1`,
not `0`**: `DaysSurvived` itself starts at `0` for a new character, so a `0` default here would
make `LastTherapist.Value == DaysSurvived.Value` true immediately, putting every brand-new
character on cooldown before their first-ever visit - the same pitfall `Xenyari`'s `LastGacha`
presumably already avoids (not independently confirmed, since its own default lives in the same
un-inspectable Studio `Setup` folder, but `-1` is the safe choice regardless of what it uses).

**Interpretive calls worth flagging**: the exact 90% success rate and the flavor dialogue text are
not spec-derived. Read "all of the new injuries can be healed" as one visit clearing all 5 at once
(whichever the player currently has) rather than a per-injury selection menu, since nothing in the
request suggested choosing one at a time.

**Follow-up (still 2026-07-28): the 5 new injuries are Therapist-exclusive.** A pre-existing
`Doctor` NPC (`dialogues.Doctor.v1`, `ModuleScript.luau` ~line 13665) already does a blanket
injury cure for 15 Money - `data.Injuries.Value = ""` then restores only whatever's in a
hardcoded `Unfixable` list (previously `{"MetalArm","vampirism","armless"}`), i.e. it would have
healed all 5 new injuries too, for free, completely bypassing Therapist's 90% chance and 1-day
cooldown. Added `VomitForcer`/`LackEater`/`AnythingEater`/`Rage`/`Squeamish` to that same
`Unfixable` list (~line 13702) so the Doctor's cure now preserves them exactly like it already
preserves `MetalArm`/`vampirism`/`armless` - the smallest possible change, reusing an existing
exclusion list rather than adding new branching logic.

## New: SolanBall "ugly" branch, Squeamish exemption, and per-character height (added 2026-07-28)

**SolanBall already had the exact permadeath-adjacent mechanics this needed** -
`dialogues.SolanBall.v1` (`ModuleScript.luau` ~13943) is the "Voice of Solan" NPC: when a player
still has lives, its `else` branch shows `haslife` (`"So... you've finally seen me"`, choice
`"I'm lost"`, which just respawns/teleports them) - this is the branch that got the new
Attractiveness-gated content, since the other branches (out-of-lives "I need another chance"/"I
give up", `LostWar`, King-title `cameop1`/`cameop2`) are unrelated existing flows.

- **Attractiveness `<= 30`**: normally shows a new `uglyhaslife` entry (the requested disgusted
  line) with the **same** `{"I'm lost"}` choice as normal `haslife` - the "I'm lost" handling
  itself (the `else` branch a few lines down) didn't need any change, since it only ever checks
  `v.choice`, and the choice text is identical either way.
- **10% instead**: wipes the character via the exact same sequence every other terminal SolanBall
  branch already uses (`data.Wiped.Value = true`, `CheckEdictObtainment(p)`,
  `task.spawn(function() task.wait(3); p.Character:Destroy(); .../CharacterCreationGui:Clone() end)`)
  and returns a new `uglywiped` entry (the requested "yelled out No, no, no..." line, `endchoice`
  only - no choices, matching the shape of every other terminal message like `theend`/`forgiven`).
  The roll happens once per dialogue-open (`v.page == 1`, checked exactly once before any choice
  is made - confirmed `talking[Character].page` only increments in the generic choice-submission
  handler, `DialogueHandler/init.server.luau:164`, not per-NPC), not once per message render.

**Squeamish's NPC-block now exempts SolanBall** (both `npcclick` and the `DialogueCreate` bindable
path in `DialogueHandler/init.server.luau`, `p2:FindFirstChild("Squeamish") and v.Name/v ~=
"SolanBall"`) - it's the only way to give up a life or come back to life, so Squeamish locking a
player out of it entirely would strand them. **The low-Attractiveness NPC-ignore gate from
earlier in this doc needed the same exemption, spotted while making this change**: that gate
(`< 30`) would otherwise have silently made the brand-new "ugly" SolanBall content unreachable for
its own target audience (an Attractiveness-`<=30` player would get filtered out before ever
reaching SolanBall's dialogue) - not something the user asked to fix directly, but a direct
consequence of this change that would have quietly broken it, so both gate locations exempt
SolanBall the same way.

### Per-character height roll

Every new character now rolls a persistent `PlayerData.HeightMultiplier` (`0.8` to `1.1`,
`CharacterCreationGui/Script.server.luau`, right before `GotData:Set(gettable)`), applied via the
existing `CharacterScale.scaleR6` at spawn (`CharacterHandler/init.server.luau`, right before the
existing Black Pill block). **Not rerolled if this character was created within 2 minutes of the
player's last one** - a new `PlayerData.LastCharacterCreated` (`os.time()` snapshot, same
real-world-elapsed-time idiom `GlobalRestoreCD` already uses elsewhere in `CharacterHandler`)
gates whether `HeightMultiplier` carries over from the just-replaced character's `PlayerData` or
gets rerolled - covers both a SolanBall wipe (creation happens almost immediately after) and an
ordinary misclicked/redone character creation, without needing to distinguish the two.

**Black Pill is now a multiplier on top of the rolled height, not a flat override**: its own
`scaleR6(Character, 1.2)` calls (both the Tool's pickup-moment application and
`CharacterHandler`'s spawn-time re-application) are unchanged in value, but `scaleR6` always
multiplies whatever the character's *current* size already is - since the height roll above is
now applied first, both call sites compose correctly (`final = base * HeightMultiplier * 1.2`)
without any change needed to the Black Pill Tool script itself, which already only ever runs on
the live, already-height-scaled character. (The request said "instead of 1.25x" - this codebase's
actual Black Pill value has always been `1.2`, not `1.25`; the composition behavior described is
what changed, not the multiplier's own number, so it was left at `1.2`.)

**Asset debt**: none - `HeightMultiplier`/`LastCharacterCreated` are two more `PlayerData` fields
needing the usual Studio `Setup`-folder addition (`HeightMultiplier` should default to `1`,
`LastCharacterCreated` to `0` so a player's very first character creation doesn't wrongly treat a
`0` timestamp as "just now" and skip its own height roll).

**Interpretive calls worth flagging**: the 10%/`<=30` numbers and the height range (`0.8`-`1.1`)
are exactly what was given, not independently chosen. The 2-minute reuse window is checked via
`os.time()` (wall-clock, survives a rejoin) rather than `os.clock()` (session-local monotonic,
used elsewhere for things like `LastMeditate` that don't need to survive a disconnect) - picked
to match `GlobalRestoreCD`'s own precedent for a real-world-elapsed cooldown, not `LastMeditate`'s.

## New: Attractiveness shown in the CurrencyGui HUD (added 2026-07-28)

Wired up the existing `PlayerGui > CurrencyGui > Attractiveness > Value` TextLabel (UI already
built by the user - only the update logic was missing) by following the exact convention Money/
Insight already use in the same `CurrencyGui/CurrencyClient.client.luau`:

- **Initial value**: `Requests.Get:InvokeServer({"Attractiveness"}).Attractiveness` - required
  adding `"Attractiveness"` to the hardcoded `TargetValues` list in
  `RequestHandler.server.luau`'s `Requests.Get.OnServerInvoke` (~line 281), which Money/Insight/
  etc. all already go through; the invoke argument itself is actually ignored server-side (the
  handler always returns every field in that fixed list regardless of what's requested), so this
  was the one required change to make the field fetchable at all.
- **Live updates**: a new `Requests.AttractivenessChanged:FireClient(player, result)`, added
  **inside `AttractivenessModule.compute` itself** rather than at each of its call sites - every
  consumer of `compute()` (spawn, the Mogging Tool, the low-Attractiveness self-trigger, both NPC
  dialogue gates, SolanBall) already keeps the HUD live for free as a result, with no other file
  needing to change.
- **Display-only rounding**: `math.floor(Number)` is applied client-side when setting `.Text`,
  not to the stored value - `PlayerData.Attractiveness.Value` stays unrounded, since Mogging's
  8-point diff threshold and both NPC gates' `< 30` checks compare against the exact computed
  float, not a display-rounded one.

**Asset debt**: a new RemoteEvent, `ReplicatedStorage.Requests.AttractivenessChanged`, needs
creating in Studio (same folder as the pre-existing `MoneyChanged`/`InsightChanged` - confirmed
`ReplicatedStorage/Requests` isn't tracked in `src/` at all, same Studio-only-instance situation as
every other Requests RemoteEvent/RemoteFunction in this doc) - the HUD won't update live until
that's added, though the initial `Requests.Get` value will still populate correctly without it.

## New: per-UserId height special-case (added 2026-07-28)

UserId `2231268759` always spawns shorter than the normal height system's floor, and can never
exceed that floor even with Black Pill's own multiplier stacked on top - a hardcoded per-UserId
override, same convention already established in this file for other one-off UserId cases (the
Playful-Stone-effect grant and the "Playful Guy" `FirstName` override, both in
`CharacterCreationGui/Script.server.luau`).

- **The roll** (`CharacterCreationGui/Script.server.luau`, in the same `HeightMultiplier`
  branch the general 0.8-1.1 roll lives in): for this UserId only, `HeightMultiplier` rolls
  `0.5` to `0.79` instead - a sub-floor range, still randomized ("on a range," per the request),
  just shifted entirely below where every other player's roll bottoms out.
- **The hard cap** (`CharacterHandler/init.server.luau`, where height is actually applied at
  spawn): since Black Pill composes multiplicatively with `HeightMultiplier`
  (`final = HeightMultiplier * 1.2` when owned, per the height system's own section above), a
  roll close to `0.79` combined with Black Pill could otherwise land above `0.8` - defeating
  "cannot get a height above shortest possible." For this UserId specifically, the two multiplies
  are collapsed into one `math.min(HeightMultiplier * (hasBlackPill and 1.2 or 1), 0.8)` call
  instead of the normal two-step (roll, then separately stack Black Pill on top) - a real
  behavioral difference from every other player, not just a bigger `HeightMultiplier` number,
  since only this player's total is clamped regardless of what multiplies into it. Black Pill's
  other effects (the head-mesh face stretch, the `Artifacts` marker) are untouched by this - only
  the body-scale portion is capped.

**Interpretive calls worth flagging**: the exact sub-floor range (`0.5`-`0.79`) is feel-based, not
spec-derived - the request only established the floor it must stay under (`0.8`) and that it
should still vary "on a range," not a specific lower bound.

## Fixed: existing characters spawning invisible (2026-07-28)

Root cause: several new `PlayerData` fields added earlier this session (`HeightMultiplier` above
being the sharpest case) were read with direct, unguarded `.Value` access at spawn. Once the user
added `HeightMultiplier` to the Studio `Setup` folder, it defaulted to `0` (Roblox's default for a
freshly-placed `NumberValue`, not `1`) for every existing character - and
`CharacterScale.scaleR6(Character, 0)` scales every body part to zero size, which is invisible
with **no error at all**, since it's a mathematically valid (if degenerate) operation, not a
script fault. This is a materially different failure mode from a missing-field error and took a
second report to fully track down.

**The fix, `CharacterHandler/init.server.luau`**: `heightMultiplier` now has two layers of
protection instead of one - (1) a reroll-if-`<=0` check (upgraded from the original `== 0` check
to also catch negatives) that lazy-rolls a proper value the same way `AttractivenessBase` already
does, **and** (2) an unconditional final floor (`if heightMultiplier <= 0 then heightMultiplier = 1
end`) positioned immediately before either `scaleR6` call, independent of whether the reroll above
actually ran. The second layer exists because the reroll alone didn't resolve the user's repro -
the exact mechanism was never fully confirmed (a plausible theory: whatever merges the Studio
`Setup` folder's fields into a *returning* player's already-saved `PlayerData` may run at a
different point in the load sequence than this script's own check, so the Instance could still
read `0` here despite the reroll) - rather than chase that ordering issue further, the final floor
makes it structurally impossible for a zero-or-negative factor to ever reach `scaleR6` from this
script, regardless of root cause or timing.

**Also fixed while investigating**: `AttractivenessModule.compute`'s low-Attractiveness
self-trigger (grants Rage/Squeamish, chance of `TerminationModule.trigger`) was still able to fire
off the module's own `AttractivenessBase`-missing fallback (a guessed neutral `15`) - for
low-race-multiplier races (Scroom `0.1x`, Navaran `0.3x`) that guess could still land under the
threshold, repeatedly Knocking/killing those characters on made-up data every spawn. Now gated on
`baseField` actually existing (a real roll), not just the computed result - see that section above.

**Lesson for future sessions**: a defaulted-but-technically-present Studio value (`0` for a
`NumberValue`, `""` for a `StringValue`, etc.) is a *silent* failure mode, categorically different
from and easier to miss than a missing-Instance error - `FindFirstChild` guards catch the latter
but not the former. Any new field this codebase multiplies, divides, or otherwise uses as a scale
factor should get an explicit sanity floor/ceiling wherever it's actually consumed, not just an
existence check, especially anywhere it feeds a visual/physical effect that fails silently (size,
transparency, position) rather than throwing.

## Fixed: bigger characters' hair/accessories scaling smaller than they should (2026-07-28)

A second, unrelated bug in the same height system: `scaleR6` only scales whatever `Accessory`
instances are already parented to the character *at the moment it's called*. Race-specific hair
attaches asynchronously - `Commands.UpdateAppearance` (`Modules/Commands/init.luau` ~line 149)
does the actual `Hairs`/`Accessories` cloning-and-parenting inside its own `task.spawn`, and is
itself called from `GameLoaded/init.server.luau` - a **completely separate script** from
`CharacterHandler/init.server.luau` (where height is applied) with no execution-order guarantee
between the two. When hair attaches after `scaleR6` already ran, it's simply never touched -
staying at its original, unscaled size while the body is already bigger, which reads as "hair
too small," and gets more visually obvious the bigger the character rolled (matching exactly what
was reported).

**The fix**: `CharacterScale.luau` gained `module.watchForLateAccessories(character, factor)` - a
`character.ChildAdded` connection that applies the same per-accessory scaling `scaleR6` already
does (factored out into a shared local `scaleAccessory`) to any `Accessory` that shows up *after*
the initial call, using whatever total factor was already applied to the body. Left connected for
the character's whole life rather than disconnected after a short window, since re-deriving "how
long could the async hair-load possibly take" is more fragile than just handling every future
Accessory addition the same way - it only ever touches real cosmetic Accessories with a `Handle`
child, so it can't misfire on the many state-flag Accessory objects this codebase uses as markers
(`Stun`, `Knocked`, etc. never have a `Handle`).

**Also simplified while fixing this**: `CharacterHandler/init.server.luau` previously called
`scaleR6` twice (once for `HeightMultiplier`, once more for Black Pill's `1.2x`) relying on the two
calls composing multiplicatively. Collapsed into a single `totalScaleFactor` computed once and
applied in one `scaleR6` call - mathematically identical (multiplication is associative) but
required for `watchForLateAccessories` to have one number to hand late-arriving accessories rather
than needing to track a running product across multiple calls. The UserId `2231268759` height cap
logic is otherwise unchanged, just expressed as one `totalScaleFactor` branch instead of two
sequential calls.

## Fixed: achieving an ultra class could DECREASE Attractiveness, softlocking players out of NPCs (2026-07-28)

Root cause: five of `AttractivenessModule.CLASS_MULTIPLIERS`' entries were keyed to the wrong
tier. `ClassData.luau` splits classes into a `supers` tier and an `ultraclass3` tier - the
original Attractiveness request named classes like "Illusionist"/"Necro"/"Spy"/"Samurai"/"Sigil"
informally, and those strings happen to be the literal `Class.Value` for the **super** tier
(`Illusionist`, `Necromancer`, `Spy`, `Samurai`, `SigilKnight`), not the **ultra** tier the
request actually meant. Since the super tier then held the requested multiplier while the real
ultra classes (`Master Illusionist`, `Master Necromancer`, `Whisper`/`Wanderer`,
`SigilKnightCommander`) weren't in the table at all and fell back to the neutral `1x` default,
**a player who ground all the way to their real ultra class would see their computed
Attractiveness drop** the moment `Class.Value` updated (e.g. Samurai `1.2x` → Ronin `1x` on
promotion) - confirmed as the direct cause of the reported softlock, since the NPC-ignore gate
added earlier this session (`< 30`, gated on `data.IsUltra.Value == true`) fires *right as* a
player reaches ultra status, with no way to raise Attractiveness back up afterward.

**Fix**: moved the five affected entries to their real ultra-tier keys - `Master Illusionist`,
`Master Necromancer`, `Whisper`, `SigilKnightCommander` - each keeping the exact multiplier the
request gave for that class line. Also added `Wanderer` (`= 1.2`), Spy's *other* ultra branch
(the request only gave one number for "Spy," not knowing it splits into two ultra tiers) - without
this, a player who chose Wanderer over Whisper would hit the identical bug. The `SigilKnight`
Solan's-Will special case in `getClassMultiplier` was moved to check `SigilKnightCommander`
instead, since that's the actual ultra tier "Sigil" always meant. `DarkSigilKnight`/`Florist`/
`Candence`/`Lapidarist`/`DragonSage`/`Oni`/`Faceless`/`Shinobi`/`DragonSlayer`/`DeepKnight` were
already correctly keyed to their ultra tier from the start and needed no change.

**One case deliberately left alone**: "Illusionist" was explicitly given `0.8` (below neutral) in
the original request. `Master Illusionist` now correctly holds that `0.8`, meaning promoting from
the super tier (unlisted, neutral `1x`) to the ultra *still* reads as a decrease - but this is the
literal number the user gave, not an accidental side effect of a wrong key like the other four
were, so it wasn't changed. A Master Illusionist whose combined stats land under the NPC-gate
threshold can still hit the same softlock shape - just as a deliberate consequence of that class's
own requested multiplier, not a calculation bug.

**Not otherwise investigated/changed**: a background research pass (prompted while chasing this)
also surfaced a smaller, pre-existing decrease for `SigilKnight` players with `Solan's Will`
promoting specifically to `DarkSigilKnight` (`1.95x` → `1.75x`, since the Solan's-Will bonus is
tied only to the "Sigil"/`SigilKnightCommander` branch, exactly as originally requested) - this is
the two-ultra-branches-from-one-prerequisite shape working as designed, not a bug, so left as-is.
Building a general "walk the whole `requiredclass` chain and take the max multiplier ever
achieved" fix (which would also future-proof against any *other* class ClassData.luau ever adds)
was considered but not implemented - `ClassData.luau` has real edge cases that would need careful
handling first (a self-referential `requiredclass` on `Templar`, an `EnibrasTeaching` entry whose
outer key doesn't match its own `.class` field, `Warrior` having no `.class` field at all) - the
direct fix above resolves every concretely-reported case without that added complexity/risk.

## New system: Alert popups (added 2026-07-29)

A generic top-of-screen toast/alert system for silently-failing player actions - the motivating
example was every artifact `Storage` Tool's own-artifact-conflict guard (`if data.Artifact.Value
~= "None" and ... then return end`), which previously just did nothing with no feedback at all
when a player tried to use a second artifact while already holding one.

**`ServerScriptService/Modules/AlertModule.luau`** (new) - the entire server-side surface is one
function, `module.send(player, text, duration)`, which fires a new `ReplicatedStorage.Requests.Alert`
RemoteEvent at that player. `duration` is optional (client falls back to a default); this mirrors
the existing `Requests.ClientMessage`/`Notify(messg, tim)` remote's own optional-duration shape
(`StarterGui/GlobalMessage/LocalScript.client.luau`) rather than inventing a new convention, though
Alert is a deliberately separate remote/GUI from that older bottom-right "Message" system - Alert is
top-center, stacks downward, and is styled distinctly (dark card, amber outline) to read as a
"heads up, that didn't work" notice rather than a combat/kill-feed style message.

**`StarterGui/AlertGui/`** (new ScreenGui + LocalScript, `DisplayOrder = 50`) - unlike most GUI in
this repo, this needed **no Studio-side placement at all**: every visual element (the container,
each alert card, its `UICorner`/`UIStroke`/`UIPadding`, the `TextLabel`) is created with
`Instance.new` at runtime, the same "fully code-built, zero asset debt" approach `GlobalMessage`'s
own `Notify()` function already uses for its half of that system. A `UIListLayout` inside the
container handles stacking automatically (`SortOrder = LayoutOrder`, each new alert gets the next
`LayoutOrder`) - new alerts append below existing ones and the stack reflows itself when one
expires, no manual position-math needed (a cleaner approach than `GlobalMessage`'s own hand-rolled
`movenum`/`TweenPosition` stacking, which this system intentionally didn't copy). Each alert fades
in, waits `duration` (default 6s), then collapses its own height to 0 while fading out (`AutomaticSize`
is switched off just for the collapse tween, since Roblox ignores any `Size.Y` you set while
`AutomaticSize` is still `Y`) before being destroyed - a smoother reflow than an abrupt disappearance.

**Asset debt**: `ReplicatedStorage.Requests.Alert` (a RemoteEvent) needs creating in Studio, in the
same `Requests` folder as every other remote referenced in this doc - confirmed via this session's
own research that `ReplicatedStorage/Requests` is a Studio-only instance tree with no corresponding
files anywhere in `src/`, same situation as `AttractivenessChanged`/`MoneyChanged`/etc. documented
elsewhere in this file. Nothing else needed - the GUI itself needs no Studio assets per above.

**Wired into every real "already have an artifact" conflict guard** (the concrete example given for
this system) - `ServerStorage/Storage/{Black Pill, Charming Stone, Exoskeleton, Playful Stone,
Lannis Amulet, Phoenix Feather, Fairfrozen, Nightstone, Philosophers Stone, Pocket Watch, Unwavering
Focus, Spider Cloak, Howler Friend}` - 13 Tools total, every script anywhere in `src/` whose guard
actually reads as "you already hold an artifact," found via a repo-wide grep for `Artifact.Value`
comparisons and cross-checked one by one (the 5 `Scroll of <Godspell>` Activators that also compare
`Artifact.Value` were deliberately excluded - theirs is a *requires*-Philo check, not a conflict
guard, an unrelated use of the same field). Each now calls
`AlertModule.send(player, "You already have an artifact - "..data.Artifact.Value..". Reset your
current artifact by talking to Isaiah at desert 3.")` right before its existing `return` - the
message names the NPC who can actually reset an artifact (`dialogues.Isaiah` in
`DialogueHandler/ModuleScript.luau`, confirmed via its own `"Reset Artifact"` choice branch).
**`Howler Friend`'s guard was split, not just extended**: it originally combined two unrelated block
reasons in one `or` condition (`Artifact.Value already set` **or** `Race.Value == "Howler"`) - only
the first reason is a real artifact conflict, so it's now two sequential `if` blocks, alerting only
on the first and leaving the Howler-race block silent as before (inventing a message for a reason
that wasn't asked about would've been a guess). Three of the thirteen files (`Pocket Watch`,
`Unwavering Focus`, `Spider Cloak`) only had the Character in scope at the guard, not the Player, so
each resolves `game.Players:GetPlayerFromCharacter(...)` inline at the call site rather than
threading a new parameter through - matches how these same three files already inline-`require()`
`Commands` on every call rather than caching a local, so this follows their own existing style
instead of introducing a new one.

**Interpretive calls worth flagging**: the exact 6s default duration and the amber/dark-card visual
style are feel-based, not spec-derived - flag for tuning if a different look/timing was wanted. The
message names the real reset NPC (`Isaiah`, confirmed via his `"Reset Artifact"` dialogue branch)
rather than a placeholder - "desert 3" is the user-specified location text and was kept as given,
even though no area with that exact name was found in `AreaData.luau` during this session's research
(the closest name there is `"Deserted Keep"`); if `Isaiah` isn't actually near an area called
"Desert 3" in-game, that's a wording fix for whoever has Studio/world access, not a code change.
This system has not been tested in Studio (no Studio access from this session, same limitation noted
throughout this doc for UI work) - worth a visual pass once the `Requests.Alert` RemoteEvent is placed.

## Backpack stacking rework: one Tool per item type + Quantity (added 2026-07-29)

Every owned inventory item used to be its own separate cloned `Tool` instance - owning 20 Copper
meant 20 separate clones sitting in `Backpack`, confirmed as the cause of load lag: the
per-character-spawn restore loop (`StarterCharacterScripts/CharacterHandler/init.server.luau`,
runs on every join **and** every respawn) split `PlayerData.Inventory.Value` (a comma-separated
string, one entry per owned unit) and cloned one `Tool` per entry - the pre-existing 50-per-name
cap and `task.wait(1/30)` throttling already baked into that loop were the original author's own
evidence this could get slow. Reworked to **one Tool instance per item type**, carrying a
`Quantity` IntValue that increments/decrements, destroyed only when `Quantity` hits 0.

**Scope, confirmed with the user**: only 49 genuinely-stackable consumable item types - potions
(13), cures (5), poisons (6, including `Five Demises`), ores (4), ore bars (4), gems (5), gem
shards (5), candy (3), and 4 misc items (Turnip, Pizza, Pork Bun, Race Reroll Essence). The full
list lives in the new `ServerScriptService/Modules/StackableItems.luau`. Singleton items (unique
artifacts, equip-only tools like Pickaxe/Torch, unique weapon-flag items, scrolls) got zero
changes - never owned >1, not part of the lag problem, touching them only adds risk. The entire
Meat/Poisonous-Meat/cooked-meat family is excluded too - user confirmed poisonous meats are
legacy items that no longer do anything, and independently `Frying Pan/Script.server.luau` (the
cooking station) counts `Uncooked Meat` by physically iterating `Backpack:GetChildren()` rather
than by name, which would silently break under stacking (cooking would always see "1" regardless
of owned quantity). `Dye Packet` is excluded (stores real per-instance `DyeColor` state a shared
stack can't represent); `Shard of Mana` is excluded (a one-time story-trigger item, not a real
consumable - a second copy already gets permanently CSV-stuck today); the 4 `Cooked
Glowshroom`/`Periashroom`/`Scroom`/`Zombie Scroom` items are excluded since they have a
pre-existing bug (destroy with no matching `RemoveFromInventory` call at all) that this rework
didn't want to bundle a fix for.

**Design constraint**: `PlayerData.Inventory.Value`'s comma-separated, one-entry-per-unit string
format did **not** change - keeps save data compatible, and means nothing outside the central
functions below needs to know anything changed; only what happens to the physical `Tool` did.

**Central architecture** - both `Commands.AddToInventory`/`RemoveFromInventory`
(`ServerScriptService/Modules/Commands/init.luau`) already took an item *name*, not an instance,
which is what made this centralizable instead of needing to touch every one of ~239 call sites'
signatures:
- `AddToInventory`: CSV append unchanged. For a `StackableItems`-listed item, now checks
  `player.Character` first (a Tool being actively held/used lives there, not `Backpack`) then
  `player.Backpack` for an existing same-named Tool - if found, get-or-creates its `Quantity`
  IntValue and increments it instead of cloning; otherwise clones as before and adds `Quantity = 1`.
- `RemoveFromInventory`: CSV splice unchanged, but now also gained a **new optional 3rd parameter,
  `destroyDelay`** (replaces the `game.Debris:AddItem(script.Parent, N)` idiom several food items
  used to delay destruction until an eat animation/sound finished - see Turnip/Pizza/Pork Bun
  below). It locates the Tool (Character then Backpack), reads `Quantity` (missing = 1, matching
  the client's own `or 1` convention), and either decrements it or destroys the Tool at 0 (after
  `destroyDelay` if given). **This function now owns all Tool destruction** - previously it only
  ever edited the CSV string and every caller destroyed its own `script.Parent` separately.
  Non-stackable items never get a `Quantity` child (only the stackable path creates one), so for
  every singleton item this behaves exactly as it always did - `Quantity` nil → treated as 1 →
  destroyed immediately - which is why **no changes were needed in any out-of-scope item's
  script.** Also fixed a piece of dead code while here: the old version recomputed a `character`/
  `player` local at the end that nothing subsequently read - replaced with the same
  `player:IsDescendantOf(workspace.Live)` normalization `AddToInventory` already used, which is
  what makes the new Character/Backpack Tool lookup actually work regardless of whether a caller
  passed a Player or a Character.
- `ToolHandler.RemoveTool` (`ServerScriptService/ToolHandler.luau`): deleted its own `Tool:Destroy()`
  call - it already called `Commands.RemoveFromInventory(Player, Tool.Name)` first, which now owns
  that decision. Confirmed every call site passes `script.Parent` (or a local `tool` variable
  that's itself always assigned `script.Parent`), so this one deletion covers all 13 Storage +
  13 Alchemy/Tools potions with no per-file edits.
- `ToolHandler.GiveAlchemy`'s non-Ingredient branch (crafted-potion output) got the same
  get-existing-or-clone-and-initialize-`Quantity` treatment as `AddToInventory`. The raw-ingredient
  branch is untouched - ingredients aren't in the whitelist, and reading `Alchemy/init.server.luau`'s
  `concoct` directly confirmed finished potions are only ever a crafting *output*, never counted as
  an input off the player's Backpack, so there's no equivalent instance-counting risk there.
- Restore-on-spawn loop (`CharacterHandler/init.server.luau`) - the actual lag fix: now tallies
  occurrences per name from the split CSV first. For each `StackableItems`-listed name, clones
  **exactly one** Tool with `Quantity` set to the tallied count (the 50-cap is dropped for these,
  since an IntValue's cost doesn't scale with its value the way N-instances did). Non-stackable
  names keep the *exact* original per-entry clone loop, 50-cap, and throttling. The throttle's
  trigger moved from "every 60 raw CSV entries" to "every 60 actual `:Clone()` calls performed," so
  a player with thousands of stacked units doesn't get throttled for a clone count that no longer
  scales with quantity.

**No client changes needed** - `StarterGui/BackpackGui/BackpackClient.client.luau` already grouped
Tools by name (one icon per unique name) and already summed a `Quantity` child IntValue per Tool
(defaulting to 1 if absent) for its "xN" badge - confirmed by reading its rendering loop directly.
A single Tool with `Quantity.Value = 5` already rendered identically to 5 separate un-quantified
clones before this change; the pre-existing `"Vocare"` item (tied to `PlayerData.BoundAmount`) was
already using this exact convention as a one-off precedent.

**Bespoke fix required and applied - Witch Malady's Candy redemption**
(`WorldHandler/Dialogues/DialogueHandler/ModuleScript.luau`, `dialogues["Witch Malady"].v1`, the "I
have some Candy." branch): this was the one place that read Backpack contents by raw *instance*
count rather than by name - it looped `player.Backpack:GetChildren()`, credited 1 Candy Point and
destroyed each item with a child named `"Candy"` it found. Investigation turned up something
unexpected: `Blue Candy`/`Green Candy`/`Orange Candy`'s own scripts already redeem themselves
directly on use (`data.Candy.Value += 1` then self-destroy) - a completely separate path from this
NPC - and no script anywhere in `src/` creates a child instance literally named `"Candy"` inside
any Tool, meaning this branch may be checking for a Studio-only marker on some other item
entirely, or may already be effectively vestigial. Rather than guess which, the loop was rewritten
to be correct either way: sum each matched item's `Quantity` (missing = 1) instead of counting
instances, and remove that many via `RemoveFromInventory` (which now correctly decrements/destroys
instead of the loop's own blind `v:Destroy()`). This is a strict improvement in every case - for a
non-whitelisted item it behaves identically to before (no `Quantity` ever set → each match still
counts as 1), and for a whitelisted stack it now credits the true owned amount instead of just 1
point per physical Tool while silently destroying the rest of the stack.

**Per-item mechanical edits applied** across the 49 whitelisted items' scripts (both
`ServerStorage/Storage/<Name>` and, for the 13 potions, their `ServerStorage/Alchemy/Tools/<Name>`
duplicates):
- **Ores** (Copper/Tin/Iron/Mythril, byte-identical templates), **ore bars** (Copper/Tin/Iron/
  Mythril Bar, byte-identical), **gems** (Ruby/Emerald/Sapphire/Opal/Diamond, byte-identical),
  **cures** (5, byte-identical), **poisons** (6, byte-identical), **candy** (3, byte-identical
  apart from the item name string) - each had a trailing `script.Parent:Destroy()` (Candy's
  wrapped in a `pcall`) immediately after its own `RemoveFromInventory` call, now deleted since
  destruction is centralized. Applied via exact whitespace-matched `perl` substitution per file
  rather than the Edit tool, after the Edit tool's literal-string matching kept failing on this
  codebase's tab-indented decompiled style until whitespace was confirmed byte-for-byte via
  `cat -A` first.
- **Gem shards**: `Ruby Shard` and `Sapphire Shard` had the same trailing-destroy pattern, fixed
  the same way. `Emerald Shard`/`Opal Shard`/`Diamond Shard`'s scripts are **empty files** (no
  logic at all yet) - nothing to fix, flagged here rather than silently assumed equivalent to Ruby
  Shard.
- **Turnip, Pizza, Pork Bun**: previously delayed their destroy via `task.delay(.65, Tool.Destroy,
  Tool)` / `game.Debris:AddItem(script.Parent, 0.65)` so an eat animation/sound could finish before
  the Tool vanished from hand. Now pass `0.65` as `RemoveFromInventory`'s new `destroyDelay`
  parameter instead, with the separate scheduling line deleted.
- **Race Reroll Essence**: same trailing-destroy pattern as the ores/gems/cures family, fixed the
  same way.
- **All 13 potions** (both the `Storage` shop-purchase copy and the `Alchemy/Tools` crafted copy -
  26 files total): already routed through `ToolHandler.RemoveTool`, so needed **zero per-file
  edits** - fully covered by the one-line fix to `ToolHandler.RemoveTool` itself. Verified by
  grepping every file's local `tool`/`script.Parent` usage to confirm none of them pass a
  different instance than the Tool actually being consumed.
- `ServerScriptService/Modules/FoodModule.luau`'s `eatAnything` (the generic "eat &lt;item&gt;"
  chat-command path, which can target any Backpack item by name including whitelisted ones) had
  its own redundant `item:Destroy()` after calling `RemoveFromInventory` - deleted for the same
  reason as every per-item script above.

**Verification**: this repo has no test runner - manual Studio verification is still needed
(stack/unstack counts, respawn survival, the Candy redemption math, delayed-destroy timing on
Turnip/Pizza/Pork Bun, and confirming Meat/Poisonous Meat behave completely unchanged). Not yet
performed this session - no Studio access.

## Backpack stacking rework, follow-up audit (2026-07-29)

After the initial rework above, did a dedicated second pass (two parallel research agents - one
covering `WorldHandler/Dialogues/DialogueHandler/ModuleScript.luau` in depth, one covering the
rest of `src/`) specifically hunting for the *same bug class* as the Witch Malady fix: code that
manipulates one of the 49 whitelisted items by directly destroying/counting physical Tool
instances instead of going through the now-centralized `Commands.AddToInventory`/
`RemoveFromInventory`. Found and fixed six more real instances, all in the same file
(`ModuleScript.luau`) plus one each in `GetInvoke.server.luau` and `Admin/init.server.luau`:

- **Alana's and Reynauld's Health Potion quest turn-ins** (`dialogues.Alana`/`dialogues.Reynauld`,
  the "Would this potion be of any use?" / "Give a Health Potion" choices) - both used to look up
  the Health Potion Tool in `Character` or `Backpack` and call `:Destroy()` on it directly,
  *before* also calling `RemoveFromInventory` (which was then a no-op on an already-gone Tool).
  Under stacking this would have deleted the player's entire Health Potion stack for a 1-potion
  quest turn-in. Fixed by deleting the manual lookup-and-destroy entirely and calling
  `commands.RemoveFromInventory(p,"Health Potion")` alone - it already searches Character then
  Backpack internally, so the old two-branch `if/else` was redundant on top of being wrong.
- **Blacksmith's gem enchant** (`dialogues.Blacksmith`, both the 100-Money first-enchant and the
  1000-Money second-enchant branches) - same `tool:Destroy(); commands.RemoveFromInventory(...)`
  double-destroy shape, for the equipped Gem (Ruby/Emerald/Sapphire/Opal/Diamond). Fixed by
  deleting the `tool:Destroy()` line in both branches.
- **Merchant and Fungchant's item-selling** (`local function merchant`/`local function fungchant`,
  both NPCs share an identical two-path design: appraise-and-sell-one, or "sell in bulk") - the
  deeper of the two bugs found this session, with two parts:
  1. The bulk-sell path summed `total += b.MoneyValue.Value` **once per Tool instance** found in
     Backpack, then sold everything found via `v:Destroy()`. Under the old one-Tool-per-unit
     system this was correct (owning 10 Copper meant 10 Tool instances, each contributing once).
     Under stacking there's only 1 Tool per item type regardless of stack size, so a bulk sell of
     10 Copper would have paid for 1 and then destroyed the Tool - now silently deleting the other
     9 for nothing. Fixed by multiplying each match's contribution by its `Quantity` (missing = 1)
     before summing.
  2. Both the single-appraise and bulk-sell paths shared one confirmation handler that looped
     `v.tosell` and did `commands.RemoveFromInventory(p,v.Name); v:Destroy()` per entry - same
     double-destroy shape as Alana/Reynauld/Blacksmith. Fixed by changing what `tosell` holds:
     instead of raw Tool references, each entry is now `{tool = Tool, amount = N}` (`amount` is
     `1` for a single appraisal, the full counted `Quantity` for a bulk-sold stack), and the
     confirmation loop calls `RemoveFromInventory` `amount` times per entry instead of destroying
     directly. This preserves the intended difference between the two flows - appraising and
     selling one held potion still only spends 1 unit even if you're carrying a stack of 5, while
     "sell in bulk" still correctly liquidates an entire stack (that's its actual purpose), it's
     just now priced and removed correctly either way.
  3. Left one **pre-existing, unrelated bug alone**, flagged rather than fixed per this doc's own
     convention: Merchant's bulk-sell total does `total = math.round(total) * 1000` *inside* the
     per-item loop (`ModuleScript.luau`, the `merchant` function) rather than once after it, so
     multi-item bulk sells were already computing an absurdly inflated (or in edge cases
     nonsensical) price before this session touched anything. Fungchant's equivalent loop doesn't
     have this bug. Not fixed since it's a pre-existing pricing-math issue orthogonal to the
     stacking rework, not something introduced by or in scope for this pass.
- **World item drop** (`Requests.Drop`, handled in `WorldHandler/GetInvoke.server.luau`) - pressing
  Backspace to drop the equipped/held item called `Commands.RemoveFromInventory` (correct) *and
  then* `Path:Destroy()` on the same Tool unconditionally. Since `Path` is now the whole stack for
  any whitelisted item, dropping "1" would have destroyed the entire held stack while only
  spawning a single-unit world bag (`DropBag`'s pickup side already only ever grants 1 unit per
  pickup, confirmed unchanged) - a straight item-loss bug. Fixed by deleting the redundant
  `Path:Destroy()`, matching every other fix in this pass: `RemoveFromInventory` alone now
  correctly decrements by 1 (or destroys only if that was the last one), restoring the intended
  "drop 1, pick up 1" symmetry.
- **`/artifact` admin command** (`WorldHandler/Admin/init.server.luau`) - despite its name, this
  command does a case-insensitive substring match across **every** child of `ServerStorage.Storage`,
  not just artifacts, so an admin typing e.g. `/e artifact copper` would match. It cloned the item
  directly (`game.ServerStorage.Storage[v.Name]:Clone().Parent = Speaker.Backpack`), bypassing
  `AddToInventory` entirely - no `Quantity` handling (would create a second, un-stacked duplicate
  Tool alongside an existing stack) and, independently of this rework, it never wrote
  `PlayerData.Inventory.Value` at all, so anything granted this way was already silently lost on
  the next respawn even before stacking existed. Fixed by routing through
  `CommandsModule.AddToInventory(Speaker, v.Name)` (the module's already `require`d at the top of
  this file, used by the neighboring `giveitem` command) - one change fixes both bugs at once, and
  behaves identically to the old raw clone for every non-whitelisted item.

**Investigated, found orphaned, deliberately left alone**: `ServerStorage/SpellEffects/Squire/SquireModule.luau`'s
`u8.gem`/`u8.bar`/`u8.shard`/`consumeShard` functions have the same double-destroy/no-bookkeeping
shape (`u8.bar` calls `p34:Destroy()` with **no** `RemoveFromInventory` call at all; `u8.gem`/
`consumeShard` reparent the Gem/Shard's `Handle` out of the Tool *before* calling
`ToolHandler.RemoveTool`, which would leave a surviving multi-unit stack visually handle-less).
Confirmed via a repo-wide grep that none of `u8.gem`/`u8.bar`/`u8.shard` have any call site
anywhere in tracked `src/` (only `u8.summon`/`u8.enchant`/`u8.grind`/`u8.replaceWeapon` are ever
invoked, from `Classes/Grindstone` and `Classes/Remote Smithing`) - `u8.shard` in particular looks
like a fully superseded duplicate of the gem-shard-casting behavior that already lives in (and was
already fixed in, earlier this session) `Ruby Shard`/`Sapphire Shard`'s own `Script.server.luau`.
This file is marked "Decompiled with the Synapse X Luau decompiler" in its own header, consistent
with being legacy code from before the current per-item Tool scripts existed. Not fixed, since
editing confirmed-unreachable code adds no verified value and risks introducing an untested change
to something that might matter if it turns out a Studio-only ClickDetector still invokes it -
flagged here instead, per this doc's established practice for exactly this situation (see the
`ModStop` stray-backtick note earlier in this file). If anyone with Studio access confirms these
functions are actually wired to something, they need the same fixes as everywhere else in this
pass before being trusted.

**Confirmed safe, no changes needed**: Ezlo's gem-teleport dialogue trick (already just called
`RemoveFromInventory`, no direct destroy); every Trinket/loot-bag/GetInvoke pickup path (always
grants exactly 1 unit via `AddToInventory`/`GiveAlchemy`, confirmed unchanged); `BackpackGui`'s
client (no combine/split-stack UI exists to worry about - the only stack-affecting player action
is the drop mechanic just fixed above); the commented-out dead `PlaceTool`/`PlaceMoney` block in
`RequestHandler.server.luau` (confirmed genuinely unreachable - wrapped in a Luau block comment -
so left untouched even though it contains the same bug pattern, since editing dead code inside a
comment has no effect either way).

## Backpack stacking: whitelist → blacklist, scope expanded to nearly all Storage items (2026-07-29)

**Root cause of a live bug report**: a player used `/e giveitem` to grant themselves an item and
still got a separate duplicate Tool per grant instead of a single stacking Tool. Traced this back to
the original design: `StackableItems.luau` was an explicit **allow-list** of the 49 items chosen in
the first pass - any item not manually added to it (which, as it turned out, was most of
`ServerStorage/Storage`) silently fell back to the old one-Tool-per-unit behavior with zero warning.
The user's fix direction: **"all items in Storage are stackable"** - flip the model so stacking is
the default and only a short, explicit, well-justified list of items opts out.

**`ServerScriptService/Modules/StackableItems.luau` was deleted and replaced by
`ServerScriptService/Modules/NonStackableItems.luau`** - a blacklist, now just 15 entries: the same
Meat-family + `Dye Packet` + `EmptyName` exclusions from the original pass, plus one newly-found
addition, **`Torch`** (each physical Torch tracks its own `Lit`/`PercentLit`/`ColdResist`-boost
warm-up state - merging two Torches in different lit states into one shared stack would silently
corrupt that state, the same class of problem as `Dye Packet`'s `DyeColor`). All three call sites
(`Commands.AddToInventory`/`RemoveFromInventory`, `ToolHandler.GiveAlchemy`, the respawn restore
loop in `CharacterHandler/init.server.luau`) now check `not NonStackableItems[item]` instead of
`StackableItems[item]` - inverted condition, same underlying increment/clone and decrement/destroy
logic as before, unchanged.

**Consequence: everything under `ServerStorage/Storage` except those 15 items is now stacking-aware**,
which meant re-running the same audit-and-fix pass from the original rework across the other 52
item types that were previously out of scope (unique artifacts, scrolls, and a handful of misc
items) - same two categories of work as before:

**1. Per-item redundant-destroy fixes (41 of the 52 needed it)**: every one of these item scripts had
the same shape already fixed in the original 49 - `RemoveFromInventory(...)` immediately followed by
`script.Parent:Destroy()` (now redundant/harmful, since `RemoveFromInventory` already owns
decrement/destroy) - fixed the same mechanical way, `:Destroy()` deleted:
- 12 artifacts: Black Pill, Charming Stone, Exoskeleton, Playful Stone, Lannis Amulet, Phoenix
  Feather, Fairfrozen, Nightstone, Philosophers Stone, Pocket Watch, Spider Cloak, Howler Friend.
  (`Unwavering Focus`, the 13th artifact, turned out to already have no redundant destroy - already
  correct, confirmed rather than assumed.)
- 18 of the 19 Scrolls (`Scroll of Mori` is the exception - see below). Five of them (Contrarium,
  Fimbulvetr, Hoppa, Manus Dei, Percutiens) are byte-identical Godspell-swap templates with **two**
  destroy sites each (an `if`/`else` branch), both fixed with one regex covering both branches.
- 9 misc items: Amulet of the White King, Azael Horn, Ice Essence, Inquisitive Essence, Mysterious
  Artifact (this one calls `RemoveFromInventory(Player, tostring(script.Parent))` instead of
  `.Name` - `tostring()` on an Instance already returns its `.Name` in Luau, so this is equivalent,
  left as-is rather than "corrected" to a different-looking but behaviorally identical call), Phoenix
  Down, Rift Gem (its destroy was wrapped in a `pcall(function() ... end)` - removed the whole
  wrapper, same as the earlier Candy fix), Scroom Key, Seraph Essence, Shard of Mana, Weights.

**2. Confirmed persistent/reusable, correctly need zero changes (9 items)**: Dark Cowl, Light Cowl,
Tan Cowl (equip/unequip toggles), Helmet (equip toggle - its one `:Destroy()` call removes an
unrelated `Boosts` buff instance tagged `"Sigil Helmet"`, not the Helmet Tool itself), Frying Pan
(cooks the already-excluded `Uncooked Meat`; never destroys itself), Pickaxe (mines ore via
`AddToInventory`; never destroys itself), Pebble (every `:Destroy()` in its script targets the
*thrown projectile clone*, never the Tool - it's a reusable ranged weapon), Phoenix Clown (a
reusable cosmetic sound toy, no inventory interaction at all), Torch (excluded above, but also
genuinely never destroys itself even before that - a belt-and-suspenders situation, not a
contradiction).

**3. Left deliberately unfixed - `Scroll of Mori`, then reconsidered and fixed anyway**: this scroll
kills its own caster (`_G.Death(script.Parent.Parent)`) and, uniquely among all ~101 stackable
items now covered, **never called `RemoveFromInventory` at all** - just a bare `script.Parent:Destroy()`
with zero CSV bookkeeping, a pre-existing gap that predates this rework entirely. Initially flagged
as "pre-existing, unrelated, don't fix" per this doc's usual convention - but since this session's
whole ask was specifically "check dialogues and other possible item deletion instances to work with
the new system," a raw unconditional Tool-destroy is exactly that, so it was fixed after all: added
the same `require(...).RemoveFromInventory(v2,script.Parent.Name)` call every other scroll already
has, removed the bare `Destroy()`. Correct CSV bookkeeping is a side benefit; the main effect is that
a stacked Mori scroll now loses only 1 unit instead of the whole stack on use.

**4. Dialogue/other-systems audit, round 2 (ran the same two-agent research pass again, scoped to
the 52 new items)** - found and fixed 2 more real double-destroy bugs, same shape as the earlier
Alana/Reynauld/Blacksmith/Merchant/Fungchant fixes:
- **Adralik's Rift Gem turn-in** (`dialogues.Adralik.v1`, "Here you go" choice) - found the Tool via
  `Character`/`Backpack`, destroyed it directly, then separately called `RemoveFromInventory`.
  Simplified to a single `commands.RemoveFromInventory(p,"Rift Gem")` call (which already checks
  both locations internally, so the manual `Character`-then-`Backpack` branching was redundant on
  top of being wrong).
- **Grimtooth's Howler quest turn-ins** (`dialogues.Grimtooth.v1`, "Here" choice) - the same
  double-destroy shape appears **four times** in this one quest (Lannis Amulet turn-in ×2, Howler
  Friend turn-in ×2, across the quest's three possible turn-in orderings) - all four fixed the same
  way, dropping the manual `:Destroy()` and keeping only the `RemoveFromInventory` call.

**Confirmed safe / correctly out of scope during round 2**: Isaiah's "Reset Artifact" dialogue (only
ever touches `PlayerData.Artifact.Value`, never a physical Tool - by the time this runs, the Tool
was already consumed at the moment the artifact was originally activated); a second, Robux-product-
driven "Reset Artifact" flow in `ProductHandler.server.luau` (same reasoning, a parallel
implementation of the same reset semantics worth knowing about but not a stacking bug); Ezlo, Miner
John, and the Castellan ascension quest (all already name-based, no raw destroy); `Dorgan`'s Frying
Pan checks (reads the CSV string via `:find`, not a physical count, unaffected by `Quantity`
either way); `TrinketsHandler.server.luau`'s loot-weight tables (probability data only, actual
grants already go through `AddToInventory`); the `RequestHandler.server.luau` `PlaceTool`/`GiveTool`
pathway (re-confirmed still fully inside the same dead block-comment identified in round 1 - a
`sameArti` Backpack-instance-counting duplicate-artifact cap living in there would have been a real
bug on a live path, but it isn't one since nothing in this file executes).

**Interpretive call flagged, not acted on**: while sweeping the dialogue file a second time, found
that "Desert Mist" and "Love Letter" (two other `:Destroy()`-by-name targets in nearby quest code)
aren't the name of any folder under `ServerStorage/Storage` at all - "Desert Mist" turned out to be
a real alchemy ingredient (see the next section - its double-destroy bug was fixed once ingredients
became stackable); "Love Letter" still isn't any known item name in either `Storage` or
`list_alchemy.luau`'s ingredients, so it remains genuinely out of scope, left alone rather than
guessed at.

No client-side changes needed, same as the original 49-item pass - `BackpackGui` already handles any
`Quantity`-bearing Tool correctly regardless of which items carry one.

## Alchemy ingredients and crafted foods didn't stack (2026-07-29)

Reported directly: "Items related to alchemy don't stack correctly." Two genuinely separate bugs,
both now fixed - one in the give-side plumbing (raw ingredients never had any stacking logic at
all), one in the consume-side plumbing (a script that already half-expected stacking but never got
wired up correctly).

**Raw ingredients (Vile Seed, Scroom, Potato, Trote, Desert Mist, ~24 others in
`list_alchemy.luau`'s `module.ingredients` table) never stacked, full stop** - unlike every `Storage`
item, ingredients are synthesized fresh from a shared `Alchemy/Tools/Ingredient` template plus a
per-type hand model (`Alchemy/Models/<Name>`), a completely different code path
(`ToolHandler.GiveAlchemy`'s `Ingredient` branch) that was never touched by the `StackableItems` →
`NonStackableItems` rework at all, since it isn't reached via `ServerStorage.Storage`. Confirmed
every ingredient's properties (`rarity`/`color`/`hot`/`silver`/`tooltip`) are static per *type*, not
randomized per pickup, so there's no per-instance-data conflict blocking this the way `Dye Packet`/
`Torch` have - safe to stack all of them. Fixed by adding the identical get-existing-or-clone-and-
initialize-`Quantity` treatment already used everywhere else, to both:
- `ToolHandler.GiveAlchemy`'s `Ingredient` branch (`ServerScriptService/ToolHandler.luau`) - checks
  `Character`/`Backpack` for an existing same-named ingredient Tool before cloning a new one.
- The respawn restore loop's ingredient branch (`CharacterHandler/init.server.luau`, the `else` arm
  of the `if ic and not ic:FindFirstChild("isIngredient")` check) - now clones **one** ingredient
  Tool with `Quantity` set to the tallied CSV count, instead of one clone per occurrence, matching
  the exact same fix already applied to the `Storage`-item arm in the original pass.

**`ServerStorage/Alchemy/Tools/Ingredient/Script.server.luau` (the ingredient Tool's own
consumption logic - depositing into the Alchemy crucible, or eating one raw via the `Herbivore`
skill) turned out to already contain partial `Quantity`-aware code** - `local quantityVal =
tool:FindFirstChild("Quantity")` captured at the top of the file, then in both the crucible-deposit
and Herbivore-eat branches: `if quantityVal and quantityVal.Value > 1 then quantityVal.Value =
quantityVal.Value - 1 else ToolHandler.RemoveTool(...) end`. This was dormant/inert before this
session - since nothing ever created a `Quantity` value on an ingredient Tool, `quantityVal` was
always `nil` and this always fell to the `else` branch (immediate destroy), which is exactly why
ingredients read as "never stacking" even though this script looks like someone already started
building stacking support for it. Now that ingredients actually carry a `Quantity` value, this
dormant code became live - and it turned out to have a real bug of its own: **the manual
`quantityVal.Value -= 1` branch never called `Commands.RemoveFromInventory`, so it silently
desynced the physical stack count from `PlayerData.Inventory.Value`'s CSV string** (the stack would
correctly shrink, but the CSV would keep every entry until the very last unit was consumed) - which
would have caused **more copies than actually owned to reappear on the next respawn**, since the
restore loop rebuilds purely from CSV entry counts. The Herbivore-eat branch additionally had the
same double-destroy shape found throughout this whole rework (`tool:Destroy()` immediately before
`ToolHandler.RemoveTool(...)`, which already handles destruction). Both branches were simplified to
a single `toolHandler.RemoveTool(plr, tool)` call each - that function already does the correct
decrement-or-destroy-and-keep-CSV-in-sync behavior, making the hand-rolled `quantityVal` math
entirely redundant. The now-unused `local quantityVal = tool:FindFirstChild("Quantity")` declaration
was removed along with its only two call sites.

**Also fixed while here - the 4 Cooked Mushroom items** (`Cooked Scroom`/`Cooked Glowshroom`/
`Cooked Periashroom`/`Cooked Zombie Scroom`, all under `ServerStorage/Alchemy/Tools/`): these are
crucible-*crafted outputs* (real `list_alchemy.luau` recipes, e.g. `["Cooked Scroom"] = {recipe =
{"Scroom"}}`), not raw ingredients, so they already went through `GiveAlchemy`'s non-Ingredient
branch and were already correctly stacking on the *give* side. But per the original 49-item pass,
their own consumption scripts had a **pre-existing bug flagged-but-not-fixed at the time**: eating
one calls a bare `script.Parent:Destroy()` with **no `RemoveFromInventory` call anywhere in the
file**. Originally left alone as "don't bundle an unrelated fix in" - but since this session is
specifically about alchemy items not stacking correctly, and a bare unconditional destroy is
precisely that failure mode (eating 1 of a stack of 5 would have wiped all 5), it was fixed the same
way `Scroll of Mori` was reconsidered and fixed last round: added a proper
`RemoveFromInventory(game.Players:GetPlayerFromCharacter(char), script.Parent.Name)` call in place
of the raw destroy, identically across all 4 files (confirmed byte-identical aside from one trivial
comment).

**Also found and fixed while re-checking dialogues - Nero's Desert Mist quest** (`dialogues.Nero.v1`
/ the "Here you go" choice, `WorldHandler/Dialogues/DialogueHandler/ModuleScript.luau`): same
double-destroy shape as Adralik/Alana/Reynauld/Grimtooth from the two previous rounds - found via
`Character`/`Backpack`, destroyed directly, then separately called `RemoveFromInventory`. This one
was missed in the prior dialogue audits because "Desert Mist" isn't a `ServerStorage/Storage` folder
name (it's an alchemy ingredient, which wasn't in scope for stacking until this session) - simplified
to a single `commands.RemoveFromInventory(p,"Desert Mist")` call, same fix shape as every other
turn-in bug found this session.

**Noted, not touched**: the working tree's `NonStackableItems.luau` had its plain `["Meat"] = true`
entry removed independently of this session's own edits (all the Poisonous Meat tiers + Uncooked/
cooked-quality Meat + Vint remain excluded) - taken as-is, not reverted, since whoever made that
change presumably has a reason plain Meat doesn't need the same exclusion its poisoned siblings do.

## Gate exempted from Squeamish; low-Attractiveness NPC gate removed (added 2026-07-29)

Two small, unrelated fixes done together, both by direct request.

**Gate is now castable while Squeamish** (`ServerScriptService/Modules/SpellModule.luau`, both
`module.cast` and `module.castnew`): the `character:FindFirstChild("Squeamish")` early-return in
each function now carves out `info.name ~= "Gate"`, mirroring this same file's existing pattern of
Gate-specific exceptions living inline as `info.name == "Gate"` checks (the pre-existing
`WarLocation`/`NoGate`/Cameo/Abysswalker carve-outs a few lines below, and the `allcast` bypass
table at the top of the file, which already listed `"Gate"` for a different restriction). Only the
Squeamish block itself was touched - Gate still goes through the exact same mana-window roll
(`mana >= info.lowerbound and mana <= info.upperbound`) and its own `Activator.luau`'s separate
mana-cost deduction (`Mana.Value -= v1.cost`) as everyone else, satisfying the "and charge mana"
part of the request: this isn't a free/instant cast bypass, just an exemption from Squeamish's
outright block. Fixed in both `cast`/`castnew` rather than tracking down which one Gate's Tool
actually calls (gated on a `Rework` child - a Studio-only Instance per this repo's Argon
`keepUnknowns` situation, not confirmable from `src/` alone) - same defensive-duplication approach
this file already uses for its other Gate carve-outs.

**NPCs no longer ignore low-Attractiveness players at all** - the generic gate added in the
Mogging/Attractiveness session (`WorldHandler/Dialogues/DialogueHandler/init.server.luau`, both
the `npcclick` ClickDetector path and the `DialogueCreate` bindable path) was removed outright, by
request. **SolanBall ("Voice of Solan," referred to in the request as "the tomeless orb" - its own
`uglyhaslife`/`uglywiped` dialogue entries literally describe it as "this orb") keeps its unique
"ugly" dialogue branch and 10% wipe chance unchanged** - confirmed via `dialogues.SolanBall.v1`
(`ModuleScript.luau` ~13774) that this was never wired through the entry gate being removed: it
calls `AttractivenessModule.compute` itself and branches on `<= 30` independently, so deleting the
outer gate has zero effect on it.

**Noticed while removing, not otherwise acted on**: the two gate copies had actually drifted from
each other before this fix - `npcclick`'s threshold read `< 15` while `DialogueCreate`'s read
`< 30` (both were documented elsewhere in this file as `< 30`). Moot now that both copies are
deleted, but flagged in case the same `< 15`/`< 30` mismatch pattern exists anywhere else this
doc's earlier Attractiveness sections describe.

**Follow-up, same day: the drifted `< 15` value turned out to be the intended bar, not a stray
copy.** Per direct confirmation ("The bar is now < 15"), `dialogues.SolanBall.v1`'s own "ugly"
threshold (`ModuleScript.luau` ~13780 - the only Attractiveness-gated NPC check left in the game
after the general gate above was deleted) was tightened from `attractiveness <= 30` to
`attractiveness < 15`, so SolanBall's disgusted dialogue and 10% wipe roll now only trigger for
genuinely very-unattractive players, not the wider "merely below-average" band the `<= 30` value
covered. Nothing else about that branch (the 10% wipe roll, the `uglyhaslife`/`uglywiped` dialogue
entries, the `haslife` fallback for everyone else) changed.

## Height/Attractiveness carry over if the previous character never survived a day (added 2026-07-29)

`CharacterCreationGui/Script.server.luau` already had a carry-over rule for `HeightMultiplier`
(don't reroll if the new character is created within 2 minutes of the last one, `LastCharacterCreated`)
but `AttractivenessBase` had none at all - it's deliberately never set in the `gettable` reset
table, so every new character fell through to the Setup folder's 0-sentinel default, which
`CharacterHandler/init.server.luau`'s lazy-roll then re-rolled fresh on next spawn, every time.

**New rule, by request**: if the just-ended character's `DaysSurvived` (read off the OLD
`PlayerData` local, captured at the top of this handler before `GotData:Set(gettable)`
overwrites it) is `< 1` - i.e. it never survived even a full in-game day - the new character
carries over **both** `HeightMultiplier` and `AttractivenessBase` from the old one instead of
rerolling. Height's existing 2-minute-reuse condition is untouched and now sits alongside this one
as an alternative trigger (`reuseWindow or survivedLessThanADay`); Attractiveness only gets the new
DaysSurvived condition, not the 2-minute one, since only DaysSurvived was asked for there - an
Attractiveness carry-over via "recreated quickly" wasn't part of this request, so it wasn't added.

**Interpretive calls worth flagging**: `< 1` was read literally ("before reaching dayssurvived is
atleast 1"), effectively `DaysSurvived == 0` for what's presumably an integer day-counter. Both
carry-over checks are defensive the same way the pre-existing HeightMultiplier logic is - a
missing `DaysSurvived`/`AttractivenessBase` Instance (Setup-folder-pending account) just skips that
branch rather than erroring, falling back to the normal fresh-roll behavior.

## Attractiveness: workout bonus (added 2026-07-29)

`ServerScriptService/Modules/AttractivenessModule.luau`'s `compute()` gained a flat bonus: +1
Attractiveness per 10 total points invested across all 5 `WorkoutModule` categories
(`WorkoutChestPoints`/`WorkoutLegsPoints`/`WorkoutCorePoints`/`WorkoutShouldersPoints`/
`WorkoutBackPoints`, see the Workout/Hypertrophy system elsewhere in this doc), summed and
`math.floor`ed then capped at 15. Added AFTER the existing `base * classMult * raceMult *
heightFactor` multiplication, not folded into `base` itself - "give 1 attractiveness" reads as a
flat point per the request, not something meant to be re-scaled by class/race/height on top. The
15 cap matches the request's own stated ceiling exactly - mathematically already the max given 5
categories * WorkoutModule's existing 30-point-per-category cap / 10 = 15 - but an explicit
`math.min` clamp is kept anyway rather than relying on that arithmetic coincidence never changing
(same defensive-clamp habit as this file's height factor and `TagHumanoid`'s
`MeleeDamageMultiplier` elsewhere in this doc). Missing workout stat fields (Setup-folder-pending,
same situation as every other new `PlayerData` field in this doc) are skipped rather than erroring,
same as every other defensive `FindFirstChild` guard in this function - a brand-new character with
no workout stats yet just gets a 0 bonus, not a broken compute() call.

## Attractiveness: Black Pill / Vampire flat bonuses (added 2026-07-29)

Two more flat additive bonuses in `AttractivenessModule.compute()`, same shape as the workout
bonus just above (added after the `base * classMult * raceMult * heightFactor` multiplication, not
folded into it) - `+5` for holding the Black Pill artifact (`data.Artifact.Value == "Black Pill"`,
the same check every other Black Pill interaction in this codebase already uses) and `+5`
independently for having Vampirism (`data.Vampire.Value == true`). Both stack with each other and
with the workout bonus - a Black Pill vampire who's also worked out gets all three bonuses at once.

**Vampire deliberately checks `PlayerData.Vampire.Value`, not the `"Vampirism"` CollectionService
tag** that most other Vampirism-related code in this codebase reads
(`CollectionService:HasTag(Character, "Vampirism")` - used all over `TagHumanoid`, `Health.server.luau`,
the various Meat/food scripts, etc.). Traced this via `CharacterHandler/Modules/Vampirism.luau`:
the tag is just a replicated-to-the-client marker that gets added/removed in response to
`PlayerData.Vampire.Value` changing - `PlayerData.Vampire` is the actual server-truth field
everything else derives from. Reading the tag here would repeat the exact spoofable-Character-marker
mistake this session's earlier security-fix pass (see that section elsewhere in this doc) already
went through and fixed for a dozen other passives - so this was written against `PlayerData`
directly from the start rather than needing a second fix later.

## Attractiveness recomputes in real time on Black Pill use and Race change (added 2026-07-29)

Before this, `AttractivenessModule.compute()` only ran at spawn (plus a handful of other call
sites - Mogging, the NPC gates, SolanBall) - picking up Black Pill mid-life or changing race
mid-life wouldn't reflect in Attractiveness (or the HUD label) until the next respawn.

**Black Pill** (`ServerStorage/Storage/Black Pill/Script.server.luau`): added a `compute()` call
immediately after `data.Artifact.Value = "Black Pill"` is set in the Tool's `Activated` handler -
its own `+5` Attractiveness bonus (see the Black Pill/Vampire bonuses section above) now shows up
the instant the artifact is used, not on next spawn. Scoped to exactly what was asked ("when black
pill is used") - the separate Isaiah "Reset Artifact" dialogue flow, which sets `Artifact.Value`
back to `"None"`, was NOT touched, so losing the bonus via a reset still waits for next spawn;
flagged here rather than silently expanded to cover it too.

**Race changes** (`ServerScriptService/Modules/AttractivenessModule.luau`, new
`module.watchForRaceChanges(player, data)`): `PlayerData.Race.Value` is reassigned from roughly two
dozen scattered call sites across this codebase (race-change items - Seraph Essence, Phoenix
Feather, Azael Horn, Scroom Key, Amulet of the White King - dialogue race-change branches,
`RaceReroll`, `ProductHandler`'s Robux race reroll, admin commands, etc.) - confirmed via a
repo-wide grep for `Race.Value =` assignments. Rather than add a `compute()` call at each of those
sites individually (invasive, and easy to miss one), a single `data.Race.Changed:Connect(...)`
listener recomputes Attractiveness whenever Race changes from any source, present or future. Wired
up once per spawn in `CharacterHandler/init.server.luau`, right next to the existing spawn-time
`compute()` call. **Guarded against stacking**: since this runs once per character spawn but
`PlayerData` (unlike `Character`) persists across respawns, connecting unconditionally every spawn
would pile up one listener per life lived, each redundantly recomputing and re-firing the HUD
update on every future race change - guarded with a one-time `AttractivenessRaceWatcher` Folder
marker parented to `PlayerData` itself, checked before connecting.

## Attractiveness: widened base roll, added a height factor (added 2026-07-29)

Two changes to `ServerScriptService/Modules/AttractivenessModule.luau` and the base-roll site in
`StarterCharacterScripts/CharacterHandler/init.server.luau` (~line 432), both per direct request.

**`AttractivenessBase`'s roll widened from a flat `math.random(10,20)` to a weighted 10-30 band**:
a `math.random(1,100)` roll picks the band (`<=20` → `math.random(10,15)`, `<=95` →
`math.random(16,24)`, else → `math.random(25,30)`), giving the requested 20%/75%/5% odds exactly
(20 numbers / 75 numbers / 5 numbers out of 100). `compute()`'s own missing-field fallback (used
only when `AttractivenessBase` doesn't exist in the Studio Setup folder yet) moved from `15` to
`20` to track the new range's dominant-band midpoint, same reasoning as the original fallback's
choice of `15` as the old range's midpoint.

**New height factor, multiplied into `compute()`'s result alongside class/race**: reads
`PlayerData.HeightMultiplier` (the existing 0.8x-1.1x per-character roll, see the height-roll
section elsewhere in this doc) directly as a multiplier - literally per the request's "height
multiplier (negative or positive) = attractiveness multiplier," so a HeightMultiplier below 1x
proportionally lowers Attractiveness and above 1x proportionally raises it, with no extra step for
the plain in-between case. Two additional bands stack a further multiplier on top of that raw
value: below `0.95x` gets an extra `0.925x` penalty (short characters lose out by more than
proportional height alone would suggest); above `1.05x` gets an extra `1.02x` bonus. Between
`0.95x` and `1.05x` inclusive, the raw HeightMultiplier applies with no further adjustment - this
also covers the request's explicit "doesn't apply to 1x+ height" carve-out for the penalty band,
since anything at or above 1x is already outside the below-0.95x penalty range. Guarded the same
defensive way as `AttractivenessBase`'s own missing-field case: a missing or `<=0` (stale
not-yet-rolled sentinel) `HeightMultiplier` falls back to a neutral `1` (no effect) rather than
erroring or crushing the whole result to 0.

**Interpretive calls worth flagging**: the height factor reads `PlayerData.HeightMultiplier`
directly, not the Black-Pill-inclusive "total scale factor" `CharacterHandler/init.server.luau`
computes for the actual visual body scale - Black Pill's own `1.2x` wasn't mentioned as an
Attractiveness input in the request, so it's excluded here; revisit if Black Pill holders are also
meant to get an Attractiveness bump from it. The exact `0.925x`/`1.02x` extra-band multipliers and
the `0.95x`/`1.05x` band edges are exactly what was given in the request, not independently chosen.
Not yet tested in Studio (no Studio access this session, same limitation noted throughout this
doc) - worth confirming the weighted roll's actual distribution and the height-factor math against
a few live characters once possible.
