import 'package:AlphaVantage/AlphaVantage.dart';
import 'dart:convert';

main()  async  {
  // using the example from the website.
  DateTime start = new DateTime.now();
  String key = "demo";
  AlphaVantage av = new AlphaVantage(key);
  String data = await av.Stock_Daily("MSFT");
  Map variable = JSON.decode(data);
  Map allStockData = variable[variable.keys.toList()[1]];
  print("All stock data");
  print(allStockData);
  Map stockDataForDay = allStockData[allStockData.keys.toList()[1]];
  print("Most Recent Day's stock data");
  print(stockDataForDay);
  DateTime end = new DateTime.now();
  print("operation took ${end.difference(start)} to complete operation");
}
