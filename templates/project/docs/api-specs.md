# API Specifications

## Base URL

- **Development**: `http://localhost:3000/api`
- **Staging**: `https://staging.example.com/api`
- **Production**: `https://api.example.com`

## Authentication

### Headers
```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

### Token Format
JWT with payload:
```json
{
  "sub": "user_id",
  "email": "user@example.com",
  "role": "user",
  "exp": 1234567890
}
```

## Response Format

### Success Response
```json
{
  "success": true,
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable message"
  }
}
```

### Pagination Response
```json
{
  "success": true,
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

## Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| UNAUTHORIZED | 401 | Authentication required |
| FORBIDDEN | 403 | Permission denied |
| NOT_FOUND | 404 | Resource not found |
| VALIDATION_ERROR | 400 | Invalid input |
| INTERNAL_ERROR | 500 | Server error |

---

## Endpoints

### Authentication

#### POST /auth/login
Login with credentials.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "jwt_token",
    "user": {
      "id": "user_id",
      "email": "user@example.com",
      "name": "User Name"
    }
  }
}
```

#### POST /auth/register
Create new account.

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "User Name"
}
```

#### POST /auth/refresh
Refresh access token.

**Request:**
```json
{
  "refreshToken": "refresh_token"
}
```

---

### Users

#### GET /users/me
Get current user profile.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user_id",
    "email": "user@example.com",
    "name": "User Name",
    "createdAt": "2024-01-01T00:00:00Z"
  }
}
```

#### PATCH /users/me
Update current user profile.

**Request:**
```json
{
  "name": "New Name"
}
```

---

### Resources (Example CRUD)

#### GET /resources
List resources with pagination.

**Query Parameters:**
| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| page | number | No | 1 | Page number |
| limit | number | No | 20 | Items per page |
| sort | string | No | createdAt | Sort field |
| order | string | No | desc | Sort order (asc/desc) |
| search | string | No | - | Search term |

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "resource_id",
      "title": "Resource Title",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

#### GET /resources/:id
Get single resource.

#### POST /resources
Create new resource.

**Request:**
```json
{
  "title": "Resource Title",
  "description": "Description"
}
```

#### PATCH /resources/:id
Update resource.

#### DELETE /resources/:id
Delete resource.

---

## Webhooks (if applicable)

### Event: resource.created
```json
{
  "event": "resource.created",
  "timestamp": "2024-01-01T00:00:00Z",
  "data": {
    "id": "resource_id",
    "title": "Resource Title"
  }
}
```

---

## Rate Limiting

| Endpoint | Limit |
|----------|-------|
| /auth/* | 10 requests/minute |
| /api/* | 100 requests/minute |
| /upload/* | 20 requests/minute |

Headers returned:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1234567890
```
