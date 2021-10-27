//
//  MainViewModel.swift
//  ForeFlightClone
//
//  Created by Logan Blevins on 9/20/21.
//

import Foundation
import CoreData
import Combine

protocol MainViewModelDelegate: AnyObject {
    func controllerWillChangeContent()
    func controllerDidChangeContent()
    func controllerRequestsInsertAt(indexPath: IndexPath)
    func controllerRequestsDeletionAt(indexPath: IndexPath)
    func controllerRequestsMoveFrom(indexPath: IndexPath, to: IndexPath)
}

final class MainViewModel: NSObject {
    weak var delegate: MainViewModelDelegate?
    
    init(api: API = WeatherAPI(), model: Persistence = Persistence()) {
        self.api = api
        self.model = model
    }
    
    func initializePersistence() {
        model.initialize { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.fetchedResultsController = strongSelf.model.fetchedResultsController()
            strongSelf.fetchedResultsController?.delegate = strongSelf
            try? strongSelf.fetchedResultsController?.performFetch()
            
            if strongSelf.fetchedResultsController?.fetchedObjects?.isEmpty ?? true {
                strongSelf.insertInitialData()
            }
            
            strongSelf.beginUpdating()
        }
    }
    
    func beginUpdating() {
        guard workOp == nil else { return }
        
        print("starting")
        
        #if DEBUG
            let intervalSeconds = 5
        #else
            let intervalSeconds = 60
        #endif
        
        let fireDelay = OperationQueue.SchedulerTimeType.Stride.seconds(1)
        let interval = OperationQueue.SchedulerTimeType.Stride.seconds(intervalSeconds)
        let tolerance = OperationQueue.SchedulerTimeType.Stride.seconds(intervalSeconds / 2)
        let fire = OperationQueue.SchedulerTimeType(Date()).advanced(by: fireDelay)
        
        opQueue = OperationQueue()
        workOp = opQueue?.schedule(after: fire, interval: interval, tolerance: tolerance) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.work()
        }
    }
    
    // I received a friendly warning from Xcode suggesting that when the table view is out of view (inside detail view),
    // we might want to consider not updating the table view. This happens because the background worker
    // refreshes our objects in the store, notifying the fetched results controller about the changes.
    // The fetched results controller tells our table view about the changes even though it isn't in view.
    // To resolve this, we stop background updates when the table view is not in view.
    // Once back in view, we start updates again as normal.
    func stopUpdating() {
        workOp?.cancel()
        workOp = nil
        
        print("stopping")
    }
    
    func fetchWeatherAsync(for ident: String, completion: @escaping (FFResult) -> ()) {
        api.fetchWeather(forIdent: ident, completion: completion)
    }
    
    func addAirportAsync(byIdent: String, json: JSON, completion: ((BasicAirport?) -> ())? = nil) {
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            completion?(nil)
            return
        }
        
        model.backgroundCtx.perform { [weak self] in
            guard let strongSelf = self else { return }
            
            let airport = Airport(context: strongSelf.model.backgroundCtx)
            airport.reportUpdated = Date()
            airport.report = String(data: data, encoding: .utf8)
            airport.ident = byIdent
            
            let pack = BasicAirport(
                ident: airport.ident,
                report: airport.report ?? "",
                created: airport.created,
                reportUpdated: airport.reportUpdated ?? Date()
            )
            strongSelf.model.save(ctx: strongSelf.model.backgroundCtx)
            completion?(pack)
        }
    }
    
    private func insertInitialData() {
        model.backgroundCtx.perform { [weak self] in
            guard let strongSelf = self else { return }
            
            for ident in Constants.initialIdents {
                let airport = Airport(context: strongSelf.model.backgroundCtx)
                airport.ident = ident
            }
            strongSelf.model.save(ctx: strongSelf.model.backgroundCtx)
        }
    }
    
    // Enclosed network request and JSONSerialization operations in autoreleasepool
    // to ensure that the Data objects are released in quicker intervals
    private func work() {
        model.backgroundCtx.perform { [weak self] in
            guard let strongSelf = self else { return }
            let request = Airport.fetchRequest()
            if let airports = try? strongSelf.model.backgroundCtx.fetch(request) {
                for airport in airports {
                    autoreleasepool {
                        strongSelf.api.fetchWeather(forIdent: airport.ident) { result in
                            switch result {
                            case .success(let json):
                                strongSelf.model.backgroundCtx.perform {
                                    autoreleasepool {
                                        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
                                            return
                                        }
                                        
                                        airport.report = String(data: data, encoding: .utf8)
                                        airport.reportUpdated = Date()
                                        strongSelf.model.save(ctx: strongSelf.model.backgroundCtx)
                                        print("Updated: \(airport.ident)")
                                    }
                                }
        
                            case.failure(let what):
                                print(what.description)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Take advantage of concurrent network requests
    private var workOp: Cancellable?
    private var opQueue: OperationQueue?
    
    private(set) var fetchedResultsController: NSFetchedResultsController<Airport>?
    
    // We could mock a fake requestor for unit tests if time allowed
    private let api: API
    private let model: Persistence
}

// Keep the architecture loosely coupled
extension MainViewModel: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerWillChangeContent()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.controllerDidChangeContent()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let indexPath = newIndexPath else { break }
            delegate?.controllerRequestsInsertAt(indexPath: indexPath)
        case .delete:
            guard let indexPath = indexPath else { break }
            delegate?.controllerRequestsDeletionAt(indexPath: indexPath)
        case .move:
            guard let oldIndexPath = indexPath, let newIndexPath = newIndexPath else { break }
            delegate?.controllerRequestsMoveFrom(indexPath: oldIndexPath, to: newIndexPath)
        case .update:
            // Don't think there is anything to do here yet...
            break
        @unknown default:
            fatalError()
        }
    }
}
