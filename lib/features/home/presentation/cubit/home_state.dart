import 'package:equatable/equatable.dart';

/// State of the home screen.
class HomeState extends Equatable {
  /// Creates a home state.
  const HomeState({required this.appName});

  /// Name displayed in the home app bar.
  final String appName;

  @override
  List<Object?> get props => [appName];
}
