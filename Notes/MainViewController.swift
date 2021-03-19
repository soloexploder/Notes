//
//  MainViewController.swift
//  TheNote
//
//  Created by MacBook on 18.03.2021.
//

import UIKit
import RealmSwift

class MainViewController: UITableViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var notes: Results<Note>!
    private var filteredNotes: Results<Note>!
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notes = realm.objects(Note.self)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredNotes.count
        } else {
            return notes.isEmpty ? 0 : notes.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TableViewCell

        var note = Note()
        
        if isFiltering {
            note = filteredNotes[indexPath.row]
        } else {
            note = notes[indexPath.row]
        }

        cell.nameLabel?.text = note.name
        cell.discriptionLabel.text = note.discription
        
        if note.imageData == nil {
            cell.imageOfNote.image = #imageLiteral(resourceName: "camera")
        } else {
            cell.imageOfNote.image = UIImage(data: note.imageData!)
        }

        cell.imageOfNote?.layer.cornerRadius = cell.imageOfNote.frame.size.height / 2
        cell.imageOfNote?.clipsToBounds = true

        return cell
    }

   // MARK: Table view delegate
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let note = notes[indexPath.row]
            StorageManager.deleteObject(note)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEdit" {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            let note: Note
            if isFiltering {
                note = filteredNotes[indexPath.row]
            } else {
                note = notes[indexPath.row]
            }
            let newNoteVC = segue.destination as! NewNoteViewController
            newNoteVC.currentNote = note
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newNoteVC = segue.source as? NewNoteViewController else { return }
        
        newNoteVC.saveNote()
        tableView.reloadData()
    }
}

extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(searchController.searchBar.text!)
    }
    
    private func filterContentForSearch(_ searchText: String) {
        
        filteredNotes = notes.filter("name CONTAINS[c] %@", searchText)
        tableView.reloadData()
    }
}


