//
//  ViewController.swift
//  TestNC1
//
//  Created by Fariz Rizky Rizaldy on 24/04/22.
//

import UIKit
import UserNotifications

struct Notification {
    struct Category {
        static let tutorial = "tutorial"
    }
    
    struct Action {
        static let readLater = "readLater"
        static let showDetails = "showDetails"
        static let unsubscribe = "unsubscribe"
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var TimerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var timer: Timer = Timer()
    var count: Int = 1200
    var timerCounting: Bool = false
    var isTimeWorking: Bool = false
    let notificationCenter = UNUserNotificationCenter.current()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        startStopButton.setTitleColor(UIColor.white, for: .normal)
        configureUserNotificationsCenter()
    }
    
    private func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
            // Request Authorization
            notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
                if let error = error {
                    print("Request Authorization Failed (\(error), \(error.localizedDescription))")
                }
                completionHandler(success)
            }
    }
    
     func scheduleNotification() {
        let content = UNMutableNotificationContent()
                content.title = "Take a rest"
                content.body = "It's time for your eyes to look 20 feet"
//                content.sound = UNNotificationSound.default
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "26339.mp3"))
                content.badge = 1
//        content.categoryIdentifier = Notification.Category.
        content.categoryIdentifier = Notification.Category.tutorial
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "Local"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                notificationCenter.add(request) { (error) in
                    if let error = error {
                        print("Error \(error.localizedDescription)")
                    }
                }
    }
    
    private func configureUserNotificationsCenter() {
            notificationCenter.delegate = self
        let actionReadLater = UNNotificationAction(identifier: Notification.Action.readLater, title: "Read Later", options: [])
        let actionShowDetails = UNNotificationAction(identifier: Notification.Action.showDetails, title: "Show Details", options: [.foreground])
        let actionUnsubscribe = UNNotificationAction(identifier: Notification.Action.unsubscribe, title: "Unsubscribe", options: [.destructive, .authenticationRequired])
        
        // Define Category
        let tutorialCategory = UNNotificationCategory(identifier: Notification.Category.tutorial, actions: [actionReadLater, actionShowDetails, actionUnsubscribe], intentIdentifiers: [], options: [])
        
        // Register Category
        notificationCenter.setNotificationCategories([tutorialCategory])
    }

    @IBAction func resetTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Reset Timer", message: "Are you sure want reset it?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
//            do nothing
        }))
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.count = 1200
            self.timer.invalidate()
            self.TimerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
            self.startStopButton.setTitle("Start", for: .normal)
            self.startStopButton.setTitleColor(UIColor.white, for: .normal)
            self.titleLabel.text = "Ready to work?"
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func startStopTapped(_ sender: Any) {
        if (timerCounting) {
            timerCounting = false
            timer.invalidate()
            startStopButton.setTitle("Start", for: .normal)
            startStopButton.backgroundColor = UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1.00)
            isTimeWorking = true
            
        } else {
            timerCounting = true
            startStopButton.setTitle("Stop", for: .normal)
            startStopButton.backgroundColor = UIColor.red
            timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
            titleLabel.text = "Happy Working!"
            isTimeWorking = false
        }
//        countMinutes()
    }
    
     func triggerNotif() {
        notificationCenter.getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    self.scheduleNotification()
                })
            case .authorized:
                self.scheduleNotification()
            case .denied:
                print("The application not allowed to display notifications")
            case .provisional:
                print("The application authorized to post non-interruptive user notifications")
            case .ephemeral:
                print("The application is temporarily authorized to post notifications. Only available to app clips.")
            @unknown default:
                print("Application Not Allowed to Display Notifications")
            }
        }
    }
    
    @IBAction func triggerNotification(sender: Any) {
        notificationCenter.getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization(completionHandler: { (success) in
                    guard success else { return }
                    self.scheduleNotification()
                })
            case .authorized:
                self.scheduleNotification()
            case .denied:
                print("The application not allowed to display notifications")
            case .provisional:
                print("The application authorized to post non-interruptive user notifications")
            case .ephemeral:
                print("The application is temporarily authorized to post notifications. Only available to app clips.")
            @unknown default:
                print("Application Not Allowed to Display Notifications")
            }
        }
    }

    @IBAction func triggerScheduledNotification(sender: Any) {

    }
    
    @objc func timerCounter() -> Void
    {
        count = count - 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        TimerLabel.text = timeString
        if count < 1 && !isTimeWorking {
            count = 20
            count = count - 1
            isTimeWorking = true
            titleLabel.text = "Rest your eyes!"
            triggerNotif()
        } else if (count <= 0 && isTimeWorking) {
            count = 1200
            count = count - 1
            isTimeWorking = false
            titleLabel.text = "Happy Working!"
        }
//        let time = secondsToHoursMinutesSeconds(seconds: count)
//        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
//        TimerLabel.text = timeString
    }
    
    
    
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int)
    {
     return ((seconds / 3600), ((seconds % 3600) / 60), ((seconds % 3600) % 60))
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds:Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
//        minutesDec = timeString
        return timeString
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            switch response.actionIdentifier {
            case Notification.Action.readLater:
                print("Save Tutorial For Later")
            case Notification.Action.unsubscribe:
                print("Unsubscribe Reader")
            default:
                print("Show Details")
            }
            
            completionHandler()
        }
    
}

extension ViewController: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }

}

