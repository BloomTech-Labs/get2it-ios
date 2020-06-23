//
//  TimerVC.swift
//  Get2It
//
//  Created by John Kouris on 6/3/20.
//  Copyright © 2020 John Kouris. All rights reserved.
//

import UIKit

protocol CountdownDelegate: AnyObject {
    func countdownDidUpdate(timeRemaining: TimeInterval)
    func countdownDidFinish()
}

enum CountdownState {
    case started
    case finished
    case reset
}

class TimerVC: UIViewController {
    
    let countdownPicker = UIPickerView()
    let timeLabel = UILabel(frame: .zero)
    let startButton = GTButton(backgroundColor: Theme.primaryBlue, title: "Start")
    let resetButton = GTButton(backgroundColor: Theme.primaryBlue, title: "Reset")
    
    private let countdown = Countdown()
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layoutMargins = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        view.isLayoutMarginsRelativeArrangement = true
        view.spacing = 8
        view.distribution = .fillEqually
        view.alignment = .fill
        return view
    }()
    
    private var duration: TimeInterval {
        let minuteString = countdownPicker.selectedRow(inComponent: 0)
        
        let minutes = Int(minuteString) + 1
        
        let totalSeconds = TimeInterval(minutes * 300)
        return totalSeconds
    }
    
    lazy private var countdownPickerData: [[String]] = {
        let minutes: [String] = Array(1...12).map { String($0 * 5) }
        
        let data: [[String]] = [minutes, ["minutes"]]
        return data
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        view.backgroundColor = .systemBackground
        
        configureViews()
        layoutViews()
        
        countdown.duration = duration
        countdown.delegate = self
        
        updateViews()
    }
    
    func configureViews() {
        countdownPicker.dataSource = self
        countdownPicker.delegate = self
        countdownPicker.selectRow(4, inComponent: 0, animated: false)
        countdownPicker.translatesAutoresizingMaskIntoConstraints = false
        
        startButton.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetTimer), for: .touchUpInside)
        
        timeLabel.text = "00:00:00"
        timeLabel.font = UIFont.monospacedSystemFont(ofSize: 60, weight: .bold)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = .center
    }
    
    @objc private func startTimer() {
        countdown.start()
    }
    
    @objc private func resetTimer() {
        countdown.reset()
        updateViews()
    }
    
    func layoutViews() {
        view.addSubviews(countdownPicker, timeLabel, buttonStackView)
        buttonStackView.addArrangedSubview(startButton)
        buttonStackView.addArrangedSubview(resetButton)
        
        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            timeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            timeLabel.heightAnchor.constraint(equalToConstant: 80),
            
            countdownPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            countdownPicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            countdownPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            countdownPicker.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Timer Finished!", message: "Your countdown is over.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func updateViews() {
        startButton.isEnabled = true
        resetButton.isEnabled = false
        
        startButton.backgroundColor = .systemBlue
        resetButton.backgroundColor = .systemGray
        
        switch countdown.state {
        case .started:
            timeLabel.text = string(from: countdown.timeRemaining)
            startButton.isEnabled = false
            resetButton.isEnabled = true
            startButton.backgroundColor = .systemGray
            resetButton.backgroundColor = .systemBlue
        case .finished:
            timeLabel.text = string(from: 0)
        case .reset:
            timeLabel.text = string(from: countdown.duration)
        }
    }
    
    private func timerFinished(_ timer: Timer) {
        showAlert()
    }
    
    private func string(from duration: TimeInterval) -> String {
        let date = Date(timeIntervalSinceReferenceDate: duration)
        return dateFormatter.string(from: date)
    }

}

extension TimerVC: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return countdownPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countdownPickerData[component].count
    }
}

extension TimerVC: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return countdownPickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 100
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        countdown.duration = duration
        updateViews()
    }
}

extension TimerVC: CountdownDelegate {
    func countdownDidUpdate(timeRemaining: TimeInterval) {
        updateViews()
    }
    
    func countdownDidFinish() {
        updateViews()
        showAlert()
    }
}


