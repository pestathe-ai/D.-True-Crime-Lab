#!/usr/bin/env bash
# Genera le cartelle android/ios e applica le modifiche necessarie.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter create --project-name d_true_crime_lab --org dev.dtruecrimelab \
  --platforms=android,ios . >/dev/null
rm -f test/widget_test.dart

GRADLE=android/app/build.gradle.kts
MANIFEST=android/app/src/main/AndroidManifest.xml

python3 - "$GRADLE" "$MANIFEST" <<'PY'
import re, sys
gradle, manifest = sys.argv[1], sys.argv[2]

g = open(gradle).read()
# minSdk 24
g = re.sub(r'minSdk\s*=\s*[^\n]+', 'minSdk = 24', g, count=1)
# Desugaring richiesto da flutter_local_notifications
if 'isCoreLibraryDesugaringEnabled' not in g:
    g = g.replace('compileOptions {', 'compileOptions {\n        isCoreLibraryDesugaringEnabled = true', 1)
if 'desugar_jdk_libs' not in g:
    g += '\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
open(gradle, 'w').write(g)

m = open(manifest).read()
perms = [
    'android.permission.POST_NOTIFICATIONS',
    'android.permission.RECEIVE_BOOT_COMPLETED',
    'android.permission.VIBRATE',
    'android.permission.USE_EXACT_ALARM',
]
block = ''.join(f'    <uses-permission android:name="{p}"/>\n' for p in perms if p not in m)
block += '    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" android:maxSdkVersion="32"/>\n'
m = re.sub(r'(<manifest[^>]*>\n)', r'\1' + block.replace('\\', '\\\\'), m, count=1)

receivers = '''        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
'''
if 'ScheduledNotificationReceiver' not in m:
    m = m.replace('</application>', receivers + '    </application>', 1)

tts = '        <intent>\n            <action android:name="android.intent.action.TTS_SERVICE" />\n        </intent>\n'
if 'TTS_SERVICE' not in m:
    if '<queries>' in m:
        m = m.replace('<queries>', '<queries>\n' + tts, 1)
    else:
        m = m.replace('</manifest>', '    <queries>\n' + tts + '    </queries>\n</manifest>', 1)

# Nome visibile dell'app
m = re.sub(r'android:label="[^"]*"', 'android:label="D. True Crime Lab"', m, count=1)
open(manifest, 'w').write(m)
PY

echo "--- build.gradle.kts (estratto)"
grep -n -E 'minSdk|Desugaring|desugar' "$GRADLE" || true
echo "--- AndroidManifest.xml"
cat "$MANIFEST"

# iOS: nome visibile
if [[ "$(uname)" == "Darwin" ]]; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName D. True Crime Lab" ios/Runner/Info.plist || true
fi

flutter pub get
dart run flutter_launcher_icons
