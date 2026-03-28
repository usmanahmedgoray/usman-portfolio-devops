# Project Specifications: Usman Ahmed Portfolio

## 📋 Overview

| Attribute | Details |
|-----------|---------|
| **Project Name** | Personal Portfolio |
| **Version** | 0.1.0 |
| **Type** | Personal Portfolio Website |
| **Developer** | Usman Ahmed (MERN Stack Developer) |
| **Status** | Production-Ready |

---

## 🏗️ Architecture

### Technology Stack

| Category | Technology | Version |
|----------|-----------|---------|
| **Framework** | Next.js (Pages Router) | 13.4.10 |
| **Frontend** | React | 18.2.0 |
| **Styling** | Tailwind CSS | 3.3.3 |
| **Animations** | Framer Motion | ^10.13.0 |
| **Icons** | React Icons | ^4.10.1 |
| **Build Tool** | PostCSS | 8.4.26 |
| **CSS Processing** | Autoprefixer | 10.4.14 |
| **Linting** | ESLint | 8.45.0 |

### Containerization & DevOps

| Tool | Purpose |
|------|---------|
| **Docker** | Containerization (multi-arch: amd64, arm64) |
| **GitHub Actions** | CI/CD Pipeline |
| **Docker Hub** | Container Registry |
| **Hadolint** | Dockerfile Linting |
| **Gitleaks** | Secret Scanning |
| **Trivy** | Vulnerability Scanning |

---

## 📁 Project Structure

```
usman-portfolio-devops/
├── .github/workflows/
│   └── production-build.yml    # CI/CD Pipeline
├── pages/
│   ├── _app.js                 # App entry point
│   ├── _document.js            # Custom document
│   ├── index.js                # Home page
│   ├── About.js                # About page
│   ├── Projects.js             # Projects showcase
│   ├── Articles.js             # Blog/articles page
│   ├── Layout.js               # Main layout component
│   └── Component/              # Reusable components
│       ├── AnimatedText.js
│       ├── HireMe.js
│       └── TransitionEffect.js
├── public/
│   └── Images/                 # Static assets
├── styles/
│   └── globals.css             # Global styles
├── specs/
│   └── PROJECT_SPECIFICATIONS.md
├── next.config.js              # Next.js configuration
├── tailwind.config.js          # Tailwind configuration
├── postcss.config.js           # PostCSS configuration
├── jsconfig.json               # JavaScript path aliases
├── .eslintrc.json              # ESLint configuration
└── package.json                # Dependencies & scripts
```

---

## 🎯 Features

### User-Facing Features
- **Home Page:** Hero section with animated text, profile image, CTA buttons
- **About Page:** Personal background and skills
- **Projects Page:** Portfolio showcase
- **Articles Page:** Blog/writing section
- **Dark Mode Support:** Via Tailwind CSS dark mode
- **Responsive Design:** Mobile-first approach
- **Page Transitions:** Smooth animations via Framer Motion
- **Resume Download:** PDF download link
- **Contact Integration:** Email link for inquiries

### Developer Features
- **Hot Reload:** Next.js dev server
- **Code Quality:** ESLint integration
- **Type Safety:** JSDoc via jsconfig.json
- **Component-Based:** Modular architecture
- **Image Optimization:** Next.js Image component

---

## 🚀 CI/CD Pipeline Specification

### Workflow Triggers
| Event | Condition |
|-------|-----------|
| Push | `main` branch |
| Tag | Semantic versioning (`v*.*.*`) |
| Pull Request | Targeting `main` branch |
| Manual | Workflow dispatch button |

### Pipeline Jobs

#### Job 1: Code Quality & Security (`check-quality`)
- **Runner:** `ubuntu-latest`
- **Timeout:** 10 minutes
- **Steps:**
  1. Checkout code (SHA-pinned for security)
  2. Hadolint Dockerfile linting (ignores: DL3018, DL3006)
  3. Gitleaks secret scanning
  4. Upload SARIF results to GitHub Security

#### Job 2: Build & Push (`build-and-push`)
- **Runner:** `ubuntu-latest`
- **Timeout:** 30 minutes
- **Dependencies:** `check-quality`
- **Steps:**
  1. Checkout code
  2. Setup Docker Buildx
  3. Extract metadata (tags, labels)
  4. Login to Docker Hub (skip on PR)
  5. Build & push Docker image
     - Multi-arch on main: `linux/amd64`, `linux/arm64`
     - Single-arch on PR: `linux/amd64`
  6. Trivy vulnerability scan (main branch only)
  7. Upload Trivy SARIF results

#### Job 3: Notifications (`notify`)
- **Runner:** `ubuntu-latest`
- **Condition:** Always runs (success/failure)
- **Channels:**
  - Telegram (via bot)
  - Email (Gmail SMTP)
  - Discord (webhook)

#### Job 4: Cleanup (`cleanup`)
- **Condition:** Main branch push only
- **Action:** Delete old Docker images (keep latest 5) using Docker Hub API + curl/jq

### Docker Image Tagging Strategy
| Tag Type | Pattern | Example |
|----------|---------|---------|
| Latest | `latest` | `nextjs-enterprise-app:latest` |
| Branch | `{branch}` | `nextjs-enterprise-app:main` |
| PR | `pr-{number}` | `nextjs-enterprise-app:pr-42` |
| SemVer | `{version}` | `nextjs-enterprise-app:1.2.3` |
| Commit SHA | `sha-{short}` | `nextjs-enterprise-app:sha-5fa9009` |

---

## ⚙️ Configuration Details

### Next.js Configuration (`next.config.js`)
```javascript
{
  reactStrictMode: true,
  output: 'standalone',        // Docker optimization
  compress: true,
  poweredByHeader: false,
  images: {
    unoptimized: process.env.NODE_ENV === 'production'
  }
}
```

### NPM Scripts
| Script | Command | Purpose |
|--------|---------|---------|
| `dev` | `next dev` | Start development server |
| `build` | `next build` | Production build |
| `start` | `next start` | Start production server |
| `lint` | `next lint` | Run ESLint |

---

## 🔐 Security Measures

1. **Secret Management:** GitHub Secrets for sensitive data
2. **SHA-Pinned Actions:** All GitHub Actions use commit hashes
3. **Read-Only Permissions:** Default workflow permissions
4. **Vulnerability Scanning:** Trivy scans for CVEs
5. **Secret Scanning:** Gitleaks prevents credential leaks
6. **Code Linting:** Hadolint ensures Dockerfile best practices

---

## 📊 Required Secrets

| Secret Name | Purpose |
|-------------|---------|
| `DOCKER_USERNAME` | Docker Hub username |
| `DOCKER_PASSWORD` | Docker Hub access token |
| `TELEGRAM_CHAT_ID` | Telegram bot chat ID |
| `TELEGRAM_TOKEN` | Telegram bot token |
| `EMAIL_USERNAME` | Gmail address for notifications |
| `EMAIL_PASSWORD` | Gmail app password |
| `TEAM_EMAIL` | Recipient email for alerts |
| `DISCORD_WEBHOOK` | Discord webhook URL (optional) |

---

## 🎨 Design Specifications

### Color Scheme
- **Light Mode:** Dark text on light background
- **Dark Mode:** Light text on dark background
- **Accent Colors:** Configurable via Tailwind config

### Typography
- Responsive font sizes (mobile-first)
- Tailwind CSS utility classes

### Animations
- Page transitions via Framer Motion
- Animated text components
- Smooth hover effects

---

## 📈 Performance Optimizations

1. **Standalone Output:** Minimal Next.js build for Docker
2. **Image Optimization:** Next.js Image component
3. **Code Splitting:** Automatic via Next.js
4. **Caching Strategy:** Docker layer caching via GitHub Actions
5. **Compression:** Gzip compression enabled
6. **Powered-By Header:** Removed for security

---

## 🔄 Deployment Flow

```
┌─────────────┐
│ Code Push   │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Quality     │
│ Checks      │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Docker      │
│ Build       │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Security    │
│ Scan        │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Push to     │
│ Docker Hub  │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Notify      │
│ Team        │
└─────────────┘
```

---

## 📝 Notes

- Project uses **Next.js Pages Router** (not App Router)
- Comments in config files are in **Urdu/Hindi**
- Portfolio is designed for **single-page application** feel
- **No TypeScript** - uses JavaScript with JSDoc
- **Monorepo support disabled** in `next.config.js`

---

## 📞 Contact Information

| Platform | Details |
|----------|---------|
| **Email** | usmanahmedkharal@gmail.com |
| **Resume** | `/UsmanResume.pdf` (public folder) |

---

*Document generated: March 28, 2026*
