# internal/delivery/http/middleware/

Folder ini menyimpan HTTP middleware — fungsi yang dieksekusi sebelum atau sesudah handler, untuk keperluan yang bersifat lintas-endpoint (cross-cutting concerns).

## Kegunaan

- Logging request dan response
- Autentikasi (validasi JWT token)
- Otorisasi (cek role/permission)
- CORS (mengizinkan request dari domain lain)
- Rate limiting
- Recovery dari panic

## Prinsip

- Middleware tidak boleh berisi business logic
- Satu file per kebutuhan (`auth.go`, `logger.go`, `cors.go`)
- Middleware harus mengikuti signature `func(http.Handler) http.Handler`

## Struktur yang Disarankan

```
internal/delivery/http/middleware/
├── auth.go      # Validasi JWT token
├── logger.go    # Log tiap request
├── cors.go      # Handle CORS headers
└── recover.go   # Catch panic agar server tidak crash
```

## Contoh Penggunaan

**`internal/delivery/http/middleware/logger.go`**

```go
package middleware

import (
    "log"
    "net/http"
    "time"
)

func Logger(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        next.ServeHTTP(w, r)
        log.Printf("%s %s %s", r.Method, r.URL.Path, time.Since(start))
    })
}
```

**`internal/delivery/http/middleware/auth.go`**

```go
package middleware

import (
    "net/http"
    "strings"

    "go-boilerplate/pkg/response"
)

func Auth(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("Authorization")
        if !strings.HasPrefix(token, "Bearer ") {
            response.Error(w, http.StatusUnauthorized, "unauthorized")
            return
        }
        // validasi token di sini...
        next.ServeHTTP(w, r)
    })
}
```

## Cara Menggunakan di Router

Middleware dibungkuskan di luar handler saat registrasi route:

```go
// Terapkan ke semua route
mux.Handle("/", middleware.Logger(middleware.Auth(routes)))

// Terapkan hanya ke route tertentu
mux.Handle("GET /users", middleware.Auth(http.HandlerFunc(userHandler.GetAll)))
```

## Dipanggil dari

Middleware didaftarkan di `router.go` atau `cmd/server/main.go`, membungkus mux yang sudah berisi semua route.
