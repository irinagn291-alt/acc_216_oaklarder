import UIKit
import SnapKit

final class DetailViewController: UIViewController, DetailViewProtocol {
    var presenter: DetailPresenterProtocol?

    private let art = UIImageView()
    private let nameLabel = UILabel()
    private let markLabel = UILabel()
    private let perHundred = UILabel()
    private let servingLabel = UILabel()
    private let stepper = UIStepper()
    private let gramsField = IronField(placeholder: "grams", keyboard: .decimalPad)
    private let assignButton = BrassButton(title: "Lay on the board")
    private let wishButton = BrassButton(title: "Pin to the wish nail")

    override func viewDidLoad() {
        super.viewDidLoad()
        oakBackground()
        oakTitleBar("The tin")
        art.contentMode = .scaleAspectFill
        art.clipsToBounds = true
        art.layer.cornerRadius = 12
        nameLabel.font = OakType.bold(20)
        nameLabel.textColor = OakPalette.parchment
        nameLabel.numberOfLines = 0
        markLabel.font = OakType.regular(14)
        markLabel.textColor = OakPalette.brass
        perHundred.font = OakType.regular(13)
        perHundred.textColor = OakPalette.parchment
        perHundred.numberOfLines = 0
        servingLabel.font = OakType.bold(15)
        servingLabel.textColor = OakPalette.parchment
        servingLabel.numberOfLines = 0
        stepper.minimumValue = 10
        stepper.maximumValue = 800
        stepper.stepValue = 10
        stepper.value = 100
        stepper.addTarget(self, action: #selector(step), for: .valueChanged)
        gramsField.addTarget(self, action: #selector(typed), for: .editingChanged)
        assignButton.addTarget(self, action: #selector(assign), for: .touchUpInside)
        wishButton.addTarget(self, action: #selector(wish), for: .touchUpInside)
        [art, nameLabel, markLabel, perHundred, servingLabel, stepper, gramsField, assignButton, wishButton].forEach {
            view.addSubview($0)
        }
        art.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(68)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(168)
        }
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(art.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        markLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.trailing.equalTo(nameLabel)
        }
        perHundred.snp.makeConstraints { make in
            make.top.equalTo(markLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(nameLabel)
        }
        servingLabel.snp.makeConstraints { make in
            make.top.equalTo(perHundred.snp.bottom).offset(10)
            make.leading.trailing.equalTo(nameLabel)
        }
        gramsField.snp.makeConstraints { make in
            make.top.equalTo(servingLabel.snp.bottom).offset(14)
            make.leading.equalToSuperview().inset(20)
            make.width.equalTo(120)
            make.height.equalTo(40)
        }
        stepper.snp.makeConstraints { make in
            make.centerY.equalTo(gramsField)
            make.leading.equalTo(gramsField.snp.trailing).offset(12)
        }
        assignButton.snp.makeConstraints { make in
            make.top.equalTo(gramsField.snp.bottom).offset(18)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(46)
        }
        wishButton.snp.makeConstraints { make in
            make.top.equalTo(assignButton.snp.bottom).offset(10)
            make.leading.trailing.equalTo(assignButton)
            make.height.equalTo(46)
        }
        presenter?.viewDidLoad()
    }

    func render(_ entity: DetailEntity) {
        art.image = UIImage(named: CellarShelfStock.artName(for: entity.goods.sku) ?? "ChromeBrassKnob")
        nameLabel.text = entity.goods.title
        markLabel.text = entity.goods.houseMark ?? "Loose tin"
        perHundred.text = String(
            format: "Per 100 g — %.0f kcal · P %.1f · C %.1f · F %.1f",
            entity.goods.kcalPerHundred,
            entity.goods.proteinPerHundred,
            entity.goods.carbsPerHundred,
            entity.goods.fatPerHundred
        )
        servingLabel.text = String(
            format: "This portion (%.0f g) — %.0f kcal · P %.1f · C %.1f · F %.1f",
            entity.serving.grams,
            entity.serving.kcal,
            entity.serving.protein,
            entity.serving.carbs,
            entity.serving.fat
        )
        gramsField.text = String(Int(entity.grams))
        stepper.value = entity.grams
        wishButton.setTitle(entity.wishPinned ? "Already on the nail" : "Pin to the wish nail", for: .normal)
        wishButton.isEnabled = !entity.wishPinned
    }

    @objc private func step() { presenter?.setGrams(stepper.value) }
    @objc private func typed() { presenter?.setGrams(Double(gramsField.text ?? "") ?? 100) }
    @objc private func assign() { presenter?.continueAssign() }
    @objc private func wish() { presenter?.pinWish() }
}
