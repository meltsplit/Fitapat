//
//  CustomViewController.swift
//  ZOOC
//
//  Created by 류희재 on 12/12/23.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import Then

enum CustomViewType {
    case concept
    case album
    
    var buttonTitle: String {
        switch self {
        case .concept:
            return "{pet}{으로/로} 커스텀 AI 캐릭터 만들기"
        case .album:
            return "내 캐릭터로 {pet} 굿즈 구매하기"
        }
    }
}

final class CustomViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    private var viewType: CustomViewType
    private let viewModel: CustomViewModel
    
    //MARK: - UI Components
    
    private let rootView = CustomView()

    //MARK: - Life Cycle
    
    init(viewType: CustomViewType,
         viewModel: CustomViewModel
    ) {
        self.viewType = viewType
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        rootView.updateUI(viewType)
        bindUI()
        bindViewModel()
        self.isNavigationBarHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = rootView
    }
    
    //MARK: - Custom Method
    
    private func bindUI() {
        
        rootView.customTopView.ticketView.rx.tapGesture().when(.recognized)
            .map { _ in "내가 커스텀 AI 캐릭터를 만들 수 있는 잔여 횟수예요\n만든 캐릭터로 커스텀 제품을 구매하면 10장을 더 드려요" }
            .bind(onNext: presentToastAtTop)
            .disposed(by: disposeBag)

        rootView.customTopView.conceptButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { owner, _ in
                Haptic.impact(.light).run()
                owner.viewType = .concept
                owner.rootView.updateUI(owner.viewType)
            }).disposed(by: disposeBag)
        
        rootView.customTopView.albumButton.rx.tap
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { owner, _ in
                Haptic.impact(.light).run()
                owner.viewType = .album
                owner.rootView.updateUI(owner.viewType)
            }).disposed(by: disposeBag)
        
        rootView.customAIButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                Haptic.selection.run()
            }).disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let input = CustomViewModel.Input(
            viewDidLoadEvent: rx.viewDidLoad.asObservable(),
            conceptButtonDidTapEvent: rootView.customTopView.conceptButton.rx.tap.asObservable(),
            albumButtonDidTapEvent: rootView.customTopView.albumButton.rx.tap.asObservable(),
            customViewRefreshEvent: Observable.merge(
                rootView.conceptView.refreshController.rx.controlEvent(.valueChanged).map { _ in () },
                rootView.albumView.refreshController.rx.controlEvent(.valueChanged).map { _ in () }),
            emptyConceptButtonDidTapEvent: rootView.albumView.emptyView.customAIButton.rx.tap.asObservable(),
            customAIButtonDidTapEvent: rootView.customAIButton.rx.tap.asObservable().map { self.viewType },
            refreshNotificationEvent: NotificationCenter.default.rx.notification(.refreshCustom).map { _ in ()}
        )
           
        let output = viewModel.transform(from: input, disposeBag: disposeBag)
        
        output.presentFirstTicket
            .asDriver(onErrorJustReturn: Void())
            .drive(with: self, onNext: { owner, _ in
                let ticketPresentVC = TicketPresentViewController(delegate: owner)
                owner.present(ticketPresentVC, animated: true)
            }).disposed(by: disposeBag)

        output.conceptData
            .asDriver(onErrorJustReturn: [])
            .do(onNext: { [weak self] _ in
                self?.rootView.conceptView.refreshController.endRefreshing()
            })
            .drive(rootView.conceptView.rx.items(
                cellIdentifier: ConceptCollectionViewSectionCell.cellIdentifier,
                cellType: ConceptCollectionViewSectionCell.self
            )) { _, data, cell in
                cell.delegate = self
                cell.updateUI(data)
            }.disposed(by: disposeBag)
        
        output.albumData
            .do(onNext: { [weak self] albumData in
                self?.rootView.albumView.refreshController.endRefreshing()
                self?.rootView.albumView.emptyView.isHidden = !albumData.isEmpty
                self?.rootView.albumView.albumCollectionView.isHidden = albumData.isEmpty
            })
            .filter { !$0.isEmpty }
            .asDriver(onErrorJustReturn: [])
            .drive(rootView.albumView.albumCollectionView.rx.items(
                cellIdentifier: AlbumCollectionViewSectionCell.cellIdentifier,
                cellType: AlbumCollectionViewSectionCell.self
            )) { _, data, cell in
                cell.delegate = self
                cell.updateUI(data)
            }.disposed(by: disposeBag)
        
        output.ticketCnt
            .asDriver(onErrorJustReturn: Int())
            .drive(with: self, onNext: { owner, ticketCnt in
                owner.rootView.customTopView.ticketView.updateUI(ticketCnt)
            }).disposed(by: disposeBag)
        
        output.pushToChooseConcpetVC
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { owner, haveTicket in
                if haveTicket {
                    if UserDefaultsManager.neverShowTutorial {
                        let chooseConceptVC = DIContainer.shared.makeChooseConceptVC()
                        chooseConceptVC.hidesBottomBarWhenPushed = true
                        owner.navigationController?.pushViewController(chooseConceptVC, animated: true)
                    } else {
                        let tutorialVC = CustomTutorialViewController(delegate: self)
                        owner.present(tutorialVC, animated: false)
                    }
                } else {
                    let exhauseTicketVC = ExhuastedTicketAlertViewController(delegate: owner)
                    owner.present(exhauseTicketVC, animated: false)
                }
            }).disposed(by: disposeBag)
        
        output.pushToSelfCustomWeb
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { owner, _ in
                let webVC = DIContainer.shared.makeFapWebVC(path: "/custom")
                webVC.hidesBottomBarWhenPushed = true
                owner.navigationController?.pushViewController(webVC, animated: true)
            })
            .disposed(by: disposeBag)
    }

}

extension CustomViewController: CustomItemCellDelegate & AlbumItemCellDelegate{
    func conceptItemCellDidSelect(_ data: CharacterResult) {
        pushCustomDetailVC(detailType: .concept, data.id)
    }
    
    func albumItemCellDidSelect(_ data: CustomCharacterResult) {
        pushCustomDetailVC(detailType: .character, data.id)
    }
}

extension CustomViewController: ExhuastedTicketAlertViewDelegate {
    func exhuastedTicketConfirmButtonDidTap() {
        let webVC = DIContainer.shared.makeFapWebVC(path: "/custom")
        webVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webVC, animated: true)
    }
}

extension CustomViewController {
    func tapAlbum() {
        viewType = .album
        rootView.updateUI(.album)
    }
    
    private func pushCustomDetailVC(detailType: CustomType ,_ characterID: Int) {
        let customDetailVC = DIContainer.shared.makeCustomDetailVC(detailType: detailType, id: characterID)
        customDetailVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(customDetailVC, animated: true)
    }
}


extension CustomViewController: CustomTutorialViewControllerDelegate {
    func confirmButtonDidTap() {
        let chooseConceptVC = DIContainer.shared.makeChooseConceptVC()
        chooseConceptVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chooseConceptVC, animated: true)
    }
    
    
}



extension CustomViewController: TicketPresentViewControllerDelegate {
    func useTicketButtonDidTap() {
        let tutorialVC = CustomTutorialViewController(delegate: self)
        self.present(tutorialVC, animated: true)
    }
}










