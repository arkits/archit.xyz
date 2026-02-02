+++
title = "onhub-web: A Local Dashboard for Google Wifi and OnHub"
date = "2026-02-02"
author = "Archit"
description = "onhub-web provides a local web UI and metrics pipeline to monitor Google Wifi and OnHub devices."
tags = ["networking", "observability", "prometheus", "grafana", "react", "golang"]
+++

Most home and small-office routers ship with apps that feel opaque. You can see a few devices, maybe reboot the network, but the data is locked inside a mobile UI.

onhub-web turns that data into a local dashboard and observability pipeline you control.

## The Big Idea

Google Wifi and OnHub devices expose internal APIs (the Google Foyer APIs) that contain a lot more information than the default apps surface. onhub-web talks to those APIs and makes the data accessible through a web UI and metrics.

In practice, that means a real dashboard for your network -- not just a glossy app screen.

## What the Dashboard Covers

The project surfaces the core parts of network health and device behavior:

- **Device health** so you can see status at a glance.
- **Overview and network pages** for high-level metrics.
- **Devices view** to list connected clients.
- **Queries history** for activity visibility.
- **Family pause and unpause controls** for managing access windows.

## Observability Built In

The UI is only half the story. onhub-web also provides a collector to feed metrics into Prometheus, with Grafana dashboards available for visualization.

That means you can track trends over time and integrate home network metrics with the rest of your monitoring stack.

## Why This Matters

onhub-web treats home networking like real infrastructure:

- Data is not trapped in a phone app.
- You get time series metrics, not just snapshots.
- Everything runs locally, which keeps private network data private.

## Closing Thoughts

onhub-web is a great example of applying software engineering discipline to the place you actually live and work. It brings observability to your network, turns black-box devices into measurable systems, and gives you a UI that respects power users.

If you have ever wished Google Wifi or OnHub felt more like a real piece of infrastructure, this project is the missing layer.
