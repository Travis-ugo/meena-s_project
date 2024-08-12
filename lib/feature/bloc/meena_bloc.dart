import 'dart:developer';

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
  Map<String, List<SensorData>> sensorDataMapList = {};

  ///
  Future<void> onLoadDataDashboardEvent(
    LoadDataDashboardEvent event,
    Emitter<MeenaState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      // log("API CALLED:: FETCH DASHBOARD FUNCTION");
      dashboards = await apiService.fetchDashboards();
      emit(state.copyWith(
        dashboards: dashboards,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  ///
  Future<void> onLoadDashboardForTab(
      LoadDashboardForTab event, Emitter<MeenaState> emit) async {
    // log("API CALLED::::   LoadDashboardForTab ");
    Dashboard dashboard = await apiService.postDashBoardId(event.dashboardId!);
    dashboardData[event.dashboardId!] = dashboard;
    // log("FROM BLOCK::::  $dashboardData");
    emit(state.copyWith(
      dashboardData: dashboardData,
    ));

    List<Future<WidgetModel>> widgetFutures = dashboard.widgets!.map(
      (widget) {
        return apiService.fetchWidget(widgetId: "${widget.widgetId}");
      },
    ).toList();

    final widgets = await Future.wait(widgetFutures);
    emit(state.copyWith(
      widgets: widgets,
    ));
    Map<String, List<SensorData>> vegat = {};
    Map<String, Map<String, List<SensorData>>> newMapOfMaps = {};
    for (int i = 0; i < state.widgets.length; i++) {
      var chartChart = state.widgets[i];
      // log("WIDGET LIST LENGTH: ${state.widgets[i].name}");

      log("A NEW WIDGET CHART :::: ${state.widgets[i].name}");

      for (int chart = 0; chart < chartChart.modalities!.length; chart++) {
        // var modality in chartChart){
        log("WIDGET LIST LENGTH: ${chartChart.modalities![chart].modalityId}");
        log("WIDGET LIST LENGTH: ${chartChart.modalities![chart].tenantId}");
        log("WIDGET LIST LENGTH: ${chartChart.modalities![chart].name}");
        log("WIDGET LIST LENGTH: ${chartChart.modalities![chart].type}");
        log("WIDGET LIST LENGTH: ${chartChart.modalities![chart].sensorId}");
        log("WIDGET LIST LENGTH: ${chartChart.modalities![chart].widgets}");
        log("----------------------------------------");

        var addSensorDataList = await apiService.fetchSensorData(
            modalitiesId: chartChart.modalities![chart].modalityId!);

        // log("${addSensorDataList.map((e) => e).toList()}");
        log("${addSensorDataList.length}");

        vegat = {"${chartChart.modalities![chart].name}": addSensorDataList};
        log("VEGATE::::: $vegat");
      }

      var mapOfMaps = {"${chartChart.name}": vegat};

      newMapOfMaps.addAll(mapOfMaps);

      log("END OF FIRST MAP WIDGET CHART :::::::::: ${state.widgets[i].name}");
      // WidgetModel widget = state.widgets[0];
      // if (widget.modalities != null) {
      //   for (var modality in widget.modalities!) {
      //     // log("MODALITY NAME: ${modality.name}");

      // var addSensorDataList = await apiService.fetchSensorData(
      //     modalitiesId: modality.modalityId!);
      // log("MODALITY NAMES ${modality.name}");

      // String key = "${modality.name}";

      // if (sensorDataMapList.containsKey(key)) {
      //   // If the key exists, append the new sensor data to the existing list
      //   sensorDataMapList[key]!.addAll(sensorDataList);
      // } else {
      //   // If the key does not exist, create a new entry
      //   sensorDataMapList[key] = sensorDataList;
      // }
      // log("MODALITY NAME: ${modality.name}");
      // log("LIST OF SENSOR DATA: ${addSensorDataList.length}");

      // sensorDataMap[event.dashboardId!] = WidgetWithName(
      //     sensorDataList: sensorDataList,
      //     widgetName: widget.name ?? "EMPTY");

      // if (sensorDataMap[event.dashboardId] != null) {
      // log("SENSOR DATA LIST ${sensorDataMap[event.dashboardId!]!.sensorDataList.length}");
      // }

      // emit(state.copyWith(
      //   sensorDataMap: sensorDataMap,
      //   sensorDataList: sensorDataMap[event.dashboardId!]!.sensorDataList,
      // ));
      // }
      // log("LIST OF SENSORDATA ${sensorDataList.length}");
      // }
    }
    log("MAP OF MAPS :::::::::: ${newMapOfMaps}");
  }
}




    // for (int i = 0; i < 1; i++) {
    //   WidgetModel widget = state.widgets[0];
    //   if (widget.modalities != null) {
    //     for (var modality in widget.modalities!) {
    //       var addSensorDataList = await apiService.fetchSensorData(
    //           modalitiesId: modality.modalityId!);
    //       log("MODALITY NAMES ${modality.name}");
    //       sensorDataList.addAll(addSensorDataList);

    //       // sensorDataMap[event.dashboardId!] = WidgetWithName(
    //       //     sensorDataList: sensorDataList,
    //       //     widgetName: widget.name ?? "EMPTY");

    //       // if (sensorDataMap[event.dashboardId] != null) {
    //       // log("SENSOR DATA LIST ${sensorDataMap[event.dashboardId!]!.sensorDataList.length}");
    //       // }

    //       // emit(state.copyWith(
    //       //   sensorDataMap: sensorDataMap,
    //       //   sensorDataList: sensorDataMap[event.dashboardId!]!.sensorDataList,
    //       // ));
    //     }
    //     log("LIST OF SENSORDATA ${sensorDataList.length}");
    //   }
    // }