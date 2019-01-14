// Copyright (c) 2019. Paul Jackson

import UIKit

class ViewController: UIViewController {

    @IBOutlet var stateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        stateLabel.text = "Can Download"
    }

    @IBAction func didTouch(_ sender: DownloadButton) {
        switch sender.downloadState {
        case .ready:
            sender.downloadState = .queued
            stateLabel.text = "Queued"
        case .queued:
            sender.downloadState = .downloading
            sender.setProgress(to: 1, withAnimation: true)
            stateLabel.text = "Downloading"
        case .downloading:
            sender.downloadState = .processing
            stateLabel.text = "Processing"
        case .processing:
            sender.resetProgress()
            sender.downloadState = .complete
            stateLabel.text = "Download Complete"
        case .complete:
            sender.downloadState = .ready
            stateLabel.text = "Can Download"
        }
    }
}
