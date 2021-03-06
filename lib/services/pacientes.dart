

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

abstract class BasePacientes {
  Future<DataSnapshot> crearPaciente(FirebaseUser currentUser, var data);
  Future<DataSnapshot> actualizarPaciente(FirebaseUser currentUser,String key, var data);
  Future<DataSnapshot> eliminarPaciente(FirebaseUser currentUser, String key);
  Future<List<dynamic>> pacientePositivo(String medico, String paciente, String fcm_token, String nombre_paciente);
  Future<DataSnapshot> pacienteNegativo(FirebaseUser currentUser,String key);
  Future<bool> pacienteExiste(FirebaseUser currentUser, String uid);
 }

class Pacientes implements BasePacientes  {

  final databaseReference = FirebaseDatabase.instance.reference();
  var uuid = Uuid();



  Future<bool> pacienteExiste(FirebaseUser currentUser, String uid) async {
    bool exists = false;
     await databaseReference.child('medicos').child(currentUser.uid).child('pacientes').child(uid).once().then((snap){
       print(snap.value);
      if(snap.value == null){
        exists = false;
      }
      else
        {
          exists = true;
        }
    });
     return exists;
  }

  Future<DataSnapshot> crearPaciente(FirebaseUser currentUser, var data) async {
    
    databaseReference.child('medicos').child(currentUser.uid).child('pacientes').child(data['uid']).set(data).then((val){

      return val;

    });


  }

  Future<DataSnapshot> actualizarPaciente(FirebaseUser currentUser,String key, var data) async {

   
    databaseReference.child('medicos').child(currentUser.uid).child('pacientes').child(key).update(data).then((val){
      return val;
    });


  }

  Future<DataSnapshot> pacienteNegativo(FirebaseUser currentUser,String key,) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String backEndUrl = prefs.getString('backEndUrl');
    String token = prefs.getString("token");



    var response = await  http.post(backEndUrl + "/api/medicos/${currentUser.uid}/pacientes/$key/negativo",headers: {"Authorization": token, "Content-Type": 'application/json'});
    print(response.body);
    return null;

  }


  Future<List<dynamic>> pacientePositivo(String medico, String paciente, String fcm_token, String nombre_paciente) async {


    SharedPreferences prefs = await SharedPreferences.getInstance();
    String backEndUrl = prefs.getString('backEndUrl');
    String token = prefs.getString("token");
    String refreshToken = prefs.getString("refreshtoken");

    Map<String,dynamic> body = {
      "fcm_token": fcm_token,
      "nombre_paciente": nombre_paciente
    };

    Map<String,dynamic> datos = {
      "estado": "POSITIVO",
      "obteniendo_nexos": true
    };

    databaseReference.child('medicos').child(medico).child('pacientes').child(paciente).update(datos);

    var response = await  http.post(backEndUrl + "/api/medicos/$medico/pacientes/$paciente/positivo",headers: {"Authorization": token, "Content-Type": 'application/json'}, body: jsonEncode(body));
    var nexos = jsonDecode(response.body)['nexos'];
    return nexos;


  }



  Future<DataSnapshot> eliminarPaciente(FirebaseUser currentUser, String key) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String backEndUrl = prefs.getString('backEndUrl');
    String token = prefs.getString("token");



    var response = await  http.delete(backEndUrl + "/api/medicos/${currentUser.uid}/pacientes/$key",headers: {"Authorization": token, "Content-Type": 'application/json'});
    return null;
  }



}