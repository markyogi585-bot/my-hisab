# My Hisab (Track • Manage • Grow)

> **Premium Fintech Personal Money, Ledger & Expense Tracker Application for Android & iOS**
> Designed according to the dark glassmorphic fintech design system from `file_0000000028188211b7a14728fd5401fb.png`.

---

## 📱 Features

- **Dashboard / Home**:
  - Live Current Balance with privacy eye toggle (`₹ 9,00,000`)
  - Monthly growth metric badge (`+12.5% from last month`)
  - Total Income & Total Expense quick summary cards
  - Quick action buttons (Add Transaction, Reports, Export, More)
  - Recent transactions list with category icons and timestamps
- **Add & Edit Transactions**:
  - Quick Expense (Debit) vs Income (Credit) segmented selector
  - Currency amount input with quick addition chips (`+500`, `+1,000`, `+5,000`, `+10,000`)
  - 4x2 category grid selector with neon border selection and checkmarks
  - Note & description field with character counter
  - Date and time pickers
  - "Save as template" toggle
- **Transactions Ledger**:
  - Grouped timeline view by date with daily expense totals
  - Monthly cashflow header (`+ ₹ 1,20,000` / `- ₹ 30,000`)
  - Debounced search across title, description, category, and amount
  - Filter modal: All / Income / Expense, category filter, sort options, min/max amount range
  - Item detail screen with edit and deletion confirmation
- **Reports & Analytics**:
  - Time horizons: Daily, Weekly, Monthly, Yearly
  - Interactive bezier dual-line trend charts (`fl_chart`)
  - Category-wise donut breakdown chart with percentage breakdown
  - Closing balance comparison card
- **Category Management**:
  - Custom category creation with icon and color picker
  - Category deletion safety with automated transaction migration
- **Data Export**:
  - Export as PDF (formatted summary cards + itemized tables)
  - Export as CSV (compatible with Excel & Google Sheets)
  - Export as TXT
  - Date range filters
  - Direct sharing via native Android/iOS share sheet (`share_plus`)
- **Settings & Security**:
  - Starting Balance configuration
  - Biometric App Lock (`local_auth`)
  - Theme mode (Dark, Light, System)
  - Demo seed data loader
  - Complete data reset

---

## 🛠️ Tech Stack & Architecture

- **Framework**: Flutter 3 (Dart 3, Null-safety)
- **Design System**: Material 3 with custom dark theme, rounded cards (18px), electric blue (`#3B82F6`) and violet accents
- **State Management**: Flutter Riverpod (`StateNotifierProvider`, `FutureProvider`)
- **Routing**: GoRouter with `StatefulShellRoute.indexedStack` (preserves bottom navigation tab states)
- **Local Persistence**: SQLite (`sqflite`), `SharedPreferences`
- **Charts**: `fl_chart`
- **Exporting**: `pdf`, `csv`, `path_provider`, `share_plus`
- **Security**: `local_auth`

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   └── app_constants.dart
│   └── utils/
│       ├── currency_formatter.dart
│       └── date_formatter.dart
├── data/
│   └── local/
│       ├── database_service.dart
│       ├── preferences_service.dart
│       └── seed_data.dart
├── models/
│   ├── category_model.dart
│   ├── export_config.dart
│   ├── transaction_filter.dart
│   └── transaction_model.dart
├── repositories/
│   ├── category_repository.dart
│   ├── settings_repository.dart
│   └── transaction_repository.dart
├── services/
│   ├── biometric_service.dart
│   ├── csv_service.dart
│   ├── export_service.dart
│   └── pdf_service.dart
├── providers/
│   ├── balance_provider.dart
│   ├── category_provider.dart
│   ├── database_provider.dart
│   ├── filter_provider.dart
│   ├── reports_provider.dart
│   ├── settings_provider.dart
│   └── transaction_provider.dart
├── features/
│   ├── home/
│   ├── add_transaction/
│   ├── transactions/
│   ├── reports/
│   ├── categories/
│   ├── export/
│   └── settings/
├── widgets/
│   ├── app_bottom_nav_bar.dart
│   ├── app_card.dart
│   ├── primary_button.dart
│   ├── secondary_button.dart
│   ├── status_badge.dart
│   └── empty_state_view.dart
├── theme/
│   ├── app_decorations.dart
│   ├── app_text_styles.dart
│   └── app_theme.dart
├── routing/
│   └── app_router.dart
└── main.dart
```

---

## 🚀 Running the Project

```bash
cd my_hisab
flutter pub get
flutter run
```

To run tests:
```bash
flutter test
```
