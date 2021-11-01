
import UIKit
import FSCalendar
import GoogleMobileAds
import Lottie
import Firebase
import UnityAds

class DateCalendarVC: UIViewController ,GADBannerViewDelegate, UnityAdsDelegate {
    var DBvalue = Int()
    var DBvalueforads = Int()
    @IBOutlet var Notaskanimationview: UIView!
    @IBOutlet var viewHeader: UIView!
    @IBOutlet weak var viewInsideScroll : UIView!

    @IBOutlet var smallview2: UIView!
    @IBOutlet var smallview1: UIView!
    @IBOutlet var CalendarView: UIView!

    @IBOutlet weak var scrollViewMain  : UIScrollView!
  
    @IBOutlet var Notaskview: AnimationView!
    
    @IBOutlet var lblTitle: UILabel!

    @IBOutlet weak var btnCalendar: UIButton!

    @IBOutlet var tableView: UITableView!

    @IBOutlet weak var constraintTableViewHeight : NSLayoutConstraint!

    @IBOutlet var calendar: FSCalendar!
    
    var arrAllAddedTasksInDB = [TaskModel]()

    var objcHistoryTaskListModel = DailyTaskListModel()
    
    var pen : Float = 0.0
    var pro: Float = 0.0
    var done: Float = 0.0
    
    var Tasks = [TaskModel]()
    
    var strSelectedDateCalendar : String = Date().toString(dateFormat: DDBSmallDateFormat)

    @IBOutlet weak var vwCalendarHeightConstraint : NSLayoutConstraint!

  
    var bannerView: GADBannerView!
    @IBOutlet var vwGoogleAd: UIView!
    private var interstitial: GADInterstitial!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UnityAds.setDebugMode(true)
        UnityAds.initialize("4278828",delegate: self)
        
        btnCalendar.tag = 0
        CalendarView.frame.size = CGSize(width: 320, height: 0)
        lblTitle.text = Date().toString(dateFormat: DTaskdateFormatFull)
        tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadProgress), name: NSNotification.Name(rawValue: "ProgressViewReload"), object: nil)
        Notaskview = .init(name: "animation")
        Notaskview!.loopMode = .loop
        Notaskview!.animationSpeed = 0.5
        Notaskview.frame = CGRect(x: 5, y: 0, width: 360, height: 200)
        Notaskanimationview.addSubview(Notaskview!)
        LaunchInterstitialAd()
    }
    override func viewWillAppear(_ animated: Bool) {

        calendar.scope = .month
        reload()
        btnCalendar.tag = 0
        let database = Database.database().reference()
        
        database.child("hidedata").observe(.value) { snapshot in
            print(snapshot.value!)
            self.DBvalue = snapshot.value as! Int
            if AppDelegate.sharedInstance.isPurchased {
                self.vwGoogleAd.isHidden = true
            } else {
                if self.DBvalue == 1 {
                    self.vwGoogleAd.isHidden = false
                }else{
                    self.vwGoogleAd.isHidden = true
                }
            }
        }
        database.child("ads").observe(.value) { snapshot in
            print(snapshot.value!)
            self.DBvalueforads = snapshot.value as! Int
            if(self.DBvalue == 1){
                self.gad()
            }
        }
        Notaskview!.play()
    }
    func unityAdsReady(_ placementId: String) {
        print("Unity ads is ready")
    }
    
    func unityAdsDidError(_ error: UnityAdsError, withMessage message: String) {
        print(error)
    }
    
    func unityAdsDidStart(_ placementId: String) {
        print(placementId)
    }
    
    func unityAdsDidFinish(_ placementId: String, with state: UnityAdsFinishState) {
        print("Unity ads is finish")
        if (state != .skipped) {
            print("Wathch full ad")
        }
    }
    private func LaunchInterstitialAd() {
         interstitial = GADInterstitial(adUnitID: fullAdID)
         let request = GADRequest()
         interstitial.load(request)
     }

     private func showInterstitialAd() {
         interstitial.present(fromRootViewController: self)
         print("show ad")
             LaunchInterstitialAd()
     }
    
    func reload() {

        self.tableView.delegate = self.objcHistoryTaskListModel
        self.tableView.dataSource = self.objcHistoryTaskListModel

        arrAllAddedTasksInDB = DBManager.sharedInstance.selectAllTasksFromTable()
        
        let allTaskWithProgress  = DBManager.sharedInstance.selectTaskListOfSelectedDate(sortBy: 0, strDate:strSelectedDateCalendar)

        Tasks = allTaskWithProgress.0

        pen = Float(allTaskWithProgress.1)
        done = Float(allTaskWithProgress.2)
        pro = Float(allTaskWithProgress.3)

        self.objcHistoryTaskListModel.reloadList(arrList: Tasks, tableView: self.tableView, footerHeight: 0.0)

        calendar.reloadData()

        countcheck()
    }

    func countcheck() {
        if Tasks.count == 0 {
            Notaskview.isHidden = true
            Notaskanimationview.isHidden = false
        }
        else {
            Notaskanimationview.isHidden = true
            Notaskview.isHidden = true
        }
    }
    @objc func reloadProgress()
    {
        reload()
    }
    func gad() {
        if DBvalueforads == 1 {
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            bannerView.adUnitID = bannerAdID
            bannerView.rootViewController = self
            bannerView.delegate = self
            vwGoogleAd.addSubview(bannerView)
            bannerView.load(GADRequest())
        }
        else if DBvalueforads == 2{
            UnityAds.show(self, placementId: "Banner_iOS")
        }
    }
    func AddTask(type : TaskTypeEnum)
    {
        let vc = UIStoryboard(name: "AddTaskVC", bundle: nil).instantiateViewController(withIdentifier: "AddTaskVC") as? AddTaskVC

        vc?.currentTaskType = type

        AppDelegate.sharedInstance.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func AddbtnClick(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Choose Style", message: "Please Choose any one.", preferredStyle: .alert)
        let Mettingbtn = UIAlertAction(title: "Meeting", style: .default) { UIAlertAction in
            self.AddTask(type: .Meeting)
            if(self.DBvalue == 1){
                if self.DBvalueforads == 1 {
                    self.showInterstitialAd()
                }
                else if(self.DBvalueforads == 2){
                    UnityAds.show(self, placementId: "Interstitial_iOS")
                }
            }
        }
        let Reminderbtn = UIAlertAction(title: "Reminder", style: .default) { UIAlertAction in
            self.AddTask(type: .Reminder)
            if(self.DBvalue == 1){
                if self.DBvalueforads == 1 {
                    self.showInterstitialAd()
                }
                else if(self.DBvalueforads == 2){
                    UnityAds.show(self, placementId: "Interstitial_iOS")
                }
            }
        }
        let Taskbtn = UIAlertAction(title: "Task", style: .default) { UIAlertAction in
            self.AddTask(type: .Task)
            if(self.DBvalue == 1){
                if self.DBvalueforads == 1 {
                    self.showInterstitialAd()
                }
                else if(self.DBvalueforads == 2){
                    UnityAds.show(self, placementId: "Interstitial_iOS")
                }
            }
        }
        let Canclebtn = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        alert.addAction(Mettingbtn)
        alert.addAction(Reminderbtn)
        alert.addAction(Taskbtn)
        alert.addAction(Canclebtn)
        present(alert, animated: true, completion: nil)
    }
    @IBAction func goCalendar(_ sender: UIButton) {
        if btnCalendar.tag == 0 {
            btnCalendar.tag = 1
            vwCalendarHeightConstraint.constant = 0.0
            CalendarView.frame.size.height = 0
            smallview1.isHidden = true
            smallview2.isHidden = true
            calendar.layoutIfNeeded()
        }
        else{
            btnCalendar.tag = 0
            vwCalendarHeightConstraint.constant = 273.0
            CalendarView.frame.size.height = 273
            smallview1.isHidden = false
            smallview2.isHidden = false
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

        if let obj = object as? UITableView {
            if obj == self.tableView && keyPath == "contentSize" {
                self.tableView.layoutIfNeeded()
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension DateCalendarVC: FSCalendarDataSource, FSCalendarDelegate
{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition)
    {
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
        strSelectedDateCalendar = date.toString(dateFormat: DDBSmallDateFormat)
        lblTitle.text = date.toString(dateFormat: DTaskdateFormatFull)
        reload()
    }
    func calendar(_: FSCalendar, numberOfEventsFor date: Date) -> Int
    {
        let items = arrAllAddedTasksInDB.filter { $0.Task_Date.isEqual(to: date.toString(dateFormat: DDBSmallDateFormat))
        }
        print(date.toString(dateFormat: DTaskdateFormat), items.count )
        return items.count
    }
}

