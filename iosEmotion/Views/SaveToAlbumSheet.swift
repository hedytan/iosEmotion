import SwiftUI

struct SaveToAlbumSheet: View {
    @EnvironmentObject var store: PostStore
    var postID: UUID
    @Environment(\.dismiss) var dismiss
    
    @State private var showCreateNew = false
    @State private var newAlbumTitle = ""
    @State private var newAlbumTag = "MY COLLECTION"

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("YOUR ALBUMS").font(.caption).fontWeight(.bold)) {
                    ForEach(store.boards) { board in
                        Button(action: {
                            store.savePost(postID: postID, toBoardID: board.id)
                            dismiss()
                        }) {
                            HStack(spacing: 15) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(board.color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "folder.fill")
                                            .foregroundColor(.white.opacity(0.5))
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(board.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(board.tag)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if board.postIDs.contains(postID) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color("AppPurple"))
                                }
                            }
                        }
                    }
                }
                
                Section {
                    if showCreateNew {
                        VStack(spacing: 12) {
                            TextField("Album Title", text: $newAlbumTitle)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Tag (e.g. MOOD, BEAT)", text: $newAlbumTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: {
                                if !newAlbumTitle.isEmpty {
                                    store.createBoard(title: newAlbumTitle, tag: newAlbumTag.uppercased())
                                    newAlbumTitle = ""
                                    showCreateNew = false
                                }
                            }) {
                                Text("Create & Add")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color("AppPurple"))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        Button(action: { showCreateNew = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create New Album")
                            }
                            .foregroundColor(Color("AppPurple"))
                            .fontWeight(.bold)
                        }
                    }
                }
            }
            .navigationTitle("Save to...")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Color("AppPurple"))
                }
            }
        }
    }
}
