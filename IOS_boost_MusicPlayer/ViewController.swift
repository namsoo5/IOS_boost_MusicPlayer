//
//  ViewController.swift
//  IOS_boost_MusicPlayer
//
//  Created by 남수김 on 04/02/2019.
//  Copyright © 2019 남수김. All rights reserved.
//

import UIKit
import AVFoundation //player를 만들기위한

class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    @IBOutlet weak var playbt: UIButton!
    @IBOutlet weak var playtimeLabel: UILabel!
    @IBOutlet weak var playslider: UISlider!
    
    var player: AVAudioPlayer!
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPlayer()
    }
    
    
    //MARK: - 기능 함수
    //player init
    func initPlayer() {
        //음원에셋파일가져옴
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else {
            print("음원 에셋파일이 존재하지 않습니다.")
            return
        }
        
        do{
            try self.player = AVAudioPlayer(data: soundAsset.data)
            self.player.delegate = self
        } catch let error as NSError {
            print("플레이어 초기화실패")
            print("코드: \(error.code), 메시지: \(error.localizedDescription)")
        }
        
        //slider위치값 초기화
        self.playslider.maximumValue = Float(self.player.duration)
        self.playslider.minimumValue = 0
        self.playslider.value = Float(self.player.currentTime)
        
    }
    
    //재생시간text 업데이트
    func updateTimeLabel(time: TimeInterval){
        let minute: Int = Int(time / 60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        // 60으로 나누고남은 나머지
        let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        let timeText: String = String(format: "%02ld:%02ld:%02ld", minute, second, milisecond)
        
        self.playtimeLabel.text = timeText
    }
    
    
    //타이머기능
    func fireTimer() {
        //scheduledTimer 타이머 콜백함수
        //withTimeInterval 타이머실행주기
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: {(timer: Timer) in
            
            if self.playslider.isTracking { return }
            //누르고잇는상태면 타이머시작 안함 ( 누르고있는상태면 아래코드실행안함 )
            
            self.updateTimeLabel(time: self.player.currentTime)
            self.playslider.value = Float(self.player.currentTime)
            //타이머 값으로 text, slider수정
        })
        self.timer.fire() //타이머 시작
    }
    
    //타이머 삭제
    func invalidateTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    //MARK: - IBAction
    //재생버튼클릭시
    @IBAction func btclick(_ sender: UIButton) {
        
        
        sender.isSelected = !sender.isSelected  //눌렷을때 값전환
        
        if sender.isSelected {
            
            let msg = "재생하시겠습니까?"
            //alert 작성
            let alert: UIAlertController = UIAlertController(title: "알림", message: msg, preferredStyle: UIAlertController.Style.alert)
            
            //alert에 대한 action작성
            let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) -> Void in
                self.player?.play()
                self.dismiss(animated: true, completion: nil) // yes 누르면 alert 사라짐
            })
            let noAction: UIAlertAction = UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) -> Void in
                sender.isSelected = !sender.isSelected //값 다시 원래대로
                self.dismiss(animated: true, completion: nil) // no 누르면 alert 사라짐
            })
            alert.addAction(noAction)  // alert action추가, 추가한순서대로 왼쪽부터 나열됨
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)  //해당 컨텐츠(alert)를 모달형식으로 띄움
            
            //self.player?.play()
        } else {
            self.player?.pause()
        }
        
        if sender.isSelected {
            self.fireTimer()  // 타이머생성(현 재생시간 표기)
        } else {
            self.invalidateTimer()  //타이머삭제
        }
        
        
    }
    
    //슬라이더 움직일시
    @IBAction func slider(_ sender: UISlider) {
        self.updateTimeLabel(time: TimeInterval(sender.value))  //text를 slider로 이동한 재생시간으로 변경
        if sender.isTracking {
            return // slide 하는도중에는 아래코드를 실행 하지않는다
        }
        self.player.currentTime = TimeInterval(sender.value) //slider값으로 재생시간 변경
        
    }
    
    //MARK:- delegate
    //decode error
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let error: Error = error else{
            print("decode error")
            return
        }
        
        let msg = "오디오 플레이어 오류 발생 \(error.localizedDescription)"
        
        //alert 작성
        let alert: UIAlertController = UIAlertController(title: "알림", message: msg, preferredStyle: UIAlertController.Style.alert)
        
        //alert에 대한 action작성
        let okAction: UIAlertAction = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction) -> Void in
            
            self.dismiss(animated: true, completion: nil) // yes 누르면 alert 사라짐
        })
        alert.addAction(okAction)  // alert action추가
        self.present(alert, animated: true, completion: nil)  //해당 컨텐츠를 모달형식으로 띄움
        
    }
    //끝까지 들었을씨
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playbt.isSelected = false //초기상태로
        self.playslider.value = 0
        self.updateTimeLabel(time: 0)
        self.invalidateTimer()
    }
    
    //MARK:- 코드로 뷰만들기
    //    func addViewsWithCode() {
    //        self.addPlayPauseButton()
    //        self.addTimeLabel()
    //        self.addProgressSlider()
    //    }
    //
    //    func addPlayPauseButton() {
    //
    //        let button: UIButton = UIButton(type: UIButtonType.custom)
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //
    //        self.view.addSubview(button)
    //
    //        button.setImage(UIImage(named: "button_play"), for: UIControlState.normal)
    //        button.setImage(UIImage(named: "button_pause"), for: UIControlState.selected)
    //
    //        button.addTarget(self, action: #selector(self.touchUpPlayPauseButton(_:)), for: UIControlEvents.touchUpInside)
    //
    //        let centerX: NSLayoutConstraint
    //        centerX = button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
    //
    //        let centerY: NSLayoutConstraint
    //        centerY = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.centerY, multiplier: 0.8, constant: 0)
    //
    //        let width: NSLayoutConstraint
    //        width = button.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5)
    //
    //        let ratio: NSLayoutConstraint
    //        ratio = button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 1)
    //
    //        centerX.isActive = true
    //        centerY.isActive = true
    //        width.isActive = true
    //        ratio.isActive = true
    //
    //        self.playPauseButton = button
    //    }
    //
    //    func addTimeLabel() {
    //        let timeLabel: UILabel = UILabel()
    //        timeLabel.translatesAutoresizingMaskIntoConstraints = false
    //
    //        self.view.addSubview(timeLabel)
    //
    //        timeLabel.textColor = UIColor.black
    //        timeLabel.textAlignment = NSTextAlignment.center
    //        timeLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
    //
    //        let centerX: NSLayoutConstraint
    //        centerX = timeLabel.centerXAnchor.constraint(equalTo: self.playPauseButton.centerXAnchor)
    //
    //        let top: NSLayoutConstraint
    //        top = timeLabel.topAnchor.constraint(equalTo: self.playPauseButton.bottomAnchor, constant: 8)
    //
    //        centerX.isActive = true
    //        top.isActive = true
    //
    //        self.timeLabel = timeLabel
    //        self.updateTimeLabelText(time: 0)
    //    }
    //
    //    func addProgressSlider() {
    //        let slider: UISlider = UISlider()
    //        slider.translatesAutoresizingMaskIntoConstraints = false
    //
    //        self.view.addSubview(slider)
    //
    //        slider.minimumTrackTintColor = UIColor.red
    //
    //        slider.addTarget(self, action: #selector(self.sliderValueChanged(_:)), for: UIControlEvents.valueChanged)
    //
    //        let safeAreaGuide: UILayoutGuide = self.view.safeAreaLayoutGuide
    //
    //        let centerX: NSLayoutConstraint
    //        centerX = slider.centerXAnchor.constraint(equalTo: self.timeLabel.centerXAnchor)
    //
    //        let top: NSLayoutConstraint
    //        top = slider.topAnchor.constraint(equalTo: self.timeLabel.bottomAnchor, constant: 8)
    //
    //        let leading: NSLayoutConstraint
    //        leading = slider.leadingAnchor.constraint(equalTo: safeAreaGuide.leadingAnchor, constant: 16)
    //
    //        let trailing: NSLayoutConstraint
    //        trailing = slider.trailingAnchor.constraint(equalTo: safeAreaGuide.trailingAnchor, constant: -16)
    //
    //        centerX.isActive = true
    //        top.isActive = true
    //        leading.isActive = true
    //        trailing.isActive = true
    //
    //        self.progressSlider = slider
    //    }
    
}

