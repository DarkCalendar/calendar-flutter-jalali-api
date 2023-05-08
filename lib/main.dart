import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    // var url = Uri.parse('http://127.0.0.1:8000/api/get');
    var url = Uri.parse('https://gist.githubusercontent.com/DevNull-IR/01459bf845a6bce2b0ffccdf961b1f4f/raw/8891dfa82c6a66aef42af76a8e8fbd0cf9c50378/api_test_date_and_time_jalali.json');
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
      'شنبه',];
      List<List<T>> chunk<T>(List<T> list, int chunkSize) {
      List<List<T>> chunks = [];
      for (int i = 0; i < list.length; i += chunkSize) {
        chunks.add(list.sublist(i, i + chunkSize > list.length ? list.length : i + chunkSize));
      }
      return chunks;
    }
    // create data columns
    
    List<DataColumn> columns = daysOfWeek.map((day) => DataColumn(label: Text(day))).toList();
    List<List<dynamic>> chunks = chunk(data, 7);
    List<DataRow> rows_chunk = [];
    for (var i = 0; i < chunks.length; i++){
      
       var rowCells = chunks[i].map((item) {
        if(item['to_day']){
          return DataCell(Tooltip(
                message: 'امروز',
                child: Text('${item['date']['jalali'][0]} / ${item['date']['jalali'][1]} / ${item['date']['jalali'][2]}', style: TextStyle(backgroundColor: Color.fromARGB(255, 21, 75, 21)),),
              ));
        }
        if(item['is_month']){
          return DataCell(Text('${item['date']['jalali'][0]} / ${item['date']['jalali'][1]} / ${item['date']['jalali'][2]}'));
        }
        
        return DataCell(Text('${item['date']['jalali'][0]} / ${item['date']['jalali'][1]} / ${item['date']['jalali'][2]}', style: TextStyle(color: Color.fromARGB(169, 169, 169, 1)),));
       }).toList();
       print(rowCells.length);
       if(rowCells.length == 7){
        rows_chunk.add(DataRow(cells: [
        ...rowCells
       ].reversed.toList()));
       }else{
        for(var b = rowCells.length; b<=6;b++){
          rowCells.add(DataCell(Text(' ')));
        }
        print(rowCells.length);
        print('b');
        rows_chunk.add(DataRow(cells: [
        ...rowCells
       ].reversed.toList()));
       }
      //  print(i);
    }
    // create data rows
    List<DataRow> rows = [
      ...rows_chunk
    ];

    // create data table
    DataTable dataTable = DataTable(columns: columns, rows: rows);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('جدول از داده‌های جیسون'),
          ),
          body: Center(
            child: data.isEmpty 
              ? CircularProgressIndicator() // show loading indicator if data is not fetched yet
              : dataTable, // show the data table when data is available
          ),
        ),
      ),
    );
  }
}