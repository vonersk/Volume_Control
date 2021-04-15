import 'package:flutter/material.dart';
import 'dart:async';
import 'package:volume_control/volume_control.dart';
import 'dart:typed_data';
import 'dart:io';

void main() => runApp(MyApp());



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initVolumeState();
  }

  //init volume_control plugin
  Future<void> initVolumeState() async {

    final socket = await Socket.connect('192.168.1.20', 4567);
    print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');

    //listening to the server
    socket.listen(

    // handle data from the server
    (Uint8List data) {
      final serverResponse = String.fromCharCodes(data);
      print('Server: $serverResponse');
    },

    // handle errors
    onError: (error) {
      print(error);
      socket.destroy();
    },

    // handle server ending connection
    onDone: () {
      print('Server left.');
      socket.destroy();
    },
  );
    await sendMessage(socket, _val.toString());   


    if (!mounted) return;

    
    //read the current volume
    _val = await VolumeControl.volume;
    
    setState(() {});
  }

  double _val = 0.5;
  Timer timer;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              // title: const Text('Noob Volume Control'),
              ),
          body: Center(
              child: Slider(
                  value: _val,
                  min: 0,
                  max: 1,
                  divisions: 100,
                  onChanged: (val) {
                    _val = val;
                    setState(() {});
                    if (timer != null) {
                      timer.cancel();
                    }

                    //use timer for the smoother sliding
                    timer = Timer(Duration(milliseconds: 200), () {
                      VolumeControl.setVolume(val);
                      
                    });

                     print("val:$val");
                                 
                  }
                  
                  ))
                  
                 ),
    );
    
  }
    Future<void> sendMessage(Socket socket,String val) async {
    print("Client: $val");
    socket.write(val);
    await Future.delayed(Duration(seconds: 2));
}
