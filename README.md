```markdown
# SaaS Musicians Sell Beats

A SaaS platform enabling musicians to sell beats online.

[![Next.js](https://img.shields.io/badge/Next.js-13-blue?logo=next.js)](https://nextjs.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.95-green?logo=fastapi)](https://fastapi.tiangolo.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

## Features

- Beat upload & management
- Digital storefront
- Payment processing
- Artist profiles
- Licensing options

## Quick Start

1. Clone repo:
```bash
git clone https://github.com/your-repo/saas-musicians-sell-beats.git
```

2. Install dependencies:
```bash
cd saas-musicians-sell-beats
npm install  # Frontend
pip install -r requirements.txt  # Backend
```

## Environment Setup

Create `.env` files:

**Frontend (Next.js):**
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

**Backend (FastAPI):**
```env
DATABASE_URL=postgresql://user:pass@localhost:5432/beatsdb
SECRET_KEY=your-secret-key
```

## Deployment

1. Build frontend:
```bash
npm run build
```

2. Start backend:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

3. Deploy via Docker (recommended):
```bash
docker-compose up --build
```

## License

MIT - See [LICENSE](LICENSE) for details.
```