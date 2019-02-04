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
        
        let timeText: String = String(format: "%02ld:%02ld:02ld", minute, second, milisecond)
        
        self.playtimeLabel.text = timeText
    }

    
    //타이머기능
    func fireTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: {(timer: Timer) in
        
            if self.playslider.isTracking { return }
            //누르고잇는상태면 타이머시작 안함
            
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
    @IBAction func btclick(_ sender: UIButton) {
        
    }
    
    @IBAction func slider(_ sender: Any) {
    }
    
    
}

