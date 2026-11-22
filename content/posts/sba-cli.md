+++
title = "Building a CLI for Spring Boot Actuator: Lessons Learned"
date = "2021-08-04"
author = "Archit"
cover = "/img/sba-cli.png"
description = "Building Go-based CLI tooling to interact with Spring Boot Actuator across microservices — and all the messy details that come with it."
+++

Building applications is only half the battle. The real fun starts when you deploy to production and suddenly need to figure out what's happening in there.

Which version is running? Why is this service slow? Can I change this config without restarting everything? These questions come up constantly, and if you're supporting multiple services across multiple environments, finding answers becomes a chore.

Most teams eventually build custom tooling for this. It's almost a rite of passage. After building a few of these tools, I wanted to write down what I learned.

## What Even Is Spring Boot Actuator?

If you've worked with Spring Boot, you know [Actuator](https://spring.io/projects/spring-boot). It exposes REST endpoints at `/actuator` that let you inspect and manage running applications.

```json
// GET /actuator
{
    "_links": {
        "beans": { "href": "http://localhost:8080/actuator/beans" },
        "env": { "href": "http://localhost:8080/actuator/env" },
        "health": { "href": "http://localhost:8080/actuator/health" },
        "logfile": { "href": "http://localhost:8080/actuator/logfile" },
        "prometheus": { "href": "http://localhost:8080/actuator/prometheus" }
    }
}
```

It's incredibly useful:
- `/health` — is the app alive?
- `/env` — change configs on the fly
- `/threaddump` — debug performance issues
- `/loggers` — toggle debug logging without restart

The problem? Actuator is just an interface. You still need a good client to actually use it.

## The Messy Reality

At my previous job, I was supporting about 12 Spring applications across three teams. Dev, QA, and Prod environments. During incidents, just checking which services were healthy meant juggling URLs, auth headers, and curl commands.

I watched coworkers wrestle with bash scripts and jq queries just to parse JSON responses. As we added more services, this approach fell apart.

Existing tools like Postman or Insomnia didn't quite fit. I needed something that was:
1. Easy to set up
2. Smart about parsing responses
3. Secure with credentials
4. Scriptable for automation

## Building sba-cli

So I built [spring-boot-actuator-cli](https://github.com/arkits/spring-boot-actuator-cli) — a CLI that makes Actuator actually usable.

Basic usage looks like this:

```bash
$ ./sba-cli health -U http://localhost:8080
┌─────────────────┐
│      HEALTH     │
├────────┬────────┤
│ status │ UP     │
└────────┴────────┘
```

No curl. No jq. Just readable output.

### Managing Multiple Services

The real power is the inventory system. You define your services in a `config.yaml`:

```yaml
inventory:
  - name: demo-service
    baseURL: http://localhost:8080
    skipVerifySSL: true
    tags: [demo, local]

  - name: auth-service-prod
    baseURL: https://auth-service-prod
    authorizationHeader: Basic YXJraXRzOmh1bnRlcjI=
    tags: [auth, prod]
```

Then target by name:

```bash
$ ./sba-cli info -S demo-service
>>> demo-service
┌─────────────────────────────┐
│        SERVICE INFO         │
├──────────────┬──────────────┤
│ title        │ demo-service │
└──────────────┴──────────────┘
┌────────────────────────────────────────────────────────────┐
│                          GIT INFO                          │
├─────────────────┬──────────────────────────────────────────┤
│ branch          │ main                                     │
│ commit.abbrev   │ c6c4cdb                                  │
└─────────────────┴──────────────────────────────────────────┘
```

### Bulk Operations

You can also query by tags. Check health across all prod services:

```bash
$ ./sba-cli health -T prod

>>> auth-service-prod
┌─────────────────┐
│      HEALTH     │
├────────┬────────┤
│ status │ DOWN   │
└────────┴────────┘

>>> demo-service-prod
┌─────────────────┐
│      HEALTH     │
├────────┬────────┤
│ status │ UP     │
└────────┴────────┘
```

The config file can live in git (even a private repo for sensitive URLs). When something changes, one person updates it, everyone pulls the latest.

## The Messy Technical Bits

### HTTP Is Never Simple

Corporate environments love making HTTP hard. Self-signed certs, proxy servers, weird auth headers. I wrapped all this in a `MakeHTTPCall` function that handles the complexity.

The CLI mirrors curl flags where it makes sense:

```bash
$ ./sba-cli health -h
Flags:
  -H, --auth-header string     Authorization Header
  -K, --skip-verify-ssl        Skip verification of SSL
  -S, --specific string        Name of a specific Inventory
  -U, --url string             URL of the target Spring Boot app
```

### Go and Dynamic JSON

Here's where it got annoying. Actuator responses are dynamic — `/env` returns keys you can't know at compile time.

Go is statically typed. It wants to know what it's unmarshaling. I ended up using the [dynamic-struct](https://github.com/Ompluscator/dynamic-struct) library, but the code isn't pretty:

```go
// Build dynamic struct from response
reader := MakeDynamicStructReader(ActuatorInfoProperties{}, actuatorResponse)

// Extract "Links" map and iterate
for _, link := range reader.GetField("Links").Interface().(map[string]interface{}) {
    var href string
    for v_k, v_v := range link.(map[string]interface{}) {
        if v_k == "href" {
            href = fmt.Sprintf("%v", v_v)
        }
    }
    t.AppendRow(table.Row{href, templated})
}
```

All those `interface{}` casts make my eyes hurt. I keep meaning to refactor this.

{{< image src="/img/sba-cli-health.png" alt="sba-cli-health" position="center" >}}

## Was It Worth It?

Building CLI tools is weirdly satisfying and incredibly frustrating. You spend way too long on edge cases and output formatting.

But watching teammates go from "ugh, I need to check the health of 5 services" to running one command? That's the good stuff. Less stress during incidents. Faster debugging. Actually useful tooling.

If you're supporting Spring Boot services and tired of curl-jq pipelines, give it a try.

*Thanks to @cyber_junkie for the feedback and testing* 🙏
