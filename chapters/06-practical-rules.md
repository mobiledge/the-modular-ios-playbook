# Practical Rules for the Matrix

* **Vertical Isolation:** A domain implementation (e.g., `MusicImplementation`) must **never** import another domain's implementation (e.g., `MovieImplementation`).
* **UI Depends on Abstractions:** ViewModels depend on `Store` protocols and `Infrastructure` protocols, never on concrete `Impl` classes. Data access and third-party tools remain entirely abstracted.
* **Keep SDKs out of the Domains:** Do not import `Mixpanel`, `LaunchDarkly`, or `Datadog` in your feature packages. Map them to your own protocols in the Core Interface, and wrap the SDKs in the Core Implementation.
* **The App is the Glue:** All concrete wiring happens in `AppContainer`. If you are instantiating a concrete repository or infrastructure service inside a SwiftUI View, the dependency chain is broken.
