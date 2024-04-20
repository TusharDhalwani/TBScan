import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
    }
    
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        // Load the sample image from the project
        guard let image = UIImage(named: "test_img.png") else {
            fatalError("Failed to load image")
        }
        print("Image loaded successfully")
        
        imageView.image = image
        resultLabel.text = "Analyzing Image..."
        
        if let ciImage = CIImage(image: image) {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                let model = try VNCoreMLModel(for: tuberculosis_detection_().model)
                let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                    guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                        self?.resultLabel.text = "Prediction failed"
                        return
                    }
                    self?.resultLabel.text = "\(topResult.identifier) (Confidence: \(topResult.confidence))"
                }
                try handler.perform([request])
            } catch {
                resultLabel.text = "Error: \(error.localizedDescription)"
            }
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
