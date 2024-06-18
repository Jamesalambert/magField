//
//  MeasurementTypes.swift
//  magField
//
//  Created by J Lambert on 13/12/2022.
//

import Foundation
import ComplexModule

enum Unit : String, CaseIterable, CustomStringConvertible, Identifiable {
    var id: Self {self}
    
    var description: String {
        switch self {
        case .gauss:
            return "Gauss"
        case .milligauss:
            return "milligauss"
        case .microTesla:
            return "microtesla"
        case .tesla:
            return "Tesla"
        }
    }
    
    case tesla = "T"
    case microTesla = "μT"
    case gauss = "G"
    case milligauss = "mG"
}


struct Measurement {
    let field: Field
    let timestamp: String
    func describe(in units: Unit) -> String {
        return "\(timestamp), \(field.describe(in: units))"
    }
}


struct Field : Equatable {
    init(x: Double, y: Double, z: Double){
        self.x = x
        self.y = y
        self.z = z
    }
    
    func x(in units: Unit) -> Double{
        return convert(self.x, to: units)
    }
    
    func y(in units: Unit) -> Double{
        return convert(self.y, to: units)
    }
    
    func z(in units: Unit) -> Double{
        return convert(self.z, to: units)
    }
    
    func magnitude(in units: Unit) -> Double {
        return convert(self.magnitude, to: units)
    }
    
    //    in the xy plane
    var direction: Double {
        let bField = Complex(x, y).normalized ?? Complex(1, 0)
        let out = 7 * Complex.root(bField, 7).imaginary
        return -out
    }
    
    private
    let x: Double
    
    private
    let y: Double
    
    private
    let z: Double
    
    private
    var magnitude: Double {
        return sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2))
    }
    
    
    static func +(lhs: Field, rhs: Field) -> Field{
        return Field(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    static func -(lhs: Field, rhs: Field) -> Field{
        return Field(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    
    func describe(in units: Unit) -> String {
        let x = convert(x, to: units)
        let y = convert(y, to: units)
        let z = convert(z, to: units)
        let mag = convert(magnitude, to: units)
        return "\(x), \(y), \(z), \(mag), \(self.direction)"
    }
    
    private
    func convert(_ value: Double, to unit: Unit) -> Double {
        var value = value           // in milli Gauss
        switch unit{
        case .gauss:
            return value / 1000
        case .milligauss:
            return value
        case .microTesla:
            value /= 1000           // to Gauss
            value /= 10_000         // to Tesla
            value *= 1_000_000      // to micro Tesla
            return value
        case .tesla:
            return value / 1_000_000
        }
    }
    
    static
    let zero = Field(x: 0, y: 0, z: 0)
}


