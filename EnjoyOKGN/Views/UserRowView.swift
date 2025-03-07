//
//  UserRowView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2025-03-06.
//

import SwiftUI

// MARK: - Supporting Views
struct UserRowView: View {
    let user: OKGNProfile
    let isRequested: Bool
    let onAddFriend: () -> Void
    let onCancelRequest: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(uiImage: user.avatar.convertToUIImage(in: .square))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            Text(user.name)
                .foregroundStyle(.white)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
            
            Button(action: { isRequested ? onCancelRequest() : onAddFriend() }) {
                Text(isRequested ? "Cancel" : "Add Friend")
                    .font(.system(size: 14, weight: .medium))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isRequested ? Color.white : Color.blue)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isRequested ? Color.blue : Color.clear, lineWidth: 1)
                    )
                    .foregroundColor(isRequested ? .blue : .white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 2)
    }
}


