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
  - `Modules/` — `Commands/` (chat/admin commands, includes a `GetClasses.luau` class-data copy),
    `HitDetection.luau` (AOE/cone targeting, calls into `TagHumanoid`), `EffectModule.luau` (generic
    VFX helpers: `Lightning`, `QuickLightning`, `Explosion`, `Wings`, `Wings2`, `HeraldWings`, etc.),
    `DataStore2`, `SpellModule`
  - `WorldHandler/` — the gameplay brain
    - `GameLoaded/init.server.luau` — the authoritative `classdata` table (class trainer NPC config)
    - `Admin/GetClasses.luau` — a second, near-duplicate flat class→skills table (admin grant tooling)
    - `Dialogues/DialogueHandler/ModuleScript.luau` — **huge** (10k+ lines): the entire dialogue
      engine, a third near-duplicate `classdata` table, `teachskill()`, and every path-trial NPC
      (`VoiceFromAbove`, `Heretic`, `Fang`, etc.)
    - `Dialogues/DialogueHandler/init.server.luau` — the dialogue *driver* (talking-state machine,
      NPC click wiring, remote events) — thin, doesn't contain content
    - `TagHumanoid.server.luau` — **huge** (3000+ lines): the actual damage/stun/knockback/proc
      resolver. Every move's `Info` table flows through here. All passive procs that trigger "on
      hit" live in this one file.
- `src/ServerStorage/`
  - `Classes/<Move Name>/` — one folder per **active move**, synced as a Roblox `Tool`. Despite the
    directory name, this is the move library, not the class library.
  - `RacialAbilities/`, `Weapons/`, `Storage/` (items/scrolls), `PlayerData` (live per-player
    instance tree, not present in this repo — created at runtime)
- `src/StarterCharacterScripts/CharacterHandler/init.server.luau` — **huge** (~5800 lines): per-character
  server logic (class/skill grants, boosts, weapon logic, path-flag reads for shared systems like Dash)
- `src/StarterGui/`, `src/StarterPlayerScripts/` — client UI/input

Much of the codebase reads as decompiled/deobfuscated Lua (generic names like `v1`, `u2`,
`l__Parent__1`) — this is pre-existing style, not something introduced recently. Match it when
editing these files rather than silently "cleaning up" unrelated code in the same diff.

## Core systems

### 1. Classes (fighting styles)

A class is a named skill bundle with a price, a prerequisite class, and (for ultras) a flag. The
**same conceptual class list is duplicated across 4 files** and must be kept in sync by hand:

1. `ServerScriptService/Modules/Commands/GetClasses.luau` — flat `{ClassName = {skill, skill, ...}}`
2. `ServerScriptService/WorldHandler/Admin/GetClasses.luau` — near-duplicate, admin variant
3. `ServerScriptService/WorldHandler/GameLoaded/init.server.luau` — richer `classdata` table (`skills`,
   `price`, `requiredclass`, `class`, `ultra`/`isultra`) used by in-world class-trainer NPCs
4. `ServerScriptService/WorldHandler/Dialogues/DialogueHandler/ModuleScript.luau` — a second, near-identical
   `classdata` table, plus `teachskill(p, info, firstcheck)` which actually grants skills

Key naming gotcha: the outer table *key* is sometimes the no-space PascalCase form (`DragonSlayer`)
and sometimes the spaced display form (`"Dragon Slayer"`) depending on the file — and the `class`
field (the literal string written to `PlayerData.Class.Value`) doesn't always match the outer key
either. Check each file's existing convention before editing rather than assuming consistency.

`teachskill()` grants **one random unowned skill per NPC visit** (for a price), not the whole class
at once — a player must return repeatedly until `ownedskills == #info.skills` ("max").

### 2. Moves (active abilities)

Master move library: `ServerStorage/Classes/<Move Name>/`, one folder per move (a Rojo/Argon-synced
`Tool`). A move script (`Script.server.luau` or `Activator.luau`) typically:
- Defines a copy-pasted `ActionCheck()` guard (stun/blocking/knocked checks) — duplicated verbatim
  in nearly every move file
- Manages its own cooldown via a `NumberValue` under `Character.Cooldowns`, auto-cleaned with
  `game.Debris:AddItem(cd, duration)`
- Builds an ad hoc `Info` table (`damage`, `physical`/`mana`, `aoe`, `move`, plus dozens of
  move-specific one-off flags) and either calls `HitDetection.magnitudeCheck`/`SMag` (AOE/cone
  targeting) or fires `ServerStorage.Requests.TagHumanoid` directly
- There is **no schema** for `Info` — whatever flag a move sets, `TagHumanoid.server.luau` must
  separately know to check for. Adding a new mechanical effect almost always means editing both
  the move script *and* `TagHumanoid.server.luau`.

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
  `Thunder Spear Crash`, `Dragon Awakening`, `Wing Soar`, `Spear Crusher`, plus procs in
  `TagHumanoid.server.luau` around the existing Storm Herald proc block).
- **Asset debt incurred**: `TheEmberWyrm`/`TheAbyssalWyrm` currently reuse existing generic
  effects (`ThunderZoom`, `LightningS`/`LightningP`, `DragonRoarQuiet`, `WingFlap`/`MegaFlap`)
  recolored via `.Color`/`Color3` where the property allows it, rather than bespoke assets like
  `StormHerald`'s `HeraldZoom`/`LightningHerald`. If dedicated sounds/meshes are wanted for these
  two paths, they need to be added in Studio and wired in by name — the code branches are already
  in place to swap them in.

## Refactor & cleanup priorities for future sessions

Ordered by risk-adjusted value — fix things that cause silent bugs before things that are just ugly.

1. **(High) Collapse the 4 duplicated class-data tables into one source of truth.** Right now a
   class change requires editing up to 4 files by hand, and they can silently drift (this is how
   `DragonBloodUpgrade` ended up half-wired). At minimum, make 3 of the 4 files `require()` a single
   shared module instead of hand-copying the table.
2. **(High) Give `Info` (the move → TagHumanoid contract) a real shape.** Even just a checked list of
   known flag names per category (damage-modifying, defense-bypassing, on-hit-proc) would catch
   typos like a flag being set in a move but never read in `TagHumanoid`, or vice versa.
3. **(Medium) Split `TagHumanoid.server.luau` and `CharacterHandler/init.server.luau`.** Both are
   several-thousand-line single files mixing unrelated concerns (damage resolution, every passive
   proc, every path's on-hit effect, boosts, curses, life steal, etc. all in one `TagHumanoid` file;
   class grants, boosts, weapon logic, path VFX in one `CharacterHandler`). Splitting by concern
   (e.g. `TagHumanoid/Procs/<PathName>.luau`) would make future path/passive additions much lower-risk.
4. **(Medium) Extract the copy-pasted `ActionCheck()` guard** from every move script into a shared
   module. It's byte-for-byte identical in most files; a single edit (e.g. adding a new universal
   stun state) currently requires touching every move.
5. **(Low) Sweep deprecated `wait()` → `task.wait()`** and clean up the large number of unused-local
   hints (`canuse`, `p2`, `TweenService`, etc.) flagged across move scripts — cosmetic, but cheap to
   batch once other structural work touches these files anyway.
6. **(Low) No automated tests exist.** Given the amount of cross-file coordination the class/path
   systems require (4 files for a class, 3+ files for a path), even a lightweight script that
   diffs the 4 class-data tables for drift would catch the exact class of bug fixed this session.

Do not attempt items 1-3 opportunistically inside unrelated feature work — they touch enough
surface area (dialogue engine, damage resolution) that they deserve their own dedicated session
with the user's sign-off on approach first.
