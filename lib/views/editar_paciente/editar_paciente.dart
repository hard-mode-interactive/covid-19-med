import 'package:coronavirusmed/services/pacientes.dart';
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
              SizedBox(height: 10.0,),
              Text("DATOS",style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: 10.0,),
              Form(
                autovalidate: _autoValidate,
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(

                      decoration: InputDecoration(
                        labelText: widget.datos['uid'],
                          icon: Text("ID:")
                      ),
                      enabled: false,
                    ),
                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: widget.datos['correo'],
                          icon: Text("Correo:")
                      ),
                    ),



                    TextFormField(
                      validator: (val){
                        if(val.isEmpty){
                          return "No puede estar vacio.";
                        }

                        if(val.length < 5){
                          return "Debe tener al menos 5 caracteres.";
                        }
                        return null;
                      },
                      onSaved: (val) => widget.datos['nombre'] = val,
                      initialValue: widget.datos['nombre'],
                      decoration: InputDecoration(
                          icon: Text("Nombre:")
                      ),
                    ),
                    TextFormField(
                      validator: (val){
                        if(val.isEmpty){
                          return "No puede estar vacio.";
                        }

                        if(val.length < 9){
                          return "Debe tener al menos 9 caracteres.";
                        }
                        return null;
                      },
                      onSaved: (val) => widget.datos['dui'] = val,
                      initialValue: widget.datos['dui'],
                      decoration: InputDecoration(
                          icon: Text("DUI:")
                      ),
                    ),
                    TextFormField(
                      validator: (val){
                        if(val.isEmpty){
                          return "No puede estar vacio.";
                        }

                        if(val.length < 9){
                          return "Debe tener al menos 10 caracteres.";
                        }
                        return null;
                      },
                      onSaved: (val) => widget.datos['direccion'] = val,
                      initialValue: widget.datos['direccion'],
                      decoration: InputDecoration(
                          icon: Text("Direccion:")
                      ),
                    ),
                    TextFormField(
                      maxLines: 5,
                      initialValue: widget.datos['notas'],
                      onChanged: (val) => widget.datos['notas'] = val,
                      decoration: InputDecoration(
                          helperText: "Notas"
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
}
