import UIKit
import SnapKit

final class WishViewController: UIViewController, WishViewProtocol {
    var presenter: WishPresenterProtocol?

    private let table = UITableView(frame: .zero, style: .plain)
    private let emptyArt = UIImageView(image: UIImage(named: "EmptyWish"))
    private let emptyLabel = UILabel()
    private var items: [WishSkuEntity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        oakBackground()
        oakTitleBar("Wish nail")
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(EntryPlankCell.self, forCellReuseIdentifier: EntryPlankCell.reuse)
        table.rowHeight = 78
        emptyArt.contentMode = .scaleAspectFit
        emptyLabel.text = "The jar is empty"
        emptyLabel.font = OakType.regular(14)
        emptyLabel.textColor = OakPalette.parchment
        emptyLabel.textAlignment = .center
        view.addSubview(table)
        view.addSubview(emptyArt)
        view.addSubview(emptyLabel)
        table.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(64)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        emptyArt.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.height.equalTo(140)
        }
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyArt.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
    }

    func render(_ entity: WishEntity) {
        items = entity.items
        emptyArt.isHidden = !items.isEmpty
        emptyLabel.isHidden = !items.isEmpty
        table.reloadData()
    }
}

extension WishViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EntryPlankCell.reuse, for: indexPath) as! EntryPlankCell
        let item = items[indexPath.row]
        let fake = LarderEntryEntity(
            id: item.sku,
            sku: item.sku,
            title: item.title,
            grams: 0,
            kcal: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            slot: .noonBoard,
            dayKey: "",
            kind: .eaten
        )
        cell.render(fake)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.open(items[indexPath.row])
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let forget = UIContextualAction(style: .destructive, title: "Unpin") { [weak self] _, _, done in
            self?.presenter?.unpin(sku: self?.items[indexPath.row].sku ?? "")
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [forget])
    }
}
