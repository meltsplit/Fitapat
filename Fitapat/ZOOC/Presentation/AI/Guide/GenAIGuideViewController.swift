//
//  GenAIGuideViewController.swift
//  ZOOC
//
//  Created by 류희재 on 2023/08/15.
//

import UIKit
import PhotosUI

import RxSwift
import RxCocoa

final class GenAIGuideViewController : BaseViewController {
    
    //MARK: - Properties
    
    private let name: String
    private let breed: String?
    private var retryWithPet: PetResult?
    private let disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    let rootView = GenAIGuideView()
    
    let xButton = UIBarButtonItem(image: .icExit,
                                  style: .plain,
                                  target: nil,
                                  action: nil)
    
    //MARK: - Life Cycle
    
    init(
        name: String,
        breed: String?,
        retryWithPet: PetResult? = nil
    ) {
        
        self.name = name
        self.breed = breed
        self.retryWithPet = retryWithPet
        super.init(nibName: nil, bundle: nil)
        
        title = "AI 모델 생성"
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
        setNavigationBar()
    }
    
    //MARK: - Custom Method
    
    private func bindUI() {
        
        xButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.presentLeavePageAlertVC()
            })
            .disposed(by: disposeBag)
        
        rootView.selectImageButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                let needToReedGuideAlert = FapAlertViewController(.needToReedGuide)
                needToReedGuideAlert.delegate = self
                owner.present(needToReedGuideAlert, animated: false)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func setNavigationBar() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem.fixedSpace(10),
                                              xButton]
    }
}

extension GenAIGuideViewController {
    
    private func pushToGenAISelectImageVC(
        with assets: [PHAsset],
        option retryWithPet: PetResult?
    ) {
        let model = SelectedImagesModel(
            name: name,
            breed: breed,
            assets: assets,
            retryWithPet: retryWithPet
        )
        
        let selectedImageVC = DIContainer.shared.makeGenAISelectedImageVC(
            with: model
        )
        self.navigationController?.pushViewController(selectedImageVC, animated: true)
    }
    
    private func presentFapPickerViewController() {
        let pickerVC = ImagePickerViewController(viewModel: ImagePickerViewModel())
        pickerVC.modalPresentationStyle = .fullScreen
        pickerVC.delegate = self
        self.present(pickerVC, animated: true)
    }
    
    private func presentLeavePageAlertVC() {
        let alertVC = FapAlertViewController(.leaveRegisterPage)
        alertVC.delegate = self
        present(alertVC, animated: false)
    }
}

extension GenAIGuideViewController: FapAlertViewControllerDelegate {
    func leftButtonDidTap(_ alertType: FapAlertType) {
        switch alertType {
        case .leaveRegisterPage:
            dismiss(animated: true)
            navigationController?.popToRootViewController(animated: true)
        case .needToReedGuide:
            break
        default:
            return
        }
        
    }
    
    func rightButtonDidTap(_ alertType: FapAlertType) {
        switch alertType {
        case .leaveRegisterPage:
            return
        case .needToReedGuide:
            presentFapPickerViewController()
        default:
            return
        }
    }
}


extension GenAIGuideViewController : ImagePickerViewControllerDelegate {
    func picker(_ picker: ImagePickerViewController, didFinishPicking results: [PHAsset]) {
        picker.dismiss(animated: true)
        pushToGenAISelectImageVC(with: results, option: retryWithPet)
    }
}
