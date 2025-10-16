import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/monitor_timeline_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToPingList;
  
  const HomeScreen({
    super.key,
    this.onNavigateToPingList,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedPeriod = '24h';
  bool _isLoading = false;
  bool _isRefreshing = false;
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

  // Cache key for SharedPreferences
  String _getCacheKey() => 'dashboard_uptime_${_selectedPeriod}';

  // Load cached data from SharedPreferences
  Future<Map<String, dynamic>?> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_getCacheKey());
      if (cachedJson != null) {
        return json.decode(cachedJson) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading cache: $e');
    }
    return null;
  }

  // Save data to SharedPreferences
  Future<void> _saveCachedData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(data);
      await prefs.setString(_getCacheKey(), jsonString);
    } catch (e) {
      debugPrint('Error saving cache: $e');
    }
  }

  Future<void> _loadDashboardData({bool isRefresh = false}) async {
    // Load cache first (only if not already showing data)
    if (!isRefresh && _dashboardData == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      final cachedData = await _loadCachedData();
      if (cachedData != null && mounted) {
        setState(() {
          _dashboardData = cachedData;
          _isLoading = false;
        });
      }
    }

    // Set refreshing state
    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
        _errorMessage = null;
      });
    } else if (_dashboardData == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    // Fetch fresh data from API
    try {
      final data = await ApiService.getMonitorUptimeList(_selectedPeriod);
      
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = null;
        });
        
        // Save to cache
        await _saveCachedData(data);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          // Only show error if we don't have cached data
          if (_dashboardData == null) {
            _errorMessage = e.toString();
          }
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  void _onPeriodChanged(String? newPeriod) {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      setState(() {
        _selectedPeriod = newPeriod;
        _dashboardData = null; // Clear current data
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

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(l10n.homeDashboard),
            if (_isRefreshing) ...[
              const SizedBox(width: 12),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : () => _loadDashboardData(isRefresh: true),
            tooltip: l10n.homeRefresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics Header - Single Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  '📊',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      _buildStatItem(l10n.homeTotal, totalMonitors, Colors.grey),
                      _buildStatItem(l10n.homeError, totalError, Colors.red),
                      _buildStatItem(l10n.homeOk, totalOk, Colors.green),
                      if (totalOther > 0)
                        _buildStatItem(l10n.homeOther, totalOther, Colors.orange),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Period Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: _onPeriodChanged,
                    ),
                  ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Ping List tab
          widget.onNavigateToPingList?.call(1);
        },
        tooltip: l10n.homeAddPingItem,
        child: const Icon(Icons.add),
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
    final l10n = AppLocalizations.of(context)!;
    
    // Show loading only when no data and not refreshing
    if (_isLoading && _dashboardData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.homeLoadingMonitors),
          ],
        ),
      );
    }

    // Show error only when no data
    if (_errorMessage != null && _dashboardData == null) {
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
                onPressed: () => _loadDashboardData(isRefresh: true),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.homeRetry),
              ),
            ],
          ),
        ),
      );
    }

    if (_dashboardData == null) {
      return Center(
        child: Text(l10n.homeNoData),
      );
    }

    final monitors = _dashboardData!['monitors'] as List? ?? [];

    if (monitors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                l10n.homeNoMonitors,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.homeAddMonitorsHint,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
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
              _onPeriodChanged(newPeriod);
            },
            onEditTapped: () {
              // Navigate to Ping List tab
              widget.onNavigateToPingList?.call(1);
            },
          ),
        );
      },
    );
  }
}
