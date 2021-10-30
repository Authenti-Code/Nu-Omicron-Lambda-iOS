//
//  ConnectSocialViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 09/09/19.
//  Copyright © 2019 osx. All rights reserved.
//

import UIKit

class ConnectSocialViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var lblArr = ["CONNECT WITH FACEBOOK","CONNECT WITH GOOGLE","CONNECT WITH TWITTER"]
    var imgArr = ["facebook","google","twitter"]
    
    private let sectionInsets = UIEdgeInsets(top: 15.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView?.separatorStyle = .none
        // Do any additional setup after loading the view.
    }
    

    @IBAction func onBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }


}
extension ConnectSocialViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lblArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ConnectSocialCell else{
            return UITableViewCell()
        }
        cell.lblText?.text = lblArr[indexPath.row]
        cell.imgSocial?.image = UIImage(named: imgArr[indexPath.row])
       
        
        
        cell.containerView.layer.shadowColor = UIColor.black.cgColor
        cell.containerView.layer.shadowOpacity = 0.3
        cell.containerView.layer.shadowOffset = .zero
        cell.containerView.layer.shadowRadius = 1
//        cell.containerView.layer.shadowPath = UIBezierPath(rect: cell.containerView.bounds).cgPath
    //                cell.containerView.layer.shouldRasterize = true
    //                cell.containerView.layer.rasterizationScale = UIScreen.main.scale
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90;//Choose your custom row height
    }
    
}

