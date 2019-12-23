//
//  ViewController.swift
//  Tabata
//
//  Created by Mina.
//  Copyright © Masaharu Minagawa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var lapLeft: UILabel!
    @IBOutlet weak var lapMiddle: UILabel!
    @IBOutlet weak var lapRight: UILabel!
    
    @IBOutlet weak var btnStopAndRestart: UIButton!
    @IBOutlet weak var resetBtn: UIButton!
    
    var count = 11
    var workoutCount = 21
    var leftCount = 7
    var rightCount = 8
    
    var soundFile = Sound()
    
    var tenCount:Timer?
    var twentyCount:Timer?
    
    func hideLap() {
        lapLeft.isHidden = true
        lapMiddle.isHidden = true
        lapRight.isHidden = true
        resetBtn.isHidden = true
    }
    
    func showLap() {
        lapLeft.isHidden = false
        lapMiddle.isHidden = false
        lapRight.isHidden = false
        resetBtn.isHidden = false
    }
    
    
    //10秒スタート
    func timerStart() {
        self.tenCount = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCountDown), userInfo: nil, repeats: true)
    }
    
    //ワークアウト開始(20秒)
    func workoutStart() {
        self.twentyCount = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(workoutCountDown), userInfo: nil, repeats: true)
    }
    
    //タイマー起動中、ボタンを押したら止まる
    @objc func stopTime() {
        print("停止")
        self.tenCount?.invalidate()
        self.twentyCount?.invalidate()
    }
    
    //FINISH後のイベント
    @objc func tapFinish() {
        resetAlert()
        print("FINISHからの再開")
    }
    
    @objc func timerCountDown() {
        resetBtn.isHidden = false
        count -= 1
        countLabel.text = String(count)
    
        
        if count <= 1 {
            //インターバルが0になった時に呼ばれる
            if count == 1 {
                leftCount += 1
                lapLeft.text = String(leftCount)
            }
            
            //インターバルタイマーストップ
            self.tenCount?.invalidate()
            workoutStart()
            
        } else if count == 3 {
            soundFile.beforeThreeCount(name: "Countdown", extentionName: "mp3")
        }
    }
    
    //ワークアウトカウントダウン
    @objc func workoutCountDown() {
        changeToWorkoutTimerImage()
        workoutCount -= 1
        countLabel.text = String(workoutCount)
        showLap()
        view.backgroundColor = UIColor(hex: "ffc400")
        
        if workoutCount <= 1 {
            // change処理
            if leftCount < 8 {
                self.changeToIntervalTimerSetting()
            } else if workoutCount == 0 && leftCount == 8 {
                //Stop処理
                stopTime()
                countLabel.text = "FINISH"
                view.backgroundColor = UIColor.red
                hideLap()
                resetBtn.isHidden = true
            }
            
        } else if workoutCount == 3 {
            soundFile.beforeThreeCount(name: "Countdown", extentionName: "mp3")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideLap()
        
    }
    
    
    
    @IBAction func btnAction(_ sender: UIButton) {
        
        print("ボタンクリック")
        if sender.tag == 0 {
            sender.tag = 1
            timerStart()
            print("動く")
        } else if workoutCount == 0 && leftCount == 8 {
            stopTime()
            tapFinish() //FINISH中タップした後、イベント発動
        } else {
            sender.tag = 0
            stopTime()
            print("stop")
            
        }
    }
    
    //リセットダイアログの表示
    func resetAlert() {
        let alertAction = UIAlertController(title: "タイマーリセット", message: "リセットしますか？", preferredStyle: .alert)
               
        let resetAction = UIAlertAction(title: "リセット", style: .default, handler: {action in self.resetStartTimer()})
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {action in
            self.timerStart()})
        
        alertAction.addAction(resetAction)
        alertAction.addAction(cancelAction)
        self.present(alertAction, animated: true, completion: nil)
    }
    
    
    @IBAction func reset(_ sender: Any) {
        resetAlert()
        self.tenCount?.invalidate()
        stopTime()
        print("リセットボタン押した")
    }
    
    
    
    
    //MARK: - Private
    //スタートタイマー画像
    private func startTimerImage() {
        btnStopAndRestart.setImage(UIImage(named: "timer_plain"), for: .normal)
    }
    
    //ワークアウトタイマー画像
    private func changeToWorkoutTimerImage() {
        btnStopAndRestart.setImage(UIImage(named: "timer_workout"), for: .normal)
    }
    
    //インターバルタイマー画像
    private func changeToIntervalTimerSetting() {
        btnStopAndRestart.setImage(UIImage(named: "timer_interval"), for: .normal)
        
        workoutCount = 21
        self.tenCount?.invalidate()
        self.hideLap()
        
        if lapLeft.isHidden == true {
            timerStart()
            print("タイマー始動")
        }
        
        showLap()
        count = 11
        view.backgroundColor = UIColor(hex: "fffc79")
    }
    //初期化
    private func resetStartTimer() {
        self.count = 11
        
        self.workoutCount = 21
        self.leftCount = 7
        self.rightCount = 8
        
        //countLabel.textの更新
        self.countLabel.text = "START"
        
        //開始の初期化
        self.btnStopAndRestart.tag = 0
        
        self.hideLap()
        
        btnStopAndRestart.setImage(UIImage(named: "timer_plain"), for: .normal)
        view.backgroundColor = UIColor(hex: "76d6ff")
    }
    
}

//MARK: - Public
public extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        let v = Int("000000" + hex, radix: 16) ?? 0
        let r = CGFloat(v / Int(powf(256, 2)) % 256) / 255
        let g = CGFloat(v / Int(powf(256, 1)) % 256) / 255
        let b = CGFloat(v / Int(powf(256, 0)) % 256) / 255
        self.init(red: r, green: g, blue: b, alpha: min(max(alpha, 0), 1))
    }
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
}

