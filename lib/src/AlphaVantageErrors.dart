part of AlphaVantage;

class OutOfRange<N extends num> implements Exception{
  String func;
  String value;
  N rangeStart;
  N rangeEnd;
  OutOfRange(this.func, this.value, this.rangeStart, this.rangeEnd);
  @override
  String toString(){
    return "$value in $func is out of range. It should be between $rangeStart and $rangeEnd";
  }
}

class NotInListOfOptions implements Exception{
  String func;
  String value;
  List list;
  NotInListOfOptions(this.func, this.value, this.list);
  @override
  String toString(){
    String error = "$value in $func is not one of the allowed options. It should be one of: ";
    list.forEach((option)=>error+="${option.toString()} ");
    return error;
  }
}

class MustBePositive implements Exception{
  String func;
  String value;
  MustBePositive(this.func, this.value);
  @override toString(){
    return "$value in $func must be positive.";
  }
}