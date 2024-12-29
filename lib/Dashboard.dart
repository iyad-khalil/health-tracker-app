import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'semaine';
  final _user = FirebaseAuth.instance.currentUser;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFA7FFEB), Color(0xFF1DE9B6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Tableau de Bord',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade700, Colors.teal.shade300],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.dashboard,
                        size: 80,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodSelector()
                          .animate()
                          .fadeIn(duration: 600.ms, delay: 300.ms),
                      const SizedBox(height: 20),
                      _buildChartSection(
                        title: 'Activité Physique',
                        chart: _buildActivityChart(),
                      )
                          .animate()
                          .slideX(begin: 50, duration: 600.ms, delay: 900.ms),
                      const SizedBox(height: 30),
                      _buildChartSection(
                        title: 'Répartition Nutritionnelle',
                        chart: _buildNutritionChart(),
                      )
                          .animate()
                          .slideY(begin: 50, duration: 600.ms, delay: 1200.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: _selectedPeriod,
        items: ['jour', 'semaine', 'mois']
            .map((period) => DropdownMenuItem(
                  value: period,
                  child: Text(
                    period.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedPeriod = value!;
            _updateDateRange();
          });
        },
        icon: const Icon(Icons.arrow_drop_down, color: Colors.teal),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: Colors.white,
      ),
    );
  }

  void _updateDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'jour':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
        break;
      case 'semaine':
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case 'mois':
        _startDate = DateTime(now.year, now.month - 1, now.day);
        _endDate = now;
        break;
    }
  }

  Widget _buildChartSection({required String title, required Widget chart}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
          chart,
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('activity_data')
          .orderBy('timestamp', descending: true)
          .limit(30)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final data = docs.map((doc) {
          final activityData = doc.data() as Map<String, dynamic>;
          final calories = activityData['calories_burned'] ?? 0;
          final timestamp = (activityData['timestamp'] as Timestamp).toDate();
          final activityType =
              activityData['activity_type'] as String? ?? 'Activité';

          return ChartSampleData(
            x: activityType, // Use activity type from Firebase for the x-axis
            y: calories.toDouble(),
            secondaryData:
                '${DateFormat('dd/MM').format(timestamp)} - $activityType',
          );
        }).toList();

        return SfCartesianChart(
          primaryXAxis: CategoryAxis(
            title: AxisTitle(
              text: 'Activité',
              textStyle: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
            labelStyle: const TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
            interval: 1,
          ),
          primaryYAxis: NumericAxis(
            labelStyle: const TextStyle(color: Colors.teal),
            title: AxisTitle(
              text: 'Calories brûlées',
              textStyle: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          plotAreaBorderWidth: 0,
          series: <CartesianSeries<ChartSampleData, String>>[
            ColumnSeries<ChartSampleData, String>(
              dataSource: data,
              xValueMapper: (ChartSampleData data, _) => data.x,
              yValueMapper: (ChartSampleData data, _) => data.y,
              color: Colors.teal,
              borderRadius: BorderRadius.circular(4),
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          tooltipBehavior: TooltipBehavior(
            enable: true,
            format: 'point.secondaryData : point.y calories',
          ),
        );
      },
    );
  }

  void _showActivityDetails(BuildContext context, ChartSampleData data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails de l\'activité'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${data.secondaryData}'),
              Text('Calories brûlées: ${data.y.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildNutritionChart() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .collection('nutrition')
          .where('timestamp', isGreaterThanOrEqualTo: _startDate)
          .where('timestamp', isLessThanOrEqualTo: _endDate)
          .orderBy('timestamp', descending: true)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Aucune donnée nutritionnelle disponible pour cette période',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final data = snapshot.data!.docs;
        final totalProteins = data.fold<double>(
            0,
            (sum, doc) =>
                sum +
                ((doc.data() as Map<String, dynamic>)['proteins'] as num? ??
                    0));
        final totalCarbs = data.fold<double>(
            0,
            (sum, doc) =>
                sum +
                ((doc.data() as Map<String, dynamic>)['carbs'] as num? ?? 0));
        final totalFat = data.fold<double>(
            0,
            (sum, doc) =>
                sum +
                ((doc.data() as Map<String, dynamic>)['fat'] as num? ?? 0));

        return Column(
          children: [
            SfCircularChart(
              series: <CircularSeries>[
                DoughnutSeries<_PieChartData, String>(
                  dataSource: [
                    _PieChartData('Protéines', totalProteins, Colors.blue),
                    _PieChartData('Glucides', totalCarbs, Colors.orange),
                    _PieChartData('Lipides', totalFat, Colors.red),
                  ],
                  xValueMapper: (_PieChartData data, _) => data.category,
                  yValueMapper: (_PieChartData data, _) => data.value,
                  pointColorMapper: (_PieChartData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                    textStyle: TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold),
                  ),
                  innerRadius: '60%',
                  enableTooltip: true,
                )
              ],
              tooltipBehavior: TooltipBehavior(enable: true),
              onSelectionChanged: (SelectionArgs args) {
                _showNutritionDetails(
                    context,
                    args.seriesRenderer as DoughnutSeriesRenderer,
                    args.pointIndex!);
                            },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.blue, 'Protéines'),
                const SizedBox(width: 10),
                _buildLegendItem(Colors.orange, 'Glucides'),
                const SizedBox(width: 10),
                _buildLegendItem(Colors.red, 'Lipides'),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showNutritionDetails(BuildContext context,
      DoughnutSeriesRenderer seriesRenderer, int pointIndex) {
    final data = seriesRenderer.dataSource![pointIndex] as _PieChartData;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Détails nutritionnels'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Catégorie: ${data.category}'),
              Text('Quantité: ${data.value.toStringAsFixed(2)} g'),
              Text(
                  'Pourcentage: ${(data.value / seriesRenderer.dataSource!.fold<double>(0, (sum, item) => sum + (item as _PieChartData).value) * 100).toStringAsFixed(2)}%'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ],
    );
  }
}

class ChartSampleData {
  final String x; // Changed from double to String
  final double y;
  final String
      secondaryData; // Added to hold additional information like date and activity type

  ChartSampleData(
      {required this.x, required this.y, required this.secondaryData});
}

class _PieChartData {
  final String category;
  final double value;
  final Color color;
  _PieChartData(this.category, this.value, this.color);
}
