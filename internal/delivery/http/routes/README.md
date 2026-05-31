# internal/delivery/http/routes/

Folder ini adalah satu-satunya tempat untuk mendefinisikan semua route aplikasi. Buka file ini untuk melihat endpoint apa saja yang tersedia.

## Kegunaan

- Mendaftarkan semua route (URL + HTTP method + handler)
- Mengelompokkan route berdasarkan resource
- Menjadi titik pusat registrasi route — tidak perlu buka file lain untuk tahu endpoint apa yang ada

## Prinsip

- Semua route didaftarkan melalui fungsi `Register()`
- Setiap resource punya fungsi `registerXxxRoutes()` sendiri
- Tidak boleh ada logika bisnis atau parsing request di sini

## Struktur yang Disarankan

```
internal/delivery/http/routes/
└── routes.go   # Satu file, semua route terdaftar di sini
```

## Contoh Penggunaan

**`internal/delivery/http/routes/routes.go`** saat menambah resource `Product`:

```go
package routes

import (
    "net/http"

    "go-boilerplate/internal/delivery/http/handler"
    "go-boilerplate/internal/domain"
)

// Register adalah satu-satunya fungsi yang perlu dipanggil dari luar.
// Tambahkan parameter use case baru di sini saat menambah entity baru.
func Register(mux *http.ServeMux, userUC domain.UserUseCase, productUC domain.ProductUseCase) {
    registerUserRoutes(mux, handler.NewUserHandler(userUC))
    registerProductRoutes(mux, handler.NewProductHandler(productUC))
}

func registerUserRoutes(mux *http.ServeMux, h *handler.UserHandler) {
    mux.HandleFunc("GET /users", h.GetAll)
    mux.HandleFunc("POST /users", h.Create)
    mux.HandleFunc("GET /users/{id}", h.GetByID)
    mux.HandleFunc("PUT /users/{id}", h.Update)
    mux.HandleFunc("DELETE /users/{id}", h.Delete)
}

func registerProductRoutes(mux *http.ServeMux, h *handler.ProductHandler) {
    mux.HandleFunc("GET /products", h.GetAll)
    mux.HandleFunc("POST /products", h.Create)
    mux.HandleFunc("GET /products/{id}", h.GetByID)
    mux.HandleFunc("PUT /products/{id}", h.Update)
    mux.HandleFunc("DELETE /products/{id}", h.Delete)
}
```

## Dipanggil dari

`routes.Register()` dipanggil oleh `router.go`:

```go
// internal/delivery/http/router.go
func NewRouter(userUC domain.UserUseCase, productUC domain.ProductUseCase) *http.ServeMux {
    mux := http.NewServeMux()
    routes.Register(mux, userUC, productUC)
    return mux
}
```
