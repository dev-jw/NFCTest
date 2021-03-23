//
//  CircleSystemButton.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct CircleSystemButton: View {
    private let action: () -> Void
    
    private let systemName: String
    
    init(systemName: String = "plus.circle.fill", action: @escaping () -> Void = {}) {
        self.action = action
        self.systemName = systemName
    }

    var body: some View {
    VStack {
        Spacer()
        HStack {
            Spacer()
            Button(action: action) {
                Image(systemName: systemName)
                    .resizable()
                    .frame(width: 36.0, height: 36.0)
                    .background(Color.init("sectionTitleColor"))
                    .foregroundColor(Color.init("sectionColor"))
                    .clipShape(Circle())
                    .shadow(color: .primary, radius: 1.0)
            }
//            .offset(x: -32, y: -16)
        }
    }
}
}

#if DEBUG
struct CircleSystemButton_Previews: PreviewProvider {
    static var previews: some View {
        CircleSystemButton()
    }
}
#endif
