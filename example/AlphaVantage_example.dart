import 'package:AlphaVantage/AlphaVantage.dart';
import 'dart:convert';
import 'dart:io';

getMSFT(AlphaVantage av) async {
  String data = await av.Stock_Daily("MSFT");
  JsonDecoder jd = new JsonDecoder();
  Map variable = jd.convert(data);
  Map allStockData = variable[variable.keys.toList()[1]];
  print("All stock data");
  print(allStockData);
  Map stockDataForDay = allStockData[allStockData.keys.toList()[1]];
  print("Most Recent Day's stock data");
  print(stockDataForDay);
}

main()  async  {
  // using the example from the website.
  DateTime start = new DateTime.now();
  String key = "demo";
  AlphaVantage av = new AlphaVantage(key);
  await getMSFT(av);
  // sleep can be fine tuned, from my test station, I need to subtract 10
  // milliseconds to get it closer to almost extactly 1 second per call
  sleep(new Duration(milliseconds: av.millisecondsToNext()));
  String input = await av.Stock_Batch_Quote(["MSFT","FB","AAPL"], datatype: "JSON");
  print(input);
  av.closeConnection();

  DateTime end = new DateTime.now();
  print("operation took ${end.difference(start)} to complete operation");
}
