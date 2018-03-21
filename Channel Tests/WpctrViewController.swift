//
//  WpctrViewController.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/21/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import UIKit
import SciChart

class WpctrViewController: UIViewController {

    @IBOutlet weak var chartView: UIView!
    //var sciChartSurface = SCIChartSurface(frame: frame)

    let dataSeries = SCIXyDataSeries(xType: .float, yType: .float)
    var sciChartSurface = SCIChartSurface()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sciChartSurface = SCIChartSurface(frame: self.chartView.bounds)
        sciChartSurface.frame = self.chartView.bounds
        sciChartSurface.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        sciChartSurface.translatesAutoresizingMaskIntoConstraints = true
        self.chartView.addSubview(sciChartSurface)
        
        let wpctrData = WpctrStats().getAllStats(debug: false)
        for each in wpctrData {
            dataSeries.appendX(SCIGeneric(each.profit), y: SCIGeneric(each.wpctR))
        }
        
        // Create a SCIXyScatterRenderableSeries and apply DataSeries
        let scatterRenderableSeries = SCIXyScatterRenderableSeries()
        scatterRenderableSeries.dataSeries = dataSeries
        
        // Create and style PointMarker
        let ellipse = SCIEllipsePointMarker()
        ellipse.fillStyle = SCISolidBrushStyle(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)) //SCISolidBrushStyle(colorCode: 0xffff6600)
        ellipse.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), withThickness: 0.5) // SCISolidPenStyle(colorCode: 0xffffffff, withThickness: 1)
        ellipse.detalization = 20
        ellipse.height = 1.0
        ellipse.width = 1.0
        scatterRenderableSeries.style.pointMarker = ellipse
        
        // Note Surface must have an XAxis/YAxis of type SCINumericAxis to match the float,float data
        let xAxis = SCINumericAxis()
        xAxis.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        sciChartSurface.yAxes.add(xAxis)
        
        let yAxis = SCINumericAxis()
        yAxis.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        sciChartSurface.xAxes.add(yAxis)
        
        // Add the Line Series to an existing SciChartSurface
        sciChartSurface.renderableSeries.add(scatterRenderableSeries)
    }

}
