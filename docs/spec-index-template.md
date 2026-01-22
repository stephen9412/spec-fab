# Product Specification Index (Master)
**Project Name**: [PROJECT_NAME]
**Last Updated**: [DATE]

> **AI INSTRUCTION**: This document is the "Product Manager's Brain". It defines NOT JUST what we build, but WHO we build for and WHAT WE AVOID.
> **Dynamic Update Rule**: Whenever a new User Story is finalized or a Feature is rejected, update this file immediately.

## 1. The "Soul" of the Product
### North Star Vision
[One sentence that defines the ultimate success. e.g., "Make video editing as easy as sending a text message for non-techies."]

### User Personas (Deep Context)
* **Persona A: [The Name]**
    * **Role**: [e.g., Shop Clerk, 50 years old, impatient.]
    * **Tech Literacy**: [e.g., Can use Line/WhatsApp, afraid of "Settings" menus.]
    * **Pain Points**: [e.g., Hates waiting, gets panic attacks if errors appear.]
* **Persona B: [The Name]**
    * ...

### Anti-Goals (The "No" List)
* **NO Cloud Dependencies**: We will not rely on AWS/GCP APIs for core logic.
* **NO Enterprise Features**: No SSO, no complex role management (RBAC).
* **NO Social Networking**: We are a tool, not a platform.

## 2. Feature Registry & Roadmap
| ID | Feature Name | Core Value | Status | Dependencies |
| :--- | :--- | :--- | :--- | :--- |
| `001` | `viral-video-gen` | One-click creation | **Live** | None |
| `002` | `shop-tv-player` | Auto-loop playback | **Planned** | `001` (Output Folder) |

## 3. Global Business Rules (The Invariants)
* **Pricing/Money**: [e.g., All calculations must be integer-based (cents), no floats.]
* **Validation**: [e.g., Phone numbers must be parsed to E.164 format before storage.]
* **UX Law**: [e.g., Every "Process" longer than 1s must show a progress bar.]

## 4. Domain Dictionary & Ubiquitous Language
* **"Clip"**: A generated video file (under 30s).
* **"Workflow"**: The ComfyUI JSON definition, NOT the business process.

## 5. Graveyard of Ideas (Rejected Specs)
* **Rejected**: "Mobile App Companion"
    * **Why**: Too high maintenance cost for V1. Stick to Web PWA.
* **Rejected**: "AI Voiceover"
    * **Why**: Costs money per API call. Violates "Local-First" rule for now.

---
*AI Open Section: Add observations about user behavior or business pivots below.*
