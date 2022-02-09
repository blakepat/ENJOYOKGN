//
//  DetailedVisitView.swift
//  STOKGN
//
//  Created by Blake Patenaude on 2022-02-03.
//

import SwiftUI

struct DetailedVisitModalView: View {
    
    
    var review: Review
    @Binding var  isShowingDetailedVisitView: Bool
    
    var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                
                Spacer().frame(height: 30)
                
                HStack {
                    
                    Text(review.reviewer.firstName + " " + review.reviewer.lastName)
                    
                    Spacer()
                    
                    Text(review.date, formatter: DateFormatter.shortDate)
                    
                }
                .foregroundColor(Color(.secondarySystemBackground))
                .padding()
                .minimumScaleFactor(0.75)
                
                
                Text(review.location.name)
                    .foregroundColor(review.location.category.color)
                    .font(.title2)
                    .fontWeight(.bold)
                    .minimumScaleFactor(0.75)
                
                Text(review.location.category.description)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                
                
                Image(uiImage: review.photo)
                    .resizable()
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .scaledToFit()
                    .padding()
                
                Text("\"" + review.reviewCaption + "\"")
                    .foregroundColor(.white)
                    
                
            }
            .frame(width: 320, height: 400)
            .padding(.vertical)
            .background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)))
            .cornerRadius(16)
            .overlay(
                Button {
                    withAnimation {
                        isShowingDetailedVisitView = false
                    }
                    
                } label: {
                    XDismissButton(color: review.location.category.color)
                }, alignment: .topTrailing
            )
            
            Image(uiImage: review.reviewer.createProfileImage())
                .resizable()
                .clipShape(Circle())
                .frame(width: 100, height: 100)
                .scaledToFit()
                .font(.title)
                .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 6)
                .offset(y: -220)
            
            
        }
    }
}

struct DetailedVisitView_Previews: PreviewProvider {
    static var previews: some View {
        DetailedVisitModalView(review: MockData.pizzeriaReview, isShowingDetailedVisitView: .constant(true))
            .background(Color.OKGNDarkBlue)
    }
}


struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
