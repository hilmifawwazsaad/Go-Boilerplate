# internal/usecase/

Folder ini menyimpan **business logic** aplikasi. Semua aturan bisnis, validasi domain, dan orkestrasi antar repository ditulis di sini.

## Kegunaan

- Mengimplementasikan interface `XxxUseCase` dari `domain/`
- Memvalidasi input sebelum diteruskan ke repository
- Mengorkestrasi logika bisnis (boleh panggil lebih dari satu repository)
- Memberi ID unik pada entity baru sebelum disimpan

## Prinsip

- Tidak boleh tahu tentang HTTP (`http.Request`, `http.ResponseWriter`, dsb.)
- Tidak boleh tahu tentang format response (JSON, XML, dsb.)
- Hanya boleh import `domain/` dan package standard library
- Setiap entity baru → buat file baru (`product_usecase.go`)

## Struktur yang Disarankan

```
internal/usecase/
├── user_usecase.go      # Implementasi domain.UserUseCase
└── product_usecase.go   # Implementasi domain.ProductUseCase
```

## Contoh Penggunaan

**`internal/usecase/product_usecase.go`**

```go
package usecase

import (
    "context"
    "errors"
    "strconv"
    "time"

    "go-boilerplate/internal/domain"
)

type productUseCase struct {
    productRepo domain.ProductRepository
}

func NewProductUseCase(repo domain.ProductRepository) domain.ProductUseCase {
    return &productUseCase{productRepo: repo}
}

func (uc *productUseCase) GetAll(ctx context.Context) ([]domain.Product, error) {
    return uc.productRepo.FindAll(ctx)
}

func (uc *productUseCase) GetByID(ctx context.Context, id string) (*domain.Product, error) {
    if id == "" {
        return nil, errors.New("id cannot be empty")
    }
    return uc.productRepo.FindByID(ctx, id)
}

func (uc *productUseCase) Create(ctx context.Context, product *domain.Product) error {
    if product.Name == "" {
        return errors.New("name is required")
    }
    if product.Price <= 0 {
        return errors.New("price must be greater than 0")
    }
    if product.Stock < 0 {
        return errors.New("stock cannot be negative")
    }
    product.ID = strconv.FormatInt(time.Now().UnixNano(), 10)
    return uc.productRepo.Create(ctx, product)
}

func (uc *productUseCase) Update(ctx context.Context, id string, input *domain.Product) error {
    existing, err := uc.productRepo.FindByID(ctx, id)
    if err != nil {
        return err
    }
    if input.Name != "" {
        existing.Name = input.Name
    }
    if input.Price > 0 {
        existing.Price = input.Price
    }
    return uc.productRepo.Update(ctx, existing)
}

func (uc *productUseCase) Delete(ctx context.Context, id string) error {
    return uc.productRepo.Delete(ctx, id)
}
```

## Dipanggil dari

Use case diinisialisasi di `cmd/server/main.go` dengan menerima repository sebagai dependency:

```go
productRepo := inmemory.NewProductRepository()
productUC   := usecase.NewProductUseCase(productRepo)
```

Lalu diinjeksikan ke handler — bukan repository-nya langsung.
