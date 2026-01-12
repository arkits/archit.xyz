---
title: "FLYBY2: Bringing a 90s Screensaver to the Modern Web"
date: "2025-12-10"
description: "How an AI-assisted rebuild transformed a vintage Windows 95 screensaver into an interactive web experience using React, Three.js, and a whole lot of vibes."
tags: ["react", "three.js", "screensaver", "vibe-coding", "retro"]
---

There's something magical about screen savers from the Windows 95 era. They represented a time when computers were becoming powerful enough to render complex 3D graphics in real-time, yet still simple enough that a single developer could build something remarkable from scratch.

FLYBY2 was exactly that—a mesmerizing screensaver showing aircraft performing aerial maneuvers over a stylized landscape. Originally developed in the 1990s by Soji Yamakawa (captainys on GitHub), who would later go on to create YS Flight, FLYBY2 captured the imagination of anyone who encountered it. The screensaver was even found on a "crusty old Windows 95 computer originally from Lockheed Martin," as noted by Lazy Game Reviews in their coverage of this forgotten piece of computing history.

This is the story of how FLYBY2 was resurrected using modern web technologies—and how using **AI tools to port 30-year-old C code** became a testament to what's possible when you embrace "vibe coding."

## The Original: A Labor of Love

The original FLYBY2 was written in C, targeting both Windows and the FM Towns OS. It featured:

- Custom aircraft models in a proprietary SRF format
- Procedurally generated flight paths with loops, barrel rolls, and figure-8s
- A distinct visual style with blue grid lines and simple geometry
- Multiple aircraft models including the F-16, F-18, F-15, F-14, Su-27, and MiG-21

What made FLYBY2 special wasn't just its visuals—it was the elegant simplicity of its flight mathematics. The code used a clever step-based maneuver system where aircraft would execute a series of "ahead," "pitch," "bank," and "turn" commands to create complex aerial choreography.

## The Rebuild: Why Modernize?

The original FLYBY2 source code was recovered from backups and released as open source in 2022. But running a Windows 95 screensaver in 2025 is impractical. The question became: how do we preserve this piece of computing history while making it accessible to a new generation?

The answer was clear—build a web version.

## The Stack: Modern Tools for a Retro Project

The rebuild chose a stack that balances modern development practices with the kind of simplicity that made the original special:

- **React 19** for the UI and component structure
- **TypeScript** for type safety (because we're not animals)
- **Three.js** via **React Three Fiber** for 3D rendering
- **Vite** for lightning-fast development and builds
- **CSS Modules** for that cyberpunk aesthetic

But the real story isn't about the tools—it's about how they were used.

## Vibe Coding: AI as the Copilot

"Build fast, ask questions later" might not be in any official software development methodology, but with modern AI tools, it should be.

The FLYBY2 rebuild embraced **vibe coding**—specifically, using LLMs (like Claude and ChatGPT) to handle the heavy lifting of translation so I could focus on the aesthetic and the "feel." I wasn't just writing code; I was directing a senior engineer who happened to be an AI.

Here is how the AI-first approach manifested:

### 1. The SRF Parser: From C Structs to Interfaces

The original aircraft models used a custom format called SRF. Manually rewriting a C binary parser into TypeScript is tedious and error-prone.

Instead, I pasted the original C structs into the LLM and asked: _"Act as a graphics engineer. Convert this C struct to a TypeScript interface and write a parser for the 15-bit color encoding."_

It immediately recognized the 15-bit GRB555 format (where Green is the high bit, not Red) and spit out the bit-shifting logic:

```typescript
// The AI correctly identified the bit shifting required for GRB555
const r = (color15 >> 10) & 0x1f;
const g = (color15 >> 5) & 0x1f;
const b = color15 & 0x1f;

// Normalize to 0-1 range for Three.js
return new THREE.Color(r / 31, g / 31, b / 31);
```

This is the essence of vibe coding: I didn't need to spend two hours debugging hex codes. I just verified the output, saw the planes render correctly, and moved on.

### 2. Flight Controller: Porting the Magic Numbers

The original FLYBY used a 16-bit angle system where `0x10000` equals a full circle. When I asked the AI to explain the movement logic, it suggested keeping the original constants rather than trying to convert everything to standard radians immediately.

We kept the "magic numbers" verbatim:

- `PITCH_RATE = 8192` (per second)
- `BANK_RATE = 32768` (per second)

This preserved the _physics_ of the original. An aircraft that banks too slowly or turns too quickly wouldn't be FLYBY2.

### 3. Visuals: Cyberpunk Aesthetics

The original FLYBY2 had a distinct look: blue grid lines and simple geometry. I wanted to enhance this with a "CRT Monitor" feel without rewriting a custom shader from scratch.

I described the vibe to the AI: _"Give me a React Three Fiber setup that looks like a high-tech 90s CRT monitor. Green scanlines, slight chromatic aberration, and a vignette."_

It generated the post-processing configuration in seconds.

## Key Features of the Modern Build

### Dynamic Camera System

The camera doesn't just sit in one place. It randomly positions itself around the action at each maneuver change, with presets for low (ground level), medium (flight level), and high (aerial view). Zoom is controllable via mouse wheel, with a range from tight 3° FOV to wide 90°.

### Real-Time Telemetry Panel

Because what's a flight sim without telemetry? The panel displays altitude, speed, heading, pitch/bank angles, and the current maneuver progress.

The telemetry uses a clever optimization: instead of React state updates (which would trigger re-renders every frame), it uses a mutable ref and `requestAnimationFrame` to update the DOM directly.

### Smoke and Vapor Trails

Aircraft emit smoke during pitch, bank, and turn maneuvers using a ribbon-based trail system. The implementation creates triangle strips that fade in alpha over their lifetime and decrease in width as they age.

## Lessons from the Rebuild

The FLYBY2 project demonstrates several principles that apply beyond this specific project:

1. **Use AI to bridge the syntax gap:** LLMs are incredible at translating logic between languages (C to TS), allowing you to focus on the architecture.
2. **Port the magic numbers:** Sometimes the specific constants in old code exist for good reasons. Don't "fix" them until you see them running.
3. **Ship the vibe first:** Get the feeling right before perfecting the implementation.
4. **Preserve the essence:** A flight sim should _feel_ like a flight sim, regardless of the platform.

## Running FLYBY2 Today

You don't need to compile C code to see it fly anymore.

**[🚀 View the Live Demo Here](https://flyby.vercel.app)**

If you want to poke around the code or run it locally:

```bash
git clone https://github.com/arkits/flyby2.git
cd flyby2
npm install
npm run dev

```

Then open your browser to `http://localhost:5173`. Press `D` to toggle the debug controls, pick your aircraft, choose your maneuver, and watch the sky.

## Conclusion

FLYBY2 represents something we sometimes forget in modern software development: that code can be joyful. It can be an expression of wonder at the possibility of making things fly across a screen.

The vibe coding approach isn't about being careless—it's about being intentional with your energy. It's about recognizing that sometimes the best way to honor the past is to build something new that captures its spirit, using the smartest tools available to get you there.

So the next time you find yourself stuck on a legacy migration, remember FLYBY2. Paste that C code into an LLM, ask it to help you fly, and let the aircraft do the talking.

---

_FLYBY2 is open source and available on GitHub. The original C implementation by Soji Yamakawa is also available for those who want to explore the vintage code._
