# App icons

Users can switch the launcher icon at runtime from **Settings → Vzhled → Ikona
aplikace**. The feature is **iOS only** — Android has no supported way to swap
the launcher icon (the `activity-alias` trick kills the app process and breaks
deep links), so the whole section is hidden behind `Platform.isIOS`. Switching
is gated as a premium feature (`PremiumFeatureEnum.appIcon`); losing premium
locks the picker but never resets an already applied icon.

iOS owns the truth about which icon is applied. `Settings.appIcon` is only a
cache so the picker can render synchronously — on open, the sheet reads back
`FlutterDynamicIconPlus.alternateIconName` and realigns the setting to it.

## Where the pieces live

| What | Where |
|------|-------|
| Icon catalogue | `lib/model/enums/app_icon_enum.dart` |
| Picker UI | `lib/components/bottom_sheets/app_icon_bottom_sheet.dart` |
| Settings entry | `lib/pages/settings_screen.dart` |
| Preview assets | `assets/app_icon*.png` (registered in `pubspec.yaml`) |
| iOS icon sets | `ios/Runner/Assets.xcassets/AppIcon*.appiconset/` |
| iOS build setting | `ios/Flutter/AppIcons.xcconfig` |

## Adding an icon

Five steps, none of them in the Xcode UI. The example adds a Christmas icon.

### 1. Prepare the PNG

1024×1024, **without an alpha channel** — the App Store rejects icons with
transparency. The same file serves as both the Flutter preview and the iOS
source:

```bash
sips -g hasAlpha assets/app_icon-vanoce.png
# if hasAlpha: yes →
ffmpeg -i input.png -vf scale=1024:1024 -pix_fmt rgb24 assets/app_icon-vanoce.png
```

### 2. Register the preview in `pubspec.yaml`

```yaml
  assets:
    - assets/app_icon.png
    - assets/app_icon-dark.png
    - assets/app_icon-vanoce.png   # ← new
```

### 3. Create the App Icon set

```bash
mkdir -p ios/Runner/Assets.xcassets/AppIconVanoce.appiconset
cp assets/app_icon-vanoce.png \
   ios/Runner/Assets.xcassets/AppIconVanoce.appiconset/Icon-App-Vanoce-1024x1024@1x.png
```

with a `Contents.json` next to it. A single size is enough — Xcode derives the
rest:

```json
{
  "images" : [
    {
      "filename" : "Icon-App-Vanoce-1024x1024@1x.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
  ],
  "info" : { "author" : "xcode", "version" : 1 }
}
```

#### Dark mode variant

Without one, iOS shows the light artwork (white background) in dark mode.
Icons that are already dark can skip this. Like the default icon, the dark
variant is the logo on a **transparent** background — iOS fills in its own
dark backdrop. Base it on the shape from `assets/app_icon-transparent.png`,
save it next to the light one and add a second entry:

```json
    {
      "appearances" : [ { "appearance" : "luminosity", "value" : "dark" } ],
      "filename" : "Icon-App-Vanoce-Dark-1024x1024@1x.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    }
```

The Flutter preview keeps using the light PNG only.

### 4. Declare it in `ios/Flutter/AppIcons.xcconfig`

Names are space-separated:

```
ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES = AppIconDark AppIconVanoce
```

**This must not move into `project.pbxproj`.** `flutter_launcher_icons`
rewrites the `ASSETCATALOG_*` settings there on every regeneration and resets
the value to `AppIcon`, silently dropping every alternate icon from the build.
The xcconfig is included from both `Debug.xcconfig` and `Release.xcconfig`
(Profile inherits from Release), so all three configurations are covered.

### 5. Add the enum value

```dart
vanoce(alternateIconName: 'AppIconVanoce', label: 'Vánoční', preview: 'assets/app_icon-vanoce.png');
```

`alternateIconName` must match the `.appiconset` directory name (without the
extension) and the xcconfig entry exactly. The picker grid and the settings
tile derive everything else — nothing further to wire up.

## Verifying

```bash
fvm flutter build ios --no-codesign --debug
plutil -extract CFBundleIcons.CFBundleAlternateIcons xml1 -o - \
  build/ios/iphoneos/Runner.app/Info.plist
```

The output must contain an `AppIconVanoce` key. If it does not, the usual cause
is a mismatch between the xcconfig entry and the directory name.

Actually applying an icon can only be verified on a physical device —
`setAlternateIconName` reliably fails on the Simulator (a known iOS bug). The
failure path (Czech toast + `LogService.captureError`) still behaves correctly
there.

## Gotchas

- **Do not rename an enum value.** The value's `name` is persisted in Hive;
  renaming it silently resets the choice to the default for everyone who had
  that icon selected. The user-facing `label` is free to change.
- **Removing an icon is safe but must be complete.**
  `AppIconEnum.fromAlternateIconName()` falls back to the default for unknown
  names, so stale cached values cause no harm — but remove the enum value, the
  xcconfig entry and the `.appiconset` together, or the bundle ships an icon
  nothing can switch to.
- **iOS shows a system alert** on every successful switch. Suppressing it needs
  a private API and risks App Store rejection, so it stays.
