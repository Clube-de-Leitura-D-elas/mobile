# CLAUDE.md

Flutter app (Android/iOS) for Clube de Leitura D'elas, backed by Supabase.

## Running on Android without exhausting memory

The dev machine has ~16 GB RAM. `android/gradle.properties` allows Gradle up to 8 GB heap + 4 GB
metaspace, which together with the emulator and a browser can freeze the system. Follow these steps.

### One-time setup

1. Cap Gradle in `~/.gradle/gradle.properties` (user-level settings override the project file):
   ```properties
   org.gradle.jvmargs=-Xmx2g -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError
   org.gradle.workers.max=4
   kotlin.daemon.jvmargs=-Xmx1g
   ```
2. Install earlyoom so Linux kills the biggest process instead of freezing when memory runs out:
   ```bash
   sudo apt install earlyoom && sudo systemctl enable --now earlyoom
   ```

### Every session

1. Close what you don't need: Docker Desktop (its VM reserves several GB) unless the local
   backend is required, and extra Chrome tabs.
2. Start the emulator capped at 2 GB RAM / 2 cores (`Pixel_5_API_34` is the lightest image, no Play Store):
   ```bash
   ~/Android/Sdk/emulator/emulator -avd Pixel_5_API_34 -memory 2048 -cores 2 -gpu host -no-boot-anim -no-audio &
   ```
3. Run the app with a hard 6 GB cap on the build (it gets killed instead of freezing the PC):
   ```bash
   systemd-run --user --scope -p MemoryMax=6G flutter run -d emulator-5554
   ```
4. After the app opens, free the Gradle daemons (~2.3 GB); hot reload keeps working:
   ```bash
   (cd android && ./gradlew --stop)
   ```
5. Use `r` (hot reload) / `R` (hot restart) in the `flutter run` terminal. Only re-run `flutter run`
   after changing `pubspec.yaml`, `.env` or native Android files.

Check memory with `free -h`; if `available` drops below ~1.5 GB, close something.
A physical phone with USB debugging avoids the emulator entirely (~3 GB saved).

### Notes for Claude

- When running `flutter run` in the background (no stdin), trigger hot reload with
  `kill -USR1 <flutter_tools pid>` and hot restart with `kill -USR2 <pid>`.
- Do not stop Docker Desktop without asking: it may be hosting the local Supabase backend.
