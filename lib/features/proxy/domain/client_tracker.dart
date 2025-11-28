class SystemStats {
  final double cpu;
  final double ram;

  SystemStats({
    required this.cpu,
    required this.ram,
  });

  @override
  String toString() => "CPU: ${cpu.toStringAsFixed(1)}% | RAM: ${ram.toStringAsFixed(1)} MB";
}
