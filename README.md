# 💊 PharmaCare — Complete Pharmacy Management App

A production-ready Pharmacy Management System built with **Flutter**, **Firebase**, and **Clean Architecture**.

---

## 📦 Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter (Material 3) |
| State Management | Riverpod (Notifier pattern) |
| Architecture | Clean Architecture (Domain → Data → Presentation) |
| Backend | Firebase (Auth, Firestore, Storage) |
| Navigation | GoRouter |
| Charts | fl_chart |
| PDF | pdf + printing |
| Scanner | mobile_scanner |

---

## 🚀 Getting Started

### 1. Prerequisites
- Flutter SDK 3.3.0+
- Firebase project (Firestore, Auth, Storage enabled)
- FlutterFire CLI installed

### 2. Clone & Install
```bash
git clone https://github.com/yourusername/pharma_care.git
cd pharma_care
flutter pub get
```

### 3. Firebase Setup
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure
```
This generates `lib/firebase_options.dart`.

### 4. Activate main.dart
Open `lib/main.dart` and uncomment the import lines.

### 5. Run
```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart
├── core/
│   ├── errors/          # Failures & Exceptions
│   ├── usecases/        # Base UseCase classes
│   ├── router/          # GoRouter config (20 routes)
│   ├── services/        # PDF service
│   └── theme/           # Light & Dark AppTheme
│
└── features/
    ├── auth/            # Login, Register, RoleGuard
    ├── dashboard/       # KPIs, Real-time stats
    ├── medicines/       # Add/Edit/Delete/Search
    ├── inventory/       # Batches, PO, Stock, FIFO
    ├── sales/           # POS, Cart, Invoice, Tax
    ├── pdf/             # A4 Invoice PDF
    ├── reports/         # 6 report tabs + charts
    ├── customers/       # Customer CRUD + loyalty
    ├── suppliers/       # Supplier management
    ├── notifications/   # Expiry + Low stock alerts
    ├── barcode/         # QR/Barcode scanner
    ├── voice_search/    # Speech-to-text search
    ├── export/          # Excel + PDF export
    ├── stores/          # Multi-branch support
    ├── recommendations/ # AI medicine suggestions
    ├── backup/          # Firestore backup + restore
    └── settings/        # Dark mode + Pharmacy config
```

---

## ✅ Features

- 🔐 Authentication (Login, Register, Role-Based: Admin/Manager/Cashier)
- 📊 Dashboard with real-time KPIs
- 💊 Medicine Management (CRUD + Search)
- 📦 Inventory (Batch/FIFO, Purchase Orders, Adjustments)
- 🛒 Sales & POS (Cart, Invoice, Tax, Discount)
- 📄 PDF Invoice (A4, Download, Share, Print)
- 📈 Reports (Daily/Weekly/Monthly/Profit/Inventory + charts)
- 📷 Barcode & QR Scanner
- 🎤 Voice Search
- 👥 Customer & Supplier Management
- 🌙 Dark Mode
- 🏪 Multi-Store Support
- 🔔 Push Notifications (Expiry + Low Stock)
- 📊 Export to Excel & PDF
- 🤖 AI Medicine Recommendations
- ☁️ Backup & Restore to Firebase Storage

---

## 📋 Firestore Collections

`users` · `medicines` · `batches` · `invoices` · `purchaseOrders`
`customers` · `suppliers` · `stores` · `stockAdjustments`
`notifications` · `backups` · `settings`

---

Made with ❤️ using Flutter & Firebase
