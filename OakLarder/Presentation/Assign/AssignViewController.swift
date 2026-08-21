import UIKit
import SnapKit

final class AssignViewController: UIViewController, AssignViewProtocol {
    var presenter: AssignPresenterProtocol?

    private let summary = UILabel()
    private let kind = UISegmentedControl(items: ["On the board", "Into the ledger"])
    private let picker = UIDatePicker()
    private let slotStack = UIStackView()
    private let confirm = BrassButton(title: "Set the tin down")
    private var slotButtons: [PantrySlotEntity: BrassButton] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        oakBackground()
        oakTitleBar("Assign the tin")
        summary.font = OakType.regular(14)
        summary.textColor = OakPalette.parchment
        summary.numberOfLines = 0
        kind.selectedSegmentIndex = 0
        kind.addTarget(self, action: #selector(kindChanged), for: .valueChanged)
        kind.selectedSegmentTintColor = OakPalette.brass
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.minimumDate = Calendar.current.startOfDay(for: Date())
        picker.maximumDate = Calendar.current.date(byAdding: .month, value: 1, to: Date())
        picker.addTarget(self, action: #selector(dayChanged), for: .valueChanged)
        picker.isHidden = true
        slotStack.axis = .vertical
        slotStack.spacing = 8
        confirm.addTarget(self, action: #selector(save), for: .touchUpInside)
        [summary, kind, picker, slotStack, confirm].forEach { view.addSubview($0) }
        summary.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(68)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        kind.snp.makeConstraints { make in
            make.top.equalTo(summary.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        picker.snp.makeConstraints { make in
            make.top.equalTo(kind.snp.bottom).offset(12)
            make.leading.equalToSuperview().inset(20)
        }
        slotStack.snp.makeConstraints { make in
            make.top.equalTo(picker.snp.bottom).offset(14)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        confirm.snp.makeConstraints { make in
            make.top.equalTo(slotStack.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(46)
        }
        presenter?.viewDidLoad()
    }

    func render(_ entity: AssignEntity) {
        summary.text = "\(entity.goods.title)\n\(Int(entity.grams)) g · \(Int(entity.serving.kcal.rounded())) kcal"
        kind.selectedSegmentIndex = entity.kind == .eaten ? 0 : 1
        picker.isHidden = entity.kind == .eaten
        if let date = LarderDayStamp.date(from: entity.dayKey) {
            picker.date = date
        }
        slotStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        slotButtons.removeAll()
        for slot in entity.allowedSlots {
            let button = BrassButton(title: slot.plaqueTitle)
            button.tag = entity.allowedSlots.firstIndex(of: slot) ?? 0
            button.addAction(UIAction { [weak self] _ in
                self?.presenter?.setSlot(slot)
            }, for: .touchUpInside)
            button.alpha = slot == entity.slot ? 1 : 0.62
            slotStack.addArrangedSubview(button)
            slotButtons[slot] = button
        }
    }

    @objc private func kindChanged() {
        presenter?.setKind(kind.selectedSegmentIndex == 0 ? .eaten : .planned)
    }

    @objc private func dayChanged() {
        presenter?.setDay(picker.date)
    }

    @objc private func save() {
        presenter?.confirm()
    }
}
