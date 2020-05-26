import 'package:provider/provider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'BikeModel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark),
      home: ChangeNotifierProvider<BikeModel>(
          create: (context) => BikeModel(),
          child: MyHomePage(title: 'Gear Head')),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    var bikeModel = Provider.of<BikeModel>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
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
            SprocketsCard(),
            Text(
              'Final Drive: ${bikeModel.finalDrive}',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
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
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Gearbox Ratios",
                      style: Theme.of(context).textTheme.body2,
                    )),
                collapsed: Text(
                  "Final Drive: ...",
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                expanded: Consumer<BikeModel>(
                  builder: (context, bikeModel, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        initialValue: '${bikeModel.getGearing(0)}',
                        onChanged: (value) => bikeModel.setGearing(0, value),
                        decoration: InputDecoration(
                          labelText: 'Primary',
                        ),
                      ),
                      TextFormField(
                        initialValue: '${bikeModel.getGearing(1)}',
                        onChanged: (value) => bikeModel.setGearing(1, value),
                        decoration: InputDecoration(
                          labelText: '1',
                        ),
                      ),
                      TextFormField(
                        initialValue: '${bikeModel.getGearing(2)}',
                        onChanged: (value) => bikeModel.setGearing(2, value),
                        decoration: InputDecoration(
                          labelText: '2',
                        ),
                      ),
                      TextFormField(
                        initialValue: '${bikeModel.getGearing(3)}',
                        onChanged: (value) => bikeModel.setGearing(3, value),
                        decoration: InputDecoration(
                          labelText: '3',
                        ),
                      ),
                      TextFormField(
                        initialValue: '${bikeModel.getGearing(4)}',
                        onChanged: (value) => bikeModel.setGearing(4, value),
                        decoration: InputDecoration(
                          labelText: '4',
                        ),
                      ),
                      TextFormField(
                        initialValue: '${bikeModel.getGearing(5)}',
                        onChanged: (value) => bikeModel.setGearing(5, value),
                        decoration: InputDecoration(
                          labelText: '5',
                        ),
                      ),
                      TextFormField(
                        initialValue: '${bikeModel.getGearing(6)}',
                        onChanged: (value) => bikeModel.setGearing(6, value),
                        decoration: InputDecoration(
                          labelText: '6',
                        ),
                      ),
                    ],
                  ),
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Sprockets',
                      style: Theme.of(context).textTheme.body2,
                    )),
                expanded: Consumer<BikeModel>(
                  builder: (context, bikeModel, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        onChanged: (value) => bikeModel.setFrontSprocketTeeth(value),
                        initialValue: '${bikeModel.frontSprocketTeeth}',
                        decoration: InputDecoration(
                          labelText: 'Front Sprocket',
                        ),
                      ),
                      TextFormField(
                        onChanged: (value) => bikeModel.setRearSprocketTeeth(value),
                        initialValue: '${bikeModel.rearSprocketTeeth}',
                        decoration: InputDecoration(
                          labelText: 'Rear Sprocket',
                        ),
                      ),
                    ],
                  ),
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
