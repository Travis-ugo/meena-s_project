//  //import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meena/feature/models/dash_board_model.dart';
import 'package:meena/feature/models/sensor.dart';
import 'package:meena/feature/models/widget_model.dart';
import 'package:meena/feature/models/widget_with_name.dart';
import 'package:meena/feature/services/api_service.dart';

part 'meena_event.dart';
part 'meena_state.dart';

class MeenaBloc extends Bloc<MeenaEvent, MeenaState> {
  final ApiService apiService;

  MeenaBloc(this.apiService) : super(const MeenaState()) {
    on<LoadDataDashboardEvent>(onLoadDataDashboardEvent);
    on<LoadDashboardForTab>(onLoadDashboardForTab);
  }
  Map<int, Dashboard> dashboardData = {};
  List<Dashboard> dashboards = [];
  List<SensorData> sensorDataList = [];
  Map<int, WidgetWithName> sensorDataMap = {};

  ///
  Future<void> onLoadDataDashboardEvent(
    LoadDataDashboardEvent event,
    Emitter<MeenaState> emit,
  ) async {
    emit(state.copyWith(isLoading: false));
    try {
      // log("API CALLED:: FETCH DASHBOARD FUNCTION");
      dashboards = await apiService.fetchDashboards();
      emit(
        state.copyWith(
          dashboards: dashboards,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  ///
  Future<void> onLoadDashboardForTab(
      LoadDashboardForTab event, Emitter<MeenaState> emit) async {
    // log("API CALLED");
    Dashboard dashboard = await apiService.postDashBoardId(event.dashboardId);
    dashboardData[event.dashboardId] = dashboard;
    emit(state.copyWith(
      dashboardData: dashboardData,
    ));

    List<Future<WidgetModel>> widgetFutures = dashboard.widgets!.map(
      (widget) {
        return apiService.fetchWidget(widgetId: "${widget.widgetId}");
      },
    ).toList();

    emit(state.copyWith(
      widgets: await Future.wait(widgetFutures),
    ));

    for (int i = 0; i < state.widgets.length; i++) {
      WidgetModel widget = state.widgets[i];
      if (widget.modalities != null) {
        for (var modality in widget.modalities!) {
          var addSensorDataList = await apiService.fetchSensorData(
              modalitiesId: modality.modalityId!);
          sensorDataList.addAll(addSensorDataList);

          sensorDataMap[event.dashboardId] = WidgetWithName(
              sensorDataList: sensorDataList,
              widgetName: widget.name ?? "EMPTY");

          emit(state.copyWith(
            sensorDataMap: sensorDataMap,
          ));
        }
      }
    }
  }
}
