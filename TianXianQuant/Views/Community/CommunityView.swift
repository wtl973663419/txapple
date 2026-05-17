import SwiftUI

struct CommunityView: View {
    @State private var viewModel = CommunityViewModel()
    @State private var showCreatePost = false
    @State private var selectedPost: Post?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.appBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Category chips scroll view
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.categories, id: \.self) { category in
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.filterByCategory(category)
                                    }
                                } label: {
                                    Text(category)
                                        .font(.subheadline)
                                        .fontWeight(viewModel.selectedCategory == category ? .semibold : .regular)
                                        .foregroundColor(viewModel.selectedCategory == category ? .white : .appTextSecondary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(viewModel.selectedCategory == category ? Color.appPrimary : Color.appBackgroundSecondary)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }

                    Divider().foregroundColor(.appDivider)

                    // Post list
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView("加载中...")
                            .tint(.appPrimary)
                        Spacer()
                    } else if viewModel.filteredPosts.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 48))
                                .foregroundColor(.appTextHint)
                            Text("暂无帖子")
                                .font(.headline)
                                .foregroundColor(.appTextSecondary)
                            Text("快来发表第一篇帖子吧")
                                .font(.subheadline)
                                .foregroundColor(.appTextHint)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.filteredPosts) { post in
                                    PostRow(post: post, onLike: {
                                        viewModel.likePost(id: post.id)
                                    })
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedPost = post
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.top, 12)
                            .padding(.bottom, 80)
                        }
                    }
                }

                // FAB - Create post
                Button {
                    showCreatePost = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(
                            Circle()
                                .fill(Color.appPrimary)
                                .shadow(color: .appPrimary.opacity(0.4), radius: 8, y: 4)
                        )
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("社区")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCreatePost) {
                CreatePostSheet(viewModel: viewModel)
            }
            .sheet(item: $selectedPost) { post in
                PostDetailView(post: post, viewModel: viewModel)
            }
            .task {
                viewModel.loadPosts()
            }
        }
    }
}

#Preview {
    CommunityView()
}
