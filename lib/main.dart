import 'dart:convert';
import 'package:calendarapp/Translate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity/connectivity.dart';
import 'package:open_settings/open_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

const List<String> array_lang = <String>['English', 'فارسی', 'العربی'];

void main() => runApp(const MyApp());

void testAlert(BuildContext context, String title, String contents) {
  var alert = AlertDialog(
    title: Text(title),
    content: Text(contents),
    actions: [
      TextButton(
        style: TextButton.styleFrom(
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),
        child: const Icon(Icons.close),
        onPressed: () {
          Navigator.of(context).pop();
        },
      )
    ],
  );

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with Translate {
  String dropdownValue = array_lang.first;
  bool _isConnected = true;
  List<dynamic> data = [];
  late SharedPreferences prefs;
  Future<void> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<void> initPrefs() async {
    prefs = await _prefs;
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
    fetchData();
    checkInternetConnection();
  }

  dynamic joinAndConverting(List app) {
    var execute;
    app.forEach((element) {
      execute = element;
    });
    return execute.join("\n");
  }

  void fetchData() async {
    // var url = Uri.parse('http://127.0.0.1:8000/api/get');
    var url = Uri.parse(
        'https://raw.githubusercontent.com/DarkCalendar/.github/main/api/json/api-test-date-and-time-jalali.json');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        data = jsonDecode(response.body)['full'];
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    String lang = prefs.getString('lang').toString();
    List<String> daysOfWeek = [
      Trans('$lang:fri'),
      Trans('$lang:thu'),
      Trans('$lang:wed'),
      Trans('$lang:tue'),
      Trans('$lang:mon'),
      Trans('$lang:sun'),
      Trans('$lang:sat'),
    ];
    List<List<T>> chunk<T>(List<T> list, int chunkSize) {
      List<List<T>> chunks = [];
      for (int i = 0; i < list.length; i += chunkSize) {
        chunks.add(list.sublist(
            i, i + chunkSize > list.length ? list.length : i + chunkSize));
      }
      return chunks;
    }
    // create data columns

    List<DataColumn> columns =
        daysOfWeek.map((day) => DataColumn(label: Text(day))).toList();
    List<List<dynamic>> chunks = chunk(data, 7);
    List<DataRow> rowsChunk = [];
    for (var i = 0; i < chunks.length; i++) {
      var rowCells = chunks[i].map((item) {
        var cr = [255, 0, 0, 0];
        if (!item['is_month']) {
          cr = [169, 169, 169, 1];
        }
        if (item['closed'] && item['is_month']) {
          cr = [255, 129, 0, 0];
        }
        var eventList = item['events']['event'];
        var bc = [255, 255, 255, 255];
        var msg = "";
        if (item['to_day']) {
          bc = [255, 8, 94, 27];
          msg = Trans('$lang:today');
        }
        return DataCell(Builder(
          builder: (context) {
            return OutlinedButton(
              style: OutlinedButton.styleFrom(
                  backgroundColor: Color.fromARGB(bc[0], bc[1], bc[2], bc[3]),
                  side: const BorderSide(color: Colors.transparent)),
              onPressed: () {
                var out = '';
                var event_exist = true;
                if (eventList.containsKey('lunar') &&
                    eventList['lunar'].length > 0) {
                  event_exist = false;
                  out += joinAndConverting(eventList['lunar']);
                  out += "\n";
                }
                if (eventList.containsKey('jalali') &&
                    eventList['jalali'].length > 0) {
                  event_exist = false;
                  out += joinAndConverting(eventList['jalali']);
                  out += "\n";
                }
                if (eventList.containsKey('gregorian') &&
                    eventList['gregorian'].length > 0) {
                  event_exist = false;
                  out += joinAndConverting(eventList['gregorian']);
                  out += "\n";
                }
                if (event_exist) {
                  out += Trans('$lang:nevent');
                }
                testAlert(context, Trans('$lang:events'), out.trim());
              },
              child: Tooltip(
                message: msg,
                child: Text(
                  '${item['date']['jalali'][0]} / ${item['date']['jalali'][1]} / ${item['date']['jalali'][2]}',
                  style: TextStyle(
                      color: Color.fromARGB(cr[0], cr[1], cr[2], cr[3])),
                ),
              ),
            );
          },
        ));
      }).toList();
      if (rowCells.length == 7) {
        rowsChunk.add(DataRow(cells: [...rowCells].reversed.toList()));
      } else {
        for (var b = rowCells.length; b <= 6; b++) {
          rowCells.add(const DataCell(Text(' ')));
        }
        rowsChunk.add(DataRow(cells: [...rowCells].reversed.toList()));
      }
    }
    // create data rows
    List<DataRow> rows = [...rowsChunk];
    // create data table
    SingleChildScrollView dataTable = SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(columns: columns, rows: rows),
    );
    Directionality SUD(BodyCalendar) {
      if (prefs.getString('lang') == null) {
        prefs.setString('lang', 'fa');
        dropdownValue = "فارسی";
      } else {
        var g_p_l = prefs.getString('lang');
        dropdownValue = "فارسی";
        if (g_p_l == 'en') {
          dropdownValue = "English";
        } else if (g_p_l == 'ar') {
          dropdownValue = "العربی";
        }
      }
      return Directionality(
        textDirection: TextDirection.ltr,
        child: MaterialApp(
            title: 'Calendar API',
            theme: ThemeData(primarySwatch: Colors.blue),
            debugShowCheckedModeBanner: false,
            home: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  bottom: TabBar(
                    tabs: [
                      Tab(
                          icon: const Icon(Icons.home),
                          text: Trans('$lang:calendar')),
                      Tab(
                          icon: const Icon(Icons.settings),
                          text: Trans('$lang:setting')),
                    ],
                  ),
                  title: const Text('جدول از داده‌های جیسون'),
                ),
                body: TabBarView(
                  children: [
                    BodyCalendar,
                    Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(Trans('$lang:ENT_LANG')),
                        DropdownButton<String>(
                          value: dropdownValue,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          style: const TextStyle(color: Colors.deepPurple),
                          underline: Container(
                            height: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                          onChanged: (String? value) {
                            String rs = value.toString();
                            if (value == 'English') {
                              rs = 'en';
                            }
                            if (value == 'فارسی') {
                              rs = 'fa';
                            }
                            if (value == 'العربی') {
                              rs = 'ar';
                            }
                            dropdownValue = value!;
                            prefs.setString('lang', rs);
                            lang = prefs.getString('lang').toString();
                            // This is called when the user selects an item.
                            setState(() {
                              dropdownValue = value;
                            });
                            prefs.setString('lang', rs);
                          },
                          items: array_lang
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        )
                      ],
                    )),
                  ],
                ),
              ),
            )),
      );
    }

    Scaffold fnDIR(NextPage) {
      checkInternetConnection();
      Scaffold BodyCalendar = Scaffold(
        body: Center(
          child: Builder(
            builder: (context) {
              return AlertDialog(
                title: const Text('Internet Connection'),
                content: const Text(
                    'No internet Data Connection. Please Turn on wifi or Mobile data.'),
                actions: [
                  TextButton(
                    child: const Icon(Icons.exit_to_app),
                    onPressed: () {
                      exit(0);
                    },
                  ),
                  TextButton(
                    child: const Icon(Icons.wifi),
                    onPressed: () {
                      OpenSettings.openWIFISetting();
                    },
                  ),
                  TextButton(
                    child: const Icon(Icons.check_sharp),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return SUD(fnDIR(NextPage));
                        }),
                      );
                    },
                  )
                ],
              );
            },
          ),
        ),
      );
      if (_isConnected) {
        fetchData();
        BodyCalendar = Scaffold(
          body: Center(
            child: data.isEmpty
                ? const CircularProgressIndicator() // show loading indicator if data is not fetched yet
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      children: [DataTable(columns: columns, rows: rows)],
                    ),
                  ), // show the data table when data is available
          ),
        );
      }
      return BodyCalendar;
    }

    Scaffold BodyCalendar = fnDIR(DataTable(columns: columns, rows: rows));

    return SUD(BodyCalendar);
    // }
  }
}
