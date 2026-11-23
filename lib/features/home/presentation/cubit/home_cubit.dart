import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/config/app_config.dart';
import 'home_state.dart';

/// ViewModel of the home screen.
@injectable
class HomeCubit extends Cubit<HomeState> {
  /// Creates the home ViewModel with its dependencies.
  HomeCubit(AppConfig config) : super(HomeState(appName: config.appName));
}
