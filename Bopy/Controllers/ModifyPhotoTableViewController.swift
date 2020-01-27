//
//  ModifyPhotoTableViewController.swift
//  Bopy
//
//  Created by bojack on 2020/1/1.
//  Copyright © 2020 bojack. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase


class ModifyPhotoTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var damageTypeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var keyTextField: UITextField!
    var photodDate: String?
    let damages = ["裂痕", "植物破壞"]
    var picker = UIPickerView()
    var ref: DatabaseReference! = Database.database().reference()
    var storageRef = Storage.storage().reference()
    var dataCell: PhotoCollectionViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        picker.delegate = self
        picker.dataSource = self
        damageTypeTextField.inputView = picker
        
        self.navigationItem.title = "Edit photos"
        
        //
        // load data from picked data cell from previous page
        //
        if let previousDataCell = dataCell {
            
            if let imageURLString = previousDataCell.imageThumbnailURLText {
                let request = URLRequest(url: URL(string: imageURLString)!)
                let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
                    if error != nil {
                        print("Download Image Task Fail: \(error!.localizedDescription)")
                    } else if let imageData = data {
                        DispatchQueue.main.async {
                            self.imageView.image = UIImage(data: imageData)
                        }
                    }
                }
                task.resume()
            }
            
            if let keyText = previousDataCell.keyText {
                keyTextField.text = keyText
            }
            
            if let locationText = previousDataCell.locationText {
                locationTextField.text = locationText
            }
            
            if let descriptionText = previousDataCell.descriptionText {
                descriptionTextField.text = descriptionText
            }
            
            if let damageTypeText = previousDataCell.damageTypeText {
                damageTypeTextField.text = damageTypeText
            }
            
            if let dateText = previousDataCell.dateText {
                photodDate = dateText
            }
        }
    }
    
    // MARK: - Picker selector
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return damages.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return damages[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.damageTypeTextField.text = damages[row]
    }
    
    // MARK: - Submit modification
    @IBAction func EditFinishAction(_ sender: Any) {
        confirmAndSubmit()
    }
    
    func updateData() {
        let key = keyTextField.text
        
        if let location = locationTextField!.text,
           let description = descriptionTextField!.text,
           let damage = damageTypeTextField!.text {
            self.ref.child("Damages/\(key!)/location").setValue(location)
            self.ref.child("Damages/\(key!)/description").setValue(description)
            self.ref.child("Damages/\(key!)/damage").setValue(damage)
        }
        
    }
    
    func confirmAndSubmit() {
        let checker = UIAlertController(title: "編輯完成", message: "確定要上傳編輯資料嗎？", preferredStyle: .alert)
        checker.addAction(UIAlertAction(title: "Ok", style: .default,
                                     handler: { (action: UIAlertAction!) in
            print("Uploading data to Firebase")
            self.updateData()
            
            // present the checker if upload image sucessfully
            let checker = UIAlertController(title: "上傳完成", message: "圖片上傳完成", preferredStyle: .alert)
            checker.addAction(UIAlertAction(title: "Ok", style: .default,
                                         handler: { (action: UIAlertAction!) in
                    // move to the main page
                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PhotoCollectionRoot")
                    let navigationController = UINavigationController(rootViewController: vc)
                    self.present(navigationController, animated: true, completion: nil)
                }))
                self.present(checker, animated: true, completion: nil)
            }))

        checker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        present(checker, animated: true, completion: nil)
    }
    
    // MARK: - Remove data from database
    @IBAction func RemoveDataAction(_ sender: Any) {
        confirmAndRemove()
    }
    
    func confirmAndRemove() {
        let checker = UIAlertController(title: "刪除資料", message: "確定要刪除資料嗎？", preferredStyle: .alert)
        checker.addAction(UIAlertAction(title: "Ok", style: .default,
                                     handler: { (action: UIAlertAction!) in
            // remove image from storage
            if let date = self.photodDate,
               let key = self.keyTextField.text {
                let imageFilename = "\(date)/\(key).png"
                let thumbnailFilename = "\(date)/\(key)_thumbnail.png"
                
                let imageRef = self.storageRef.child(imageFilename)
                imageRef.delete { error in
                  if let error = error {
                    print("Error occur during cleaning \(imageFilename): \(error)")
                  } else {
                    print("Successfully clean the image \(imageFilename)")
                  }
                }
                
                let thumbnailRef = self.storageRef.child(thumbnailFilename)
                thumbnailRef.delete { error in
                  if let error = error {
                    print("Error occur during cleaning \(thumbnailFilename): \(error)")
                  } else {
                    print("Successfully clean the image \(thumbnailFilename)")
                  }
                }
            }
            
            // remove data from data ref
            if let key = self.keyTextField.text {
                let dataRef = self.ref.child("Damages").child(key)
                dataRef.removeValue { error, _ in
                    if let error = error {
                        print("Error occur during cleaning Damages/\(key): \(error)")
                    } else {
                        print("Successfully clean the image Damages/\(key)")
                    }
                }
            }
                                        
            // move to the main page
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "PhotoCollectionRoot")
            let navigationController = UINavigationController(rootViewController: vc)
            self.present(navigationController, animated: true, completion: nil)
        }))

       checker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
           print("Handle Cancel Logic here")
       }))
       present(checker, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
