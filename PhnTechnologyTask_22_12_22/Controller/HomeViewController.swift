//
//  HomeViewController.swift
//  PhnTechnologyTask_22_12_22
//
//  Created by Apple on 23/12/22.
//

import UIKit
import MapKit
import CoreLocation
import SDWebImage
class HomeViewController: UIViewController {
//Mark:- Create Connection of outlets And taking empty instance of model class objects..
    var resultFromProductModelClass = [ApiResponse]()
    var posts = [Post]()
    var apiResult = [Product]()
    let locationManager = CLLocationManager()
    
    @IBOutlet var mapViewForDisplayCurrentLocation: MKMapView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionViewForDisplayImagesFromApi: UICollectionView!
    @IBOutlet var collectionViewForDisplayDataFromApi: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//Mark:- Calling functions
        InitializeDataSourceAndDelegate()
        RegisterNIB()
        getJsonDataFormApiForImageCollectionView()
        
        getJsonDataFormApiForDataCollectionView {
            self.collectionViewForDisplayDataFromApi.reloadData()
        }
        
        FetchJsonDataForTableView{
            self.tableView.reloadData()
        }
    }
    
//Mark:-Define ViewDidAppear Method for Display Googlemaps
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
//Mark:- Create Instance Datasource And Delegate
    func InitializeDataSourceAndDelegate(){
        collectionViewForDisplayImagesFromApi.dataSource = self
        collectionViewForDisplayImagesFromApi.delegate = self
        
        collectionViewForDisplayDataFromApi.dataSource = self
        collectionViewForDisplayDataFromApi.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
//Mark:- Register Xib Cells
    func RegisterNIB(){
        
        var uinib = UINib(nibName: "ImagesCollectionViewCell", bundle: nil)
        self.collectionViewForDisplayImagesFromApi.register(uinib, forCellWithReuseIdentifier: "imageCollectionCell")
        
         uinib = UINib(nibName: "DisplayDataCollectionViewCell", bundle: nil)
        self.collectionViewForDisplayDataFromApi.register(uinib, forCellWithReuseIdentifier: "dataCollectionViewCell")
        
        var nib = UINib(nibName: "TableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "tableViewCell")
        
    }
    
//Mark:- FetchingApi For Showing Data On CollectionView
    func getJsonDataFormApiForDataCollectionView(completed : @escaping() -> ()){
        let urlString = "https://jsonplaceholder.typicode.com/posts"
        guard let  url = URL(string: urlString) else{
            print("did not fetch url")
            return
        }
        URLSession.shared.dataTask(with: url){ data, response, error in
            if(error == nil){
                do{
                    let jsonDecoder = JSONDecoder()
                    self.posts = try! jsonDecoder.decode([Post].self, from: data!)
                 }catch{
                    print("error")
                }
                DispatchQueue.main.async {
                    completed()
                }
            }
        }.resume()
    }
    
//Mark:- Fetching Api For showing image On collection View
    func getJsonDataFormApiForImageCollectionView(){
        let urlString = "https://fakestoreapi.com/products"
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = ("get")
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request){data,response,error in
            print(data!)
            print(error as Any)
            
            let getJsonData = try! JSONSerialization.jsonObject(with: data!) as! [[String : Any]]
            
            guard data != nil else{
                print("Data not found")
                print("error\(String(describing: error))")
                return
            }
            for dictionary in getJsonData{
                let eachDict = dictionary

                let img = eachDict["image"] as! String
                self.resultFromProductModelClass.append(ApiResponse(image: img))
                
            }
            DispatchQueue.main.async {
                self.collectionViewForDisplayImagesFromApi.reloadData()
            }
        }
        dataTask.resume()
    }
//Mark:- Fetching Api For showing Data On Table View
    func FetchJsonDataForTableView(completed : @escaping() -> ()){
        let url = URL(string: "https://dummyjson.com/products")
        URLSession.shared.dataTask(with: url!){data, response, error in
            guard let data = data else{
                print("data not found")
                return
            }
            print(data)
            print(error)
            
            let result = try! JSONDecoder().decode(ApiResponseForUser.self, from: data)
            self.apiResult = result.products
            DispatchQueue.main.async {
                completed()
            }
        }.resume()
    }
    
}

//mark:- Create Extension To Conform Googlemap methods
extension HomeViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            manager.stopUpdatingLocation()
            render(location)
        }
        let coordinates : CLLocationCoordinate2D = manager.location!.coordinate
       
        
    }
    func render(_ location : CLLocation){
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapViewForDisplayCurrentLocation.setRegion(region, animated: true)
        mapViewForDisplayCurrentLocation.showsUserLocation = true
    }
}

//Mark:-//mark:- Create Extension To Conform CollectionViw methods
extension HomeViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0{
            return posts.count
        }else{
            return resultFromProductModelClass.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0{
            let dataCell = self.collectionViewForDisplayDataFromApi.dequeueReusableCell(withReuseIdentifier: "dataCollectionViewCell", for: indexPath) as! DisplayDataCollectionViewCell
            dataCell.idLabel.text = String(posts[indexPath.row].id)
            dataCell.titleLabel.text = posts[indexPath.row].title
            dataCell.bodyLabel.text = posts[indexPath.row].body
            return dataCell
        }else{
            let imgCell = self.collectionViewForDisplayImagesFromApi.dequeueReusableCell(withReuseIdentifier: "imageCollectionCell", for: indexPath) as! ImagesCollectionViewCell
            let imageFetched = NSURL(string: resultFromProductModelClass[indexPath.row].image)
            imgCell.imgView.sd_setImage(with: imageFetched as URL?)
            return imgCell
        }
        
    }
}

//mark:- Create Extension To Conform CollectionViewDelegateFlowlayout
extension HomeViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0{
            return CGSize(width: 220, height: 220)
        }else{
            return CGSize(width: 185, height: 122)
        }
    }
}

//mark:- Create Extension To Conform TableView methods
extension HomeViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apiResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! TableViewCell
        cell.idLabel.text = String(apiResult[indexPath.row].id)
        cell.titleLabel.text = apiResult[indexPath.row].title
        cell.priceLabel.text = String(apiResult[indexPath.row].price)
        return cell
    }
}

extension HomeViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        110
    }
}
