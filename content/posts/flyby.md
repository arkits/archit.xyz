---
title: "FLYBY2: Resurrecting a 90s Screensaver with AI and React"
date: "2025-12-10"
description: "How I used AI tools to port 30-year-old C code into a modern web screensaver — and why 'vibe coding' actually works."
tags: ["react", "three.js", "screensaver", "vibe-coding", "retro"]
---

There's something about 90s screensavers. Before computers had reliable power management, we needed them to prevent burn-in. But developers turned that limitation into art. Mystify. 3D Pipes. And of course, FLYBY2.

FLYBY2 was mesmerizing — aircraft looping and rolling over a wireframe landscape. Originally written by Soji Yamakawa in the mid-90s (who later created YS Flight), it was even found on old Lockheed Martin machines. It was simple, elegant, and hypnotic.

Fast forward 30 years. The source code was open-sourced in 2022, but good luck running a Windows 95 screensaver today. I wanted to bring it back.

## The Original

FLYBY2 was written in C, targeting Windows and the FM Towns (a Japanese computer from the 90s). It had:

- Custom aircraft models in a proprietary SRF format
- Procedurally generated flight paths with loops and barrel rolls
- That distinctive blue-grid aesthetic
- Multiple aircraft: F-16, F-18, F-15, F-14, Su-27, MiG-21

The flight math was surprisingly elegant. Instead of complex physics simulation, it used a step-based system: "go forward," "pitch up," "bank left," "turn right." String those together and you get aerial choreography.

## The Plan

Rebuild it for the web. But I didn't want to manually port 30-year-old C code line by line. Life's too short.

Enter AI.

## The Stack

Pretty standard modern web stuff:

- **React 19** for UI
- **TypeScript** because types prevent headaches
- **Three.js** via **React Three Fiber** for 3D
- **Vite** for fast builds
- **CSS Modules** for that retro look

But the interesting part isn't the stack — it's how AI handled the translation.

## Vibe Coding: AI as Pair Programmer

You've probably heard the term "vibe coding" — basically, letting AI handle the tedious stuff while you focus on the fun parts. That's exactly what this project was.

I wasn't writing code so much as directing an AI pair programmer who happens to know C, TypeScript, 3D graphics, and vintage file formats.

### The SRF Parser

The aircraft models used a custom binary format. Writing a parser from scratch means dealing with:
- Binary struct layouts
- 15-bit color encoding (GRB555 format)
- Byte alignment issues

I pasted the original C structs into Claude and asked: "Convert this to TypeScript and handle the 15-bit color."

It immediately understood the GRB555 format — green in the high bits, not red — and generated the bit-shifting:

```typescript
// AI nailed the bit shifting for GRB555
const r = (color15 >> 10) & 0x1f;
const g = (color15 >> 5) & 0x1f;
const b = color15 & 0x1f;

// Convert to 0-1 range for Three.js
return new THREE.Color(r / 31, g / 31, b / 31);
```

I didn't spend two hours debugging hex codes. I verified the output worked, saw the planes render, and moved on.

### The Flight Math

The original used a 16-bit angle system where `0x10000` = full circle. When I asked about converting to radians, the AI suggested keeping the original constants.

Smart move. We preserved:
- `PITCH_RATE = 8192` per second
- `BANK_RATE = 32768` per second

These "magic numbers" weren't arbitrary — they defined how the aircraft *felt*. Change them and it's not FLYBY2 anymore.

### The CRT Look

The original had blue grid lines and simple geometry. I wanted to keep that but add a CRT monitor effect.

I described the vibe: "Green scanlines, slight chromatic aberration, vignette, like a 90s high-tech display."

The AI generated the post-processing shaders. Took seconds, looked perfect.

## What The Rebuild Actually Does

### Dynamic Camera

The camera positions itself randomly around the action at each maneuver change. Presets for ground level, flight level, and aerial view. Mouse wheel controls zoom from 3° to 90° FOV.

### Telemetry Panel

Real-time altitude, speed, heading, pitch/bank angles, and maneuver progress. Used a ref + `requestAnimationFrame` instead of React state to avoid re-rendering every frame.

### Smoke Trails

Aircraft emit smoke during maneuvers using ribbon trails — triangle strips that fade in alpha and shrink as they age.

## What I Learned

1. **AI is incredible at syntax translation** — C to TypeScript, weird binary formats to parsers. Focus on architecture, let AI handle the translation.

2. **Don't fix the magic numbers** — Those weird constants in old code often exist for good reasons. Port them verbatim first, adjust later if needed.

3. **Ship the vibe first** — Get the feeling right, then optimize.

4. **Preserve the essence** — A flight sim should *feel* like flying, regardless of the tech stack.

## Try It

No need to compile ancient C code.

**[🚀 Live Demo](https://flyby.vercel.app)**

Or run it locally:

```bash
git clone https://github.com/arkits/flyby2.git
cd flyby2
npm install
npm run dev
```

Open `http://localhost:5173`. Press `D` for debug controls, pick an aircraft, choose a maneuver, and watch it fly.

## Why This Matters

FLYBY2 is a reminder that software can be joyful. That code can be about wonder — about making things fly across a screen just because it's cool.

"Vibe coding" isn't about being sloppy. It's about being smart with your energy. Using the best tools available to capture the spirit of something, without getting bogged down in the grunt work.

The next time you're facing a legacy migration, try it. Paste that old code into an LLM. Ask it to help you fly. You might be surprised what takes off.

---

_FLYBY2 is [open source](https://github.com/arkits/flyby2). The original C implementation by Soji Yamakawa is also available for anyone who wants to explore the vintage code._
