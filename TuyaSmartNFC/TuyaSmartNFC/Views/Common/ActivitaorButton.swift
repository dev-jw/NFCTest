//
//  ActivitaorButton.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct ActivitaorButton: View {
    private let action: () -> Void
    private let nfcAction: () -> Void
    private let sceneAction: () -> Void

    init(action: @escaping () -> Void = {},
         nfcAction: @escaping () -> Void = {},
         sceneAction: @escaping () -> Void = {}) {
        self.action = action
        self.nfcAction = nfcAction
        self.sceneAction = sceneAction
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                HStack {
                    Spacer().frame(width: 5)
                    VStack {
                        Spacer().frame(height: 10)
                        Button(action: sceneAction) {
                            Image(systemName: "command.circle.fill")
                                .resizable()
                                .frame(width: 44.0, height: 44.0)
                                .background(Color.white)
                                .foregroundColor(Color.black)
                                .clipShape(Circle())
                        }
                        Spacer().frame(height: 10)
                        Button(action: nfcAction) {
                            Image(systemName: "wave.3.right.circle.fill")
                                .resizable()
                                .frame(width: 44.0, height: 44.0)
                                .background(Color.white)
                                .foregroundColor(Color.black)
                                .clipShape(Circle())
                        }
                        Spacer().frame(height: 10)
                        Button(action: action) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .frame(width: 44.0, height: 44.0)
                                .background(Color.white)
                                .foregroundColor(Color.black)
                                .clipShape(Circle())
                        }
                        Spacer().frame(height: 10)
                    }
                    Spacer().frame(width: 5)
                }
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.25), lineWidth: 1)
                )
                .shadow(color: .primary, radius: 4.0)
                .frame(width: 60, height: 150)
                .offset(x: -32, y: -16)
            }
        }
    }
}

#if DEBUG
struct ActivitaorButton_Previews: PreviewProvider {
    static var previews: some View {
        ActivitaorButton()
    }
}
#endif
