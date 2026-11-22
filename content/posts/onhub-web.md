+++
title = "onhub-web: Finally, a Real Dashboard for Google Wifi"
date = "2026-02-02"
author = "Archit"
description = "onhub-web gives you a local web dashboard and metrics for Google Wifi and OnHub devices."
tags = ["networking", "observability", "prometheus", "grafana", "react", "golang"]
+++

Google Wifi's official app is... fine. You can see your devices, run a speed test, reboot things when they break. But if you've ever wanted to actually *monitor* your network rather than just glance at it, you're out of luck.

That's where onhub-web comes in. It unlocks the data your Google Wifi and OnHub devices are already collecting and gives you a real dashboard and metrics pipeline.

## How It Works

These devices actually expose internal APIs (Google's Foyer APIs) with way more data than the mobile app shows you. onhub-web talks to those APIs directly and makes everything available through a web UI plus time-series metrics.

Think of it as turning your home router into actual infrastructure you can observe.

## What You Actually Get

The dashboard shows you the stuff you actually care about:

- **Device health** at a glance — see what's online, what's struggling, what's just given up
- **Network overview** with the metrics that matter
- **Connected devices list** — finally, an actual list you can search through
- **Query history** to see what's been happening on your network
- **Family controls** — pause and unpause internet access for specific devices

## Prometheus and Grafana, Because Of Course

The UI is nice, but the real power is the metrics pipeline. onhub-web includes a collector that feeds data into Prometheus, with pre-built Grafana dashboards ready to go.

Now you can see trends over time. Is your network slower in the evenings? Is one device going haywire? You'll actually know instead of guessing.

## Why I Built This

I got tired of treating my home network like a black box. If I'm going to have a "smart" router, I want to actually see what it's doing.

- No more data trapped in a phone app
- Real time-series metrics, not just snapshots
- Everything stays local — your network data stays yours

onhub-web brings software engineering rigor to the network you actually use every day. If you've ever wished Google Wifi felt more like real infrastructure, this is what you're looking for.
