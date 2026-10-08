---
name: Magic app project overview
description: Flutter/Dart macOS app for launching independent app profiles — architecture, tech stack, and phase status
type: project
---

Magic is a native macOS app (Flutter + Dart) for creating and launching independent application profiles (e.g. Work/Personal Chrome with separate data).

**Why:** Users need to run multiple instances of the same app with separate accounts, cookies, and data — something macOS doesn't natively support.

**How to apply:** All product logic lives in Dart. Swift is only used in a thin platform plugin (MethodChannel) for macOS APIs: app discovery, process launching, file system ops, Finder reveal. Never put business logic in Swift.

Tech stack: Flutter 3.44, Riverpod (state), GoRouter (nav), Drift (SQLite persistence), MethodChannel (Dart↔Swift bridge).

Phase status as of 2026-10-07:
- Phase 1: COMPLETE — project scaffold, domain models, Drift persistence, Swift plugin (AppDiscovery, ProcessLauncher, FileSystemBridge), services, providers, UI shell, 28 passing tests, macOS debug build verified.
- Phase 2: NOT STARTED — adapter system, Chromium adapter
- Phase 3: NOT STARTED — Firefox and generic experimental adapters
- Phase 4: NOT STARTED — process tracking, logs, storage, reset, polished UI
- Phase 5: NOT STARTED — end-to-end testing with real apps

App sandbox is disabled (required for launching external processes).
