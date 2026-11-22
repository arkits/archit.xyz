+++
title = "chaddi-tg: A Telegram Bot for Games, Economy, and Community"
date = "2026-02-02"
author = "Archit"
description = "chaddi-tg is a Telegram bot with chat onboarding, mini games, and a lightweight economy system."
tags = ["telegram", "bot", "python", "community", "tdlib"]
+++

The best group chats have a certain energy. New people wander in and actually stick around. Regulars have inside jokes. There's just enough going on that checking the chat feels rewarding, not like another notification to clear.

I built chaddi-tg to help create that kind of vibe. It's a Telegram bot that handles the boring stuff (welcoming people) while adding just enough fun stuff (games, fake money, dumb commands) to keep things interesting.

## What's Under the Hood

chaddi-tg runs on Telegram's `tdlib` with Redis keeping track of everything in real-time. It handles multiple chats without breaking a sweat.

## What It Actually Does

Rather than throwing every feature at the wall, I organized things into four areas that actually matter for group chats:

### 1) Making New People Feel Welcome

First impressions count. chaddi-tg greets newcomers automatically and helps them figure out the vibe. Less "who is this person?" awkwardness, more "oh cool, a new regular."

### 2) Fake Money, Real Engagement

There's a simple economy system because people love numbers going up:

- Earn coins just by being active
- Send money to friends (or enemies)
- Check who's richest (it's probably not you)

It's light enough that you can ignore it, but fun enough that you won't want to.

### 3) Actually Fun Commands

The bot has games and reactions that make sense in a group context:

- Quick games like tic-tac-toe when the chat goes quiet
- Commands like `/bully` or `/kudos` that create moments
- Responses that feel like they were written by a person, not a corporate bot

### 4) Random Useful Stuff

Some commands defy categorization. They're just... useful. Or funny. Sometimes both.

## The Point

chaddi-tg works because it doesn't try to do everything. It just handles the basics well and adds enough flavor that people want to participate.

If you're running a Telegram community and want something that feels alive rather than robotic, give it a shot.
