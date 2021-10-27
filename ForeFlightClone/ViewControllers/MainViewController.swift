//
//  MainViewController.swift
//  ForeFlightClone
//
//  Created by Logan Blevins on 9/20/21.
//

import UIKit
import CoreData

final class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Versions < iOS 15 behave differently
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.view.backgroundColor = .clear
        navigationController?.navigationBar.backgroundColor = .clear
        viewModel.initializePersistence()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.beginUpdating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopUpdating()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
        
    private func digestUserInput(_ text: String?) {
        guard let ident = text?.uppercased(), !ident.isEmpty else { return }
        fetchAndShow(ident)
    }
    
    // Prevent quick taps, back to back, before the op has finished
    private func fetchAndShow(_ ident: String) {
        fetchButton.isEnabled = false
        
        viewModel.fetchWeatherAsync(for: ident) { [weak self] result in
            guard let strongSelf = self else { return }
            
            defer {
                strongSelf.fetchButton.isEnabled = true
            }
            
            switch result {
            case .success(let json):
                print(json)
                strongSelf.viewModel.addAirportAsync(byIdent: ident, json: json) { added in
                    if let added = added {
                        DispatchQueue.main.async {
                            strongSelf.requestDetail(forPack: added)
                        }
                    }
                }
            case.failure(let what):
                let alert = UIAlertController(
                    title: Constants.alertTitle,
                    message: what.description,
                    preferredStyle: .alert
                )
                alert.addAction(.init(title: Constants.alertButtonTitle, style: .default))
                strongSelf.present(alert, animated: true, completion: nil)
                print(what.description)
            }
        }
    }
    
    private func requestDetail(forPack pack: BasicAirport) {
        let vc = DetailViewController.storyboardInstance()
        vc.pack = pack
        navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction private func onFetchPressed(_ sender: UIButton) {
        textField.resignFirstResponder()
        digestUserInput(textField.text)
    }
    
    private lazy var viewModel: MainViewModel = {
        let vm = MainViewModel()
        vm.delegate = self
        return vm
    }()
    
    @IBOutlet private var fetchButton: UIButton!
    @IBOutlet private var textField: UITextField!
    @IBOutlet private var tableView: UITableView!
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        digestUserInput(textField.text)
        return true
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.fetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AirportCell.id, for: indexPath) as! AirportCell
        let airport = viewModel.fetchedResultsController?.object(at: indexPath)
        cell.title.text = airport?.ident
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let airport = viewModel.fetchedResultsController?.object(at: indexPath) else { return }
        if let _ = airport.report {
            let pack = BasicAirport(
                ident: airport.ident,
                report: airport.report,
                created: airport.created,
                reportUpdated: airport.reportUpdated
            )

            requestDetail(forPack: pack)
        } else {
            fetchAndShow(airport.ident)
        }
    }
}

extension MainViewController: MainViewModelDelegate {
    func controllerWillChangeContent() {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent() {
        tableView.endUpdates()
    }
    
    func controllerRequestsInsertAt(indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    func controllerRequestsDeletionAt(indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    func controllerRequestsMoveFrom(indexPath: IndexPath, to: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.insertRows(at: [to], with: .automatic)
    }
}
