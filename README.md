# 👗 Tailoré Integration Service

![Tailoré Banner](https://img.shields.io/badge/Status-Live-success?style=for-the-badge&logo=vercel)
![Tech](https://img.shields.io/badge/Tech-Node.js%20|%20Express%20|%20VanillaJS-blue?style=for-the-badge)

**Tailoré Integration Service** adalah solusi *frontend integration layer* yang dirancang untuk mengorkestrasi ekosistem e-commerce rental fashion. Layanan ini menghubungkan **Catalog Service (Ooga)** dan **Order Service (Cimol)** menjadi satu pengalaman pengguna yang kohesif.

[**🌐 Kunjungi Tailoré Web**](http://tailore-tika.queenifyofficial.site/)

---

## 📋 Deskripsi Proyek

Service ini bertindak sebagai pusat kendali (*orchestrator*) yang menjembatani komunikasi antar microservices. Fokus utamanya adalah menjaga integritas data selama proses pemesanan melalui mekanisme transaksi atomik.

### Analisis Layanan Kelompok

**Catalog Service (Ooga)**:
- ✅ JWT auth & role-based access
- ✅ Product management dengan filter lengkap
- ✅ 2PC stock reservation
- ⚠️ Butuh image upload & bulk operations

**Order Service (Cimol)**:
- ✅ Order creation & invoice generation
- ✅ Transaction history (user & admin)
- ✅ Secret key authentication
- ⚠️ Butuh order status update & notifications

---

## 🏗️ Arsitektur

```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │ HTTP Request
       ▼
┌─────────────────────────┐
│  Tailoré Frontend       │ ◄─── Integration Service
│  (SPA - Port 5000)      │
└───┬─────────────┬───────┘
    │             │
    │ JWT         │ JWT + Secret
    ▼             ▼
┌──────────┐  ┌──────────┐
│  Ooga    │  │  Cimol   │
│ Catalog  │  │  Order   │
└──────────┘  └──────────┘
```

**Strategi Integrasi**:
1.  **Unified Authentication**: Pengguna hanya perlu login satu kali menggunakan JWT dari Catalog Service yang kemudian diteruskan ke Order Service.
2.  **State Management**: Sinkronisasi data antara `localStorage` (sisi klien) dengan database backend secara real-time.
3.  **Atomic Transaction**: Menjamin bahwa stok tidak akan berkurang jika pembuatan invoice gagal, dan sebaliknya.

---

## ✨ Fitur Utama

- **🛒 Integrated Catalog**: Penjelajahan produk dengan fitur pencarian dan filter kategori.
- **🛍️ Cart System**: Pengelolaan keranjang belanja yang persisten berbasis browser.
- **🔐 2-Phase Commit Checkout**: Protokol transaksi aman (Reserve → Order → Commit).
- **📊 Admin Dashboard**: Monitoring inventaris dan transaksi gabungan dari kedua service.
- **📱 Responsive UI**: Antarmuka modern dengan tema warna *Cherry & Green* yang dioptimalkan untuk perangkat mobile.

---

### Untuk User
- Browse products dengan pagination
- Add to cart & adjust quantity
- Checkout dengan form lengkap
- View order history

### Untuk Admin
- Inventory statistics & management
- Stock adjustment
- View all transactions

---

## 🚀 Instalasi

### Prerequisites
- Node.js v14+
- npm/yarn

### Setup

```bash
# Clone repo
git clone <url>
cd Integrasi-Tailore-Service

# Install
npm install

# Run
npm start
```

Service berjalan di **http://localhost:5000**

---

## 📡 API Endpoints

### Integration Service (Tailoré)
**Base URL**: `http://localhost:5000`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/checkout` | Process checkout with 2PC |
| GET | `/api/orders/:customerName` | Get orders by customer |

**Checkout Request**:
```json
{
  "items": [
    {
      "productId": "xxx",
      "quantity": 2
    }
  ],
  "customerName": "John Doe"
}
```

**Headers**: `Authorization: Bearer <token>`

**Response**:
```json
{
  "success": true,
  "message": "Transaksi Berhasil!",
  "invoices": ["#ORD-123", "#ORD-124"]
}
```

### Catalog Service (Ooga)
**Base URL**: `https://ooga.queenifyofficial.site/api`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register user |
| POST | `/auth/login` | Login & get JWT |
| GET | `/catalog/products` | List products |
| POST | `/catalog/reserve` | Reserve stock (2PC) |
| POST | `/catalog/commit` | Commit reservation |

### Order Service (Cimol)
**Base URL**: `https://cimol.queenifyofficial.site/api`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/orders` | Create order |
| GET | `/orders/history` | User orders |
| GET | `/orders/transactions` | Admin: all orders |

---

## 🔗 Service Integration

| Service | URL | Function |
|---------|-----|----------|
| **Catalog (Ooga)** | https://ooga.queenifyofficial.site/api | Products, auth, stock |
| **Order (Cimol)** | https://cimol.queenifyofficial.site/api | Orders, invoices |

---

## 📦 Dependencies

```json
{
  "express": "^4.18.2",
  "cors": "^2.8.5"
}
```

---

## 🔐 Authentication

- **Frontend → Catalog**: `Bearer <token>`
- **Frontend → Order**: `Bearer <token>` + `x-secret-key: rahasia123`

Login menggunakan Catalog Service, token digunakan untuk kedua service.

---

## 🎯 Alur Transaksi (2-Phase Commit)

Protokol ini sangat krusial untuk mencegah inkonsistensi data stok:

1.  **Phase 1 (Prepare/Reserve)**: Melakukan pengecekan dan reservasi stok di **Catalog Service**.
2.  **Phase 2 (Execute/Order)**: Jika stok tersedia, membuat entri transaksi di **Order Service**.
3.  **Phase 3 (Commit)**: Finalisasi pengurangan stok secara permanen.
4.  **Rollback**: Jika salah satu tahap di atas gagal, sistem secara otomatis membatalkan reservasi stok.

---

**Implementation**:
```javascript
try {
  // Phase 1: Reserve
  const reservation = await reserveStock(items);
  
  // Phase 2: Order
  const orders = await createOrders(items);
  
  // Phase 3: Commit
  await commitReservation(reservation.id);
} catch (error) {
  // Rollback
  await rollbackReservation(reservation.id);
}
```

---

## 📁 Struktur Project

```
Integrasi-Tailore-Service/
├── server.js           # Express server
├── package.json        # Dependencies
├── vercel.json         # Deployment config
├── README.md           # Documentation
└── public/
    └── index.html      # Frontend SPA
```

---

## 🛠️ Development

### Port Configuration
Default: **5000**  
Change via environment:
```bash
PORT=3000 npm start
```

### Tech Stack
- **Frontend**: HTML5, CSS3, Vanilla JS
- **Backend**: Node.js, Express (static server)
- **APIs**: RESTful with JWT
- **Deployment**: Vercel

---

## 🐛 Troubleshooting

**"Harap login dulu!"**
- Token invalid/expired
- Login ulang

**"Keranjang kosong!"**
- Cart kosong di localStorage
- Add products dulu

**Stock reservation failed**
- Product out of stock
- Catalog service down

**Order creation failed**
- Order service down
- Secret key salah

---

## 🌐 Deployment

**Live URL**: [http://tailore-tika.queenifyofficial.site/](http://tailore-tika.queenifyofficial.site/)

---

## 👥 Team

**Tailoré E-Commerce Project**  
**Integration Service by**: Fhatika Adhalisman Ryanjani

---

## 📝 Kesimpulan

Proyek ini berhasil mengintegrasikan Catalog & Order service dengan:
- ✅ 2-Phase Commit untuk data consistency
- ✅ JWT authentication & role-based access
- ✅ Client-side cart dengan localStorage
- ✅ Responsive UI dengan modern design
- ✅ Production deployment
