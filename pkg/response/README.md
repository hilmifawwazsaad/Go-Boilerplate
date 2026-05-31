# pkg/response/

Folder ini menyimpan helper untuk menulis HTTP response JSON dengan format yang konsisten di seluruh aplikasi.

## Kegunaan

- Memastikan semua endpoint mengembalikan format response yang sama
- Menyederhanakan penulisan response di handler — cukup satu baris

## Format Response

```json
// Sukses (Success / Created)
{ "success": true, "data": { ... }, "message": null, "error": null }

// Error
{ "success": false, "data": null, "message": "pesan error", "error": null }
```

## Fungsi yang Tersedia

| Fungsi | Status Code | Kapan dipakai |
|--------|-------------|---------------|
| `Success(w, data)` | 200 | GET, PUT, DELETE berhasil |
| `Created(w, data)` | 201 | POST berhasil membuat data baru |
| `Error(w, code, msg)` | bebas | Saat terjadi error |
| `JSON(w, code, payload)` | bebas | Untuk response custom |

## Contoh Penggunaan

```go
// GET — kembalikan data
func (h *UserHandler) GetAll(w http.ResponseWriter, r *http.Request) {
    users, err := h.userUC.GetAll(r.Context())
    if err != nil {
        response.Error(w, http.StatusInternalServerError, err.Error())
        return
    }
    response.Success(w, users)
}

// POST — kembalikan data yang baru dibuat
func (h *UserHandler) Create(w http.ResponseWriter, r *http.Request) {
    // ...
    response.Created(w, user)
}

// DELETE — tidak perlu kembalikan data
func (h *UserHandler) Delete(w http.ResponseWriter, r *http.Request) {
    // ...
    response.Success(w, nil)
}

// Error spesifik
response.Error(w, http.StatusNotFound, "user not found")
response.Error(w, http.StatusBadRequest, "invalid request body")
response.Error(w, http.StatusUnauthorized, "unauthorized")
```
