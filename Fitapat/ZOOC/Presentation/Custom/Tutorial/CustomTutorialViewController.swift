//
//  CustomTutorialViewController.swift
//  ZOOC
//
//  Created by 장석우 on 3/20/24.
//

import UIKit

import RxSwift
import RxCocoa

import SnapKit
import Then

protocol CustomTutorialViewControllerDelegate: AnyObject {
    func confirmButtonDidTap()
}


final class CustomTutorialViewController: UIViewController {
    
    enum TutorialStep: String, CaseIterable {
        case makeImage = "컨셉 이미지 만들기"
        case checkImage = "컨셉 이미지 확인하기"
        case buyProduct = "제품 구매하고 적용하기"
        
        var title: String {
            switch self {
            case .makeImage:
                return "배경, 액세서리, 옷 자유롭게 선택하기"
            case .checkImage:
                return "웰시코기로 미리 확인하기"
            case .buyProduct:
                return "제품 구매해서 내 반려동물에 적용하기"
            }
        }
        
        var description: String {
            switch self {
            case .makeImage:
                return "직접 만든 캐릭터 컨셉으로 AI 이미지가 완성돼요"
            case .checkImage:
                return "구매하기 전에 웰시코기로 컨셉을 확인할 수 있어요"
            case .buyProduct:
                return "제품에 내가 만든 컨셉이 적용된 우리집 반려동물이 쏙!"
            }
        }
        
        var image: UIImage {
            switch self {
            case .makeImage:
                return .firstTutorial
            case .checkImage:
                return .secondTutorial
            case .buyProduct:
                return .thirdTutorial
            }
        }
        
        func next() -> Self? {
            let steps = Self.allCases
            let idx = steps.firstIndex(of: self)!
            let next = steps.index(after: idx)
            guard next != steps.endIndex else { return nil}
            return steps[next]
        }
    }
    
    private var step: TutorialStep = .makeImage {
        didSet {
            updateUI(step)
        }
    }
    
    unowned var delegate: CustomTutorialViewControllerDelegate
    private let disposeBag = DisposeBag()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return .init(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let fisrtCircleView = UIButton()
    private let secondCircleView = UIButton()
    private let thirdCircleView = UIButton()
    private let hStackView = UIStackView()
    
    private let titleLabel = UILabel()
    
    private let nextButtonContainerView = UIView()
    private let nextButton = UIButton()
    private let neverShowButton = UIButton()
    private let confirmButton = UIButton()
    
    init(delegate: CustomTutorialViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .fullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        style()
        hierarchy()
        layout()
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI(step)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindUI() {
        fisrtCircleView.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                Haptic.impact(.light).run()
                owner.step = .makeImage
            })
            .disposed(by: disposeBag)
        
        secondCircleView.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                Haptic.impact(.light).run()
                owner.step = .checkImage
            })
            .disposed(by: disposeBag)
        
        thirdCircleView.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                Haptic.impact(.light).run()
                owner.step = .buyProduct
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                Haptic.impact(.light).run()
                if let nextStep = owner.step.next() {
                    owner.step = nextStep
                }
            })
            .disposed(by: disposeBag)
        
        
        confirmButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                Haptic.impact(.light).run()
                owner.dismiss(animated: false)
                owner.delegate.confirmButtonDidTap()
            })
            .disposed(by: disposeBag)
        
        
           
           neverShowButton.rx.tap
               .subscribe(with: self, onNext: { owner, _ in
                   UserDefaultsManager.neverShowTutorial = true
                   owner.dismiss(animated: false)
                   owner.delegate.confirmButtonDidTap()
               })
               .disposed(by: disposeBag)
       
    }

    
    private func style() {
        view.backgroundColor = .zw_background
        
        
        
        [fisrtCircleView, secondCircleView, thirdCircleView].forEach {
            $0.titleLabel?.font = .pretendard(font: .regular, size: 11)
            $0.setTitleColor(.zw_white, for: .normal)
            $0.isSelected = false
            $0.setBackgroundColor(.zw_brightgray, for: .normal)
            $0.setBackgroundColor(.zw_black, for: .selected)
            $0.makeCornerRound(radius: 9)
        }
        
        fisrtCircleView.setTitle("1", for: .normal)
        secondCircleView.setTitle("2", for: .normal)
        thirdCircleView.setTitle("3", for: .normal)
        
        hStackView.do {
            $0.axis = .horizontal
            $0.spacing = 12
            $0.alignment = .center
            $0.distribution = .fillEqually
        }
        
        titleLabel.do {
            $0.font = .zw_Subhead4
            $0.textColor = .zw_black
            $0.textAlignment = .center
        }
        
        collectionView.do {
            $0.backgroundColor = .zw_background
            $0.isScrollEnabled = true
            $0.bounces = false
            $0.isPagingEnabled = true
            $0.showsHorizontalScrollIndicator = false
            $0.delegate = self
            $0.dataSource = self
            $0.register(CustomTutorialCell.self, 
                        forCellWithReuseIdentifier: CustomTutorialCell.reuseCellIdentifier)
        }

        nextButtonContainerView.layer.makeShadow(color: .black,
                                                 alpha: 0.1,
                                                 x: 0,
                                                 y: 0,
                                                 blur: 20,
                                                 spread: 0)
        
        nextButton.do {
            $0.backgroundColor = .zw_white
            $0.setImage(.next.withTintColor(.zw_point), 
                        for: .normal)
            $0.makeCornerRound(radius: 30)
            $0.largeContentImageInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        confirmButton.do {
            var config = UIButton.Configuration.plain()
            config.image = .icTicket.withTintColor(.zw_white)
            config.imagePadding = 8
            config.imagePlacement = .leading
            config.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: 0,
                bottom: 15,
                trailing: 0
            )
            
            var titleAttr = AttributedString.init("티켓 쓰고 셀프 AI 이미지 만들기")
            titleAttr.font = .zw_Subhead1
            titleAttr.foregroundColor = .zw_white
            
            config.attributedTitle = titleAttr
            $0.backgroundColor = .zw_black
            $0.configuration = config
        }
        
        neverShowButton.do {
            $0.setTitle("다시 보지 않기", for: .normal)
            $0.setTitleColor(.zw_lightgray, for: .normal)
            $0.titleLabel?.font = .zw_caption
            $0.titleLabel?.asUnderLine("다시 보지 않기")
            
        }
    }
    
    private func hierarchy() {
        view.addSubviews(
            hStackView,
            titleLabel,
            collectionView,
            nextButtonContainerView,
            neverShowButton,
            confirmButton)
        
        nextButtonContainerView.addSubview(nextButton)
        
        hStackView.addArrangedSubViews(fisrtCircleView, secondCircleView, thirdCircleView)
    }
    
    private func layout() {
        
        hStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            $0.centerX.equalToSuperview()
        }
        
        [fisrtCircleView, secondCircleView, thirdCircleView].forEach {
            $0.snp.makeConstraints {
                $0.size.equalTo(18)
            }
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(hStackView.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().priority(.required)
            $0.bottom.equalTo(confirmButton.snp.top)
        }
        
        confirmButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(90)
        }
        
        nextButtonContainerView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(40)
            $0.size.equalTo(60)
            
        }
        
        neverShowButton.snp.makeConstraints {
            $0.centerY.equalTo(hStackView)
            $0.trailing.equalToSuperview().inset(28)
        }
        
        nextButton.snp.makeConstraints {
            $0.edges.equalTo(nextButtonContainerView)
        }
    }
    
    private func updateUI(_ step: TutorialStep) {
        nextButtonContainerView.alpha = 0
        
        fisrtCircleView.isSelected = step == .makeImage
        secondCircleView.isSelected = step == .checkImage
        thirdCircleView.isSelected = step == .buyProduct
        
        titleLabel.text = step.rawValue
        confirmButton.isHidden = step != .buyProduct
        neverShowButton.isHidden = step != .buyProduct
        
        if step != .buyProduct {
            UIView.animate(withDuration: 1, delay: 2) {
                self.nextButtonContainerView.alpha = 1
            }
        }
        
        let index = TutorialStep.allCases.firstIndex(of: step)!
        
        collectionView.setContentOffset(
            .init(x: CGFloat(index) * Device.width , y: 0)
            , animated: true)

    }
    

}

extension CustomTutorialViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TutorialStep.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CustomTutorialCell.reuseCellIdentifier,
            for: indexPath) as! CustomTutorialCell
        cell.dataBind(TutorialStep.allCases[indexPath.row])
        return cell
    }
    
    
}

extension CustomTutorialViewController: UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width, 
                     height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
            let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

            if let indexPath = collectionView.indexPathForItem(at: visiblePoint) {
                switch indexPath.row {
                case 0: self.step = .makeImage
                case 1: self.step = .checkImage
                case 2: self.step = .buyProduct
                default: return
                }
            }
        }
}


