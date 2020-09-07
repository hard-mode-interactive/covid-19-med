import 'package:coronavirusmed/services/pacientes.dart';
import 'package:coronavirusmed/utilities/screenSize.dart';
import 'package:flutter/material.dart';

class EditarPacientePage extends StatefulWidget {
  EditarPacientePage({this.datos,this.currentUser});
  final currentUser;
  Map<dynamic,dynamic> datos;
  @override
  _EditarPacientePageState createState() => _EditarPacientePageState();
}

class _EditarPacientePageState extends State<EditarPacientePage> {
  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _loading = false;

  BasePacientes _pacientes = new Pacientes();



  void _validateInputs() async {

    setState(() {
      _loading = true;
    });
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      var data = {
        "uid":widget.datos['uid'],
        "fcmToken":widget.datos['fcmToken'],
        "correo":widget.datos['correo'],
        "nombre":widget.datos['nombre'],
        "dui":widget.datos['dui'],
        "direccion":widget.datos['direccion'],
        "estado":widget.datos['estado'],
        "fechaIngreso": widget.datos['fechaIngreso'],
        "notas":widget.datos['notas']
      };

      await _pacientes.actualizarPaciente(widget.currentUser,widget.datos['key'], data).then((val){
        setState(() {
          _loading = false;
        });
        Navigator.pop(context);
        return showDialog(
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))
              ),
              title: Text('Covid-19 MED'),
              content:Text('El paciente ha sido actualizado exitosamente.'),
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
        _loading = false;
      });
    }


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("EDITAR PACIENTE"),
      ),
        floatingActionButton: !_loading  ? FloatingActionButton(
          onPressed:_validateInputs,
          child: Icon(Icons.save),

        ) : null,
      body: SingleChildScrollView(
        child: Container (
          padding: EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Form(
                autovalidate: _autoValidate,
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _dataField("Nombre:", widget.datos['nombre'],TextInputType.text,(val){
                      if(val.length < 5){
                        return "Al menos 5 caracteres";
                      }
                      else
                        {
                          return null;
                        }
                    },(val){
                      setState(() {
                        widget.datos['nombre'] = val;
                      });
                    }),
                    SizedBox(
                      height: 2 * SizeConfig.blockSizeVertical,
                    ),

                    _dataField("Dui:", widget.datos['dui'],TextInputType.number,(val){
                      if(val.length < 9){
                        return "Al menos 9 digitos";
                      }
                      else
                      {
                        return null;
                      }
                    },(val){
                      setState(() {
                        widget.datos['dui'] = val;
                      });
                    }),
                    SizedBox(
                      height: 2 * SizeConfig.blockSizeVertical,
                    ),
                    _dataField("Direccion:", widget.datos['direccion'],TextInputType.text,(val){
                      if(val.length < 10){
                        return "Al menos 10 caracteres";
                      }
                      else
                      {
                        return null;
                      }
                    },(val){
                      setState(() {
                        widget.datos['direccion'] = val;
                      });
                    }),
                    SizedBox(
                      height: 2 * SizeConfig.blockSizeVertical,
                    ),
                    TextFormField(
                      maxLines: 5,
                      initialValue: widget.datos['notas'],
                      onChanged: (val) => widget.datos['notas'] = val,
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
      )
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
