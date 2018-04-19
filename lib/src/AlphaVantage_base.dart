import 'dart:io';
import 'dart:convert';

class AlphaVantage {
  String APIKey;
  HttpClient _hc;
  static DateTime _last;
  AlphaVantage(this.APIKey){
    _hc = new HttpClient();
  }
  // if only doing 1 data pull
  closeConnection(){
    _hc.close();
  }
  // time elapsed since last time data was retrieved
  Duration timeElapsed(){
    DateTime now = new DateTime.now();
    return now.difference(_last);
  }
  // milliseconds until next data pull
  // Alpha Vantage requests that we make one API call per second. Do with this what you will.
  int millisecondsToNext(){
    Duration elapsed = timeElapsed();
    int milliseconds = 1000-(elapsed.inMilliseconds);
    return (milliseconds>0)?milliseconds:0;
  }

  final List<int> intraday_intervals = [1, 5, 15, 30, 60];
  final List<dynamic> technical_intervals = [1, 5, 15, 30, 60, "1min", "5min", "15min", "30min", "60min", "daily", "weekly", "monthly"];
  final List<String> series_type_list = ["close", "open", "high", "low"];


  getData(String function, String symbol, {Map<String, String> extras, String datatype: "json"}) async {
    String parameters = "";
    if(extras!=null) {
      extras.forEach((param, value) {
        parameters =
        (parameters == "") ? "$param=$value" : "$parameters&$param=$value";
      });
    }
    String URL = "https://www.alphavantage.co/query?function=$function&symbol=$symbol${(parameters!="")?"&$parameters":""}&apikey=$APIKey";
    print(URL);
    _last = new DateTime.now();
    String ret = await _hc.getUrl(Uri.parse(URL))
        .then((HttpClientRequest request) => request.close())
        .then((HttpClientResponse response) =>
        response.transform(new Utf8Decoder()).join());
    return await ret;
  }

  // Stock APIS

  Stock_Intraday(String symbol, int interval, {bool isFullSized: false, String datatype: "json"}){
    if(intraday_intervals.contains(interval)){
      Map<String, String> extras = {};
      if(isFullSized) extras["outputsize"] = "full";
      extras["interval"] = "${interval}min";
      return getData("TIME_SERIES_INTRADAY", symbol, extras: extras, datatype: datatype);
    } else {
      print("Invalid interval entered");
      return "";
    }
  }

  Stock_Daily(String symbol, {bool isFullSized: false, String datatype: "json"}){
    Map<String, String> extras = {};
    if(isFullSized) extras["outputsize"] = "full";
    return getData("TIME_SERIES_DAILY", symbol, extras: extras, datatype: datatype);
  }

  Stock_Daily_Adjusted(String symbol, {bool isFullSized: false, String datatype: "json"}){
    Map<String, String> extras = {};
    if(isFullSized) extras["outputsize"] = "full";
    return getData("TIME_SERIES_DAILY_ADJUSTED", symbol, extras: extras, datatype: datatype);
  }

  Stock_Weekly(String symbol, {String datatype: "json"}){
    return getData("TIME_SERIES_WEEKLY", symbol, datatype: datatype);
  }

  Stock_Weekly_Adjusted(String symbol, {String datatype: "json"}){
    return getData("TIME_SERIES_WEEKLY_ADJUSTED", symbol, datatype: datatype);
  }

  Stock_Monthly(String symbol, {String datatype: "json"}){
    return getData("TIME_SERIES_MONTHLY", symbol, datatype: datatype);
  }

  Stock_Monthly_Adjusted(String symbol, {String datatype: "json"}){
    return getData("TIME_SERIES_MONTHLY_ADJUSTED", symbol, datatype: datatype);
  }

  Stock_Batch_Quote(List<String> symbols, {String datatype: "json"}){
    if(symbols.length>100){
      print("Too many symbols entered");
      symbols = symbols.sublist(0, 100);
    } else if(symbols.length==0){
      print("No symbols entered");
      return "{}";
    }
    String symbol = "";
    symbols.forEach(
            (sym){
              (symbol=="")?symbol=sym:symbol="$symbol,$sym";
            });
    return getData("BATCH_STOCK_QUOTES", symbol, datatype: datatype);
  }

  // Stock Technical Indicators

  Stock_Technicals(String func, String symbol, dynamic interval, int time_period, String series_type, [Map<String, String> extraExtra]){
    if(time_period<1){
      print("Time period must be a positive integer.");
      return "";
    }
    if(!series_type_list.contains(series_type)){
      print("Invalid series type provided");
      return "";
    }
    if(!technical_intervals.contains(interval)){
      print("Invalid interval entered");
      return "";
    }
    Map<String, String> extras = {};
    if(interval is int){
      interval = "${interval}min";
    }
    extras["interval"] = interval;
    extras["time_period"] = time_period.toString();
    extras["series_type"] = series_type;
    if(extraExtra.length>0){
      extras.addAll(extraExtra);
    }
    return getData(func, symbol, extras: extras);
  }

  SMA(String symbol, dynamic interval, int time_period, String series_type){
    return Stock_Technicals("SMA", symbol, interval, time_period, series_type);
  }

  EMA(String symbol, dynamic interval, int time_period, String series_type){
    return Stock_Technicals("EMA", symbol, interval, time_period, series_type);
  }

  WMA(String symbol, dynamic interval, int time_period, String series_type){
    return Stock_Technicals("WMA", symbol, interval, time_period, series_type);
  }

  DEMA(String symbol, dynamic interval, int time_period, String series_type){
    return Stock_Technicals("DEMA", symbol, interval, time_period, series_type);
  }

  TEMA(String symbol, dynamic interval, int time_period, String series_type){
    return Stock_Technicals("TEMA", symbol, interval, time_period, series_type);
  }

  TRIMA(String symbol, dynamic interval, int time_period, String series_type){
    return Stock_Technicals("TRIMA", symbol, interval, time_period, series_type);
  }

  KAMA(String symbol, dynamic interval, int time_period, String series_type){
    return Stock_Technicals("KAMA", symbol, interval, time_period, series_type);
  }

  MAMA(String symbol, dynamic interval, int time_period, String series_type, {double fastlimit, double slowlimit}){
    Map<String, String> extraExtra = {};
    if(fastlimit!=null){
      if(!(fastlimit>0||fastlimit<1)){
        print("fastlimit must be between 0 and 1");
        return "";
      }
      extraExtra["fastlimit"] = fastlimit.toString();
    }
    if(slowlimit!=null){
      if(!(slowlimit>0||slowlimit<1)){
        print("slowlimit must be between 0 and 1");
        return "";
      }
      extraExtra["slowlimit"] = slowlimit.toString();
    }
    return Stock_Technicals("MAMA", symbol, interval, time_period, series_type, extraExtra);
  }

  T3(String symbol, dynamic interval, int time_period, String series_type){
    return Stock_Technicals("T3", symbol, interval, time_period, series_type);
  }
  // reduces redundant code from next two functions
  MACX(String func, String symbol, dynamic interval, int time_period, String series_type, {int fastperiod, int slowperiod, int signalperiod, Map<String,String> extraContent}){
    Map<String, String> extraExtra = {};
    if(fastperiod!=null){
      if(fastperiod<1){
        print("Fast period must be positive");
        return "";
      }
      extraExtra["fastlimit"] = fastperiod.toString();
    }
    if(slowperiod!=null){
      if(slowperiod<1){
        print("Slow period must be positive");
        return "";
      }
      extraExtra["slowlimit"] = slowperiod.toString();
    }
    if(signalperiod!=null){
      if(signalperiod<1){
        print("Signal period must be positive");
        return "";
      }
      extraExtra["signallimit"] = signalperiod.toString();
    }
    extraExtra.addAll(extraContent);
    return Stock_Technicals(func, symbol, interval, time_period, series_type, extraExtra);
  }

  MACD(String symbol, dynamic interval, int time_period, String series_type, {int fastperiod, int slowperiod, int signalperiod}){
    return MACX("MACD", symbol, interval, time_period, series_type, fastperiod: fastperiod, slowperiod: slowperiod, signalperiod: signalperiod);
  }

  MACDEXT(String symbol, dynamic interval, int time_period, String series_type, {int fastperiod, int slowperiod, int signalperiod, int fastmatype, int slowmatype, int signalmatype}){
    Map<String, String> extraExtra = {};
    if(fastmatype!=null){
      if(fastmatype>9||fastmatype<0){
        print("Fast ma type is out of range");
        return "";
      }
      extraExtra["fastmatype"] = fastmatype.toString();
    }
    if(slowmatype!=null){
      if(slowmatype>9||slowmatype<0){
        print("Slow ma type is out of range");
        return "";
      }
      extraExtra["slowmatype"] = slowmatype.toString();
    }
    if(signalmatype!=null){
      if(signalmatype>9||signalmatype<0){
        print("Signal ma type is out of range");
        return "";
      }
      extraExtra["signalmatype"] = signalmatype.toString();
    }
    return MACX("MACDEXT", symbol, interval, time_period, series_type, fastperiod: fastperiod, slowperiod: slowperiod, signalperiod: signalperiod, extraContent: extraExtra);
  }


}
