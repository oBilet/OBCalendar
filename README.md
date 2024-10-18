
# OBCalendar


- `OBCalendar` is a SwiftUI-based calendar library designed to allow you to easily create your own custom calendars. With this structure, you can customize the days, months, and years. Additionally, you can change the localization of the calendar and display days within specific ranges.
- Users set the `startDate` and `endDate` in `OBCalendar`, and the range is created automatically.



## Documentation and Tutorial
- You can visit for the <a href="https://obilet.github.io/OBCalendarDocument/documentation/obiletcalendar/" target="_blank">documentation</a>
- You can visit for the <a href="https://obilet.github.io/OBCalendarDocument/tutorials/obiletcalendar/" target="_blank">tutorial</a> step by step

## Examples

<div align="center">
  <table>
    <tr>
      <td><img width=300 src="https://github.com/developerburakgul/OBCalendarDemoPrivate/blob/main/Sources/OBCalendar/ObiletCalendar.docc/Resources/ForReadme/firstSS.png"></td>
      <td><img width=300 src="https://github.com/developerburakgul/OBCalendarDemoPrivate/blob/main/Sources/OBCalendar/ObiletCalendar.docc/Resources/ForReadme/secondSS.png"></td>
      <td><img width=300 src="https://github.com/developerburakgul/OBCalendarDemoPrivate/blob/main/Sources/OBCalendar/ObiletCalendar.docc/Resources/ForReadme/thirdSS.png"></td>
    </tr>
    <tr>
     <td><img width=300 src="https://github.com/developerburakgul/OBCalendarDemoPrivate/blob/main/Sources/OBCalendar/ObiletCalendar.docc/Resources/ForReadme/fourthSS.png"></td>
      <td><img width=300 src="https://github.com/developerburakgul/OBCalendarDemoPrivate/blob/main/Sources/OBCalendar/ObiletCalendar.docc/Resources/ForReadme/fifthSS.png"></td>
      <td><img width=300 src="https://github.com/developerburakgul/OBCalendarDemoPrivate/blob/main/Sources/OBCalendar/ObiletCalendar.docc/Resources/ForReadme/sixthSS.png"></td>
    </tr>
  </table>
</div>

## Requirements
- iOS 14+
- Swift 5.10+

## Installation
To integrate `OBCalendar` into your project using Swift Package Manager, follow these steps:
- Open your Xcode project.
- Go to File > Add Packages.
- In the search bar, enter the following URL :
  
    ```
    https://github.com/oBilet/OBCalendar.git
    ```
- Choose the package version or branch and click Add Package.

## Usage
```swift
let today = Date()
let twoYearsLater = calendar.date(byAdding: .year, value: 2, to: today)!
return OBCalendar(startingDate: today, endingDate: twoYearsLater) { model, scrollProxy in
    // day view goes here
    let day = model.day
    Text("\(day.day)")
} monthContent: { model, scrollProxy, daysView in
    // month view goes here
    daysView
} yearContent: { model, scrollProxy, monthsView in
    // year view goes here
      monthsView
}
```

- You can create `OBCalendar` specifying `startingDate` and `endingDate`.
- The first model consists of `CalendarModel.Year`, `CalendarModel.Month` and `CalendarModel.Day` and a view is created for each day using this model in the first block
- The second model consists of `CalendarModel.Year` and `CalendarModel.Month`. In block 2, you can customize the view for each month by using this model and the collection of `day views` from the previous block and adding `daysView`.
- The third model consists of `CalendarModel.Year`.  In block 3, using this model and the collection of `month views` from the previous block, `monthsView` is created and you can customize the view for each year by adding

- You can fully customize the view for each day, month, and year using SwiftUI blocks, providing a seamless and dynamic user experience.

****

Feel free to explore the SwiftUI-powered flexibility of `OBCalendar` to meet your custom calendar needs!













