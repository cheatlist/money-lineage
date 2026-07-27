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
