
import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'BikeModel.dart';

class SpeedTimeBezierChart extends StatelessWidget {
  List<DataPoint<double>> _getList(BikeModel bike) {
    final List<DataPoint<double>> dataList = <DataPoint<double>>[];
    bike.createSpeedTimeList().forEach((p) => dataList.add(DataPoint<double>(xAxis: p.x.toDouble(), value: p.y.toDouble())));

    return dataList;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.red,
        height: 300,
        // width: MediaQuery.of(context).size.width * 0.9,
        child: Consumer<BikeModel>(builder: (context, bikeModel, child) {
          return BezierChart(
            bezierChartScale: BezierChartScale.CUSTOM,
            xAxisCustomValues: _getList(bikeModel).map((e) => e.xAxis).toList(),
            series: [
              BezierLine(
                data: _getList(bikeModel),
              ),
            ],
            config: BezierChartConfig(
              displayYAxis: true,
              stepsYAxis: 3000,
              verticalIndicatorStrokeWidth: 10.0,
              verticalIndicatorColor: Colors.black26,
              showVerticalIndicator: true,
              backgroundColor: Colors.transparent,
              contentWidth: MediaQuery.of(context).size.width * 2,
            ),
          );
        }),
      ),
    );
  }
}