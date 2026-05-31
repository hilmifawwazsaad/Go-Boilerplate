# Workflows

GitHub Actions workflows untuk CI/CD pipeline.

## ci.yml — Continuous Integration

Dijalankan pada setiap `push` dan `pull_request` ke `main`.

| Step | Command | Keterangan |
|---|---|---|
| Check formatting | `gofmt -s -l .` | Pastikan semua file sudah diformat |
| Run vet | `go vet ./...` | Deteksi kesalahan umum di kode |
| Run lint | `golangci-lint run` | Jalankan semua linter |
| Build | `go build ./...` | Pastikan kode bisa dikompilasi |
| Run tests | `go test ./...` | Jalankan semua unit test |

## cd.yml — Continuous Deployment

Dijalankan otomatis setelah CI berhasil di `main`.

Tiga opsi deploy tersedia (uncomment yang dibutuhkan):

| Opsi | Secrets yang Dibutuhkan |
|---|---|
| VPS via SSH | `SSH_HOST`, `SSH_USER`, `SSH_PRIVATE_KEY` |
| Docker + Registry | `DOCKER_USERNAME`, `DOCKER_PASSWORD` |
| Fly.io | `FLY_API_TOKEN` |

Untuk menambah secrets: **GitHub repo → Settings → Secrets and variables → Actions**.

## Perbedaan dengan Express.js

| | Express.js | Go |
|---|---|---|
| Setup runtime | `actions/setup-node` | `actions/setup-go` |
| Format check | `pnpm format:check` | `gofmt -s -l .` |
| Type check | `pnpm typecheck` | — *(dicek saat build)* |
| Build | `pnpm build` | `go build ./...` |
| Cache | pnpm cache | Go module cache (built-in) |

Di Go tidak perlu step type check terpisah karena `go build` sudah sekaligus mengecek tipe.
