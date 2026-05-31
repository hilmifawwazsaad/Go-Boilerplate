# internal/delivery/http/handler/

Folder ini menyimpan HTTP handler untuk setiap resource. Handler adalah lapisan tipis yang menjadi jembatan antara HTTP request dan use case.

## Kegunaan

- Menerima HTTP request
- Mengekstrak data dari request body, path param (`r.PathValue`), dan query param
- Memanggil use case yang sesuai
- Mengembalikan HTTP response (sukses atau error)

## Prinsip

Handler harus **tipis** — jika handler lebih dari ~20 baris, kemungkinan ada logika yang seharusnya dipindah ke use case.

- Tidak boleh ada business logic di sini
- Tidak boleh langsung mengakses repository
- Hanya boleh import `domain/` dan `pkg/response/`
- Setiap entity baru → buat file baru (`product_handler.go`)

## Struktur yang Disarankan

```
internal/delivery/http/handler/
├── user_handler.go      # Handler endpoint /users
└── product_handler.go   # Handler endpoint /products
```

## Contoh Penggunaan

**`internal/delivery/http/handler/product_handler.go`**

```go
package handler

import (
    "encoding/json"
    "net/http"

    "go-boilerplate/internal/domain"
    "go-boilerplate/pkg/response"
)

type ProductHandler struct {
    productUC domain.ProductUseCase
}

func NewProductHandler(productUC domain.ProductUseCase) *ProductHandler {
    return &ProductHandler{productUC: productUC}
}

func (h *ProductHandler) GetAll(w http.ResponseWriter, r *http.Request) {
    products, err := h.productUC.GetAll(r.Context())
    if err != nil {
        response.Error(w, http.StatusInternalServerError, err.Error())
        return
    }
    response.Success(w, products)
}

func (h *ProductHandler) GetByID(w http.ResponseWriter, r *http.Request) {
    id := r.PathValue("id")
    product, err := h.productUC.GetByID(r.Context(), id)
    if err != nil {
        response.Error(w, http.StatusNotFound, err.Error())
        return
    }
    response.Success(w, product)
}

func (h *ProductHandler) Create(w http.ResponseWriter, r *http.Request) {
    var product domain.Product
    if err := json.NewDecoder(r.Body).Decode(&product); err != nil {
        response.Error(w, http.StatusBadRequest, "invalid request body")
        return
    }
    if err := h.productUC.Create(r.Context(), &product); err != nil {
        response.Error(w, http.StatusBadRequest, err.Error())
        return
    }
    response.Created(w, product)
}

func (h *ProductHandler) Update(w http.ResponseWriter, r *http.Request) {
    id := r.PathValue("id")
    var product domain.Product
    if err := json.NewDecoder(r.Body).Decode(&product); err != nil {
        response.Error(w, http.StatusBadRequest, "invalid request body")
        return
    }
    if err := h.productUC.Update(r.Context(), id, &product); err != nil {
        response.Error(w, http.StatusBadRequest, err.Error())
        return
    }
    response.Success(w, nil)
}

func (h *ProductHandler) Delete(w http.ResponseWriter, r *http.Request) {
    id := r.PathValue("id")
    if err := h.productUC.Delete(r.Context(), id); err != nil {
        response.Error(w, http.StatusNotFound, err.Error())
        return
    }
    response.Success(w, nil)
}
```

## Dipanggil dari

Handler dipanggil oleh routes:

```go
// internal/delivery/http/routes/routes.go
productHandler := handler.NewProductHandler(productUC)

mux.HandleFunc("GET /products", productHandler.GetAll)
mux.HandleFunc("POST /products", productHandler.Create)
mux.HandleFunc("GET /products/{id}", productHandler.GetByID)
mux.HandleFunc("PUT /products/{id}", productHandler.Update)
mux.HandleFunc("DELETE /products/{id}", productHandler.Delete)
```
