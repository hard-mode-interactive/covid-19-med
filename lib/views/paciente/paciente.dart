import 'package:coronavirusmed/services/pacientes.dart';
import 'package:coronavirusmed/views/nexos_epidemiologicos/nexos_epidemiologicos.dart';
import 'package:coronavirusmed/views/paciente/temperaturas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class VerPacientePage extends StatefulWidget {
  VerPacientePage({this.currentUser, this.datos});
  final currentUser;
  Map<dynamic,dynamic> datos;

  @override
  _VerPacientePageState createState() => _VerPacientePageState();
}

class _VerPacientePageState extends State<VerPacientePage> {
  BasePacientes _pacientes = new Pacientes();

  final _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _loading = false;
  SharedPreferences prefs;
  bool esperando_nexos = false;


  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if(widget.datos['obteniendo_nexos'] == 'true'){
      setState(() {
        esperando_nexos = true;
      });
    }

  }

  void _positivo() async {

    setState(() {
      _loading = true;
      widget.datos['estado'] = "POSITIVO";
      esperando_nexos = true;
    });


    _pacientes.pacientePositivo(widget.currentUser.uid, widget.datos['key'], prefs.getString('fcm_token'),widget.datos['nombre']);


    return showDialog(
      barrierDismissible: false,
      builder: (context) {

        return AlertDialog(

          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: Text('Covid-19 MED'),
          content:Text('Se estan obteniendo los nexos epidemiologicos del paciente.\nEl proceso esta siendo ejecutado en el servidor, no es necesario que la aplicacion pemanezca abierta.\nSera notificado cuando este proceso termine'),
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

  void _negativo() async {
    setState(() {
      _loading = true;
      widget.datos['estado'] = "NEGATIVO";
      widget.datos['nexos'] = null;
    });

    await _pacientes.pacienteNegativo(widget.currentUser, widget.datos['key']).then((val){
      setState(() {
        _loading = false;
      });
    });

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPrefs();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PACIENTE"),
        actions: <Widget>[
          IconButton(
            icon: FaIcon(FontAwesomeIcons.thermometerHalf),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder:  (context) => TemperaturasPage(currentUser: widget.currentUser,pacienteUid: widget.datos['key'],)
              ));
            },
          )
        ],
      ),
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
                      enabled: false,
                      decoration: InputDecoration(
                          labelText: widget.datos['uid'],
                          icon: Text("ID:")
                      ),
                    ),
                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                          labelText: widget.datos['correo'],
                          icon: Text("Correo:")
                      ),
                    ),

                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                          labelText: widget.datos['estado'],
                          icon: Text("Covid-19:")
                      ),
                    ),

                    TextFormField(
                      enabled: false,
                      decoration: InputDecoration(
                          labelText: widget.datos['nombre'],
                          icon: Text("Nombre:")
                      ),
                    ),
                    TextFormField(
                      enabled: false,

                      decoration: InputDecoration(
                          labelText: widget.datos['dui'],
                          icon: Text("DUI:")
                      ),
                    ),
                    TextFormField(
                      enabled: false,

                      decoration: InputDecoration(
                          labelText: widget.datos['direccion'],
                          icon: Text("Direccion:")
                      ),
                    ),
                    TextFormField(
                      enabled: false,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: widget.datos['notas'],
                          icon: Text("Notas")
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 25.0,
              ),
              widget.datos['estado'] == "NEGATIVO" ? RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                    side: BorderSide(color: !esperando_nexos ?   Colors.red : Colors.grey)
                ),
                color: !esperando_nexos ?   Colors.red : Colors.grey,
                onPressed: esperando_nexos ? null : (){
                  return showDialog(
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20.0))
                        ),
                        title: Text('Esta seguro ?'),
                        content:Text('El paciente sera declarado Covid-19 Positivo'),
                        actions: <Widget>[
                          FlatButton(

                            child: Text('Cancelar'),
                            onPressed: (){
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(

                            child: Text('Aceptar'),
                            onPressed: (){
                              Navigator.pop(context);
                              _positivo();
                            },
                          )

                        ],
                      );
                    },
                    context: context,
                  );
                },
                child: Text( !esperando_nexos ? "Covid-19 POSITIVO" : "Esperando Nexos",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ):RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.green)
                ),
                color: Colors.green,
                onPressed: _negativo,
                child: Text("Covid-19 NEGATIVO",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ),


              widget.datos['nexos'] != null ? RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                ),
                color: Colors.orange,
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => NexosPage(datos: widget.datos['nexos'],)
                  ));
                },
                child: Text("Ver Nexos Epidemiologicos",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ): Container(),
              esperando_nexos  ? RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(18.0),
                ),
                child: Text("Esperando nexos",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              ): Container(),
            ],
          ),
        ),
      ),
    );
  }
}
