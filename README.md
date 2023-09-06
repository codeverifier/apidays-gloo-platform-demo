# Apidays Gloo Platform Demo

This repository contains artifacts for demonstrating the following Gloo Platform features.

## Feature Demo

| Order | Dir   |      Command      |  Notes |
|:----------|:----------|:-------------|:------|
|1| Zero trust | `zero-trust` | Demonstrates the Workspace feature which helps to establish service isolation boundaries. Here the "backend team" who owns `backend-apis-team` workspace has taken a stance on who can be trusted. They have not allowed any service out of the workspace to access their APIs |
|2| Canary deployment | `canary-deployment` | This shows deploying a new version of reviews v5 in the east cluster. Only 10% of traffic will be routed to this new version and the rest will be load balanced to reviews-v1 on both clusters |
|3| Single cluster traffic routing | `single-cluster-traffic` | Single cluster traffic management within the west cluster |
|4| Cross cluster traffic routing  | `cross-cluster-traffic`   | Cross cluster traffic management between west and east clusters  |
|5| Traffic shifting to reviews v3 | `cross-cluster-traffic-shift` | Shifting all the traffic to reviews v3 on east cluster |
|6| Failover policy | `failover-policy` | Failover to reviews v3 on east cluster when none of the reviews services on west cluster are available |

## High-level Architecture

Below architecture is the basis for the demo.

![Apidays Demo High Level Architecture](https://github.com/pseudonator/apidays-gloo-platform-demo/assets/2648624/a69e1950-7b22-4bce-8b29-3558022fdc00)
