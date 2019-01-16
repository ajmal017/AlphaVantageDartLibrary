part of AlphaVantage;

final List<int> intraday_intervals = [1, 5, 15, 30, 60];
final List<dynamic> technical_intervals = [1, 5, 15, 30, 60, "1min", "5min", "15min", "30min", "60min", "daily", "weekly", "monthly"];
final List<String> series_type_list = ["close", "open", "high", "low"];

bool inRange<N extends num>(N val, N rangeStart, N rangeEnd, String func, String param){
  if(val>=rangeStart&&val<=rangeEnd){
    return true;
  } else {
    throw new OutOfRange<N>(func, param, rangeStart, rangeEnd);
  }
}
bool matypeInRange(int matype, String func){
  return inRange(matype, 0, 8, func, 'matype');
}
bool inList(dynamic val, List list, String func, String param){
  if(list.contains(val)){
    return true;
  } else {
    throw new NotInListOfOptions(func, param, list);
  }
}

bool isPositive<N extends num>(N val, String func, String param){
  if(val>0.0){
    return true;
  } else {
    throw new MustBePositive(func, param);
  }
}