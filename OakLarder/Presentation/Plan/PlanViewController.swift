import UIKit
import SnapKit

final class PlanViewController: UIViewController, PlanViewProtocol {
    var presenter: PlanPresenterProtocol?

    private let monthLabel = UILabel()
    private let grid = UIStackView()
    private let table = UITableView(frame: .zero, style: .plain)
    private let emptyArt = UIImageView(image: UIImage(named: "EmptyLedger"))
    private var marks: [PlanDayMarkEntity] = []
    private var entries: [LarderEntryEntity] = []
    private var selectedKey = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        oakBackground()
        oakTitleBar("Month ledger")
        monthLabel.font = OakType.bold(16)
        monthLabel.textColor = OakPalette.parchment
        monthLabel.textAlignment = .center
        let prev = BrassButton(title: "◀")
        let next = BrassButton(title: "▶")
        prev.addTarget(self, action: #selector(prevMonth), for: .touchUpInside)
        next.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        let header = UIStackView(arrangedSubviews: [prev, monthLabel, next])
        header.axis = .horizontal
        header.alignment = .center
        grid.axis = .vertical
        grid.spacing = 4
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(EntryPlankCell.self, forCellReuseIdentifier: EntryPlankCell.reuse)
        table.rowHeight = 78
        emptyArt.contentMode = .scaleAspectFit
        let add = BrassButton(title: "Seek a tin for this day")
        add.addTarget(self, action: #selector(addTin), for: .touchUpInside)
        [header, grid, table, emptyArt, add].forEach { view.addSubview($0) }
        header.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(64)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        grid.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
        }
        add.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(44)
        }
        table.snp.makeConstraints { make in
            make.top.equalTo(grid.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalTo(add.snp.top).offset(-8)
        }
        emptyArt.snp.makeConstraints { make in
            make.center.equalTo(table)
            make.width.height.equalTo(120)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
    }

    func render(_ entity: PlanEntity) {
        monthLabel.text = entity.monthTitle
        marks = entity.marks
        entries = entity.selectedEntries
        selectedKey = entity.selectedKey
        emptyArt.isHidden = !entries.isEmpty
        rebuildGrid(entity)
        table.reloadData()
    }

    private func rebuildGrid(_ entity: PlanEntity) {
        grid.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let week = UIStackView()
        week.axis = .horizontal
        week.distribution = .fillEqually
        ["S", "M", "T", "W", "T", "F", "S"].forEach { symbol in
            let label = UILabel()
            label.text = symbol
            label.font = OakType.regular(11)
            label.textColor = OakPalette.brass
            label.textAlignment = .center
            week.addArrangedSubview(label)
        }
        grid.addArrangedSubview(week)
        guard let first = entity.marks.first, let date = LarderDayStamp.date(from: first.dayKey) else { return }
        let weekday = Calendar.current.component(.weekday, from: date) - 1
        var cells: [UIView] = (0..<weekday).map { _ in UIView() }
        for mark in entity.marks {
            let day = String(mark.dayKey.suffix(2))
            let button = UIButton(type: .system)
            button.setTitle(day, for: .normal)
            button.titleLabel?.font = OakType.bold(12)
            button.setTitleColor(mark.dayKey == entity.selectedKey ? OakPalette.ink : OakPalette.parchment, for: .normal)
            button.backgroundColor = mark.dayKey == entity.selectedKey
                ? OakPalette.brass
                : (mark.hasPlanned ? OakPalette.oakMid : OakPalette.iron.withAlphaComponent(0.7))
            button.layer.cornerRadius = 6
            button.addAction(UIAction { [weak self] _ in
                self?.presenter?.select(dayKey: mark.dayKey)
            }, for: .touchUpInside)
            cells.append(button)
        }
        stride(from: 0, to: cells.count, by: 7).forEach { start in
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .fillEqually
            row.spacing = 4
            let slice = cells[start..<min(start + 7, cells.count)]
            slice.forEach { row.addArrangedSubview($0) }
            while row.arrangedSubviews.count < 7 {
                row.addArrangedSubview(UIView())
            }
            row.snp.makeConstraints { $0.height.equalTo(34) }
            grid.addArrangedSubview(row)
        }
    }

    @objc private func prevMonth() { presenter?.shiftMonth(-1) }
    @objc private func nextMonth() { presenter?.shiftMonth(1) }
    @objc private func addTin() { presenter?.addTin() }
}

extension PlanViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { entries.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EntryPlankCell.reuse, for: indexPath) as! EntryPlankCell
        cell.render(entries[indexPath.row])
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let forget = UIContextualAction(style: .destructive, title: "Forget") { [weak self] _, _, done in
            self?.presenter?.deleteEntry(id: self?.entries[indexPath.row].id ?? "")
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [forget])
    }
}
