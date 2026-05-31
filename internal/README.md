# internal/

Kode inti aplikasi. Folder `internal/` adalah konvensi Go yang membuat kode di dalamnya
**tidak bisa diimport** oleh project lain di luar modul ini — hanya bisa dipakai sendiri.

Terdiri dari lima bagian:

| Folder | Peran |
|--------|-------|
| `app/` | Bootstrap — merakit semua dependency (DI) |
| `domain/` | Entity dan interface (kontrak antar layer) |
| `repository/` | Implementasi akses data |
| `usecase/` | Business logic |
| `delivery/` | HTTP handler dan routing |

Aturan dependency antar layer:

```
delivery → usecase → repository
   semua layer boleh import domain, tidak boleh sebaliknya
```
