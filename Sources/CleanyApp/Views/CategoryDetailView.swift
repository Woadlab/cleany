import SwiftUI
import CleanyCore

/// Native Apple HIG Category Detail View.
/// Integrates ContentUnavailableView for empty states, standard macOS search and filters,
/// native SF Symbols, and semantic typography.
public struct CategoryDetailView: View {
    public let category: JunkCategory
    @ObservedObject var state: AppState

    @LocalVar private var selectedSubcategory: String = "Tutti"
    @LocalVar private var searchQuery: String = ""

    public init(category: JunkCategory, state: AppState) {
        self.category = category
        self.state = state
    }

    private var items: [JunkItem] {
        state.itemsByCategory[category] ?? []
    }

    private var subcategories: [String] {
        var subs = Array(Set(items.map { $0.subcategory })).sorted()
        subs.insert("Tutti", at: 0)
        return subs
    }

    private var filteredItems: [JunkItem] {
        items.filter { item in
            let matchesSub = selectedSubcategory == "Tutti" || item.subcategory == selectedSubcategory
            let matchesSearch = searchQuery.isEmpty ||
                item.displayName.localizedCaseInsensitiveContains(searchQuery) ||
                item.path.localizedCaseInsensitiveContains(searchQuery)
            return matchesSub && matchesSearch
        }
    }

    private var categoryColor: Color {
        switch category {
        case .aiClutter: return .purple
        case .developerJunk: return .blue
        case .systemJunk: return .teal
        case .appLeftovers: return .orange
        case .trashBins: return .red
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            HStack(spacing: 16) {
                Image(systemName: category.systemImage)
                    .font(.system(size: 28, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(categoryColor)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(category.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)

                        if let badge = category.badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.accentColor)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }

                    Text(category.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(state.categoryFormattedSize(category))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    let selectedCount = items.filter { $0.isSelected }.count
                    Text("\(selectedCount) di \(items.count) selezionati")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Filter & Search Controls Bar
            if !items.isEmpty {
                HStack(spacing: 12) {
                    if subcategories.count > 2 {
                        Picker("Sottocategoria", selection: $selectedSubcategory) {
                            ForEach(subcategories, id: \.self) { sub in
                                Text(sub).tag(sub)
                            }
                        }
                        .pickerStyle(.segmented)
                        .controlSize(.small)
                        .frame(maxWidth: 320)
                    }

                    Spacer()

                    // Native-Styled Search Field
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        TextField("Filtra elementi...", text: $searchQuery)
                            .textFieldStyle(.plain)
                            .font(.callout)

                        if !searchQuery.isEmpty {
                            Button {
                                searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(nsColor: .textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color(nsColor: .separatorColor).opacity(0.5), lineWidth: 0.5)
                    )
                    .frame(width: 200)

                    // Quick Select Actions
                    HStack(spacing: 8) {
                        Button("Seleziona tutti") {
                            SoundHaptics.tap()
                            state.selectAll(in: category, isSelected: true)
                        }
                        .buttonStyle(.link)
                        .font(.caption)

                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)

                        Button("Deseleziona") {
                            SoundHaptics.tap()
                            state.selectAll(in: category, isSelected: false)
                        }
                        .buttonStyle(.link)
                        .font(.caption)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color(nsColor: .windowBackgroundColor))

                Divider()
            }

            // Main Content: ContentUnavailableView vs List
            Group {
                if items.isEmpty {
                    if category == .trashBins {
                        ContentUnavailableView(
                            "Cestino vuoto",
                            systemImage: "trash",
                            description: Text("Non ci sono elementi eliminabili al momento.")
                        )
                    } else {
                        ContentUnavailableView {
                            Label(category.title, systemImage: category.systemImage)
                        } description: {
                            Text("Nessun elemento trovato. Questa categoria è pulita.")
                        } actions: {
                            Button("Scansiona \(category.title)") {
                                SoundHaptics.tap()
                                state.startScan(category: category)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else if filteredItems.isEmpty {
                    ContentUnavailableView.search(text: searchQuery)
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            JunkRowView(item: item) {
                                SoundHaptics.tap()
                                state.toggleItemSelection(id: item.id)
                            }
                        }
                    }
                    .listStyle(.inset)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // Bottom Actions Toolbar
            HStack {
                Button {
                    SoundHaptics.tap()
                    state.startScan(category: category)
                } label: {
                    Label(state.isScanning ? "Scansione..." : "Riscansiona", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .disabled(state.isScanning)

                Spacer()

                let selectedCount = items.filter { $0.isSelected }.count
                let selectedSize = items.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
                let formattedSelected = ByteCountFormatter.string(fromByteCount: Int64(selectedSize), countStyle: .file)

                Button {
                    SoundHaptics.clean()
                    state.cleanSelected()
                } label: {
                    Label(
                        category == .trashBins ? "Svuota Cestino (\(formattedSelected))" : "Pulisci Selezionati (\(formattedSelected))",
                        systemImage: "trash.fill"
                    )
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedCount == 0 || state.isCleaning || state.isScanning)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}
