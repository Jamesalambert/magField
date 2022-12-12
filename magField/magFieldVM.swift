//
//  magFieldVM.swift
//  magField
//
//  Created by J Lambert on 05/12/2022.
//

import Foundation
import CoreMotion
import ComplexModule


class MagFieldVM: ObservableObject{
        
    @Published
    var isRunning = false  {
        didSet{
            if isRunning {
                self.startReadingMag()
            } else {
                self.motionManager.stopMagnetometerUpdates()
            }
        }
    }
    
    @Published
    var isRecording = false {
        didSet{
            if isRecording {
                self.recordedData.append(self.columnHeaders)
            } else {
                if self.recordedData.count > 2 {
                    self.hasDataToExport = true
                }
            }
        }
    }
    
    @Published
    var isZeroed = false{
        didSet{
            if isZeroed {
                self.zeroedField = self.field ?? Field.zero
            } else {
                self.zeroedField = Field.zero
            }
        }
    }
    
    @Published
    var hasDataToExport = false
    
    @Published
    var field: Field? = nil {
        didSet{
            if isRecording {
                let entry: String = "\(self.dateFormatter.string(from: Date.now)), \(self.field ?? Field.zero)"
                self.recordedData.append(entry)
            }
        }
    }
    
    var exportedData : String {
        return self.recordedData.joined(separator: "\n")
    }
    
    @Published
    var zeroedField = Field.zero
    
    func playPause() -> Void{
        self.isRunning.toggle()
    }
    
    func recordPause() -> Void {
        self.isRecording.toggle()
    }
    
    func clearRecordedData() -> Void {
        self.recordedData = []
        self.hasDataToExport = false
    }
    
    func zeroUnzero() {
        self.isZeroed.toggle()
    }

    
    private
    let columnHeaders = "time (ms), x (μT), y (μT), z (μT), magnitude (μT), direction (rad)"
    
    private
    var recordedData: [String] = []
    
    private
    lazy
    var dateFormatter = {
        let o = DateFormatter()
        o.dateFormat = "A"
        return o
    }()
    
    private
    lazy
    var motionManager: CMMotionManager = {
        let o = CMMotionManager()
        o.magnetometerUpdateInterval = 1/20
        return o
    }()
    
    private
    func startReadingMag() {
        self.motionManager.startMagnetometerUpdates(
            to: .current!,
            withHandler: {(magnetometerData, error) in
                DispatchQueue.main.async {
                    let measuredField = Field(x: magnetometerData?.magneticField.x ?? -999,
                                          y: magnetometerData?.magneticField.y ?? -999,
                                          z: magnetometerData?.magneticField.z ?? -999)
                    self.field = measuredField - self.zeroedField
                }
            }
        )
    }
    
    init() {
        self.isRunning = true
    }
}



struct Field : Equatable, Encodable, CustomStringConvertible {
    var x: Double = 0
    var y: Double = 0
    var z: Double = 0
    
    var magnitude: Double {
        return sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
    }
    
//    in the xy plane
    var direction: Double {
        let bField = Complex(x, y).normalized ?? Complex(1, 0)
        let out = 7 * Complex.root(bField, 7).imaginary
        return -out
    }
    
    static func +(lhs: Field, rhs: Field) -> Field{
        return Field(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    static func -(lhs: Field, rhs: Field) -> Field{
        return Field(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
//    CustomStringConvertible
    var description: String {
        return "\(x), \(y), \(z), \(self.magnitude), \(self.direction)"
    }
    
    static
    let zero = Field(x: 0, y: 0, z: 0)
}
