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
        builder: (context) => Butler("Development", "local", null, true),
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
                  border: Border.all(width: 10, color: butler.online ? Colors.green : Colors.red),
                  borderRadius: BorderRadius.circular(200),
                ),
                margin: const EdgeInsets.all(4),
                width: 200,
                height: 200,
                alignment: Alignment.center,
                child: SvgPicture.asset('images/butler.svg',
                    semanticsLabel: 'Butler default image'),
              ),
              Divider(
                thickness: 3,
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.display1,
              ),
            ],
          ),
        ),
      );
    });
  }

}
