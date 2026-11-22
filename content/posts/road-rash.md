+++
title = "Road Rash: Six Weeks, Five Agents, One 1996 EXE"
date = "2026-11-22"
author = "Archit"
description = "A dev log of porting the Windows 95 Road Rash to native C++ on macOS, Android, Linux, Windows and the browser, mostly by directing a crowd of AI coding agents."
tags = ["road-rash", "reverse-engineering", "c++", "sdl3", "webassembly", "ai-agents", "retro", "dev-log"]
+++

On September 28 I typed this into Codex:

> I have Road Rash 1997 Windows in this folder. Can you decompile and recompile it to run on a modern macOS machine?

Codex replied with a reasonable answer. It said the EXE was stripped 32-bit x86, there was no source, it leaned on DirectDraw and DirectSound, a native port would need serious reverse engineering, and I should probably try Wine.

My next message, the following evening:

> No wine! I want native port for macos and android. BEGIN WORK

Six weeks and 704 commits later, [arkits/road-rash](https://github.com/arkits/road-rash) is a C++20 / SDL3 port of the 1996 Windows rerelease. It has the full front end, careers, shop and saves, all five courses, the AI field, combat, traffic, pedestrians, cops, music and cutscenes. It runs on macOS, Android, Linux, Steam Deck, Windows and in the browser at [road-rash.archit.xyz](https://road-rash.archit.xyz). There's online mano-a-mano for up to eight players. A 2400-tick Napa race with all 14 riders matches the original game tick for tick.

I wrote very little of the code. This post covers what I did do: steer five different AI agents, yell at them, clean up after them, and watch them solve problems I wouldn't have known how to start on.

## The cast

- **Codex** started it and came back over and over. 57 sessions on this project.
- **OMP** was the main development client for most of October. It ran Meta's Muse Spark models through the OpenCode provider and did the long autonomous grinds with lots of subagents.
- **Claude Code** handled 49 sessions: reviews, plans, the Windows/Linux work, the frontend pixel work, multiplayer, and most of the "why does this look broken" debugging.
- **Muse Code** took over the police work around October 18, and came back in November for simulation parity.
- **OpenCode** and **Gemini** show up in the git history (a fuzzing fix, a docs commit, and one memorable `git reset`) but left no conversations I could recover. Pi never touched it.

The prompt I pasted most often was this one, verbatim, into every one of them:

```
Review plans from native-port/docs, recent commits and continue work.

Notes -
- Follow the plan close.
- Ensure build passes before committing.
- Use npx rea-agents for reverse engineering.
- Use rg and fd
- Use LSP
- Do NOT ask any questions. Work completely autonomously until manually stopped
- Commit and push to main as you progress
- DO NOT STOP UNTIL YOU ARE MANUAL TOLD
```

That last line is a typo I never fixed, and it turned out to be the most important instruction.

## Week 1: a playable Napa in a day

The first session went further than I expected. By the end of September 29 Codex had decompiled 1,585 functions into research pseudocode, verified 429 resource entries across 13 game files, built a macOS viewer that showed the original menus and scenery, and installed an APK on my Android device. That evening it ported the bike physics (throttle, brake, steering, gears, traction), movement along the course, a chase camera, and a playable single race on Napa.

Over October 1 and 2 it added sprites with per-rider colour remaps, seven AI opponents with their original personalities and rubber-banding, rider contact, and combat with punches, kicks, weapons and knock-offs. It also brought up the front end from the EXE's own menu tables, the disc's TrueType fonts, career saves, audio and video playback.

The key decision of that week was the **oracle**. A port can look right and still be wrong in a hundred subtle ways, so the agents built a way to ask the original game what it would do.

Road Rash statically imports one function from `AWEMAN32.DLL`, the Sound Blaster AWE32 driver. The oracle is a fake `AWEMAN32.DLL`. It forwards that one import to the renamed real driver. On load it patches `call` instructions inside the running EXE so they jump into dump hooks:

```c
/* Verify an E8 rel32 call at site targeting expected_target, then redirect it to hook. */
static int rr_patch_bytes(uint8_t* site, uint32_t expected_target, void* hook) {
    int32_t rel;
    if (site[0] != 0xE8) return 0;
    memcpy(&rel, site + 1, 4);
    if ((uint32_t)((uintptr_t)(site + 5) + rel) != expected_target) return 0;
    rel = (int32_t)((uintptr_t)hook - (uintptr_t)(site + 5));
    memcpy(site + 1, &rel, 4);
    return 1;
}
```

Run the unmodified EXE under Wine with that DLL and you get per-tick dumps of the simulation: every rider's position, velocity, animation, RNG state, scheduler ring and draw list. The native port replays the same inputs and compares field by field. So yes, I said "No Wine!", and Wine ended up as the test rig. It never runs at game time, though.

## Week 2: too many agents, one `main` branch

On October 11 I moved OMP in as the main client with: "Port Road Rash to natively run on macOS and Android. Focus on porting first level of the game with complete traffic, physics and AI. Need as close to original as possible." Then I mostly typed "continue".

October 12 had 164 commits. A lot of them look like this:

```
docs: REA-confirmed AI state step 0x00408ad0 + reset 0x00408df0 (plan 10 Task 6 port input)
docs: REA-confirmed police chain 0x00406b80/0x00407860/0x00407f30 (plan 11 Task 6 port input)
docs: REA-confirmed MIDI volume/teardown ... via parallel subagents, chain complete
```

`rea-agents` is a decompiler front end the agents could call from the shell. The workflow became: one agent ports a function from pseudocode, another independently re-decompiles the same address and confirms the pseudocode is whitespace-identical, and only then does the port count as "input". It's slow and boring, and it caught real mislabels. One function a scout called an "audio path resolver" turned out to be a serial-port session constructor.

It also got chaotic. I had Codex, Claude, OMP and OpenCode all working in the same checkout, all told to commit and push to `main`. Things broke in ways I hadn't thought about:

- Agents ran `git add` on their own paths, and another agent's pre-staged files rode along into the commit.
- On October 14 an OpenCode session tried to undo a bad commit with `git reset HEAD~1`. A Codex worker had committed in the four minutes since, so the reset orphaned Codex's commit. The agent noticed, stopped touching git, and wrote an 82-line incident report with reflog evidence proving nothing was lost.
- On October 18 Muse staged only its own hunks with `git add -p` so it wouldn't commit another session's edits. It misplaced three blocks and left `race.cpp` uncompilable on `main`.

So I asked Codex to review every AI session on the project and propose fixes. It read 18 conversations, then 53 on a second pass. The result was the `AGENTS.md` that runs the repo now: a worktree and a separate build directory per worker, explicit file ownership claims, verification gates, capture receipts, build provenance, and a handoff doc at the end of every session. There are 389 of those handoffs in `docs/agent-handoffs/` now. They're the only reason a cold agent could pick up where another left off.

The oracle went down that same week. Every capture died after two frames with a Wine page fault, and it took two separate diagnoses to fix. First, a `g_race_started` flag in the proxy got set on the first menu entry and never cleared, so the dump kept writing menu-background ticks after an abandoned race. Then the real killer: the proxy's billboard hook wasn't forwarding correctly, and actor records overflowed into the game's own frame globals. A Codex worker caught `g_frame` going *backwards* inside a single frame. The fix capped actor records at 512 with a reset every present.

## How far along are we?

On October 14 I asked Claude how much was done. It said about 55% by features, 15 to 20% by proven fidelity. Codex said 65% the next day. The more useful part of Claude's review was this:

> Most important: the game races with different code than the tests check.

There were three separate places that built a race: the game, the soak test and the oracle replay. Only the test paths had the AI personality tables, the attack timing data, nitro, the track ring and the original finish line. In the game I was actually playing, AI opponents never overtook. That explained my first playtest complaint, where the AI riders had "pulled over to the side". Plan 26 merged everything into one race factory. OMP did it and Claude reviewed it, and the review caught OMP's regression: career races now ignored the bike you'd bought in the shop.

That reviewer/implementer split ended up being the pattern I liked best. One autonomous agent grinds. A second one, with no stake in the code, reads the diffs.

## Chasing ticks

The fidelity goal was simple to state. Record a race in the original, replay the same inputs in the port, and match every compared field on every tick. Getting there was a sequence of "first divergence at tick N":

- **Tick 189.** The terrain walker's RNG draws weren't happening in the same order. Porting the live ring setup walks moved it to 371.
- **Tick 371.** A rider velocity mismatch. Ring-built terrain slices had to feed the physics ground. Now 702.
- **Tick 702.** An RNG divergence traced to solid roadside objects. The original sweeps every roadside box and billboard in the rider's slice against collision boxes copied from the sprite's *frame 2*, then runs the full bike contact handler. The mass products also have to wrap like x86 `imul`. After that, 1431/1431 on a human-driven capture.
- **Tick 713** on level 5. Codex found the crashed rider's body has a static collision callback the port skipped. The original calls `rand()`, gets 7071, and shifts the body by `7071 % 33 - 16 = -7` units. That one missing call explained the RNG offset, the animation mismatch and a seven-unit finish distance gap all at once.

My favourite was **tick 1995** on Napa level 5. A traffic car got removed in the original and not in the port, and the agents spent a whole day on it. The track ring spans exactly `0x8000` in Q8 fixed point, which is 128 samples. The hypothesis was that a car behind the camera reads a lane word from a slot indexed mod 128, so it sees a stale value written for a *different* sample further ahead. The agents predicted which sample each car would read, confirmed one with a probe (`route[287] = 512/512`, matching the observed flip), refuted a competing "newest in window" variant, and ported the slot rule. L5 went green. The original was reading stale memory and the port now reads the same stale memory, on purpose.

Another one: police captures kept diverging between runs *of the original game*. The port can't match something that doesn't match itself. The cause was that the game seeds `rand()` from `time()` at launch, then uses it to jitter the speeds of spare rider rows 9 to 14 before the oracle's seed ever applies. The port now carries the CRT RNG state in the career and does the same jitter at all four call sites.

## Things that looked broken

**Pacific Highway black wedges.** On October 16 I sent Claude a screenshot of big black triangles beside the road. It first guessed a regression from the widescreen fix, and that guess was wrong. The real cause was that Pacific Highway starts in "mountain" terrain, a rock wall on one side and a cliff to the sea on the other. The port read that terrain type and simply never drew it. The next round of screenshots showed what it had first called "mountain sides at road splits" were actually tunnels, which it also had to port: an eight-sided arch with ceiling lights and a mouth trim. Then it built an `oracle-terrain` test that rebuilds the scene from each recorded camera position and checks that every road, wall, tunnel, water and rail piece matches the original in corners and texture. That test immediately caught two more bugs. One was that the port lit every fourth tunnel section, and in the 88 recorded sections the original never did.

**Widescreen.** Road slices and scenery were centred on different points in Hor+ widescreen, so objects drifted into the lane. Toggling back to 4:3 also didn't work, because there were two hidden widescreen settings.

**10 fps.** On October 25 I ran it with the enhanced visuals on and got about 10 fps. Claude found that `run-macos.sh` built Debug, which made the CPU renderer about 7x slower. On top of that, colour grading, bloom, motion blur, vignette and palette fades each ran single-threaded over every pixel, the grade table got rebuilt every frame, and the rasterizer gave each thread one horizontal strip, so the sky threads sat idle while the road threads worked. After the fixes it ran at 120 fps.

**The demo video.** I asked Codex for a two-minute in-engine gameplay video for Twitter. It made a nice one, and the autopilot punched continuously for two minutes at nobody. "why are you continuously punching in the video??? looks stupid!!" The fix was to attack only riders within reach.

**Smooth terrain.** On the web build Napa's hillsides looked streaky and speckled. Claude first told me it matched the original. I pushed back: "you agree that it looks broken in my screenshots, right??? can you fix the rendering? i dont care if its broken in the original game". So it painted the grass as one continuous ground-fixed texture. It was smoother, and it looked nothing like Road Rash. "i dont like this smooth texture change. IT NEEDS TO LOOK LIKE THE ORIGINAL!" Reverted. I contradicted myself inside one hour, and the agent just did both.

**Rider colours.** In the quick-race picker, every character rode in the same red and white. In the original, rider colours come from the *bike*, not the character. That's a nice detail I never knew.

## The browser

On October 25 I gave Codex a `/goal` to make the port run in the browser and deploy it to Vercel. Emscripten plus SDL3 got the actual game running quickly. Hosting was the problem. The game files come to 489.5 MB, 310 MB of that video, and that doesn't fit Vercel's hobby tier. So: "lets pivot. fuck vercel. i have a vps... it has dokku running on it." Twenty-five minutes later it was live at road-rash.archit.xyz with CI deploys, all 341 game files served and cached in the browser, and HTTPS.

Some things from that day:

- The first launcher design was, in my words, "absolutly garbage". It had slogans like "THE OPEN ROAD. IN YOUR BROWSER", a giant logo and a tiny game window. The redesign copied the original title screen instead.
- The fonts didn't match. Codex looked at the ISO and found the game's four fonts were plain TrueType files renamed to `.DLL`.
- After a deploy, the live site died with `LinkError: WebAssembly.instantiate(): Import #287 "a" "re": function import requires a callable`. A cached old JS loader was running against a new Wasm module. The fix fingerprints the JS and Wasm together and embeds the hashed Wasm filename in the loader before the loader itself gets hashed. CI now tests an upgrade from a poisoned, four-hour-cached old loader.
- I added Sentry and PostHog. The next morning Sentry showed real players hitting storage failures (private browsing), fullscreen APIs that threw, and false "unclean exit" reports across tabs.

I posted it. Users came back with two complaints: missing road pieces at intersections, and no way to hit other riders. I took the second one personally: "how dare you release that without the ability to hit your rivals." Player swing completion had a bug, and City had gaps where lane widths changed.

## Multiplayer

The original has mano-a-mano, a two-player mode over modem or serial cable. On October 26 I asked Claude to work out how it worked and plan a modern version over the internet. The design is deterministic rollback. Every client runs the full integer 60 Hz simulation, only 16-bit input words cross the network, and a small C++ server, `rr-netd`, seals one authoritative input timeline per race.

I briefly told it to rewrite the server in Rust, then twenty minutes later said never mind and switched back to C++. The plan doc has commits for both. Then came protocol codecs, per-seat track ring windows, per-seat traffic and police, race snapshots and a rollback core, clock sync, WebRTC data channels, and bots for testing.

The determinism matrix is the part I'm proudest of, and I didn't write a line of it. CI runs bots on macOS, Linux x86-64 and ARM64, Windows x64 and ARM64, and WebAssembly under Node. They all join one live room and finish a race with equal hashes.

A November review caught that the server's `/net/health` endpoint ran on the race-sealing thread and could block up to 200 ms per request, eight per loop. A few slow health checks could stall every race on the server for over a second. The fix moved it to a non-blocking responder.

## Windows, Linux, and an unsequenced `+`

Claude wrote plans 33a (Linux and Steam Deck) and 33b (Windows), then worked through them task by task. The best bug of the project came from the first cross-play run with real game data on Windows. Every compressed resource failed to unpack.

```cpp
const uint32_t dist = (uint32_t(in.decode(distance_code())) << extra) + in.get(extra) + 1;
```

The two operands of `+` are unsequenced in C++. Clang read the Huffman code first. MSVC called `get()` first and read the extra distance bits before the code they belong to. That's legal, and on MSVC it corrupted every packed file in the game. The fix is two statements. Without a determinism test spanning five platforms, it could have sat there for a long time.

## Pixel-exact menus and a sound card I don't own

By late October, Claude was chasing the last pixels on the menus. Menu pictures turned out to be RGB565, not 555, which the agents found by dumping the original's 64K colour lookup table live from the running game. Text needed glyphs that match Windows GDI hinting, so it pinned FreeType 2.13.3 to match Wine's rasterizer. The last mismatched pixels on several screens were the focus arrow, drawn in Wingdings, a Windows system font that isn't on the disc. 18 of 20 captured screens now match the original pixel for pixel.

Then race music. The songs are MIDI played through SoundFont banks made for the Sound Blaster AWE32's EMU8000 chip. Claude fixed real bugs. One attenuation misread had put every note 12.7 dB too quiet. It also wrote a voice engine and reverb and chorus buses. It kept calling the timbre "unmeasured", until I asked:

> what is AWE32 hardware?? do i have it?

I don't. Nobody with a Mac does. Wine has no EMU8000, so there's nothing original to compare against. It's the one part of the port where the agents openly said "this is our best guess" and labelled the code that way.

## What went wrong, overall

- **Shared `main` with autonomous agents** caused most of the pain. Orphaned commits, broken builds, files claimed by sessions that had died. Worktrees and ownership files fixed most of it, but only after I'd lost a few days.
- **Status drift.** Agents happily wrote "done" into docs. Plan checkboxes said 0 tasks finished on a plan with four committed tasks. An agent once recorded a "full ASan suite" pass that was really a focused subset, and a later agent corrected it in a commit literally titled `docs: correct ASan to focused-only, was never full suite`. Adversarial review sessions were the only thing that kept the docs honest.
- **Usage limits.** Several Claude sessions ended mid-task with "usage limit reached". The handoff docs are what made that survivable.
- **Me.** Contradictory instructions ("fix it even if the original is broken" / "make it look like the original"), Rust/C++ flip-flopping, and a lot of all-caps. The agents took it in stride, which says something about them, maybe less about me.

## What surprised me

The agents are very good at patient, boring, exact work. Bisecting a divergence across 2400 ticks, re-decompiling the same function twice to confirm it, writing an incident report instead of trying another `git reset`. Nobody does that work for a hobby port, which is why hobby ports usually aren't exact.

They're worse at taste. Every UI they designed on their own was bad. They also needed a human to say "this looks broken" before they'd question their own evidence.

The oracle is what made the rest work. Once an agent could ask the original game "what's the value at tick 1995", most arguments ended.

## Where it stands

From the README as of November 8:

- Napa level 1 with the full 14-rider field matches for 2400/2400 ticks, and a human-input run matches 1431/1431.
- Police pursuit, siren and arrest match tick for tick on the captured scenarios.
- All 223 original menu items pass the layout sweep. Seeded saves round-trip byte for byte.
- 134/134 tests pass on macOS and Linux with ASan/UBSan and TSan clean.
- About 92,000 lines of C and C++, 39 plan files, and 389 agent handoff docs.

Still open: simulation parity on other courses and levels, the AWE32 timbre, and real-hardware testing on Windows, Linux desktops and the Steam Deck.

Play it at **[road-rash.archit.xyz](https://road-rash.archit.xyz)**. The code is at [github.com/arkits/road-rash](https://github.com/arkits/road-rash).
