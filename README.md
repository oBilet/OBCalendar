
# OBCalendar


- `OBCalendar` is a SwiftUI-based calendar library designed to allow you to easily create your own custom calendars. With this structure, you can customize the days, months, and years.
- To change the locale of calendar-related texts, create a `Calendar` object, set its locale, and pass it to the OBCalendar initializer.
- To configure the date range, pass `startDate` and `drawingRange` to the `OBCalendar`'s initializer.



## Documentation and Tutorial
- You can visit for the <a href="https://obilet.github.io/OBCalendarDocument/documentation/obiletcalendar/" target="_blank">documentation</a>
- You can visit for the <a href="https://obilet.github.io/OBCalendarDocument/tutorials/meetobiletcalendar" target="_blank">tutorial</a> step by step
- Video tutorial: <table><tr>
- [<img width="627" height="444" alt="image" src="https://github.com/user-attachments/assets/faadfa40-577c-4b3f-a1f2-9e317770e708" />](https://youtu.be/nXdM4WMNDkg)
</tr></table>

 

## Example Designs

<div align="center">
  <table>
    <tr>
      <td><img width=300 src="https://github.com/oBilet/OBCalendar/blob/main/SSForReadme/firstSS.png"></td>
      <td><img width=300 src="https://github.com/oBilet/OBCalendar/blob/main/SSForReadme/secondSS.png"></td>
      <td><img width=300 src="https://github.com/oBilet/OBCalendar/blob/main/SSForReadme/thirdSS.png"></td>
    </tr>
    <tr>
     <td><img width=300 src="https://github.com/oBilet/OBCalendar/blob/main/SSForReadme/fourthSS.png"></td>
      <td><img width=300 src="https://github.com/oBilet/OBCalendar/blob/main/SSForReadme/fifthSS.png"></td>
      <td><img width=300 src="https://github.com/oBilet/OBCalendar/blob/main/SSForReadme/sixthSS.png"></td>
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

## Note
For better performance, use `lazyDays: true` and `lazyMonths: true`.
If you are using programmatic scroll, set `lazyYears: false` because subviews need to be loaded into memory once for ScrollViewProxy to recognize their id values.

## Usage

- You can create `OBCalendar` specifying `startDate` (default is: current date) and DrawingRange (day, month or year from startDate) (default `drawingRange` is `.year(1)`).
- Modifiers are optional and you can choose to use `baseView` or use the packed views (daysView, monthsView) inside the modifiers or you can return your custom view.
- The dayModifier's "viewModel" contains `CalendarModel.Year`, `CalendarModel.Month` and `CalendarModel.Day` and a view is created for each day using these models.
- Modifiers should be written in this order: dayModifier -> monthModifier -> yearModifier
- `baseView` in the modifier closures is the default view that has its own custom modification over the previous modifier method's return type, like having a header in months for example.
- `daysView` in the monthModifier and `monthsView` in the yearModifier are the untouched pack of views that will have the modifications from previous modifiers.
- Every modifier has its own viewModel in the closure parameter list. Default name is "viewModel" and it contains some functions and related models: `CalendarModel.Year`, `CalendarModel.Month` and `CalendarModel.Day`.
- The data models which the closures' related viewModels contain are: `Day` + `Month` + `Year` for dayModifier, `Month` +`Year` for month modifier and only `Year` for yearModifier.

- You can fully customize the view for each day, month, and year by calling `dayModifier`, `monthModifier` and `yearModifier` modifier functions each of which accepts `ViewBuilder` blocks.
- This structure facilitates efficient and adaptable development.

- If you'd like to create the calendar from scratch, you can use the base version of it as well. You can customize it even further by setting start and end dates to generating and providing your own date array for custom layouts.

Default:
```swift
// 1 year of drawing range
OBCalendar(drawingRange: .year(1))

// 3 months of drawing range
OBCalendar(drawingRange: .month(3))

// 60 days of drawing range
OBCalendar(drawingRange: .day(60))
```

Range selection example:
```swift
OBCalendar()
   .dayModifier { baseView, viewModel in
      baseView
        .selectable(
          lhsDate: $firstSelectedDate,
          rhsDate: $secondSelectedDate,
          viewModel: viewModel
        )
   }
```


Horizontal Scroll:
```swift
GeometryReader { geometry in
      OBCalendar(
          monthScrollAxis: .horizontal,
          yearScrollAxis: .horizontal
      )
      .monthModifier { baseView, daysView, viewModel in
          baseView
              .padding()
              .frame(width: geometry.size.width)
      }
}
```

DayModifier:
```swift
 OBCalendar()
      .dayModifier { baseView, viewModel in
          baseView
              .background(Color.blue)
              .padding(2)
              .foregroundColor(.white)
      }
```

MonthModifier:
```swift
OBCalendar()
      .monthModifier{ baseView, daysView, viewModel in
          VStack {
              Text("Modified Months")
              Text(viewModel.title)
              daysView
          }
          .padding()
      }
```

Modified Day + Modified Month:
```swift
OBCalendar()
      .dayModifier { baseView, viewModel in
          baseView
              .foregroundColor(Color(.red))
      }
      .monthModifier { baseView, daysView, viewModel in
          VStack {
              Text("Modified Months")
              daysView
          }
          .padding()
      }
```

BaseCalendar
```swift
let today = Date()
let twoYearsLater = calendar.date(byAdding: .year, value: 2, to: today)!

OBBaseCalendar(startDate: today, endDate: twoYearsLater) { model, scrollProxy in
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

BaseCalendar + Custom layouts
```swift
//Implement your own layout
let years = [CalendarModel.Year]() 

// Or use default layout
let defaultLayout = CalendarModelBuilder.defaultLayout(
      calendar: .current,
      startDate: Date(),
      endDate: Date().addingTimeInterval(3600 * 24 * 365)
)

OBBaseCalendar(years: years) { model, scrollProxy in
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

****

Feel free to explore the SwiftUI-powered flexibility of `OBCalendar` to meet your custom calendar needs!













