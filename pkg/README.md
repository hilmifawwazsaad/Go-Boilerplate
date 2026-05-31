# pkg/

Berisi package utilitas yang **bisa dipakai ulang** di mana saja dalam proyek,
bahkan bisa diekspor ke proyek lain.

Perbedaan dengan `internal/`:
- `internal/` → kode spesifik untuk aplikasi ini, tidak bisa diimport dari luar
- `pkg/` → kode generik dan reusable

Isi saat ini:

| Package | Keterangan |
|---------|------------|
| `response/` | Helper untuk menulis HTTP response JSON secara konsisten |
