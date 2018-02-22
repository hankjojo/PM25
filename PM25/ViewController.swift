//
//  ViewController.swift
//  TestAlamofire
//
//  Created by 江宗翰 on 2017/12/25.
//  Copyright © 2017年 Hank.Chiang. All rights reserved.
//
import UIKit
import Alamofire
import SwiftyJSON
import SWXMLHash
import NVActivityIndicatorView
import MapKit
import Hero


class MyMkMarkerAnnotation : MKPointAnnotation {
    var markerTintColor: UIColor?
    var glyPhText: String?
    var glyphTintColor: UIColor?
}

class ViewController: UIViewController ,MKMapViewDelegate{
    
    var infoMod:String = "PM25"
    var show:Bool = false
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var nvView: NVActivityIndicatorView!
    @IBOutlet var menuView: UIView!
    @IBOutlet weak var nvItem: UINavigationItem!
    @IBOutlet weak var pm25standard: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("lat:\(map.region.center.latitude)  long:\(map.region.center.longitude)")
        //經度
        let latitude:CLLocationDegrees = 23.597651
        //緯度
        let longitude:CLLocationDegrees = 120.997932
        //座標
        let location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        //x軸
        let xScale:CLLocationDegrees = 4
        //y軸
        let yScale:CLLocationDegrees = 4
        //縮放範圍
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: xScale, longitudeDelta: yScale)
        //顯示區域
        let region:MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.addSubview(menuView)
        //設定元件位置必須先把Autoresizing關掉不然會出錯
        menuView.translatesAutoresizingMaskIntoConstraints = false
        //高度
        menuView.heightAnchor.constraint(equalToConstant: 400).isActive = true
        menuView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        //左邊的constraint
        menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        //右邊的constraint
//        menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        //宣告下面
        let c = menuView.topAnchor.constraint(equalTo: view.topAnchor, constant: -400)
        c.identifier = "bottom"
        c.isActive = true
        //四個圓角弧度
        menuView.layer.cornerRadius = 10
        
        getInfo()
    }
    @IBAction func changeMod(_ sender: UIButton) {
        if infoMod == sender.restorationIdentifier!{
            displayView(false)
            show = false
        }else{
            infoMod = sender.restorationIdentifier!
            getInfo()
            displayView(false)
            show = false
        }
    }
    
    @IBAction func showView(_ sender: UIBarButtonItem) {
        if show {
            displayView(false)
            show = false
        } else {
            displayView(true)
            show = true
        }
        
    }
    //控制menuView位置的方法
    func displayView(_ show:Bool){
        //找所有constraints
        for c in view.constraints {
            //如果找到..
            if c.identifier == "bottom" {
                //改變myView的位置讓他跳出或收回
                if show {
                    c.constant = 100
                }else{
                    c.constant = -400
                }
                break
            }
        }
        
        UIView.animate(withDuration: 0.5){
            self.view.layoutIfNeeded()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getInfo(){
        if infoMod == "PM25" {
            getPM25Info()
        }else if infoMod == "weather" {
            getWeatherInfo()
        }
    }
    
    
    //iso日期格式處理
    func isoDateStringToString(isoDateString:String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        let date = isoFormatter.date(from: isoDateString)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    @IBAction func refreshAction(_ sender: UIBarButtonItem) {
        print(infoMod)
        getInfo()
    }
    
    //改寫MKAnnotationView顏色
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Marker") as? MKMarkerAnnotationView
    
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Marker")
                annotationView?.canShowCallout = true //接受外面給的設定
            } else {
                annotationView?.annotation = annotation
            }
    
            if let annotation = annotation as? MyMkMarkerAnnotation {
                annotationView?.markerTintColor = annotation.markerTintColor
                annotationView?.glyphText = annotation.glyPhText
                annotationView?.glyphTintColor = annotation.glyphTintColor
            }
            annotationView?.displayPriority = .required
            return annotationView
        
    }
    //取天氣資訊(xml)
    func getWeatherInfo(){
        pm25standard.isHidden = true
        nvItem.title = "溫度"
        nvView.startAnimating() //開始播放loading動畫
        map.removeAnnotations(self.map.annotations)//刪除所有annotation
        let url = "http://opendata.cwb.gov.tw/govdownload?dataid=O-A0003-001&authorizationkey=rdec-key-123-45678-011121314"
        Alamofire.request(url).responseString { response in
            if let data = response.result.value {
                let xml = SWXMLHash.parse(data)
                let location = xml["cwbopendata"]["location"]
                for l in location.all {
                    //經度 緯度
                    if let latString = l["lat"].element?.text, let longString = l["lon"].element?.text{
                        let latitude = CLLocationDegrees(latString)!
                        let longitude = CLLocationDegrees(longString)!
                        //座標
                        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        //大頭針
                        let annotation = MyMkMarkerAnnotation()
                        annotation.markerTintColor = UIColor(red: 85/255, green: 186/255, blue: 238/255, alpha: 1)
                        annotation.coordinate = location
                        if let weatherElement = l["weatherElement"][3]["elementValue"]["value"].element?.text {
                            annotation.glyPhText = "\(Int(Double(weatherElement)!))℃"
                        }
                        self.map.addAnnotation(annotation)
                    }
                    
                }
            }
            
            self.nvView.stopAnimating() //結束播放loading動畫
        }
    }
    
    
    //取得pm2.5資訊(jsno)
    func getPM25Info(){
        pm25standard.isHidden = false
        nvItem.title = "PM2.5"
        nvView.startAnimating() //開始播放loading動畫
        map.removeAnnotations(self.map.annotations)//刪除所有annotation
        let url = "https://pm25.lass-net.org/data/last-all-airbox.json"
        Alamofire.request(url).responseJSON { response in
            //避免取得的資料為nil
            if let json = response.result.value {
                //取得台灣各地觀測站的空氣品質指標
                //print("json: \(json)")
                let sjson = JSON(arrayLiteral: json)
                if let content = sjson[0]["feeds"].array{
                    for data in content {
                        
                        //經度
                        let latitude = CLLocationDegrees("\(data["gps_lat"])")!
                        //緯度
                        let longitude = CLLocationDegrees("\(data["gps_lon"])")!
                        //座標
                        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        
                        //大頭針
                        let annotation = MyMkMarkerAnnotation()
                        annotation.coordinate = location
                        annotation.glyphTintColor = .white
                        if let pm25 = Int("\(data["s_d0"])"){
                            if pm25 < 3 {
                                annotation.markerTintColor = UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1)
                            }else if pm25 >= 3 && pm25 < 5 {
                                annotation.markerTintColor = UIColor(red: 29/255, green: 38/255, blue: 243/255, alpha: 1)
                            }else if pm25 >= 5 && pm25 < 8 {
                                annotation.markerTintColor = UIColor(red: 55/255, green: 126/255, blue: 246/255, alpha: 1)
                            }else if pm25 >= 8 && pm25 < 10 {
                                annotation.markerTintColor = UIColor(red: 85/255, green: 186/255, blue: 238/255, alpha: 1)
                            }else if pm25 >= 10 && pm25 < 13 {
                                annotation.markerTintColor = UIColor(red: 117/255, green: 250/255, blue: 236/255, alpha: 1)
                            }else if pm25 >= 13 && pm25 < 15 {
                                annotation.markerTintColor = UIColor(red: 164/255, green: 250/255, blue: 140/255, alpha: 1)
                            }else if pm25 >= 15 && pm25 < 18 {
                                annotation.markerTintColor = UIColor(red: 142/255, green: 251/255, blue: 157/255, alpha: 1)
                            }else if pm25 >= 18 && pm25 < 20 {
                                annotation.markerTintColor = UIColor(red: 232/255, green: 253/255, blue: 88/255, alpha: 1)
                                
                                annotation.glyphTintColor = .black
                            }else if pm25 >= 20 && pm25 < 35  {
                                annotation.markerTintColor = UIColor(red: 252/255, green: 255/255, blue: 84/255,
                                                                     alpha: 1)
                                
                                annotation.glyphTintColor = .black
                            }else if pm25 >= 35 && pm25 < 50 {
                                annotation.markerTintColor = UIColor(red: 240/255, green: 153/255, blue: 55/255, alpha: 1)
                            }else if pm25 >= 50 && pm25 < 65 {
                                annotation.markerTintColor = UIColor(red: 232/255, green: 58/255, blue: 36/255, alpha: 1)
                            }else if pm25 >= 65 && pm25 < 80 {
                                annotation.markerTintColor = UIColor(red: 170/255, green: 34/255, blue: 23/255, alpha: 1)
                            }else if pm25 >= 80 && pm25 < 90 {
                                annotation.markerTintColor = UIColor(red: 171/255, green: 34/255, blue: 148/255, alpha: 1)
                            }else if pm25 >= 90 && pm25 < 100 {
                                annotation.markerTintColor = UIColor(red: 202/255, green: 47/255, blue: 208/255, alpha: 1)
                            }else if pm25 > 100 {
                                annotation.markerTintColor = UIColor(red: 234/255, green: 51/255, blue: 247/255, alpha: 1)
                            }
                        }
                        annotation.glyPhText = "\(data["s_d0"])"
//                        annotation.title = "裝置名稱:\(data["device"])"
                        annotation.subtitle = "PM2.5濃度:\(data["s_d0"])/更新時間:\(self.isoDateStringToString(isoDateString: "\(data["timestamp"])"))"
                        
                        self.map.addAnnotation(annotation)
                        
                    }
                    self.nvView.stopAnimating()  //停止播放loading動畫
                }
            }
        }
    }
    
}

