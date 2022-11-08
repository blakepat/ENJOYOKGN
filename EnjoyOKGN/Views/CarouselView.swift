//
//  CarouselView.swift
//  EnjoyOKGN
//
//  Created by Blake Patenaude on 2022-09-25.
//

import SwiftUI

struct CarouselView<Content: View, Item, ID>: View where Item: RandomAccessCollection, ID: Hashable {
    
    var content: (Item.Element, CGSize)->Content
    var id: KeyPath<Item.Element, ID>
    
    //View Properties
    var spacing: CGFloat
    var cardPadding: CGFloat
    var items: Item
    @Binding var index: Int
    
    init(index: Binding<Int>, items: Item,spacing: CGFloat = 30, cardPadding: CGFloat = 80, id: KeyPath<Item.Element, ID>, @ViewBuilder content: @escaping (Item.Element, CGSize) -> Content) {
        
        self.content = content
        self.id = id
        self._index = index
        self.spacing = spacing
        self.cardPadding = cardPadding
        self.items = items
        
    }
    
    //Gesture Properties
    @GestureState var translation: CGFloat = 0
    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    
    @State var currentIndex: Int = 0
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            let cardWidth = size.width - (cardPadding - spacing)
            LazyHStack(spacing: spacing) {
                ForEach(items, id: id) { category in
                    
                    content(category, CGSize(width: size.width - cardPadding, height: size.height))
                        .frame(width: size.width - cardPadding, height: size.height)
                        .contentShape(Rectangle())
                }
            }
            .padding(.horizontal, spacing)
            .offset(x: limitScroll())
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 5)
                    .updating($translation, body: { value, out, _ in
                        out = value.translation.width
                    })
                    .onChanged { onChanged(value: $0, cardWidth: cardWidth) }
                    .onChanged { onEnd(value: $0, cardWidth: cardWidth) }
            )
        }
        .onAppear {
            let extraSpace = (cardPadding / 2) - spacing
            offset = extraSpace
            lastStoredOffset = extraSpace
        }
    }
    
    func limitScroll() -> CGFloat {
        let extraSpace = (cardPadding / 2) - spacing
        if index == 0 && offset > extraSpace {
            return extraSpace + (offset / 4)
        } else if index == items.count - 1 && translation > 0 {
             return offset - (translation / 2)
        } else {
            return offset
        }
    }
    
    
    
    
    func onChanged(value: DragGesture.Value, cardWidth: CGFloat) {
        let translationX = value.translation.width
        offset = translationX + lastStoredOffset
    }
    
    func onEnd(value: DragGesture.Value, cardWidth: CGFloat) {
        //finding current index
        var _index = (offset / cardWidth).rounded()
        _index = max(-CGFloat(items.count - 1), _index)
        _index = min(_index, 0)
        
        currentIndex = Int(_index)
        index = -currentIndex
        
        withAnimation(.easeInOut(duration: 0.25)) {
            let extraSpace = (cardPadding / 2) - spacing
            offset = cardWidth * _index + extraSpace
        }
        
        lastStoredOffset = offset
    }
    
    
}

struct CarouselView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView(tabSelection: .constant(.home))
    }
}
