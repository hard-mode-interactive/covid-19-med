import 'package:coronavirusmed/utilities/screenSize.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TemperaturaPage extends StatefulWidget {
  TemperaturaPage({this.currentUser,this.pacienteUid,this.datos});
  final currentUser;
  final pacienteUid;
  var datos;
  @override
  _TemperaturaPageState createState() => _TemperaturaPageState();
}

class _TemperaturaPageState extends State<TemperaturaPage> {

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  String _fecha;
  DateFormat _dateFormat = DateFormat("dd-MM-yyyy hh:mm a");
  String _temperatura;
  String _notas;
  final databaseReference = FirebaseDatabase.instance.reference();
  var uuid = Uuid();
  bool _loading = false;

   _crear() async {
    if(_formKey.currentState.validate()){
      _formKey.currentState.save();
      setState(() {
        _loading = true;
      });
      var datos = {
        "temperatura": _temperatura,
        "timeStamp": DateTime.now().millisecondsSinceEpoch * 1000,
        "notas": _notas
      };

      await databaseReference.child("medicos").child(widget.currentUser.uid).child("pacientes").child(widget.pacienteUid).child("temperaturas").child(uuid.v4()).set(datos);

      setState(() {
        _loading = false;
      });

      return showDialog(
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),
            title: Text('Listo!'),
            content:Text('El registro ha sido agregado al historial de temperaturas del paciente'),
            actions: <Widget>[
              FlatButton(
                child: Text('Aceptar'),
                onPressed: (){
                  Navigator.pop(context);
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
          _autoValidate = true;
        });
      }
  }

  _actualizar() async {
    if(_formKey.currentState.validate()){
      setState(() {
        _loading = true;
      });

      _formKey.currentState.save();
      var datos = {
        "temperatura": _temperatura,
        "timeStamp": widget.datos['timeStamp'],
        "notas": _notas
      };
      setState(() {
        widget.datos['notas'] = _notas;
        widget.datos['temperatura'] = _temperatura;
      });
      await databaseReference.child("medicos").child(widget.currentUser.uid).child("pacientes").child(widget.pacienteUid).child("temperaturas").child(widget.datos['key']).set(datos);
      setState(() {
        _loading = false;
      });
      return showDialog(
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),
            title: Text('Listo!'),
            content:Text('El registro ha sido actualizado correctamentee'),
            actions: <Widget>[
              FlatButton(
                child: Text('Aceptar'),
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
        _autoValidate = true;
      });
    }
  }

   _borrar(){
    return showDialog(
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: Text('Esta seguro?'),
          content:Text('El registro sera borrado permanentemente'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancelar'),
              onPressed: (){
                Navigator.pop(context);

              },
            ),
            FlatButton(
              child: Text('Aceptar'),
              onPressed: () async {
                Navigator.pop(context);
                _cerrar();
              },
            ),

          ],
        );
      },
      context: context,
    );
  }

  void _cerrar() async {
     setState(() {
       _loading = true;
     });
    await databaseReference.child("medicos").child(widget.currentUser.uid).child("pacientes").child(widget.pacienteUid).child("temperaturas").child(widget.datos['key']).remove().then((value) => Navigator.pop(context));


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fecha =  _dateFormat.format(DateTime.now()).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xff3380d6),
        title: Text( widget.datos == null ? 'NUEVO REGISTRO': 'ACTUALIZAR REGISTRO',style: TextStyle(color: Colors.white, fontSize: 2 * SizeConfig.safeBlockVertical),),
        actions: <Widget>[
          widget.datos != null && !_loading ? IconButton(
            icon: Icon(Icons.delete),
            onPressed: _borrar,
          ) :
              Container()
        ],
      ),
      floatingActionButton: !_loading ? FloatingActionButton(
        onPressed: widget.datos == null ? _crear : _actualizar,
        child: Icon(Icons.save),
      ): Container(),
      body: !_loading ? SingleChildScrollView(
        child: Container (
          padding: EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 10.0,),
              Text("DATOS",style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: 10.0,),
               widget.datos == null ? crear() : actualizar()
            ],
          ),
        ),
      ): Center(child: CircularProgressIndicator()),
    );
  }

  Widget crear (){
     return Form(
       autovalidate: _autoValidate,
       key: _formKey,
       child: Column(
         children: <Widget>[

           TextFormField(
             keyboardType: TextInputType.number,
             validator: (val)  {
               if(val.length <= 0){
                 return "Este campo no puede estar vacio";
               }
               else
               {
                 return null;
               }
             },
             onSaved: (val) => _temperatura = val,
             decoration: InputDecoration(
                 labelText: "Tempertura °"
             ),
           ),
           TextFormField(

             keyboardType: TextInputType.datetime,
             initialValue: _fecha,
             enabled: false,

             decoration: InputDecoration(
               labelText: "Fecha",

             ),
           ),
           TextFormField(
             maxLines: 5,
             onSaved: (val) => _notas = val,
             decoration: InputDecoration(
                 labelText: "Notas"
             ),
           ),
         ],
       ),
     );
  }

  Widget actualizar (){
    return Form(
      autovalidate: _autoValidate,
      key: _formKey,
      child: Column(
        children: <Widget>[

          TextFormField(
            keyboardType: TextInputType.number,
            validator: (val)  {
              if(val.length <= 0){
                return "Este campo no puede estar vacio";
              }
              else
              {
                return null;
              }
            },
            onSaved: (val) => _temperatura = val,
            initialValue: widget.datos['temperatura'],
            decoration: InputDecoration(
                labelText: "Tempertura °"
            ),
          ),
          TextFormField(

            keyboardType: TextInputType.datetime,
            initialValue: _dateFormat.format(DateTime.fromMicrosecondsSinceEpoch(widget.datos['timeStamp'])).toString(),
            enabled: false,

            decoration: InputDecoration(
              labelText: "Fecha",

            ),
          ),
          TextFormField(
            maxLines: 5,
            onSaved: (val) => _notas = val,
            initialValue: widget.datos['notas'],
            decoration: InputDecoration(
                labelText: "Notas"
            ),
          ),
        ],
      ),
    );
  }
}
