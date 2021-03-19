//
//  HomeListView.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI

struct HomeListView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack {
            HStack { EmptyView() }
            ZStack {
                ScrollView {
                    LazyVStack(content: {
                        ForEach(store.state.homeState.homes, id: \.self) { home in
                            
                            RootRow(content: HStack {
                                Text("Name: \(home.name ?? "")")
                                Spacer()
                                Text("Delete").foregroundColor(.red).onTapGesture {
                                    store.dispatch(HomeAction.delete(home.homeId))
                                }
                            }) {
                                
                                store.dispatch(HomeAction.switchCurrentHome(home.homeId))
                                // 设置 当前 home 并返回
                                presentationMode.wrappedValue.dismiss()
                                
                            }.animation(.easeIn(duration: 0.3))
                            
                        }
                    })
                }
            }
            .layoutPriority(1)
        }
        .navigationBarTitle("Homes")
        .navigationBarItems(trailing:
                                Button(action: {
                                    store.dispatch(HomeAction.create())
                                }) {
                                    Text("Create")
                                })
        .onAppear { self.store.dispatch(HomeAction.subscribe()) }
    }
}

struct HomeListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListView().environmentObject(AppMain().store)
    }
}
