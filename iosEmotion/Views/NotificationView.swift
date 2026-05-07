import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var store: PostStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if store.notifications.isEmpty {
                    Text("No notifications yet.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(store.notifications) { notif in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(notif.type == .like ? Color.pink : Color("AppPurple"))
                                .frame(width: 8, height: 8)
                                .opacity(notif.isRead ? 0 : 1)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(notif.message)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Text(notif.timestamp, style: .relative)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Color("CardBackground"))
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        store.markAllAsRead()
                        dismiss()
                    }
                }
            }
            .background(Color("AppBackground"))
            .scrollContentBackground(.hidden)
        }
        .preferredColorScheme(.dark)
    }
}
