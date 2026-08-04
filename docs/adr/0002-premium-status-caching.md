# ADR 0002 — Premium status caching policy

- **Status:** Accepted
- **Date:** 2026-08-03

## Context

Premium features are gated by the Supabase `subscribers` table. The original
implementation queried Supabase on every cold start and blocked on the result;
any Supabase or network outage silently turned premium features off until the
next successful start.

## Decision

Premium Status is cached locally and honoured according to a freshness policy;
the remote is only consulted when the cache is not fresh, and never on the UI's
critical path.

- **Fresh windows:** a premium status is fresh until `valid_to`; a god status
  (`is_god`, no `valid_to`) is fresh for 7 days after fetch; a negative
  ("not premium") result is fresh for 24 hours after fetch.
- **Grace period:** after a premium/god status stops being fresh, it is still
  honoured for another 7 days while refreshes are attempted. Premium is turned
  off only by a successful remote answer of "not premium", or by the end of the
  grace period.
- **Refresh triggers:** cold start and resume (only when not fresh), after
  login, and manually from settings. Refreshes run in the background and never
  block startup.
- **Local evaluation:** the client fetches the subscriber row by nickname alone
  (no server-side `valid_to`/`is_god` filter) and evaluates premium locally —
  otherwise `valid_to` could not be cached.
- **Cache identity:** the cached record stores the nickname it belongs to and
  is ignored when it does not match the current credentials.

## Considered options

- **Fail-closed** (status quo): expired cache or failed refresh means no
  premium. Rejected — this is exactly the outage problem being fixed.
- **Fail-open**: last known status holds until a successful refresh says
  otherwise. Rejected — a lapsed subscriber who stays offline would keep
  premium indefinitely.
- **Grace period** (chosen): outages up to a week cost nobody their features,
  while a lapsed subscription cannot outlive the grace window.
