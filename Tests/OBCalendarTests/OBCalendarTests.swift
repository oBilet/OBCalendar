import XCTest
@testable import ObiletCalendar

final class OBCalendarTests: XCTestCase {
    
    func testWeekDay() {
        let date = Date()
        
        let enLocale = Locale(identifier: "en_US")
        let trLocale = Locale(identifier: "tr_TR")
        
        var calendar = Calendar(identifier: .gregorian)
        let targetComponent = Calendar.Component.weekday
        
        calendar.locale = enLocale
        var weekDay = calendar.firstWeekday//calendar.component(targetComponent, from: date)
        XCTAssertTrue(weekDay == 1, "\(weekDay)")
        print(calendar.weekdaySymbols)
        
        calendar.locale = trLocale
        weekDay = calendar.firstWeekday//calendar.component(targetComponent, from: date)
        XCTAssertTrue(weekDay == 2, "\(weekDay)")
        print(calendar.weekdaySymbols)
    }
    
    func testCalendarRange() {
        
        let calendar = Calendar.current
        
        let currentDate = Date()
        
        let upperRange = 100000
        
        self.measure {
            for _ in 0...upperRange {
                let range = calendar.range(of: .day, in: .month, for: currentDate)!
                
                XCTAssertTrue(
                    range.upperBound == calendar.component(.day, from: currentDate)
                )
            }
        }
    }
    
    func testCalendarMonthDif() {
        let calendar = Calendar.current
        let today = Date()
        
        let upperRange = 100000
        
        self.measure {
            for _ in 0...upperRange {
                let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
                
                XCTAssertTrue(
                    calendar.component(.day, from: tomorrow) == 1
                )
            }
        }
    }
}
