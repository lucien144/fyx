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

**Christmas Unlock**:
Easter egg: from December 24 to 31 premium features are available to everyone.
It does not change the Premium Status — the user is not premium, the features
are just unlocked. Statistics (Year in Review) stay subscriber-only.

**Refresh**:
Fetching the Subscriber from Supabase and replacing the cached Premium Status
with the result. Never blocks the UI; runs on cold start and resume when the
cache is not fresh, after login, or manually from settings.

### Statistics

**Statistics**:
The raw per-year usage numbers the app collects locally on the device (time in
app, scroll distance, ratings, posts, streaks, top discussions), shown as a
plain list. Nothing leaves the device.
_Avoid_: userstats (that's the module name), analytics (that's Firebase)

**Year in Review**:
A story-style walkthrough of one year's Statistics, shown to the user as "Rok s
Fyxem". Always about one specific year: the previous year during the January
Window, the running year when a beta tester opens it from Statistics. A premium
easter egg — it is not advertised among the premium features.
_Avoid_: Wrapped, recap, stories

**January Window**:
The first 14 days of January, when the Year in Review for the previous year is
offered to premium users: once on its own, and on demand from the menu. Users
with fewer than 7 active days in that year are not offered it.

**Active Day**:
A calendar day on which the user opened the app at least once.

**Streak**:
A run of consecutive Active Days within one year.

**Rhythm**:
The label a Year in Review gives the user for the hour of day they are most
active in (e.g. "Ranní ptáče", "Fachman").

**Character**:
The film character a Year in Review assigns the user from the share of
positive ratings among all ratings they gave (e.g. Gandalf, Tichý Bob).
_Avoid_: persona, mood
