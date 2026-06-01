---
name: software-principles
description: Engineering principles for all code in this Go project. Required reading before any code generation.
license: MIT
---

## Pre-Code Checklist

1. One reason to change? If not — split it (SRP)
2. Simpler solution with same outcome? — use it (KISS)
3. Building for a future need that doesn't exist yet? — delete it (YAGNI)
4. Name reveals intent without generic words? (`and`, `data`, `info`, `manager`, `handle`) — if not, rethink

## Principles

| Principle                            | Rule                                    | Signal                                           | Fix                                  |
| ------------------------------------ | --------------------------------------- | ------------------------------------------------ | ------------------------------------ |
| **SRP** — Single Responsibility      | One unit, one reason to change          | `and` in name · file > 200 lines · fn > 20 lines | Split                                |
| **OCP** — Open/Closed                | Extend without modifying existing code  | Adding a variant by editing internals            | New module/strategy                  |
| **DIP** — Dependency Inversion       | Depend on abstractions, not concretions | `new ConcreteService()` hardcoded in logic       | Inject dependencies                  |
| **DRY** — Don't Repeat Yourself      | One source of truth per piece of logic  | Copy-paste logic across files                    | Extract to shared module             |
| **KISS** — Keep It Simple            | Simplest correct solution               | Unnecessary abstraction · deep indirection       | Remove layers · flatten              |
| **YAGNI** — You Aren't Gonna Need It | Build only what is needed now           | Unused params · "might need later" code          | Delete it                            |
| **SoC** — Separation of Concerns     | Each module owns one concern            | Business logic mixed with request handling       | Separate into layers                 |
| **LoD** — Law of Demeter             | Talk only to direct collaborators       | `a.b.c.method()` chains                          | Add intermediate method              |
| **Fail Fast**                        | Surface errors at earliest point        | Silent catch · late validation                   | Validate at boundaries · throw early |
| **SSOT** — Single Source of Truth    | One authoritative place per logic       | Same validation in multiple layers               | Centralize · import everywhere       |

## Naming

Generic names destroy readability. Names must reveal intent.

| Concept   | Pattern                     | Good                                           | Bad                                   |
| --------- | --------------------------- | ---------------------------------------------- | ------------------------------------- |
| Functions | verb phrase                 | `getUserById`, `validateEmail`, `hashPassword` | `handle`, `process`, `doStuff`, `run` |
| Booleans  | `is` / `has` / `can` prefix | `isActive`, `hasPermission`, `canDelete`       | `active`, `flag`, `check`, `status`   |
| Variables | noun, specific              | `userId`, `paginatedUsers`, `hashedPassword`   | `data`, `result`, `info`, `temp`      |
| Files     | `[name]_[layer].go`         | `user_usecase.go`, `auth_middleware.go`        | `utils2.go`, `misc.go`, `helpers.go`  |

Rules: no abbreviations (except `id`, `req`, `res`, `err`, `ctx`, `w`) · no single-letter names outside loop counters.

## Function Design

| Rule                  | Limit              | When exceeded                                |
| --------------------- | ------------------ | -------------------------------------------- |
| Single responsibility | One action         | Split into smaller functions                 |
| Length                | ≤ 20 lines         | Extract to named helper                      |
| Parameters            | ≤ 3                | Group into options object                    |
| Nesting               | ≤ 2 levels         | Early return (guard clause)                  |
| Return paths          | Prefer single exit | Guard clauses at top, one `return` at bottom |

## Applied to This Project

Go — clean/layered architecture (`routes → handler → usecase → repository`).

| Principle | Example                                                                                              |
| --------- | ---------------------------------------------------------------------------------------------------- |
| SRP       | `UserUseCase` owns one domain — no mixing auth logic into user usecase                               |
| SoC       | Handlers parse/respond · usecases own logic · repositories own DB — never mix                        |
| DRY       | Shared entity types in `internal/domain/` · response helpers once in `pkg/response/`                 |
| Fail Fast | `pkg/config/config.go` panics at startup if required env vars are missing · validate at handler boundary |
| SSOT      | Sentinel errors → `internal/domain/` · env vars → `pkg/config/config.go`                            |
| YAGNI     | No abstraction until needed by 2+ consumers                                                          |
| KISS      | Handler calls one usecase method — no orchestration logic in handlers                                |
| DIP       | Usecases depend on `domain.XxxRepository` interfaces, not concrete implementations                   |

## Error Handling

- Return errors upward — handle only where you can meaningfully recover
- Never ignore an error with `_` — always handle or propagate
- Return `domain.ErrXxxNotFound` for missing resources — never `nil, nil`
- Map domain errors to HTTP status codes in the handler layer, not deeper
- Never expose raw `err.Error()` strings to HTTP clients

## Testing

- Unit test pure functions and services in isolation
- Integration test at route boundaries — not implementation details
- Don't mock what you own; mock external services only
- One assertion per test concept

## Never Do

- Name anything `data`, `result`, `info`, `temp`, `manager`, `handleX`, `processX`
- Functions > 20 lines · parameters > 3 · nesting > 2 levels — split or group
- Use `interface{}` / `any` to bypass type safety — fix the actual type
- Put business logic in handlers or routes — extract to usecase