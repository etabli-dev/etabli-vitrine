# Apple build and roadmap refinement — 2026-11-08

Release WebViews no longer expose inspection or allow arbitrary mixed content. iOS loopback hosts are declared as app-bound domains, and both runtime WebViews opt into those domains so WebKit can expose the service-worker API. Navigation remains inside the local runtime; imported content still needs to be trusted before executing it.

Android release builds now use private `android/keystore.properties` when supplied and otherwise remain unsigned. They no longer silently use the debug key. Existing debug installs must retain their data; export files before moving to a differently signed installation. No signing keys were changed or created.

The application workflow now includes an unsigned iOS simulator compilation job with pinned runtime preparation. Binary uploads remain disabled while the corresponding-source delivery gate is open.

Local runtime-preparation safeguards, locked dependency resolution, static analysis and all 27 Flutter tests passed. The unsigned iOS simulator application compiled successfully with Xcode 27.2; Flutter migrated its minimum deployment target to iOS 15.0. The final workflow also compiles the unsigned Android release configuration. Live WKWebView service-worker behavior, incoming shares, signing and physical-device notification/lifecycle acceptance remain separate checks.
