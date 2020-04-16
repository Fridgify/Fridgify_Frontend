import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fridgify/controller/content_menu_controller.dart';

import 'package:fridgify/model/fridge.dart';
import 'package:fridgify/view/widgets/popup.dart';
import 'package:pie_chart/pie_chart.dart';

class MenuElements {
  static List<Color> colorList = [
    Color(0xff86c06a),
    Color(0xfffff265),
    Color(0xffec6446),
  ];

  static TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  static Widget pieChart(Fridge fridge, BuildContext context) {
    if (fridge.content['total'] > 0)
      return PieChart(
        dataMap: fridge.contentForPieChart(),
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32.0,
        chartRadius: MediaQuery.of(context).size.height / 4.0,
        showChartValuesInPercentage: false,
        showChartValues: true,
        showChartValuesOutside: true,
        chartValueBackgroundColor: Colors.grey[200],
        colorList: colorList,
        showLegends: true,
        centerText: "${fridge.content['total']}",
        legendPosition: LegendPosition.bottom,
        legendStyle: defaultLegendStyle,
        decimalPlaces: 0,
        showChartValueLabel: true,
        chartValueStyle: defaultChartValueStyle.copyWith(
          color: Colors.blueGrey[900].withOpacity(0.9),
        ),
        chartType: ChartType.ring,
      );
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(
          'No items found. ',
          style: Theme.of(context).textTheme.title,
        ),
        Text(
          'Add items to display them here. ',
          style: Theme.of(context).textTheme.title,
        ),
      ]),
    );
  }

  static Widget fridgeCard(Fridge fridge, BuildContext context, onChanged,
      ContentMenuController controller) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 0.0),
        child: Card(
            child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Container(
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                          child: Column(children: [
                        Row(children: [
                          Text(
                            fridge.name,
                            style: TextStyle(
                                fontSize: 24, fontFamily: 'Montserrat'),
                          ),
                        ]),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              fridge.description,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Montserrat',
                                  color: Colors.blueGrey),
                            )
                          ],
                        ),
                        Divider(),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              "Members: ${fridge.member.length}",
                              style: Theme.of(context).textTheme.body1,
                            ),
                          ],
                        )
                      ])),
                      pieChart(fridge, context),
                      Positioned(
                          child: Align(
                              alignment: FractionalOffset.bottomCenter,
                              child: ButtonBar(
                                alignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  RaisedButton(
                                    color: Colors.purple,
                                    child: Text("Invite"),
                                    onPressed: () {},
                                  ),
                                  FlatButton(
                                    child: Text("Leave"),
                                    onPressed: () async {
                                      await Popups.confirmationPopup(context, "Leave fridge?", "Are you sure you want to leave ${fridge.name}? You can only re-join if you get invited again.", () => controller.leaveFridge(
                                        fridge, context, onChanged),);
                                    }

                                  ),
                                ],
                              )))
                    ],
                  ),
                ))));
  }

  static List<Widget> cardStack(List<Fridge> fridges, BuildContext context,
      Function() onChanged, ContentMenuController controller) {
    return fridges
        .map((fridge) => fridgeCard(fridge, context, onChanged, controller))
        .toList();
  }

  static int current = 0;

  static Widget carousel(List<Fridge> fridges, BuildContext context,
      Function() onChanged, ContentMenuController controller) {
    if (fridges.length <= 0) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.add_circle),
            color: Colors.purple,
            iconSize: MediaQuery.of(context).size.height * 0.1,
            onPressed: () => {Popups.addFridge(context, controller, onChanged)},
          )
        ],
      ));
    }
    return Column(children: [
      CarouselSlider(
        items: cardStack(
          fridges,
          context,
          onChanged,
          controller,
        ),
        height: MediaQuery.of(context).size.height * 0.8,
        autoPlay: false,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 2.0,
        onPageChanged: (index) {
          print(index);
          current = index;
          onChanged();
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: map<Widget>(
          fridges,
          (index, url) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: current == index
                      ? Color.fromRGBO(0, 0, 0, 0.9)
                      : Color.fromRGBO(0, 0, 0, 0.4)),
            );
          },
        ),
      ),
    ]);
  }

  static List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }
}