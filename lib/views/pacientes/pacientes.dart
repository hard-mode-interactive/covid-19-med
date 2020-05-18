import 'package:coronavirusmed/services/pacientes.dart';
import 'package:coronavirusmed/views/editar_paciente/editar_paciente.dart';
import 'package:coronavirusmed/views/paciente/paciente.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../utilities/screenSize.dart';


class PacientesPage extends StatefulWidget {
  PacientesPage({this.currentUser});
  final FirebaseUser currentUser;
  @override
  _PacientesPageState createState() => _PacientesPageState();
}

class _PacientesPageState extends State<PacientesPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  var _firebaseRef;
  BasePacientes _pacientes = new Pacientes();
  bool _loading = true;



  void getData(){
    setState(() {
      _loading = true;
    });
    _firebaseRef = FirebaseDatabase().reference().child('medicos').child(widget.currentUser.uid).child("pacientes");

    setState(() {
      _loading = false;
    });
  }



  void _borrarPaciente(var item, int index) async{

    showDialog(
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Confirmar'),
              Divider(color: Colors.black26,)
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Esta seguro que desea borrar la notificacion?'),
              SizedBox(height: 10.0,),
              Divider(color: Colors.black26,)
            ],
          ),
          actions: <Widget>[


            FlatButton(
              onPressed:  (){
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            FlatButton(
              child: Text('Continuar'),
              onPressed: ()async {
                Navigator.pop(context);
                setState(() {
                  _loading = true;
                });
                await _pacientes.eliminarPaciente(widget.currentUser, item[index]['key']);
                setState(() {
                  _loading = false;
                });
              },
            ),
          ],
        );
      },
      context: context,
    );


  }


  void _opciones(context, var item, int index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                new ListTile(
                    leading: new Icon(Icons.remove_red_eye),
                    title: new Text('Ver'),
                    onTap: (){
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => VerPacientePage(currentUser: widget.currentUser,datos:item[index] ,)
                      ));
                    }),
                new ListTile(
                    leading: new Icon(Icons.edit),
                    title: new Text('Editar'),
                    onTap: (){
                      Navigator.pop(context);
                      print(item[index]);
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => EditarPacientePage(currentUser: widget.currentUser,datos: item[index],)
                      ));

                    }),
                new ListTile(
                  leading: new Icon(Icons.delete),
                  title: new Text('Eliminar'),
                  onTap: () async {

                    Navigator.pop(context);
                    _borrarPaciente(item,index);

                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xff3380d6),
          title: Text('MIS PACIENTES',style: TextStyle(color: Colors.white, fontSize: 2.5 * SizeConfig.safeBlockVertical),),
        ),
        body: !_loading ?  StreamBuilder(
          stream: _firebaseRef.onValue,
          builder: (context, snap) {

            if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {

              Map data = snap.data.snapshot.value;
              List item = [];

              data.forEach((index, data) => item.add({"key": index, ...data}));

              return ListView.builder(
                itemCount: item.length,

                itemBuilder: (context, index) {

                  return Card(
                    margin: EdgeInsets.all(10.0),
                    elevation: 10.0,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(20.0),
                      dense: true,
                      leading: Icon(Icons.person,color: item[index]['estado'] == "NEGATIVO" ?  Colors.green : Colors.red,),
                      title: Text('${item[index]['nombre']}'),
                      subtitle: Text('Covid-19 ${item[index]['estado']}'),
                      trailing: item[index]['estado'] == "positivo" ?  Column(
                        children: <Widget>[
                          Text('Nexos',style: TextStyle(fontWeight: FontWeight.bold),),
                          SizedBox(height: 5.0,),
                          Text('${ item[index]['nexos'] != null ? item[index]['nexos'].length : "0"}',style: TextStyle(color: item[index]['nexos'] != null ? Colors.red: Colors.green),)
                        ],
                      ) : null,
                      onTap: (){
                        _opciones(context,item, index );
                      },
                    ),
                  );
                },
              );
            }
            else
              return Center(
                child: Text('No hay pacientes.',style: TextStyle(color: Colors.black26),),
              );
          },
        ) : Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}
