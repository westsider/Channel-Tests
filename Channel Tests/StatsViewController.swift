//
//  StatsViewController.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/3/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import UIKit
import SciChart

class StatsViewController: UIViewController {

    @IBOutlet weak var chartView: UIView!
    
    @IBOutlet weak var columnView: UIView!

    var spyCloses:[(date:Date, close:Double)] = []
    var profitOpt:[(date:Date, profit:Double)] = []
    var profitStd:[(date:Date, profit:Double)] = []
    var cost:[(date:Date, cost:Double)] = []
    var spyChart:[(date:Date, close:Double)]  = []
    
    let maxBarsOnChart:Int = 1100
    var rangeStart:Int = 0
    let axisY1Id:String = "Y1"
    let axisX1Id:String = "X1"
    let axisY2Id:String = "Y2"
    let axisX2Id:String = "X2"
    let axisY3Id:String = "Y3"
    var sciChartView1 = SCIChartSurface()
    var sciChartView2 = SCIChartSurface()
    let rangeSync = SCIAxisRangeSynchronization()
    let sizeAxisAreaSync = SCIAxisAreaSizeSynchronization()
    let rolloverModifierSync = SCIMultiSurfaceModifier(modifierType: SCIRolloverModifier.self)
    let pinchZoomModifierSync = SCIMultiSurfaceModifier(modifierType: SCIPinchZoomModifier.self)
    let yDragModifierSync = SCIMultiSurfaceModifier(modifierType: SCIYAxisDragModifier.self)
    let xDragModifierSync = SCIMultiSurfaceModifier(modifierType: SCIXAxisDragModifier.self)
    let zoomExtendsSync = SCIMultiSurfaceModifier(modifierType: SCIZoomExtentsModifier.self)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        completeConfiguration()
        
    }

    // MARK: Overrided Functions
    func completeConfiguration() {
        profitOpt = OptBacktest().populateProfitChart()
        profitStd = StdBacktest().populateProfitChart()
        cost =  OptBacktest().populateCostChart()
        spyChart = Prices().matchSpyToBacktestData(ticker: "SPY", debug: false)
        
        for each in spyChart {
            print("SPY Date \(each.date) close \(each.close)")
        }
        configureChartSuraface()
        addAxis(BarsToShow: maxBarsOnChart)
        addModifiers()
        topChartDataSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        topChartStdSeries(surface: sciChartView1, xID: axisX1Id, yID: axisY1Id)
        topChartSpySeries(surface: sciChartView1, xID: axisX1Id, yID: axisY3Id)
        bottomChartDataSeries(surface: sciChartView2, xID: axisX2Id, yID: axisY2Id)
    }
    
    //MARK: - Add Profit Series
    fileprivate func topChartDataSeries(surface:SCIChartSurface, xID:String, yID:String) {
        let cumulativeProfit = SCIXyDataSeries(xType: .dateTime, yType: .double)
        cumulativeProfit.acceptUnsortedData = true
        
        for things in profitOpt {
            cumulativeProfit.appendX(SCIGeneric(things.date), y: SCIGeneric(things.profit))
        }
        let topChartRenderSeries = SCIFastLineRenderableSeries()
        topChartRenderSeries.dataSeries = cumulativeProfit
        topChartRenderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), withThickness: 1.0)
        topChartRenderSeries.xAxisId = xID
        topChartRenderSeries.yAxisId = yID
        surface.renderableSeries.add(topChartRenderSeries)
    }
    
    //MARK: - Profit Series befor optimization
    fileprivate func topChartStdSeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let smaDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .double)
        
        for ( things) in profitStd {
            smaDataSeries.appendX(SCIGeneric(things.date), y: SCIGeneric(things.profit))
        }
        
        let renderSeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        renderSeries.dataSeries = smaDataSeries
        renderSeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), withThickness: 0.7)
        renderSeries.style.isDigitalLine = false
        renderSeries.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSeries.xAxisId = xID
        renderSeries.yAxisId = yID
        surface.renderableSeries.add(renderSeries)
    }
    
    //MARK: - Spy Series
    fileprivate func topChartSpySeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let spyDataSeries:SCIXyDataSeries = SCIXyDataSeries(xType: .dateTime, yType: .double)
        
        for ( things) in spyChart {
            spyDataSeries.appendX(SCIGeneric(things.date), y: SCIGeneric(things.close))
        }
        
        let renderSpySeries:SCIFastLineRenderableSeries = SCIFastLineRenderableSeries()
        renderSpySeries.dataSeries = spyDataSeries
        renderSpySeries.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1), withThickness: 0.7)
        renderSpySeries.style.isDigitalLine = false
        renderSpySeries.hitTestProvider().hitTestMode = .verticalInterpolate
        renderSpySeries.xAxisId = xID
        renderSpySeries.yAxisId = yID
        surface.renderableSeries.add(renderSpySeries)
    }
    
    //MARK: - Cost Data Series
    fileprivate func bottomChartDataSeries(surface:SCIChartSurface, xID:String, yID:String)  {
        let cumulativeCost = SCIXyDataSeries(xType: .dateTime, yType: .double)
        cumulativeCost.acceptUnsortedData = true
        
        for things in cost {
            cumulativeCost.appendX(SCIGeneric(things.date), y: SCIGeneric(things.cost))
        }
        let bottomChartRenderSeries = SCIFastColumnRenderableSeries()
        bottomChartRenderSeries.dataSeries = cumulativeCost
        bottomChartRenderSeries.xAxisId = xID
        bottomChartRenderSeries.yAxisId = yID
        bottomChartRenderSeries.dataSeries = cumulativeCost
        bottomChartRenderSeries.paletteProvider = ColumnsTripleColorPalette()
        surface.renderableSeries.add(bottomChartRenderSeries)
    }
    
    fileprivate func configureChartSuraface() {
        sciChartView1 = SCIChartSurface(frame: self.chartView.bounds)
        sciChartView1.frame = self.chartView.bounds
        sciChartView1.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        sciChartView1.translatesAutoresizingMaskIntoConstraints = true
        self.chartView.addSubview(sciChartView1)
        
        sciChartView2 = SCIChartSurface(frame: self.columnView.bounds)
        sciChartView2.frame = self.columnView.bounds
        sciChartView2.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        sciChartView2.translatesAutoresizingMaskIntoConstraints = true
        self.columnView.addSubview(sciChartView2)
    }
    
    fileprivate func addAxis(BarsToShow: Int) {
        
        let dateAxisSize:Float = 9.0
        let dollarAxisSize :Float = 12.0
        
        let totalBars:Int = profitOpt.count
        rangeStart = totalBars - BarsToShow
        
        let axisX1:SCICategoryDateTimeAxis = SCICategoryDateTimeAxis()
        axisX1.axisId = axisX1Id
        rangeSync.attachAxis(axisX1)
        
        axisX1.visibleRange = SCIDoubleRange(min: SCIGeneric(rangeStart), max: SCIGeneric(totalBars))
        axisX1.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisX1.style.labelStyle.fontName = "Helvetica"
        axisX1.style.labelStyle.fontSize = dateAxisSize
        
        sciChartView1.xAxes.add(axisX1)
        
        let axisY1:SCINumericAxis = SCINumericAxis()
        axisY1.axisId = axisY1Id
        axisY1.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisY1.style.labelStyle.fontName = "Helvetica"
        axisY1.style.labelStyle.fontSize = dollarAxisSize
        axisY1.autoRange = .always
        sciChartView1.yAxes.add(axisY1)
        
        let axisX2:SCICategoryDateTimeAxis = SCICategoryDateTimeAxis()
        axisX2.axisId = axisX2Id
        rangeSync.attachAxis(axisX2)
        axisX2.visibleRange = SCIDoubleRange(min: SCIGeneric(rangeStart), max: SCIGeneric(totalBars))
        axisX2.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisX2.style.labelStyle.fontName = "Helvetica"
        axisX2.style.labelStyle.fontSize = dateAxisSize
        sciChartView2.xAxes.add(axisX2)
        
        let axisY2:SCINumericAxis = SCINumericAxis()
        axisY2.axisId = axisY2Id
        axisY2.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisY2.style.labelStyle.fontName = "Helvetica"
        axisY2.style.labelStyle.fontSize = dollarAxisSize
        axisY2.autoRange = .always
        sciChartView2.yAxes.add(axisY2)
        
        let axisY3:SCINumericAxis = SCINumericAxis()
        axisY3.axisId = axisY3Id
        axisY3.growBy = SCIDoubleRange(min: SCIGeneric(0.1), max: SCIGeneric(0.1))
        axisY3.style.labelStyle.fontName = "Helvetica"
        axisY3.style.labelStyle.fontSize = dollarAxisSize
        axisY3.axisAlignment = .left
        axisY3.autoRange = .always
        sciChartView1.yAxes.add(axisY3)
    }
    
    fileprivate func addModifiers() {
        sizeAxisAreaSync.syncMode = .right
        sizeAxisAreaSync.attachSurface(sciChartView1)
        sizeAxisAreaSync.attachSurface(sciChartView2)
        
        var yDragModifier = yDragModifierSync.modifier(forSurface: sciChartView1) as? SCIYAxisDragModifier
        yDragModifier?.axisId = axisY1Id
        yDragModifier?.dragMode = .pan;
        
        var xDragModifier = xDragModifierSync.modifier(forSurface: sciChartView1) as? SCIXAxisDragModifier
        xDragModifier?.axisId = axisX1Id
        xDragModifier?.dragMode = .pan;
        
        var modifierGroup = SCIChartModifierCollection(childModifiers: [rolloverModifierSync, yDragModifierSync, pinchZoomModifierSync, zoomExtendsSync, xDragModifierSync])
        sciChartView1.chartModifiers = modifierGroup
        
        yDragModifier = yDragModifierSync.modifier(forSurface: sciChartView2) as? SCIYAxisDragModifier
        yDragModifier?.axisId = axisY2Id
        yDragModifier?.dragMode = .pan;
        
        xDragModifier = xDragModifierSync.modifier(forSurface: sciChartView2) as? SCIXAxisDragModifier
        xDragModifier?.axisId = axisX2Id
        xDragModifier?.dragMode = .pan;
        
        modifierGroup = SCIChartModifierCollection(childModifiers: [rolloverModifierSync, yDragModifierSync, pinchZoomModifierSync, zoomExtendsSync, xDragModifierSync])
        sciChartView2.chartModifiers = modifierGroup
    }
    
    func addAxisMarkerAnnotation(surface:SCIChartSurface, yID:String, color:UIColor, valueFormat:String, value:SCIGenericType){
        let axisMarker:SCIAxisMarkerAnnotation = SCIAxisMarkerAnnotation()
        axisMarker.yAxisId = yID;
        axisMarker.style.margin = 5;
        
        let textFormatting:SCITextFormattingStyle = SCITextFormattingStyle();
        textFormatting.color = UIColor.white;
        textFormatting.fontSize = 14;
        axisMarker.style.textStyle = textFormatting;
        axisMarker.formattedValue = String.init(format: valueFormat, SCIGenericDouble(value));
        axisMarker.coordinateMode = .absolute
        axisMarker.style.backgroundColor = color
        axisMarker.position = value;
        //print("SMA Anntation \(value.doubleData)")
        surface.annotations.add(axisMarker);
    }
    
    func updateNVActivity(with:String) {
        DispatchQueue.main.async {
            //NVActivityIndicatorPresenter.sharedInstance.setMessage(with)
        }
    }
}

class ColumnsTripleColorPalette : SCIPaletteProvider {
    let style1 : SCIColumnSeriesStyle = SCIColumnSeriesStyle()
    let style2 : SCIColumnSeriesStyle = SCIColumnSeriesStyle()
    let style3 : SCIColumnSeriesStyle = SCIColumnSeriesStyle()
    
    override init() {
        super.init()
        
        style1.fillBrushStyle = SCILinearGradientBrushStyle(colorStart: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), finish: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), direction: .vertical)
        style1.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), withThickness: 0.2)
        style2.fillBrushStyle = SCILinearGradientBrushStyle(colorStart: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), finish: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), direction: .vertical)
        style2.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), withThickness: 0.2)
        style3.fillBrushStyle = SCILinearGradientBrushStyle(colorStart: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), finish: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), direction: .vertical)
        style3.strokeStyle = SCISolidPenStyle(color: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), withThickness: 0.2)
    }
    
    override func styleFor(x: Double, y: Double, index: Int32) -> SCIStyleProtocol! {
        let styleIndex : Int32 = index % 3;
        if (styleIndex == 0) {
            return style1;
        } else if (styleIndex == 1) {
            return style2;
        } else {
            return style3;
        }
    }

}
