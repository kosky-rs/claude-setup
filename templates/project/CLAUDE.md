# Project: [PROJECT_NAME]

## Overview
[Brief project description - 2-3 sentences explaining what this project does]

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | [e.g., React, Vue, Next.js] |
| Backend | [e.g., Node.js, Python, Go] |
| Database | [e.g., PostgreSQL, MongoDB] |
| Cloud | [e.g., AWS, Azure, GCP] |
| CI/CD | [e.g., GitHub Actions, GitLab CI] |

## Project-Specific Rules

### Architecture
@./docs/architecture.md

### API Specifications
@./docs/api-specs.md

## Directory Structure

```
src/
├── components/    # [description]
├── pages/         # [description]
├── api/           # [description]
├── lib/           # [description]
├── types/         # [description]
└── utils/         # [description]
```

## MCP Usage Guidelines

| MCP Server | Purpose | When to Use |
|------------|---------|-------------|
| context7 | Library documentation | BEFORE using unfamiliar library |
| postgresql | DB schema/queries | Before migrations, data verification |
| puppeteer | Browser screenshots | After UI implementation |

## Commands

### Development
```bash
npm run dev       # Start development server
npm run build     # Build for production
npm run lint      # Run linter
```

### Testing
```bash
npm test          # Run unit tests
npm run test:e2e  # Run E2E tests
npm run test:cov  # Run tests with coverage
```

### Database
```bash
npm run db:migrate    # Run migrations
npm run db:seed       # Seed database
npm run db:reset      # Reset database
```

## Environment Variables

See `.env.example` for required variables.

**Critical variables:**
- `DATABASE_URL` - Database connection string
- `API_KEY` - External API key
- `[other critical vars]`

## Coding Conventions

### This Project Specific
- [Convention 1]
- [Convention 2]
- [Convention 3]

### Naming Patterns
- Components: `PascalCase.tsx`
- Utilities: `camelCase.ts`
- Types: `types.ts` or `*.types.ts`

## Known Issues / Technical Debt

- [ ] [Issue 1]
- [ ] [Issue 2]

## External Dependencies

| Service | Purpose | Documentation |
|---------|---------|---------------|
| [Service 1] | [Purpose] | [Link] |
| [Service 2] | [Purpose] | [Link] |
