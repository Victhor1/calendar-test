import 'package:flutter/material.dart';
import 'widgets/custom_calendar.dart';
import 'widgets/draggable_bottom_sheet.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  final GlobalKey _calendarKey = GlobalKey();
  double _minTop = 130.0; // Valores iniciales de fallback
  double _maxTop = 330.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateDynamicHeights();
    });
  }

  void _calculateDynamicHeights() {
    final RenderBox? renderBox =
        _calendarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final size = renderBox.size;
      setState(() {
        _maxTop = size.height;
        // La diferencia exacta para ocultar 5 semanas (40px cada una) y el padding inferior (20px)
        _minTop = _maxTop - (5 * 40.0) - 20.0;
      });
    }
  }

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

    final mainColor = Colors.blue.withValues(alpha: .5);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Text(widget.title),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Calendar Background
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      key: _calendarKey,
                      width: double.infinity,
                      decoration: BoxDecoration(color: mainColor),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                        child: CustomCalendar.month(
                          key: const ValueKey('month_calendar'),
                          events: dummyEvents,
                          onPageChanged: (date) {
                            print('Mes actual: ${date.month} / ${date.year}');
                          },
                          onDaySelected: (date) {
                            print(
                              'Día seleccionado: ${date.day}/${date.month}/${date.year}',
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  // Draggable Bottom Sheet
                  DraggableBottomSheet(
                    minTop: _minTop,
                    maxTop: _maxTop,
                    child: const Center(
                      child: Text('Contenido adicional aquí'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
