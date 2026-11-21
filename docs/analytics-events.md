# Analytics events

Everything the app reports through `AnalyticsService` (`lib/shared/services/analytics/`).
Every call goes to Firebase Analytics, and in production builds with `MIXPANEL_TOKEN`
also to Mixpanel (EU servers). Users are identified by a SHA-256 fingerprint of the
nickname, never the nickname itself. No content is sent: no post text, discussion
names, recipients or who is blocked.

Keep this file in sync when adding, renaming or removing an event.

## Screens

Sent with `setScreen(name, class)`. Firebase logs `screen_view`, Mixpanel `Screen View`
with `screen` and `screenClass`.

| Screen | Class | When |
|---|---|---|
| `Home` | `HomePage` | Home page opens (after login / cold start). |
| `Bookmarks` | `BookmarksTab` | Switching to the bookmarks tab. |
| `Mailbox` | `MailboxTab` | Mailbox tab opens. |
| `Discussion` | `DiscussionPage` | A discussion opens. |
| `New Message` | `NewMessagePage` | Composer for a post or mail opens. |
| `Gallery` | `GalleryPage` | Image gallery opens. |
| `Notices` | `NoticesPage` | Notifications (ratings and replies) open. |
| `Last` | `Last` | "Poslední" (latest posts) opens. |
| `Reminders` | `Reminders` | Saved reminders open. |
| `Search` | `Search` | Search opens. Both `/search` and `/fulltext` report this name. |
| `Settings` | `SettingsPage` | Settings open. |
| `Settings / Design` | `SettingsDesignScreen` | Appearance settings open. |
| page title | `InfoPage` | An info page opens; today only "O aplikaci". |
| `YearInReview` | `YearInReviewScreen` | "Rok s Fyxem" opens. |
| `Login` | `LoginPage` | Login page opens. |
| `Tutorial` | `TutorialPage` | Onboarding after login opens. |

## Events

### Posts (context menu and post header)

| Event | Parameters | When |
|---|---|---|
| `show_post_replies` | – | The replies sheet opens (reply count in the header or the context menu). |
| `copyPostBody` | – | Copying a post's text. |
| `copyLink` | – | Copying a link to a post. |
| `shareSheet` | – | Sharing a post through the system sheet. |
| `filter_user_posts` | – | Showing the author's posts in a discussion. |
| `filter_user_discussions` | – | Showing the author's posts across discussions. |
| `reminder_add` / `reminder_remove` | – | Adding or removing a post reminder. |
| `hidePost` | – | Hiding a post. |
| `blockUser` | – | Blocking the author. |
| `flagContent` | – | Reporting a post. |

### Market ads

The same actions from an ad's menu. The name is the post event with a ` / ad` suffix.

| Event | Parameters | When |
|---|---|---|
| `copyLink / ad` | – | Copying a link to an ad. |
| `shareSheet / ad` | – | Sharing an ad. |
| `filter_user_posts / ad` | – | Showing the seller's posts. |
| `filter_user_discussions / ad` | – | Showing the seller's posts across discussions. |

### Mail and search

| Event | Parameters | When |
|---|---|---|
| `toggleNsfwMail` | – | Turning NSFW on or off for the mailbox (blurs attachments). |
| `filter_saved_search` | – | Tapping a saved search. |

### Menu

| Event | Parameters | When |
|---|---|---|
| `open_app_release` | `build`: newest build, `current_build`: installed build | Tapping "Sleduj vývoj Fyxu" while its new-version dot is shown. |
| `reportBug` | – | "Nahlásit chybu" in the menu or in settings. |
| `userStats` | – | The statistics sheet opens (beta testers only). |

### "Co je nového" (What's new)

| Event | Parameters | When |
|---|---|---|
| `open_changelog` | `build`: installed build, `found`: 1 when the release post was found, 0 when the club opened instead | "Zobrazit celý changelog". |

### "Rok s Fyxem" (Year in Review)

| Event | Parameters | When |
|---|---|---|
| `yearInReviewOpen` | `source`: `auto` (opened by itself in January), `menu`, `statistics` (beta button) | The story opens. |
| `yearInReviewClose` | `slide`: slide closed on (1-based), `furthest`: furthest slide reached, `slides`: number of slides, `completed`: 1 when the last slide was reached, `seconds`: time open | The story closes. Not sent when no slides loaded. |
| `yearInReviewShare` | – | Sharing the summary card. |

### Settings

| Event | Parameters | When |
|---|---|---|
| `resetAppearance` | – | "Resetovat vzhled". |
| `resetBlockedContent` | – | Resetting blocked content: blocked users, posts and mails, NSFW discussions, the NSFW mailbox and drafts. |
| `emptyCache` | – | Clearing the app storage (cache). |
| `openTerms` | – | Opening the terms of use. |
| `openWhatsNew` | – | Opening "Co je nového" from settings. |
| `logout` | – | Logging out. The user id and user properties are reset afterwards. |

### Onboarding

| Event | Parameters | When |
|---|---|---|
| `tutorial_begin` | – | "Začít" on the first onboarding slide. |
| `tutorial_complete` | – | Defined (`logTutorialComplete`), but never called. |

## User properties

Sent by `trackUserProperties()` (`analytics_user_properties.dart`) as Firebase user
properties and Mixpanel people properties plus super properties, so they are attached
to every Mixpanel event. They are resent only when a value changes: after login, when
the premium status loads, and when settings close.

| Property | Value |
|---|---|
| `theme` | Colour mode: light, dark, system. |
| `skin` | Selected skin. |
| `fontSize` | Font size. |
| `appIcon` | App icon (iOS). |
| `compactMode` | Compact layout on/off. |
| `markdown` | Markdown in the composer on/off. |
| `bulkActions` | Bulk actions on/off. |
| `autocorrect` | Autocorrect on/off. |
| `quickRating` | Quick rating on/off. |
| `fyxImageCache` | Fyx image cache on/off. |
| `defaultView` | Default home view. |
| `firstUnread` | Where a discussion opens (first unread, ...). |
| `linksMode` | How links open. |
| `nsfwMail` | NSFW mailbox on/off. |
| `blockedUsers` | Number of blocked users. |
| `blockedPosts` | Number of hidden posts. |
| `blockedMails` | Number of hidden mails. |
| `nsfwDiscussions` | Number of discussions marked NSFW. |
| `savedSearches` | Number of saved searches. |
| `premium` | Has premium. |
| `premiumUnlocked` | Premium features available (premium or the Christmas unlock). |

Firebase allows at most 25 user properties; 21 are used.

## Automatic events

Besides the above, both SDKs record their own events: Firebase `first_open`,
`session_start`, `app_update`, ..., and Mixpanel (`trackAutomaticEvents: true`)
`$ae_first_open`, `$ae_session`, `$ae_updated`, ....

## Known inconsistencies

- Names mix `camelCase` (`copyLink`) and `snake_case` (`show_post_replies`); ads use a ` / ad` suffix.
- `/search` and `/fulltext` both report the screen `Search`.
- `tutorial_complete` is never sent.
- The discussion home and header screens send no screen view.
