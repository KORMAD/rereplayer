//
//  ViewController.swift
//  rereplayer
//
//  Created by soojin jeong on 2022/11/29.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import AVFoundation
import RealmSwift
protocol isAbleToReceiveData {
  func pass(data: String)  //data: string is an example parameter
}

class RateSettingViewController: UIViewController  {
    
    var delegate: isAbleToReceiveData?
    
    @IBOutlet var testLabel: UILabel!
    var labelText: String?
    

    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          print("ViewController의 view가 사라지기 전")
        
     }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testLabel.text=labelText
    }
  
    @IBAction func test(_ sender: UIButton) {
        print("test method")
        
        if presentingViewController != nil {
            print("presentingViewController")
            
            guard let presentingVC = self.presentingViewController as? UINavigationController else {
                print("guard enter")
                return
                
            }
            print(presentingVC)
            
            guard let rootVC = presentingVC.viewControllers.first as? ViewController else{
           // guard let rootVC = navigationController.topViewController as? ViewController else{
                print("guard rootVc");
                return
            }
            rootVC.paramRate="HELLO"
            rootVC.lbCurrentTime.text="1984.07.02"
            /*
            self.dismiss(animated: true) {
                  presentingVC.popToRootViewController(animated: true)
            }
            */
            dismiss(animated: true, completion: nil)
            
        
        } else {
            print("popViewController")
            navigationController?.popViewController(animated: true)
        }
        
        
     
    }
    
    
    
}


class ViewController: UIViewController, UIDocumentPickerDelegate, AVAudioPlayerDelegate, AVAudioRecorderDelegate, UITableViewDataSource, UITableViewDelegate, isAbleToReceiveData   {
    


    

    let timePlayerSelector:Selector = #selector(ViewController.updatePlayTime)
    var progressTimer : Timer!
    
    var paramRate: String? // 값을 전달받을 속성
    var audioPlayer : AVAudioPlayer!
    var audioFile : URL!
    var structPlayList: [StructPlayInfo]!
    
    @IBOutlet var slStartArrow: UISlider!
    @IBOutlet var lbStartText: UILabel!
    @IBOutlet var slEndArrow: UISlider!
    @IBOutlet var lbEndText: UILabel!
    @IBOutlet var slSliderPlay: UISlider!
    
    
    @IBOutlet var lbCurrentTime: UILabel!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPause: UIButton!
    @IBOutlet var btnStop: UIButton!
    @IBOutlet var playListTableView: UITableView!
    @IBOutlet var btnSlower: UIButton!
    
    // Realm 가져오기
    var realm: Realm?
    func setGradientBackground() {
        let colorTop =  UIColor(red: 85.0/255.0, green: 37.0/255.0, blue: 134.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 128/255.0, green: 79/255.0, blue: 179/255.0, alpha: 1.0).cgColor
                    
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds
                
        self.view.layer.insertSublayer(gradientLayer, at:0)
    }

    // 화면에 표시될 때마다 실행되는 메소드
    override func viewWillAppear(_ animated: Bool) {
        setGradientBackground()
        
        if let rate = paramRate {
            print(rate);
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        initPlay()
        addLongPressGesture()
    }
    func pass(data: String) { //conforms to protocol
    // implement your own implementation
        print("pass")
        print(data)
        //self.showData.text = "\(data)"
        lbCurrentTime.text = "\(data)"
     }
    func setPet(_ pet: String) {
      //override the label with the parameter received in this method
        print(pet)
        
    }
    @IBAction func btnFasterClick(_ sender: Any) {
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "RateSettingViewController") as? RateSettingViewController else {return}
        nextVC.modalPresentationStyle = .fullScreen//전체화면(기본은 팝업형태)
        
        nextVC.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        nextVC.labelText="이동 완료"
        self.present(nextVC, animated: true)

    }
    
    func addLongPressGesture(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPress.minimumPressDuration = 2
        self.btnSlower.addGestureRecognizer(longPress)
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        /*
        if gesture.state == UIGestureRecognizerState.began {
            print("Long Press")
        }
         */
        print(gesture.state.rawValue)
        
        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "RateSettingViewController") as? RateSettingViewController else {return}

        //present 방식
        //nextVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        nextVC.modalPresentationStyle = .fullScreen//전체화면(기본은 팝업형태)
        //nextVC.modalPresentationStyle = .overCurrentContext
        //애니메이션 설정 - 반대로 돌아올 때도 적용됩니다.
        nextVC.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        nextVC.labelText="이동 완료"
        self.present(nextVC, animated: true)
        
        
        //네비게이션 방식
        /*
        if let nextVC = storyboard?.instantiateViewController(withIdentifier: "RateSettingViewController") as? RateSettingViewController {
                  //informs the Juice ViewController that the restaurant is the delegate
            nextVC.delegate = self
            nextVC.labelText="이동 완료"
            self.navigationController?.pushViewController(nextVC, animated: true)
          }
         */
    }
    
    
    
    /// 어학플레이 초기화
    ///
    /// - Parameters:
    func initPlay() {
        structPlayList=[];
        // Do any additional setup after loading the view.
        playListTableView.delegate = self
        playListTableView.dataSource = self
        
        
        realm = try! Realm()

        // Realm 파일 위치
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // RealmPlayList 가져오기
        let savedPlayList = realm!.objects(RealmPlayList.self)
        
        for (index, tPlayInfo) in savedPlayList.enumerated(){
            var structInfo = StructPlayInfo()
            structInfo.fileName=tPlayInfo.fileName
            structInfo.url=tPlayInfo.url
            structInfo.albumName=tPlayInfo.albumName
            structInfo.title=tPlayInfo.title
            structInfo.artist=tPlayInfo.artist
            print(structInfo.url)
            structPlayList.append(structInfo)
        }
        
    }
    
    @IBAction func showDocumentPicker(_ sender: UIBarButtonItem) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.mp3])
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .overFullScreen
        documentPicker.allowsMultipleSelection = true
        present(documentPicker, animated: true)
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){

        for (index, url) in urls.enumerated(){
            guard url.startAccessingSecurityScopedResource() else {
                return
            }
            //let destPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            var tempURL=URL(fileURLWithPath: destPath)
            //var tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            print(tempURL.path)
            tempURL.appendPathComponent(url.lastPathComponent)
            print(tempURL.path)
            do {
            if FileManager.default.fileExists(atPath: tempURL.path) {
                try FileManager.default.removeItem(atPath: tempURL.path)
            }
            // Move file from app_id‑Inbox to tmp/filename
            try FileManager.default.copyItem(atPath: url.path, toPath: tempURL.path)
            } catch {
                print(error.localizedDescription)
                //return nil
            }
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            print("absoluteString:\(tempURL.absoluteString)")
            
            var structPlayInfo = StructPlayInfo()
            structPlayInfo.fileName=tempURL.lastPathComponent
            structPlayInfo.url=tempURL.absoluteString
            
            
            if let serverURL = URL(string: url.absoluteString) {
                let asset = AVAsset(url: serverURL)
                // do something with the asset
                
                for metaDataItems in asset.commonMetadata {
                    
                    if metaDataItems.commonKey?.rawValue == "title" {
                        if let titleData = metaDataItems.stringValue{
                            print("title ---> \(titleData)")
                            structPlayInfo.title=titleData
                        }
                    }
                            //getting the "Artist of the mp3 file"
                    if metaDataItems.commonKey?.rawValue == "artist" {
                        if let artistData = metaDataItems.stringValue{
                            structPlayInfo.artist=artistData
                            print("artist ---> \(artistData)")
                        }
                    }
                    
                    if metaDataItems.commonKey?.rawValue == "albumName" {
                        if let albumNameData = metaDataItems.stringValue{
                            structPlayInfo.albumName=albumNameData
                            print("albumName ---> \(albumNameData)")
                        }
                    }
                }
            }
            
            structPlayList.append(structPlayInfo)
            
            var tPlaylist = RealmPlayList()
            tPlaylist.fileName = structPlayInfo.fileName
            tPlaylist.albumName = structPlayInfo.albumName
            tPlaylist.artist = structPlayInfo.artist
            tPlaylist.title = structPlayInfo.title
            tPlaylist.url = structPlayInfo.url
            //tPlaylist.fileName=tempURL.lastPathComponent
            if let tRealm = realm{
                try! tRealm.write {
                    tRealm.add(tPlaylist)
                }
            }
            
        }//for
        playListTableView.reloadData()
    }
    
    @IBAction func btnPlayAudio(_ sender: UIButton) {
        audioPlayer.play()
        setPlayButtons(false, pause: true, stop: true)
    }
    
    @IBAction func btnPauseAudio(_ sender: UIButton) {
        audioPlayer.pause()
        setPlayButtons(true, pause: false, stop: true)
    }
    
 
    @IBAction func btnStopAudio(_ sender: UIButton) {
        audioPlayer.stop()
        setPlayButtons(true, pause: false, stop: false)
        
    }
    
    func setPlayButtons(_ play:Bool, pause:Bool, stop:Bool) {
        btnPlay.isEnabled = play
        btnPause.isEnabled = pause
        btnStop.isEnabled = stop
    }
    @IBAction func btnMoveBefore(_ sender: UIButton) {
        print(audioPlayer.currentTime)
        audioPlayer.currentTime = audioPlayer.currentTime - 5
        print(audioPlayer.currentTime)
    }
    @IBAction func btnMoveAfter(_ sender: UIButton) {
        print(audioPlayer.currentTime)
        audioPlayer.currentTime = audioPlayer.currentTime + 5
        print(audioPlayer.currentTime)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return structPlayList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = playListTableView.dequeueReusableCell(withIdentifier: "playListCell", for: indexPath) as! PlayListTableViewCell
        cell.lbFilenName.text = structPlayList[indexPath.row].fileName
        cell.lbAlbumName.text = structPlayList[indexPath.row].albumName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        print(indexPath.row)
        
        let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        var tempURL=URL(fileURLWithPath: destPath)
        
        //let playUrl=tempURL.path+"/"+structPlayList[indexPath.row].fileName
        
        let playUrl=tempURL.appendingPathComponent(structPlayList[indexPath.row].fileName)
        
        print(playUrl)
        
        guard playUrl.startAccessingSecurityScopedResource() else {
            return
        }
        audioFile=playUrl
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.enableRate = true
            audioPlayer.volume = 1.0
            
            progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timePlayerSelector, userInfo: nil, repeats: true)
            
            
            slStartArrow.minimumValue = 0.0
            slStartArrow.maximumValue = Float(audioPlayer.duration)
            slEndArrow.value = 0.0
            lbStartText.text=convertNSTimeInterval2String(Double(0))
            
            slEndArrow.minimumValue = 0.0
            slEndArrow.maximumValue = Float(audioPlayer.duration)
            slEndArrow.value = Float(audioPlayer.duration)
            lbEndText.text=convertNSTimeInterval2String(Double(audioPlayer.duration))
            
            slSliderPlay.minimumValue = 0.0
            slSliderPlay.maximumValue = Float(audioPlayer.duration)
            slSliderPlay.value = 0.0
            
            audioPlayer.play()
            setPlayButtons(false, pause: true, stop: true)
        } catch let error as NSError {
            print("Error-initPlay : \(error)")
        }
        
        defer {
            playUrl.stopAccessingSecurityScopedResource()
        }
        /*
        if let playUrl = URL(string: structPlayList[indexPath.row].url){
            guard playUrl.startAccessingSecurityScopedResource() else {
                return
            }
            
            
            //print(playUrl.absoluteString)
            audioFile=playUrl
            
        
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
                audioPlayer.delegate = self
                audioPlayer.prepareToPlay()
                audioPlayer.enableRate = true
                audioPlayer.volume = 1.0
                
                progressTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: timePlayerSelector, userInfo: nil, repeats: true)
                
                audioPlayer.play()
                setPlayButtons(false, pause: true, stop: true)
            } catch let error as NSError {
                print("Error-initPlay : \(error)")
            }
            
            defer {
                playUrl.stopAccessingSecurityScopedResource()
            }
        }
        */

    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                structPlayList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                
            } else if editingStyle == .insert {
                
            }
        }
    
    @objc func updatePlayTime() {
        lbCurrentTime.text = convertNSTimeInterval2String(audioPlayer.currentTime)
        slSliderPlay.value = Float(audioPlayer.currentTime)
    }
    
    func convertNSTimeInterval2String(_ time:TimeInterval ) -> String{
        let min = Int(time/60)
        let sec = Int(time.truncatingRemainder(dividingBy: 60))
        let strTime = String(format: "%02d:%02d", min,sec)
        return strTime
    }
    
    @IBAction func changeStartArrow(_ sender: Any) {
        if(slStartArrow.value > slEndArrow.value){
            slStartArrow.value=slEndArrow.value
        }
        lbStartText.text=convertNSTimeInterval2String(Double(slStartArrow.value))
    }
    @IBAction func changeEndArrow(_ sender: Any) {
        if(slEndArrow.value < slStartArrow.value  ){
            slEndArrow.value=slStartArrow.value
        }
        lbEndText.text=convertNSTimeInterval2String(Double(slEndArrow.value))
    }
    
    @IBAction func changedSliderPlay(_ sender: Any) {
        print(audioPlayer.currentTime)
        audioPlayer.currentTime = Double(slSliderPlay.value)
        print(audioPlayer.currentTime)
        
    }
    
    /* !todo delete */
    @IBAction func testClick(_ sender: Any) {
        audioPlayer.rate = 2.0
    }
    
    
    @IBAction func test2Click(_ sender: Any) {
        audioPlayer.rate = 1.0
    }
}

