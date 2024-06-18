//
//  ContentView + recording.swift
//  magField
//
//  Created by J Lambert on 13/12/2022.
//

import SwiftUI

extension ContentView {
    
    @ViewBuilder
    func settings() -> some View {
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
            ShareLink(item: self.csvData)
        }
        .opacity(model.hasDataToExport ? 1 : 0)
    }    
}
