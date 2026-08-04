# Fyx

Unofficial mobile client for the Czech discussion server Nyx.cz. This context
covers the app's own domain concepts layered on top of Nyx (premium
subscriptions, local statistics), not the Nyx discussion domain itself.

## Language

### Premium

**Premium Status**:
The locally known answer to "does this user have premium features?", together
with the evidence for it (valid-to date, god flag, when it was fetched, for
which nickname).
_Avoid_: subscription, premium flag

**Subscriber**:
A row in the Supabase `subscribers` table — the remote source of truth for
Premium Status.
_Avoid_: premium user (that's a property of the user, not the record)

**God**:
A subscriber with `is_god = true`; has premium forever, with no valid-to date.
Cached god status is trusted for a limited time (TTL), not indefinitely.

**Freshness**:
How trustworthy the cached Premium Status currently is. One of: `fresh` (no
refresh needed), `stale` (refresh wanted, status still honoured), `grace`
(expired but still honoured while refresh keeps failing), `expired` (grace ran
out; premium off), `none` (no cache for this user).
_Avoid_: validity, expiration state

**Grace Period**:
The window after a cached Premium Status expires during which premium features
stay enabled even though a refresh has not succeeded. Only a successful remote
answer of "not premium" — or the end of the Grace Period — turns premium off.

**Refresh**:
Fetching the Subscriber from Supabase and replacing the cached Premium Status
with the result. Never blocks the UI; runs on cold start and resume when the
cache is not fresh, after login, or manually from settings.
