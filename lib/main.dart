import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:garden_madam/model.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garden Madam',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: ChangeNotifierProvider(
        builder: (context) => Butler(
            "Development",
            "local",
            List.of([
              Pin("yellow", 27, 22, 21, Status.ON, null),
              Pin("blue", 10, 11, 12, Status.OFF,
                  Schedule(true, 10, 00, 11, 00, RepeatRate.DAILY)),
              Pin("red", 1, 2, 3, Status.OFF,
                  Schedule(false, 18, 00, 18, 30, RepeatRate.WEEKLY)),
            ]),
            true),
        child: ButlerDetailPage(),
      ),
    );
  }
}

class ButlerDetailPage extends StatefulWidget {
  ButlerDetailPage({Key key}) : super(key: key);

  @override
  _ButlerDetailPageState createState() => _ButlerDetailPageState();
}

class _ButlerDetailPageState extends State<ButlerDetailPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Butler>(builder: (context, butler, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text(butler.name),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 10,
                      color: butler.online ? Colors.green : Colors.red),
                  borderRadius: BorderRadius.circular(200),
                ),
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                width: 200,
                height: 200,
                alignment: Alignment.center,
                child: SvgPicture.asset('images/butler.svg',
                    semanticsLabel: 'Butler default image'),
              ),
              Divider(
                thickness: 3,
              ),
              Expanded(child: ListView(children: _getValves(butler))),
              Divider(
                thickness: 3,
              ),
            ],
          ),
        ),
      );
    });
  }

  List<Container> _getValves(Butler butler) {
    return butler.pins != null ? butler.pins.map(_getValve).toList() : [];
  }

  Container _getValve(Pin pin) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
        child: Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            border: Border.all(
                width: 5,
                color: pin.status == Status.ON ? Colors.blue : Colors.grey),
            borderRadius: BorderRadius.circular(50),
          ),
          margin: const EdgeInsets.fromLTRB(4, 4, 50, 4),
          padding: EdgeInsets.all(5),
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: SvgPicture.asset('images/valve_1.svg',
              semanticsLabel: 'Butler default image'),
        ),
        Expanded(
            child: Text(
          pin.name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        )),
        Expanded(child: _getScheduleIcon(pin))
      ],
    ));
  }

  Icon _getScheduleIcon(Pin pin) {
    if (pin.schedule == null) {
      return Icon(Icons.add_alarm, color: Colors.grey);
    }

    if (!pin.schedule.enabled) {
      return Icon(Icons.access_alarm, color: Colors.grey);
    }

    return Icon(Icons.access_alarm, color: Colors.lightBlueAccent);
  }
}
