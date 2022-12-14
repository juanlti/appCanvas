import 'package:cliente_app_canvas/src/pages/painter.dart';
import 'package:cliente_app_canvas/src/services/sockete.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Sockets!',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Offset> points = [];
  final GlobalKey key = GlobalKey();
  late Sockets socket;

  @override
  void initState() {
    super.initState();
    socket = Sockets();

    Future.delayed(const Duration(seconds: 5)).then(
      (_) => socket.clearCanvas().listen((event) {
        points.clear();
      }),
    );
  }
// renderBox.globalToLocal(globalPosition) as RenderBox;

  void _addPointsForCurrentFrame(Offset globalPosition) {
    final RenderBox renderBox =
        key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(globalPosition);

    socket.emitPaint(offset.dx, offset.dy);
  }

  void _finishLine() {
    socket.emitEndLine();
  }

  void _clearCanvas() {
    socket.emitClearCanvas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          key: key,
          color: Colors.grey[200],
          height: MediaQuery.of(context).size.height - 200,
          width: MediaQuery.of(context).size.width - 50,
          child: GestureDetector(
            onPanDown: (details) {
              _addPointsForCurrentFrame(details.globalPosition);
            },
            onPanUpdate: (details) {
              _addPointsForCurrentFrame(details.globalPosition);
            },
            onPanEnd: (_) {
              _finishLine();
            },
            child: StreamBuilder<Offset>(
              stream: socket.recivedPaint(),
              builder: (BuildContext context, AsyncSnapshot<Offset> snapshot) {
                if (!snapshot.hasData) {
                  points.add(Offset.zero);
                  print('estoy en nulo');
                }
                //  return Text('ESTOY EN PANTALLA');

                return CustomPaint(
                    painter: Painter(
                        offsets: points..add(snapshot.data ?? Offset.zero),
                        drawColor: Colors.red));
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearCanvas,
        tooltip: 'Increment',
        child: Icon(Icons.delete),
      ),
    );
  }
}
