//
//  ContentView.swift
//  magField
//
//  Created by J Lambert on 05/12/2022.
//

import SwiftUI


enum Component: String{
    case x = "x"
    case y = "y"
    case z = "z"
    case magnitude = "magnitude"
}


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
    
    @State
    internal
    var recordingMessageOpacity: Double = 1
    
    internal
    var csvData: String {
        let exporter: CSVWriter = CSVWriter(rows: model.recordedData, units: self.unit)
        return exporter.csvData
    }
    
    private
    func getField(for component : Component) -> String {
        var value : Double = 0.0
        
        switch component {
            case .x:
            value = model.field?.x(in: self.unit) ?? 0.0
            case .y:
            value = model.field?.y(in: self.unit) ?? 0.0
            case .z:
            value = model.field?.z(in: self.unit) ?? 0.0
            case .magnitude:
            value = model.field?.magnitude(in: self.unit) ?? 0.0
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
                .opacity(model.field?.magnitude(in: self.unit) ?? 0.0 > 1.2 * model.zeroedField.magnitude(in: self.unit) ? 1 : 0)

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
            
            List{
                Picker("Sample Interval / s", selection: $model.selectedInterval){
                    ForEach(SampleInterval.allCases){f in
                        Text(String(describing: f))
                    }
                }
                Picker("Units", selection: $unit){
                    ForEach(Unit.allCases){ unit in
                        Text(String(describing: unit))
                    }
                }
            }
        }
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
    
    internal
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
