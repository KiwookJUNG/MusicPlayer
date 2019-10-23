//
//  ViewController.swift
//  MusicPlayer
//
//  Created by 정기욱 on 30/09/2019.
//  Copyright © 2019 kiwook. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: Properties
    var player: AVAudioPlayer!
    var timer: Timer!
    
    // MARK: IBOutlets
    @IBOutlet var playPauseButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var progressSlider: UISlider!
    
    // MARK: IBActions
    // Play 버튼이 눌러졌을때 
    @IBAction func touchUpPlayPauseButton(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.player?.play()
        } else {
            self.player?.pause()
        }
        
        if sender.isSelected {
            self.makeAndFireTimer()
        } else {
            self.invalidateTimer()
        }
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
       
        self.updateTimeLabelText(time: TimeInterval(sender.value))
        if sender.isTracking { return }
        self.player.currentTime = TimeInterval(sender.value)
       
    }
    
    // MARK: viewDidLoad
    // 컨트롤러의 뷰가 메모리에 로드되고 난 이후 호출되는 메소드
    override func viewDidLoad() {
         super.viewDidLoad()
         // Do any additional setup after loading the view.
         
         self.initializedPlayer()
    }
    
    
    
    // MARK: Custom Method
    func initializedPlayer() {
        // NSDataAsset(name:) 이니셜라이저를 사용해 Asset 카달로그에 있는 데이터로 초기화
        guard let soundAsset: NSDataAsset = NSDataAsset(name: "sound") else {
            print("음원 파일 에셋을 가져올 수 없습니다.")
            return
        }
        
        do {
            // AVAudiPlayer(data:)는 throws 초기화 메소드 이므로
            // 오류가 발생하면 오류를 던져주는 초기화 메소드이므로
            // do - try - catch 구문을 사용해야한다.
            try self.player = AVAudioPlayer(data: soundAsset.data)
            
            // AVAudioPlayerDelegate의 델리게이트 프로퍼티는 self(ViewController)로 지정
            self.player.delegate = self
        } catch let error as NSError {
            print("플레이어 초기화 실패")
            print("코드 : \(error.code), 메시지 : \(error.localizedDescription)")
        }
        
        self.progressSlider.maximumValue = Float(self.player.duration)
        self.progressSlider.minimumValue = 0
        self.progressSlider.value = Float(self.player.currentTime)
    }
    
    func updateTimeLabelText(time: TimeInterval) {
        let minute: Int = Int(time / 60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        let timeText: String = String(format: "%02ld:%02ld:%02ld", minute, second, milisecond)
        
        self.timeLabel.text = timeText
    }
    
    func makeAndFireTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self] (timer: Timer) in
            
            if self.progressSlider.isTracking { return }
            
            self.updateTimeLabelText(time: self.player.currentTime)
            self.progressSlider.value = Float(self.player.currentTime)
        })
        self.timer.fire()
    }
    
    func invalidateTimer() {
        // Stops the timer from ever firing again and
        // requests its removal from its run loop.
        self.timer.invalidate()
        self.timer = nil
    }
 

    
    

}




// MARK: AVAudioPlayerDelegate

extension ViewController: AVAudioPlayerDelegate {

    // plyer의 delegate 프로퍼티가 self(ViewController)이므로 self가 대신해서 처리해줌.
    // 디코딩 과정에서 에러가 발생했을 때 메출되는 메소드
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
        guard let error: Error = error else {
            print("오디오 플레이어 디코드 오류발생")
            return
        }
        
        let message: String
        message = "오디오 플레이어 오류 발생 \(error.localizedDescription)"
        
        let alert: UIAlertController = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        
        let okAction : UIAlertAction = UIAlertAction(title: "확인", style: .default) { (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // 음악이 끝나자마자 호출되는 메소드
    // 음악을 모두 재생하면 버튼, 레이블, 슬라이더가 맨 처음 상태로 되돌아감.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playPauseButton.isSelected = false // 재생버튼 초기화
        self.progressSlider.value = 0 // 슬라이더 초기화
        self.updateTimeLabelText(time: 0) // 시간 레이블 초기화
        self.invalidateTimer() // 
    }
}

