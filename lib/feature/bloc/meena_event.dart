part of 'meena_bloc.dart';

abstract class MeenaEvent extends Equatable {
  const MeenaEvent();

  @override
  List<Object> get props => [];
}

class LoadDataDashboardEvent extends MeenaEvent {
  const LoadDataDashboardEvent({this.index = 0});
  final int index;
}

class LoadDashboardForTabEvent extends MeenaEvent {}

class LoadDashboardForTab extends MeenaEvent {
  const LoadDashboardForTab({this.dashboardId, this.index});
  final int? dashboardId;
  final int? index;
}
