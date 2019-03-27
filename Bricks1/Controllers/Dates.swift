import SwiftDate

func naiveDate(delta: Int? = 0) -> DateInRegion {
    var date = DateInRegion(Date()).convertTo(calendar: Calendar.current, timezone: TimeZone.current)
    
    date = date.dateByAdding(delta!, .day)
    
    date = date.dateAt(.startOfDay)
    
    let dateString = String(date.toISO().split(separator: "T")[0])
    
    return DateInRegion(Date(dateString)!)
}

func convertToDateString(_ date: DateInRegion) -> String {
    return String(date.toISO().split(separator: "T")[0])
}

func convertToDate(_ dateString: String) -> DateInRegion {
    return DateInRegion(Date(dateString)!)
}
