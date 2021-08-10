//
//  ContentView.swift
//  UITrace2021年8月10日
//
//  Created by 吉田周平 on 2021/08/10.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = ContentViewModel()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {}, label: {
                    Text("skip")
                        .fontWeight(.bold)
                        .padding()
                })
            }
            PagingView(index: $viewModel.index, maxIndex: viewModel.maxIndex) {
                ForEach(0..<viewModel.maxIndex) {_ in
                    VStack {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.blue)
                            .frame(width:300, height: 300)
                            .padding()
                        Text("If they're there, we'll find'em")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        Text("SeatGeek brings together tickets from hundreds of sites to save you time and money.")
                            .padding()
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                }
            }
            PageControl(index: $viewModel.index, maxIndex: viewModel.maxIndex)
            HStack {
                Button(action: {}, label: {
                    Text("Sign up")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding()
                })
                Button(action: {}, label: {
                    Text("Log in")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .padding()
                })
            }
            HStack {
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Text("Terms Of Use")
                        .font(.callout)
                        .foregroundColor(.secondary)
                })
                Text("|")
                    .font(.callout)
                    .foregroundColor(.secondary)
                Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                    Text("Privacy Policy")
                        .font(.callout)
                        .foregroundColor(.secondary)
                })
            }
        }
    }
}

class ContentViewModel: ObservableObject {
    @Published var index = 0
    let maxIndex = 2
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

///https://stackoverflow.com/questions/58896661/swiftui-create-image-slider-with-dots-as-indicators
struct PagingView<Content>: View where Content: View {
    
    @Binding var index: Int
    let maxIndex: Int
    let content: () -> Content
    
    @State private var offset = CGFloat.zero
    @State private var dragging = false
    
    init(index: Binding<Int>,
         maxIndex: Int,
         @ViewBuilder content: @escaping () -> Content) {
        self._index = index
        self.maxIndex = maxIndex
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        self.content()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                    }
                }
                .content.offset(x: self.offset(in: geometry), y: 0)
                .frame(width: geometry.size.width, alignment: .leading)
                .gesture(
                    DragGesture().onChanged { value in
                        self.dragging = true
                        self.offset = -CGFloat(self.index) * geometry.size.width + value.translation.width
                    }
                    .onEnded { value in
                        let predictedEndOffset = -CGFloat(self.index) * geometry.size.width + value.predictedEndTranslation.width
                        let predictedIndex = Int(round(predictedEndOffset / -geometry.size.width))
                        self.index = self.clampedIndex(from: predictedIndex)
                        withAnimation(.easeOut) {
                            self.dragging = false
                        }
                    }
                )
            }
            .clipped()
        }
    }
    
    func offset(in geometry: GeometryProxy) -> CGFloat {
        if self.dragging {
            return max(min(self.offset, 0), -CGFloat(self.maxIndex) * geometry.size.width)
        } else {
            return -CGFloat(self.index) * geometry.size.width
        }
    }
    
    func clampedIndex(from predictedIndex: Int) -> Int {
        let newIndex = min(max(predictedIndex, self.index - 1), self.index + 1)
        guard newIndex >= 0 else { return 0 }
        guard newIndex <= maxIndex else { return maxIndex }
        return newIndex
    }
}

struct PageControl: View {
    @Binding var index: Int
    let maxIndex: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0...maxIndex, id: \.self) { index in
                Circle()
                    .fill(index == self.index ? Color.blue : Color.gray)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(15)
    }
}
