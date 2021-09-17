import UIKit

let amountConverter = AmountConverter(locateIdentifier: "hi_IN")

// 1
print(amountConverter?.string(from: 12.4520)!)
print(amountConverter?.string(from: -12.4520)!)

// 2
amountConverter?.currencyCodePolicy = .codeUseAlways
print(amountConverter?.string(from: 12.4520)!)
print(amountConverter?.string(from: -12.4520)!)

// 3
amountConverter?.currencyCodePolicy = .codeUseNever
print(amountConverter?.string(from: 12.4520)!)
print(amountConverter?.string(from: -12.4520)!)
