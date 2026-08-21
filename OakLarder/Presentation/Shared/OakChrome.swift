import UIKit
import SnapKit

enum OakPalette {
    static let oakDeep = UIColor(red: 0.22, green: 0.13, blue: 0.07, alpha: 1)
    static let oakMid = UIColor(red: 0.45, green: 0.28, blue: 0.14, alpha: 1)
    static let parchment = UIColor(red: 0.95, green: 0.90, blue: 0.78, alpha: 1)
    static let brass = UIColor(red: 0.72, green: 0.53, blue: 0.16, alpha: 1)
    static let iron = UIColor(red: 0.20, green: 0.20, blue: 0.21, alpha: 1)
    static let ink = UIColor(red: 0.12, green: 0.08, blue: 0.05, alpha: 1)
    static let rust = UIColor(red: 0.55, green: 0.22, blue: 0.12, alpha: 1)
}

enum OakType {
    static func regular(_ size: CGFloat) -> UIFont {
        UIFont(name: "LibreBaskerville-Regular", size: size) ?? .systemFont(ofSize: size)
    }

    static func bold(_ size: CGFloat) -> UIFont {
        UIFont(name: "LibreBaskerville-Bold", size: size) ?? .boldSystemFont(ofSize: size)
    }
}

final class OakTextureView: UIImageView {
    convenience init(named: String) {
        self.init(image: UIImage(named: named))
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }
}

final class BrassButton: UIButton {
    convenience init(title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseForegroundColor = OakPalette.ink
        config.baseBackgroundColor = OakPalette.brass
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = OakType.bold(14)
            return outgoing
        }
        self.init(configuration: config)
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        var config = configuration ?? .filled()
        config.title = title
        configuration = config
    }
}

final class IronField: UITextField {
    convenience init(placeholder: String, keyboard: UIKeyboardType = .default) {
        self.init(frame: .zero)
        self.placeholder = placeholder
        keyboardType = keyboard
        font = OakType.regular(15)
        textColor = OakPalette.parchment
        backgroundColor = OakPalette.iron.withAlphaComponent(0.88)
        layer.borderColor = OakPalette.brass.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 8
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        leftViewMode = .always
        autocapitalizationType = .sentences
        autocorrectionType = .no
        returnKeyType = .search
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: OakPalette.parchment.withAlphaComponent(0.45), .font: OakType.regular(14)]
        )
    }
}

final class MacroBarrelView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let ring = CAShapeLayer()
    private let track = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = OakType.regular(11)
        titleLabel.textColor = OakPalette.parchment
        titleLabel.textAlignment = .center
        valueLabel.font = OakType.bold(13)
        valueLabel.textColor = OakPalette.brass
        valueLabel.textAlignment = .center
        valueLabel.adjustsFontSizeToFitWidth = true
        addSubview(titleLabel)
        addSubview(valueLabel)
        track.strokeColor = OakPalette.iron.cgColor
        track.fillColor = UIColor.clear.cgColor
        track.lineWidth = 6
        ring.strokeColor = OakPalette.brass.cgColor
        ring.fillColor = UIColor.clear.cgColor
        ring.lineWidth = 6
        ring.lineCap = .round
        layer.addSublayer(track)
        layer.addSublayer(ring)
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        valueLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(4)
        }
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        let caption = max(titleLabel.intrinsicContentSize.height, 14)
        let field = CGRect(x: 4, y: 2, width: bounds.width - 8, height: max(0, bounds.height - caption - 4))
        let side = min(field.width, field.height)
        let box = CGRect(
            x: field.midX - side / 2,
            y: field.midY - side / 2,
            width: side,
            height: side
        )
        let path = UIBezierPath(ovalIn: box)
        track.path = path.cgPath
        ring.path = path.cgPath
    }

    func render(title: String, value: Double, goal: Double) {
        titleLabel.text = title
        valueLabel.text = "\(Int(value.rounded()))"
        let ratio = goal <= 0 ? 0 : min(1, value / goal)
        ring.strokeEnd = ratio
        ring.strokeColor = ratio > 1.02 ? OakPalette.rust.cgColor : OakPalette.brass.cgColor
    }
}

final class SlotPlankView: UIControl {
    private let art = UIImageView()
    private let titleLabel = UILabel()
    private let kcalLabel = UILabel()
    private(set) var slot: PantrySlotEntity = .morningLoaf

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        clipsToBounds = true
        art.contentMode = .scaleAspectFill
        titleLabel.font = OakType.bold(13)
        titleLabel.textColor = OakPalette.parchment
        titleLabel.numberOfLines = 2
        kcalLabel.font = OakType.regular(12)
        kcalLabel.textColor = OakPalette.brass
        let shade = UIView()
        shade.backgroundColor = UIColor.black.withAlphaComponent(0.38)
        addSubview(art)
        addSubview(shade)
        addSubview(titleLabel)
        addSubview(kcalLabel)
        art.snp.makeConstraints { $0.edges.equalToSuperview() }
        shade.snp.makeConstraints { $0.edges.equalToSuperview() }
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(8)
            make.bottom.equalTo(kcalLabel.snp.top).offset(-2)
        }
        kcalLabel.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) { nil }

    func render(slot: PantrySlotEntity, kcal: Double, titles: [String]) {
        self.slot = slot
        art.image = UIImage(named: slot.artName)
        titleLabel.text = slot.plaqueTitle
        if titles.isEmpty {
            kcalLabel.text = "empty board"
        } else {
            kcalLabel.text = "\(Int(kcal.rounded())) kcal · \(titles.joined(separator: ", "))"
        }
    }
}

final class EntryPlankCell: UITableViewCell {
    static let reuse = "EntryPlankCell"
    private let art = UIImageView()
    private let titleLabel = UILabel()
    private let metaLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.backgroundColor = OakPalette.iron.withAlphaComponent(0.55)
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = OakPalette.brass.withAlphaComponent(0.35).cgColor
        art.contentMode = .scaleAspectFill
        art.clipsToBounds = true
        art.layer.cornerRadius = 6
        titleLabel.font = OakType.bold(14)
        titleLabel.textColor = OakPalette.parchment
        titleLabel.numberOfLines = 2
        metaLabel.font = OakType.regular(12)
        metaLabel.textColor = OakPalette.brass
        metaLabel.numberOfLines = 2
        contentView.addSubview(art)
        contentView.addSubview(titleLabel)
        contentView.addSubview(metaLabel)
        art.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(8)
            make.width.equalTo(54)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(art.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview().offset(10)
        }
        metaLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.lessThanOrEqualToSuperview().inset(8)
        }
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.insetBy(dx: 0, dy: 4)
    }

    func render(_ entry: LarderEntryEntity) {
        art.image = UIImage(named: CellarShelfStock.artName(for: entry.sku) ?? entry.slot.artName)
        titleLabel.text = entry.title
        if entry.grams <= 0, entry.dayKey.isEmpty {
            metaLabel.text = "Waiting on the nail"
        } else if entry.dayKey.isEmpty {
            metaLabel.text = String(format: "Per 100 g · %.0f kcal", entry.kcal)
        } else {
            metaLabel.text = "\(entry.slot.plaqueTitle) · \(Int(entry.grams)) g · \(Int(entry.kcal.rounded())) kcal"
        }
    }
}

enum OakSheet {
    static func present(_ host: UIViewController, _ child: UIViewController) {
        child.modalPresentationStyle = .pageSheet
        if let sheet = child.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        host.present(child, animated: true)
    }
}

extension UIViewController {
    func oakBackground(_ name: String = "TexOakPlank") {
        let texture = OakTextureView(named: name)
        view.insertSubview(texture, at: 0)
        texture.snp.makeConstraints { $0.edges.equalToSuperview() }
        view.backgroundColor = OakPalette.oakDeep
    }

    func oakTitleBar(_ text: String) -> UILabel {
        let plaque = UIImageView(image: UIImage(named: "ChromeBrassPlaque"))
        plaque.contentMode = .scaleAspectFill
        plaque.clipsToBounds = true
        plaque.layer.cornerRadius = 8
        let label = UILabel()
        label.text = text
        label.font = OakType.bold(20)
        label.textColor = OakPalette.ink
        label.textAlignment = .center
        view.addSubview(plaque)
        view.addSubview(label)
        plaque.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().inset(20)
            make.trailing.lessThanOrEqualToSuperview().inset(20)
            make.width.equalTo(340).priority(.high)
            make.height.equalTo(48)
        }
        label.snp.makeConstraints { $0.edges.equalTo(plaque) }
        return label
    }
}
