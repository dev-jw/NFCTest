//
//  RootRow.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct RootRow: View {
    
    private let onTapCompleted: () -> Void
    @State var opacity: Double = 0.0
    
    private let _body: AnyView
    var body: some View {
        ZStack {
            HStack(spacing: 16.0) {
                VStack(alignment: .leading, spacing: 4.0) {
                    _body
                }
                .layoutPriority(1)
                Spacer().frame(height: 0.0)
            }
            .onTapGesture(perform: onTapCompleted)
            .padding()
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.25), lineWidth: 1)
        )
        .padding()
        .opacity(opacity)
        .padding([.horizontal], 16.0)
        .padding([.bottom], -8.0)
        .onAppear {
            withAnimation {
                self.opacity = 1.0
            }
        }
    }
    
    init?<V>(content: V?, onTapCompleted: @escaping () -> Void) where V: View  {
        guard let content = content else { return nil }
        self._body = AnyView(content)
        self.onTapCompleted = onTapCompleted
    }
}

struct RootRow_Previews: PreviewProvider {
    static var previews: some View {
        RootRow(content: EmptyView(), onTapCompleted: {})
    }
}
