//
//  DetailViewController.swift
//  ForeFlightClone
//
//  Created by Logan Blevins on 9/20/21.
//

import Foundation
import UIKit

final class DetailViewController: UIViewController {
    private enum Report: Int {
        case conditions
        case forecast
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
    static func storyboardInstance() -> Self {
        let storyboard = UIStoryboard(name: String(describing: self), bundle: nil)
        return storyboard.instantiateInitialViewController() as! Self
    }
    
    // To simplify the Core Data dance of objects and proper queues, let's make it as simple as possible
    // to avoid any issues between what the user sees and what the store is doing behind the scenes.
    // KISS is a great principle!
    var pack: BasicAirport?
    
    @IBAction private func onSegmentChanged(_ sender: UISegmentedControl) {
        updateView()
    }
    
    @IBOutlet private var textView: UITextView!
    @IBOutlet private var segment: UISegmentedControl!
    @IBOutlet private var identLabel: UILabel!
    @IBOutlet private var lastUpdatedLabel: UILabel!
    
    private func updateView() {
        identLabel.text = pack?.ident
        lastUpdatedLabel.text = pack?.reportUpdated?.description
        
        guard let report = Report(rawValue: segment.selectedSegmentIndex) else { return }
        switch report {
        case .conditions:
            textView.text = viewModel.conditions(for: pack?.report ?? Constants.noDataMessage) ?? Constants.noDataMessage
            break
        case .forecast:
            textView.text = viewModel.forecast(for: pack?.report ?? Constants.noDataMessage) ?? Constants.noDataMessage
            break
        }
    }
    
    private lazy var viewModel = DetailViewModel()
}
