//
//  magFieldVM.swift
//  magField
//
//  Created by J Lambert on 05/12/2022.
//

import Foundation
import CoreMotion

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
            if !isRecording && !self.recordedData.isEmpty {
                self.hasDataToExport = true
            }
        }
    }
    
    @Published
    var isZeroed = false {
        didSet{
            if isZeroed {
                self.zeroedField = self.field!
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
                self.recordField()
            }
        }
    }
    
    @Published
    var zeroedField = Field.zero
    
    var recordedData: [Measurement] = []
    
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
    
//    MARK:- Private
    
    private
    lazy
    var motionManager: CMMotionManager = {
        let o = CMMotionManager()
        o.magnetometerUpdateInterval = 1/20
        return o
    }()
    
    private
    let dateFormatter = {
        let o = DateFormatter()
        o.dateFormat = "A"
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
    
    private
    func recordField() -> Void{
        let time: String = self.dateFormatter.string(from: Date.now)
        self.recordedData.append(Measurement(field: self.field!, timestamp: time))
    }
    
    init() {
        self.isRunning = true
    }
}
