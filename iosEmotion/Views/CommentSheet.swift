import SwiftUI

struct CommentSheet: View {
    @ObservedObject var store: PostStore
    var postID: UUID
    @State private var newComment: String = ""
    @Environment(\.dismiss) var dismiss
    
    var post: Post? {
        store.posts.first(where: { $0.id == postID })
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if let post = post {
                    List {
                        if post.comments.isEmpty {
                            Text("No comments yet. Be the first to share your thoughts.")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .listRowSeparator(.hidden)
                                .padding(.top, 20)
                        } else {
                            ForEach(post.comments, id: \.self) { comment in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("You")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("AppPurple"))
                                    Text(comment)
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.plain)
                    
                    Divider()
                    
                    HStack {
                        TextField("Add a comment...", text: $newComment)
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        
                        Button(action: {
                            if !newComment.isEmpty {
                                store.addComment(to: postID, text: newComment)
                                newComment = ""
                            }
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(newComment.isEmpty ? .gray : Color("AppPurple"))
                                .padding(10)
                        }
                        .disabled(newComment.isEmpty)
                    }
                    .padding()
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
