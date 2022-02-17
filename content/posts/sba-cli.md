+++
title = "Custom Observability Tooling Sagas: Spring Boot Actuator CLI"
date = "2021-04-07"
author = "Archit"
cover = "/img/sba-cli.png"
description = "Exploring the nuances of building CLI tooling to interact and visualize a Spring Boot application's Actuator endpoint's data."
+++

## Preface

A substantial part of today's modern service infrastructure involves delivering an _application_ ( server / backend / service / micro-service / API ). The intention of this application could be anything - serving a rendered page, REST API, WebSocket stream, message queue worker etc.

While building the application is one challenge, the real boss-fight begins once the application is deployed to prod, and the team needs to support it. Supporting the application could be a simple task of figuring out which version of the service is deployed, or something more challenging such as mutating a configuration. Due to the ubiquity of these support tasks, teams often dive into building custom tooling for gaining observability and insights into said application. Building these tools has almost become a right of passage into modern application development; and after having built a few, I wanted to capture the nuances, design decisions and the lessons learned.

## Spring Boot...?

In a _tiny_ nutshell, [Spring Boot](https://spring.io/projects/spring-boot) is a framework to build _applications_ in Java. Think Express in Node, Rails in Ruby, Django in Python (to an extent). The Spring [project](https://spring.io/) pieces together many popular Java projects into a palatable, yet extensible experience. While Spring Boot provides the base to build your applications, the rest of the Spring ['eco-system'](https://spring.io/projects) provides answers for almost every possible type of integration - from Kafka to Kubernetes.

While Spring is a great solution for quickly standing-up applications, personally I've found it too be a bit to _magical_ in it's details and often requires some goofy workarounds if you don't happen to agree with the 'Spring way'. However, Spring's ease-of-use, decent performance, and strong eco-system of integrations make it a strong candidate to build applications.

## Spring Boot Actuator...?

Actuator is one such member of the previously mentioned Spring eco-system. Actuator is module that once _installed_ into a Spring application, exposes a variety of REST endpoints, which can be programmatically queried and interacted with in order to facilitate typical management related tasks of an application.

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

A notable aspect about the `/health` actuator, and to illustrate the value of Actuator in the Spring project - other components within your application can implement the [API for submitting custom health indicators](https://www.baeldung.com/spring-boot-health-indicators#customhealthindicators) to the `/health` actuator, which in turn would show up as the updated response for `/health`. Various other Spring projects, such as Spring Kafka and Spring Data JPA, already implement this API thus making `/health` truly useful.

On the other hand, there are actuators with write operations, such as the `/env` actuator which let you mutate the application's env / configurations...

```bash
$ curl \
    -X POST \
    -d '{"name":"db_password", "value":"hunter2"}' \
    -H "Content-Type: application/json" \
    http://localhost:8080/actuator/env
```

This again, is another "standard" feature that most other frameworks don't tend to provide, leading teams to end up hacking together their own frankenstein implementations.

And `/env` isn't even scratching the surface...

- `/threaddump` is always handy when needed for that level of debugging.
- `/loggers` allows you to mutate the logging level on a class-path level, thus letting you turn off noisy debug statements in runtime.
- `/beans` for the Bean-heads (I don't need to explain any further - you know who you are).
- there is also my personal favorite, `/logfile` which literally streams you your log file.

> All of these great endpoints surely make Actuator a great debug tool... right? If you haven't figured out the problem with Actuator as a debug tool... well it's not - it's an interface; and like any other interface, it needs a good client to drive it.

## Spring Boot Actuator CLI...!

My previous job involved supporting ~12 applications written in Spring, and had to manage them between 3 independent teams' sprints. Naturally, things were breaking and Actuator was used heavily to debug the cause. With 12 applications (and multiple instances of dev/qa/prod), in the heat of the moment, even introspecting the heath of one particular application can become a massive chore.

I would often see my co-workers wrestle with bash scripts, curl commands, jq queries and env variables to facilitate working with Actuator, however you can imagine that approach getting out of control as the permutations of environments increase. While, there are some big name tools out in this space - REST clients such as Postman, Insomnia, Paw as the notable examples; none have hit the apex in -

- ease of use / ease of setup
- parsing of the responses / understanding what the responses mean
- config storage / location of stored variables and credentials

In early 2021, I spent some time building [spring-boot-actuator-cli](https://github.com/arkits/spring-boot-actuator-cli) - a command-line application to interact and visualize a Spring Boot application's Actuator endpoint's data.

Here's the most basic usage - hitting the `/health` actuator of an application running on `http://localhost:8080` -

```bash
# ./sba-cli health -U <base URL>
$ ./sba-cli health -U http://localhost:8080
┌─────────────────┐
│      HEALTH     │
├────────┬────────┤
│ status │ UP     │
└────────┴────────┘
```

With the arguments from the command, sba-cli figures out the right REST call to make, parses the response and prints it out - in a more human readable format.

Please excuse the text rendering on the blog; here are [some screenshots of sba-cli in action](https://github.com/arkits/spring-boot-actuator-cli/blob/main/docs/screenshots/README.md)

### Inventory Management

To address the use case of managing multiple applications, sba-cli allows the user to supply an Inventory. An Inventory can be defined in a `config.yaml` file, which sba-cli reads on init. A listing in the Inventory describes an instance of an application - defining the base URL, authorization etc. Here is the sample Inventory -

```yaml
inventory:
  - name: demo-service
    baseURL: http://localhost:8080
    skipVerifySSL: true
    tags:
      - demo
      - local

  - name: demo-service-dev
    baseURL: https://demo-service-dev
    tags:
      - demo
      - dev

  - name: demo-service-prod
    baseURL: https://demo-service-prod
    tags:
      - demo
      - prod

  - name: auth-service-prod
    baseURL: https://auth-service-prod
    authorizationHeader: Basic YXJraXRzOmh1bnRlcjI=
    tags:
      - auth
      - prod
```

This Inventory describes 3 instances of the `demo-service` (running on localhost, dev, prod) and 1 instance of the `auth-service` (running only in prod).

After defining multiple services in your Inventory, a specific service can be referred to by passing it's name rather than the URL...

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

... and multiple services can be referred to as a comma-separated string. sba-cli will iterate and print the responses for each.

```bash
$ ./sba-cli health -S demo-service-dev,demo-service-prod
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

### Inventory Tagging

Another usage, that allows for "bulk" actions in complicated inventories, is with Tags. Each Inventory entry can have a list of string tags associated to it. During runtime, the user can pass a query tag (multiple as a comma-separated string) and sba-cli will match the Inventory appropriately.

For example, to query all `prod` services -

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

### Collaboration through Git

A key motivation for the Inventory file mechanism was for using Git to manage the file, allowing the file to collaboratively updated. The approach would be to commit the file to a 'secrets' repo, and extend from there with a suitable merge-flow approach to intake changes.

It does means that access control to the repo is outsourced to whatever is available, which may not be acceptable in all cases. However, sba-cli is distributed as a single binary, allowing automation to be built around it.
