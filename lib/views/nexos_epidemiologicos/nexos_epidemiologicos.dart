import 'package:coronavirusmed/services/nexos_epidemiologicos.dart';
import 'package:coronavirusmed/views/ver_nexo/nexo.dart';
import 'package:flutter/material.dart';

class NexosPage extends StatefulWidget {
  NexosPage({this.datos});
  final datos;
  @override
  _NexosPageState createState() => _NexosPageState();
}

class _NexosPageState extends State<NexosPage> {

  bool _loading = true;

  BaseNexos _nexos = new Nexos();
  List<dynamic> nexos = [];

  void _getNexos() async{

    setState(() {
      _loading = true;
    });

    /*widget.datos.forEach((nexo){

      Map<String,dynamic> _newNexo = {
        'infectado': {
          'message': 'Esta es la informacion de la ubicacion y fecha del paciente infectado',
          'location': {
            'lat': nexo['infectado']['location']['lat'],
            'long': nexo['infectado']['location']['long'],
            'direction': nexo['infectado']['location']['direction']
          },
          'date': nexo['infectado']['date'],
        },

        'posible_infectado': {
          'message': 'Esta es la informacion del la ubicacion y fecha del posible nexo de contagio',
          'email': nexo['posible_infectado']['email'],
          'fcm_token': nexo['posible_infectado']['fcm_token'],
          'date':nexo['posible_infectado']['date'],
          'uid':nexo['posible_infectado']['uid'],
          'location': {
            'lat': nexo['posible_infectado']['location']['lat'],
            'long': nexo['posible_infectado']['location']['long'],
            'direction': nexo['posible_infectado']['location']['direction']
          },
        }
      };
      nexos.add(_newNexo);
    });*/

    nexos = widget.datos;

    setState(() {
      _loading = false;
    });

  }


  void notificarTodosLosUsuario() async {

    setState(() {
      _loading = true;
    });

    await _nexos.notificarTodosLosPacientes(nexos).then((value){

      setState(() {
        _loading = false;
      });

      return showDialog(
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))
            ),
            title: Text('Listo!'),
            content:Text('Los usuarios han sido notificados'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cerrar'),
                onPressed: (){
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
        context: context,
      );
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getNexos();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("NEXOS EPIDEMIOLOGICOS"),
        actions: <Widget>[
          IconButton(
            onPressed: (){
              return showDialog(
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))
                    ),
                    title: Text('Esta seguro ? '),
                    content:Text('Si continua mandara una alerta de contagio a todos los usuarios que estan en la lista de posibles nexos epidemiologicos'),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('Cerrar'),
                        onPressed: (){
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text('Aceptar'),
                        onPressed: () {
                          Navigator.pop(context);
                          notificarTodosLosUsuario();
                        },
                      )

                    ],
                  );
                },
                context: context,
              );
            },
            icon: Icon(Icons.notifications_active),
          )
        ],
      ),
      body: _loading ? Center(
        child: CircularProgressIndicator(),
      ) : nexos.isNotEmpty ? ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 15.0),
        itemCount: nexos.length,
        itemBuilder: (context, i){
          return _nexoWidget(nexos[i]);

        }
      ) : Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("No se encontraron nexos epidemiologicos relacionados a este usuario.",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black38),textAlign: TextAlign.center,),
        ),
      )
    );
  }


  Widget _nexoWidget(Map<dynamic,dynamic> datos) {
    return ListTile(
      contentPadding: EdgeInsets.all(10.0),
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => VerNexoPage(datos: datos,)
        ));
      },
      leading: Icon(Icons.person,color: Colors.red,),
      title: Text(datos['posible_infectado']['email']),
     subtitle: Text(datos['posible_infectado']['location']['direction']),
    );
  }
}
