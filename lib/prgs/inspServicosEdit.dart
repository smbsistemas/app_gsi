import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:rgti_gsi/models/infra/data.dart';
import 'package:rgti_gsi/models/infra/appconfig.dart';
import 'package:http/http.dart' as http;

class InspServicosEdit extends StatefulWidget {
  final Data data;
  final AppConfig dataConfig;

  InspServicosEdit({this.data, this.dataConfig});

  @override
  _InspServicosEdit createState() =>
      new _InspServicosEdit(data: data, dataConfig: dataConfig);
}

enum SingingCharacter { conforme, naoConforme }

class _InspServicosEdit extends State<InspServicosEdit> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Data data;
  final AppConfig dataConfig;

  _InspServicosEdit({this.data, this.dataConfig});

  Widget _appBarTitle;
  Color _appBarBackgroundColor;
  GlobalKey<FormState> _key = new GlobalKey();

  List<ModeloServicos> _listModeloServicosI = [];

  String _login = '';
  String _password = '';
  String _nome = '';
  String _codigo = '';
  String _userId = '';
  String _host = '';
  String _porta = '';
  String _idColigada = '';
  String _tipoInspecao = '';

  String _codFVS = '';
  int _index = 0;

  bool wvar = true;
  List checked1 = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  List checked2 = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ];

  initState() {
    super.initState();
    _idColigada = this.data.idColigada;
    _appBarTitle = new Text('INSPEÇÃO DE SERVIÇOS');
    _appBarBackgroundColor = Colors.red;
    _porta = this.dataConfig.auPorta;
    _host = this.dataConfig.auHost;
    _userId = this.dataConfig.auIdUser;
    _codFVS = this.data.codFVS;

    _getModeloFVSCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: _appBarTitle,
        backgroundColor: _appBarBackgroundColor,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 10.0, 17.0, 3.0),
          ),
          Row(children: <Widget>[
            Container(
                width: 80.0,
                child: Text(
                  'Conforme',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
            Container(
                width: 200.0,
                child: Text(
                  'Serviços',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
            Container(
                width: 80.0,
                child: Text(
                  'Não Conforme',
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
          ]),
          Container(
            child: Divider(),
            padding: EdgeInsets.fromLTRB(17.0, 10.0, 17.0, 3.0),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getModeloFVS(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Container(child: Center(child: Text("Loading...")));
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: 80.0,
                                child: Column(children: <Widget>[
                                  new Radio(
                                    value:
                                        checked1[index] == true ? true : false,
                                    groupValue: true,
                                    onChanged: (value) {
                                      setState(() {
                                        checked1[index] = true;
                                        checked2[index] = false;
                                      });
                                    },
                                  ),
                                ]),
                              ),
                              Container(
                                width: 200.0,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        snapshot.data[index].descricao,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Text(
                                        snapshot.data[index].tolerancia,
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal),
                                      )
                                    ]),
                              ),
                              Container(
                                width: 80.0,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      new Radio(
                                        value: checked2[index] == true
                                            ? true
                                            : false,
                                        groupValue: true,
                                        onChanged: (value) {
                                          setState(() {
                                            checked2[index] = true;
                                            checked1[index] = false;
                                          });
                                        },
                                      )
                                    ]),
                              ),
                            ],
                          ),
                          Container(
                            child: Divider(),
                          ),
                        ]);
                      });
                }
              },
            ),
          ),
          new RaisedButton(
            onPressed: _sendForm,
            child: new Text('Salvar'),
          )
        ],
      ),
    );
  }

  void _sendForm() async {
    print('update - ficha de inspeção de serviços');
    String _codModelo = '';
    String _item = '';
    String _pInspecao = '';
    String _pAcao = '';
    String _pReinspecao = '';
    String _temNaoConformidade = 'N';

    int x = 0;
    int t = _listModeloServicosI.length;
    while (x < t) {
      _codModelo = _listModeloServicosI[x].codModelo;
      _item = _listModeloServicosI[x].item;
      _pInspecao = '';
      _pAcao = '';
      _pReinspecao = '';
      if (checked1[x] != false) {
        _pInspecao = 'X'; // Item Conforme
      } else {
        if (checked2[x] != false) {
          _pAcao = 'O'; // Item não conforme
          _temNaoConformidade = 'S';
        }
      }
      var data = await http.get(
          'http://$_host:$_porta/PostUpdateInspecao/$_codFVS/$_idColigada/$_codModelo/$_item/$_pInspecao/$_pAcao/$_pReinspecao');
      var jsonData = json.decode(data.body)['UpDateInspecao'];
      x = x + 1;
    }

    if (_temNaoConformidade == 'S') {
      Navigator.pushReplacementNamed(context, "/");
    } else {
      Navigator.pushReplacementNamed(context, "/");
    }
  }

  Future<List<ModeloServicos>> _getModeloFVS() async {
    print('_codFVS:$_codFVS');

    String _inspecao;
    String _acao;
    var data = await http
        .get('http://$_host:$_porta/GetItemMFVSEdit/$_idColigada/$_codFVS');
    var jsonData = json.decode(data.body)['ItensServicosEdit'];

    List<ModeloServicos> _listModeloServicos = [];
    int x = 0;
    for (var u in jsonData) {
      ModeloServicos documento = ModeloServicos(x, u['CODMODELO'], u['ITEM'],
          u['DESCRICAO'], u['TOLERANCIA'], u['INSPECAO'], u['ACAO'], '');
      _listModeloServicos.add(documento);
      /*    _inspecao = u['INSPECAO'];
      print('_inspecao: $_inspecao');
      _acao = u['ACAO'];
      if (_inspecao == 'X') {
        print('inspecao = checked1: true');
        checked1[x] = true;
        checked2[x] = false;
      } else {
        print('inspecao = checked1: false');
        checked1[x] = false;
      }
      if (_acao == 'O') {
        print('ACAO - checked2: true');
        checked2[x] = true;
        checked1[x] = false;
      } else {
        print('ACAO - checked2: false');
        checked2[x] = false;
      } */
      x = x + 1;
    }

    _listModeloServicosI = _listModeloServicos;

    return _listModeloServicos;
  }

  Future<List<ModeloServicos>> _getModeloFVSCheck() async {
    String _inspecao;
    String _acao;
    print('cheguei 1');
    var data = await http
        .get('http://$_host:$_porta/GetItemMFVSEdit/$_idColigada/$_codFVS');
    var jsonData = json.decode(data.body)['ItensServicosEdit'];
    print('cheguei 1');
    int x = 0;
    for (var u in jsonData) {
      ModeloServicos documento = ModeloServicos(x, u['CODMODELO'], u['ITEM'],
          u['DESCRICAO'], u['TOLERANCIA'], u['INSPECAO'], u['ACAO'], '');
      _inspecao = u['INSPECAO'];
      _acao = u['ACAO'];
      if (_inspecao == 'X') {
        checked1[x] = true;
        checked2[x] = false;
      } else {
        checked1[x] = false;
      }
      if (_acao == 'O') {
        checked2[x] = true;
        checked1[x] = false;
      } else {
        checked2[x] = false;
      }
      x = x + 1;
      print('x: $x');
    }
  }
}

class ModeloServicos {
  final int index;
  final String codModelo;
  final String item;
  final String descricao;
  final String tolerancia;
  final String inspecao;
  final String acao;
  final String reinspecao;

  ModeloServicos(this.index, this.codModelo, this.item, this.descricao,
      this.tolerancia, this.inspecao, this.acao, this.reinspecao);
}
