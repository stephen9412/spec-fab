# Technical Implementation Master Plan
**Project Name**: [PROJECT_NAME]
**Last Updated**: [DATE]

> **AI INSTRUCTION**: This document is the "Chief Architect's Brain". It prioritizes CONSISTENCY over novelty. Use the "Cookbook" section to write code that looks like it was written by the same person.

## 1. Architecture Decision Records (ADR Snapshot)
* **ADR-001: Local Filesystem vs Database**
    * **Decision**: Use `pathlib` + JSON metadata sidecars.
    * **Why**: No DB migration overhead; easy for users to backup (just copy folder).
* **ADR-002: Queue Implementation**
    * **Decision**: In-memory `Queue` with file-based locking.
    * **Why**: Redis is overkill for a single-machine deployment.

## 2. The "Immutable" Tech Stack
* **Language**: Python 3.11+ (Type Hints Mandatory)
* **Frontend**: Vanilla JS (ES6 Modules) + Tailwind CSS (CDN/Local)
* **Backend**: FastAPI (Async Native)
* **Testing**: `pytest` (Backend), Manual (Frontend)

## 3. The Cookbook (Code Idioms & Patterns)
### Pattern: Error Handling
```python
# GOOD: Always use the custom AppError
from src.core.errors import AppError
if not valid:
    raise AppError(code="INVALID_INPUT", msg="The file is corrupt")

# BAD: Do not raise generic exceptions
raise Exception("Error")

```

### Pattern: File Operations

```python
# GOOD: Use Atomic Writes
from src.utils.fs import atomic_write
atomic_write(path, data)

# BAD: Don't use raw open() for critical data
with open(path, 'w') as f: ...

```

## 4. System Topology (The Map)

```text
root/
├── src/
│   ├── core/          # Pure Python logic (No HTTP dependencies)
│   ├── api/           # FastAPI routers (Thin wrappers around core)
│   └── adapters/      # ComfyUI connectors / Hardware IO
└── data/              # Runtime storage (Gitignored)

```

## 5. Reusable Components Registry

* **`JobQueue`** (`src/core/queue.py`): The only way to run heavy tasks.
* **`LogManager`** (`src/utils/logger.py`): Structured JSON logging.

## 6. Technical Debt & Watchlist

* **WARN**: The `JobQueue` is not persistent across restarts. (Accepted risk for V1).
* **TODO**: `src/adapters/comfy.py` needs a retry mechanism for timeout.

---

*AI Open Section: Add new discovered design patterns or library constraints below.*
