import 'package:coronavirusmed/utilities/screenSize.dart';
import 'package:coronavirusmed/views/paciente/temperatura.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TemperaturasPage extends StatefulWidget {
  TemperaturasPage({this.currentUser,this.pacienteUid});
  final FirebaseUser currentUser;
  final pacienteUid;
  @override
  _TemperaturasPageState createState() => _TemperaturasPageState();
}

class _TemperaturasPageState extends State<TemperaturasPage> {
  final databaseReference = FirebaseDatabase.instance.reference();
  var _firebaseRef;
  bool _loading = true;

  DateFormat _dateFormat = DateFormat("dd-MM-yyyy hh:mm a");


  void getData(){
    setState(() {
      _loading = true;
    });
    _firebaseRef = FirebaseDatabase().reference().child('medicos').child(widget.currentUser.uid).child("pacientes").child(widget.pacienteUid).child("temperaturas").orderByChild("timeStamp");

    setState(() {
      _loading = false;
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
    return  Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xff3380d6),
          title: Text('REGISTRO DE TEMPERATURAS',style: TextStyle(color: Colors.white, fontSize: 2 * SizeConfig.safeBlockVertical),),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => TemperaturaPage(currentUser: widget.currentUser,pacienteUid: widget.pacienteUid,)
                ));
              },
            )
          ],
        ),
        body: !_loading ?  StreamBuilder(
          stream: _firebaseRef.onValue,
          builder: (context, snap) {

            if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {

              Map data = snap.data.snapshot.value;
              List item = [];

              data.forEach((index, data) => item.add({"key": index, ...data}));
              item.sort((a, b) {
                return b["timeStamp"].compareTo(a["timeStamp"]);
              });
              return ListView.builder(
                itemCount: item.length,

                itemBuilder: (context, index) {

                  return Card(
                    margin: EdgeInsets.all(10.0),
                    elevation: 10.0,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(20.0),
                      dense: true,
                      leading: FaIcon(FontAwesomeIcons.thermometerHalf),
                      title: Text('${item[index]['temperatura']}'),
                      subtitle: Text('${_dateFormat.format(DateTime.fromMicrosecondsSinceEpoch(item[index]['timeStamp']))}'),

                      onTap: (){
                       Navigator.push(context, MaterialPageRoute(
                         builder: (context) => TemperaturaPage(pacienteUid: widget.pacienteUid,currentUser: widget.currentUser,datos:item[index] ,)
                       ));
                      },
                    ),
                  );
                },
              );
            }
            else
              return Center(
                child: Text('No hay registros.',style: TextStyle(color: Colors.black26),),
              );
          },
        ) : Center(
          child: CircularProgressIndicator(),
        )
    );
  }
}
