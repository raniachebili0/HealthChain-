// This is a stub file for non-web platforms to enable conditional imports
// It provides mock implementations of the parts of dart:html we use

class HttpRequest {
  void open(String method, String url) {}
  void setRequestHeader(String header, String value) {}
  void send(String data) {}
  
  Stream<dynamic> get onLoadEnd => Stream.empty();
  Stream<dynamic> get onError => Stream.empty();
  
  int? status;
  String? responseText;
  String? statusText;
} 