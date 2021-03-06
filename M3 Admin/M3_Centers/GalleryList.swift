//
//  GalleryList.swift
//  M3 Admin
//
//  Created by Happy Sanz Tech on 05/02/19.
//  Copyright © 2019 Happy Sanz Tech. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class GalleryList: UIViewController,UITableViewDelegate,UITableViewDataSource
{
    
    var centerPhoto = [String]()
    var galleryId = [String]()
    var fromScheme = String()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Gallery"
        
        if fromScheme == "YES"
        {
            navigationLeftButton ()
            self.tableView.reloadData()
        }
        else
        {
            if GlobalVariables.user_type_name == "TNSRLM"
            {
               // navigationRightButton ()
                navigationLeftButton ()
                webRequestTnsrlm ()
            }
            else
            {
                navigationRightButton ()
                navigationLeftButton ()
                webRequest ()
            }
        }

    }
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
      return centerPhoto.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier:"cell", for: indexPath)as! GalleryTableviewCell
        let imgUrl = centerPhoto[indexPath.row]
        cell.imgView.sd_setImage(with: URL(string: imgUrl), placeholderImage: UIImage(named: "placeholder.png"))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 263
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
          if (editingStyle == .delete) {
              // handle delete (by removing the data from your array and updating the tableview)
              let gallery_id = galleryId[indexPath.row]
              print(gallery_id)
              self.webRequestRemoveFromList(GalleryID: gallery_id)
          }
    }
      
      func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
      {
          return "Delete"
      }
    
    func webRequestRemoveFromList(GalleryID:String)
    {
        let functionName = "apipia/center_gallery_delete"
        let baseUrl = Baseurl.baseUrl + functionName
        let url = URL(string: baseUrl)!
        let parameters: Parameters = ["gallery_id":GalleryID]
        Alamofire.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                response in
                switch response.result
                {
                case .success:
                    print(response)
                    let JSON = response.result.value as? [String: Any]
                    let msg = JSON?["msg"] as? String
                    let status = JSON?["status"] as? String
                    if (status == "success")
                    {
                        self.webRequest()
                    }
                    else
                    {
                        let alertController = UIAlertController(title: "M3", message: msg, preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                            print("You've pressed default");
                        }
                        alertController.addAction(action1)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    break
                case .failure(let error):
                     print(error)
                }
        }
    }
    
    func navigationRightButton ()
    {
        let navigationRightButton = UIButton(type: .custom)
        navigationRightButton.setImage(UIImage(named: "add"), for: .normal)
        navigationRightButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        navigationRightButton.addTarget(self, action: #selector(clickButton), for: .touchUpInside)
        let navigationButton = UIBarButtonItem(customView: navigationRightButton)
        self.navigationItem.setRightBarButtonItems([navigationButton], animated: true)
    }
    
    func navigationLeftButton ()
    {
        let navigationLeftButton = UIButton(type: .custom)
        navigationLeftButton.setImage(UIImage(named: "back-01"), for: .normal)
        navigationLeftButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        navigationLeftButton.addTarget(self, action: #selector(backButtonclick), for: .touchUpInside)
        let navigationButton = UIBarButtonItem(customView: navigationLeftButton)
        self.navigationItem.setLeftBarButton(navigationButton, animated: true)
    }
        
    @objc func clickButton()
    {
        self.performSegue(withIdentifier: "addImage", sender: self)
    }
    
    @objc func backButtonclick()
    {
        if fromScheme == "YES"
        {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            if GlobalVariables.user_type_name == "TNSRLM"
            {
                self.performSegue(withIdentifier: "tnsrlm_Center", sender: self)
            }
            else
            {
                self.performSegue(withIdentifier: "to_centerDetail", sender: self)
            }
        }
    }
    
    func webRequest ()
    {
        let functionName = "apipia/center_gallery"
        let baseUrl = Baseurl.baseUrl + functionName
        let url = URL(string: baseUrl)!
        let parameters: Parameters = ["user_id": GlobalVariables.user_id!, "center_id": GlobalVariables.center_id!]
        Alamofire.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                response in
                switch response.result
                {
                case .success:
                    print(response)
                    let JSON = response.result.value as? [String: Any]
                    let msg = JSON?["msg"] as? String
                    let status = JSON?["status"] as? String
                    if (status == "success")
                    {
                        let centerGallery = JSON?["centerGallery"] as? [Any]
                        for i in 0..<(centerGallery?.count ?? 0)
                        {
                            let dict = centerGallery?[i] as? [AnyHashable : Any]
                            let center_photo = dict?["center_photo"] as? String
                            let gallery_id = dict?["gallery_id"] as? String
                            
                            self.centerPhoto.append(center_photo ?? "")
                            self.galleryId.append(gallery_id ?? "")
                        }
                        
                            self.tableView.reloadData()
                    }
                    else
                    {
                        self.tableView.reloadData()
                        let alertController = UIAlertController(title: "M3", message: msg, preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                            print("You've pressed default");
                        }
                        alertController.addAction(action1)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    break
                case .failure(let error):
                     print(error)
                }
        }
    }
    
    func webRequestTnsrlm ()
    {
        let functionName = "apipia/center_gallery"
        let baseUrl = Baseurl.baseUrl + functionName
        let url = URL(string: baseUrl)!
        let parameters: Parameters = ["user_id": GlobalVariables.pia_id!, "center_id": GlobalVariables.center_id!]
        Alamofire.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: nil).responseJSON
            {
                response in
                switch response.result
                {
                case .success:
                    print(response)
                    let JSON = response.result.value as? [String: Any]
                    let msg = JSON?["msg"] as? String
                    let status = JSON?["status"] as? String
                    if (status == "success")
                    {
                        let centerGallery = JSON?["centerGallery"] as? [Any]
                        for i in 0..<(centerGallery?.count ?? 0)
                        {
                            let dict = centerGallery?[i] as? [AnyHashable : Any]
                            let center_photo = dict?["center_photo"] as? String
                            let gallery_id = dict?["gallery_id"] as? String
                            
                            self.centerPhoto.append(center_photo ?? "")
                            self.galleryId.append(gallery_id ?? "")
                        }
                        
                            self.tableView.reloadData()
                    }
                    else
                    {
                        let alertController = UIAlertController(title: "M3", message: msg, preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                            print("You've pressed default");
                        }
                        alertController.addAction(action1)
                        self.present(alertController, animated: true, completion: nil)
                    }
                    break
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    /*
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
