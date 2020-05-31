import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/src/text_element.dart' as txt;
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:flutter/painting.dart';

//https://github.com/google/charts/issues/58

mixin ToolTipMgr {

  static Map<String, String> _selectedValues = <String, String>{};

  static void setSelectedValue(String chartId, String selectedValue) {
    _selectedValues[chartId] = selectedValue;
  }

  static String getSelectedValue(String chartId) => _selectedValues[chartId];
}

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  final BuildContext _context;
  final String _chartId;

  CustomCircleSymbolRenderer(this._context, this._chartId);

  @override
  void paint(ChartCanvas canvas, Rectangle bounds,
      {List<int> dashPattern, Color fillColor, FillPatternType fillPattern, Color strokeColor, double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern, fillColor: fillColor, fillPattern: fillPattern, strokeColor: strokeColor, strokeWidthPx: strokeWidthPx);

    final circleLine = ColorUtil.fromDartColor(Theme.of(_context).accentColor.withOpacity(0.4));
    final circleColor = ColorUtil.fromDartColor(Theme.of(_context).accentColor);
    canvas.drawCircleSector(Point(bounds.left + 3, bounds.top - 21), 15, 0, 0, 2 * pi, fill: circleLine);
    canvas.drawCircleSector(Point(bounds.left + 3, bounds.top - 21), 12, 0, 0, 2 * pi, fill: circleColor);
    final textStyle = style.TextStyle();
    textStyle.color = Color.white;
    textStyle.fontSize = 15;
    canvas.drawText(txt.TextElement(ToolTipMgr.getSelectedValue(_chartId), style: textStyle), (bounds.left - 5).round(), (bounds.top - 28).round());
  }
}
