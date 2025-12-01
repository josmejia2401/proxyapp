class SystemStats {
  final double cpu;
  final double ram;
  final double appMemory;
  int countTask;

  SystemStats({
    required this.cpu,
    required this.ram,
    required this.appMemory,
    this.countTask = 0
  });
}
