import 'package:ezmoney/ai_view_model.dart';
import 'package:ezmoney/chat_view.dart' show ChatScreen;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AIAssistantView extends StatefulWidget {
  const AIAssistantView({super.key});

  @override
  State<AIAssistantView> createState() => _AIAssistantViewState();
}

class _AIAssistantViewState extends State<AIAssistantView> {
  final _viewModel = AIAssistantViewModel();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _viewModel.loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 20),
            _buildQuickPrompts(),
            const SizedBox(height: 20),
            _buildWhatIfQuestions(),
            const SizedBox(height: 24),
            _buildWhatIfSection(),
            const SizedBox(height: 24),
            if (_viewModel.simulationResults != null) _buildSimulationResults(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }


  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.waving_hand, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Hi there!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'I\'m your AI financial assistant. Ask me anything about your finances, or try out "What-If" scenarios!',
            style: TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, color: Color(0xFF8B5CF6), size: 20),
                  SizedBox(width: 8),
                  Text('Talk to EZ', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(color: Color(0xFF1A1D29), fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _viewModel.quickPrompts.map((p) => _buildPromptChip(p)).toList(),
        ),
      ],
    );
  }

  Widget _buildPromptChip(QuickPrompt prompt) {
    return InkWell(
      onTap: () => setState(() => _viewModel.selectPrompt(prompt)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: prompt.isSelected ? prompt.color : const Color(0xFFE5E7EB), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(prompt.icon, color: prompt.color, size: 18),
            const SizedBox(width: 8),
            Text(prompt.text, style: TextStyle(color: prompt.isSelected ? prompt.color : const Color(0xFF6B7280), fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildWhatIfQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 20),
            SizedBox(width: 8),
            Text('What-If Questions', style: TextStyle(color: Color(0xFF1A1D29), fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ..._viewModel.whatIfQuestions.map((q) => _buildQuestionCard(q)),
      ],
    );
  }

  Widget _buildQuestionCard(WhatIfQuestion q) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(initialMessage: q.question),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: q.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(q.icon, color: q.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(q.question, style: const TextStyle(color: Color(0xFF1A1D29), fontSize: 14))),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFF9CA3AF), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWhatIfSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.science, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('What-If Scenarios', style: TextStyle(color: Color(0xFF1A1D29), fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildSlider('Monthly Savings Increase', _viewModel.savingsIncrease, 0, 10000, Icons.savings, const Color(0xFF22C55E), (v) => setState(() => _viewModel.savingsIncrease = v)),
          const SizedBox(height: 16),
          _buildSlider('Monthly Income Change', _viewModel.incomeChange, -20000, 50000, Icons.trending_up, const Color(0xFF3B82F6), (v) => setState(() => _viewModel.incomeChange = v)),
          const SizedBox(height: 16),
          _buildSlider('Monthly Expense Reduction', _viewModel.expenseReduction, 0, 15000, Icons.trending_down, const Color(0xFFF59E0B), (v) => setState(() => _viewModel.expenseReduction = v)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _viewModel.runSimulation()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Run Simulation', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat, color: Color(0xFF8B5CF6)),
                      SizedBox(width: 8),
                      Text('Ask EZ', style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, IconData icon, Color color, Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, fontWeight: FontWeight.w600))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withValues(alpha: 0.3))),
              child: Text('₹${value.toStringAsFixed(0)}', style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(activeTrackColor: color, inactiveTrackColor: color.withValues(alpha: 0.2), thumbColor: color, trackHeight: 4),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildSimulationResults() {
    final r = _viewModel.simulationResults!;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFF22C55E).withValues(alpha: 0.1), const Color(0xFF16A34A).withValues(alpha: 0.05)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.3), width: 2),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF22C55E), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.analytics, color: Colors.white, size: 20)),
                  const SizedBox(width: 12),
                  const Text('Simulation Results', style: TextStyle(color: Color(0xFF16A34A), fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(child: _buildMetric('Current Path', '₹${r.currentScenario.toStringAsFixed(0)}', Icons.timeline, const Color(0xFF6B7280))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildMetric('New Scenario', '₹${r.newScenario.toStringAsFixed(0)}', Icons.rocket_launch, const Color(0xFF22C55E))),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 24),
                    const SizedBox(width: 12),
                    Expanded(child: Text(r.insight, style: const TextStyle(color: Color(0xFF16A34A), fontSize: 14, fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Projected Growth', style: TextStyle(color: Color(0xFF1A1D29), fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(height: 250, child: _buildChart(r)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 16), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontSize: 12))]),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChart(SimulationResults r) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (v, m) => Text('₹${(v / 1000).toStringAsFixed(0)}k', style: const TextStyle(fontSize: 11)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('M${v.toInt() + 1}', style: const TextStyle(fontSize: 11)))),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(spots: r.currentPath, isCurved: true, color: const Color(0xFF9CA3AF), barWidth: 2, dotData: const FlDotData(show: false), dashArray: [5, 5]),
          LineChartBarData(
            spots: r.newPath,
            isCurved: true,
            gradient: const LinearGradient(colors: [Color(0xFF22C55E), Color(0xFF16A34A)]),
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [const Color(0xFF22C55E).withValues(alpha: 0.3), const Color(0xFF22C55E).withValues(alpha: 0.0)])),
          ),
        ],
      ),
    );
  }
}