library AlphaVantage;

import 'dart:io';
import 'dart:convert';

part 'AlphaVantageErrors.dart';
part 'AlphaVantageCheckers.dart';

class AlphaVantage {
  String APIKey;
  HttpClient _hc;
  String datatype;
  static DateTime _last;
  AlphaVantage(this.APIKey, [this.datatype]){
    _hc = new HttpClient();
    if(datatype==null||!"jsoncsv".contains(datatype.toLowerCase())||datatype.length>4||datatype.length<3){
      // make sure we get a valid datatype
      this.datatype = 'json';
    }
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

  getData(String function, String symbol, {Map<String, String> extras}) async {
    String parameters = "";
    if(extras!=null) {
      extras.forEach((param, value) {
        parameters =
        (parameters == "") ? "$param=$value" : "$parameters&$param=$value";
      });
    }
    parameters+="&datatype=$datatype&apikey=$APIKey";
    String URL = "https://www.alphavantage.co/query?function=$function&${(function == "SECTOR")?"":"symbol=$symbol"}${(parameters!="")?"&$parameters":""}";
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
      return getData("TIME_SERIES_INTRADAY", symbol, extras: extras);
    } else {
      print("Invalid interval entered");
      return "";
    }
  }

  Stock_Daily(String symbol, {bool isFullSized: false}){
    Map<String, String> extras = {};
    if(isFullSized) extras["outputsize"] = "full";
    return getData("TIME_SERIES_DAILY", symbol, extras: extras);
  }

  Stock_Daily_Adjusted(String symbol, {bool isFullSized: false}){
    Map<String, String> extras = {};
    if(isFullSized) extras["outputsize"] = "full";
    return getData("TIME_SERIES_DAILY_ADJUSTED", symbol, extras: extras);
  }

  Stock_Weekly(String symbol){
    return getData("TIME_SERIES_WEEKLY", symbol);
  }

  Stock_Weekly_Adjusted(String symbol){
    return getData("TIME_SERIES_WEEKLY_ADJUSTED", symbol);
  }

  Stock_Monthly(String symbol){
    return getData("TIME_SERIES_MONTHLY", symbol);
  }

  Stock_Monthly_Adjusted(String symbol){
    return getData("TIME_SERIES_MONTHLY_ADJUSTED", symbol);
  }

  // Stock Technical Indicators
  _TechSI(String func, String symbol, dynamic interval, {Map extras=const {}}){
    if(inList(interval, technical_intervals , func, 'interval')){
      extras.addAll({'interval':interval});
      return getData(func, symbol, extras: extras);
    }
  }

  _TechSIT(String func, String symbol, dynamic interval, String series_type, {Map extras=const {}}){
    if(inList(series_type, series_type_list, func, 'series_type')){
      extras.addAll({"series_type": series_type});
      return _TechSI(func, symbol, interval, extras: extras);
    }
  }

  _TechSIP(String func, String symbol, dynamic interval, int time_period, {Map extras=const {}}){
    if(isPositive(time_period, func, 'time_period')){
      extras.addAll({"time_period":time_period.toString()});
      return _TechSI(func, symbol, interval);
    }
  }

  _TechSIPT(String func, String symbol, dynamic interval, int time_period, String series_type, {Map extras=const {}}){
    if(inList(series_type, series_type_list, func, 'series_type')){
      extras.addAll({"series_type": series_type});
      return _TechSIP(func, symbol, interval, time_period, extras: extras);
    }
  }

  SMA(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("SMA", symbol, interval, time_period, series_type);
  }

  EMA(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("EMA", symbol, interval, time_period, series_type);
  }

  WMA(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("WMA", symbol, interval, time_period, series_type);
  }

  DEMA(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("DEMA", symbol, interval, time_period, series_type);
  }

  TEMA(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("TEMA", symbol, interval, time_period, series_type);
  }

  TRIMA(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("TRIMA", symbol, interval, time_period, series_type);
  }

  KAMA(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("KAMA", symbol, interval, time_period, series_type);
  }

  MAMA(String symbol, dynamic interval, int time_period, String series_type, {double fastlimit, double slowlimit}){
    String func = "MAMA";
    if(isPositive(fastlimit, func, "fastlimit")&&
        isPositive(slowlimit, func, "slowlimit")){
      return _TechSIPT("MAMA", symbol, interval, time_period, series_type,
          extras: {
            "fastlimit":fastlimit,
            "slowlimit":slowlimit
          });
    }
  }

  T3(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("T3", symbol, interval, time_period, series_type);
  }

  MACD(String symbol, dynamic interval, int time_period, String series_type,
      {int fastperiod=12, int slowperiod=26, int signalperiod=9}){
    String func = "MACD";
    if(isPositive(fastperiod, func, "fastperiod")&&
        isPositive(slowperiod, func, "slowperiod")&&
        isPositive(signalperiod, func, "signalperiod")){
      return _TechSIPT(func, symbol, interval, time_period, series_type, extras: {
        "fastperiod":fastperiod.toString(),
        "slowperiod":slowperiod.toString(),
        "signalperiod":signalperiod.toString(),
      });
    }
  }

  MACDEXT(String symbol, dynamic interval, int time_period, String series_type,
      {int fastperiod=12, int slowperiod=26, int signalperiod=9,
        int fastmatype=0, int slowmatype=0, int signalmatype=0}){
    String func = "MACDEXT";
    if(isPositive(fastperiod, func, "fastperiod")&&
        isPositive(slowperiod, func, "slowperiod")&&
        isPositive(signalperiod, func, "signalperiod")&&
        inRange(fastmatype, 0, 8, func, "fastmatype")&&
        inRange(slowmatype, 0, 8, func, "slowmatype")&&
        inRange(signalmatype, 0, 8, func, "signalmatype")){
      return _TechSIPT(func, symbol, interval, time_period, series_type, extras: {
        "fastperiod":fastperiod.toString(),
        "slowperiod":slowperiod.toString(),
        "signalperiod":signalperiod.toString(),
        "fastmatype":fastmatype.toString(),
        "slowmatype":slowmatype.toString(),
        "signalmatype":signalmatype.toString()
      });
    }
  }
  STOCH(String symbol, dynamic interval, {int fastkperiod=5, int slowkperiod=3, int slowdperiod=3, int slowkmatype=3, int slowdmatype=0}){
    String func = "STOCH";
    if(isPositive(fastkperiod, func, "fastkperiod")&&
        isPositive(slowkperiod, func, "slowkperiod")&&
        isPositive(slowdperiod, func, "slowdperiod")&&
        inRange(slowdmatype, 0, 8, func, "slowdmatype")&&
        inRange(slowkmatype, 0, 8, func, "slowkmatype")){
      return _TechSI(func, symbol, interval, extras: {
      "fastkperiod":fastkperiod.toString(),
      "slowkperiod":slowkperiod.toString(),
      "slowdperiod":slowdperiod.toString(),
      "slowkmatype":slowkmatype.toString(),
      "slowdmatype":slowdmatype.toString()});
    }
  }
  STOCHF(String symbol, dynamic interval, {int fastkperiod=5, int fastdperiod=3, int fastdmatype=3}){
    String func = "STOCHF";
    if(isPositive(fastkperiod, func, "fastkperiod")&&
        isPositive(fastdperiod, func, "fastdperiod")&&
        inRange(fastdmatype, 0, 8, func, "fastdmatype")){
      return _TechSI(func, symbol, interval, extras: {
                                            "fastkperiod":fastkperiod,
                                            "fastdperiod":fastdperiod,
                                            "fastdmatype":fastdmatype
                                            });
    }
  }
  RSI(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("RSI", symbol, interval, time_period, series_type);
  }
  STOCHRSI(String symbol, dynamic interval, int time_period, String series_type, {int fastkperiod=5, int fastdperiod=3, int fastdmatype=3}){
    String func = "STOCHRSI";
    if(isPositive(fastkperiod, func, "fastkperiod")&&
        isPositive(fastdperiod, func, "fastdperiod")&&
        inRange(fastdmatype, 0, 8, func, "fastdmatype")){
      return _TechSIPT(func, symbol, interval, time_period, series_type, extras: {
                "fastkperiod":fastkperiod,
                "fastdperiod":fastdperiod,
                "fastdmatype":fastdmatype
                });
    }
  }
  WILLR(String symbol, dynamic interval, int time_period){
    return _TechSIP("WILLR", symbol, interval, time_period);
  }
  ADX(String symbol, dynamic interval, int time_period){
    return _TechSIP("ADX", symbol, interval, time_period);
  }
  ADXR(String symbol, dynamic interval, int time_period){
    return _TechSIP("ADX", symbol, interval, time_period);
  }
  APO(String symbol, dynamic interval, String series_type, {int fastperiod=12, int slowperiod = 26, int matype = 0}){
    String func = 'APO';
    if( isPositive(fastperiod, func, 'fastperiod')&&
        isPositive(slowperiod, func, 'slowperiod')&&
        inRange(matype, 0, 8, func, 'matype')){
      return _TechSIT(func, symbol, interval, series_type, extras: {
                                            "fastperiod":fastperiod.toString(),
                                            "slowperiod":slowperiod.toString(),
                                            "matype": matype.toString()});
    }
  }
  PPO(String symbol, dynamic interval, String series_type, {int fastperiod=12, int slowperiod = 26, int matype = 0}){
    String func = 'PPO';
    if( isPositive(fastperiod, func, 'fastperiod')&&
        isPositive(slowperiod, func, 'slowperiod')&&
        inRange(matype, 0, 8, func, 'matype')){
      return _TechSIT(func, symbol, interval, series_type, extras: {
        "fastperiod":fastperiod.toString(),
        "slowperiod":slowperiod.toString(),
        "matype": matype.toString()});
    }
  }
  MOM(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("MOM", symbol, interval, time_period, series_type);
  }
  BOP(String symbol, dynamic interval){
    return _TechSI("BOP", symbol, interval);
  }
  CCI(String symbol, dynamic interval, int time_period){
    return _TechSIP("CCI", symbol, interval, time_period);
  }
  CMO(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("CMO", symbol, interval, time_period, series_type);
  }
  ROC(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("ROC", symbol, interval, time_period, series_type);
  }
  ROCR(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("ROCR", symbol, interval, time_period, series_type);
  }
  AROON(String symbol, dynamic interval, int time_period){
    return _TechSIP("AROON", symbol, interval, time_period);
  }
  AROONOSC(String symbol, dynamic interval, int time_period){
    return _TechSIP("AROONOSC", symbol, interval, time_period);
  }
  MFI(String symbol, dynamic interval, int time_period){
    return _TechSIP("MFI", symbol, interval, time_period);
  }
  TRIX(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("TRIX", symbol, interval, time_period, series_type);
  }
  ULTOSC(String symbol, dynamic interval, {int timeperiod1=7, int timeperiod2=14, int timeperiod3=28}){
    String func = 'ULTOSC';
    if( isPositive(timeperiod1, func, "timeperiod1")&&
        isPositive(timeperiod2, func, "timeperiod2")&&
        isPositive(timeperiod3, func, "timeperiod3")){
      return _TechSI(func, symbol, interval, extras: {
        'timeperiod1':timeperiod1.toString(),
        'timeperiod2':timeperiod2.toString(),
        'timeperiod3':timeperiod3.toString()});
    }
  }
  DX(String symbol, dynamic interval, int time_period){
    return _TechSIP("DX", symbol, interval, time_period);
  }
  MINUS_DI(String symbol, dynamic interval, int time_period){
    return _TechSIP("MINUS_DI", symbol, interval, time_period);
  }
  PLUS_DI(String symbol, dynamic interval, int time_period){
    return _TechSIP("PLUS_DI", symbol, interval, time_period);
  }
  MINUS_DM(String symbol, dynamic interval, int time_period){
    return _TechSIP("MINUS_DM", symbol, interval, time_period);
  }
  PLUS_DM(String symbol, dynamic interval, int time_period){
    return _TechSIP("PLUS_DM", symbol, interval, time_period);
  }
  BBANDS(String symbol, dynamic interval, int time_period, String series_type, {int nbdevup=2, int nbdevdn=2, int matype=0}){
    String func = 'BBANDS';
    if( isPositive(nbdevup, func, "nbdevup")&&
        isPositive(nbdevdn, func, "nbdevdn")&&
        matypeInRange(matype, func)){
      return _TechSIPT(func, symbol, interval, time_period, series_type, extras: {
        "nbdevup":nbdevup.toString(),
        "nbdevdn":nbdevdn.toString(),
        "matype":matype.toString()});
    }
  }
  MIDPOINT(String symbol, dynamic interval, int time_period, String series_type){
    return _TechSIPT("MIDPOINT", symbol, interval, time_period, series_type);
  }
  MIDPRICE(String symbol, dynamic interval, int time_period) {
    return _TechSIP("MIDPRICE", symbol, interval, time_period);
  }
  SAR(String symbol, dynamic interval, {double acceleration=0.01, double maximum=0.20}){
    String func = 'SAR';
    if( isPositive(acceleration, func, 'acceleration')&&
        isPositive(maximum, func, 'maximum')){
      return _TechSI(func, symbol, interval, extras: {
        'acceleration': acceleration.toString(),
        'maximum':maximum.toString()});
    }
  }
  TRANGE(String symbol, dynamic interval){
    return _TechSI("TRANGE", symbol, interval);
  }
  ATR(String symbol, dynamic interval, int time_period){
    return _TechSIP("ATR", symbol, interval, time_period);
  }
  NATR(String symbol, dynamic interval, int time_period){
    return _TechSIP("NATR", symbol, interval, time_period);
  }
  AD(String symbol, dynamic interval){
    return _TechSI("AD", symbol, interval);
  }
  ADOSC(String symbol, dynamic interval, {int fastperiod=3, int slowperiod=10}){
    String func = 'ADOSC';
    if( isPositive(fastperiod, func, 'fastperiod')&&
        isPositive(slowperiod, func, 'slowperiod')){
      return _TechSI(func, symbol, interval, extras: {
        'fastperiod':fastperiod.toString(),
        'slowperiod':slowperiod.toString()});
    }
  }
  OBV(String symbol, dynamic interval){
    return _TechSI("OBV", symbol, interval);
  }
  HT_TRENDLINE(String symbol, dynamic interval, String series_type){
    return _TechSIT("HT_TRENDLINE", symbol, interval, series_type);
  }
  HT_SINE(String symbol, dynamic interval, String series_type){
    return _TechSIT("HT_SINE", symbol, interval, series_type);
  }
  HT_TRENDMODE(String symbol, dynamic interval, String series_type){
    return _TechSIT("HT_TRENDMODE", symbol, interval, series_type);
  }
  HT_DCPERIOD(String symbol, dynamic interval, String series_type){
    return _TechSIT("HT_DCPERIOD", symbol, interval, series_type);
  }
  HT_DCPHASE(String symbol, dynamic interval, String series_type){
    return _TechSIT("HT_DCPHASE", symbol, interval, series_type);
  }
  HT_PHASOR(String symbol, dynamic interval, String series_type){
    return _TechSIT("HT_PHASOR", symbol, interval, series_type);
  }
}
