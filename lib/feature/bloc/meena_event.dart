part of 'meena_bloc.dart';

abstract class MeenaEvent extends Equatable {
  const MeenaEvent();

  @override
  List<Object> get props => [];
}

class LoadDataDashboardEvent extends MeenaEvent {}

class LoadDashboardForTabEvent extends MeenaEvent {}

class LoadDashboardForTab extends MeenaEvent {
  const LoadDashboardForTab({required this.dashboardId});
  final int dashboardId;
}
