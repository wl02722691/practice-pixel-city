//
//  MapVC.swift
//  pixel-city
//
//  Created by 張書涵 on 2017/12/11.
//  Copyright © 2017年 AliceChang. All rights reserved.
//
import AlamofireImage
import Alamofire
import UIKit
import MapKit
import CoreLocation
//用Map三步驟：1.import MapKit 2.MapVC:MKMapViewDelegate 3.mapView.delegate = self
class MapVC: UIViewController,UIGestureRecognizerDelegate {

    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus()
    let regionRadius:Double = 1000 //意思是1000公里
    
    var screenSize = UIScreen.main.bounds
   
    var spinner:UIActivityIndicatorView?
    var progressLbl:UILabel?
    
    var flowLayout = UICollectionViewFlowLayout()
    var collectionView:UICollectionView?
    
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configuareLocationServices()
        addDoubleTap()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
    
        registerForPreviewing(with: self, sourceView: collectionView!)
        
        pullUpView.addSubview(collectionView!)
    }
  
    
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2  //按兩下就觸動action
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    
    func addSwipe() {
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp(){
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
          self.view.layoutIfNeeded()
        }
    }
    
    @objc func animateViewDown() {
        cancelAllSessions()
        pullUpViewHeightConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addspinner(){
        spinner = UIActivityIndicatorView()
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2) , y: 150)
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func  removeSpinner(){
        if spinner != nil{
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: screenSize.width/2 - 120/*120是width240的一半才能在中間*/, y: 175/*會在spinner170-150=20px下方,原點在左上方*/, width: 240, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 16)
        progressLbl?.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgressLbl(){
        if progressLbl != nil{
            progressLbl?.removeFromSuperview()
        }
    }
    
    @IBAction func centerBtnWasPressed(_ sender: Any) {
        //按下按鈕就會回到自己的位置
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse{
            centerMapOnUserLocation()
        }
    }
    
}

extension MapVC:MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{ //如果是自己的位置就不用改成橘色的annotation
            return nil
        }else{
            //把annotation顏色改成橘色
        let pinannotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            //Identifier要與dropPin的identifer一樣
        pinannotation.pinTintColor = UIColor.orange
        pinannotation.animatesDrop = true
        return pinannotation
            }
        }
    
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else{return} //自己的位置
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, regionRadius*2, regionRadius*2)
        //打開App時會在自己的位子,範圍1000m*2,範圍1000m*2
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender:UITapGestureRecognizer){
        //寫一個func會放大頭針在地圖上
        removeProgressLbl()
        removeSpinner()
        removePin()
        cancelAllSessions()
        animateViewUp()
        addSwipe()
        addspinner()
        addProgressLbl()
        
        imageUrlArray = []
        imageArray = []
       
        collectionView?.reloadData()
        
        let touchPoint = sender.location(in: mapView)//print(touchPoint) print出來的內容會是UI的數字
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)//把UI的數字轉成GPS 帥
        let annotation = DroppablePin(coordinate: touchCoordinate, identifer: "droppablePin")//DroppablePin是swift檔
        mapView.addAnnotation(annotation)//加入大頭針
        print(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhoto: 40))
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinate, regionRadius*2, regionRadius*2)
        mapView.setRegion(coordinateRegion, animated: true)//按下新的地點放下大頭針之後就會切換到至中的位子
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        self.removeSpinner()
                        self.removeProgressLbl()
                        self.collectionView?.reloadData()
                        // reload collectionView'
                        
                    }
                })
            }
        }
    }
    
    func removePin(){//讓舊的annotation消失
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    
    func retrieveUrls(forAnnotation annotation:DroppablePin,handler:@escaping(_ status:Bool)->()){
        
        Alamofire.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhoto: 40)).responseJSON { (response) in
            guard let json = response.result.value as? Dictionary<String,AnyObject> else {return}
            let photoDict = json["photos"] as! Dictionary<String,AnyObject>
            let photoDictArray = photoDict["photo"] as! [Dictionary<String,AnyObject>]
            for photo in photoDictArray{
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
                self.imageUrlArray.append(postUrl)
            }
            handler(true)
        }
    }
    
    func retrieveImages(handler: @escaping (_ status: Bool) -> ()) {
       
        for url in imageUrlArray {
            Alamofire.request(url).responseImage(completionHandler: { (response) in
                guard let image = response.result.value else { return }
                self.imageArray.append(image)
                self.progressLbl?.text = "\(self.imageArray.count)/40 IMAGES DOWNLOADED"
                
                if self.imageArray.count == self.imageUrlArray.count {
                    handler(true)
                }
            })
        }
    }
    
    func cancelAllSessions(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
    }
}

extension MapVC:CLLocationManagerDelegate{
    func configuareLocationServices(){
        if authorizationStatus == .notDetermined{
            locationManager.requestAlwaysAuthorization()//不管App有沒有打開都能取到位置
        }else{
            return
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //只要移動位置也會改變
        centerMapOnUserLocation()
    }
    
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell() }
        let imageFromIndex = imageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView)
        return cell
    }
    //加
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else{return}
        popVC.initData(forimage: imageArray[indexPath.row])
        present(popVC, animated: true, completion: nil)
    }
}

extension MapVC: UIViewControllerPreviewingDelegate{
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = collectionView?.indexPathForItem(at: location)
            
            ,let cell = collectionView?.cellForItem(at: indexPath) else { return nil }
        
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else{
            return nil
        }
        popVC.initData(forimage: imageArray[indexPath.row])
        previewingContext.sourceRect = cell.contentView.frame
        return popVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}
