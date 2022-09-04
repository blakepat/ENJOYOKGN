//
//  LaunchView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-06-24.
//

import SwiftUI

struct LaunchView: View {
    
    @Binding var showLaunchScreen: Bool
//    @State var showLoadingText = false
    @State var counter = 0
    @State var loops = 0
    private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    
    var body: some View {
        ZStack {
            Color.OKGNDarkBlue.ignoresSafeArea()
            
            VStack {
                HStack {
                    ForEach(awardImages.indices, id: \.self) { index in
                        Image(uiImage: awardImages[index])
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .offset(y: counter == index ? -5 : 0)
                    }
                }
                .transition(AnyTransition.scale.animation(.easeIn))
                .padding(.horizontal, 20)
            }
        }

        .onReceive(timer) { _ in
            withAnimation(.spring()) {
                let lastIndex = awardImages.count - 1
                if counter == lastIndex {
                    counter = 0
                    loops += 1
                    
                    if loops >= 3 {
                        showLaunchScreen = false
                    }
                } else {
                    counter += 1
                }
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView(showLaunchScreen: .constant(true))
    }
}
