//
//  ImagePickerView.swift
//  ZOOC
//
//  Created by 장석우 on 4/10/24.
//


import UIKit
import PhotosUI

import SnapKit
import Then


final class ImagePickerView: UIView {
    
    //MARK: - Properties
    
    private var isAlbumViewPresented = true {
        didSet {
            showAlbumView(isAlbumViewPresented)
        }
    }
    
    //MARK: - UI Components
    
    lazy var unauthorizedView = ImagePickerUnauthorizedView()
    
    private let topView = UIView()
    let albumButton = UIButton()
    let xButton = UIButton()
    private let descriptionLabel = BasePaddingLabel(padding: 5)
    let confirmButton = UIButton()
    
    private let albumFlowLayout = UICollectionViewFlowLayout()
    lazy var albumCollectionView = UICollectionView(frame: .zero,
                                                    collectionViewLayout: albumFlowLayout)
    
    private let photoFlowLayout = UICollectionViewFlowLayout()
    lazy var photoCollectionView = UICollectionView(frame: .zero,
                                                    collectionViewLayout: photoFlowLayout)
    
    private let selectedPhotoFlowLayout = UICollectionViewFlowLayout()
    lazy var selectedPhotoCollectionView = UICollectionView(frame: .zero,
                                                    collectionViewLayout: selectedPhotoFlowLayout)
    
    //MARK: - Life Cycle
    
    init() {
        super.init(frame: .zero)
        
        style()
        hierarchy()
        layout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK: - UI & Layout

private extension ImagePickerView {
    
    func style() {
        
        self.backgroundColor = .zw_background
        
        topView.do {
            $0.backgroundColor = .zw_background
        }
        
        albumButton.do {
            var config = UIButton.Configuration.plain()
            config.image = .icDropdown
                .withTintColor(.zw_black)
                .applyingSymbolConfiguration(.init(pointSize: 10))
            config.imagePadding = 1
            config.imagePlacement = .trailing
            config.titleLineBreakMode = .byTruncatingTail
            
            $0.backgroundColor = .clear
            $0.configuration = config
        }
        
        xButton.do {
            $0.setImage(.btnX.withTintColor(.zw_black), for: .normal)
            $0.contentMode = .scaleAspectFit
        }
        
        confirmButton.do {
            $0.isEnabled = false
            $0.setTitle("0/15 완료", for: .normal)
            $0.titleLabel?.font = .pretendard(font: .bold, size: 18)
            $0.setTitleColor(.zw_gray, for: .disabled)
            $0.setTitleColor(.zw_black, for: .normal)
        }
        
        descriptionLabel.do {
            $0.text = "8~15장의 사진을 선택해 주세요."
            $0.textAlignment = .center
            $0.font = .zw_Body2
            $0.textColor = .zw_white
            $0.backgroundColor = .zw_point
        }
        
        albumCollectionView.do {
            $0.bounces = false
            $0.allowsMultipleSelection = true
            $0.alwaysBounceVertical = true
            $0.backgroundColor = .zw_brightgray
            $0.register(AlbumCollectionViewCell.self,
                        forCellWithReuseIdentifier: AlbumCollectionViewCell.reuseCellIdentifier)
        }
        
        photoCollectionView.do {
            $0.register(PhotoCollectionViewCell.self,
                        forCellWithReuseIdentifier: PhotoCollectionViewCell.reuseCellIdentifier)
            $0.allowsMultipleSelection = true
            $0.alwaysBounceVertical = true
            $0.backgroundColor = .zw_background
        }
        
        selectedPhotoCollectionView.do {
            $0.register(SelectedPhotoCollectionViewCell.self,
                        forCellWithReuseIdentifier: SelectedPhotoCollectionViewCell.reuseCellIdentifier)
            $0.showsHorizontalScrollIndicator = false
            $0.backgroundColor = .zw_background
        }
        
    }
    
    func hierarchy() {
        addSubviews(
            topView,
            descriptionLabel,
            selectedPhotoCollectionView,
            photoCollectionView,
            albumCollectionView
        )
        
        topView.addSubviews(
            xButton,
            albumButton,
            confirmButton
        )
        
        
        bringSubviewToFront(topView)
        addSubview(unauthorizedView)
    }
    
    func layout() {
        
        albumFlowLayout.do {
            $0.itemSize.height = 80.adjusted
            $0.itemSize.width = Device.width
            $0.minimumLineSpacing = 1
        }
        
        photoFlowLayout.do {
            let spacing = 2.0
            let length = (Device.width - spacing * 2 ) / 3
            
            $0.itemSize = CGSize(width: length, height: length)
            
            $0.minimumLineSpacing = spacing
            $0.minimumInteritemSpacing = spacing
            $0.sectionInset = .init(top: spacing,
                                    left: 0,
                                    bottom: spacing,
                                    right: 0)
        }
        
        selectedPhotoFlowLayout.do {
            let spacing = 2.0
            $0.scrollDirection = .horizontal
            $0.itemSize = CGSize(width: 70, height: 70)
            
            $0.minimumLineSpacing = 8
            $0.sectionInset = .init(top: 0,
                                    left: 18,
                                    bottom: 0,
                                    right: 18)
        }
        
        topView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        }
        
        xButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
            $0.size.equalTo(42)
        }
        
        albumButton.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(confirmButton.snp.leading).offset(-5)
        }

        confirmButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        confirmButton.setContentHuggingPriority(.required, for: .horizontal)
        confirmButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(18)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        selectedPhotoCollectionView.snp.remakeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        photoCollectionView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        albumCollectionView.snp.makeConstraints {
            $0.top.equalTo(topView.snp.bottom).offset(-1)
            $0.bottom.equalTo(topView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
        }
        
        unauthorizedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func showAlbumView(_ show: Bool) {
        
        if show {
            albumCollectionView.snp.remakeConstraints {
                $0.top.equalTo(topView.snp.bottom)
                $0.horizontalEdges.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        } else {
            albumCollectionView.snp.remakeConstraints {
                $0.verticalEdges.equalTo(topView.snp.bottom)
                $0.horizontalEdges.equalToSuperview()
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
    }
    
    func showSelectedPhotoView(_ show: Bool) {
        
        if show {
            photoCollectionView.snp.remakeConstraints {
                $0.top.equalTo(selectedPhotoCollectionView.snp.bottom)
                $0.horizontalEdges.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        } else {
            photoCollectionView.snp.remakeConstraints {
                $0.top.equalTo(descriptionLabel.snp.bottom)
                $0.horizontalEdges.equalToSuperview()
                $0.bottom.equalToSuperview()
            }
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
    }
    
}



//MARK: - Custom Method

internal extension ImagePickerView {
    
    func toggleAlbum() {
        isAlbumViewPresented.toggle()
    }
    
    func updateAlbumTitle(_ album: AlbumInfo) {
        var titleAttr = AttributedString.init(album.name)
        titleAttr.font = .pretendard(font: .semiBold, size: 16)
        titleAttr.foregroundColor = .zw_black
        albumButton.configuration?.attributedTitle = titleAttr
    }
    
    func hiddenUnauthorizedView(_ isHidden: Bool) {
        unauthorizedView.isHidden = isHidden
    }
        
    func updateUI(_ count: Int) {
        showSelectedPhotoView(count > 0)
        // confirm Button
        let isEnabled = count >= 8
        
        let countText = "\(String(count))/15"
        let completeText = "완료"
        let fullText = countText + " " + completeText
        
        let normalString = NSMutableAttributedString.create(
            text: fullText,
            targets: [countText, completeText],
            colors: [.zw_point, .zw_black],
            font: .pretendard(font: .semiBold, size: 18))
        
        let disabledString = NSMutableAttributedString.create(
            text: fullText,
            targets: [fullText],
            colors: [.zw_gray],
            font: .pretendard(font: .semiBold, size: 18))
        
        confirmButton.setAttributedTitle(normalString, for: .normal)
        confirmButton.setAttributedTitle(disabledString, for: .disabled)
        confirmButton.isEnabled = isEnabled    
        
    }
    
    func scrollToRight() {
        let cv = selectedPhotoCollectionView
        guard cv.contentSize.width > cv.frame.width else { return }
        
        let offset = cv.contentSize.width - cv.bounds.width
        cv.setContentOffset(.init(x: offset, y: 0), animated: true)
    }
    
}
