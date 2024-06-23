//
//  EditProfileViewController.swift
//  ZOOC
//
//  Created by 류희재 on 2023/01/04.
//

import UIKit

import RxSwift
import RxCocoa

final class MyEditProfileViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let viewModel: MyEditProfileViewModel
    private let disposeBag = DisposeBag()
    
    private let nameTextFieldDidChangeEventSubject = BehaviorRelay<String>(value: "")
    private let breedTextFieldDidChangeEventSubject = BehaviorRelay<String?>(value: nil)
    private let profileImageChangeEventSubject = BehaviorRelay<Data?>(value: nil)
    
    //MARK: - Life Cycle
    
    init(viewModel: MyEditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UIComponents
    
    private lazy var rootView = MyEditProfileView()
    
    private var galleryAlertController: GalleryAlertController {
        let galleryAlertController = GalleryAlertController()
        galleryAlertController.delegate = self
        return galleryAlertController
    }
    
    private lazy var imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        return imagePickerController
    }()
    
    //MARK: - Life Cycle
    
    override func loadView() {
        self.view = rootView
        self.title = "프로필 수정"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addNotification()
        dismissKeyboardWhenTappedAround(cancelsTouchesInView: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeKeyboardNotifications()
    }
    
    //MARK: - Custom Method
    
    private func bindUI() {
        rootView.profileImageButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                owner.present(owner.galleryAlertController,animated: true)
                owner.rootView.updateEditButtonUI(owner.rootView.nameTextField.text!.count > 0)
            }).disposed(by: disposeBag)
        
        rootView.nameTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(with: self, onNext: { owner, name in
                owner.nameTextFieldDidChangeEventSubject.accept(name)
                owner.rootView.updateNameTextField(name)
                owner.rootView.updateEditButtonUI(name.count > 0)
            }).disposed(by: disposeBag)
        
        rootView.breedTextField.rx.text
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: nil)
            .drive(with: self, onNext: { owner, breed in
                owner.breedTextFieldDidChangeEventSubject.accept(breed)
                owner.rootView.updateBreedTextField(breed)
                owner.rootView.updateEditButtonUI(owner.rootView.nameTextField.text!.count > 0)
            }).disposed(by: disposeBag)
        
        rootView.editButton.rx.tap
            .throttle(.seconds(2), scheduler: MainScheduler.instance)
            .map { self.nameTextFieldDidChangeEventSubject.value }
            .filter { $0 == "" }
            .subscribe(with: self, onNext: { owner, _ in
                owner.showToast("필수 정보를 입력해주세요!")
            }).disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let input = MyEditProfileViewModel.Input(
            viewWillAppearEvent: rx.viewWillAppear.asObservable(),
            nameTextFieldDidChangeEvent: nameTextFieldDidChangeEventSubject.asObservable(),
            breedTextFieldDidChangeEvent: breedTextFieldDidChangeEventSubject.asObservable(),
            profileImageDidChangeEvent: profileImageChangeEventSubject.asObservable(),
            editButtonTapEvent: rootView.editButton.rx.tap
                .throttle(.seconds(2), scheduler: MainScheduler.instance)
                .asObservable()
        )
        
        let output = self.viewModel.transform(from: input, disposeBag: self.disposeBag)
        
        output.petResult
            .asDriver(onErrorJustReturn: PetResult())
            .drive(with: self, onNext: { owner, pet in
                owner.rootView.updateUI(pet)
                owner.nameTextFieldDidChangeEventSubject.accept(pet.name)
                owner.breedTextFieldDidChangeEventSubject.accept(pet.breed)
            }).disposed(by: disposeBag)
        
        output.showToast
            .asDriver(onErrorJustReturn: "")
            .drive(with: self, onNext: { owner, message in
                owner.showToast(message)
            }).disposed(by: disposeBag)
        
        output.isEdited
            .asDriver(onErrorJustReturn: Void())
            .drive(with: self, onNext: { owner, _ in
                owner.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
    }
}

//MARK: - GalleryAlertControllerDelegate

extension MyEditProfileViewController: GalleryAlertControllerDelegate {
    func galleryButtonDidTap() {
        present(imagePickerController, animated: true)
    }
    
    func deleteButtonDidTap() {
        let defaultProfile: UIImage = .defaultProfile
        profileImageChangeEventSubject.accept(defaultProfile.jpegData(compressionQuality: 1.0))
        rootView.updateProfileImageButtonUI(nil)
    }
}

//MARK: - UIImagePickerControllerDelegate

extension MyEditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            rootView.profileImageButton.setImage(image, for: .normal)
            profileImageChangeEventSubject.accept(image.jpegData(compressionQuality: 1.0) ?? nil)
        }
        dismiss(animated: true)
    }
}

// 신성한 VC를 더렵혀서 죄송합니ㅏ 죄송합니다 죄송합니다ㅏ...
extension MyEditProfileViewController {
    
    private func addNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification ,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification){
        
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: duration){
            self.rootView.editButton.snp.updateConstraints {
                $0.bottom.equalToSuperview().inset(keyboardHeight - 20)
            }
            self.view.layoutIfNeeded()
        }
        
        let contentInsets = UIEdgeInsets(top: 0.0,
                                         left: 0.0,
                                         bottom: 36,
                                         right: 0.0)
                
        rootView.scrollView.contentInset = contentInsets
                
        
    }
    
    
    @objc
    private func keyboardWillHide(notification: NSNotification){
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        UIView.animate(withDuration: duration){
            self.rootView.editButton.snp.updateConstraints {
                $0.bottom.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
        rootView.scrollView.contentInset = .zero
    }
}
