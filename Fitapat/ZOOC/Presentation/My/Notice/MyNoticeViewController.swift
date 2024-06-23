//
//  MyNoticeViewController.swift
//  ZOOC
//
//  Created by 류희재 on 5/14/24.
//

import UIKit

import SnapKit
import Then
import RxSwift

final class MyNoticeViewController: BaseViewController {
    
    //MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    //MARK: - UI Components
    
    private lazy var rootView = MyNoticeView()
    
    //MARK: - Life Cycle
    
    override func loadView() {
        self.view = rootView
        self.title = "알림설정"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI()
    }
    
    private func bindUI() {
        rootView.noticeSettingButton.rx.tap
            .subscribe(with: self, onNext: { owner, _ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }).disposed(by: disposeBag)
    }
}

