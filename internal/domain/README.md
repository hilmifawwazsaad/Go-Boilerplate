# internal/domain/

Folder ini menyimpan **entity** dan **interface** (kontrak antar layer). Ini adalah inti dari aplikasi — layer lain bergantung pada domain, bukan sebaliknya.

## Kegunaan

- Mendefinisikan struct data (entity) yang merepresentasikan objek bisnis
- Mendefinisikan interface `Repository` sebagai kontrak untuk layer data
- Mendefinisikan interface `UseCase` sebagai kontrak untuk layer bisnis

## Prinsip

- **Tidak boleh import layer lain** (`usecase`, `repository`, `delivery`)
- Tidak boleh ada logika bisnis di sini
- Tidak boleh ada kode yang tahu tentang database, HTTP, atau format tertentu
- Setiap entity baru → buat file baru (`product.go`, `order.go`)

## Struktur yang Disarankan

```
internal/domain/
├── user.go       # Entity User + UserRepository + UserUseCase
├── product.go    # Entity Product + ProductRepository + ProductUseCase
└── order.go      # Entity Order + OrderRepository + OrderUseCase
```

## Contoh Penggunaan

**`internal/domain/product.go`**

```go
package domain

import "context"

type Product struct {
    ID    string  `json:"id"`
    Name  string  `json:"name"`
    Price float64 `json:"price"`
    Stock int     `json:"stock"`
}

type ProductRepository interface {
    FindAll(ctx context.Context) ([]Product, error)
    FindByID(ctx context.Context, id string) (*Product, error)
    Create(ctx context.Context, product *Product) error
    Update(ctx context.Context, product *Product) error
    Delete(ctx context.Context, id string) error
}

type ProductUseCase interface {
    GetAll(ctx context.Context) ([]Product, error)
    GetByID(ctx context.Context, id string) (*Product, error)
    Create(ctx context.Context, product *Product) error
    Update(ctx context.Context, id string, product *Product) error
    Delete(ctx context.Context, id string) error
}
```

## Digunakan oleh

Interface di domain diimplementasikan oleh layer lain:

```
domain.ProductRepository → diimplementasikan di repository/inmemory/product_repository.go
domain.ProductUseCase    → diimplementasikan di usecase/product_usecase.go
```
