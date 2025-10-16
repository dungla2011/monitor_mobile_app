/**
 * Monitor Timeline Widget
 * Hiển thị trạng thái On/Off dạng timeline đơn giản với các gạch dọc màu
 */
class MonitorTimeline {
    constructor(containerId, options = {}) {
        this.container = document.getElementById(containerId);
        if (!this.container) {
            console.error('Container not found:', containerId);
            return;
        }

        this.options = {
            apiUrl: options.apiUrl || '/api/monitor-graph/uptime',
            monitorId: options.monitorId || null,
            monitorName: options.monitorName || null,
            urlEdit: options.urlEdit || null,
            period: options.period || '24h',
            height: options.height || 20,
            autoRefresh: options.autoRefresh || false,
            refreshInterval: options.refreshInterval || 60000,
            showLabels: options.showLabels !== false,
            showStats: options.showStats !== false,
            showTimeRange: options.showTimeRange !== false,
            showMonitorName: options.showMonitorName !== false,
            timeRanges: ['30m', '1h', '6h', '24h', '7d', '30d'],
            ...options
        };

        // Ensure timeRanges is always an array
        if (!Array.isArray(this.options.timeRanges)) {
            this.options.timeRanges = ['30m', '1h', '6h', '24h', '7d', '30d'];
        }

        this.data = null;
        this.refreshTimer = null;

        // Không auto-init nếu options.skipInit = true (dùng cho batch loading)
        if (!options.skipInit) {
            this.init();
        }
    }

    init() {
        this.render();
        
        // Chỉ load data nếu có apiUrl (không phải batch mode)
        if (this.options.apiUrl) {
            this.loadData();
        }

        if (this.options.autoRefresh) {
            this.startAutoRefresh();
        }
    }

    render() {
        const editIcon = this.options.urlEdit && this.options.monitorId ? `
            <button class="timeline-edit-btn" title="Edit Monitor">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                    <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                </svg>
            </button>
        ` : '';

        const monitorNameSection = this.options.showMonitorName && this.options.monitorName ? `
            <div class="timeline-monitor-name">
                ${editIcon}
                <span class="monitor-name-text">${this.options.monitorName}</span>
            </div>
        ` : '';

        const timeRangeSelector = this.options.showTimeRange ? `
            <div class="timeline-time-range">
                <select class="time-range-select" data-timeline-id="${this.container.id}">
                    ${this.options.timeRanges.map(range =>
                        `<option value="${range}" ${range === this.options.period ? 'selected' : ''}>${this.formatRangeLabel(range)}</option>`
                    ).join('')}
                </select>
            </div>
        ` : '';

        this.container.innerHTML = `
            <div class="monitor-timeline-widget">
                <div class="timeline-header">
                    ${monitorNameSection}
                    <div class="timeline-header-right">
                        ${this.options.showStats ? '<div class="timeline-stats"></div>' : ''}
                        ${timeRangeSelector}
                    </div>
                </div>
                <div class="timeline-container" style="height: ${this.options.height}px;">
                    <div class="timeline-loading">Đang tải...</div>
                </div>
                ${this.options.showLabels ? '<div class="timeline-labels"></div>' : ''}
            </div>
        `;

        // Attach event listener cho edit button
        if (this.options.urlEdit && this.options.monitorId) {
            const editBtn = this.container.querySelector('.timeline-edit-btn');
            if (editBtn) {
                editBtn.addEventListener('click', (e) => {
                    e.preventDefault();
                    const editUrl = `${this.options.urlEdit}`;
                    window.location.href = editUrl;
                });
            }
        }

        // Attach event listener cho time range selector
        if (this.options.showTimeRange) {
            const select = this.container.querySelector('.time-range-select');
            if (select) {
                select.addEventListener('change', (e) => {
                    this.updateOptions({ period: e.target.value });
                });
            }
        }
    }

    formatRangeLabel(range) {
        const labels = {
            '30m': '30 mins',
            '1h': '1h',
            '6h': '6h',
            '24h': '24h',
            '7d': '7 days',
            '30d': '30 days',
            '90d': '90 days'
        };
        return labels[range] || range;
    }

    async loadData() {
        try {
            const url = new URL(this.options.apiUrl, window.location.origin);
            if (this.options.monitorId) {
                url.searchParams.append('monitor_id', this.options.monitorId);
            }
            url.searchParams.append('period', this.options.period);

            const response = await fetch(url.toString());
            if (!response.ok) {
                // Try to parse error message from response
                let errorMessage = `HTTP ${response.status}`;
                try {
                    const errorData = await response.json();
                    errorMessage = errorData.error || errorData.message || errorMessage;
                } catch (e) {
                    // If response is not JSON, try to get text
                    try {
                        const errorText = await response.text();
                        if (errorText) {
                            errorMessage = errorText;
                        }
                    } catch (e2) {
                        // Keep default error message
                    }
                }
                throw new Error(errorMessage);
            }

            this.data = await response.json();
            this.renderTimeline();
        } catch (error) {
            console.error('Error loading data:', error);
            this.showError('Cannot load data: ' + error.message);
        }
    }

    renderTimeline() {
        // Chuẩn hóa dữ liệu từ API
        let timelineData = [];
        let uptimePercentage = 0;
        let totalChecks = 0;

        // Xử lý cấu trúc mới từ API (chart_data)
        if (this.data && this.data.chart_data) {
            const chartData = this.data.chart_data;
            if (chartData.labels && chartData.status && chartData.labels.length > 0) {
                timelineData = chartData.labels.map((label, index) => ({
                    time: label,
                    status: chartData.status[index]
                }));

                if (this.data.stats) {
                    uptimePercentage = this.data.stats.uptime_percentage || 0;
                    totalChecks = this.data.stats.total_checks || chartData.labels.length;
                }
            }
        }
        // Xử lý cấu trúc cũ (data array)
        else if (this.data && this.data.data && this.data.data.length > 0) {
            timelineData = this.data.data;
            uptimePercentage = this.data.uptime_percentage || 0;
            totalChecks = this.data.data.length;
        }

        // Kiểm tra có dữ liệu không
        if (timelineData.length === 0) {
            this.showError('Không có dữ liệu');
            return;
        }

        const container = this.container.querySelector('.timeline-container');
        const labels = this.container.querySelector('.timeline-labels');
        const stats = this.container.querySelector('.timeline-stats');

        // Render stats nếu có
        if (stats && uptimePercentage !== undefined) {
            const uptime = uptimePercentage;
            const downtime = 100 - uptime;
            stats.innerHTML = `
                <div class="stat-item">
                    <span class="stat-label">Uptime:</span>
                    <span class="stat-value stat-up">${uptime.toFixed(2)}%</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Downtime:</span>
                    <span class="stat-value stat-down">${downtime.toFixed(2)}%</span>
                </div>
                <div class="stat-item">
                    <span class="stat-label">Checks:</span>
                    <span class="stat-value">${totalChecks}</span>
                </div>
            `;
        }

        // Tính toán số bars dựa trên container width
        // Mỗi bar: 2-3px, gap tự động fill bởi space-between
        const containerWidth = container.offsetWidth || 800;
        
        // Tính số bars tối đa có thể hiển thị
        // Với mỗi bar tối thiểu 2px + gap 1px = 3px/bar
        const maxPossibleBars = Math.floor(containerWidth / 3);
        
        // Quyết định có cần group không
        const totalDataPoints = timelineData.length;
        const needsGrouping = totalDataPoints > maxPossibleBars;
        const groupSize = needsGrouping ? Math.ceil(totalDataPoints / maxPossibleBars) : 1;
        
        console.log('Container:', containerWidth + 'px', 'Total points:', totalDataPoints, 
                    'Max bars:', maxPossibleBars, 'Group size:', groupSize);

        // Group data
        const groupedData = [];
        for (let i = 0; i < totalDataPoints; i += groupSize) {
            const group = timelineData.slice(i, Math.min(i + groupSize, totalDataPoints));
            
            // Xác định status chính của group (status xuất hiện nhiều nhất)
            const upCount = group.filter(item => item.status === 1).length;
            const downCount = group.length - upCount;
            const dominantStatus = upCount >= downCount ? 1 : 0;
            
            groupedData.push({
                status: dominantStatus,
                statusName: dominantStatus === 1 ? 'up' : 'down',
                count: group.length,
                startTime: group[0].time,
                endTime: group[group.length - 1].time,
                upCount: upCount,
                downCount: downCount
            });
        }

        const totalBars = groupedData.length;
        
        // Tính toán bar width: 2-3px dựa trên số lượng bars
        // Nhiều bars → width nhỏ (2px), ít bars → width lớn (3px)
        // Gap sẽ tự động fill bởi CSS justify-content: space-between
        let barWidth = 3; // Mặc định 3px
        
        if (totalBars * 4 > containerWidth) {
            // Quá nhiều bars, giảm width xuống 2px (tối thiểu)
            barWidth = 2;
        }
        
        console.log('Total bars:', totalBars, 'Bar width:', barWidth + 'px', 'Gaps: auto');

        // Render timeline bars - gap tự động fill bởi space-between
        const barsHtml = groupedData.map((group, index) => {
            const statusText = group.statusName === 'up' ? 'Online' : 'Offline';
            
            const timeRange = group.count === 1 
                ? group.startTime 
                : `${group.startTime} - ${group.endTime}`;
            
            const tooltip = group.count === 1
                ? `${statusText} - ${timeRange}`
                : `${statusText} (${group.count} checks: ${group.upCount} up, ${group.downCount} down)\n${timeRange}`;
            
            return `
                <div class="timeline-bar status-${group.statusName}"
                     style="width: ${barWidth}px;"
                     title="${tooltip}">
                </div>
            `;
        }).join('');

        container.innerHTML = `<div class="timeline-bars">${barsHtml}</div>`;

        // Render labels nếu có
        if (labels && this.options.showLabels) {
            this.renderLabels(labels, timelineData);
        }
    }

    renderLabels(labelsContainer, timelineData) {
        const totalPoints = timelineData.length;
        if (totalPoints === 0) return;

        // Lấy điểm đầu, giữa và cuối
        const firstPoint = timelineData[0];
        const lastPoint = timelineData[totalPoints - 1];
        const middleIndex = Math.floor(totalPoints / 2);
        const middlePoint = timelineData[middleIndex];

        // Format time để hiển thị ngắn gọn
        const formatTime = (timeStr) => {
            const date = new Date(timeStr);
            const now = new Date();
            const isToday = date.toDateString() === now.toDateString();

            if (isToday) {
                return date.toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });
            } else {
                return date.toLocaleDateString('vi-VN', { month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
            }
        };

        labelsContainer.innerHTML = `
            <div class="timeline-label timeline-label-start">${formatTime(firstPoint.time)}</div>
            <div class="timeline-label timeline-label-middle">${formatTime(middlePoint.time)}</div>
            <div class="timeline-label timeline-label-end">${formatTime(lastPoint.time)}</div>
        `;
    }

    showError(message) {
        const container = this.container.querySelector('.timeline-container');
        if (container) {
            container.innerHTML = `<div class="timeline-error">${message}</div>`;
        }
    }

    startAutoRefresh() {
        this.refreshTimer = setInterval(() => {
            this.loadData();
        }, this.options.refreshInterval);
    }

    stopAutoRefresh() {
        if (this.refreshTimer) {
            clearInterval(this.refreshTimer);
            this.refreshTimer = null;
        }
    }

    destroy() {
        this.stopAutoRefresh();
        if (this.container) {
            this.container.innerHTML = '';
        }
    }

    // Update options và reload
    updateOptions(newOptions) {
        this.options = { ...this.options, ...newOptions };
        this.loadData();
    }
}

// Batch init - Load tất cả monitors cùng lúc với 1 API call
async function initMonitorTimelineBatch(container) {
    const apiUrl = container.getAttribute('data-api-url');
    const period = container.getAttribute('data-period') || '24h';
    const height = parseInt(container.getAttribute('data-height')) || 20;
    
    console.log('Batch loading monitors from:', apiUrl, 'Period:', period);
    
    try {
        const url = new URL(apiUrl, window.location.origin);
        url.searchParams.append('period', period);
        
        const response = await fetch(url.toString());
        if (!response.ok) {
            throw new Error(`HTTP ${response.status}`);
        }
        
        const result = await response.json();
        
        if (!result.success || !result.monitors || result.monitors.length === 0) {
            container.innerHTML = '<div style="text-align: center; padding: 20px; color: #999;">Không có monitor nào</div>';
            return;
        }
        
        console.log('Loaded', result.monitors.length, 'monitors');
        
        // Clear loading message
        container.innerHTML = '';
        
        // Create timeline widget cho mỗi monitor
        result.monitors.forEach((monitor, index) => {
            // Create container element
            const widgetId = `monitor-timeline-${monitor.monitor_id}`;
            const widgetDiv = document.createElement('div');
            widgetDiv.id = widgetId;
            container.appendChild(widgetDiv);
            
            // Create widget với data đã load sẵn - KHÔNG auto init
            const widget = new MonitorTimeline(widgetId, {
                apiUrl: null, // Không cần load lại
                monitorId: monitor.monitor_id,
                monitorName: monitor.monitor_name,
                urlEdit: `/member/monitor-item/edit/${monitor.monitor_id}`,
                period: period,
                height: height,
                autoRefresh: false,
                showLabels: true,
                showStats: true,
                showTimeRange: false, // ẨN time range selector ở widget - dùng global selector
                showMonitorName: true,
                skipInit: true, // QUAN TRỌNG: Skip auto init
            });
            
            // Inject data trực tiếp
            widget.data = {
                chart_data: monitor.chart_data,
                stats: monitor.stats
            };
            
            // Manual init: render UI và timeline
            widget.render();
            widget.renderTimeline();
        });
        
        console.log('Batch init completed:', result.monitors.length, 'widgets created');
        
    } catch (error) {
        console.error('Batch loading failed:', error);
        container.innerHTML = `<div style="text-align: center; padding: 20px; color: #f44336;">
            ❌ Lỗi tải dữ liệu: ${error.message}
        </div>`;
    }
}

// Auto-init widgets với data attributes
document.addEventListener('DOMContentLoaded', function() {
    // Batch init - ưu tiên load trước
    const batchContainers = document.querySelectorAll('[data-batch-init="monitor-timeline-batch"]');
    batchContainers.forEach(container => {
        initMonitorTimelineBatch(container);
    });
    
    // Global time range selector handler
    const globalSelector = document.getElementById('global-time-range-selector');
    if (globalSelector) {
        globalSelector.addEventListener('change', function() {
            const newPeriod = this.value;
            console.log('Global time range changed to:', newPeriod);
            
            // Update tất cả batch containers
            batchContainers.forEach(container => {
                container.setAttribute('data-period', newPeriod);
                // Reload batch data với period mới
                initMonitorTimelineBatch(container);
            });
        });
    }
    
    // Single widget init (fallback cho các widget riêng lẻ)
    const widgets = document.querySelectorAll('[data-auto-init="monitor-timeline"]');
    widgets.forEach(element => {
        const timeRangesAttr = element.getAttribute('data-time-ranges');
        const options = {
            apiUrl: element.getAttribute('data-api-url'),
            monitorId: element.getAttribute('data-monitor-id'),
            monitorName: element.getAttribute('data-monitor-name'),
            urlEdit: element.getAttribute('data-url-edit'),
            period: element.getAttribute('data-period'),
            height: parseInt(element.getAttribute('data-height')) || 20,
            autoRefresh: element.getAttribute('data-auto-refresh') === 'true',
            refreshInterval: parseInt(element.getAttribute('data-refresh-interval')) || 60000,
            showLabels: element.getAttribute('data-show-labels') !== 'false',
            showStats: element.getAttribute('data-show-stats') !== 'false',
            showTimeRange: element.getAttribute('data-show-time-range') !== 'false',
            showMonitorName: element.getAttribute('data-show-monitor-name') !== 'false',
            timeRanges: timeRangesAttr ? timeRangesAttr.split(',') : undefined,
        };

        new MonitorTimeline(element.id, options);
    });
});
