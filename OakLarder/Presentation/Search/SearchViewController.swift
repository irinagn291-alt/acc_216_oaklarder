import UIKit
import SnapKit

final class SearchViewController: UIViewController, SearchViewProtocol {
    var presenter: SearchPresenterProtocol?

    private let field = IronField(placeholder: "Name on the crate…")
    private let ribbon = UILabel()
    private let table = UITableView(frame: .zero, style: .plain)
    private var goods: [LarderGoodsEntity] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        oakBackground()
        oakTitleBar("Seek the cellar")
        ribbon.font = OakType.regular(12)
        ribbon.textColor = OakPalette.brass
        ribbon.textAlignment = .center
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(EntryPlankCell.self, forCellReuseIdentifier: EntryPlankCell.reuse)
        table.rowHeight = 78
        field.addTarget(self, action: #selector(changed), for: .editingChanged)
        view.addSubview(field)
        view.addSubview(ribbon)
        view.addSubview(table)
        field.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(64)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        ribbon.snp.makeConstraints { make in
            make.top.equalTo(field.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        table.snp.makeConstraints { make in
            make.top.equalTo(ribbon.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        presenter?.viewDidLoad()
    }

    func render(_ entity: SearchEntity) {
        goods = entity.goods
        ribbon.text = entity.fromCellarCache
            ? "Cellar cache — offline boards first"
            : "Distant crates from Open Food Facts"
        table.reloadData()
    }

    @objc private func changed() {
        presenter?.queryChanged(field.text ?? "")
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { goods.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EntryPlankCell.reuse, for: indexPath) as! EntryPlankCell
        let item = goods[indexPath.row]
        let fake = LarderEntryEntity(
            id: item.sku,
            sku: item.sku,
            title: item.title,
            grams: 100,
            kcal: item.kcalPerHundred,
            protein: item.proteinPerHundred,
            carbs: item.carbsPerHundred,
            fat: item.fatPerHundred,
            slot: .noonBoard,
            dayKey: "",
            kind: .eaten
        )
        cell.render(fake)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.pick(goods[indexPath.row])
    }
}
