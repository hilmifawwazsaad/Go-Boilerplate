# internal/repository/

Layer data. Bertanggung jawab mengimplementasikan interface `XxxRepository` dari `domain/`.

Setiap subfolder adalah satu jenis data source:

| Subfolder | Keterangan |
|-----------|------------|
| `inmemory/` | Penyimpanan sementara di RAM (untuk development/testing) |
| `postgres/` | *(contoh)* Implementasi dengan PostgreSQL |
| `mysql/` | *(contoh)* Implementasi dengan MySQL |

Untuk ganti data source, cukup buat subfolder baru dan implementasikan interface yang sama.
Layer `usecase/` tidak perlu diubah sama sekali.

Aturan:
- Tidak boleh ada business logic di sini
- Hanya boleh import `domain/` dan driver/library database
