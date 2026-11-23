import 'package:finora/core/config/app_config.dart';
import 'package:finora/features/home/presentation/cubit/home_cubit.dart';
import 'package:finora/features/home/presentation/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initial state exposes the app name', () async {
    final cubit = HomeCubit(AppConfig());

    expect(cubit.state, const HomeState(appName: 'Finora'));

    await cubit.close();
  });
}
