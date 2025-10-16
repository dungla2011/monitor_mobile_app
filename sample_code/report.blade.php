<?php
$uid = getCurrentUserId();
$mm = \App\Models\MonitorItem::where("user_id", $uid)->where( 'enable', 1)->orderBy('last_check_status', 'asc')->get();

// Thống kê
$totalEnabled = $mm->count();
$totalError = $mm->where('last_check_status', -1)->count();
$totalOk = $mm->where('last_check_status', 1)->count();
$totalOther = $totalEnabled - $totalError - $totalOk;

?>

<link rel="stylesheet" href="css/monitor-timeline.css">
<script src="js/monitor-timeline.js" data-code-pos='ppp17605166157201'></script>

<div data-code-pos='ppp17605421634041'>

<!-- Thống kê -->
<div style="background: white; padding: 15px; margin-bottom: 20px; border-radius: 5px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
    <div style="display: flex; align-items: center; gap: 20px; flex-wrap: wrap;">
        <div>
            <strong style="font-size: 16px;">📊 {{ __('member.monitor_report.statistics') }}</strong>
        </div>
        <div style="display: flex; gap: 15px; flex-wrap: wrap;">
            <span>
                <span style="color: #666;">{{ __('member.monitor_report.total') }}:</span> <strong>{{ $totalEnabled }}</strong>
            </span>
            <span>
                <span style="color: #f44336;"> {{ __('member.monitor_report.error') }}:</span> <strong style="color: #f44336;">{{ $totalError }}</strong>
            </span>
            <span>
                <span style="color: #4caf50;">✓ {{ __('member.monitor_report.ok') }}:</span> <strong style="color: #4caf50;">{{ $totalOk }}</strong>
            </span>
            @if($totalOther > 0)
            <span>
                <span style="color: #ff9800;">◷ {{ __('member.monitor_report.other') }}:</span> <strong style="color: #ff9800;">{{ $totalOther }}</strong>
            </span>
            @endif
        </div>
    </div>
    <div style="display: flex; gap: 10px; align-items: center;">
        <!-- Global Time Range Selector -->
        <select id="global-time-range-selector" class="form-control form-control-sm" style="width: auto; min-width: 100px;">
            <option value="30m">30 mins</option>
            <option value="1h">1 hour</option>
            <option value="6h">6 hours</option>
            <option value="24h" selected>24 hours</option>
            <option value="7d">7 days</option>
            <option value="30d">30 days</option>
        </select>

        <a href="/member/monitor-item" class="btn btn-primary btn-sm">
{{ __('member.monitor_report.view_all') }}
        </a>
    </div>
</div>

<!-- Container cho tất cả timelines - sẽ được populate bởi JavaScript -->
<div id="monitor-timelines-container"
     data-batch-init="monitor-timeline-batch"
     data-api-url="/api/monitor-graph/uptime-list"
     data-period="24h"
     data-height="20">
    <div style="text-align: center; padding: 20px; color: #666;">
        <div class="spinner-border" role="status">
            <span class="sr-only">Đang tải...</span>
        </div>
        <p>Đang tải dữ liệu monitor...</p>
    </div>
</div>
</div>
