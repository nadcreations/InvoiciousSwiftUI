import SwiftUI

// MARK: - Help & Support Main View
struct HelpSupportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: HelpSupportContent.FAQCategory? = nil
    @State private var expandedFAQs: Set<UUID> = []
    
    var filteredFAQs: [HelpSupportContent.FAQItem] {
        if !searchText.isEmpty {
            return HelpSupportContent.searchFAQs(searchText)
        } else if let category = selectedCategory {
            return HelpSupportContent.getFAQs(for: category)
        } else {
            return HelpSupportContent.getMostRelevantFAQs()
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Help Icon and Title
                    VStack(spacing: DesignSystem.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.primaryGradient)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.textInverse)
                        }
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("Help & Support")
                                .font(DesignSystem.Typography.title1)
                                .fontWeight(.bold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Text("Find answers to common questions and get support")
                                .font(DesignSystem.Typography.callout)
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(DesignSystem.Colors.textTertiary)
                        
                        TextField("Search FAQ...", text: $searchText)
                            .font(DesignSystem.Typography.callout)
                    }
                    .padding(DesignSystem.Spacing.md)
                    .background(DesignSystem.Colors.backgroundSecondary)
                    .cornerRadius(DesignSystem.CornerRadius.md)
                    .onChange(of: searchText) { _ in
                        selectedCategory = nil // Clear category when searching
                    }
                }
                .padding(DesignSystem.Spacing.screenPadding)
                .background(
                    LinearGradient(
                        colors: [DesignSystem.Colors.backgroundSecondary, DesignSystem.Colors.background],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Main Content
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.lg) {
                        
                        // Support Options (only show when not searching)
                        if searchText.isEmpty && selectedCategory == nil {
                            SupportOptionsSection()
                        }
                        
                        // Category Filter (only show when not searching)
                        if searchText.isEmpty {
                            CategoryFilterSection(selectedCategory: $selectedCategory)
                        }
                        
                        // FAQ Content
                        FAQListSection(
                            faqs: filteredFAQs,
                            expandedFAQs: $expandedFAQs,
                            searchText: searchText
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.screenPadding)
                    .padding(.top, DesignSystem.Spacing.lg)
                }
            }
            .navigationBarHidden(true)
            .overlay(
                // Custom Close Button
                VStack {
                    HStack {
                        Spacer()
                        Button("Done") {
                            dismiss()
                        }
                        .professionalButton(style: .ghost, size: .small)
                        .padding(.top, DesignSystem.Spacing.md)
                        .padding(.trailing, DesignSystem.Spacing.screenPadding)
                    }
                    Spacer()
                },
                alignment: .topTrailing
            )
        }
    }
}

// MARK: - Support Options Section
struct SupportOptionsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Get Additional Support")
                .font(DesignSystem.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(DesignSystem.Colors.textPrimary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: DesignSystem.Spacing.md) {
                ForEach(SupportInfo.contactOptions, id: \.title) { option in
                    SupportOptionCard(option: option)
                }
            }
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .modernCard(elevation: 1)
    }
}

public struct SupportOptionCard: View {
    let option: SupportInfo.ContactOption
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button(action: {
            handleSupportAction(option.action)
        }) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: option.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(DesignSystem.Colors.primary)
                
                VStack(spacing: 4) {
                    Text(option.title)
                        .font(DesignSystem.Typography.caption1)
                        .fontWeight(.semibold)
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Text(option.subtitle)
                        .font(DesignSystem.Typography.caption2)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(DesignSystem.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(DesignSystem.Colors.backgroundSecondary)
            .cornerRadius(DesignSystem.CornerRadius.md)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func handleSupportAction(_ action: SupportInfo.ContactAction) {
        switch action {
        case .inAppFAQ:
            // Already in FAQ view, do nothing
            break
        case .email:
            if let url = URL(string: "mailto:\(SupportInfo.supportEmail)?subject=Invoicious%20Support%20Request") {
                UIApplication.shared.open(url)
            }
        case .website:
            if let url = URL(string: SupportInfo.websiteURL) {
                UIApplication.shared.open(url)
            }
        case .documentation:
            if let url = URL(string: SupportInfo.documentationURL) {
                UIApplication.shared.open(url)
            }
        }
    }
}

// MARK: - Category Filter Section
struct CategoryFilterSection: View {
    @Binding var selectedCategory: HelpSupportContent.FAQCategory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Browse by Category")
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                if selectedCategory != nil {
                    Button("Show All") {
                        selectedCategory = nil
                    }
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.primary)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(HelpSupportContent.FAQCategory.allCases, id: \.self) { category in
                        CategoryChip(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = selectedCategory == category ? nil : category
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
            }
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .modernCard(elevation: 1)
    }
}

struct CategoryChip: View {
    let category: HelpSupportContent.FAQCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                Text(category.rawValue)
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.medium)
                
                if isSelected {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                }
            }
            .foregroundColor(isSelected ? DesignSystem.Colors.textInverse : DesignSystem.Colors.textSecondary)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(
                isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.backgroundSecondary
            )
            .cornerRadius(DesignSystem.CornerRadius.badge)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.badge)
                    .stroke(
                        isSelected ? Color.clear : DesignSystem.Colors.borderLight,
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - FAQ List Section
struct FAQListSection: View {
    let faqs: [HelpSupportContent.FAQItem]
    @Binding var expandedFAQs: Set<UUID>
    let searchText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text(searchText.isEmpty ? "Frequently Asked Questions" : "Search Results")
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Spacer()
                
                Text("\(faqs.count) \(faqs.count == 1 ? "result" : "results")")
                    .font(DesignSystem.Typography.caption1)
                    .foregroundColor(DesignSystem.Colors.textTertiary)
            }
            
            if faqs.isEmpty {
                EmptySearchResultsView(searchText: searchText)
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(faqs, id: \.id) { faq in
                        FAQItemView(
                            faq: faq,
                            isExpanded: expandedFAQs.contains(faq.id),
                            searchText: searchText
                        ) {
                            toggleExpansion(for: faq.id)
                        }
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.cardPadding)
        .modernCard(elevation: 1)
    }
    
    private func toggleExpansion(for id: UUID) {
        if expandedFAQs.contains(id) {
            expandedFAQs.remove(id)
        } else {
            expandedFAQs.insert(id)
        }
    }
}

// MARK: - FAQ Item View
struct FAQItemView: View {
    let faq: HelpSupportContent.FAQItem
    let isExpanded: Bool
    let searchText: String
    let onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Question Header
            Button(action: onToggle) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        HStack {
                            Text(highlightedText(faq.question, searchText: searchText))
                                .font(DesignSystem.Typography.callout)
                                .fontWeight(.semibold)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        
                        Text(faq.category.rawValue)
                            .font(DesignSystem.Typography.caption2)
                            .foregroundColor(DesignSystem.Colors.primary)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, 2)
                            .background(DesignSystem.Colors.primary.opacity(0.1))
                            .cornerRadius(DesignSystem.CornerRadius.xs)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(DesignSystem.Colors.textTertiary)
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.backgroundSecondary)
                .cornerRadius(DesignSystem.CornerRadius.md)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Answer Content
            if isExpanded {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Divider()
                        .background(DesignSystem.Colors.borderLight)
                    
                    Text(faq.answer)
                        .font(DesignSystem.Typography.callout)
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Tags
                    if !faq.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                ForEach(faq.tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(DesignSystem.Typography.caption2)
                                        .foregroundColor(DesignSystem.Colors.textTertiary)
                                        .padding(.horizontal, DesignSystem.Spacing.sm)
                                        .padding(.vertical, 4)
                                        .background(DesignSystem.Colors.borderLight.opacity(0.5))
                                        .cornerRadius(DesignSystem.CornerRadius.xs)
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.xs)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.md)
                .background(DesignSystem.Colors.surface)
                .cornerRadius(DesignSystem.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(DesignSystem.Colors.border, lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.3), value: isExpanded)
            }
        }
    }
    
    private func highlightedText(_ text: String, searchText: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        if !searchText.isEmpty && searchText.count > 2 {
            let lowercasedText = text.lowercased()
            let lowercasedSearch = searchText.lowercased()
            
            if let range = lowercasedText.range(of: lowercasedSearch) {
                let start = text.distance(from: text.startIndex, to: range.lowerBound)
                let length = searchText.count
                
                if let startIndex = AttributedString.Index(attributedString.startIndex, offsetByCharacters: start),
                   let endIndex = AttributedString.Index(startIndex, offsetByCharacters: length) {
                    attributedString[startIndex..<endIndex].foregroundColor = DesignSystem.Colors.primary
                    attributedString[startIndex..<endIndex].font = .boldSystemFont(ofSize: 16)
                }
            }
        }
        
        return attributedString
    }
}

// MARK: - Empty Search Results View
struct EmptySearchResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(DesignSystem.Colors.textTertiary)
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("No Results Found")
                    .font(DesignSystem.Typography.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                
                Text("Try searching with different keywords or browse by category")
                    .font(DesignSystem.Typography.callout)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("Suggestions:")
                    .font(DesignSystem.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("• Try 'invoice', 'payment', 'client', 'template'")
                    Text("• Search for specific features like 'PDF' or 'email'")
                    Text("• Browse categories above for organized topics")
                }
                .font(DesignSystem.Typography.caption2)
                .foregroundColor(DesignSystem.Colors.textTertiary)
            }
        }
        .padding(DesignSystem.Spacing.massive)
    }
}

#Preview {
    HelpSupportView()
}