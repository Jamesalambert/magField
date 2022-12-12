//
//  ContentView.swift
//  magField
//
//  Created by J Lambert on 05/12/2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject
    var model: MagFieldVM
    
    @State
    var unit: Unit = .gauss

    private
    let componentFormatter = {
        let o: NumberFormatter = NumberFormatter()
        o.maximumFractionDigits = 2
        o.minimumFractionDigits = 2
        o.positivePrefix = " "
        return o
    }()
    
    private
    let magnitudeFormatter = {
        let o: NumberFormatter = NumberFormatter()
        o.maximumFractionDigits = 2
        o.minimumFractionDigits = 2
        return o
    }()
    
    enum Unit : String, CaseIterable {
        case tesla = "T"
        case microTesla = "μT"
        case gauss = "G"
    }
    
    enum Component: String{
        case x = "x"
        case y = "y"
        case z = "z"
        case magnitude = "magnitude"
    }
    
    @State
    private
    var recordingMessageOpacity: Double = 1
    
    private
    func getField(for component : Component) -> String {
        var value : Double = 0.0
        switch component {
            case .x:
                value = model.field?.x ?? 0.0
            case .y:
                value = model.field?.y ?? 0.0
            case .z:
                value = model.field?.z ?? 0.0
            case .magnitude:
                value = model.field?.magnitude ?? 0.0
        }
        
        switch self.unit{
            case .gauss:
                value /= 100
            case .microTesla:
                value /= 1
            case .tesla:
                value /= 1_000_000
        }
        
        let formatter = component == .magnitude ? self.magnitudeFormatter : self.componentFormatter

        let formattedValue: String = formatter.string(from: value as NSNumber) ?? "---"
        return formattedValue + unit.rawValue
    }
    
    var body: some View {
        VStack{
            Spacer()
            
            compass()
                .frame(maxWidth: 100, maxHeight: 100)
                .rotationEffect(
                    Angle(radians: model.field?.direction ?? 0.0),
                    anchor: UnitPoint.center)
                .opacity(model.field?.magnitude ?? 0.0 > 1.2 * model.zeroedField.magnitude ? 1 : 0)

            Group{
                Text(getField(for: .magnitude))
                    .font(.largeTitle)
                    .padding()

                VStack(alignment: .leading){
                    Text("x:\t" + getField(for: .x)).foregroundColor(.red)
                    Text("y:\t" + getField(for: .y)).foregroundColor(.green)
                    Text("z:\t" + getField(for: .z)).foregroundColor(.blue)
                }.font(.title)

            }
            .fontDesign(.monospaced)
            
            controls()
            
            Spacer()
            
            Picker("Units", selection: $unit){
                ForEach(Unit.allCases, id: \.self){ unit in
                    Text(unit.rawValue).tag(unit)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: CGFloat(Unit.allCases.count)  * 80)
        }
        
    }

    
    @ViewBuilder
    func controls() -> some View{
        VStack{
            Button(action: {withAnimation(.quickEaseIO){model.zeroUnzero()}}){
                Text(model.isZeroed ? "un-zero" : "zero")
            }
            
            HStack{
                Button(action: {withAnimation(.quickEaseIO){model.playPause()}}){
                    Image(systemName: model.isRunning ? "pause" : "play")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .padding()
                }

                Button(action: {withAnimation(.quickEaseIO){model.recordPause()}}){
                    Image(systemName: model.isRecording ? "stop" : "record.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.red)
                        .padding()
                }
                .opacity(model.isRunning ? 1 : 0)
            }
            
            HStack{
                if model.isRecording{
                    recordingMessage()
                    
                } else if model.hasDataToExport {
                    exportControls()
                }
            }
            .frame(width: 200, height: 40)
        }
    }
    
    
    @ViewBuilder
    func recordingMessage() -> some View {
        Text("Recording...")
            .opacity(self.recordingMessageOpacity)
            .onAppear(perform: {self.recordingMessageOpacity = 0.5})
            .onDisappear(perform: {self.recordingMessageOpacity = 1.0})
            .foregroundColor(.red)
            .animation(.pulse(period: 1.5), value: self.recordingMessageOpacity)
    }
    
    @ViewBuilder
    func exportControls() -> some View {
        HStack(spacing: 30){
            Button(action: {withAnimation(.quickEaseIO){model.clearRecordedData()}}){
                Text("clear data").foregroundColor(.red)
            }
            ShareLink(item: model.exportedData)
        }
        .opacity(model.hasDataToExport ? 1 : 0)
    }
    
    @ViewBuilder
    func compass() -> some View {
        Path(){ path in
            let height: CGFloat = 100
            let width = height
            path.addLines(arrow(width: width, height: height).points)
        }
        .fill(.foreground)
    }
}

private
struct arrow {
    var width: CGFloat
    var height: CGFloat
    var points : [CGPoint] {
        return [
            CGPoint(x: 0.0 * width, y: 0.45 * height),
            CGPoint(x: 0.8 * width, y: 0.45 * height),
            CGPoint(x: 0.8 * width, y: 0.35 * height),
            CGPoint(x: 1.0 * width, y: 0.50 * height),
            CGPoint(x: 0.8 * width, y: 0.65 * height),
            CGPoint(x: 0.8 * width, y: 0.55 * height),
            CGPoint(x: 0.0 * width, y: 0.55 * height)
        ]
    }
}


extension Animation {
    static
    let quickEaseIO = Animation.easeInOut(duration: 0.15)
    static
    func pulse(period : Double = 1.0) -> Animation {
        return Animation.easeInOut(duration: period / 2).repeatForever(autoreverses: true)
    }
}




//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
