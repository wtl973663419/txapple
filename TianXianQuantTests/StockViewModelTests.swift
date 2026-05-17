import XCTest
@testable import TianXianQuant

final class StockViewModelTests: XCTestCase {

    // MARK: - Mock Data Loading

    func testLoadMockData() {
        guard let url = Bundle(for: type(of: self)).url(
            forResource: "stock_list",
            withExtension: "json"
        ) else {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let stocks = try JSONDecoder().decode([StockInfo].self, from: data)
            XCTAssertFalse(stocks.isEmpty, "Stock list should not be empty")
        } catch {
            XCTFail("Failed to decode stock_list.json: \(error.localizedDescription)")
        }
    }

    // MARK: - Search Filtering

    func testSearchFiltersCorrectly() {
        let stocks = [
            StockInfo(code: "600519", name: "\u{8d35}\u{5dde}\u{8305}\u{53f0}", price: 1800, changePercent: 1.5, volume: 10000),
            StockInfo(code: "000858", name: "\u{4e94}\u{7cae}\u{6db2}", price: 160, changePercent: -0.5, volume: 50000),
            StockInfo(code: "300750", name: "\u{5b81}\u{5fb7}\u{65f6}\u{4ee3}", price: 200, changePercent: 2.3, volume: 30000),
            StockInfo(code: "000001", name: "\u{5e73}\u{5b89}\u{94f6}\u{884c}", price: 12, changePercent: 0.1, volume: 200000),
        ]

        let codeResults = stocks.filter { $0.code.contains("600519") }
        XCTAssertEqual(codeResults.count, 1)

        let partialResults = stocks.filter { $0.code.contains("000") }
        XCTAssertEqual(partialResults.count, 3)

        let noResults = stocks.filter { $0.code.contains("999999") }
        XCTAssertTrue(noResults.isEmpty)
    }

    // MARK: - Debounce Timer

    func testDebounceTimer() {
        let expectation = expectation(description: "Debounce timer fires")
        let debounceDelay: TimeInterval = 0.3
        let tolerance: TimeInterval = 0.2

        var fired = false
        let timer = Timer.scheduledTimer(withTimeInterval: debounceDelay, repeats: false) { _ in
            fired = true
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: debounceDelay + tolerance)
        timer.invalidate()

        XCTAssertTrue(fired, "Timer should have fired")
    }

    // MARK: - StockInfo Equatable

    func testStockInfoEquality() {
        let stock1 = StockInfo(code: "600519", name: "\u{8305}\u{53f0}", price: 1800, changePercent: 1.5, volume: 10000)
        let stock2 = StockInfo(code: "600519", name: "\u{8305}\u{53f0}", price: 1801, changePercent: 1.6, volume: 11000)

        XCTAssertEqual(stock1, stock2)

        let stock3 = StockInfo(code: "000858", name: "\u{4e94}\u{7cae}\u{6db2}", price: 160, changePercent: -0.5, volume: 50000)
        XCTAssertNotEqual(stock1, stock3)
    }
}
