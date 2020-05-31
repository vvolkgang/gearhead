import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/src/text_element.dart' as txt;
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:flutter/painting.dart';

//https://github.com/google/charts/issues/58

String _title;

String _subTitle;

class ToolTipMgr {
  static String get title => _title;

  static String get subTitle => _subTitle;

  static void setTitle(Map<String, dynamic> data) {
    if (data['title'] != null && data['title'].length > 0 == true) {
      _title = data['title'] as String;
    }

    if (data['subTitle'] != null && data['subTitle'].length > 0 == true) {
      _subTitle = data['subTitle'] as String;
    }
  }

  static void setTitleString(String data) {
    _title = data;
  }
}

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  final BuildContext context;
  
  CustomCircleSymbolRenderer(this.context);

  @override
  void paint(ChartCanvas canvas, Rectangle bounds,
      {List<int> dashPattern, Color fillColor, FillPatternType fillPattern, Color strokeColor, double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern, fillColor: fillColor, fillPattern: fillPattern, strokeColor: strokeColor, strokeWidthPx: strokeWidthPx);
    
    var circleLine = ColorUtil.fromDartColor(Theme.of(context).accentColor.withOpacity(0.4));
    var circleColor = ColorUtil.fromDartColor(Theme.of(context).accentColor);
    canvas.drawCircleSector(Point(bounds.left + 3, bounds.top - 21), 15, 0, 0, 2*pi, fill: circleLine);
    canvas.drawCircleSector(Point(bounds.left + 3, bounds.top - 21), 12, 0, 0, 2*pi, fill: circleColor);
    final textStyle = style.TextStyle();
    textStyle.color = Color.white;
    textStyle.fontSize = 15;
    canvas.drawText(txt.TextElement(ToolTipMgr.title, style: textStyle), (bounds.left -5).round(), (bounds.top - 28).round());
  }
}
