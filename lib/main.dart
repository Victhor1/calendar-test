import 'package:flutter/material.dart';
import 'widgets/custom_calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool _showFullCalendar = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<DateTime, ({int count, Color color})> dummyEvents = {
      DateTime(DateTime.now().year, DateTime.now().month, 15): (
        count: 3,
        color: Colors.purple,
      ),
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day): (
        count: 4,
        color: Colors.orange,
      ),
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       const Text(
            //         'Mostrar calendario completo',
            //         style: TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //       Switch(
            //         value: _showFullCalendar,
            //         onChanged: (value) {
            //           setState(() {
            //             _showFullCalendar = value;
            //           });
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: .5),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: CustomCalendar.month(
                  key: const ValueKey('month_calendar'),
                  events: dummyEvents,
                  onPageChanged: (date) {
                    print('Mes actual: \${date.month} / \${date.year}');
                  },
                  onDaySelected: (date) {
                    print(
                      'Día seleccionado: \${date.day}/\${date.month}/\${date.year}',
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
