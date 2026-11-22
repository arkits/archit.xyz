+++
title = "Historian: Actually Search Your Browser History"
date = "2026-02-02"
author = "Archit"
description = "Historian turns your browser history into a searchable, local database with full-text search, entity extraction, and SQL queries."
tags = ["local-first", "productivity", "browser", "search", "postgres"]
+++

Your browser history knows more about you than most of your apps combined. Every article you read, every docs page you visited at 2 AM, every Stack Overflow tab you left open for three weeks — it's all in there.

But good luck finding any of it. Standard browser history search is basically useless. You get titles and URLs, that's it. Goodbye to finding that blog post you read last month if you don't remember the exact title.

Historian fixes this. It treats your history like the valuable dataset it actually is, and gives you proper search tools to dig through it.

## The Problem: Your History Is There, But Useless

Browser history is stored in a SQLite database you never touch. Want to search the actual *content* of pages you visited? Nope. Want to find "that article about Postgres indexing I read sometime last year"? Good luck.

The data exists. You're just not allowed to use it properly.

## The Solution: Just Make It Local

Historian runs entirely on your machine. No cloud service, no accounts, no "we value your privacy" while they mine your data. It even bundles its own Postgres database so you don't need to mess with Docker or setup.

Your history stays yours. Novel concept.

## What You Can Actually Do

Historian is a query engine for your personal web archive. Here's what that means:

### 1) Search Page Contents

Most tools only index titles. Historian grabs the actual page content so you can search for what you *read*, not just what the tab was called.

### 2) Find Things By Entity

The system pulls out people, places, organizations, topics — then indexes those too. Search for "Kubernetes" and get everything you've read about it, even if the word "Kubernetes" wasn't in the title.

### 3) Filter By Metadata

Domain, time range, visit count — slice your history however you want.

### 4) Write Actual SQL

If you're the type who thinks "I could write a query for that," Historian gives you a SQL playground. Ask complex questions. Join things. Go wild.

### 5) Clean Up Safely

Sometimes you want to delete history without the risk of corrupting your browser's database. Historian handles that too.

## Importing Is Actually Easy

Every browser stores history differently. Historian handles this with custom importers — one-time setup, then you're done. It supports Chrome, Firefox, Safari, and Edge out of the box.

## Who's This For?

- Developers who fall down research rabbit holes and need to find their way back
- Writers collecting sources and references
- Anyone who wants a searchable archive of what they've learned
- People who just really like having control over their own data

## The Bottom Line

Historian proves that local-first software doesn't have to feel limiting. You keep your data, you get real search power, and you don't need to run a server farm to make it work.

If you've ever wished your browser history was actually useful, this is the tool that makes it happen.
