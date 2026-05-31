# cmd/server/

Entry point aplikasi. File `main.go` di sini dibuat setipis mungkin — hanya memanggil `app.Run()`. Semua logika perakitan dependency ada di `internal/app/`.

## Kegunaan

- Menjadi titik masuk binary Go
- Mendelegasikan seluruh inisialisasi ke `internal/app/`

## Cara Menjalankan

```bash
go run ./cmd/server
```

## Contoh Penggunaan

**`cmd/server/main.go`**

```go
package main

import "go-boilerplate/internal/app"

func main() {
    app.Run()
}
```

Untuk menambah entity baru atau mengganti dependency, tidak perlu menyentuh file ini — cukup edit `internal/app/app.go`.

## Lihat Juga

- [internal/app/README.md](../../internal/app/README.md) — tempat semua dependency dirakit
