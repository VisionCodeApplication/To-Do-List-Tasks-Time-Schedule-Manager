
import UIKit
import IQKeyboardManager
import SVProgressHUD
import GoogleMobileAds
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.Messgae_ID"
    var keyPurchased: String = "keyPurchased"
    var window: UIWindow?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var navigationController: UINavigationController? // Navigation controller
    static var sharedInstance: AppDelegate {
        return UIApplication.shared.delegate! as! AppDelegate
    }

    var isPurchased: Bool = false

    var interstitial: GADInterstitial!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        FirebaseApp.configure()

        let ispurchased = fetchUserDefault(Key: keyPurchased)
        isPurchased = ispurchased
        if !isPurchased {
            GADMobileAds.sharedInstance().start(completionHandler: nil)
            UserDefaults.standard.set(0, forKey: "fullAd")
            UserDefaults.standard.synchronize()
        }
        Initialization()
        IQKeyboardManager.shared().isEnabled = true
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) {
            didAllow, _ in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
        let initialViewController: UIViewController = storyboard.instantiateViewController(withIdentifier: "SplashVC") as! UIViewController
        navigationController = UINavigationController(rootViewController: initialViewController)

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

    func checkFullAd() {
        let ispurchased = fetchUserDefault(Key: keyPurchased)
        isPurchased = ispurchased
        if !isPurchased {
            if let isFullAd: Int? = UserDefaults.standard.integer(forKey: "fullAd") {
                if isFullAd == 2 {
                    UserDefaults.standard.set(0, forKey: "fullAd")
                    UserDefaults.standard.synchronize()
                }
                else{
                    UserDefaults.standard.set(isFullAd!+1, forKey: "fullAd")
                    UserDefaults.standard.synchronize()
                }
            }
            else{
                UserDefaults.standard.set(1, forKey: "fullAd")
                UserDefaults.standard.synchronize()
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
           // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
           // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
       }

       func applicationDidEnterBackground(_ application: UIApplication) {
           // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
           // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
       }

       func applicationWillEnterForeground(_ application: UIApplication) {
           // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
       }

       func applicationDidBecomeActive(_ application: UIApplication) {
           // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
       }

       func applicationWillTerminate(_ application: UIApplication) {
           // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
       }
       
   func Initialization() {
       DBManager.sharedInstance.createDB()
       DBManager.sharedInstance.createTable()
    
        copyHTMLFileToDocDir(fileExtension: ".html")
   }
    
    func copyHTMLFileToDocDir(fileExtension: String) {
        if let resPath = DBundlePathToTaskTableHTMLTemplate {
            do {
                let dirContents = try FileManager.default.contentsOfDirectory(atPath: resPath)
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let filteredFiles = dirContents.filter{ $0.contains(fileExtension)}
                for fileName in filteredFiles {
                    if let documentsURL = documentsURL {
                        let sourceURL = Bundle.main.bundleURL.appendingPathComponent(fileName)
                        let destURL = documentsURL.appendingPathComponent(fileName)
                        do { try FileManager.default.copyItem(at: sourceURL, to: destURL) } catch { }
                    }
                }
            } catch { }
        }
        
        if let resPath = DBundlePathToTaskTablePDFHTMLTemplate {
            do {
                let dirContents = try FileManager.default.contentsOfDirectory(atPath: resPath)
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let filteredFiles = dirContents.filter{ $0.contains(fileExtension)}
                for fileName in filteredFiles {
                    if let documentsURL = documentsURL {
                        let sourceURL = Bundle.main.bundleURL.appendingPathComponent(fileName)
                        let destURL = documentsURL.appendingPathComponent(fileName)
                        do { try FileManager.default.copyItem(at: sourceURL, to: destURL) } catch { }
                    }
                }
            } catch { }
        }
    }
    
    func getDocDir() -> String {
           return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
       }

    func saveUserDefault(value: Any, Key: String) {
        UserDefaults.standard.set(value, forKey: Key)
        isPurchased = value as! Bool
    }

    func fetchUserDefault(Key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: Key) ?? false
    }
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                       -> Void) {
      if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
      }

      // Print full message.
      print(userInfo)

      completionHandler(UIBackgroundFetchResult.newData)
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
  // Receive displayed notifications for iOS 10 devices.
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
    let userInfo = notification.request.content.userInfo

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // ...

   
    if let messageID = userInfo[gcmMessageIDKey] {
        print("Message ID: \(messageID)")
    }
    // Print full message.
    print(userInfo)

    // Change this to your preferred presentation option
    completionHandler([.alert, .sound, .badge])
  }

  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
    let userInfo = response.notification.request.content.userInfo

    // ...

    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)

    // Print full message.
    print(userInfo)

    completionHandler()
  }
}

extension AppDelegate: MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
      // TODO: If necessary send token to application server.
      // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Massege :", remoteMessage.appData)
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
        }
            
    }
}
