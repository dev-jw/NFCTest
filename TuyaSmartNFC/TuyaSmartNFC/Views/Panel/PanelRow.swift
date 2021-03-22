//
//  PanelRow.swift
//  TuyaSmartNFC
//
//  Copyright (c) 2014-2021 Tuya Inc. (https://developer.tuya.com/)

import SwiftUI
import TuyaSmartDeviceKit

enum PanelRowType: String {
    case switchRow  = "panel-switch-row"
    case sliderRow  = "panel-slider-row"
    case enumRow    = "panel-enum-row"
    case stringRow  = "panel-string-row"
    case labelRow   = "panel-label-row"
    
    static func identifier(with schema: TuyaSmartSchemaModel) -> Self {
        let type = schema.type == "obj" ? schema.property.type : schema.type
        
        switch type {
        case "bool":
            return Self.switchRow
        case "enum":
            return Self.enumRow
        case "value":
            return Self.sliderRow
        case "bitmap":
            return Self.labelRow
        case "string":
            return Self.stringRow
        case "raw":
            return Self.stringRow
        default:
            return Self.labelRow
        }
    }
}


struct PanelRowBase: View {
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
            .padding()
        }
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.25), lineWidth: 1)
        )
        .padding()
        .opacity(opacity)
        .padding([.bottom], -8.0)
        .onAppear {
            withAnimation {
                self.opacity = 1.0
            }
        }
    }
    
    init?<V>(content: V?) where V: View  {
        guard let content = content else { return nil }
        self._body = AnyView(content)
    }
}

class ActionSheetState: ObservableObject {
    @Published var showActionSheet: Bool = false
}


struct PanelRow: View {
    @EnvironmentObject private var store: AppStore
    
    @ObservedObject private var actionSheetState: ActionSheetState = .init()
    
    var schemaModel: TuyaSmartSchemaModel
    
    var body: some View {
        VStack {
            switch PanelRowType.identifier(with: schemaModel) {
            case .labelRow:
                PanelRowBase(content: HStack {
                    Text("\(schemaModel.name)")
                    Spacer()
                    setupText()
                })
            case .switchRow:
                PanelRowBase(content: HStack {
                    Text("\(schemaModel.name)")
                    Spacer()
                    setupToggle()
                })
            case .enumRow:
                PanelRowBase(content: HStack {
                    Text("\(schemaModel.name)")
                    Spacer()
                    Button(action: {
                        // 选择模式
                        actionSheetState.showActionSheet = true
                    }) {
                        Text(store.state.deviceState.device?.deviceModel.dps[schemaModel.dpId as String] as! String)
                    }
                })
            case .sliderRow:
                PanelRowBase(content: HStack {
                    Text("\(schemaModel.name)")
                    Spacer()
                    setupSlider()
                })
            case .stringRow:
                PanelRowBase(content: HStack {
                    Text("\(schemaModel.name)")
                    Spacer()
                    setupString()
                })
            }
        }
        .actionSheet(isPresented: $actionSheetState.showActionSheet) {
            ActionSheet(
                title: Text(""),
                message: Text("Please choose one of the following ways"),
                buttons: setupButtons()
            )
        }
    }
    
    
    func setupText() -> AnyView {
        guard let dps = store.state.deviceState.device?.deviceModel.dps else { return AnyView(EmptyView()) }
        guard let value = dps[schemaModel.dpId as String] else { return AnyView(EmptyView()) }
        
        var text = ""
        
        ((value as? Int) != nil) ? (text = String(value as! Int)) : (text = value as? String ?? "")
        return AnyView(Text(text))
    }
    
    func setupToggle() -> AnyView {
        guard let dps = store.state.deviceState.device?.deviceModel.dps else { return AnyView(EmptyView()) }
        guard let value = dps[schemaModel.dpId as String] else { return AnyView(EmptyView()) }
        
        return AnyView(
            Toggle("", isOn: Binding<Bool>(get: {
                return value as! Bool
            }, set: { newValue in
                
                // 发送 dp 指令
                store.dispatch(DeviceAction.publishDps(with: [schemaModel.dpId: newValue], dpId: schemaModel.dpId))
            }))
        )
    }
    
    
    func setupButtons() -> [ActionSheet.Button] {
        
        var arr: [ActionSheet.Button] = []
        
        let options = schemaModel.property.range as! [String]
        
        options.forEach({ title in
            arr.append(            ActionSheet.Button.default(Text("\(title)")) {
                
                store.dispatch(DeviceAction.publishDps(with: [schemaModel.dpId: title], dpId: schemaModel.dpId))
            })
        })
        
        arr.append(ActionSheet.Button.cancel())
        return arr
    }
    
    func setupSlider() -> AnyView {
        guard let dps = store.state.deviceState.device?.deviceModel.dps else { return AnyView(EmptyView()) }
        guard let value = dps[schemaModel.dpId as String] else { return AnyView(EmptyView()) }
        
        let min = Float(schemaModel.property.min)
        let max = Float(schemaModel.property.max)
        
        return AnyView(
            Slider(value:
                    Binding<Float>(get: {
                        return value as! Float
                    }, set: { newValue in
                        store.dispatch(DeviceAction.publishDps(with: [schemaModel.dpId: newValue], dpId: schemaModel.dpId))
                    }),
                   in: min...max,
                   step: 0.5)
        )
    }
    
    func setupString() -> AnyView {
        guard let dps = store.state.deviceState.device?.deviceModel.dps else { return AnyView(EmptyView()) }
        guard let value = dps[schemaModel.dpId as String] else { return AnyView(EmptyView()) }
        
        var text = ""
        
        ((value as? Int) != nil) ? (text = String(value as! Int)) : (text = value as? String ?? "")
        
        return AnyView(
            VStack {
                TextField("", text: Binding<String>(get: {
                    return text
                }, set: { A,B in
                    print("\(A) + \(B)")
                }))
                .autocapitalization(.words)
                .font(Font.system(size: 14))
                .frame(width: 120)
                Button("Send", action: {
                    
                })

            }
        )
    }
    
}

struct PanelRow_Previews: PreviewProvider {
    static var previews: some View {
        PanelRow(schemaModel: TuyaSmartSchemaModel()).environmentObject(AppMain().store)
    }
}
