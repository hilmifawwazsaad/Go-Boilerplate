<div align="center">
<h1> Go Boilerplate </h1>

Boilerplate REST API menggunakan pure Go standard library dengan pendekatan **Layered Architecture** — memisahkan setiap tanggung jawab ke dalam lapisan yang jelas dan terstruktur.
</div>

## Tech Stack

- **Language**: Go 1.22+
- **Framework**: `net/http` (standard library)
- **Storage**: In-memory (siap diganti database tanpa ubah layer lain)
- **Dev Tools**: golangci-lint, goimports, lefthook

## Arsitektur

Proyek ini menggunakan **Layered Architecture** (arsitektur berlapis). Setiap HTTP request mengalir melalui lapisan-lapisan berikut secara berurutan:

```
HTTP Request
    │
    ▼
internal/delivery/http/routes/      → Definisi path dan method endpoint
    │
    ▼
internal/delivery/http/middleware/  → Auth, logging, CORS, dsb.
    │
    ▼
internal/delivery/http/handler/     → Controller tipis — parse request, panggil use case, kirim response
    │
    ▼
internal/usecase/                   → Logika bisnis dan validasi input
    │
    ▼
internal/repository/                → Akses data (in-memory, database, API eksternal)
    │
    ▼
internal/domain/                    → Definisi entity dan interface (kontrak antar layer)
```

Layer pendukung:

```
pkg/config/     → Konfigurasi dari environment variable
pkg/response/   → Helper HTTP response JSON
```

## Struktur Folder

```
go-boilerplate/
├── cmd/
│   └── server/              # Entry point — inisialisasi dan merakit semua layer
├── internal/
│   ├── app/                 # Bootstrap — merakit semua dependency (DI)
│   ├── domain/              # Entity dan interface (kontrak antar layer)
│   ├── repository/
│   │   └── inmemory/        # Implementasi storage in-memory
│   ├── usecase/             # Logika bisnis dan validasi
│   └── delivery/
│       └── http/
│           ├── handler/     # HTTP handler per resource
│           ├── routes/      # Definisi semua route
│           └── middleware/  # Auth, logger, CORS, dsb.
└── pkg/
    ├── config/              # Konfigurasi environment
    └── response/            # Helper HTTP response JSON
```

Setiap folder memiliki `README.md` tersendiri yang menjelaskan konvensi, prinsip, dan contoh kode penggunaan.

## Memulai

### Prasyarat

- Go 1.22+
- [golangci-lint](https://golangci-lint.run/welcome/install/) — linter
- [goimports](https://pkg.go.dev/golang.org/x/tools/cmd/goimports) — formatter (`go install golang.org/x/tools/cmd/goimports@latest`)
- [lefthook](https://github.com/evilmartians/lefthook) — git hooks
- `make` — untuk menjalankan perintah di Makefile (tersedia di macOS/Linux; Windows pakai Git Bash atau WSL)

### Instalasi

```bash
# Install git hooks
lefthook install
```

### Menjalankan Server

```bash
make run
```

Server berjalan di `http://localhost:8080`.

### Perintah yang Tersedia

```bash
make run    # Jalankan server
make fmt    # Format kode (gofmt + goimports)
make vet    # Deteksi kesalahan umum (go vet)
make lint   # Jalankan linter (golangci-lint)
make tidy   # Bersihkan dependency (go mod tidy)
make check  # Jalankan fmt + vet + lint sekaligus
```

## Git Hooks (Lefthook)

| Hook | Trigger | Aksi |
|---|---|---|
| `pre-commit` | Sebelum commit | Format (`gofmt`), deteksi error (`go vet`), lint (`golangci-lint`) |
| `commit-msg` | Saat menulis commit | Validasi format Conventional Commits — blokir jika salah |
| `post-merge` | Setelah merge/pull | Jalankan `go mod tidy` otomatis |
| `pre-push` | Sebelum push | Lint strict (zero warning) + validasi semua commit yang akan dipush |

### Format Commit Message

Menggunakan [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

feat(user): add get all users endpoint
fix(auth): handle expired token
refactor(usecase): simplify validation logic
docs: update README
chore: add golangci-lint config
```

Tipe yang tersedia: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`, `perf`, `ci`, `build`, `revert`

## Konvensi

| Konvensi | Penerapan |
|---|---|
| Nama package singular | `handler`, `middleware`, `repository` — bukan `handlers`, `middlewares` |
| Dependency hanya ke dalam | `delivery` → `usecase` → `repository`, tidak sebaliknya |
| Interface di domain | Semua layer bergantung pada interface, bukan implementasi konkret |
| Validasi di use case | Validasi input ditulis di `usecase/`, tidak dipisah ke folder sendiri |
