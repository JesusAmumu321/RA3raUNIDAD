// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:async';
// import 'dart:convert';
//
// import 'gTemp.dart';
// import 'gPresion.dart';
// import 'gAltura.dart';
// import 'textos.dart';
//
// class Home extends StatefulWidget {
//   const Home({super.key});
//
//   @override
//   State<Home> createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//   BluetoothDevice? _device;
//   bool _btConnected = false;
//   List<ScanResult> _scanResults = [];
//   bool _isScanning = false;
//
//   double? temp = 0, pres = 0, alt = 0;
//   double? _tempReceived;
//   double? _presReceived;
//   double? _altReceived;
//
//   @override
//   void initState() {
//     super.initState();
//     requestPermissions().then((_) {
//       _checkBluetoothStatus();
//     });
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//   }
//
//   Future<void> requestPermissions() async {
//     Map<Permission, PermissionStatus> statuses =
//         await [
//           Permission.bluetooth,
//           Permission.bluetoothScan,
//           Permission.bluetoothConnect,
//           Permission.location,
//         ].request();
//
//     if (statuses[Permission.bluetooth]!.isDenied ||
//         statuses[Permission.bluetoothScan]!.isDenied ||
//         statuses[Permission.bluetoothConnect]!.isDenied ||
//         statuses[Permission.location]!.isDenied) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Por favor, acepta todos los permisos para usar Bluetooth.',
//           ),
//         ),
//       );
//     }
//   }
//
//   void _checkBluetoothStatus() async {
//     try {
//       var status = await FlutterBluePlus.adapterState.first;
//       setState(() {
//         _isBluetoothOn = status == BluetoothAdapterState.on;
//       });
//
//       if (!_isBluetoothOn) {
//         await FlutterBluePlus.turnOn();
//         await Future.delayed(const Duration(seconds: 2));
//         _checkBluetoothStatus();
//       }
//     } catch (e) {
//       print('Error al verificar estado de Bluetooth: $e');
//     }
//   }
//
//   bool _isBluetoothOn = false;
//
//   void _toggleBluetooth() async {
//     if (_isBluetoothOn) {
//       await FlutterBluePlus.turnOff();
//     } else {
//       await FlutterBluePlus.turnOn();
//     }
//     _checkBluetoothStatus();
//   }
//
//   void _startScan() async {
//     if (!_isBluetoothOn) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Por favor, enciende el Bluetooth primero'),
//         ),
//       );
//       return;
//     }
//
//     setState(() {
//       _isScanning = true;
//       _scanResults.clear();
//     });
//
//     try {
//       await FlutterBluePlus.stopScan();
//       await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
//
//       FlutterBluePlus.scanResults.listen((results) {
//         setState(() {
//           _scanResults =
//               results
//                   .where((result) => result.device.advName.isNotEmpty)
//                   .toList();
//         });
//       });
//
//       await FlutterBluePlus.isScanning.where((isScanning) => !isScanning).first;
//     } catch (e) {
//       print('Error durante el escaneo: $e');
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error durante el escaneo: $e')));
//     } finally {
//       setState(() {
//         _isScanning = false;
//       });
//     }
//   }
//
//   void _connectToDevice(BluetoothDevice device) async {
//     try {
//       await device.connect();
//       setState(() {
//         _device = device;
//         _btConnected = true;
//       });
//       _getData();
//
//       device.connectionState.listen((state) {
//         if (state == BluetoothConnectionState.disconnected) {
//           setState(() {
//             _btConnected = false;
//             _device = null;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Dispositivo desconectado')),
//           );
//         }
//       });
//
//       Navigator.pop(context);
//     } catch (e) {
//       print('Error conectando al dispositivo: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error conectando al dispositivo: $e')),
//       );
//     }
//   }
//
//   void connectToDevice() async {
//     try {
//       await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
//
//       FlutterBluePlus.scanResults.listen((results) {
//         for (ScanResult r in results) {
//           if (r.advertisementData.advName == 'Banana_ESP') {
//             _device = r.device;
//             FlutterBluePlus.stopScan();
//             _connectToDevice(_device!);
//             break;
//           }
//         }
//       });
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   void _connectToSpecificDevice() async {
//     try {
//       if (_device != null) {
//         await _device!.connect();
//         setState(() {
//           _btConnected = true;
//         });
//         _getData();
//       }
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   void sendData(String msg) async {
//     if (_device != null && _btConnected) {
//       var services = await _device!.discoverServices();
//       print('Servicios disponibles para escribir:');
//       bool serviceFound = false;
//       for (var service in services) {
//         print('Servicio UUID: ${service.uuid.toString()}');
//         for (var characteristic in service.characteristics) {
//           print('  Característica UUID: ${characteristic.uuid.toString()}');
//         }
//         if (service.uuid.toString() == '181a') {
//           serviceFound = true;
//           for (var characteristic in service.characteristics) {
//             if (characteristic.uuid.toString() == '2a6e') {
//               await characteristic.write(ascii.encode("$msg\n"));
//               print('Mensaje enviado: $msg');
//               break;
//             }
//           }
//         }
//       }
//       if (!serviceFound) {
//         print('Servicio no encontrado');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Servicio BLE no encontrado en el dispositivo.'),
//           ),
//         );
//       }
//     }
//   }
//
//   void _getData() {
//     if (_device != null) {
//       _device!
//           .discoverServices()
//           .then((services) {
//             print('Servicios encontrados:');
//             bool serviceFound = false;
//             for (var service in services) {
//               print('Servicio UUID: ${service.uuid.toString()}');
//               for (var characteristic in service.characteristics) {
//                 print('Característica UUID: ${characteristic.uuid.toString()}');
//               }
//               if (service.uuid.toString() == '181a') {
//                 serviceFound = true;
//                 bool characteristicFound = false;
//                 for (var characteristic in service.characteristics) {
//                   if (characteristic.uuid.toString() == '2a6e') {
//                     characteristicFound = true;
//                     try {
//                       characteristic.setNotifyValue(true);
//                       characteristic.onValueReceived.listen((value) {
//                         String receivedData = String.fromCharCodes(value);
//                         print('Datos recibidos: $receivedData');
//                         List<String> datos = receivedData.split('//');
//
//                         if (datos.length == 3) {
//                           setState(() {
//                             _tempReceived = double.tryParse(datos[0]);
//                             _presReceived = double.tryParse(datos[1]);
//                             _altReceived = double.tryParse(datos[2]);
//                             if (_tempReceived != null) temp = _tempReceived;
//                             if (_presReceived != null) pres = _presReceived;
//                             if (_altReceived != null) alt = _altReceived;
//                           });
//                         } else {
//                           print('Formato de datos incorrecto: $receivedData');
//                         }
//                       });
//                     } catch (e) {
//                       print('Error al habilitar notificaciones: $e');
//                     }
//                   }
//                 }
//                 if (!characteristicFound) {
//                   print('Característica no encontrada');
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text(
//                         'Característica BLE no encontrada en el isp.',
//                       ),
//                     ),
//                   );
//                 }
//               }
//             }
//             if (!serviceFound) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("El BLE no se encontro")),
//               );
//             }
//           })
//           .catchError((e) {
//             print('Error de servicios: $e');
//           });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               decoration: BoxDecoration(color: Colors.blue),
//               child: Text(
//                 'Bluetooth Conf',
//                 style: TextStyle(color: Colors.white, fontSize: 24),
//               ),
//             ),
//             SwitchListTile(
//               title: const Text('Bluetooth'),
//               value: _isBluetoothOn,
//               onChanged: (_) => _toggleBluetooth(),
//             ),
//             ListTile(
//               title: const Text('Buscar Dispositivos'),
//               onTap: _isBluetoothOn ? _startScan : null,
//             ),
//             if (_isScanning) const LinearProgressIndicator(),
//             ..._scanResults.map(
//               (result) => ListTile(
//                 title: Text(
//                   result.device.advName.isNotEmpty
//                       ? result.device.advName
//                       : '(Sin nombre)',
//                 ),
//                 subtitle: Text(result.device.remoteId.toString()),
//                 trailing: ElevatedButton(
//                   onPressed: () => _connectToDevice(result.device),
//                   child: const Text('Conectar'),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       backgroundColor: Colors.black12,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: Row(
//           children: [
//             Icon(
//               _btConnected
//                   ? Icons.bluetooth_connected
//                   : Icons.bluetooth_disabled,
//               color: _btConnected ? Colors.green : Colors.red,
//             ),
//             const SizedBox(width: 8),
//             Text(
//               _btConnected ? 'Conectado' : 'Desconectado',
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//             ),
//           ],
//         ),
//         actions: [
//           IconButton(
//             onPressed: () async {
//               Map<Permission, PermissionStatus> statuses =
//                   await [
//                     Permission.bluetooth,
//                     Permission.bluetoothScan,
//                     Permission.bluetoothConnect,
//                   ].request();
//
//               if (statuses[Permission.bluetooth]!.isDenied ||
//                   statuses[Permission.bluetoothScan]!.isDenied ||
//                   statuses[Permission.bluetoothConnect]!.isDenied) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text(
//                       "Se necesitan permisos pa actualizar los datos",
//                     ),
//                   ),
//                 );
//                 return;
//               }
//
//               if (!_btConnected || _device == null) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('Conecta el Bluetooth primero.'),
//                   ),
//                 );
//                 return;
//               }
//
//               sendData("obtener");
//             },
//             icon: const Icon(Icons.restore, color: Colors.white),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Gtemp(temp: temp),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [GPresion(pres: pres), GAltura(alt: alt)],
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Textos(temp: temp),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:convert';

import 'gTemp.dart';
import 'gPresion.dart';
import 'gAltura.dart';
import 'textos.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BluetoothDevice? _device;
  bool _btConnected = false;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  double? temp = 0, pres = 0, alt = 0;
  double? _tempReceived;
  double? _presReceived;
  double? _altReceived;

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) {
      _checkBluetoothStatus();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.location,
        ].request();

    if (statuses[Permission.bluetooth]!.isDenied ||
        statuses[Permission.bluetoothScan]!.isDenied ||
        statuses[Permission.bluetoothConnect]!.isDenied ||
        statuses[Permission.location]!.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, acepta todos los permisos para usar Bluetooth.',
          ),
        ),
      );
    }
  }

  void _checkBluetoothStatus() async {
    try {
      var status = await FlutterBluePlus.adapterState.first;
      setState(() {
        _isBluetoothOn = status == BluetoothAdapterState.on;
      });

      if (!_isBluetoothOn) {
        await FlutterBluePlus.turnOn();
        await Future.delayed(const Duration(seconds: 2));
        _checkBluetoothStatus();
      }
    } catch (e) {
      print('Error al verificar estado de Bluetooth: $e');
    }
  }

  bool _isBluetoothOn = false;

  void _toggleBluetooth() async {
    if (_isBluetoothOn) {
      await FlutterBluePlus.turnOff();
    } else {
      await FlutterBluePlus.turnOn();
    }
    _checkBluetoothStatus();
  }

  void _startScan() async {
    if (!_isBluetoothOn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, enciende el Bluetooth primero'),
        ),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResults.clear();
    });

    try {
      await FlutterBluePlus.stopScan();
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _scanResults =
              results
                  .where((result) => result.device.advName.isNotEmpty)
                  .toList();
        });
      });

      await FlutterBluePlus.isScanning.where((isScanning) => !isScanning).first;
    } catch (e) {
      print('Error durante el escaneo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error durante el escaneo: $e')));
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        _device = device;
        _btConnected = true;
      });
      _getData();

      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          setState(() {
            _btConnected = false;
            _device = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dispositivo desconectado')),
          );
        }
      });

      Navigator.pop(context);
    } catch (e) {
      print('Error conectando al dispositivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error conectando al dispositivo: $e')),
      );
    }
  }

  void connectToDevice() async {
    try {
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));

      FlutterBluePlus.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.advertisementData.advName == 'Banana_ESP') {
            _device = r.device;
            FlutterBluePlus.stopScan();
            _connectToDevice(_device!);
            break;
          }
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _connectToSpecificDevice() async {
    try {
      if (_device != null) {
        await _device!.connect();
        setState(() {
          _btConnected = true;
        });
        _getData();
      }
    } catch (e) {
      print(e);
    }
  }

  void sendData(String msg) async {
    if (_device != null && _btConnected) {
      var services = await _device!.discoverServices();
      print('Servicios disponibles para escribir:');
      bool serviceFound = false;
      for (var service in services) {
        print('Servicio UUID: ${service.uuid.toString()}');
        for (var characteristic in service.characteristics) {
          print('  Caracteristica UUID: ${characteristic.uuid.toString()}');
        }
        if (service.uuid.toString() == '181a') {
          serviceFound = true;
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == '2a6e') {
              await characteristic.write(ascii.encode("$msg\n"));
              print('Mensaje enviado: $msg');
              break;
            }
          }
        }
      }
      if (!serviceFound) {
        print('Servicio no encontrado');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('BLE no encontrado en el dispositivo.'),
          ),
        );
      }
    }
  }

  void _getData() {
    if (_device != null) {
      _device!
          .discoverServices()
          .then((services) {
            print('Servicios encontrados:');
            bool serviceFound = false;
            for (var service in services) {
              print('Servicio UUID: ${service.uuid.toString()}');
              for (var characteristic in service.characteristics) {
                print('Característica UUID: ${characteristic.uuid.toString()}');
              }
              if (service.uuid.toString() == '181a') {
                serviceFound = true;
                bool characteristicFound = false;
                for (var characteristic in service.characteristics) {
                  if (characteristic.uuid.toString() == '2a6e') {
                    characteristicFound = true;
                    try {
                      characteristic.setNotifyValue(true);
                      characteristic.onValueReceived.listen((value) {
                        String receivedData = String.fromCharCodes(value);
                        List<String> datos = receivedData.split('//');

                        if (datos.length == 3) {
                          setState(() {
                            _tempReceived = double.tryParse(datos[0]);
                            _presReceived = double.tryParse(datos[1]);
                            _altReceived = double.tryParse(datos[2]);
                            if (_tempReceived != null) temp = _tempReceived;
                            if (_presReceived != null) pres = _presReceived;
                            if (_altReceived != null) alt = _altReceived;
                          });
                        } else {
                          print('Formato de datos incorrecto: $receivedData');
                        }
                      });
                    } catch (e) {
                      print('Error al habilitar notificaciones: $e');
                    }
                  }
                }
                if (!characteristicFound) {
                  print('Caracteristica no encontrada');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'BLE no encontrado en el isp.',
                      ),
                    ),
                  );
                }
              }
            }
            if (!serviceFound) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("El BLE no se encontro")),
              );
            }
          })
          .catchError((e) {
            print('Error de servicios: $e');
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.grey[900],
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey[800]!, Colors.blueGrey[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Text(
                'Bluetooth Config',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SwitchListTile(
              title: const Text(
                'Bluetooth',
                style: TextStyle(color: Colors.white),
              ),
              value: _isBluetoothOn,
              activeColor: Colors.blueAccent,
              onChanged: (_) => _toggleBluetooth(),
            ),
            ListTile(
              title: const Text(
                'Buscar Dispositivos',
                style: TextStyle(color: Colors.white),
              ),
              onTap: _isBluetoothOn ? _startScan : null,
            ),
            if (_isScanning)
              const LinearProgressIndicator(
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ..._scanResults.map(
              (result) => ListTile(
                title: Text(
                  result.device.advName.isNotEmpty
                      ? result.device.advName
                      : '(Sin nombre)',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  result.device.remoteId.toString(),
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _connectToDevice(result.device),
                  child: const Text('Conectar'),
                ),
              ),
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        title: Row(
          children: [
            Icon(
              _btConnected
                  ? Icons.bluetooth_connected
                  : Icons.bluetooth_disabled,
              color: _btConnected ? Colors.greenAccent : Colors.redAccent,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              _btConnected ? 'Conectado' : 'Desconectado',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              Map<Permission, PermissionStatus> statuses =
                  await [
                    Permission.bluetooth,
                    Permission.bluetoothScan,
                    Permission.bluetoothConnect,
                  ].request();

              if (statuses[Permission.bluetooth]!.isDenied ||
                  statuses[Permission.bluetoothScan]!.isDenied ||
                  statuses[Permission.bluetoothConnect]!.isDenied) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Se necesitan permisos pa actualizar los datos",
                    ),
                  ),
                );
                return;
              }

              if (!_btConnected || _device == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conecta el Bluetooth primero.'),
                  ),
                );
                return;
              }

              sendData("obtener");
            },
            icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[900]!, Colors.blueGrey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.black.withOpacity(0.6),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Gtemp(temp: temp),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.black.withOpacity(0.6),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GPresion(pres: pres),
                      ),
                    ),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.black.withOpacity(0.6),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: GAltura(alt: alt),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        child: Textos(temp: temp),
      ),
    );
  }
}
