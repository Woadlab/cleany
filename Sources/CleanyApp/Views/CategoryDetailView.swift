import SwiftUI
import CleanyCore

/// Native macOS 27 Category Detail View.
/// Redesigned with liquid glass curvature, integrated search and selection pills,
/// dedicated privacy-safe Trash Bins workflow, and single-source actions.
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
                // Header Platter
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
                                    .padding(.horizontal, 7)
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
                        if items.count > 0 {
                            Text("\(selectedCount) di \(items.count) selezionati")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .liquidGlass(cornerRadius: 22, tint: categoryColor.opacity(0.08), isInteractive: false)
                .padding(.horizontal, 24)
                .padding(.top, 18)

                // Dedicated Trash Bins Platter when category is Trash
                if category == .trashBins && items.count > 0 {
                    trashDedicatedView
                } else {
                    standardCategoryContent
                }
            }
        }
    }

    // Dedicated Clean Experience for Trash Bins
    @ViewBuilder
    private var trashDedicatedView: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "trash.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.red)
                    .symbolEffect(.pulse)

                Text(state.categoryFormattedSize(.trashBins))
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Spazio occupato nel Cestino di macOS")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text("macOS protegge l'accesso diretto ai singoli file del Cestino per ragioni di sicurezza e privacy. Puoi liberare questo spazio immediatamente svuotando il Cestino.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 480)
                    .padding(.top, 4)

                Button {
                    SoundHaptics.clean()
                    state.cleanSelected()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 15, weight: .bold))
                        Text("Svuota Cestino Adesso")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.glassProminent)
                .tint(.red)
                .clipShape(Capsule())
                .padding(.top, 12)
            }
            .padding(36)
            .liquidGlass(cornerRadius: 26, tint: Color.red.opacity(0.05), isInteractive: false)
            .padding(.horizontal, 48)

            Spacer()
        }
    }

    // Standard Category Flow (AI, Dev, System, App Leftovers)
    @ViewBuilder
    private var standardCategoryContent: some View {
        VStack(spacing: 0) {
            // Integrated Search & Selection Bar
            if !items.isEmpty {
                HStack(spacing: 14) {
                    // Subcategory Filter Capsules
                    if subcategories.count > 2 {
                        HStack(spacing: 4) {
                            ForEach(subcategories, id: \.self) { sub in
                                Button {
                                    selectedSubcategory = sub
                                } label: {
                                    Text(sub)
                                        .font(.caption)
                                        .fontWeight(selectedSubcategory == sub ? .bold : .medium)
                                        .foregroundStyle(selectedSubcategory == sub ? .primary : .secondary)
                                        .padding(.horizontal, 11)
                                        .padding(.vertical, 6)
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

                    // Smooth Glass Search Capsule
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
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(Capsule())
                    .frame(width: 210)

                    // Rounded Selection Control Capsule
                    HStack(spacing: 4) {
                        Button("Tutti") {
                            state.selectAll(in: category, isSelected: true)
                        }
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)

                        Text("•")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)

                        Button("Nessuno") {
                            state.selectAll(in: category, isSelected: false)
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    }
                    .background(Capsule().fill(Color.primary.opacity(0.04)))
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
            }

            // Items List or Empty State
            Group {
                if items.isEmpty {
                    VStack {
                        Spacer()
                        if category == .trashBins {
                            ContentUnavailableView(
                                "Cestino vuoto",
                                systemImage: "trash",
                                description: Text("Non ci sono elementi nel Cestino al momento.")
                            )
                        } else {
                            ContentUnavailableView {
                                Label(category.title, systemImage: category.systemImage)
                            } description: {
                                Text("Nessun elemento trovato. Questa categoria è pulita.")
                            } actions: {
                                Button("Scansiona \(category.title)") {
                                    state.startScan(category: category)
                                }
                                .buttonStyle(.glassProminent)
                                .clipShape(Capsule())
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
                                    state.toggleItemSelection(id: item.id)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Single Floating Action Dock (Only rendered when there are items)
            if !items.isEmpty {
                let selectedCount = items.filter { $0.isSelected }.count
                let selectedSize = items.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
                let formattedSelected = ByteCountFormatter.string(fromByteCount: Int64(selectedSize), countStyle: .file)

                HStack {
                    Button {
                        state.startScan(category: category)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 13, weight: .semibold))
                            Text(state.isScanning ? "Scansione..." : "Riscansiona")
                                .font(.system(size: 13.5, weight: .medium))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.glass)
                    .clipShape(Capsule())
                    .disabled(state.isScanning)

                    Spacer()

                    Button {
                        SoundHaptics.clean()
                        state.cleanSelected()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 13, weight: .bold))
                            Text("Sposta nel Cestino (\(formattedSelected))")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(Color.accentColor)
                    .clipShape(Capsule())
                    .disabled(selectedCount == 0 || state.isCleaning || state.isScanning)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .liquidGlass(cornerRadius: 22, tint: Color.primary.opacity(0.04), isInteractive: false)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
    }
}
