import 'dart:io';

import 'package:coronavirus_rest_api_flutter_course/app/repositories/data_repositories.dart';
import 'package:coronavirus_rest_api_flutter_course/app/repositories/endpointdata.dart';
import 'package:coronavirus_rest_api_flutter_course/app/services/api.dart';
import 'package:coronavirus_rest_api_flutter_course/app/ui/alert_dialog.dart';
import 'package:coronavirus_rest_api_flutter_course/app/ui/endpoint_card.dart';
import 'package:coronavirus_rest_api_flutter_course/app/ui/last_update.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget{
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  EndpointsData _endpointsData;

  @override
  void initState(){
    super.initState();
    final dataRepository = Provider.of<DataRepository>(context, listen: false);
    _endpointsData = dataRepository.getAllEndpointsCachedData();
    _updateData();
  }
  Future<void> _updateData() async{
    try{
    final dataRepository = Provider.of<DataRepository>(context, listen: false);
    final endpointsData = await dataRepository.getAllEndpointData();
    setState(() => _endpointsData = endpointsData);
  } on SocketException catch (_){
    showAlertDialog(
      context: context, 
      title: 'Connection Error', 
      content: 'Could not retrieve data. Please try again later.', 
      defaultContextText: 'OK');
  } catch (_) {
    showAlertDialog(
      context: context, 
      title: 'Unknown Error', 
      content: 'Please contact admin.', 
      defaultContextText: 'OK');
  }
  }
  @override
  Widget build(BuildContext context){
    final formatter = LastUpdateDateFormatter(
      lastUpdated: _endpointsData != null ? _endpointsData.values[Endpoint.cases]?.date : null);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Coronavirus Tracker'),
      ),
      body: RefreshIndicator(
        onRefresh: _updateData,
        child: ListView(
          children: [
            LastUpdateStatusText(text: formatter.lastUpdateStatusText()),
            for (var endpoint in Endpoint.values)
            EndpointCard(
              endpoint: endpoint,
              value: _endpointsData != null ? _endpointsData.values[endpoint]?.value : null
            )
          ],
        ),
      ),
    );
  }
}