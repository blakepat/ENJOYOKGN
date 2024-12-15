//
//  OnboardingView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-11-08.
//

import SwiftUI

struct OnboardView: View {
    
    @State var selection = 0
    
    var body: some View {
        ZStack {
            
            LinearGradient(colors: [Color.OKGNDarkYellow, Color.OKGNDarkBlue],
                           startPoint: .top,
                           endPoint: .bottom).ignoresSafeArea()
                .overlay(
                    ZStack {
                        
                        backgroundWave2()
                            .fill(
                                LinearGradient(colors: [.OKGNLightGreen, .OKGNDarkYellow],
                                               startPoint: .topLeading,
                                               endPoint: .bottom)
                            )
                        
                        backgroundWave()
                            .fill(
                                LinearGradient(colors: [.OKGNLightGreen, .OKGNPeach],
                                               startPoint: .topLeading,
                                               endPoint: .bottomTrailing)
                            )
                            .ignoresSafeArea(edges: .bottom)
                    }
                )
            VStack {
                Spacer()
                
                TabView(selection: $selection) {
                    OnboardInfoView(imageName: "building.2.crop.circle",
                                    title: "See Points of Interest",
                                    descriptionOne: "☼ Find cool places to eat, drink, or play in the Okanagan!",
                                    descriptionTwo: "☼ You can search either by map or list!",
                                    descriptionThree: "☼ On the list you can filter by category or favourites",
                                    selection: $selection).tag(0)
                    
                    OnboardInfoView(imageName: "newspaper.circle",
                                    title: "Review and Share",
                                    descriptionOne: "☼ Review locations by sharing a photo and rating with friends!",
                                    descriptionTwo: "☼ See your friends favourites spots and visit them next!",
                                    descriptionThree: "☼ Show your friends your favourite spots!",
                                    selection: $selection).tag(1)
                    
                    OnboardInfoView(imageName: "star.circle",
                                    title: "Awarded Locations",
                                    descriptionOne: "☼ Your top rated locations will get awards",
                                    descriptionTwo: "☼ Keep track of what is the best Pizza, Brewery, Winery in town!",
                                    descriptionThree: "☼ Compare your top spots with your friends top spots!",
                                    selection: $selection).tag(2)
                    
                    OnboardInfoView(imageName: "newspaper.circle",
                                    title: "End User License Agreement",
                                    descriptionOne: EULA,
                                    selection: $selection).tag(3)
                }
                .tabViewStyle(PageTabViewStyle())
                .padding(.bottom, 32)
            }

        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardView()
    }
}



struct backgroundWave: Shape {
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            
            path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.midY * 1.25), control: CGPoint(x: rect.width * 0.25, y: rect.height * 0.60))
            
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY * 1.8), control: CGPoint(x: rect.width * 0.65, y: rect.height * 0.80))
            
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            
        }
    }
}

struct backgroundWave2: Shape {
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY * 1.25), control: CGPoint(x: rect.midX, y: rect.midY))
            
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }
    }
}


struct OnboardInfoView: View {
    
    var imageName: String
    var title: String
    var descriptionOne: String
    var descriptionTwo: String?
    var descriptionThree: String?
    @Binding var selection: Int
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {

            VStack(alignment: .center, spacing: 4)  {
                    HStack {
                        Image(systemName: imageName)
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.OKGNDarkYellow)
                        
                        LinearGradient(colors: [.OKGNLightGreen, .OKGNDarkYellow],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                        .frame(height: 100)
                        .mask {
                            Text(title)
                                .font(.largeTitle)
                                .bold()
                                .minimumScaleFactor(0.6)
                        }
                    }
                    .padding()
                    
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(descriptionOne)
                            .foregroundColor(.white.opacity(0.8))
                            .minimumScaleFactor(0.75)
                            .padding(.bottom)
                        
                        Text(descriptionTwo ?? "")
                            .foregroundColor(.white.opacity(0.8))
                            .minimumScaleFactor(0.75)
                            .padding(.bottom)
                        
                        
                        Text(descriptionThree ?? "")
                            .foregroundColor(.white.opacity(0.8))
                            .minimumScaleFactor(0.75)
                            .padding(.bottom)
                    }
                }
                .frame(height: 300)


                Button {
                    if selection == 3 {
                        dismiss()
                    } else {
                        withAnimation(.linear) {
                            selection += 1
                        }
                    }
                } label: {
                    Text(selection == 3 ? "I Agree" : "Next")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 30, alignment: .center)
                        .background(Color.OKGNDarkYellow.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                .blur(radius: 1)
                        )
                }
            }
            .padding()
            .background(
                LinearGradient(colors: [.OKGNDarkBlue, .clear],
                               startPoint: .top,
                               endPoint: .bottom)
            
            )
            .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        LinearGradient(colors: [.white, .clear],
                                       startPoint: .top,
                                       endPoint: .bottom)
                        , lineWidth: 1)
                    .blendMode(.overlay)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(
                                LinearGradient(colors: [.white, .clear],
                                               startPoint: .top,
                                               endPoint: .bottom)
                                , lineWidth: 2)
                            .blur(radius: 5)
                    )
            )
            .background(
                VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
                    .mask(RoundedRectangle(cornerRadius: 30, style: .continuous))
            )
                
            .padding()
        
    }
}
