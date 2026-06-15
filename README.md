# iOS Modular Architecture — E-Commerce App

A reference summary of the modular architecture pattern discussed for a large-scale iOS app, using an e-commerce app (orders, customers, products, cart) as the concrete example.

---

## Why modularize?

A monolithic app compiles everything together. As the codebase grows, every small change triggers a full recompile, features bleed into each other, and teams step on each other's work. Modularization addresses this by splitting the app into self-contained Swift packages with explicit, enforced boundaries.

Key benefits:

- **Faster builds** — Xcode only recompiles changed modules
- **Testability** — modules can be tested in isolation, with no real network or database
- **Ownership** — each module has a clear responsible team
- **Encapsulation** — internal details are hidden behind public interfaces; nothing leaks by accident
- **Scalability** — adding a new feature means adding a new module, not touching existing ones

---

## The four-layer architecture

Dependencies flow strictly **downward**. An upper layer may import a lower one, but never the reverse.

```
┌─────────────────────────────────────┐
│                 App                 │  ← glue layer, owns DI wiring
└──────────┬──────────────────────────┘
           │ imports
┌──────────▼──────────────────────────┐
│  Orders  │ Customers │ Products │ Cart  │  ← feature modules
└──────────┬──────────────────────────┘
           │ imports
┌──────────▼──────────────────────────┐
│ OrdersData │ CustomersData │ ProductsData │  ← data modules
└──────────┬──────────────────────────┘
           │ imports
┌──────────▼──────────────────────────┐
│  Networking  │  DesignSystem  │  Analytics  │  ← core modules
└─────────────────────────────────────┘
```

### Layer responsibilities

**App**
The main Xcode target. Creates all concrete instances, wires dependencies, and sets up navigation. The only layer that imports both feature and data modules simultaneously.

**Feature modules** (e.g. `OrdersFeature`)
SwiftUI views and their view models. Know how to display and interact with data, but have no idea how that data is fetched. Depend on the data layer for model types and repository protocols, not for concrete implementations.

**Data modules** (e.g. `OrdersData`)
Domain models (`Order`, `Customer`, `Product`), repository protocols, and their concrete implementations. The protocol and the implementation live in the same package; the feature only ever sees the protocol.

**Core modules**
Shared infrastructure with no knowledge of the business domain. `Networking` wraps `URLSession`. `DesignSystem` holds shared colors, fonts, and UI components. `Analytics` provides a generic event-logging interface. These modules have zero imports from feature or data layers.

---

## Module map — e-commerce app

| Module | Layer | Key contents |
|---|---|---|
| `App` | App | `AppContainer`, `AppRootView`, `ECommerceApp` |
| `OrdersFeature` | Feature | `OrdersView`, `OrdersViewModel` |
| `CustomersFeature` | Feature | `CustomersView`, `CustomersViewModel` |
| `ProductsFeature` | Feature | `ProductsView`, `ProductsViewModel` |
| `CartFeature` | Feature | `CartView`, `CartViewModel` |
| `OrdersData` | Data | `Order`, `OrderRepository` (protocol), `OrderRepositoryImpl` |
| `CustomersData` | Data | `Customer`, `CustomerRepository`, `CustomerRepositoryImpl` |
| `ProductsData` | Data | `Product`, `ProductRepository`, `ProductRepositoryImpl` |
| `Networking` | Core | `NetworkClient` |
| `DesignSystem` | Core | Shared UI components, tokens |
| `Analytics` | Core | `AnalyticsEvent`, `AnalyticsLogger` |

---

## The Orders slice in detail

The Orders feature touches all four layers and illustrates every pattern in the architecture.

### Class diagram

```
OrdersFeature package
┌─────────────────────┐       ┌──────────────────────────┐
│ OrdersView          │──────▶│ OrdersViewModel           │
│ SwiftUI View        │       │ ObservableObject          │
│─────────────────────│       │──────────────────────────│
│ body: some View     │       │ orders: [Order]           │
└─────────────────────┘       │ fetchOrders()             │
                              │ selectOrder(id:)          │
                              └────────────┬─────────────┘
                                           │ depends on (protocol)
                                           ▼
OrdersData package
┌─────────────────────┐       ┌──────────────────────────┐       ┌──────────────────────┐
│ Order               │       │ OrderRepository           │◀─ ─ ─│ OrderRepositoryImpl  │
│ struct              │       │ protocol                  │       │ class                │
│─────────────────────│       │──────────────────────────│       │──────────────────────│
│ id: UUID            │       │ fetchOrders()             │       │ fetchOrders()        │
│ status: OrderStatus │       │ fetchOrder(id:)           │       │ fetchOrder(id:)      │
│ total: Decimal      │       └──────────────────────────┘       └──────────┬───────────┘
│ items: [LineItem]   │                                                      │ uses
└─────────────────────┘                                                      ▼
                                                           Networking package
                                                           ┌──────────────────────┐
                                                           │ NetworkClient        │
                                                           │ class                │
                                                           │──────────────────────│
                                                           │ get(endpoint:)       │
                                                           │ post(endpoint:body:) │
                                                           └──────────────────────┘
```

`─ ─ ▶` = conforms to (dashed = protocol conformance)
`────▶` = depends on (solid = usage / import)

### Key relationship: protocol-based dependency inversion

`OrdersViewModel` depends on `OrderRepository` — the **protocol** — not on `OrderRepositoryImpl`. This is the single most important architectural decision in the design.

```swift
// Inside OrdersFeature — this is all it sees
class OrdersViewModel: ObservableObject {
    private let repository: any OrderRepository  // protocol type

    init(repository: any OrderRepository) {
        self.repository = repository
    }
}
```

The ViewModel never mentions `OrderRepositoryImpl`. It cannot import `Networking`. It has no idea whether data comes from an API, a local database, or a mock. That is entirely the concern of the data module.

---

## The App module — composition root

The App module is the only place in the codebase where `*Impl` types are mentioned by name. It creates all dependencies and wires them together.

### AppContainer.swift

```swift
import Foundation

// Core
import Networking

// Concrete implementations (Data layer)
import OrdersData
import CustomersData
import ProductsData
import CartData

// ViewModels (Feature layer)
import OrdersFeature
import CustomersFeature
import ProductsFeature
import CartFeature

@Observable
final class AppContainer {

    // MARK: - Core infrastructure (shared across all repositories)
    private let networkClient: NetworkClient

    // MARK: - Repositories (typed as protocols — Impl never escapes this file)
    private let ordersRepository:    any OrderRepository
    private let customersRepository: any CustomerRepository
    private let productsRepository:  any ProductRepository

    // MARK: - ViewModels
    let ordersViewModel:    OrdersViewModel
    let customersViewModel: CustomersViewModel
    let productsViewModel:  ProductsViewModel
    let cartViewModel:      CartViewModel

    init() {
        // Step 1: Core infrastructure — one instance, shared everywhere
        networkClient = NetworkClient(
            baseURL: URL(string: "https://api.mystore.com/v1")!,
            session: .shared
        )

        // Step 2: Concrete repositories — *Impl appears exactly once each
        ordersRepository    = OrderRepositoryImpl(client: networkClient)
        customersRepository = CustomerRepositoryImpl(client: networkClient)
        productsRepository  = ProductRepositoryImpl(client: networkClient)

        // Step 3: ViewModels receive protocol types, not concrete types
        ordersViewModel    = OrdersViewModel(repository: ordersRepository)
        customersViewModel = CustomersViewModel(repository: customersRepository)
        productsViewModel  = ProductsViewModel(repository: productsRepository)

        // Cart spans two domains — the App module is the right place to express this
        cartViewModel = CartViewModel(
            productsRepository: productsRepository,
            ordersRepository:   ordersRepository
        )
    }
}
```

### ECommerceApp.swift

```swift
import SwiftUI
import OrdersFeature
import CustomersFeature
import ProductsFeature
import CartFeature

@main
struct ECommerceApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(container.ordersViewModel)
                .environment(container.customersViewModel)
                .environment(container.productsViewModel)
                .environment(container.cartViewModel)
        }
    }
}
```

### AppRootView.swift

```swift
import SwiftUI
import OrdersFeature
import CustomersFeature
import ProductsFeature
import CartFeature

struct AppRootView: View {
    var body: some View {
        TabView {
            NavigationStack { OrdersView() }
                .tabItem { Label("Orders",    systemImage: "list.clipboard")  }
            NavigationStack { ProductsView() }
                .tabItem { Label("Products",  systemImage: "square.grid.2x2") }
            NavigationStack { CustomersView() }
                .tabItem { Label("Customers", systemImage: "person.2")        }
            NavigationStack { CartView() }
                .tabItem { Label("Cart",      systemImage: "cart")            }
        }
    }
}
```

### How a feature view reads its ViewModel

The feature view reads its ViewModel from the SwiftUI environment, with no reference to `AppContainer` or any concrete type.

```swift
// Inside OrdersFeature package
public struct OrdersView: View {
    @Environment(OrdersViewModel.self) private var viewModel

    public var body: some View {
        List(viewModel.orders) { order in
            OrderRowView(order: order)
        }
        .task { await viewModel.fetchOrders() }
        .navigationTitle("Orders")
    }
}
```

---

## Testing

Because every ViewModel depends on a protocol, testing requires no network, no simulator, and no mocking framework.

```swift
final class MockOrderRepository: OrderRepository {
    var stubbedOrders: [Order] = []

    func fetchOrders() async throws -> [Order] { stubbedOrders }
    func fetchOrder(id: UUID) async throws -> Order {
        stubbedOrders.first { $0.id == id } ?? { throw RepositoryError.notFound }()
    }
}

final class OrdersViewModelTests: XCTestCase {
    func testFetchOrdersPopulatesArray() async throws {
        let mock = MockOrderRepository()
        mock.stubbedOrders = [Order(id: UUID(), status: .processing, total: 49.99, items: [])]

        let viewModel = OrdersViewModel(repository: mock)
        await viewModel.fetchOrders()

        XCTAssertEqual(viewModel.orders.count, 1)
    }
}
```

`CustomersViewModel`, `ProductsViewModel`, and `CartViewModel` all test the same way — swap the repository implementation, no other changes needed.

---

## Practical rules

**Dependencies flow downward only.**
A feature module may import a data module. A data module may import a core module. Nothing flows upward.

**No cross-feature imports.**
`OrdersFeature` must never import `CustomersFeature`. If two features need to share something, that thing belongs in a data module or core module.

**`*Impl` types appear only in the App target.**
Run `grep -r "RepositoryImpl" --include="*.swift"` across the project. Results should only appear in `AppContainer.swift`. If they appear inside a feature module, a concrete type has leaked past a boundary.

**Protocols live in the data module, not the feature module.**
`OrderRepository` is defined in `OrdersData`, not `OrdersFeature`. The feature imports the data module to get the protocol shape and model types.

**The App module is the only legitimate place to hold multiple-domain knowledge.**
`CartViewModel` needs both `ProductRepository` and `OrderRepository`. That cross-domain wiring lives in `AppContainer`, not in either feature module.

---

## Common pitfalls

| Pitfall | Consequence | Fix |
|---|---|---|
| Too many modules too early | Build overhead, boilerplate cost exceeds the benefit | Start with 2–3 feature modules; split further as the team grows |
| Importing `*Impl` inside a feature | Concrete type leaks past boundary; testing becomes harder | Keep `*Impl` types `internal` in the data package; expose only the protocol |
| Cross-feature imports | Circular dependencies, tightly coupled features | Extract shared logic into a data or core module |
| Putting business logic in the view | Hard to test, hard to reuse | All logic lives in the ViewModel; views are purely presentational |
| One module per file | Excessive granularity; management overhead | Group by feature domain, not by Swift type |
