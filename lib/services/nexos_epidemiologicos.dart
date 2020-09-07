

import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

abstract class BaseNexos {
  Future<List<Map<String,dynamic>>> obtenerNexos(String infectedUser);
  Future<http.Response> notificarUnPaciente(Map<String,dynamic> nexo);
  Future<http.Response> notificarTodosLosPacientes(List<Map<String,dynamic>> nexos);


}

class Nexos implements BaseNexos  {

  final databaseReference = FirebaseDatabase.instance.reference();
  var uuid = Uuid();






  Future<List<Map<String,dynamic>>> obtenerNexos(String infectedUser) async {

    Map<dynamic,dynamic> usuarios;
    Map<dynamic,dynamic>  infectedBitacora;
    List<Map<String,dynamic>> nexos = [];

    await databaseReference.child("usuarios").once().then((snap){
      usuarios = snap.value;
    });

    await databaseReference.child('usuarios').child(infectedUser).child('bitacora_lugares').once().then((snap){
      infectedBitacora = snap.value;
    });


    usuarios.remove(infectedUser);
    usuarios.forEach((key,datos){

      if(datos['bitacora_lugares'] != null ){
        Map<dynamic,dynamic> bitacora = datos['bitacora_lugares'];

        if(bitacora == null) {
          return null;
        }
        bitacora.forEach((bitacoraID,bitacoraDatos){

          if(infectedBitacora == null) {
            return null;
          }
          infectedBitacora.forEach((infectedBitacoraKey,infectedBitacoraDatos){
            if(infectedBitacoraDatos['direccion'] == bitacoraDatos['direccion']){
//
//              if(infectedBitacoraDatos['timeStamp'] == null || bitacoraDatos['timeStamp'] == null){
//                print(key);
//              }

              var infectedDate = new DateTime.fromMillisecondsSinceEpoch(infectedBitacoraDatos['timeStamp']);
              var newNexoDate = new DateTime.fromMillisecondsSinceEpoch(bitacoraDatos['timeStamp']);
              var difference = infectedDate.difference(newNexoDate).inDays;

              if(newNexoDate.isAfter(infectedDate) && difference <= 10){

                Map<String,dynamic> _newNexo = {
                  'infectado': {
                    'message': 'Esta es la informacion de la ubicacion y fecha del paciente infectado',
                    'location': {
                      'lat': infectedBitacoraDatos['location']['lat'],
                      'long': infectedBitacoraDatos['location']['long'],
                      'direction': infectedBitacoraDatos['direccion']
                    },
                    'date': DateFormat('dd-MM-yyyy – hh:mm').format(infectedDate),
                  },

                  'posible_infectado': {
                    'uid':key,
                    'message': 'Esta es la informacion del la ubicacion y fecha del posible nexo de contagio',
                    'email': datos['informacion']['correo'],
                    'fcm_token': datos['informacion']['fcm_token'],
                    'date': DateFormat('dd-MM-yyyy – hh:mm').format(newNexoDate),
                    'location': {
                      'lat': bitacoraDatos['location']['lat'],
                      'long': bitacoraDatos['location']['long'],
                      'direction': bitacoraDatos['direccion']
                    },
                  }
                };

                bool exists = false;
                nexos.forEach((nexo){
                  if(nexo['posible_infectado']['email'] == _newNexo['posible_infectado']['email'] && nexo['posible_infectado']['location']['direction'] == _newNexo['posible_infectado']['location']['direction']){
                    exists = true;
                  }
                });
                if(!exists){
                  nexos.add(_newNexo);
                }

              }

            }
          });
        });
      }


    });

    return nexos;
  }


  Future<http.Response> notificarUnPaciente(Map<String,dynamic> informacion) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String backEndUrl = prefs.getString('backEndUrl');
    String token = prefs.getString('token');
    Map<String,dynamic> nexo = {
      "nexo": informacion
    };

    print(nexo);

    return http.post(backEndUrl + '/api/notificar/uno',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token
      },
      body: jsonEncode(nexo),
    );
  }


  Future<http.Response> notificarTodosLosPacientes(List<Map<String,dynamic>> informacion) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String backEndUrl = prefs.getString('backEndUrl');
    String token = prefs.getString('token');


    Map<String,dynamic> nexos = {
      "nexos": informacion
    };

    return http.post(
      backEndUrl + '/api/notificar/todos',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': token
      },
      body: jsonEncode(nexos),
    );
  }


}