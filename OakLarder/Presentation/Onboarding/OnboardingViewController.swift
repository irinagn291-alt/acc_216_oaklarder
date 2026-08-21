import UIKit
import SnapKit

final class OnboardingViewController: UIViewController, OnboardingViewProtocol {
    var presenter: OnboardingPresenterProtocol?

    private let art = UIImageView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let dots = UIPageControl()
    private let nextButton = BrassButton(title: "Next plank")

    override func viewDidLoad() {
        super.viewDidLoad()
        oakBackground()
        art.contentMode = .scaleAspectFill
        art.clipsToBounds = true
        art.layer.cornerRadius = 16
        titleLabel.font = OakType.bold(24)
        titleLabel.textColor = OakPalette.parchment
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        bodyLabel.font = OakType.regular(15)
        bodyLabel.textColor = OakPalette.parchment
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        dots.currentPageIndicatorTintColor = OakPalette.brass
        dots.pageIndicatorTintColor = OakPalette.iron
        nextButton.addTarget(self, action: #selector(advance), for: .touchUpInside)
        [art, titleLabel, bodyLabel, dots, nextButton].forEach { view.addSubview($0) }
        art.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(art.snp.width).multipliedBy(1.15)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(art.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        dots.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        nextButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(28)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(48)
        }
        presenter?.viewDidLoad()
    }

    func render(_ entity: OnboardingEntity) {
        guard entity.pages.indices.contains(entity.index) else { return }
        let page = entity.pages[entity.index]
        art.image = UIImage(named: page.artName)
        titleLabel.text = page.title
        bodyLabel.text = page.body
        dots.numberOfPages = entity.pages.count
        dots.currentPage = entity.index
        nextButton.setTitle(entity.index == entity.pages.count - 1 ? "Open the larder" : "Next plank", for: .normal)
    }

    @objc private func advance() {
        presenter?.advance()
    }
}
