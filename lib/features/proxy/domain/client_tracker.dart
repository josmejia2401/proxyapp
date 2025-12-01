class SystemStats {
  final double cpu;
  final double ram;
  final double appMemory;
  int countTask;
  final double appCpu;

  SystemStats({
    required this.cpu,
    required this.ram,
    required this.appMemory,
    this.countTask = 0,
    this.appCpu = 0
  });
}
