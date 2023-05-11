import 'dart:convert';
import 'package:calendarapp/Translate.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;



const List<String> array_lang = <String>['English', 'فارسی', 'العربی'];


void main() => runApp(MyApp());

void testAlert(BuildContext context, String title, String contents) {
  var alert = AlertDialog(
    title: Text(title),
    content: Text(contents),
    actions: [
      TextButton(
        style: TextButton.styleFrom(
          textStyle: Theme.of(context).textTheme.labelLarge,
        ),
        child: Icon(Icons.close),
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
  List<dynamic> data = [];

  @override
  void initState() {
      super.initState();
    fetchData();
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
    List<String> daysOfWeek = [
      'جمعه',
      'پنجشنبه',
      'چهارشنبه',
      'سه شنبه',
      'دوشنبه',
      'یکشنبه',
      'شنبه',
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
    List<DataRow> rows_chunk = [];
    for (var i = 0; i < chunks.length; i++) {
      var rowCells = chunks[i].map((item) {
        var ColorReturn = [255, 0, 0, 0];
        if (!item['is_month']) {
          ColorReturn = [169, 169, 169, 1];
        }
        if (item['closed'] && item['is_month']) {
          ColorReturn = [255, 129, 0, 0];
        }
        if (item['to_day']) {
          return DataCell(Builder(
            builder: (context) {
              return OutlinedButton(
                style: OutlinedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 8, 94, 27),
                    side: BorderSide(color: Colors.transparent)),
                onPressed: () {
                  testAlert(context, 'رویداد ها', 'اینم رویداد ها\nیکی دیگه');
                },
                child: Tooltip(
                  message: 'امروز',
                  child: Text(
                    '${item['date']['jalali'][0]} / ${item['date']['jalali'][1]} / ${item['date']['jalali'][2]}',
                    style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ),
              );
            },
          ));
        }

        return DataCell(Text(
          '${item['date']['jalali'][0]} / ${item['date']['jalali'][1]} / ${item['date']['jalali'][2]}',
          style: TextStyle(
              color: Color.fromARGB(ColorReturn[0], ColorReturn[1],
                  ColorReturn[2], ColorReturn[3])),
        ));
      }).toList();
      if (rowCells.length == 7) {
        rows_chunk.add(DataRow(cells: [...rowCells].reversed.toList()));
      } else {
        for (var b = rowCells.length; b <= 6; b++) {
          rowCells.add(DataCell(Text(' ')));
        }
        rows_chunk.add(DataRow(cells: [...rowCells].reversed.toList()));
      }
      //  print(i);
    }
    // create data rows
    List<DataRow> rows = [...rows_chunk];

    // create data table
    SingleChildScrollView dataTable = SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(columns: columns, rows: rows),
    );
    // DataTable dataTable = DataTable(columns: columns, rows: rows);
    // print(asTR('en:ENT_LANG'));
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
                    Tab(icon: Icon(Icons.home), text: 'Calendar'),
                    Tab(icon: Icon(Icons.settings), text: 'Setting'),
                  ],
                ),
                title: Text('جدول از داده‌های جیسون'),
              ),
              body: TabBarView(
                children: [
                  Scaffold(
                    body: Center(
                      child: data.isEmpty
                          ? CircularProgressIndicator() // show loading indicator if data is not fetched yet
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(columns: columns, rows: rows),
                            ), // show the data table when data is available
                    ),
                  ),
                  Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          Trans('fa:ENT_LANG')
                      ),

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
                        // This is called when the user selects an item.
                        setState(() {
                          dropdownValue = value!;
                        });
                      },
                      items: array_lang.map<DropdownMenuItem<String>>((String value) {
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
}
