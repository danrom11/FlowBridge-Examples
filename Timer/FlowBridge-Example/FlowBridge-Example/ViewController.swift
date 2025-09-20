//
//  ViewController.swift
//  FlowBridge-Example
//
// Created by Daniil Arsentev on 18.09.2025.
//

import UIKit

import FlowBridge

class ViewController: UIViewController {
    @IBOutlet var nameLabel: UILabel!
    
    struct FlowSignals {
        static let tick_score = "tick_score"
    }

    
    @objc func test(_ data: Any?) {
        print("Data: \(data ?? "none")")
        
        // Приводим к строке и обновляем UI на главном потоке
        if let stringData = data as? String {
            DispatchQueue.main.async {
                self.nameLabel.text = stringData
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        nameLabel.text = "0"
        
        FlowBridge.connect(FlowSignals.tick_score, target: self, slot: #selector(test(_:)))
        
        let manager = ManagerWrapper.shared
        manager().start(withInterval: 1000) // запустит Timer на 1 секунду
    }


}

