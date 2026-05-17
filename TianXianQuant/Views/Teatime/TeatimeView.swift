import SwiftUI

struct TeatimeView: View {
    @State private var viewModel = TeatimeViewModel()
    @State private var selectedTab: TeatimeTab = .friends

    enum TeatimeTab: String, CaseIterable {
        case friends = "好友"
        case conversations = "会话"
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented picker
                Picker("", selection: $selectedTab) {
                    ForEach(TeatimeTab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                Divider().foregroundColor(.appDivider)

                // Content
                switch selectedTab {
                case .friends:
                    FriendListView(viewModel: viewModel)
                case .conversations:
                    ConversationListView(viewModel: viewModel)
                }
            }
            .background(Color.appBackground)
            .navigationTitle("茶歇时间")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewModel.loadMockData()
            }
        }
    }
}

#Preview {
    TeatimeView()
}
