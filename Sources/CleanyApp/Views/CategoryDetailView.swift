import SwiftUI
import CleanyCore

/// Native macOS 27 Category Detail View.
/// Features Liquid Glass header, subcategory filter pills, ContentUnavailableView integration,
/// interactive item tiles, and floating glass action dock.
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
        ZStack {
            // macOS 27 Ambient Fluid Mesh Atmosphere
            LiquidGlassBackground()

            VStack(spacing: 0) {
                // Liquid Glass Header Platter
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.18))
                            .frame(width: 48, height: 48)
                            .overlay(Circle().stroke(categoryColor.opacity(0.35), lineWidth: 1))

                        Image(systemName: category.systemImage)
                            .font(.system(size: 22, weight: .semibold))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(categoryColor)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(category.title)
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)

                            if let badge = category.badge {
                                Text(badge)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(categoryColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(categoryColor.opacity(0.18))
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
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        let selectedCount = items.filter { $0.isSelected }.count
                        Text("\(selectedCount) di \(items.count) selezionati")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .liquidGlass(cornerRadius: 18, tint: categoryColor.opacity(0.08), isInteractive: false)
                .padding(.horizontal, 24)
                .padding(.top, 18)

                // Subcategory Filter & Search Bar Platter
                if !items.isEmpty {
                    HStack(spacing: 14) {
                        // Subcategory Pills
                        if subcategories.count > 2 {
                            HStack(spacing: 4) {
                                ForEach(subcategories, id: \.self) { sub in
                                    Button {
                                        SoundHaptics.tap()
                                        selectedSubcategory = sub
                                    } label: {
                                        Text(sub)
                                            .font(.caption)
                                            .fontWeight(selectedSubcategory == sub ? .bold : .medium)
                                            .foregroundStyle(selectedSubcategory == sub ? .primary : .secondary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(
                                                Capsule()
                                                    .fill(selectedSubcategory == sub ? Color.primary.opacity(0.12) : Color.clear)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(3)
                            .background(Color.primary.opacity(0.04))
                            .clipShape(Capsule())
                        }

                        Spacer()

                        // Instant Search Bar
                        HStack(spacing: 6) {
                            Image(systemName: "magnifyingglass")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            TextField("Cerca elementi...", text: $searchQuery)
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
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .frame(width: 220)

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
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                }

                // Main Content List or ContentUnavailableView
                Group {
                    if items.isEmpty {
                        VStack {
                            Spacer()
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
                                    .buttonStyle(.glassProminent)
                                }
                            }
                            Spacer()
                        }
                    } else if filteredItems.isEmpty {
                        VStack {
                            Spacer()
                            ContentUnavailableView.search(text: searchQuery)
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(filteredItems) { item in
                                    JunkRowView(item: item) {
                                        SoundHaptics.tap()
                                        state.toggleItemSelection(id: item.id)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Floating Liquid Glass Action Dock
                HStack {
                    Button {
                        SoundHaptics.tap()
                        state.startScan(category: category)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 13, weight: .semibold))
                            Text(state.isScanning ? "Scansione..." : "Riscansiona")
                                .font(.system(size: 13.5, weight: .medium))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.glass)
                    .disabled(state.isScanning)

                    Spacer()

                    let selectedCount = items.filter { $0.isSelected }.count
                    let selectedSize = items.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
                    let formattedSelected = ByteCountFormatter.string(fromByteCount: Int64(selectedSize), countStyle: .file)

                    Button {
                        SoundHaptics.clean()
                        state.cleanSelected()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text(
                                category == .trashBins
                                    ? "Svuota Cestino (\(formattedSelected))"
                                    : "Sposta nel Cestino (\(formattedSelected))"
                            )
                            .font(.system(size: 14, weight: .bold))
                        }
                        .padding(.horizontal, 22)
                        .padding(.vertical, 9)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(category == .trashBins ? .red : Color.accentColor)
                    .disabled(selectedCount == 0 || state.isCleaning || state.isScanning)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .liquidGlass(cornerRadius: 18, tint: Color.primary.opacity(0.04), isInteractive: false)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
    }
}
