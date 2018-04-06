# AlphaVantage

A Dart library for getting stock data from the Alpha Vantage API. Further documention on the API and all services available through the can be accessed at:

https://www.alphavantage.co/documentation/

In order to use this API, one will need an API key which is freely available from the following site:

https://www.alphavantage.co/support/#api-key

This library is still a work in progress until otherwise noted, currently the focus is on stock data however Forex and Crypto access will be added as soon as the stock technical indicators are complete.

## Usage

A simple usage example:

    import 'package:AlphaVantage/AlphaVantage.dart';

    main() {
      // Establishes the library with the Key value
      AlphaVantage av = new AlphaVantage("demo");
      
      // Gets the daily stock data for MSFT
      String msft = await av.Stock_Daily("MSFT");
      print(msft);
    }

## Features and bugs

Gets all basic stock data over time from the Alpha Vantage API.

Looking at the Technical Indicators section in the API documentation, SMA through MACDEXT have been implemented so far with more to follow.

I am looking to allow persistent connections in the future using the same object as an option over single use as is currently implemented.
