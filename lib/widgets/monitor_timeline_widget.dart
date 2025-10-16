import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonitorTimelineWidget extends StatelessWidget {
  final Map<String, dynamic> monitorData;
  final String period;
  final Function(String)? onPeriodChanged;

  const MonitorTimelineWidget({
    super.key,
    required this.monitorData,
    required this.period,
    this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Extract data
    final monitorName = monitorData['monitor_name'] ?? 'Unknown';
    final monitorId = monitorData['monitor_id'];
    final stats = monitorData['stats'] as Map<String, dynamic>? ?? {};
    final chartData = monitorData['chart_data'] as Map<String, dynamic>? ?? {};
    
    final uptimePercentage = stats['uptime_percentage'] ?? 0.0;
    final totalChecks = stats['total_checks'] ?? 0;
    final successfulChecks = stats['successful_checks'] ?? 0;
    final failedChecks = stats['failed_checks'] ?? 0;
    
    final labels = (chartData['labels'] as List?)?.cast<String>() ?? [];
    final statusList = (chartData['status'] as List?)?.cast<int>() ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(context, monitorName, monitorId, uptimePercentage, 
                      successfulChecks, failedChecks),
          const SizedBox(height: 12),
          
          // Timeline
          _buildTimeline(labels, statusList),
          
          const SizedBox(height: 8),
          
          // Time Labels
          _buildTimeLabels(labels),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, dynamic id, 
                     double uptime, int up, int down) {
    return Row(
      children: [
        // Monitor Name
        Expanded(
          child: Row(
            children: [
              // Edit button
              InkWell(
                onTap: () {
                  // Navigate to edit screen
                  Navigator.pushNamed(
                    context,
                    '/monitor-item/edit',
                    arguments: id,
                  );
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.edit, size: 16, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        
        // Stats
        _buildStatItem('Uptime', '${uptime.toStringAsFixed(1)}%', 
                      uptime >= 95 ? Colors.green : Colors.orange),
        const SizedBox(width: 16),
        _buildStatItem('Up', '$up', Colors.green),
        const SizedBox(width: 16),
        _buildStatItem('Down', '$down', Colors.red),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(List<String> labels, List<int> statusList) {
    if (statusList.isEmpty) {
      return Container(
        height: 20,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Text(
            'No data',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      height: 20,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildTimelineBars(statusList, labels, constraints.maxWidth),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildTimelineBars(List<int> statusList, List<String> labels, double availableWidth) {
    if (statusList.isEmpty) return [];
    
    // Calculate max bars that can fit: (width / (2px bar + 1px gap))
    final int maxBarsCanFit = (availableWidth / 3).floor();
    
    // Sample data if needed
    List<int> displayStatus;
    List<String> displayLabels;
    
    if (statusList.length > maxBarsCanFit) {
      // Need to sample data
      final int step = (statusList.length / maxBarsCanFit).ceil();
      displayStatus = [];
      displayLabels = [];
      
      for (int i = 0; i < statusList.length; i += step) {
        // Take majority status from this group
        int endIdx = (i + step).clamp(0, statusList.length);
        List<int> group = statusList.sublist(i, endIdx);
        
        int onlineCount = group.where((s) => s == 1).length;
        displayStatus.add(onlineCount > group.length / 2 ? 1 : 0);
        displayLabels.add(i < labels.length ? labels[i] : '');
      }
    } else {
      displayStatus = statusList;
      displayLabels = labels;
    }
    
    final int totalBars = displayStatus.length;
    final double barWidth = 2.0;
    final double totalBarsWidth = totalBars * barWidth;
    final double totalGapWidth = availableWidth - totalBarsWidth;
    final int gapCount = totalBars - 1;
    final double gapWidth = gapCount > 0 ? (totalGapWidth / gapCount).clamp(1.0, double.infinity) : 0.0;
    
    List<Widget> bars = [];
    
    for (int i = 0; i < displayStatus.length; i++) {
      final status = displayStatus[i];
      final color = status == 1 ? Colors.green : Colors.red;
      final time = i < displayLabels.length ? displayLabels[i] : '';
      final statusText = status == 1 ? 'Online' : 'Offline';
      
      bars.add(
        Tooltip(
          message: '$statusText\n$time',
          child: Container(
            width: barWidth,
            color: color,
          ),
        ),
      );
      
      if (i < displayStatus.length - 1) {
        bars.add(SizedBox(width: gapWidth));
      }
    }
    
    return bars;
  }

  Widget _buildTimeLabels(List<String> labels) {
    if (labels.isEmpty) return const SizedBox.shrink();
    
    final startLabel = _formatTimeLabel(labels.first);
    final endLabel = _formatTimeLabel(labels.last);
    final middleIndex = labels.length ~/ 2;
    final middleLabel = middleIndex < labels.length 
        ? _formatTimeLabel(labels[middleIndex]) 
        : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          startLabel,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          middleLabel,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          endLabel,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  String _formatTimeLabel(String timeStr) {
    try {
      final dt = DateFormat('yyyy-MM-dd HH:mm').parse(timeStr);
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return timeStr;
    }
  }
}
