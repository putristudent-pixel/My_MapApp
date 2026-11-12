import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../widgets/shared_widgets.dart';

class _HourlyForecast {
  const _HourlyForecast({
    required this.time,
    required this.temperature,
    required this.icon,
  });

  final String time;
  final String temperature;
  final IconData icon;
}

const _todayForecast = <_HourlyForecast>[
  _HourlyForecast(time: '5 AM', temperature: '16°', icon: Icons.nightlight_round),
  _HourlyForecast(time: '6 AM', temperature: '17°', icon: Icons.wb_twilight_rounded),
  _HourlyForecast(time: '7 AM', temperature: '18°', icon: Icons.wb_sunny_rounded),
  _HourlyForecast(time: '8 AM', temperature: '20°', icon: Icons.wb_sunny_rounded),
  _HourlyForecast(time: '9 AM', temperature: '21°', icon: Icons.cloud_rounded),
  _HourlyForecast(time: '10 AM', temperature: '22°', icon: Icons.cloud_rounded),
];

class WeatherPreview extends StatelessWidget {
  const WeatherPreview({required this.onOpenForecast});

  final VoidCallback onOpenForecast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_sunny_rounded, color: Color(0xFFE5A227), size: 25),
              SizedBox(width: 8),
              Text(
                'Partly sunny · 18°',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _todayForecast.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final forecast = _todayForecast[index];
                return SizedBox(
                  width: 58,
                  child: Column(
                    children: [
                      Text(forecast.time, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                      const SizedBox(height: 6),
                      Icon(forecast.icon, color: const Color(0xFFE5A227), size: 25),
                      const SizedBox(height: 4),
                      Text(
                        forecast.temperature,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                      ),
                      if (forecast.time == '8 AM')
                        const Text('Now', style: TextStyle(fontSize: 11, color: AppColors.green)),
                    ],
                  ),
                );
              },
            ),
          ),
          OutlinedButton.icon(
            onPressed: onOpenForecast,
            icon: const Icon(Icons.calendar_month_rounded),
            label: const Text('View weather forecast'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Sample forecast for the demo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class WeatherForecastScreen extends StatelessWidget {
  const WeatherForecastScreen({
    required this.onBack,
    required this.onTabSelected,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onBack),
        title: const Text('Weather forecast'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  Icon(Icons.wb_sunny_rounded, color: Color(0xFFE5A227), size: 56),
                  SizedBox(height: 8),
                  Text('Today · Partly sunny', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  Text('18° now · High 22° · Low 16°', style: TextStyle(fontSize: 16, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionTitle(title: 'Today by the hour'),
            const SizedBox(height: 10),
            ..._todayForecast.map(
              (forecast) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      SizedBox(width: 64, child: Text(forecast.time, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink))),
                      Icon(forecast.icon, color: const Color(0xFFE5A227)),
                      const Spacer(),
                      Text(forecast.temperature, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const ReassuranceCard(
              icon: Icons.info_outline_rounded,
              text: 'This is sample weather for the demo, not a live forecast.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 1,
        onDestinationSelected: onTabSelected,
      ),
    );
  }
}
