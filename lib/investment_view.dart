import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'investments_view_model.dart';

class InvestmentsView extends StatefulWidget {
  const InvestmentsView({super.key});

  @override
  State<InvestmentsView> createState() => _InvestmentsViewState();
}

class _InvestmentsViewState extends State<InvestmentsView> {
  final InvestmentsViewModel _viewModel = InvestmentsViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.loadInvestments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPortfolioOverview(),
            const SizedBox(height: 24),
            _buildPortfolioChart(),
            const SizedBox(height: 24),
            _buildAssetClasses(),
            const SizedBox(height: 24),
            _buildGainsLosses(),
            const SizedBox(height: 24),
            _buildAIInsights(),
            const SizedBox(height: 134),
          ],
        ),
      ),
      );
  }

  Widget _buildPortfolioOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Portfolio Value',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.visibility_outlined, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${_viewModel.totalPortfolioValue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _viewModel.totalGainLoss >= 0
                      ? const Color(0xFF22C55E).withValues(alpha: 0.2)
                      : const Color(0xFFEF4444).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _viewModel.totalGainLoss >= 0
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFEF4444),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _viewModel.totalGainLoss >= 0
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: _viewModel.totalGainLoss >= 0
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '₹${_viewModel.totalGainLoss.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _viewModel.totalGainLoss >= 0
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_viewModel.totalGainLoss >= 0 ? "+" : ""}${_viewModel.totalReturnPercentage.toStringAsFixed(2)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Portfolio Performance',
                style: TextStyle(
                  color: Color(0xFF1A1D29),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '1M',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50000,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Color(0xFFE5E7EB),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '₹${(value / 1000).toStringAsFixed(0)}k',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const weeks = ['W1', 'W2', 'W3', 'W4'];
                        if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              weeks[value.toInt()],
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 11,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _viewModel.portfolioPerformanceData,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                    ),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: const Color(0xFF22C55E),
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF22C55E).withValues(alpha: 0.3),
                          const Color(0xFF22C55E).withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetClasses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Asset Classes',
          style: TextStyle(
            color: Color(0xFF1A1D29),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...(_viewModel.assetClasses.map((asset) => _buildAssetCard(asset))),
      ],
    );
  }

  Widget _buildAssetCard(AssetClass asset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: asset.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              asset.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.name,
                  style: const TextStyle(
                    color: Color(0xFF1A1D29),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${asset.currentValue.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: asset.returnPercentage >= 0
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      asset.returnPercentage >= 0
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: asset.returnPercentage >= 0
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${asset.returnPercentage.abs().toStringAsFixed(2)}%',
                      style: TextStyle(
                        color: asset.returnPercentage >= 0
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${asset.percentage.toStringAsFixed(1)}% of portfolio',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGainsLosses() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gains & Losses Summary',
            style: TextStyle(
              color: Color(0xFF1A1D29),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildGainLossCard(
                  'Total Gains',
                  _viewModel.totalGains,
                  true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGainLossCard(
                  'Total Losses',
                  _viewModel.totalLosses,
                  false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Invested',
                  _viewModel.totalInvested,
                  Icons.account_balance_wallet,
                  const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Current',
                  _viewModel.totalPortfolioValue,
                  Icons.trending_up,
                  const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGainLossCard(String title, double amount, bool isGain) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGain
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGain
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFFECACA),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGain ? Icons.arrow_upward : Icons.arrow_downward,
                color: isGain
                    ? const Color(0xFF22C55E)
                    : const Color(0xFFEF4444),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isGain
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: isGain
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'AI Insights',
              style: TextStyle(
                color: Color(0xFF1A1D29),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...(_viewModel.aiInsights.map((insight) => _buildInsightCard(insight))),
      ],
    );
  }

  Widget _buildInsightCard(AIInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: insight.borderColor,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: insight.iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  insight.icon,
                  color: insight.iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  insight.type,
                  style: TextStyle(
                    color: insight.textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (insight.type == 'RISK ALERT')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: insight.iconColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'HIGH',
                    style: TextStyle(
                      color: insight.iconColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight.message,
            style: TextStyle(
              color: insight.textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          if (insight.actionText != null) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: insight.iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      insight.actionText!,
                      style: TextStyle(
                        color: insight.iconColor,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      color: insight.iconColor,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}