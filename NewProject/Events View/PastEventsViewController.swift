//
//  PastEventsViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 11/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit
import SVProgressHUD
import EventKit

class PastEventsViewController: UIViewController,APIsDelegate {
    
    @IBOutlet weak var tbl_View: UITableView?
    @IBOutlet weak var tableView: UIView!
    var data = [[String: Any]]();
    var current_page = 1
    var refreshControl = UIRefreshControl()
    var search = ""
    var next_page:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tbl_View?.delegate = self
        tbl_View?.dataSource = self
        self.tbl_View?.separatorStyle = UITableViewCell.SeparatorStyle.none
        //        theme()
        if Reachability.isConnectedToNetwork(){
            
        }else{
            showAlert(text: "No Internet Connection")
            return
        }
        getData()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if next_page != nil{
                current_page = current_page + 1
                getData()
            }
        }
    }
    func addPullToRefresh(){
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tbl_View?.addSubview(refreshControl)
    }
    @objc func refresh() {
        search = ""
        current_page = 1
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tbl_View?.indexPathForSelectedRow{
            self.tbl_View?.deselectRow(at: index, animated: true)
        }
    }
    func getData(){
        // api.delegate = self
        // api.delegate = self
        var params = [String:String]()
        params = ["order_by": "past","search": search , "limit": "20","page": "\(current_page)"]
        //        params = ["order_by": "upcoming"]
        SVProgressHUD.show()
        API.shared.deligate = self
        API.shared.getData(url: API_ENDPOINTS.GET_EVENTS.rawValue.appending("?order_by=past"), viewController: self, params: params) { (response) in
            print(response)
            if self.refreshControl.isRefreshing  {
                self.refreshControl.endRefreshing()
                self.data.removeAll()
                self.tbl_View?.reloadData()
            }
            
            let data1 = response["data"] as! [String : Any]
            self.data =   self.data + (data1["data"] as! [[String : Any]])
            self.next_page = data1["next_page_url"] as? String
            self.tbl_View?.reloadData()
            
        }
    }
    @objc func detailsClicked(sender:UIButton) {
        // download
        savePdf(urlString: "https://ikl.apa1906.app/public/event-pdf/" + "\(data[sender.tag]["id"] as! Int)", fileName: data[sender.tag]["name"] as! String)
    }
    
    @objc func calanderBtnClicked(sender:UIButton) {
        let sender = sender.tag
        let indexPath = IndexPath(row: sender, section: 0)
        print(indexPath.row)
        let title  = data[indexPath.row]["name"] as! String
//        let description  = data[indexPath.row]["description"] as! String
        let startDate  = data[indexPath.row]["start_date_time"] as! String
        let endDate  = data[indexPath.row]["end_date_time"] as! String
        let start = Utility.convertToDate(str: startDate)
        let end = Utility.convertToDate(str: endDate)
        
        let eventStore : EKEventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted) && (error == nil) {
                print("granted \(granted)")
                print("error \(String(describing: error))")
                
                let event:EKEvent = EKEvent(eventStore: eventStore)
                let date = Date()
                print(date)
                event.title = title
                event.startDate = start
                event.endDate = end
//                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let error as NSError {
                    print("failed to save event with error : \(error)")
                }
                print("Saved Event")
            } else {
                print("failed to save event with error : \(String(describing: error)) or access not granted")
            }
        }
        let alert = UIAlertController(title: "Alert", message: "Event added to calender successully", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func savePdf(urlString:String, fileName:String) {
        DispatchQueue.main.async {
            let url = URL(string: urlString)
            let pdfData = try? Data.init(contentsOf: url!)
            let resourceDocPath = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
            let pdfNameFromUrl = "\(fileName).pdf"
            let actualPath = resourceDocPath.appendingPathComponent(pdfNameFromUrl)
            do {
                try pdfData?.write(to: actualPath, options: .atomic)
                print("pdf successfully saved!")
                self.showAlert(text: "Event saved.")
            } catch {
                print("Pdf could not be saved")
            }
        }
    }
    @objc func shareClicked(sender:UIButton) {
        
        if let myWebsite = NSURL(string: "https://ikl.apa1906.app/public/event-pdf/" + "\(data[sender.tag]["id"] as! Int)") {
            let objectsToShare = ["Event", myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            //New Excluded Activities Code
            activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
            //
            
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
        }
        
    }
    func callBackFromAPI()  {
        SVProgressHUD.dismiss()
    }
    class func instance()->PastEventsViewController?{
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PastEventsViewController") as? PastEventsViewController
        
        return controller
    }
}
extension PastEventsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data.count == 0 {
            tableView.setEmptyMessage( "No Record Found")
        }else{
            tableView.restore()
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingEventsTableCell", for: indexPath) as? UpcomingEventsTableCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.dateLbl?.text = Utility.formatDate(date: ((data[indexPath.row]["date"] as! String)))
        let from = data[indexPath.row]["from_time"] as! String
        let to = data[indexPath.row]["to_time"] as! String
        let time : String =   Utility.formatTime(str: from)  +  " - " +  Utility.formatTime(str: to)
        cell.lblTime?.text = time
        cell.lblTitle?.text = data[indexPath.row]["name"] as? String
        cell.lblGoing?.text = ("\(data[indexPath.row]["attendees_cnt"] as! Int)" ) + " Person going"
        cell.btnDownload.addTarget(self, action: #selector(detailsClicked(sender:)), for: UIControl.Event.touchDown)
        cell.btnShare.addTarget(self, action: #selector(shareClicked(sender:)), for: UIControl.Event.touchDown)
        cell.calanderBtn.tag = indexPath.row
        cell.calanderBtn.addTarget(self, action: #selector(calanderBtnClicked(sender:)), for: UIControl.Event.touchDown)
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Do here
        
        let sb = UIStoryboard.init(name: "Main", bundle: nil)
        let vc =  sb.instantiateViewController(withIdentifier: "EventsDetailsViewController") as! EventsDetailsViewController
        vc.isPast = true
        vc.id = data[indexPath.row]["id"] as! Int
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
}

