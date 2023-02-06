//
//  ViewController.swift
//  MathTrainingGame
//
//  Created by Yanunsey on 14/12/22.
//

import UIKit
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var drawingImageView: DrawingImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var questionFactory = QuestionFactory()
    var mnistModel : MnistModel?
    
    var gameTimer : Timer!
    var totalTime = 60
    var timeLeft : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureAppearance()
        configureTableView()
        drawingImageView.delegate = self
        mnistModel = try? MnistModel(configuration: MLModelConfiguration())
        configureTimer()
    }

    func configureTimer() {
        timeLeft = totalTime
        self.progressView.progress = 1.0
        self.progressView.progressTintColor = UIColor.green
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.timeLeft -= 1
            self.progressView.progress = Float(max(self.timeLeft,0)) / Float(self.totalTime)
            
            let greenValue = CGFloat(Float(self.timeLeft)/Float(self.totalTime))
            
            let redValue = 1.0 - greenValue
            
            self.progressView.progressTintColor = UIColor(red: redValue, green: greenValue, blue: 0.2, alpha: 1.0)
        })
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "QuestionCell", bundle: nil), forCellReuseIdentifier: "QuestionCell")
    }
    
    func configureAppearance(){
        tableView.layer.cornerRadius = 12
        drawingImageView.layer.cornerRadius = 12
    }
    
    func askNextQuestion() {
        
        if timeLeft > 0 {
            drawingImageView.image = nil
            
            questionFactory.addNewQuestion()
            
            let newIndexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .right)
            
            let secondIndexPath = IndexPath(row: 1, section: 0)
            
            if let cell = tableView.cellForRow(at: secondIndexPath) as? QuestionCell {
                if let secondQuestion = questionFactory.getQuestionAt(position: secondIndexPath.row) {
                    cell.bind(at: secondIndexPath, to: secondQuestion)
                }
            }
        } else {
            gameTimer.invalidate()
            let controller = UIAlertController(title: "Fin de la partida", message: "Has conseguido \(questionFactory.score) / \(self.questionFactory.pointsPerQuestion * self.questionFactory.numberOfQuestions()) puntos.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Jugar otra más", style: .default) { action in
                self.drawingImageView.image = nil
                self.restartGame()
            }
            controller.addAction(action)
            present(controller, animated: true)
        }
        
    }
    
    func restartGame(){
        questionFactory.restartData()
        self.tableView.reloadData()
        configureTimer()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionFactory.numberOfQuestions()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath) as! QuestionCell
        if let currentQuestion = questionFactory.getQuestionAt(position: indexPath.row){
            cell.bind(at: indexPath, to: currentQuestion)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 
    }
}

extension ViewController: DrawingImageViewDelegate {
    func numberDrawn(_ resulImage: UIImage) {
        
        //1. Resize user image to 299x299 image (size expected by model).
        let modelSize = 299
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: modelSize, height: modelSize), true, 1.0)
        
        resulImage.draw(in: CGRect(x: 0, y: 0, width: modelSize, height: modelSize))
        
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return }
        
        UIGraphicsEndImageContext()
        
        //2. UIImage -> CIImage
        guard let ciImage = CIImage(image: newImage) else { return }
        
        //3. Creating a Vision instance using the image classifier's model instance.
        guard let mnistModel =  mnistModel else { return }
        guard let model = try? VNCoreMLModel(for: mnistModel.model) else { return }
        
        //4. VNCoreML Request
        let request = VNCoreMLRequest(model: model) { [weak self] (vnRequest, error) in
            //5. Retrieve the request’s results
            guard let results = vnRequest.results as? [VNClassificationObservation], let prediction = results.first else {
                print(error?.localizedDescription as Any)
                return
            }
            
            
            DispatchQueue.main.async {
                
                let result = Int(prediction.identifier) ?? 0
                print(result)
                
                self?.questionFactory.updateQuestion(at: 0, with: result)
                
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                
                self?.questionFactory.validateQuestion(at: 0)
            
                self?.askNextQuestion()
            }
        }
        request.usesCPUOnly = true
        //6. VNImageRequestHandler:An object that processes one or more image analysis requests pertaining to a single image.
        let handler = VNImageRequestHandler(ciImage: ciImage)
        

        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print (error.localizedDescription)
            }
        }
    }
}



