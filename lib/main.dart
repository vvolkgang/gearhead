import 'package:charts_flutter/flutter.dart' as charts;
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'BikeModel.dart';
import 'ChartUtils.dart';
import 'NumericFormField.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.deepPurple, visualDensity: VisualDensity.adaptivePlatformDensity, brightness: Brightness.light),
      home: ChangeNotifierProvider<BikeModel>(create: (context) => BikeModel(), child: const MyHomePage(title: 'Gear Head')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final bikeModel = Provider.of<BikeModel>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GearboxRatiosCard(),
              Text(
                'Final Drive: ${bikeModel.finalDrive.toStringAsFixed(3)}',
              ),
              SprocketsCard(),
              const Divider(),
              Text(
                'Wheel Radius (m): ${bikeModel.wheelRadius.toStringAsFixed(3)}',
              ),
              RearWheelCard(),
              EngineInfoCard(),
              Text(
                'Total weight (kg): ${bikeModel.totalWeight.toStringAsFixed(3)}',
              ),
              Text(
                'Roll Resistance Force (N): ${bikeModel.rollResistanceForce.toStringAsFixed(3)}',
              ),
              OtherInfoCard(),
              const Divider(),
              Text(
                'Max Acceleration (m/s^2): ${bikeModel.maxAcceleration.toStringAsFixed(1)}',
              ),
              Text(
                'Max Speeds trans limited (km/h): ${bikeModel.maxSpeedTransLimited.toStringAsFixed(1)}',
              ),
              const Divider(),
              const Text(
                'Max Speeds per gear (km/h):',
              ),
              Text('1st: ${bikeModel.getMaxSpeedForGear(1).toStringAsFixed(1)}'),
              Text('2nd: ${bikeModel.getMaxSpeedForGear(2).toStringAsFixed(1)}'),
              Text('3rd: ${bikeModel.getMaxSpeedForGear(3).toStringAsFixed(1)}'),
              Text('4th: ${bikeModel.getMaxSpeedForGear(4).toStringAsFixed(1)}'),
              Text('5th: ${bikeModel.getMaxSpeedForGear(5).toStringAsFixed(1)}'),
              Text('6th: ${bikeModel.getMaxSpeedForGear(6).toStringAsFixed(1)}'),
              const Text('Speed per Gear Plot:'),
              SizedBox(
                height: 300,
                child: charts.LineChart(bikeModel.createSpeedPerRpmData(),
                    animate: true,
                    defaultRenderer: charts.LineRendererConfig(includeArea: false, stacked: true, roundEndCaps: false),
                    selectionModels: [
                      charts.SelectionModelConfig(changedListener: (charts.SelectionModel model) {
                        if (model.hasDatumSelection) {
                          ToolTipMgr.setSelectedValue('speedPerRpmChart', model.selectedSeries[0].measureFn(model.selectedDatum[0].index).toString());
                        }
                      })
                    ],
                    behaviors: [
                      charts.PanAndZoomBehavior(),
                      //charts.LinePointHighlighter(symbolRenderer: CustomCircleSymbolRenderer(context, 'speedPerRpmChart'))
                    ]),
              ),
              const Divider(),
              const Text('Torque Plot:'),
              SizedBox(
                height: 300,
                child: charts.LineChart(bikeModel.createTorquePerRpmData(),
                    animate: true,
                    defaultRenderer: charts.LineRendererConfig(includeArea: false, stacked: true, roundEndCaps: true),
                    selectionModels: [
                      charts.SelectionModelConfig(changedListener: (charts.SelectionModel model) {
                        if (model.hasDatumSelection) {
                          ToolTipMgr.setSelectedValue('torqueChart', model.selectedSeries[0].measureFn(model.selectedDatum[0].index).toString());
                        }
                      })
                    ],
                    behaviors: [
                      charts.PanAndZoomBehavior(),
                      charts.LinePointHighlighter(symbolRenderer: CustomCircleSymbolRenderer(context, 'torqueChart'))
                    ]),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GearboxRatiosCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Gearbox Ratios',
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                expanded: Consumer<BikeModel>(
                  builder: (context, bikeModel, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DoubleFormField(
                        initialValue: '${bikeModel.getGearing(0)}',
                        onChanged: (value) => bikeModel.setGearing(0, value),
                        decoration: const InputDecoration(
                          labelText: 'Primary',
                        ),
                      ),
                      DoubleFormField(
                        initialValue: '${bikeModel.getGearing(1)}',
                        onChanged: (value) => bikeModel.setGearing(1, value),
                        decoration: const InputDecoration(
                          labelText: '1',
                        ),
                      ),
                      DoubleFormField(
                        initialValue: '${bikeModel.getGearing(2)}',
                        onChanged: (value) => bikeModel.setGearing(2, value),
                        decoration: const InputDecoration(
                          labelText: '2',
                        ),
                      ),
                      DoubleFormField(
                        initialValue: '${bikeModel.getGearing(3)}',
                        onChanged: (value) => bikeModel.setGearing(3, value),
                        decoration: const InputDecoration(
                          labelText: '3',
                        ),
                      ),
                      DoubleFormField(
                        initialValue: '${bikeModel.getGearing(4)}',
                        onChanged: (value) => bikeModel.setGearing(4, value),
                        decoration: const InputDecoration(
                          labelText: '4',
                        ),
                      ),
                      DoubleFormField(
                        initialValue: '${bikeModel.getGearing(5)}',
                        onChanged: (value) => bikeModel.setGearing(5, value),
                        decoration: const InputDecoration(
                          labelText: '5',
                        ),
                      ),
                      DoubleFormField(
                        initialValue: '${bikeModel.getGearing(6)}',
                        onChanged: (value) => bikeModel.setGearing(6, value),
                        decoration: const InputDecoration(
                          labelText: '6',
                        ),
                      ),
                    ],
                  ),
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class SprocketsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Sprockets',
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                expanded: Consumer<BikeModel>(
                  builder: (context, bikeModel, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      IntFormField(
                        onChanged: (value) => bikeModel.frontSprocketTeeth = value,
                        initialValue: '${bikeModel.frontSprocketTeeth}',
                        decoration: const InputDecoration(
                          labelText: 'Front Sprocket',
                        ),
                      ),
                      IntFormField(
                        onChanged: (value) => bikeModel.rearSprocketTeeth = value,
                        initialValue: '${bikeModel.rearSprocketTeeth}',
                        decoration: const InputDecoration(
                          labelText: 'Rear Sprocket',
                        ),
                      ),
                    ],
                  ),
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class RearWheelCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Rear Wheel Information',
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                expanded: Consumer<BikeModel>(
                  builder: (context, bikeModel, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      IntFormField(
                        onChanged: (value) => bikeModel.rimSize = value,
                        initialValue: '${bikeModel.rimSize}',
                        decoration: const InputDecoration(
                          labelText: 'Rim size (inch)',
                        ),
                      ),
                      IntFormField(
                        onChanged: (value) => bikeModel.tireWidth = value,
                        initialValue: '${bikeModel.tireWidth}',
                        decoration: const InputDecoration(
                          labelText: 'Tire Width (mm)',
                        ),
                      ),
                      IntFormField(
                        onChanged: (value) => bikeModel.tireAspectRation = value,
                        initialValue: '${bikeModel.tireAspectRation}',
                        decoration: const InputDecoration(
                          labelText: 'Tire Aspect Ratio',
                        ),
                      ),
                    ],
                  ),
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class EngineInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Engine Information',
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                expanded: Consumer<BikeModel>(
                  builder: (context, bikeModel, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      IntFormField(
                        onChanged: (value) => bikeModel.maxRpm = value,
                        initialValue: '${bikeModel.maxRpm}',
                        decoration: const InputDecoration(
                          labelText: 'Max RPM',
                        ),
                      ),
                      IntFormField(
                        onChanged: (value) => bikeModel.maxTorque = value,
                        initialValue: '${bikeModel.maxTorque}',
                        decoration: const InputDecoration(
                          labelText: 'Max Torque (Nm)',
                        ),
                      ),
                      IntFormField(
                        onChanged: (value) => bikeModel.launchControlRpm = value,
                        initialValue: '${bikeModel.launchControlRpm}',
                        decoration: const InputDecoration(
                          labelText: 'Launch Control RPM',
                        ),
                      ),
                      DoubleFormField(
                        onChanged: (value) => bikeModel.powerLossInTransmission = value,
                        initialValue: '${bikeModel.powerLossInTransmission}',
                        decoration: const InputDecoration(
                          labelText: 'Power Loss in Transmission',
                        ),
                      ),
                    ],
                  ),
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class OtherInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      'Misc. Info',
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                expanded: Consumer<BikeModel>(
                  builder: (context, bikeModel, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DoubleFormField(
                        onChanged: (value) => bikeModel.frontArea = value,
                        initialValue: '${bikeModel.frontArea}',
                        decoration: const InputDecoration(
                          labelText: 'Motorbike Fronta Area (m^2)',
                        ),
                      ),
                      DoubleFormField(
                        onChanged: (value) => bikeModel.airDensity = value,
                        initialValue: '${bikeModel.airDensity}',
                        decoration: const InputDecoration(
                          labelText: 'Air Density (kg/m^3)',
                        ),
                      ),
                      DoubleFormField(
                        onChanged: (value) => bikeModel.dragCoefficient = value,
                        initialValue: '${bikeModel.dragCoefficient}',
                        decoration: const InputDecoration(
                          labelText: 'Drag Coefficient',
                        ),
                      ),
                      DoubleFormField(
                        onChanged: (value) => bikeModel.wetWeight = value,
                        initialValue: '${bikeModel.wetWeight}',
                        decoration: const InputDecoration(
                          labelText: 'Motorbike Wet Weight (kg)',
                        ),
                      ),
                      DoubleFormField(
                        onChanged: (value) => bikeModel.riderWeight = value,
                        initialValue: '${bikeModel.riderWeight}',
                        decoration: const InputDecoration(
                          labelText: 'Rider Weight (kg)',
                        ),
                      ),
                      DoubleFormField(
                        onChanged: (value) => bikeModel.rollResistanceCoeff = value,
                        initialValue: '${bikeModel.rollResistanceCoeff}',
                        decoration: const InputDecoration(
                          labelText: 'Roll Resistance coeff.',
                        ),
                      ),
                      DoubleFormField(
                        onChanged: (value) => bikeModel.gravity = value,
                        initialValue: '${bikeModel.gravity}',
                        decoration: const InputDecoration(
                          labelText: 'Gravity (m/s^2)',
                        ),
                      ),
                    ],
                  ),
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
