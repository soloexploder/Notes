//
//  NewNoteViewController.swift
//  Notes
//
//  Created by MacBook on 18.03.2021.
//

import UIKit

class NewNoteViewController: UITableViewController {
    
    var currentNote: Note?
    var imageIsChanged = false
    
    @IBOutlet var noteImage: UIImageView!
    @IBOutlet var noteName: UITextField!
    @IBOutlet var noteDiscription: UITextField!
    
    @IBOutlet var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        saveButton.isEnabled = false
        noteName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }
    
    // MARK: table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let cameraIcon = #imageLiteral(resourceName: "camera")
            let photoIcon = #imageLiteral(resourceName: "photo")
            
            let actionSheet = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) {_ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            
            let photo = UIAlertAction(title: "Photo", style: .default) {_ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        } else {
            view.endEditing(true)
        }
    }
    
    func saveNote() {
        let newNote = Note()
        var image: UIImage?
        
        if imageIsChanged {
            image = noteImage.image
        } else {
            image = #imageLiteral(resourceName: "photo")
        }
        
        let imageData = image?.pngData()
        
        newNote.name = noteName.text!
        newNote.discription = noteDiscription.text
        newNote.imageData = imageData
        
        if currentNote != nil {
            try! realm.write {
                currentNote?.name = newNote.name
                currentNote?.discription = newNote.discription
                currentNote?.imageData = newNote.imageData
            }
        } else {
            StorageManager.saveObject(newNote)
        }
    }
    
    private func setupEditScreen() {
        if currentNote != nil {
            setupNavigationBar()
            imageIsChanged = true
            
            guard let data = currentNote?.imageData, let image = UIImage(data: data) else { return }
            
            noteImage.image = image
            noteImage.contentMode = .scaleAspectFill
            noteName.text = currentNote?.name
            noteDiscription.text = currentNote?.discription
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = nil
        title = currentNote?.name
        saveButton.isEnabled = true
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}

// MARK: Text field delegate
extension NewNoteViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func textFieldChanged() {
        if noteName.text?.isEmpty == false{
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
}

// MARK: work with image
extension NewNoteViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        noteImage.image = info[.editedImage] as? UIImage
        noteImage.contentMode = .scaleAspectFill
        noteImage.clipsToBounds = true
        
        imageIsChanged = true
        
        dismiss(animated: true)
    }
}





