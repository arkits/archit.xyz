+++
title = "Custom Observability Tooling Sagas: Spring Boot Actuator CLI"
date = "2021-04-07"
author = "Archit"
cover = "/img/sba-cli.png"
description = "Exploring the nuances of building CLI tooling to interact and visualize a Spring Boot application's Actuator endpoint's data."
+++

## Preface

A substantial part of today's modern infrastructure involves delivering an _application_[^1]. The intention of this application maybe to serve a rendered page, REST API, WebSocket stream, message queue worker etc. In order to provide a _well-managed_[^2] application, teams often dive into building tools for gaining observability and insights into their applications. This blog series aims to capture the nuances of building such custom tooling.

## Spring Boot...?

In a _tiny_ nutshell, Spring Boot is a framework to build _applications_ in Java. Think Express in Node, Rails in Ruby, Django in Python (to an extent). The Spring project pieces together other popular Java projects into a palatable, yet solid experience. The Spring 'eco-system' provides answers for almost every possible type of integration - from Kafka to Kubernetes.

While Spring is a great solution for quickly standing-up applications, personally I've found it too be a bit to _magical_ in it's details and often requires some goofy workarounds if you don't happen to agree with the 'Spring way'. However, Spring's ease-of-use and relatively decent performance still keep a strong candidate to build applications.

## Spring Boot Actuator...?

Actuator is one such member of the previously mentioned Spring eco-system. Actuator is module that once _installed_ into a Spring application, exposes a variety of REST endpoints, which can be programmatically queried and interacted with in order to facilitate typical management related aspects of an application.

After setting it up, Actuator is available through the `/actuator` endpoint of your application; here's a sample...

```bash
$ curl -v localhost:8080/actuator
HTTP/1.1 200
Connection: keep-alive
Content-Type: application/vnd.spring-boot.actuator.v3+jsonF
Keep-Alive: timeout=60
Transfer-Encoding: chunked

{
    "_links": {
        "beans": {
            "href": "http://localhost:8080/actuator/beans",
            "templated": false
        },
        "env": {
            "href": "http://localhost:8080/actuator/env",
            "templated": false
        },
        "health": {
            "href": "http://localhost:8080/actuator/health",
            "templated": false
        },
        "logfile": {
            "href": "http://localhost:8080/actuator/logfile",
            "templated": false
        },
        "loggers": {
            "href": "http://localhost:8080/actuator/loggers",
            "templated": false
        },
        "prometheus": {
            "href": "http://localhost:8080/actuator/prometheus",
            "templated": false
        },
        "scheduledtasks": {
            "href": "http://localhost:8080/actuator/scheduledtasks",
            "templated": false
        },
        "shutdown": {
            "href": "http://localhost:8080/actuator/shutdown",
            "templated": false
        },
        "threaddump": {
            "href": "http://localhost:8080/actuator/threaddump",
            "templated": false
        }
    }
}
```

The `/actuator` endpoint acts a 'discovery' endpoint and lists the available 'Actuators'. Some of these actuators can be dead-simple read operations, such as the `/health` actuator which returns (you can guess)...

```bash
$ curl -v localhost:8080/actuator/health
HTTP/1.1 200
Connection: keep-alive
Content-Type: application/vnd.spring-boot.actuator.v3+json
Keep-Alive: timeout=60
Transfer-Encoding: chunked

{
    "status": "UP"
}
```

A notable aspect about the `/health` actuator, and to illustrate the value of Actuator in the Spring project - other components within your application can implement the [API for submitting custom health indicators](https://www.baeldung.com/spring-boot-health-indicators#customhealthindicators) to the `/health` actuator, which in turn would show up as the updated response for `/health`. Various other Spring Projects, such as the Spring Kafka and Spring Data JPA, already implement this API and make `/health` truly useful.

On the other hand, there are actuators with write operations, such as the `/env` actuator which let you mutate the application's env / config...

```bash
curl \
    -X POST \
    -d '{"name":"db_password", "value":"hunter2"}' \
    -H "Content-Type: application/json" \
    http://localhost:8080/actuator/env
```

This again, is another "standard" feature that most other frameworks don't tend to provide, leading teams to end up hacking together their own frankenstein implementations.

And `/env` isn't even scratching the surface...

- `/threaddump` is always handy when needed for that level of debugging
- `/loggers` allows you to mutate the logging level on a class-path level - thus letting you turn off those noisy debug statements in production
- there is `/beans` for the Bean enthusiasts (I don't need to explain you any further - you know who you are).
- There is also my personal favorite, `/logfile` which literally streams you your log file. All of these great endpoints surely make Actuator a great debug tool... right?

If you haven't figured out the problem with Actuator as a debug tool... well it's not - it's an interface - and just like any other interface, it needs a good client to drive it.

## Spring Boot Actuator CLI...!

My previous job involved supporting ~12 Backends applications written in Spring, and had to manage them between 3 independent teams' sprints. Naturally, things were breaking and Actuator was used quite often. However, interacting with those 12 Backends, multiplied by environments of dev/qa/prod, can be a massive chore. There were tools to help out in this space - REST clients such as Postman, Insomnia are the notable examples.

In early 2021, I spent some time building `spring-boot-actuator-cli` - a command-line application to interact and visualize a Spring Boot application's Actuator endpoint's data. Let me walk you through it!

Here's the most basic usage - hit the `/health` actuator of an application running on `http://localhost:8080` -

```bash
$ ./sba-cli health -U http://localhost:8080
┌─────────────────┐
│      HEALTH     │
├────────┬────────┤
│ status │ UP     │
└────────┴────────┘
```

With the arguments from the command, sba-cli figures out the right REST call to make, parses the response and prints it out - in a more human readable format.

### Inventory Management

Chances are that you are managing multiple micro-services. sba-cli is designed to support this is use case by allowing the user to supply an Inventory. An Inventory can be defined in a `config.yaml` file that must be placed in the same directory as sba-cli. Here is the sample Inventory -

```yaml
inventory:
  - name: demo-service
    baseURL: http://localhost:8080
    authorizationHeader: Basic YXJraXRzOmh1bnRlcjI=
    skipVerifySSL: true
    tags:
      - demo
      - local

  - name: demo-service-dev
    baseURL: https://demo-service-dev
    authorizationHeader: Basic YXJraXRzOmh1bnRlcjI=
    tags:
      - demo
      - dev

  - name: demo-service-prod
    baseURL: https://demo-service-prod
    authorizationHeader: Basic YXJraXRzOmh1bnRlcjI=
    tags:
      - demo
      - prod
```

After defining multiple services in your `config.yaml`, you can refer to a specific service by passing it's name in -S flag.

```bash
# ./sba-cli info -S <name of a specific service>
$ ./sba-cli info -S demo-service
>>> demo-service
┌─────────────────────────────┐
│         SERVICE INFO        │
├──────────────┬──────────────┤
│ title        │ demo-service │
└──────────────┴──────────────┘
┌────────────────────────────────────────────────────────────┐
│                          GIT INFO                          │
├─────────────────┬──────────────────────────────────────────┤
│ branch          │ main                                     │
│ commit.time     │ 2021-03-24 01:18:38+0000                 │
│ commit.describe │ 0.0.3-6-gc6c4cdb-dirty                   │
│ commit.abbrev   │ c6c4cdb                                  │
│ commit.full     │ c6c4cdb3932d1b2f28b342fbeb1c3de1d724114e │
└─────────────────┴──────────────────────────────────────────┘
```

Multiple specific services can be passed as a comma-separated string. sba-cli will iterate and print the responses for each.

```bash
$ ./sba-cli info -S demo-service,demo-service-prod
>>> demo-service
┌─────────────────────────────┐
│         SERVICE INFO        │
├──────────────┬──────────────┤
│ title        │ demo-service │
└──────────────┴──────────────┘
┌────────────────────────────────────────────────────────────┐
│                          GIT INFO                          │
├─────────────────┬──────────────────────────────────────────┤
│ branch          │ main                                     │
│ commit.time     │ 2021-03-24 01:18:38+0000                 │
│ commit.describe │ 0.0.3-6-gc6c4cdb-dirty                   │
│ commit.abbrev   │ c6c4cdb                                  │
│ commit.full     │ c6c4cdb3932d1b2f28b342fbeb1c3de1d724114e │
└─────────────────┴──────────────────────────────────────────┘
>>> demo-service-prod
┌─────────────────────────────┐
│         SERVICE INFO        │
├──────────────┬──────────────┤
│ title        │ demo-service │
└──────────────┴──────────────┘
┌────────────────────────────────────────────────────────────┐
│                          GIT INFO                          │
├─────────────────┬──────────────────────────────────────────┤
│ branch          │ main                                     │
│ commit.time     │ 2021-03-24 01:18:38+0000                 │
│ commit.describe │ 0.0.3-6-gc6c4cdb-dirty                   │
│ commit.abbrev   │ c6c4cdb                                  │
│ commit.full     │ c6c4cdb3932d1b2f28b342fbeb1c3de1d724114e │
└─────────────────┴──────────────────────────────────────────┘
```

### Inventory Tagging

Complicated Inventories can be managed and queried easily with Tags. Each Inventory entry can have a list of string tags associated to it. During runtime, the user can pass a query tag (multiple as a comma-separated string) and sba-cli will match the Inventory appropriately.

```bash
$ ./sba-cli health -T dev,prod
>>> demo-service-dev
┌─────────────────┐
│      HEALTH     │
├────────┬────────┤
│ status │ UP     │
└────────┴────────┘

>>> demo-service-prod
┌─────────────────┐
│      HEALTH     │
├────────┬────────┤
│ status │ UP     │
└────────┴────────┘
```

[^1]: interchangeable with server, backend, service.
[^2]: 'well-managed' is an term used internally at Capital One. An application is well-managed when all the necessary tools, procedures, personnel have are in place and guarantee an application is always on. While there maybe technical requirements to describe what constitutes as a well-managed application, it is the ethos of this term that is more significant in this context.
