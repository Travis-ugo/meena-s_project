import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meena/feature/models/sensor.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  ChartData(this.x, this.y);
  int x;
  double y;
}

class ChartPage extends StatefulWidget {
  final String chartType;
  final List<SensorData> sensordata;

  const ChartPage({
    super.key,
    required this.chartType,
    required this.sensordata,
  });

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final List<ChartData> chartData = [];
  bool isFullscreen = false;

  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    _zoomPanBehavior = ZoomPanBehavior(
        enableDoubleTapZooming: true,
        enablePinching: true,
        enableSelectionZooming: true);

    for (var element in widget.sensordata) {
      if (element.d.isNotEmpty && element.d.isNotEmpty) {
        chartData.add(ChartData(element.ts, element.d[0]));
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CartesianSeries<ChartData, int>> getSeries() {
      switch (widget.chartType) {
        case "bar chart":
          return <CartesianSeries<ChartData, int>>[
            BarSeries<ChartData, int>(
              selectionBehavior: SelectionBehavior(enable: true),
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: Colors.orange,
            ),
          ];
        case "Trend Chart":
          return <CartesianSeries<ChartData, int>>[
            ColumnSeries<ChartData, int>(
              selectionBehavior: SelectionBehavior(enable: true),
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: Colors.green,
            ),
          ];
        case "Scatter Chart":
          return <CartesianSeries<ChartData, int>>[
            ScatterSeries<ChartData, int>(
              selectionBehavior: SelectionBehavior(enable: true),
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: Colors.green,
            ),
          ];
        case "line chart":
          return <CartesianSeries<ChartData, int>>[
            LineSeries<ChartData, int>(
              selectionBehavior: SelectionBehavior(enable: true),
              dataSource: chartData,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              color: Colors.green,
            ),
          ];
        default:
          return [];
      }
    }

    final chartWidget = SfCartesianChart(
      margin: const EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 40),
      zoomPanBehavior: _zoomPanBehavior,
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: const NumericAxis(
        labelAlignment: LabelAlignment.start,
        majorGridLines: MajorGridLines(width: 0),
        labelStyle: TextStyle(fontSize: 12),
        interval: 10,
        title: AxisTitle(text: "TimeStamp"),
      ),
      primaryYAxis: const NumericAxis(title: AxisTitle(text: "Pressure")),
      title: widget.chartType == "Bar Chart"
          ? const ChartTitle(text: "Bar Chart")
          : const ChartTitle(text: "Trend Chart"),
      series: getSeries(),
    );

    return GestureDetector(
      child: Container(
        width: 400,
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.0),
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  _enableFullscreen(!isFullscreen, chartWidget);
                },
                icon: const Icon(Icons.fullscreen),
              ),
            ),
            const SizedBox(
              width: 5.0,
            ),
            chartWidget,
          ],
        ),
      ),
    );
  }

  void _enableFullscreen(bool fullscreen, Widget chartWidget) async {
    isFullscreen = fullscreen;
    if (fullscreen) {
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      );
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return FullScreenViewPage(
              chartWidget: chartWidget,
            );
          },
        ),
      );
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );
    } else {
      SystemChrome.setPreferredOrientations(
        [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ],
      );
      SystemChrome.setPreferredOrientations([]);
    }
  }
}

class FullScreenViewPage extends StatefulWidget {
  const FullScreenViewPage({super.key, required this.chartWidget});

  final Widget chartWidget;

  @override
  State<FullScreenViewPage> createState() => _FullScreenViewPageState();
}

class _FullScreenViewPageState extends State<FullScreenViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.chartWidget,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.fullscreen_exit),
      ),
    );
  }
}
