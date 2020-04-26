//
//  ContentView.swift
//  ColorGame
//
//  Created by ezou on 2020/4/26.
//  Copyright © 2020 ezou. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject
    var viewModel: GameViewModel = .init()
    
    @State
    var scale: CGFloat = 0.1
    
    @State
    var offset: CGFloat = 8.0
        
    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 20.0) {
                Text("Current level: " + String(self.viewModel.level))
                Text("Time remaining: " + String(format: "%.1f", abs(self.viewModel.remaingTimeInterval)))
                VStack(spacing: 0.0) {
                    ForEach(0..<self.viewModel.length, id: \.self) { y in
                        HStack(spacing: 0.0) {
                            ForEach(0..<self.viewModel.length, id: \.self) { x in
                                Circle()
                                    .foregroundColor(self.viewModel.color)
                                    .brightness(self.viewModel.getBrightness(x: x, y: y))
                                    .onTapGesture {
                                        self.viewModel.submit(x: x, y: y)
                                    }
                                    .scaleEffect(self.scale)
                                    .onReceive(self.viewModel.$level) { _ in
                                        self.scale = 0.1
                                        withAnimation(.linear(duration: 0.2)) {
                                            self.scale = 1.0
                                        }
                                    }
                            }
                        }
                    }
                }
                    .frame(height: proxy.frame(in: .global).width)
                    .offset(x: self.offset, y: 0.0)
                    .onReceive(self.viewModel.failureSubject) {
                        self.offset = 8.0
                        withAnimation(Animation.linear(duration: 0.025).repeatCount(3, autoreverses: true)) {
                            self.offset = 0.0
                        }
                    }
            }
        }
            .padding()
            .alert(isPresented: self.viewModel.isFinished) {
                Alert(
                    title: Text("Time's up!!!"),
                    message: Text("Finished at level \(self.viewModel.level)"),
                    dismissButton: nil
                )
            }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
