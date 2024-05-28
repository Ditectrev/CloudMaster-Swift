import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @Binding var isPresented: Bool
    @Binding var notificationsEnabled: Bool
    @State private var selectedFrequency = 1
    @State private var selectedTime = Date()
    @State private var showAlert = false
    let course: Course

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notification Frequency")) {
                    Picker("Notify me every", selection: $selectedFrequency) {
                        Text("1 day").tag(1)
                        Text("2 days").tag(2)
                        Text("3 days").tag(3)
                        Text("1 week").tag(7)
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section(header: Text("Notification Time")) {
                    DatePicker("Notify me at", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                }
            }
            .navigationBarTitle("Notification Settings", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                isPresented = false
            }, trailing: Button("Save") {
                saveNotificationSettings()
            })
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Notification Scheduled"),
                    message: Text("Your notification has been scheduled."),
                    dismissButton: .default(Text("OK")) {
                        isPresented = false
                    }
                )
            }
        }
    }

    private func saveNotificationSettings() {
        UserDefaults.standard.set(selectedFrequency, forKey: "\(course.shortName)_notificationFrequency")
        UserDefaults.standard.set(selectedTime, forKey: "\(course.shortName)_notificationTime")
        notificationsEnabled = true
        scheduleNotifications(for: course, frequency: selectedFrequency, time: selectedTime)
        showAlert = true
    }

    private func scheduleNotifications(for course: Course, frequency: Int, time: Date) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [course.shortName])

        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "Time to review your \(course.shortName) course material!"
        content.sound = .default

        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        var trigger: UNCalendarNotificationTrigger
        if frequency == 7 {
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        } else {
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            for day in stride(from: frequency, through: 365, by: frequency) {
                dateComponents.day = day
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "\(course.shortName)_\(day)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            }
            return
        }

        let request = UNNotificationRequest(identifier: course.shortName, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}
