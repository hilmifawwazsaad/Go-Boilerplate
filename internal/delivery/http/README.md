# internal/delivery/http/

Implementasi delivery layer via HTTP menggunakan `net/http` standard library (Go 1.22+).

Terdiri dari:

| File/Folder | Peran |
|-------------|-------|
| `router.go` | Setup `http.ServeMux`, mendelegasikan registrasi route ke `routes/` |
| `routes/` | Definisi semua route (URL + method + handler) |
| `handler/` | Implementasi tiap endpoint (parse request, panggil usecase, tulis response) |
