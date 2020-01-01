//
//  AddPhotoTableViewController.swift
//  Bopy
//
//  Created by bojack on 2019/12/20.
//  Copyright © 2019 bojack. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class AddPhotoTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var damageTypeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    let damages = ["裂痕","植物性破壞"]
    var picker = UIPickerView()
    var ref: DatabaseReference! = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        picker.delegate = self
        picker.dataSource = self
        damageTypeTextField.inputView = picker
        
        self.navigationItem.title = "Add photos";
    }

    // MARK: - submit logic
    @IBAction func submitDataAction(_ sender: Any) {
        if locationTextField.text == "" || descriptionTextField.text == "" || damageTypeTextField.text == "" {
            incompleteDataWarning()
        } else {
            print("========== the data will be submitted ==========")
            print("locationTextField: ", locationTextField.text!)
            print("descriptionTextField: ", descriptionTextField.text!)
            print("damageTypeTextField: ", damageTypeTextField.text!)
            print("===============================================")
            confirmAndSubmit()
        }
    }
    
    func incompleteDataWarning() {
        let incompleteDataAlert = UIAlertController(title: "Error",
                       message: "請檢查地點、描述和問題種類", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        incompleteDataAlert.addAction(defaultAction)
        self.present(incompleteDataAlert, animated: true, completion: nil)
    }
    
    func confirmAndSubmit() {
        let checker = UIAlertController(title: "編輯完成", message: "確定要上傳編輯資料嗎？", preferredStyle: .alert)
        checker.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("Uploading data to Firebase")
            self.uplaodData()
        }))

        checker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        present(checker, animated: true, completion: nil)
    }
    
    // MARK: - upload data by date
    func uplaodData() {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = Date()
        let dateString = dateFormatter.string(from: date)
        
        //
        // upload: full-sized image, thumbnail image and structural data
        //
        if let selectedImage: UIImage = imageView.image?.fixedOrientation()?.resizeImage(newWidth: 1000) {
            let uniqueString = NSUUID().uuidString
            
            // upload full-sized image
            var storageRef = Storage.storage().reference().child(dateString).child("\(uniqueString).png")
            if let uploadData = selectedImage.pngData() {
                storageRef.putData(uploadData, metadata: nil, completion: { (data, error) in
                    if error != nil {
                        print("Error: \(error!.localizedDescription)")
                        return
                    }
                    (storageRef.child("")).downloadURL(completion: { (url, error) in
                        if error != nil {
                            print("Error: \(error!.localizedDescription)")
                            return
                        } else if url != nil {
                            // get the URL if it is available
                            print("URL: ", url!.absoluteString)
                            self.uploadURLData(key: uniqueString, urlKey: "imageURL", urlValue: url!.absoluteString)
                            print("Upload full-sized image successfully!")
                            
                            // present the checker if upload image sucessfully
                            let checker = UIAlertController(title: "上傳完成", message: "圖片上傳完成", preferredStyle: .alert)
                            checker.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                                    // move to the main page
                                    let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc = storyboard.instantiateViewController(withIdentifier: "PhotoCollectionRoot")
                                    let navigationController = UINavigationController(rootViewController: vc)
                                    self.present(navigationController, animated: true, completion: nil)
                                }))
                            self.present(checker, animated: true, completion: nil)
                        }
                    })
                })
            } // upload full-sized image
            
            // upload thumb nail image
            let selectedImageThumbnail = selectedImage.resizeImage(newWidth: 200)!
            storageRef = Storage.storage().reference().child(dateString).child("\(uniqueString)_thumbnail.png")
            if let uploadData = selectedImageThumbnail.pngData() {
                storageRef.putData(uploadData, metadata: nil, completion: { (data, error) in
                    if error != nil {
                        print("Error: \(error!.localizedDescription)")
                        return
                    }
                    (storageRef.child("")).downloadURL(completion: { (url, error) in
                        if error != nil {
                            print("Error: \(error!.localizedDescription)")
                            return
                        } else if url != nil {
                            // get the URL if it is available
                            print("URL: ", url!.absoluteString)
                            self.uploadURLData(key: uniqueString, urlKey: "imageThumbnailURL", urlValue: url!.absoluteString)
                            print("Upload thumbnail image successfully!")
                        }
                    })
                })
            } // upload thumbnail image

            // update text data
            self.uploadTextData(key: uniqueString, date: dateString)
            print("Upload text data successfully!")
        }
    } // uplaodData

    func uploadURLData(key: String, urlKey:String, urlValue: String) {
        self.ref.child("Damages/\(key)/\(urlKey)").setValue(urlValue)
    }
    
    func uploadTextData(key: String, date: String) {
        if let location = locationTextField!.text,
           let description = descriptionTextField!.text,
           let damage = damageTypeTextField!.text {
               self.ref.child("Damages/\(key)/location").setValue(location)
               self.ref.child("Damages/\(key)/description").setValue(description)
               self.ref.child("Damages/\(key)/damage").setValue(damage)
               self.ref.child("Damages/\(key)/date").setValue(date)
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
    
    // MARK: - Table view
    @IBAction func takePictureAction(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // select the photo from album
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                present(imagePicker, animated: true, completion: nil)
            }
        }
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                return
            }
        imageView.image = image
        dismiss(animated:true, completion: nil)
    }
    
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
