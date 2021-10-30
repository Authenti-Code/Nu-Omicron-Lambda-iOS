//
//  MainCollectionCell.swift
//  NewProject
//
//  Created by Jatinder Arora on 31/01/20.
//  Copyright © 2020 osx. All rights reserved.
//

import UIKit
import PINRemoteImage
import WebKit
import SDWebImage
class MainCollectionCell: UICollectionViewCell ,WKNavigationDelegate{
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var onPhone: UIButton!
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var dedscTitle: UILabel!
    
//    @IBOutlet weak var detailDescription: UILabel!
    @IBOutlet weak var collectionVIewA: UICollectionView!
   
    var globalIndexPath: IndexPath = IndexPath.init(row: 0, section: 0)
    var imgArray = [String]()
//   var imageArray = [#imageLiteral(resourceName: "image"), #imageLiteral(resourceName: "photo_5d0aa67e771ac"), #imageLiteral(resourceName: "footer_ads")]
  
    @IBAction func onNext(_ sender: Any) {
        if imgArray.count > 1{
            if globalIndexPath.row <= imgArray.count-2{
                let indexPath1: IndexPath?
                indexPath1 = IndexPath.init(row: (globalIndexPath.row) + 1, section: (globalIndexPath.section))

                collectionVIewA.scrollToItem(at: indexPath1!, at: .right, animated: true)
                globalIndexPath = indexPath1!
            }
        }
        
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            if components?.scheme == "http" || components?.scheme == "https"
            {
                UIApplication.shared.open(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    @IBAction func onPrev(_ sender: Any) {
        if globalIndexPath.row > 0{
            let indexPath1: IndexPath?
            indexPath1 = IndexPath.init(row:  (globalIndexPath.row) - 1, section: (globalIndexPath.section))
            collectionVIewA.scrollToItem(at: indexPath1!, at: .left, animated: true)
            globalIndexPath = indexPath1!
        }
    }
    override func awakeFromNib() {
           super.awakeFromNib()
           collectionVIewA.delegate = self
           collectionVIewA.dataSource = self
        webView.navigationDelegate = self
        let cellWidth : CGFloat = UIScreen.main.bounds.width
        let cellheight : CGFloat = collectionVIewA.bounds.height
        let cellSize = CGSize(width: cellWidth , height:280)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionVIewA.setCollectionViewLayout(layout, animated: true)
        startTimer()
   }
}


extension MainCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    print(imgArray.count)
   return imgArray.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
    
//    cell.images.pin_setImage(from: URL(string: (API_URLS.BASE_URL_VIP_PARTNER.rawValue + imgArray[indexPath.row]))!)
    cell.images.sd_imageIndicator = SDWebImageActivityIndicator.gray
    cell.images.sd_setImage(with: URL(string: (API_URLS.BASE_URL_VIP_PARTNER.rawValue + imgArray[indexPath.row]))!, completed: nil)
//    cell.images.contentMode = .scaleAspectFill
    
//    var imageView :UIImageView
//    imageView = UIImageView(frame: CGRect(x: 0, y: 58, width: collectionVIewA.bounds.width, height: 240));
//
//
//
//    imageView.sd_setImage(with: URL(string: (API_URLS.BASE_URL_VIP_PARTNER.rawValue + imgArray[indexPath.row]))!, completed: nil)
////    imageView.backgroundColor = UIColor.redColor()
//    imageView.contentMode = .scaleToFill
//    cell.addSubview(imageView)
    // assign the index of the youtuber to button tag
//    cell.btnNext.tag = indexPath.row
//    cell.btnPrev.tag = indexPath.row
//    // call the subscribeTapped method when tapped
//    cell.btnNext.addTarget(self, action: #selector(nextTap(_:)), for: .touchUpInside)
//    cell.btnNext.addTarget(self, action: #selector(prevTap(_:)), for: .touchUpInside)
        
    return cell
}
    func startTimer() {

        let timer =  Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
        
    }
    @objc func scrollAutomatically(_ timer1: Timer) {

        if let coll  = collectionVIewA {
            for cell in coll.visibleCells {
                let indexPath: IndexPath? = coll.indexPath(for: cell)
                if ((indexPath?.row)! < imgArray.count - 1){
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)

                    coll.scrollToItem(at: indexPath1!, at: .right, animated: true)
                    globalIndexPath = indexPath1!
                }
                else{
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
                    coll.scrollToItem(at: indexPath1!, at: .left, animated: true)
                    globalIndexPath = indexPath1!
                }

            }
        }
    }
    @objc func nextTap(_ sender: UIButton){
      // use the tag of button as index
//      let youtuber = youtubers[sender.tag]
        collectionVIewA.reloadData()
    
    }
    @objc func prevTap(_ sender: UIButton){
         // use the tag of button as index
//         let youtuber = youtubers[sender.tag]
//        collectionVIewA.scrollToItem(at: <#T##IndexPath#>, at: UICollectionView.ScrollPosition.left, animated: true)
         collectionVIewA.reloadData()
       
       }
}

