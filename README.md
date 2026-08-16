# Astha Diagnostic — Full-Stack Healthcare Application

This repository contains the separated **Frontend** and **Backend** codebases for the **Astha Diagnostic** Healthcare Management System.

---

## 📁 Project Architecture & Folder Structure

```text
Astha-Diagnostic/
│
├── frontend/             # Flutter Application (Patient, Doctor, Staff, Admin)
│   ├── lib/              # Dart source code (screens, widgets, services, models)
│   ├── assets/           # Images, illustrations, and static assets
│   ├── test/             # Flutter widget and unit tests
│   ├── pubspec.yaml      # Flutter dependencies and configuration
│   └── ...
│
├── backend/              # NestJS REST API Server & Database ORM
│   ├── src/              # TypeScript source code (controllers, services, DTOs)
│   ├── prisma/           # Prisma schema & database migrations
│   ├── .env              # Environment configuration (secrets, DB URL, JWT keys)
│   ├── package.json      # Node.js dependencies and scripts
│   └── ...
│
├── README.md             # Project documentation and developer setup guide
└── .gitignore            # Git exclusion rules
```

---

## 🛠️ Technology Stack

- **Frontend**: Flutter / Dart (Riverpod State Management, GoRouter Navigation, HTTP REST Client)
- **Backend**: NestJS (TypeScript, Node.js, RxJS, Class Validator, Passport JWT)
- **Database & ORM**: PostgreSQL database with Prisma ORM
- **Authentication**: JWT Token-based Auth with RBAC (`PATIENT`, `RECEPTIONIST`, `LAB_TECHNICIAN`, `DOCTOR`, `ADMIN`)

---

## ⚙️ Prerequisites

- **Node.js**: v18.x or higher
- **npm**: v9.x or higher
- **Flutter SDK**: v3.x or higher
- **PostgreSQL**: v14.x or higher (Running locally or via Docker)

---

## 🚀 Step-by-Step Local Setup & Execution

### 1. Launch Backend Server

```bash
# 1. Navigate to backend directory
cd backend

# 2. Install dependencies
npm install

# 3. Create .env file (copy from .env.example if available)
# Ensure DATABASE_URL and JWT_SECRET are correctly configured in backend/.env

# 4. Generate Prisma Client & apply migrations
npx prisma generate
npx prisma migrate dev --name init

# 5. Start NestJS Development Server (runs on http://localhost:3000)
npm run dev
```

### 2. Launch Flutter Frontend Application

Open a second terminal window:

```bash
# 1. Navigate to frontend directory
cd frontend

# 2. Fetch Flutter package dependencies
flutter pub get

# 3. Run Flutter Application
flutter run
```

#### Custom API Base URL Configuration (Optional)
By default, the Flutter application connects to `http://localhost:3000/api/v1`. To point the frontend to a remote server or custom IP:

```bash
cd frontend
flutter run --dart-define=API_BASE_URL=http://YOUR_SERVER_IP:3000/api/v1
```

---

## 🔐 Environment Configuration

The backend reads configuration from `backend/.env`. Key variables include:

```env
PORT=3000
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/astha_db?schema=public"
JWT_SECRET="astha-diagnostic-super-secret-key-2026"
JWT_EXPIRATION="7d"
```

> **Note**: Never commit `backend/.env` to Git. The `.gitignore` file automatically excludes sensitive `.env` files.

---

## 🧪 Testing & Verification

### Run Flutter Analysis & Unit Tests
```bash
cd frontend
flutter analyze
flutter test
```

### Run NestJS Build & Prisma Validation
```bash
cd backend
npx prisma validate
npm run build
```
