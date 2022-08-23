//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Neo on 19.08.2022.
//

import UIKit
import CoreData

class DetailsVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    var selectedPaintID : UUID!
    var choosed = false
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if choosed == true{
            saveButton.isHidden = true
            saveButton.isEnabled = false
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            
            let idString = selectedPaintID.uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String{
                         
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int{
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                            
                    }
                }
            }
            
            catch{
                
            }
            }
            
        else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            
            let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
            view.addGestureRecognizer(gestureRecognizer)
            
            imageView.isUserInteractionEnabled = true
            imageView.addGestureRecognizer(imageTapRecognizer)
            
        }
        
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
       
               
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text, forKey: "artist")

        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        
        newPainting.setValue(data, forKey: "image")
        
        
        do{
            try
                context.save()
                print("saved")
            
        }
        catch{
            print("error")
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true,completion: nil)
        
    }
    
}
