//
//  ContentView.swift
//  BetterRest
//
//  Created by Prasanna Bhat on 07/08/24.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var coffeeCups = 1
    @State private var hoursOfSleep = 8.0
    @State private var wakeUp = defaultWakeupTime
    @State private var alertMessage = ""
    @State private var isAlertPresent = false
    
    private static var defaultWakeupTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 10) {
                    Text("When do you want to wake up ?")
                    DatePicker("Wake up time",
                               selection: $wakeUp,
                               displayedComponents: .hourAndMinute)
                    .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Desired Amount of Sleep")
                    Stepper("\(hoursOfSleep.formatted()) hours", value: $hoursOfSleep,
                            in: 6...12, step: 0.25)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Daily coffee intake")
                    Stepper("\(coffeeCups) cup(s)", value: $coffeeCups, in: 0...10)
                }
            }
            .toolbar {
                Button("Calculate") {
                    calculateBedTime()
                }
            }
            .alert(alertMessage,
                   isPresented: $isAlertPresent) {
                Button("OK") { }
            }
            .navigationTitle("Better Rest")
        }
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let sleepCalculator = try SleepCalculator(configuration: config)
            
            // get seconds of selected sleep
            let component = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            var timeInSeconds = (component.hour ?? 0) * 60 * 60
            timeInSeconds += (component.minute ?? 0) * 60
            let prediction = try sleepCalculator.prediction(wake: Double(timeInSeconds),
                                                               estimatedSleep: hoursOfSleep,
                                                               coffee: Double(coffeeCups))
            let bedTime = wakeUp - prediction.actualSleep
            alertMessage = "Your BedTime is \(bedTime.formatted(date: .omitted, time: .shortened))"
            
        } catch {
            alertMessage = "Error While Calculating Your Bedtime"
        }
        isAlertPresent = true
    }
}

#Preview {
    ContentView()
}
