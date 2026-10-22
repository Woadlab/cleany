import SwiftUI
import CleanyCore

public struct CategoryDetailView: View {
    public let category: JunkCategory
    @ObservedObject var state: AppState

    @LocalVar private var selectedSubcategory: String = "All"
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
        subs.insert("All", at: 0)
        return subs
    }

    private var filteredItems: [JunkItem] {
        items.filter { item in
            let matchesSub = selectedSubcategory == "All" || item.subcategory == selectedSubcategory
            let matchesSearch = searchQuery.isEmpty ||
                item.displayName.localizedCaseInsensitiveContains(searchQuery) ||
                item.path.localizedCaseInsensitiveContains(searchQuery)
            return matchesSub && matchesSearch
        }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: category.systemImage)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(categoryColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(category.title)
                            .font(.system(size: 18, weight: .bold))

                        if let badge = category.badge {
                            Text(badge)
                                .font(.system(size: 9, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.pink.opacity(0.15))
                                .foregroundStyle(.pink)
                                .clipShape(Capsule())
                        }
                    }

                    Text(category.subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(state.categoryFormattedSize(category))
                        .font(.system(size: 22, weight: .bold, design: .rounded))

                    Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Filter Bar
            HStack(spacing: 12) {
                if subcategories.count > 2 {
                    Picker("", selection: $selectedSubcategory) {
                        ForEach(subcategories, id: \.self) { sub in
                            Text(sub).tag(sub)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 320)
                }

                Spacer()

                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)

                    TextField("Filter items...", text: $searchQuery)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.primary.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .frame(width: 180)

                Button("Select All") {
                    state.selectAll(in: category, isSelected: true)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)

                Text("•").foregroundStyle(.secondary.opacity(0.5))

                Button("Deselect All") {
                    state.selectAll(in: category, isSelected: false)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))

            Divider()

            // Items List
            if items.isEmpty {
                VStack(spacing: 14) {
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary.opacity(0.4))

                    Text("No items found")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text("This category is clean, or has not been scanned yet.")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary.opacity(0.8))

                    Button("Scan \(category.title)") {
                        state.startScan(category: category)
                    }
                    .buttonStyle(.bordered)
                    .disabled(state.isScanning)
                    Spacer()
                }
            } else if filteredItems.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Text("No matching items for '\(searchQuery)'")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredItems) { item in
                        JunkRowView(item: item) {
                            state.toggleItemSelection(id: item.id)
                        }
                    }
                }
                .listStyle(.inset)
            }

            Divider()

            // Bottom action bar
            HStack {
                Button {
                    state.startScan(category: category)
                } label: {
                    Label(state.isScanning ? "Scanning..." : "Rescan", systemImage: "arrow.clockwise")
                        .font(.system(size: 12))
                }
                .buttonStyle(.bordered)
                .disabled(state.isScanning || state.isCleaning)

                Spacer()

                let selectedCount = filteredItems.filter { $0.isSelected }.count
                let selectedSize = filteredItems.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
                let formattedSelected = ByteCountFormatter.string(fromByteCount: Int64(selectedSize), countStyle: .file)

                Text("Selected: \(formattedSelected) (\(selectedCount) items)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Button {
                    state.cleanSelected(category: category)
                } label: {
                    Label(state.isCleaning ? "Cleaning..." : "Clean to Trash", systemImage: "trash.fill")
                        .font(.system(size: 12, weight: .semibold))
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(selectedCount == 0 || state.isScanning || state.isCleaning)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(nsColor: .windowBackgroundColor))
        }
    }

    private var categoryColor: Color {
        switch category {
        case .aiClutter:
            return .purple
        case .developerJunk:
            return .blue
        case .systemJunk:
            return .teal
        case .appLeftovers:
            return .orange
        case .trashBins:
            return .red
        }
    }
}
