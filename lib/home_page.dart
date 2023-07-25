import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hasPermission = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchPermissionStatus();
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() {
          _hasPermission = (status == PermissionStatus.granted);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        if (_hasPermission) {
          return _buildCompass();
        } else {
         return _buildPermission();
        }
      }),
    );
  }

  //compass widget

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: ((context, snapshot) {
      if(snapshot.hasError){
        return Text("error");
      }

      if(snapshot.connectionState==ConnectionState.waiting){
        return const Center(
          child: CircularProgressIndicator(),
        );
      }


      double? direction =snapshot.data!.heading;

      ///if direction is Nll,then device doesn't support this sensor
      if(direction==null)
      {
        return const Center(
          child: Text("Device does't support"),
        );
      }


      //return compass

      return  Center(
        child: Container(padding: EdgeInsets.all(20),
        child: Transform.rotate(
          angle: direction*(math.pi/180)*-1,child: Image.asset("images/com.png",color: Colors.black,)),),
      );
    }));
  }
  //permission select widget

  Widget _buildPermission() {
    return Center(
      child: ElevatedButton(
          onPressed: () {
            Permission.locationWhenInUse.request().then((value) {
              _fetchPermissionStatus();
            });
          },
          child: Text("Request permission")),
    );
  }
}
