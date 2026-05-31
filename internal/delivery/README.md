# internal/delivery/

Layer presentasi. Bertanggung jawab menerima request dari luar dan mengembalikan response.

Setiap subfolder adalah satu protokol komunikasi:

| Subfolder | Keterangan |
|-----------|------------|
| `http/` | REST API via `net/http` |
| `grpc/` | *(contoh)* gRPC server |
| `cli/` | *(contoh)* Command line interface |

Aturan:
- Tidak boleh ada business logic di sini
- Hanya boleh memanggil `usecase/`, tidak boleh langsung ke `repository/`
