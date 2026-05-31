# pkg/config/

Folder ini menyimpan konfigurasi aplikasi — membaca nilai dari environment variable atau file `.env`.

## Kegunaan

- Membaca environment variable (`PORT`, `DATABASE_URL`, `JWT_SECRET`, dsb.)
- Menyediakan satu struct `Config` yang bisa diakses seluruh aplikasi
- Memvalidasi bahwa semua konfigurasi wajib sudah tersedia saat startup

## Prinsip

- Konfigurasi dibaca **sekali** saat aplikasi start, lalu diteruskan sebagai dependency
- Tidak boleh membaca `os.Getenv()` langsung di dalam handler atau usecase — semua lewat struct `Config`
- Nilai default boleh ada untuk konfigurasi opsional

## Struktur yang Disarankan

```
pkg/config/
└── config.go   # Struct Config + fungsi Load()
```

## Contoh Penggunaan

**`pkg/config/config.go`**

```go
package config

import (
    "log"
    "os"
)

type Config struct {
    Port      string
    JWTSecret string
    // Tambahkan field lain sesuai kebutuhan:
    // DatabaseURL string
    // RedisURL    string
}

func Load() *Config {
    cfg := &Config{
        Port:      getEnv("PORT", "8080"),
        JWTSecret: getEnv("JWT_SECRET", ""),
    }

    if cfg.JWTSecret == "" {
        log.Fatal("JWT_SECRET is required")
    }

    return cfg
}

func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}
```

**`.env.example`** (buat file ini di root project sebagai panduan)

```env
PORT=8080
JWT_SECRET=your-secret-key-here
# DATABASE_URL=postgres://user:password@localhost:5432/dbname
```

## Dipanggil dari

Config diinisialisasi di `cmd/server/main.go` paling awal, lalu diteruskan ke komponen yang membutuhkan:

```go
func main() {
    cfg := config.Load()

    // diteruskan ke middleware, usecase, atau komponen lain yang butuh config
    mux := httpdelivery.NewRouter(userUC, cfg)

    http.ListenAndServe(":"+cfg.Port, mux)
}
```
