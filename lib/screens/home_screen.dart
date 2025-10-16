import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/monitor_timeline_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedPeriod = '24h';
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _dashboardData;

  final List<Map<String, String>> _periodOptions = [
    {'value': '30m', 'label': '30 mins'},
    {'value': '1h', 'label': '1 hour'},
    {'value': '6h', 'label': '6 hours'},
    {'value': '24h', 'label': '24 hours'},
    {'value': '7d', 'label': '7 days'},
    {'value': '30d', 'label': '30 days'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ApiService.getMonitorUptimeList(_selectedPeriod);
      setState(() {
        _dashboardData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onPeriodChanged(String? newPeriod) {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      setState(() {
        _selectedPeriod = newPeriod;
      });
      _loadDashboardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Statistics
    int totalMonitors = 0;
    int totalError = 0;
    int totalOk = 0;
    int totalOther = 0;

    if (_dashboardData != null) {
      final monitors = _dashboardData!['monitors'] as List? ?? [];
      totalMonitors = monitors.length;
      
      for (var monitor in monitors) {
        final status = monitor['last_check_status'];
        if (status == -1) {
          totalError++;
        } else if (status == 1) {
          totalOk++;
        } else {
          totalOther++;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📊 Statistics',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Period Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          isDense: true,
                          items: _periodOptions.map((option) {
                            return DropdownMenuItem<String>(
                              value: option['value'],
                              child: Text(
                                option['label']!,
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: _onPeriodChanged,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildStatItem('Total', totalMonitors, Colors.grey),
                    _buildStatItem('Error', totalError, Colors.red),
                    _buildStatItem('OK', totalOk, Colors.green),
                    if (totalOther > 0)
                      _buildStatItem('Other', totalOther, Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Timeline List
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading monitors...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_dashboardData == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    final monitors = _dashboardData!['monitors'] as List? ?? [];

    if (monitors.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No monitors found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Add monitors to see them here',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: monitors.length,
      itemBuilder: (context, index) {
        final monitor = monitors[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: MonitorTimelineWidget(
            monitorData: monitor,
            period: _selectedPeriod,
            onPeriodChanged: (newPeriod) {
              setState(() {
                _selectedPeriod = newPeriod;
              });
              _loadDashboardData();
            },
          ),
        );
      },
    );
  }
}
