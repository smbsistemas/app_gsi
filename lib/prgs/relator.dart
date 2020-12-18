import 'package:flutter/material.dart';
import 'dart:convert';
//import 'package:flutter/src/rendering/box.dart';

//import 'package:intl/intl.dart';
import 'package:rgti_gsi/models/infra/data.dart';
import 'package:rgti_gsi/models/infra/appconfig.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:rgti_gsi/models/infra/usuarios.dart';
import 'package:rgti_gsi/prgs/AnexarEvidencias.dart';

import 'package:http/http.dart' as http;

class API {
  static Future getUsers(String phost, String pporta) async {
    var url = "http://$phost:$pporta/getUsuarios";
    var dataUsers = await http.get(url);
    return dataUsers;
  }
}

class Relator extends StatefulWidget {
  final Data data;
  final AppConfig dataConfig;

  Relator({this.data, this.dataConfig});

  @override
  _Relator createState() => new _Relator(data: data, dataConfig: dataConfig);
}

class _Relator extends State<Relator> {
  final Data data;
  final AppConfig dataConfig;

  _Relator({this.data, this.dataConfig});
  List<IRelator> _addRelator = [];

  Widget _appBarTitle;
  Color _appBarBackgroundColor;

  String _login = '';
  String _password = '';
  String _nome = '';
  String _idUser = '';
  String _host = '';
  String _porta = '';

  var _usuarios = new List<Usuarios>();
  DateTime _dataCorrente = new DateTime.now();

  String _idNaoConformidade;
  String _idCCU;
  String _idColigada;
  String _reCodigo;
  String _itemRelator = '';
  bool _unico = true;

  initState() {
    super.initState();
    _idNaoConformidade = this.data.idNaoConformidade;
    _idColigada = this.data.idColigada;
    _idCCU = this.data.idCCU;
    _appBarTitle = new Text('Relator');
    _appBarBackgroundColor = Colors.red;
    _porta = this.dataConfig.auPorta;
    _host = this.dataConfig.auHost;
    _idUser = this.dataConfig.auIdUser;

    _getUsers();
  }

  GlobalKey<FormState> _key = new GlobalKey();
  bool _validate = false;

  @override
  Widget build(BuildContext context) {
    print('idNC: $_idNaoConformidade');

    return Scaffold(
      appBar: new AppBar(
        title: _appBarTitle,
        backgroundColor: _appBarBackgroundColor,
        centerTitle: true,
      ),
      body: new Form(
        key: _key,
        autovalidate: _validate,
        child: _formUI(),
      ),
    );
  }

  Widget _formUI() {
    if (_usuarios.length > 0 && _unico) {
      _itemRelator = _usuarios[0].nome;
      _unico = false;
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverFixedExtentList(
            itemExtent: 50.0,
            delegate: SliverChildListDelegate([
              Container(
                child: Row(
                  children: <Widget>[
                    Text(
                      '  Relator:  ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButtonHideUnderline(
                      child: new DropdownButton<String>(
                        hint: new Text("Relator"),
                        isDense: true,
                        items: _usuarios.map((Usuarios map) {
                          return new DropdownMenuItem<String>(
                            value: map.nome,
                            child: new Text(map.nome,
                                style: new TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                        onChanged: (String newValue) {
                          setState(() {
                            //_dropDownItemSelected('USU', newValue);
                            this._itemRelator = newValue;
                            print('itemRelator: $_itemRelator');
                          });
                        },
                        value: _itemRelator,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                  child: new Column(children: <Widget>[
                RaisedButton(
                  onPressed: _sendForm,
                  child: new Text('Adcionar'),
                ),
              ])),
              Container(
                  child: new Column(children: <Widget>[
                RaisedButton(
                  onPressed: _proximaPagina,
                  child: new Text('Proximo'),
                ),
              ])),
            ])),
        SliverToBoxAdapter(
          child: Container(
            height: 300.0,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: _addRelator.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100.0,
                  child: Card(child: Text(_addRelator[index].reNome)),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _sendForm() {
    print('sendForm - cheguei');
    if (_key.currentState.validate()) {
      // Sem erros na validação
      _insertRelator();
      _key.currentState.save();
    } else {
      // erro de validação
//      setState(() {
      _validate = true;
//      });
    }
  }

  void _proximaPagina() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                AnexarEvidencias(data: data, dataConfig: dataConfig)),
      );

      _key.currentState.save();
    } else {
      // erro de validação
//      setState(() {
      _validate = true;
//      });
    }
  }

  void _insertRelator() async {
    //Navigator.pop(context);
    //Navigator.pushReplacementNamed(context, "/");
    print('_insertRelator: - post relator: $_itemRelator');
    var dataRelator = await http.get(
        'http://$_host:$_porta/PostRelator/$_idColigada/$_idCCU/$_idNaoConformidade/$_itemRelator/$_idUser');
    var jsonData = json.decode(dataRelator.body)['AdiconaRelator'];

    int x = 0;

    for (var u in jsonData) {
      IRelator documento =
          IRelator(x, u['CODIGO'], _itemRelator, u['MENSAGEM']);
      _addRelator.add(documento);
      x = x + 1;
    }
    setState(() {
      _reCodigo = _addRelator[0].reCodigo;
    });
    print('_reCodigo:$_reCodigo');
    if (_reCodigo != 'OK') {
      _showAlertDialog(context);
      print('Insert OK - Sucesso!');
    }
  }

  _getUsers() async {
    API.getUsers(_host, _porta).then((response) {
      setState(() {
        Iterable list = json.decode(response.body)['Usuarios'];
        _usuarios = list.map((model) => Usuarios.fromJson(model)).toList();
      });
    });
  }

  Future<List<LRelator>> _getRelator() async {
    var data = await http.get(
        'http://$_host:$_porta/GetRelator/$_idColigada/$_idNaoConformidade');
    var jsonData = json.decode(data.body)['Relator'];

    List<LRelator> _listRelator = [];
    int x = 0;
    for (var u in jsonData) {
      LRelator documento = LRelator(x, u['CODIGO'], u['NOME']);
      _listRelator.add(documento);
      x = x + 1;
    }
    return _listRelator;
  }

  Future _showAlertDialog(BuildContext context) async {
    Alert(
      context: context,
      // type: AlertType.warning,
      title: "ERROR",
      desc: "AO INSERIR O RELATOR",
      buttons: [
        DialogButton(
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }
}

class IRelator {
  final int index;
  final String reCodigo;
  final String reNome;
  final String reMensagem;
  IRelator(this.index, this.reCodigo, this.reNome, this.reMensagem);
}

class LRelator {
  final int index;
  final String reCodigo;
  final String reNome;

  LRelator(this.index, this.reCodigo, this.reNome);
}
