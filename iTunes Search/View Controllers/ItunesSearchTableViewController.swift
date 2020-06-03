//
//  ItunesSearchTableViewController.swift
//  iTunes Search
//
//  Created by Spencer Curtis on 8/5/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ItunesSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    var searchResults = [SearchResult]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchTerm = searchBar.text,
            searchTerm != "" else { return }
        
        var resultType: ResultType!
        
        switch resultTypeSegmentedControl.selectedSegmentIndex {
        case 0:
            resultType = .software
        case 1:
            resultType = .musicTrack
        case 2:
            resultType = .movie
        default:
            break
        }
        
        searchResultController.performSearch(for: searchTerm, resultType: resultType, urlSession: URLSession.shared) { result in
            
            switch result {
            case .success(let searchResultsArray):
                DispatchQueue.main.async {
                    self.searchResults = searchResultsArray
                    // ABC of UI elements, Always Be on the Main Queue
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
                
                switch error {
                case .invalidStatNoErrorButNoData:
                    break
                case .invalidJSON(let jsonError):
                    break
                case .network(let networkError):
                    break
                case .requestURLisNil:
                    break
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        
        let searchResult = searchResults[indexPath.row]
        
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.artist
        
        return cell
    }
    
    
    let searchResultController = SearchResultController()
    
    @IBOutlet weak var resultTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
}
