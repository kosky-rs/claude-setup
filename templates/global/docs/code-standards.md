# Code Standards

## General Principles

### Readability First
- Write self-documenting code
- Use clear, descriptive names
- Keep functions small and focused
- Prefer explicit over implicit

### Consistency
- Follow existing project patterns
- Match surrounding code style
- Use project-specific linter rules

### Simplicity
- Avoid premature optimization
- Don't over-engineer
- Prefer composition over inheritance
- YAGNI (You Aren't Gonna Need It)

## Language-Specific Standards

### TypeScript/JavaScript

```typescript
// Prefer const over let
const value = 42;

// Use async/await over callbacks
async function fetchData() {
  const response = await fetch(url);
  return response.json();
}

// Explicit return types for public functions
function calculateTotal(items: Item[]): number {
  return items.reduce((sum, item) => sum + item.price, 0);
}

// Use strict equality
if (value === expected) { }

// Destructure when appropriate
const { name, email } = user;

// Use template literals
const message = `Hello, ${name}!`;
```

### Python

```python
# Follow PEP 8
def calculate_total(items: list[Item]) -> float:
    """Calculate the total price of items."""
    return sum(item.price for item in items)

# Use type hints
def process_data(data: dict[str, Any]) -> Result:
    pass

# Prefer f-strings
message = f"Hello, {name}!"

# Use dataclasses for data structures
@dataclass
class User:
    name: str
    email: str
    created_at: datetime = field(default_factory=datetime.now)

# Use context managers
with open(filepath, 'r') as f:
    content = f.read()
```

## Git Commit Messages

### Format
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types
| Type | Description |
|------|-------------|
| feat | New feature |
| fix | Bug fix |
| refactor | Code restructuring (no behavior change) |
| docs | Documentation changes |
| test | Test additions/changes |
| chore | Maintenance tasks |
| style | Formatting, whitespace |
| perf | Performance improvement |

### Examples
```
feat(auth): add JWT token refresh endpoint

fix(api): handle null response from external service

refactor(user): extract validation logic to separate module

docs: update API documentation with new endpoints

test(auth): add integration tests for login flow
```

### Rules
- Use imperative mood ("add" not "added")
- Keep first line under 72 characters
- Reference issue numbers when applicable
- Explain "why" in body if not obvious

## Testing Requirements

### Coverage Targets
| Type | Minimum | Target |
|------|---------|--------|
| Unit Tests | 70% | 85% |
| Integration | Key paths | All paths |
| E2E | Critical flows | Main flows |

### Test Structure
```typescript
describe('ComponentName', () => {
  describe('methodName', () => {
    it('should do expected behavior when given valid input', () => {
      // Arrange
      const input = createTestInput();
      
      // Act
      const result = component.methodName(input);
      
      // Assert
      expect(result).toBe(expected);
    });

    it('should throw error when given invalid input', () => {
      expect(() => component.methodName(null)).toThrow();
    });
  });
});
```

### What to Test
- Happy path (normal operation)
- Edge cases (empty, null, boundary values)
- Error conditions
- State transitions

## Documentation Standards

### Code Comments
```typescript
// BAD: Explains "what" (obvious from code)
// Increment counter by 1
counter++;

// GOOD: Explains "why" (not obvious)
// Reset counter after reaching max to prevent overflow
if (counter >= MAX_VALUE) counter = 0;
```

### Function Documentation
```typescript
/**
 * Calculates the discounted price for a product.
 * 
 * @param price - Original price in cents
 * @param discountPercent - Discount as percentage (0-100)
 * @returns Discounted price in cents, rounded down
 * @throws {RangeError} If discount is not between 0-100
 */
function calculateDiscount(price: number, discountPercent: number): number {
  // ...
}
```

### README Requirements
- Project overview
- Setup instructions
- Development workflow
- API documentation (if applicable)
- Deployment guide

## Error Handling

### Principles
- Fail fast, fail loud
- Provide actionable error messages
- Log sufficient context
- Don't swallow exceptions

### Pattern
```typescript
try {
  const result = await riskyOperation();
  return result;
} catch (error) {
  logger.error('Operation failed', {
    operation: 'riskyOperation',
    context: { userId, requestId },
    error: error.message,
  });
  throw new OperationError('Failed to complete operation', { cause: error });
}
```

## File Organization

### Naming Conventions
| Type | Convention | Example |
|------|------------|---------|
| Files | kebab-case | `user-service.ts` |
| Classes | PascalCase | `UserService` |
| Functions | camelCase | `getUserById` |
| Constants | UPPER_SNAKE | `MAX_RETRY_COUNT` |
| Types/Interfaces | PascalCase | `UserProfile` |

### Directory Structure
```
src/
├── components/     # UI components
├── services/       # Business logic
├── utils/          # Utility functions
├── types/          # Type definitions
├── hooks/          # Custom hooks (React)
├── api/            # API layer
└── config/         # Configuration
```
