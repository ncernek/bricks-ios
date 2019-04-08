import Charts


func updateBarChart(_ weeklyGrades: [Int], barChartView: BarChartView) {
    
    var allDataEntries = [BarChartDataEntry]()
    for (i, value) in weeklyGrades.enumerated() {
        allDataEntries.append(BarChartDataEntry(x:Double(i), y: Double(value)))
    }
    
    let chartDataSet = BarChartDataSet(values: allDataEntries, label: nil)
    chartDataSet.setColor(UIColor.defaultGreen)
    chartDataSet.drawValuesEnabled = false
    chartDataSet.highlightEnabled = false
    
    let chartData = BarChartData(dataSet: chartDataSet)
    barChartView.data = chartData
    
    // FORMATTING
    
    // turn off features
    barChartView.leftAxis.enabled = false
    barChartView.rightAxis.enabled = false
    barChartView.legend.enabled = false
    barChartView.drawValueAboveBarEnabled = false
    barChartView.isUserInteractionEnabled = false
    
    // format x axis
    barChartView.xAxis.drawGridLinesEnabled = false
    barChartView.xAxis.drawAxisLineEnabled = false
    barChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
    let days = ["M", "T", "W", "T", "F", "S", "S"]
    barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values:days)
    barChartView.xAxis.granularity = 1
    
    // format y axis
    barChartView.leftAxis.axisMinimum = 0
    barChartView.leftAxis.axisMaximum = 5
    
    barChartView.minOffset = 0
    barChartView.isHidden = true
}

func updatePieChart(_ streak: Int = 20, goal: Int = 30, pieChartView: PieChartView) {
    let streakEntry = PieChartDataEntry(value: Double(streak))
    let goalEntry = PieChartDataEntry(value: Double(goal - streak))
    
    let dataSet = PieChartDataSet(values: [streakEntry, goalEntry], label: nil)
    dataSet.colors = [UIColor.defaultGreen, UIColor.customGrey]
    dataSet.drawValuesEnabled = false
    dataSet.highlightEnabled = false
    dataSet.selectionShift = 0
    
    pieChartView.data = PieChartData(dataSet: dataSet)
    
    // FORMATTING
    
    // turn off features
    pieChartView.legend.enabled = false
    //        pieChart.chartDescription?.enabled = false
    pieChartView.isUserInteractionEnabled = false
    
    // format art
    pieChartView.rotationAngle = 270
    
    
    // add labels
    pieChartView.centerText = String(streak)
    pieChartView.isHidden = true
    
}
