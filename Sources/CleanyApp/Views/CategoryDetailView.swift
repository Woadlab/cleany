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
        ZStack {
            AtmosphericBackgroundView()

            VStack(spacing: 0) {
                // Header Bar
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.20))
                            .frame(width: 46, height: 46)
                            .overlay(Circle().stroke(categoryColor.opacity(0.4), lineWidth: 1))
                            .shadow(color: categoryColor.opacity(0.3), radius: 8)

                        Image(systemName: category.systemImage)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(categoryColor)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(category.title)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)

                            if let badge = category.badge {
                                Text(badge)
                                    .font(.system(size: 9, weight: .bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2.5)
                                    .background(Color.pink.opacity(0.20))
                                    .foregroundStyle(Color.pink)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.pink.opacity(0.4), lineWidth: 0.8))
                            }
                        }

                        Text(category.subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(state.categoryFormattedSize(category))
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("\(items.count) item\(items.count == 1 ? "" : "s")")
                            .font(.system(size: 11.5, weight: .medium))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color.black.opacity(0.25))

                Divider().overlay(Color.white.opacity(0.08))

                // Filter & Search Controls Toolbar
                HStack(spacing: 12) {
                    if subcategories.count > 2 {
                        HStack(spacing: 4) {
                            ForEach(subcategories, id: \.self) { sub in
                                Button {
                                    SoundHaptics.tap()
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                        selectedSubcategory = sub
                                    }
                                } label: {
                                    Text(sub)
                                        .font(.system(size: 11, weight: selectedSubcategory == sub ? .bold : .medium))
                                        .foregroundStyle(selectedSubcategory == sub ? .white : .white.opacity(0.55))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(selectedSubcategory == sub ? Color.white.opacity(0.15) : Color.clear)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(3)
                        .background(Capsule().fill(Color.white.opacity(0.05)))
                    }

                    Spacer()

                    // Instant Search Pill
                    HStack(spacing: 6) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 11))
                            .foregroundStyle(.white.opacity(0.4))

                        TextField("Filter items...", text: $searchQuery)
                            .textFieldStyle(.plain)
                            .font(.system(size: 11.5))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .frame(width: 170)

                    // Select All / Deselect All
                    HStack(spacing: 8) {
                        Button("Select All") {
                            SoundHaptics.tap()
                            state.selectAll(in: category, isSelected: true)
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(categoryColor)

                        Text("•").foregroundStyle(.white.opacity(0.2))

                        Button("Deselect All") {
                            SoundHaptics.tap()
                            state.selectAll(in: category, isSelected: false)
                        }
                        .buttonStyle(.plain)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.45))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(Color.black.opacity(0.15))

                Divider().overlay(Color.white.opacity(0.08))

                // Items Scrollable List
                if items.isEmpty {
                    VStack(spacing: 14) {
                        Spacer()
                        Image(systemName: "sparkles")
                            .font(.system(size: 44))
                            .foregroundStyle(categoryColor.opacity(0.5))

                        Text("No items found")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))

                        Text("This category is clean, or has not been scanned yet.")
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.45))

                        Button("Scan \(category.title)") {
                            SoundHaptics.tap()
                            state.startScan(category: category)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(categoryColor)
                        Spacer()
                    }
                } else if filteredItems.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Text("No matching items for '\(searchQuery)'")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.5))
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 6) {
                            ForEach(filteredItems) { item in
                                JunkRowView(item: item) {
                                    SoundHaptics.tap()
                                    state.toggleItemSelection(id: item.id)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                }

                Divider().overlay(Color.white.opacity(0.08))

                // Bottom Floating Action Bar
                HStack {
                    Button {
                        SoundHaptics.tap()
                        state.startScan(category: category)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 11, weight: .semibold))
                            Text(state.isScanning ? "Scanning..." : "Rescan")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(Color.white.opacity(0.08)))
                    }
                    .buttonStyle(.plain)
                    .disabled(state.isScanning || state.isCleaning)

                    Spacer()

                    let selectedCount = filteredItems.filter { $0.isSelected }.count
                    let selectedSize = filteredItems.filter { $0.isSelected }.reduce(0) { $0 + $1.size }
                    let formattedSelected = ByteCountFormatter.string(fromByteCount: Int64(selectedSize), countStyle: .file)

                    HStack(spacing: 4) {
                        Text("Selected:")
                            .foregroundStyle(.white.opacity(0.5))
                        Text("\(formattedSelected)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("(\(selectedCount) items)")
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .font(.system(size: 12))

                    Button {
                        SoundHaptics.tap()
                        state.cleanSelected(category: category)
                    } label: {
                        HStack(spacing: 8) {
                            Text(state.isCleaning ? "Cleaning..." : "Clean to Trash")
                                .font(.system(size: 13, weight: .bold))
                            Image(systemName: "trash.fill")
                                .font(.system(size: 11))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue, Color.cyan],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1))
                        .shadow(color: Color.blue.opacity(0.35), radius: 8, x: 0, y: 3)
                    }
                    .buttonStyle(PressableButtonStyle())
                    .disabled(selectedCount == 0 || state.isScanning || state.isCleaning)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.black.opacity(0.35))
            }
        }
    }

    private var categoryColor: Color {
        switch category {
        case .aiClutter:
            return Color(red: 0.75, green: 0.35, blue: 0.95)
        case .developerJunk:
            return Color(red: 0.25, green: 0.55, blue: 0.98)
        case .systemJunk:
            return Color(red: 0.15, green: 0.75, blue: 0.75)
        case .appLeftovers:
            return Color(red: 0.98, green: 0.55, blue: 0.15)
        case .trashBins:
            return Color(red: 0.95, green: 0.28, blue: 0.32)
        }
    }
}
