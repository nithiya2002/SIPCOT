import 'package:logger/logger.dart';

Logger createLogger(Type type) {
  return Logger(printer: CustomLogPrinter(type.toString()));
}

class CustomLogPrinter extends LogPrinter {
  final String className;
  CustomLogPrinter(this.className);
  @override
  List<String> log(LogEvent event) {
    final color = PrettyPrinter.defaultLevelColors[event.level];
    final emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    final message = event.message;
    return [color!('$emoji : $className : $message')];
  }
}
