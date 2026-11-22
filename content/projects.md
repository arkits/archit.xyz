---
title: "Stuff that I've worked on"
layout: "projects"
intro: "Things I've built across web, games, tooling, and data visualization. Most started because something annoyed me or looked fun to take apart."
projects:
  - name: "tagore"
    year: "2026"
    status: "wip"
    tagline: "Self-hosted AI co-author for long-form fiction."
    description: "A manuscript editor where the agent edits through tracked suggestions instead of a chat window. You accept or reject each change, from a single word up to a whole chapter."
    highlights:
      - "Block-level diff editing: every change is validated against the saved chapter before it shows up as a suggestion."
      - "Layered, token-budgeted context (story bible, characters, lorebook) keeps long stories consistent."
    tech: ["TypeScript", "Bun", "tRPC", "React", "SQLite", "TipTap"]
    links:
      - label: "github"
        url: "https://github.com/arkits/tagore"
  - name: "road-rash"
    year: "2026"
    tagline: "Native C++/SDL3 port of the 1996 Windows Road Rash."
    description: "Runs the game natively on macOS, Linux, Windows, Android, and in the browser via WebAssembly, with no emulation at runtime. Includes online multiplayer for two to eight riders."
    highlights:
      - "Simulation matches the original tick for tick in recorded races."
      - "All 223 original menu items pass the layout sweep; most captured screens match pixel for pixel."
    tech: ["C++20", "SDL3", "WebAssembly"]
    links:
      - label: "play"
        url: "https://road-rash.archit.xyz/"
      - label: "github"
        url: "https://github.com/arkits/road-rash"
  - name: "carrom"
    year: "2026"
    tagline: "3D carrom in the browser."
    description: "Human vs. bot under simplified ICF singles rules, with deterministic physics, procedural PBR materials, and synthesized audio."
    highlights:
      - "Pure TypeScript physics engine: the same board and shot always produce the same frame trace."
      - "Bot runs a seeded rollout search on the real engine inside a Web Worker."
    tech: ["TypeScript", "React Three Fiber", "Zustand", "Web Audio"]
    links:
      - label: "play"
        url: "https://carrom.archit.xyz"
      - label: "github"
        url: "https://github.com/arkits/carrom"
  - name: "ludo"
    year: "2025"
    tagline: "Real-time multiplayer Ludo."
    description: "Room-based games for two to four players with password-protected rooms, anonymous nicknames, and classic rules."
    tech: ["TypeScript", "React", "Convex"]
    links:
      - label: "play"
        url: "https://ludo.archit.xyz"
      - label: "github"
        url: "https://github.com/arkits/ludo"
  - name: "next-bart"
    year: "2023"
    tagline: "When's the next train?"
    description: "Shows the next BART service between two stations you pick, built on BART's GTFS realtime feeds."
    tech: ["TypeScript", "Next.js", "GTFS-RT"]
    links:
      - label: "live"
        url: "https://next-bart.vercel.app/"
      - label: "github"
        url: "https://github.com/arkits/next-bart"
  - name: "flyby"
    year: "2022"
    tagline: "The FLYBY2 screensaver, rebuilt for the web."
    description: "A TypeScript/WebGPU reimplementation of Soji Yamakawa's 90s Windows screensaver, aiming for behavior parity with the original C code, plus free-flight and drive sandbox modes."
    tech: ["TypeScript", "WebGPU", "Bun"]
    links:
      - label: "live"
        url: "https://flyby.archit.xyz/"
      - label: "github"
        url: "https://github.com/arkits/flyby"
      - label: "blog post"
        url: "/posts/flyby"
  - name: "spring-boot-actuator-cli"
    year: "2021"
    tagline: "CLI companion for Spring Boot Actuator."
    description: "A command-line app that inspects Actuator endpoints and prints data in human-friendly formats for debugging and operations."
    image: "/img/sba-cli.png"
    image_alt: "spring-boot-actuator-cli output"
    highlights:
      - "Designed parsers for multiple Actuator endpoints."
      - "Added config file support for multi-service fleets."
    tech: ["Go", "Java", "Spring Boot"]
    links:
      - label: "github"
        url: "https://github.com/arkits/spring-boot-actuator-cli"
      - label: "blog post"
        url: "/posts/sba-cli"
  - name: "onhub-web"
    year: "2021"
    tagline: "Home network dashboard for Google OnHub and Google Wifi."
    description: "A web client that pulls metrics from the Google Foyer APIs and turns them into a responsive UI plus Prometheus and Grafana integrations."
    image: "/img/ohw-web-ui.png"
    image_alt: "onhub-web dashboard"
    highlights:
      - "Built a metrics pipeline to surface device health and performance."
      - "Shipped a clean UI for monitoring home network devices."
    tech: ["Go", "React", "Prometheus", "Grafana"]
    links:
      - label: "github"
        url: "https://github.com/arkits/onhub-web"
      - label: "blog post"
        url: "/posts/onhub-web"
  - name: "historian"
    year: "2020"
    tagline: "Search your browser history properly."
    description: "Turns browser history into a local, searchable database with full-text search, entity extraction, and SQL queries."
    tech: ["TypeScript", "Bun", "React", "tRPC", "PostgreSQL"]
    links:
      - label: "live"
        url: "https://historian.archit.xyz/"
      - label: "github"
        url: "https://github.com/arkits/historian"
      - label: "blog post"
        url: "/posts/historian"
  - name: "exige"
    year: "2020"
    tagline: "UAM traffic visualizer."
    description: "A proof-of-concept visualizer for UAM and UTM data streams with live mapping and event overlays."
    image: "/img/exige.png"
    image_alt: "Exige map visualization"
    tech: ["JavaScript", "React", "Mapbox", "Socket.IO"]
    links:
      - label: "live"
        url: "https://arkits.github.io/exige"
      - label: "github"
        url: "https://github.com/arkits/exige"
  - name: "chaddi-tg"
    year: "2019"
    tagline: "Telegram bot for games, economy, and community."
    description: "Handles chat onboarding and adds mini games, a lightweight economy, and a pile of silly commands to keep group chats lively."
    tech: ["Python", "tdlib"]
    links:
      - label: "telegram"
        url: "https://t.me/chaddibot"
      - label: "github"
        url: "https://github.com/arkits/chaddi-tg"
      - label: "blog post"
        url: "/posts/chaddi-tg"
  - name: "newtab"
    year: "2015"
    tagline: "Personal new tab dashboard."
    description: "A configurable start page that surfaces news, now-playing music, and shortcuts to daily tools."
    image: "/img/newtab.png"
    image_alt: "newtab dashboard"
    tech: ["JavaScript"]
    links:
      - label: "live"
        url: "https://newtab.archit.xyz/"
      - label: "github"
        url: "https://github.com/arkits/newtab"
---
