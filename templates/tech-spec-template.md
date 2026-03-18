# [Project Name] -- Tech Spec

> Architecture decisions, data structures, and API designs in code must follow this document. When modifying technical solutions, update this document first, then change the code.

---

## Architecture Overview

### Overall Architecture
<!-- Describe the high-level system architecture in text, e.g., client-only / client + cloud functions / frontend-backend separation / microservices -->
[Description]

### Architecture Diagram
<!-- Optional: ASCII diagram or descriptive text -->

### Key Architecture Constraints
<!-- List architecture decisions that cannot be changed arbitrarily, with reasons -->
| Constraint | Reason |
|------------|--------|
| ... | ... |

---

## Data Model

### Core Entities
<!-- List fields, types, and constraints for each entity -->

#### [Entity Name]
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| ... | ... | ... | ... |

### Entity Relationships
<!-- Describe relationships between entities: one-to-many, many-to-many, etc. -->

### Local Storage Strategy
<!-- If applicable: CoreData / SQLite / UserDefaults / file system, etc. -->

---

## API Contracts

### Internal Interfaces
<!-- Key interface definitions between modules: function signatures, parameters, return values -->

### External APIs
<!-- If applicable: backend endpoints, cloud functions, third-party APIs -->

#### [Interface Name]
- Endpoint: [URL / function name]
- Method: [GET / POST / cloud function call]
- Request parameters:
- Response format:
- Error codes:

---

## State Management

### Global State
<!-- Application-level state: user auth status, theme, language, etc. -->

### Page/Module State
<!-- State management approach within each module -->

---

## Third-Party Service Integrations

| Service | Purpose | SDK/Method | Configuration Notes |
|---------|---------|------------|---------------------|
| ... | ... | ... | ... |

---

## Infrastructure

### Environment Configuration
<!-- Differences between development/testing/production environments -->

### Build & Deployment
<!-- CI/CD, signing, release process, etc. -->

### Security
<!-- Sensitive data handling, encryption, access control -->

---

## Error Handling

### Error Code System
<!-- If applicable -->

| Error Code | Meaning | Handling Approach |
|------------|---------|-------------------|
| ... | ... | ... |

### Exception Fallback Strategy
<!-- Network errors, data anomalies, crash recovery, etc. -->
