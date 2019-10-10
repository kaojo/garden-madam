import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:garden_madam/butler-feed.dart';

import '../model.dart';

class ValvesListItem extends StatefulWidget {
  ButlerController butlerController;
  Pin pin;

  ValvesListItem(this.butlerController, this.pin);

  @override
  _ValvesListItemState createState() => _ValvesListItemState();
}

class _ValvesListItemState extends State<ValvesListItem> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {print("tap");},
      leading: new GestureDetector(
        onTap: () => widget.pin.toggle(widget.butlerController),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
                width: 5,
                color:
                    widget.pin.status == Status.ON ? Colors.blue : Colors.grey),
            borderRadius: BorderRadius.circular(50),
          ),
          margin: const EdgeInsets.fromLTRB(4, 4, 50, 4),
          padding: EdgeInsets.all(5),
          width: 50,
          height: 50,
          alignment: Alignment.center,
          child: SvgPicture.asset(
              'images/' +
                  (widget.pin.imageName != null
                      ? widget.pin.imageName
                      : 'valve_1.svg'),
              semanticsLabel: 'Butler default image'),
        ),
      ),
      title: Text(
        widget.pin.name != null
            ? widget.pin.name
            : widget.pin.valvePinNumber.toString(),
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      trailing: _getScheduleIcon(widget.pin),

    );
  }
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
