//
//  MethodsViewController.swift
//  UIComponents
//
//  Created by Sagar Ajudiya on 28/06/23.
//

import UIKit
import Alamofire

class MethodsViewController: BaseViewController {

    // MARK: Variables
    var viewModel = MethodsViewModel()
    
    // MARK: IBOutlets
    @IBOutlet weak var imgURL: UIImageView!
    @IBOutlet weak var pvLine: UIProgressView!
    @IBOutlet weak var lblProgress: UILabel!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var avIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imgUpload: UIImageView!
    @IBOutlet weak var btnUpload: UIButton!
    @IBOutlet weak var btnPickImage: UIButton!
    @IBOutlet weak var tfURL: UITextField!
    @IBOutlet weak var lblUploadProgress: UILabel!
    
    // MARK: View Controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }
    
    // MARK: SetUp Views
    private func setupViews() {
        pvLine.progress = 0
        avIndicator.isHidden = true
        lblUploadProgress.text = ""
    }
    
    // MARK: Bind ViewModel
    private func bindViewModel() {
        viewModel.progress.bind({ progress in
            DispatchQueue.main.async { [weak self] in
                self?.lblUploadProgress.text = "Uploading..."
                self?.lblUploadProgress.text = "\(progress)"
            }
        })

    }
    
    private func openPickerView(_ sender: UIView) {
        ImagePickerHelper.shared.pick(sender, viewController: self, completionHandler: { [weak self] (image, _) in
            if let image {
                    self?.imgUpload.image = image
            }
        }, cancelHandler: { [weak self] in
            guard self != nil else { return }
        })
    }
    
    // MARK: IBActions
    @IBAction func btnDownloadTapped(_ sender: Any) {
        viewModel.downloadData(url: tfURL.text ?? "", delegate: self)
        avIndicator.isHidden = false
        avIndicator.startAnimating()
        imgURL.image = nil
        pvLine.progress = 0
    }
    
    @IBAction func btnPickImageTapped(_ sender: UIButton) {
        openPickerView(sender)
    }
    
    @IBAction func btnUploadTapped(_ sender: UIButton) {
        viewModel.uploadData(image: imgUpload)
    }
    
}

// MARK: Extension MethodsViewController
extension MethodsViewController: URLSessionDownloadDelegate {

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let data = try? Data(contentsOf: location) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.imgURL.image = UIImage(data: data)
            self.avIndicator.stopAnimating()
            self.avIndicator.isHidden = true
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.pvLine.setProgress(progress, animated: true)
            self.lblProgress.text = "\(progress * 100)%"
        }
    }

}
