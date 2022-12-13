//
//  ContentView + export.swift
//  magField
//
//  Created by J Lambert on 13/12/2022.
//

import SwiftUI

extension ContentView {
    
    struct CSVWriter {
        let columnTitles: [String] = "time,x,y,z,magnitude,direction".split(separator: ",").map{s in String(s)}
        
        var columnUnits: [String] {
            let b_unit = self.units.rawValue
            return ["ms"] + [b_unit, b_unit, b_unit, b_unit] + ["rad"]
        }

        var rows: [Measurement]
        var units: Unit
        
        var csvData: String {
            let headerRow: String = zip(columnTitles, columnUnits).map{title, unit in
                "\(title) (\(unit))"
            }
            .joined(separator: ", ")
            
            let rowData: String = rows.map{row in row.describe(in: self.units)}.joined(separator: "\n")
            return headerRow + "\n" + rowData + "\n"
        }
    }
}
