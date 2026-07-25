# Money Lineage — Architecture Notes

A Roblox game in the Rogue Lineage / Deepwoken lineage-roguelike genre: permadeath-ish
progression through Races, Classes (fighting styles/skill trees), and Paths (elemental/thematic
specializations layered on top of a class).

## Tooling: Argon, not Rojo

This repo is synced with **Argon**, not Rojo. `default.project.json` is Argon's project file — the
format is Rojo-compatible (Argon reads/writes the same schema), but the actual sync/build/watch
tooling is Argon's CLI + VS Code extension. Practical implications:

- `/sourcemap.json` is Argon-generated and gitignored — don't hand-edit it, don't expect it to exist.
- Every `$path` folder in `default.project.json` has `$keepUnknowns: true`. This means **binary
  Roblox instances (Animations, Sounds, Meshes, ParticleEmitters, NPC models, dialogue-trigger
  parts) are NOT tracked in this git repo** — they live only in the live Studio place file. Scripts
  reference them by sibling/child instance name (e.g. `script.Parent.Anim`,
  `HumanoidRootPart.DragonRoar:Play()`). When a script references an instance name that doesn't
  appear anywhere in `src/`, that's expected — it's a Studio-side asset, not a bug.
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

The dialogue engine itself (`Dialogues/DialogueHandler/init.server.luau`) is a simple state machine:
`talking[Character] = {npc, page, choice}`. Each NPC's `dialogues.<Name>.v1(p, v)` handler is called
on every step; `v.page` starts at 1 and increments by 1 per choice made; `v.choice` holds the last
choice string. Handlers branch on `v.page` for flow position and `v.choice` for which option was
picked — **when adding a page to an existing NPC's flow, disambiguate by `v.choice` content if the
page number can be reached from more than one prior branch**, don't assume page number alone is
unique.

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
5. **`wait()` → `task.wait()` sweep — scoped, not exhaustive.** Only the ~135 files already touched
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
