//
//  PhotosViewController.swift
//  NewProject
//
//  Created by Jatinder Arora on 20/01/20.
//  Copyright © 2020 osx. All rights reserved.
//

import UIKit
import SDWebImage
class PhotosViewController: UIViewController {
    var dataSource = [[String:Any]]()
    var current_page = 1;
    var refreshControl = UIRefreshControl()
    var next_page: String?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func doBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var onBack: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addPullToRefresh()
                collectionView.dataSource = self
                collectionView.delegate = self
                let cellWidth : CGFloat = collectionView.frame.size.width / 3.1
                let cellheight : CGFloat = cellWidth
                let cellSize = CGSize(width: cellWidth , height:cellheight)
                
                let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .vertical //.horizontal
                layout.itemSize = cellSize
                layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
                layout.minimumLineSpacing = 1.0
                layout.minimumInteritemSpacing = 1.0
                collectionView.setCollectionViewLayout(layout, animated: true)
                collectionView.reloadData()
                getAllPost();
                
            }
            func addPullToRefresh(){
                refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
                refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
                collectionView?.addSubview(refreshControl)
            }
            @objc func refresh() {
               current_page = 1
                dataSource.removeAll()
                getAllPost()
            }
            func getAllPost() {
                var params = [String:String]()
                params = ["limit": "100","page": "\(current_page)","type": "attachment"]
                API.shared.getData(url: API_ENDPOINTS.GET_CHAT_LIST.rawValue, viewController: self, params: params) { (model) in
                    print(model)
                    let data = model["data"] as! [String : Any]
                    self.next_page = data["next_page_url"] as? String
                    let localdataSource = data["data"] as! [[String : Any]]
                    self.dataSource = self.dataSource + localdataSource
                    self.collectionView.reloadData()
                }
            }
            class func instance()->GalleryViewController?{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "GalleryViewController") as? GalleryViewController
                
                return controller
            }
            
            

        }
        extension PhotosViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
            func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath as IndexPath) as! GalleryCell
//                if let image: String = API_URLS.BASE_URL_MEDIA.rawValue + (dataSource[indexPath.row]["attachment"] as? String ?? ""){
//                    print(image)
////                    cell.imgPhoto.pin_setImage(from: URL(string: image)!)
//                    let imageURL = URL(string: image)!
//                                 cell.imgPhoto.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                                 cell.imgPhoto.sd_setImage(with: imageURL)
//                }
        //        var image: String = API_URLS.BASE_URL_MEDIA.rawValue + (dataSource[indexPath.row]["attachment"] as? String ?? "")
               
        //        cell.imgPhoto.imageFromServerURL(urlString: API_URLS.BASE_URL_MEDIA.rawValue +  (dataSource[indexPath.row]["message"] as! String))
        //        var user = users[indexPath.row]["user"] as! [String:Any]
        //        cell.lblName.text = user["name"] as! String
                return cell
            }
            
            //UICollectionViewDelegateFlowLayout methods
            func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
            {
                
                return 2;
            }
            func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
            {
                
                return 1;
            }
            
            
            //UICollectionViewDatasource methods
            func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
                
                return 1
            }
            
            func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                
                return dataSource.count
            }
            func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
                let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewImageVC") as! ViewImageVC
              
                if let  image = dataSource[indexPath.row]["attachment"] as? String{
                    
                    print(image)
                    vc.image = API_URLS.BASE_URL_MEDIA.rawValue + image
                    self.navigationController?.pushViewController(vc, animated: true)
                }
               
            }
            
            
        }
