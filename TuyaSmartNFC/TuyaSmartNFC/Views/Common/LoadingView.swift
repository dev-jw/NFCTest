//
//  LoadingView.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct LoadingView: View {
    private let isLoading: Bool
    init(isLoading: Bool) {
        self.isLoading = isLoading
    }
    
    var body: some View {
        ZStack {
            if isLoading {
                
                VStack{
                    Spacer()
                        .background(Color.primary)
                        .opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                    ActivityIndicator()
                }
                .padding()
                .frame(maxWidth: 175, maxHeight: 175, alignment: .center)
                .cornerRadius(10)
            }
        }
    }
}

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(isLoading: true)
    }
}
#endif

#if os(macOS)
@available(macOS 11, *)
struct ActivityIndicator: NSViewRepresentable {
    
    func makeNSView(context: NSViewRepresentableContext<ActivityIndicator>) -> NSProgressIndicator {
        let nsView = NSProgressIndicator()
        
        nsView.isIndeterminate = true
        nsView.style = .spinning
        nsView.startAnimation(context)
        
        return nsView
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: NSViewRepresentableContext<ActivityIndicator>) {
    }
}
#else
@available(iOS 13, *)
struct ActivityIndicator: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        
        let progressView = UIActivityIndicatorView(style: .large)
        progressView.startAnimating()
        
        return progressView
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
    }
}
#endif
