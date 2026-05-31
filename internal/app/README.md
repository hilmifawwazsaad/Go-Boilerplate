# internal/app/

Folder ini menyimpan logika bootstrap aplikasi — tempat semua dependency dirakit (Dependency Injection) sebelum server dijalankan.

## Kegunaan

- Menginisialisasi semua layer secara berurutan: repository → use case → router
- Memisahkan logika perakitan dari entry point (`cmd/server/main.go`)
- Membuat `main.go` tetap tipis — hanya memanggil `app.Run()`

## Prinsip

- Satu-satunya tempat yang "tahu" tentang semua layer sekaligus
- Urutan inisialisasi selalu dari dalam ke luar: repository → use case → router
- Tidak boleh ada business logic di sini

## Struktur yang Disarankan

```
internal/app/
└── app.go    # Fungsi Run() yang merakit semua dependency
```

## Contoh Penggunaan

**`internal/app/app.go`**

```go
package app

import (
    "log"
    "net/http"

    httpdelivery "go-boilerplate/internal/delivery/http"
    "go-boilerplate/internal/repository/inmemory"
    "go-boilerplate/internal/usecase"
    "go-boilerplate/pkg/config"
)

func Run() {
    // Load konfigurasi
    cfg := config.Load()

    // Layer 1 — Repository (data source)
    userRepo := inmemory.NewUserRepository()

    // Layer 2 — Use Case (business logic), terima repository sebagai dependency
    userUC := usecase.NewUserUseCase(userRepo)

    // Layer 3 — Router (HTTP delivery), terima use case sebagai dependency
    mux := httpdelivery.NewRouter(userUC)

    // Jalankan server
    log.Printf("Server running on http://localhost:%s", cfg.Port)
    if err := http.ListenAndServe(":"+cfg.Port, mux); err != nil {
        log.Fatal(err)
    }
}
```

**`cmd/server/main.go`** cukup satu panggilan:

```go
package main

import "go-boilerplate/internal/app"

func main() {
    app.Run()
}
```

## Cara Menambah Entity Baru

Saat menambah entity `Product`, cukup tambahkan baris inisialisasi di `app.go`:

```go
// Tambahkan setelah baris user
productRepo := inmemory.NewProductRepository()
productUC   := usecase.NewProductUseCase(productRepo)

// Teruskan ke router
mux := httpdelivery.NewRouter(userUC, productUC)
```

`main.go` tidak perlu disentuh sama sekali.

## Dipanggil dari

```
cmd/server/main.go → app.Run()
```
