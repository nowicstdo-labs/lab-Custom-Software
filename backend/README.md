# Astha Diagnostic — Production NestJS + PostgreSQL Backend

This directory contains the production-ready, secure, and scalable **NestJS REST API Backend** built for the **Astha Diagnostic Management System**.

---

## 🛠️ Technology Stack

- **Framework**: NestJS (Node.js & TypeScript)
- **Database**: PostgreSQL
- **ORM**: Prisma ORM v5
- **Authentication**: JWT Access (15m) & Refresh Token Rotation (7d), Passport.js
- **Password Hashing**: Argon2id
- **Validation**: Class-Validator & Class-Transformer (DTO Validation)
- **API Documentation**: Swagger / OpenAPI 3.0
- **Security**: Helmet, CORS Allowlist, Rate Limiting (Throttler)
- **Math Evaluator**: Math.js (Restricted expression evaluator for medical formulas)
- **PDF Generation**: PDFKit (Server-side A4 Medical Report Renderer)
- **Containerization**: Docker & Docker Compose

---

## 📁 Directory Structure

```text
backend/
├── prisma/
│   ├── schema.prisma      # PostgreSQL Database Schema & Relational Models
│   └── seed.ts           # Development Database Seeding Script
├── src/
│   ├── main.ts            # Application Bootstrap & Swagger Setup
│   ├── app.module.ts      # Root Application Module
│   ├── common/            # Guards (RBAC), Decorators, Interceptors, Filters
│   ├── database/          # PrismaService & DatabaseModule
│   ├── auth/              # JWT Auth, Argon2 Password Hashing, Patient Registration
│   ├── staff/             # Admin Staff Creation (Doctor, Receptionist, Tech, Admin)
│   ├── tests/             # Diagnostic Test Catalog API
│   ├── bookings/          # Test Booking Service with 10-Patient Slot Capacity Guard
│   ├── formulas/          # Restricted Math Formula Calculation Engine
│   ├── reports/           # Report Lifecycle, PDF Buffer Builder & Public QR Verification
│   └── audit-logs/        # Immutable Security Audit Logging Service
├── .env.example           # Environment Configuration Template
├── Dockerfile             # Multi-stage Docker Build
├── docker-compose.yml     # Containerized PostgreSQL & API Services
└── README.md              # Documentation & Setup Guide
```

---

## ⚡ Quick Start & Setup

### 1. Installation
```bash
cd backend
npm install
```

### 2. Environment Setup
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

### 3. Start PostgreSQL via Docker Compose
```bash
docker compose up -d postgres
```

### 4. Run Prisma Database Migrations & Seed Data
```bash
npx prisma migrate dev --name init
npx prisma db seed
```

### 5. Start NestJS Development Server
```bash
npm run start:dev
```

Server will run at: `http://localhost:3000`  
Swagger API Explorer: `http://localhost:3000/api/docs`

---

## 🔐 Pre-Seeded Development Accounts

| Role | Email | Password | Allowed Access |
| :--- | :--- | :--- | :--- |
| **Admin / Lab Owner** | `admin@asthadiagnostic.com` | `Admin@123` | Staff Creation, Formula Management, Report Approval, Billing, Audit Logs |
| **Doctor** | `doctor@astha.com` | `password` | Consultations, Patient History, Report Approvals |
| **Lab Technician** | `labtech@astha.com` | `password` | Assigned Tests, Sample Scanner, Result Entry, Drafts (Cannot Final Approve) |
| **Receptionist** | `receptionist@astha.com` | `password` | Patient Registration, Queue Management, Invoices |
| **Patient** | `patient@astha.com` | `password` | Self-Booking, My Tests, A4 Report Download |

---

## 🚀 Key Business Rules & Guards Enforced

1. **Public Registration Guard**: `POST /api/v1/auth/register` strictly assigns `Role.PATIENT`. Staff accounts can only be created by an authenticated Admin via `POST /api/v1/staff`.
2. **10-Patient Slot Capacity Rule**: Enforced at the database transaction level (`$transaction`) using row-level locking. Over-booking is physically impossible.
3. **Formula Engine**: Uses a restricted mathematical parser (`mathjs`) allowing only numbers, basic arithmetic operators (`+ - * /`), and approved parameter names (`TOTAL_BIL - DIRECT_BIL`, `TOTAL_PROTEIN - ALBUMIN`, `ALBUMIN / GLOBULIN`).
4. **Report Approval Security Guard**: Lab Technicians are prevented by `@Roles(Role.ADMIN, Role.DOCTOR)` guards from approving final reports.
5. **Public QR Report Verification**: `GET /api/v1/public/reports/verify/:token` provides token validation without leaking sensitive patient passwords or internal database IDs.

---

## 📱 Flutter Frontend Integration

To switch the Flutter application from Mock Mode to Real API Mode:
1. Update `lib/frontend_app.dart` or set `MOCK_MODE = false`.
2. Configure HTTP client base URL: `http://localhost:3000/api/v1`.
