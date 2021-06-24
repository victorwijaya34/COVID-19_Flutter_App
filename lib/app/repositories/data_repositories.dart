import 'package:coronavirus_rest_api_flutter_course/app/repositories/endpointdata.dart';
import 'package:coronavirus_rest_api_flutter_course/app/services/api.dart';
import 'package:coronavirus_rest_api_flutter_course/app/services/api_service.dart';
import 'package:coronavirus_rest_api_flutter_course/app/services/data_cache.dart';
import 'package:coronavirus_rest_api_flutter_course/app/services/endpoint_data.dart';
import 'package:coronavirus_rest_api_flutter_course/app/ui/endpoint_card.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class DataRepository {
  DataRepository({@required this.apiservice, @required this.dataCacheService});
  final APIService apiservice;
  final DataCacheService dataCacheService;

  String _accessToken;

  Future<EndpointData> getEndpointData (Endpoint endpoint) async => 
  await _getDataRefreshingToken<EndpointData>(
    onGetData: () => apiservice.getEndpointData(accessToken: _accessToken, endpoint: endpoint)
  );

  EndpointsData getAllEndpointsCachedData() => dataCacheService.getData();

  Future<EndpointsData> getAllEndpointData () async { 
  final endpointData = await _getDataRefreshingToken<EndpointsData>(
    onGetData:  _getAllEndpointsData,
  );
  await dataCacheService.setData(endpointData);
  return endpointData;
  }

  Future<T> _getDataRefreshingToken<T> ({Future<T> Function() onGetData}) async{
    try{
      if (_accessToken == null){
     _accessToken = await apiservice.getAccessToken();
  }
    return await onGetData();
    } on Response catch (response){
      if (response.statusCode == 401){
        _accessToken = await apiservice.getAccessToken();
        return await onGetData();
      }
      rethrow;
    }
  }

  Future<EndpointsData> _getAllEndpointsData() async{
    final values = await Future.wait([
      apiservice.getEndpointData(accessToken: _accessToken, endpoint:Endpoint.cases),
      apiservice.getEndpointData(accessToken: _accessToken, endpoint:Endpoint.casesSuspected),
      apiservice.getEndpointData(accessToken: _accessToken, endpoint:Endpoint.casesConfirmed),
      apiservice.getEndpointData(accessToken: _accessToken, endpoint:Endpoint.deaths),
      apiservice.getEndpointData(accessToken: _accessToken, endpoint:Endpoint.recovered),
    ]);
  return EndpointsData(
    values: {
      Endpoint.cases: values[0],
      Endpoint.casesSuspected: values[1],
      Endpoint.casesConfirmed: values[2],
      Endpoint.deaths: values[3],
      Endpoint.recovered: values[4],
    },
  );
  }
}