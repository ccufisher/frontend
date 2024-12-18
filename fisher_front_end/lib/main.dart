import 'package:flutter/cupertino.dart';
import 'package:fisher_front_end/route/route.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: Navigator(
        // change initialRoute to test different page
        initialRoute: 'loginPage',
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
