import 'package:coronavirusmed/services/pacientes.dart';
import 'package:coronavirusmed/utilities/screenSize.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';

import 'package:flutter/services.dart';

class AgregarPacientePage extends StatefulWidget {
  AgregarPacientePage({this.currentUser});
  final FirebaseUser currentUser;
  @override
  _AgregarPacientePageState createState() => _AgregarPacientePageState();
}

class _AgregarPacientePageState extends State<AgregarPacientePage> {
  BasePacientes _pacientes = new Pacientes();

  final _formKey = GlobalKey<FormState>();
  String barcode = "";
  String _email;
  String _token;
  String _uid;
  String _estado = "NEGATIVO";
  String _dui;
  String _nombre;
  String _direccion;
  String _notas;
  String _fechaIngreso;
  bool _loading = false;

  bool _autoValidate = false;

  var info;
  bool _scanned = false;

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        this.barcode = barcode;
        info = barcode.split(',');
        _uid = info[0];
        _email = info[1];
        _token = info[2];

        _scanned = true;
        _validarPaciente();
      });
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }


  void _validarPaciente() async {
    setState(() {
      _loading = true;
    });
     bool exists = await _pacientes.pacienteExiste(widget.currentUser, _uid);
    if(exists){
      Navigator.pop(context);
      return showDialog(
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),
            title: Text('Covid-19 MED'),
            content:Text('El paciente que esta intentando agregar ya existe en su lista de pacientes'),
            actions: <Widget>[
              FlatButton(

                child: Text('cerrar'),
                onPressed: (){
                  Navigator.pop(context);
                },
              )

            ],
          );
        },
        context: context,
      );
    }
    else
    {
      setState(() {
        _loading = false;
      });
    }

  }


  void _validateInputs() async {

    setState(() {
      _loading = true;
    });
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      var data = {
        "uid":_uid,
        "fcmToken":_token,
        "correo":_email,
        "nombre":_nombre,
        "dui":_dui,
        "direccion":_direccion,
        "estado":_estado,
        "fechaIngreso": DateTime.now().millisecondsSinceEpoch,
        "notas":_notas
      };

      await _pacientes.crearPaciente(widget.currentUser, data).then((val){
        Navigator.pop(context);
        return showDialog(
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))
              ),
              title: Text('Covid-19 MED'),
              content:Text('El paciente ha sido creado exitosamente.'),
              actions: <Widget>[
                FlatButton(

                  child: Text('cerrar'),
                  onPressed: (){
                    Navigator.pop(context);
                  },
                )

              ],
            );
          },
          context: context,
        );
      });

    } else {

      setState(() {
        _autoValidate = true;
      });
    }

    setState(() {
      _loading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NUEVO PACIENTE"),
        backgroundColor: Color(0xff3380d6),
      ),
      body: !_scanned ? Center(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(10.0),
              color: Color(0xff3380d6)
            ),
            child: FlatButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: scan,
              child: Text("Escanear codigo QR",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
          ),
        ),
      ): !_loading ?  SingleChildScrollView(
        child: Container (
          padding: EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10.0,),
              Text("DATOS",style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: 10.0,),
              Form(
                autovalidate: _autoValidate,
                key: _formKey,
                child: Column(
                  children: <Widget>[

                    SizedBox(
                      height: 2 * SizeConfig.blockSizeVertical,
                    ),
                    _dataField("Nombre:", "",TextInputType.text,(val){
                      if(val.length < 5){
                        return "Al menos 5 caracteres";
                      }
                      else
                      {
                        return null;
                      }
                    },(val){
                      setState(() {
                        _nombre = val;
                      });
                    }),
                    SizedBox(
                      height: 2 * SizeConfig.blockSizeVertical,
                    ),

                    _dataField("Dui:", "",TextInputType.number,(val){
                      if(val.length < 9){
                        return "Al menos 9 digitos";
                      }
                      else
                      {
                        return null;
                      }
                    },(val){
                      setState(() {
                        _dui = val;
                      });
                    }),
                    SizedBox(
                      height: 2 * SizeConfig.blockSizeVertical,
                    ),
                    _dataField("Direccion:", "",TextInputType.text,(val){
                      if(val.length < 10){
                        return "Al menos 10 caracteres";
                      }
                      else
                      {
                        return null;
                      }
                    },(val){
                      setState(() {
                        _direccion = val;
                      });
                    }),
                    SizedBox(
                      height: 2 * SizeConfig.blockSizeVertical,
                    ),
                    TextFormField(
                      maxLines: 5,
                      onChanged: (val) => _notas = val,
                      decoration: InputDecoration(
                          helperText: "Notas",
                          filled: true
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ): Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: !_loading && _scanned ? FloatingActionButton(
        onPressed:_validateInputs,
        child: Icon(Icons.save),

      ) : null,
    );
  }

  Widget _dataField(String name, String value,TextInputType textType, var validation, var save){
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(name,style: TextStyle(fontWeight: FontWeight.bold),),
          TextFormField(
            initialValue: value,
            validator: validation,
            keyboardType: textType,
            onSaved: save,
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
            ),
          )
        ],
      ),
    );
  }
}
