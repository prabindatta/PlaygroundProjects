import Foundation

public enum AmountConverterCurrencyCodePolicy {
    case codeUseAsPerLocale,
         codeUseAlways,
         codeUseNever
}

public class AmountConverter {
    
    public let locale: Locale
    public var amountNumberFormatter: NumberFormatter?
    public var amountNumberFormatterNoCurrency: NumberFormatter?
    public var currencyCodePolicy: AmountConverterCurrencyCodePolicy? {
        didSet {
            amountNumberFormatter = nil
            amountNumberFormatterNoCurrency = nil
        }
    }
    
    public init?(locateIdentifier: String?) {
        if let locateIdentifier = locateIdentifier {
            self.locale = Locale.init(identifier: locateIdentifier)
        } else {
            self.locale = Locale.autoupdatingCurrent
        }
    }
    
    public func string(from amountNumber: NSNumber) -> String? {
        self.string(from: amountNumber, useCurrency: true)
    }
    
    public func string(fromNumberNoCurrency amountNumber: NSNumber) -> String?  {
        self.string(from: amountNumber, useCurrency: false)
    }
    
    public func string(from amountDecimalNumber: NSDecimalNumber) -> String?  {
        self.string(from: amountDecimalNumber, useCurrency: true)
    }
    
    public func string(fromDecimalNumberNoCurrency amountDecimalNumber: NSDecimalNumber) -> String?  {
        self.string(from: amountDecimalNumber, useCurrency: false)
    }
    
    public func string(from amountNumber: NSNumber, useCurrency: Bool, maxFractionDigit: UInt = UInt.max) -> String? {
        
        var nf = useCurrency ? amountNumberFormatter : amountNumberFormatterNoCurrency
        if nf == nil {
            nf = NumberFormatter()
            nf?.numberStyle = .currency
            nf?.locale = self.locale
            
            switch self.currencyCodePolicy {
            case .codeUseAlways:
                guard var positiveFormat = nf?.positiveFormat else { return nil }
                
                if !positiveFormat.contains("¤¤") && positiveFormat.contains("¤") {
                    positiveFormat = positiveFormat.replacingOccurrences(of: "¤", with: "¤¤")
                    nf?.positiveFormat = positiveFormat
                }
                
                guard var negativeFormat = nf?.negativeFormat else { return nil }
                
                if !negativeFormat.contains("¤¤") && negativeFormat.contains("¤") {
                    negativeFormat = negativeFormat.replacingOccurrences(of: "¤", with: "¤¤")
                    nf?.negativeFormat = negativeFormat
                }
                
            case .codeUseNever:
                guard var positiveFormat = nf?.positiveFormat else { return nil }
                
                if positiveFormat.contains("¤¤") {
                    positiveFormat = positiveFormat.replacingOccurrences(of: "¤¤", with: "¤")
                    nf?.positiveFormat = positiveFormat
                }
                
                guard var negativeFormat = nf?.negativeFormat else { return nil }
                
                if negativeFormat.contains("¤¤") {
                    negativeFormat = negativeFormat.replacingOccurrences(of: "¤¤", with: "¤")
                    nf?.negativeFormat = negativeFormat
                }
                
            case .codeUseAsPerLocale, .none:
                break
            }
            
            guard var negativeFormat = nf?.negativeFormat else { return nil }
            
            if negativeFormat.contains("(") {
                negativeFormat = negativeFormat.replacingOccurrences(of: "(", with: "")
                negativeFormat = negativeFormat.replacingOccurrences(of: ")", with: "")
                negativeFormat = "-\(negativeFormat)"
                nf?.negativeFormat = negativeFormat
            }
            
            amountNumberFormatter = nf
        }
        
        if !useCurrency {
            var positiveFormat = nf?.positiveFormat
            positiveFormat = positiveFormat?.replacingOccurrences(of: "¤", with: "")
            positiveFormat = positiveFormat?.trimmingCharacters(in: .whitespacesAndNewlines)
            nf?.positiveFormat = positiveFormat
            
            var negativeFormat = nf?.negativeFormat
            negativeFormat = negativeFormat?.replacingOccurrences(of: "¤", with: "")
            negativeFormat = negativeFormat?.trimmingCharacters(in: .whitespacesAndNewlines)
            nf?.negativeFormat = negativeFormat
            
            amountNumberFormatterNoCurrency = nf
        }
        
        let amountString: String?
        if maxFractionDigit == UInt.max {
            amountString = nf?.string(from: amountNumber)
        } else {
            nf?.maximumFractionDigits = Int(maxFractionDigit)
            amountString = nf?.string(from: amountNumber)
        }
        
        return amountString
    }
    
    public func number(fromString inputString: String) -> NSDecimalNumber {
        NSDecimalNumber.init(string: inputString, locale: self.locale)
    }
}
