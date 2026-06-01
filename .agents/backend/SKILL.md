---
name: backend
description: Generate production-grade Go code with Clean/Layered Architecture. Handlers, usecases, repositories, domain, middlewares — no UI.
license: MIT
---

## Pre-Code Checklist

1. Which layer? Map need to exactly one row in the Architecture table
2. Call direction: `routes → handler → usecase → repository` — no skipping, no reversing
3. Error to return? Define sentinel/typed errors in `internal/domain/` — never `errors.New()` inline in handlers or usecases
4. Which package? Internal app code lives in `internal/`; reusable, domain-agnostic helpers go in `pkg/`

## Architecture

| Layer                   | File                                                             | Constraint                                                                    |
| ----------------------- | ---------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Entry point             | `cmd/server/main.go`                                             | Calls `app.Run()` only — zero logic                                           |
| Bootstrap / DI          | `internal/app/app.go`                                            | Initializes repository → usecase → router in order · only place importing all layers |
| Entity & interfaces     | `internal/domain/[name].go`                                      | Struct + `XxxRepository` + `XxxUseCase` interfaces — no logic, no imports     |
| Business logic          | `internal/usecase/[name]_usecase.go`                             | Implements `domain.XxxUseCase` · no HTTP types · no DB access                 |
| Data access             | `internal/repository/inmemory/[name]_repository.go`              | Only layer allowed to touch storage · implements `domain.XxxRepository`       |
| HTTP handler            | `internal/delivery/http/handler/[name]_handler.go`               | ≤ 20 lines · parse request → call usecase → respond · no business logic       |
| Route registration      | `internal/delivery/http/routes/routes.go`                        | Register URL + method + handler only — no logic                               |
| Middleware              | `internal/delivery/http/middleware/[name]_middleware.go`         | Cross-cutting only (auth, logging, CORS, recovery) · wrap `http.Handler`      |
| HTTP response helpers   | `pkg/response/response.go`                                       | Consistent JSON envelope — use these, never raw `w.Write` or `json.Encode`    |
| Configuration           | `pkg/config/config.go`                                           | All `os.Getenv` calls here only · validates required vars · provides defaults |

## Go Conventions

- Use `any` only when necessary — add an inline comment explaining why
- Unused params: use blank identifier `_` — `_ http.ResponseWriter`, `_ *http.Request`
- Constructors return the interface, not the concrete type: `func NewUserUseCase(...) domain.UserUseCase`
- Interface for every cross-layer dependency — defined in `domain/`, implemented in `usecase/` or `repository/`
- Error handling: always check `if err != nil` — never ignore errors with `_`
- Import groups (enforced by goimports): stdlib → internal packages → pkg packages
- File naming: `[name]_[layer].go` — e.g. `user_usecase.go`, `auth_middleware.go`

## Response & Errors

Use helpers from `pkg/response/`:
- `response.Success(w, data)` — HTTP 200
- `response.Created(w, data)` — HTTP 201
- `response.Error(w, statusCode, msg)` — any error status

Never write raw `json.NewEncoder(w).Encode(...)` in handlers — always use response helpers.

Domain errors: define sentinel errors in `internal/domain/` — e.g. `var ErrUserNotFound = errors.New("user not found")`. Usecases return these; handlers map them to HTTP status codes with a switch or errors.Is check.

## Never Do

- Logic in `routes/` or `cmd/` · DB access in `handler/` or `usecase/` · HTTP types (`http.Request`, `http.ResponseWriter`) in `usecase/`
- `os.Getenv` outside `pkg/config/config.go`
- Ignore errors: `result, _ := someFunc()` — handle or propagate every error
- Return `nil, nil` for not-found — return `nil, domain.ErrXxxNotFound`
- Expose raw `err.Error()` to HTTP clients — map errors to safe messages in the handler
- Import packages not in `go.mod`
- Hard-code concrete struct types as dependencies between layers — always depend on interfaces from `domain/`
