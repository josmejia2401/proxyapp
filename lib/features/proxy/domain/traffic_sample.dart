class TrafficSample {
  final int bytes;
  final int timestamp;

  TrafficSample(this.bytes)
      : timestamp = DateTime.now().millisecondsSinceEpoch;
}
