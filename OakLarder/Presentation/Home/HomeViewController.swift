import UIKit
import SnapKit

final class HomeViewController: UIViewController, HomeViewProtocol {
    var presenter: HomePresenterProtocol?

    private let dayLabel = UILabel()
    private let kcalBarrel = MacroBarrelView()
    private let proteinBarrel = MacroBarrelView()
    private let carbsBarrel = MacroBarrelView()
    private let fatBarrel = MacroBarrelView()
    private let slotGrid = UIStackView()
    private let table = UITableView(frame: .zero, style: .plain)
    private let emptyArt = UIImageView(image: UIImage(named: "EmptyPlate"))
    private var log: [LarderEntryEntity] = []
    private var slotViews: [SlotPlankView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        oakBackground()
        let title = oakTitleBar("OakLarder")
        dayLabel.font = OakType.regular(14)
        dayLabel.textColor = OakPalette.parchment
        dayLabel.textAlignment = .center
        let barrels = UIStackView(arrangedSubviews: [kcalBarrel, proteinBarrel, carbsBarrel, fatBarrel])
        barrels.axis = .horizontal
        barrels.distribution = .fillEqually
        barrels.spacing = 6
        slotGrid.axis = .vertical
        slotGrid.spacing = 8
        let top = UIStackView()
        top.axis = .horizontal
        top.spacing = 8
        top.distribution = .fillEqually
        let bottom = UIStackView()
        bottom.axis = .horizontal
        bottom.spacing = 8
        bottom.distribution = .fillEqually
        slotViews = PantrySlotEntity.allCases.map { slot in
            let plank = SlotPlankView()
            plank.render(slot: slot, kcal: 0, titles: [])
            return plank
        }
        top.addArrangedSubview(slotViews[0])
        top.addArrangedSubview(slotViews[1])
        bottom.addArrangedSubview(slotViews[2])
        bottom.addArrangedSubview(slotViews[3])
        slotGrid.addArrangedSubview(top)
        slotGrid.addArrangedSubview(bottom)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.register(EntryPlankCell.self, forCellReuseIdentifier: EntryPlankCell.reuse)
        table.rowHeight = 78
        emptyArt.contentMode = .scaleAspectFit
        emptyArt.isHidden = true
        let bar = UIStackView()
        bar.axis = .horizontal
        bar.distribution = .fillEqually
        bar.spacing = 6
        let seek = BrassButton(title: "Seek")
        let stamp = BrassButton(title: "Stamp")
        let ledger = BrassButton(title: "Ledger")
        let nail = BrassButton(title: "Nail")
        let aims = BrassButton(title: "Aims")
        [seek, stamp, ledger, nail, aims].forEach { bar.addArrangedSubview($0) }
        seek.addTarget(self, action: #selector(tapSearch), for: .touchUpInside)
        stamp.addTarget(self, action: #selector(tapScan), for: .touchUpInside)
        ledger.addTarget(self, action: #selector(tapPlan), for: .touchUpInside)
        nail.addTarget(self, action: #selector(tapWish), for: .touchUpInside)
        aims.addTarget(self, action: #selector(tapGoals), for: .touchUpInside)
        view.addSubview(dayLabel)
        view.addSubview(barrels)
        view.addSubview(slotGrid)
        view.addSubview(table)
        view.addSubview(emptyArt)
        view.addSubview(bar)
        dayLabel.snp.makeConstraints { make in
            make.top.equalTo(title.superview!.safeAreaLayoutGuide).offset(60)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        barrels.snp.makeConstraints { make in
            make.top.equalTo(dayLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(10)
            make.height.equalTo(92)
        }
        slotGrid.snp.makeConstraints { make in
            make.top.equalTo(barrels.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(12)
            make.height.equalTo(188)
        }
        bar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            make.height.equalTo(46)
        }
        table.snp.makeConstraints { make in
            make.top.equalTo(slotGrid.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(12)
            make.bottom.equalTo(bar.snp.top).offset(-8)
        }
        emptyArt.snp.makeConstraints { make in
            make.center.equalTo(table)
            make.width.height.equalTo(140)
        }
        slotViews.forEach { plank in
            plank.snp.makeConstraints { $0.height.equalTo(90) }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.viewDidAppear()
    }

    func render(_ entity: HomeEntity) {
        dayLabel.text = entity.spokenDay
        kcalBarrel.render(title: "kcal", value: entity.eaten.kcal, goal: entity.goals.kcal)
        proteinBarrel.render(title: "protein", value: entity.eaten.protein, goal: entity.goals.protein)
        carbsBarrel.render(title: "carbs", value: entity.eaten.carbs, goal: entity.goals.carbs)
        fatBarrel.render(title: "fat", value: entity.eaten.fat, goal: entity.goals.fat)
        for plank in slotViews {
            if let board = entity.slots.first(where: { $0.slot == plank.slot }) {
                plank.render(slot: board.slot, kcal: board.kcal, titles: board.titles)
            }
        }
        log = entity.log
        emptyArt.isHidden = !log.isEmpty
        table.reloadData()
    }

    @objc private func tapSearch() { presenter?.tapSearch() }
    @objc private func tapScan() { presenter?.tapScan() }
    @objc private func tapPlan() { presenter?.tapPlan() }
    @objc private func tapWish() { presenter?.tapWish() }
    @objc private func tapGoals() { presenter?.tapGoals() }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { log.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EntryPlankCell.reuse, for: indexPath) as! EntryPlankCell
        cell.render(log[indexPath.row])
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let forget = UIContextualAction(style: .destructive, title: "Forget") { [weak self] _, _, done in
            guard let self else { return }
            self.presenter?.deleteEntry(id: self.log[indexPath.row].id)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [forget])
    }
}
