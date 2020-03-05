class RouterInfo {
  final String path;
  final Map<dynamic, dynamic> data;

  RouterInfo.fromMap(Map<dynamic, dynamic> map)
      : assert(map != null),
        path = map['path'],
        data = map['data'];
}
