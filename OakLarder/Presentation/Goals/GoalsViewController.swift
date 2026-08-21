import UIKit
import SnapKit

final class GoalsViewController: UIViewController, GoalsViewProtocol {
    var presenter: GoalsPresenterProtocol?

    private let kcalField = IronField(placeholder: "kcal", keyboard: .decimalPad)
    private let proteinField = IronField(placeholder: "protein g", keyboard: .decimalPad)
    private let carbsField = IronField(placeholder: "carbs g", keyboard: .decimalPad)
    private let fatField = IronField(placeholder: "fat g", keyboard: .decimalPad)
    private let save = BrassButton(title: "Stamp the aims")
    private let contact = BrassButton(title: "Contact Us")

    override func viewDidLoad() {
        super.viewDidLoad()
        oakBackground()
        oakTitleBar("Cellar aims")
        let stack = UIStackView(arrangedSubviews: [kcalField, proteinField, carbsField, fatField])
        stack.axis = .vertical
        stack.spacing = 10
        save.addTarget(self, action: #selector(stamp), for: .touchUpInside)
        contact.addTarget(self, action: #selector(writeDesk), for: .touchUpInside)
        view.addSubview(stack)
        view.addSubview(save)
        view.addSubview(contact)
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(72)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        [kcalField, proteinField, carbsField, fatField].forEach {
            $0.snp.makeConstraints { $0.height.equalTo(44) }
        }
        save.snp.makeConstraints { make in
            make.top.equalTo(stack.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(46)
        }
        contact.snp.makeConstraints { make in
            make.top.equalTo(save.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(46)
        }
        presenter?.viewDidLoad()
    }

    func render(_ entity: GoalsEntity) {
        kcalField.text = String(Int(entity.goals.kcal))
        proteinField.text = String(Int(entity.goals.protein))
        carbsField.text = String(Int(entity.goals.carbs))
        fatField.text = String(Int(entity.goals.fat))
    }

    @objc private func stamp() {
        presenter?.save(
            kcal: Double(kcalField.text ?? "") ?? 2150,
            protein: Double(proteinField.text ?? "") ?? 98,
            carbs: Double(carbsField.text ?? "") ?? 248,
            fat: Double(fatField.text ?? "") ?? 71
        )
    }

    @objc private func writeDesk() {
        presenter?.tapContact()
    }
}
