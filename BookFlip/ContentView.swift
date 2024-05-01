//
//  ContentView.swift
//  BookFlip
//
//  Created by 渡邊魁優 on 2024/05/01.
//

import SwiftUI

struct ContentView: View {
    @State private var progress: CGFloat = 0
    var body: some View {
        NavigationStack {
            VStack {
                OpenableBookFlipView(config: .init(progress: progress)) { size in
                    FrontView(size: size)
                } insideLeft: { size in
                    LeftView(size: size)
                } insideRight: { size in
                    RightView(size: size)
                }
                Slider(value: $progress)
                    .padding(10)
                    .background(.background, in: .rect(cornerRadius: 10))
                    .padding(.top)
            }
            .padding()
            .navigationTitle("Book Flip")
        }
    }
    @ViewBuilder func FrontView(size: CGSize) -> some View {
        Rectangle()
            .frame(width: size.width/2, height: size.height/2)
            .offset(y: 10) //上を削る
    }
    @ViewBuilder func LeftView(size: CGSize) -> some View {
        Rectangle()
            .frame(width: size.width/2, height: size.height/2)
            .foregroundStyle(Color.blue)
            .overlay {
                Text("Left")
            }
    }
    @ViewBuilder func RightView(size: CGSize) -> some View {
        Rectangle()
            .frame(width: size.width/2, height: size.height/2)
            .foregroundStyle(Color.red)
            .overlay {
                Text("Right")
            }
    }
}

struct OpenableBookFlipView<Front: View, InsideLeft: View, InsideRight: View>: View {
    var config: Config = .init()
    @ViewBuilder var front: (CGSize) -> Front
    @ViewBuilder var insideLeft: (CGSize) -> InsideLeft
    @ViewBuilder var insideRight: (CGSize) -> InsideRight
    var body: some View {
        GeometryReader {
            let size = $0.size
            let progress = max(min(config.progress, 1), 0)
            let rotation = progress * -100
            let cornerRadius = config.cornerRadius
            let shadowColor = config.shadowColor
            
            ZStack {
                insideRight(size)
                    .frame(width: size.width, height: size.height)
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: cornerRadius,
                            topTrailingRadius: cornerRadius
                        )
                    )
                    .shadow(color: shadowColor, radius: 5, x: 0, y: 0)
    
                front(size)
                    .frame(width: size.width/2, height: size.height/2)
                    .allowsHitTesting(-rotation < 90)
                    .overlay {
                        if -rotation * 1.4 > 90 {
                            insideLeft(size)
                                .frame(width: size.width, height: size.height)
                            //背面のViewなのでViewを反転
                                .scaleEffect(x: -1)
                                .transition(.identity)
                        }
                    }
                    .clipShape(
                        .rect(
                            topLeadingRadius: 0,
                            bottomLeadingRadius: 0,
                            bottomTrailingRadius: cornerRadius,
                            topTrailingRadius: cornerRadius
                        )
                    )
                    .rotation3DEffect(
                        .init(degrees: rotation * 1.4),
                        //回転する方向設定
                        axis: (x: 0, y: 1, z: 0),
                        //支点が左側になる
                        anchor: .leading,
                        perspective: 0.3
                    )
            }
            //Sliderを動かすと本が動くようにする
            .offset(x: (config.width / 2) * progress)
        }
    }
    
    struct Config {
        var width: CGFloat = 150
        var height: CGFloat = 200
        var progress: CGFloat = 0
        var cornerRadius: CGFloat = 10
        var shadowColor: Color = .black
    }
}

#Preview {
    ContentView()
}
