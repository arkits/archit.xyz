+++
title = "Historian: A Local-First Search Engine for Your Browser History"
date = "2026-02-02"
author = "Archit"
description = "Historian turns your saved browser history into a local, searchable dataset with full-text, entity, and metadata search."
tags = ["local-first", "productivity", "browser", "search", "postgres"]
+++

Your browser history is a strangely valuable dataset. It tells a story about what you learned, what you shipped, and which tabs you never closed. But most history tools treat it as disposable: you can scroll, you can delete, and that is about it.

Historian flips that on its head. It treats your history like a dataset worth exploring -- privately, locally, and with the same rigor you would apply to application logs or analytics.

## The Problem: History Is Locked Away

Browser history typically lives in a database you never touch. You cannot:

- Search across page contents, not just titles.
- Ask questions like "show me all pages that mention X" or "every time I searched for Y in the last 12 months."
- Run custom queries against your own browsing data.

If the data exists, why not make it usable?

## The Approach: Local-First, Zero-Drama

Historian is built to be fully local. It does not require a hosted service or a cloud account. It also brings its own Postgres database, so you do not need to spin up Docker or manage a separate database instance.

That design choice matters. It keeps your browsing history on your machine and removes the operational overhead that would otherwise stop you from using the tool at all.

## What Historian Lets You Do

Historian is more than a log viewer. It is a query engine for your personal web archive.

### 1) Search By Page Contents

Most history tools index only titles and URLs. Historian indexes page contents so you can search for the actual text you read, even if the page title was vague.

### 2) Search By Entities

The system extracts and indexes entities -- people, places, and organizations -- so you can find everything you read about a topic without guessing exact keywords.

### 3) Search By Metadata

Looking for a page by domain, visit time window, or other metadata? That is supported too.

### 4) SQL Playground

If you are the kind of person who wants to ask more complicated questions, Historian exposes a SQL playground so you can query the data directly.

### 5) Delete With Intent

Sometimes you want to clean up. Historian allows deleting entries, which is safer than poking directly at browser storage.

## Importing History Without the Pain

Every browser stores history slightly differently. Historian tackles this with custom migrations per browser, so importing data is a one-time setup instead of a perpetual headache.

## Who This Is For

Historian is for anyone who wants to treat their browsing history as an asset:

- Engineers debugging research rabbit holes.
- Writers tracking what they have read.
- People who want a personal, local "knowledge trail" they control.

## Closing Thoughts

Historian is a reminder that local-first software can feel powerful, not limiting. You keep your data. You get real query power. And you do not have to run infrastructure to make it work.

If you have ever wished your browser history were more than a scrollable list, Historian is the tool that makes it useful.
