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
    @IBOutlet private weak var progressView: UIProgressView!
    
    struct FlowSignals {
        static let loader_progress = "loader_progress"
        static let loader_finished = "loader_finished"
        static let loader_error    = "loader_error"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = "-"
        progressView.progress = 0

        // Subscribe to progress
        FlowBridge.connect(FlowSignals.loader_progress) { [weak self] data in
            guard let self else { return }
            if let p = data as? NSNumber {
                DispatchQueue.main.async {
                    self.progressView.progress = Float(truncating: p)
                    self.nameLabel.text = "\(Int((p.doubleValue) * 100))%"
                }
            }
        }

        // Completion
        FlowBridge.connect(FlowSignals.loader_finished) { [weak self] data in
            guard let self else { return }
            let path = (data as? String) ?? ""
            DispatchQueue.main.async {
                self.nameLabel.text = "Saved: \(path.lastPathComponent)"
            }
        }

        // Error
        FlowBridge.connect(FlowSignals.loader_error) { [weak self] data in
            guard let self else { return }
            let message = (data as? String) ?? "Unknown error"
            DispatchQueue.main.async {
                self.nameLabel.text = "Error: \(message)"
            }
        }

        // Start download (URL example - large file)
        let url = "https://speedtest.selectel.ru/10MB"
        ManagerWrapper.shared().startDownload(withURL: url, destFileName: "10MB.bin")
    }
}

// A small helper for displaying the last component of the path
private extension String {
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
}
