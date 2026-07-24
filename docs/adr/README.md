# Architecture Decision Records

This directory holds Architecture Decision Records (ADRs) — short documents that
capture a significant architectural decision, its context and its consequences.

## Convention

- One file per decision: `NNNN-short-title.md` (zero-padded, incrementing).
- Each ADR has a **Status** (`Proposed`, `Accepted`, `Superseded by NNNN`,
  `Deprecated`) and a **Date**.
- ADRs are immutable once accepted. To change a decision, add a new ADR that
  supersedes the old one rather than editing history.

## Index

| ADR | Title | Status |
|-----|-------|--------|
| [0001](0001-feature-architecture.md) | Feature architecture: MVVM over a use-case-less Clean Architecture | Accepted |
