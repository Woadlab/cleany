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
            // Header bar
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 48, height: 48)

                    Image(systemName: category.systemImage)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.tint)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(category.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        if let badge = category.badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.pink.opacity(0.18))
                                .foregroundStyle(.pink)
                                .clipShape(Capsule())
                        }
                    }

                    Text(category.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(state.categoryFormattedSize(category))
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    Text("\(items.count) item(s)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 18)
            .background(.regularMaterial)

            Divider()

            // Subcategory pill filters & actions
            HStack {
                Picker("Subcategory", selection: $selectedSubcategory) {
                    ForEach(subcategories, id: \.self) { sub in
                        Text(sub).tag(sub)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 360)

                Spacer()

                Button("Select All") {
                    state.selectAll(in: category, isSelected: true)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)

                Text("•").foregroundStyle(.secondary)

                Button("Deselect All") {
                    state.selectAll(in: category, isSelected: false)
                }
                .buttonStyle(.plain)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 10)

            Divider()

            // Items List
            if filteredItems.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary.opacity(0.5))

                    Text("No items found")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    Button("Scan \(category.title)") {
                        state.startScan(category: category)
                    }
                    .buttonStyle(.bordered)
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
                }
                .disabled(state.isScanning || state.isCleaning)

                Spacer()

                let selectedCount = filteredItems.filter { $0.isSelected }.count
                let selectedSize = filteredItems.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
                let formattedSelected = ByteCountFormatter.string(fromByteCount: Int64(selectedSize), countStyle: .file)

                Text("Selected: \(formattedSelected) (\(selectedCount) items)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    state.cleanSelected(category: category)
                } label: {
                    Label(state.isCleaning ? "Cleaning..." : "Clean to Trash", systemImage: "trash.fill")
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(selectedCount == 0 || state.isScanning || state.isCleaning)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(.regularMaterial)
        }
    }
}
