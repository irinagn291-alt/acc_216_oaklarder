import Foundation

struct PortionScaleUseCase: Sendable {
    func weigh(
        kcalPerHundred: Double,
        proteinPerHundred: Double,
        carbsPerHundred: Double,
        fatPerHundred: Double,
        grams: Double
    ) -> ServingMathEntity {
        let factor = grams / 100.0
        return ServingMathEntity(
            grams: grams,
            kcal: kcalPerHundred * factor,
            protein: proteinPerHundred * factor,
            carbs: carbsPerHundred * factor,
            fat: fatPerHundred * factor
        )
    }

    func weigh(_ goods: LarderGoodsEntity, grams: Double) -> ServingMathEntity {
        weigh(
            kcalPerHundred: goods.kcalPerHundred,
            proteinPerHundred: goods.proteinPerHundred,
            carbsPerHundred: goods.carbsPerHundred,
            fatPerHundred: goods.fatPerHundred,
            grams: grams
        )
    }

    func kcalFromKilojoules(_ kilojoules: Double) -> Double {
        kilojoules / 4.184
    }
}
