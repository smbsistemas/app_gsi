import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:rgti_gsi/models/infra/data.dart';
import 'package:rgti_gsi/models/infra/appconfig.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'package:http/http.dart' as http;

class PlanoAcao extends StatefulWidget {
  final Data data;
  final AppConfig dataConfig;

  PlanoAcao({this.data, this.dataConfig});

  @override
  _PlanoAcao createState() =>
      new _PlanoAcao(data: data, dataConfig: dataConfig);
}

class _PlanoAcao extends State<PlanoAcao> {
  final Data data;
  final AppConfig dataConfig;

  _PlanoAcao({this.data, this.dataConfig});

  //print('idnaoconformidade: $data.idNaoConformidade');

  Widget _appBarTitle;
  Color _appBarBackgroundColor;
  GlobalKey<FormState> _key = new GlobalKey();

  String _login = '';
  String _password = '';
  String _nome = '';
  String _idUser = '';
  String _host = '';
  String _porta = '';

  bool _validate = false;
  DateTime _dataCorrente = new DateTime.now();

  String _paOque = '';
  String _paQuem = '';
  String _idNaoConformidade;
  String _idCCU;
  String _idColigada;
  String _paCodigo;
  String _naoConformidade;
  String _itemTipo;

  initState() {
    super.initState();
    _idNaoConformidade = this.data.idNaoConformidade;
    _idColigada = this.data.idColigada;
    _idCCU = this.data.idCCU;
    _appBarTitle = new Text('Plano de Ação');
    _appBarBackgroundColor = Colors.red;
    _porta = this.dataConfig.auPorta;
    _host = this.dataConfig.auHost;
    _idUser = this.dataConfig.auIdUser;
    _naoConformidade = this.data.desNaoConfomidade;
    _itemTipo = this.data.tipoAcao;
  }

  @override
  Widget build(BuildContext context) {
    print('idNC: $_idNaoConformidade');

    return Scaffold(
      appBar: new AppBar(
        title: _appBarTitle,
        backgroundColor: _appBarBackgroundColor,
        centerTitle: true,
      ),
      body: new SingleChildScrollView(
        child: new Container(
          margin: new EdgeInsets.all(15.0),
          child: new Form(
            key: _key,
            autovalidate: _validate,
            child: _formUI(),
          ),
        ),
      ),
    );
  }

  Widget _formUI() {
    String _dataQuando = new DateFormat.yMMMd().format(_dataCorrente);

    return new Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Text(
              'Centro de Custo:  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_idCCU),
          ],
        ),
        Row(
          children: <Widget>[
            Text(
              'Tipo da Ação:  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_itemTipo),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 20),
            ),
          ],
        ),

        Row(
          children: <Widget>[
            Text(
              'Não Conformidade:  ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_naoConformidade),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 40),
            ),
          ],
        ),
        // O que?
        new TextFormField(
          decoration:
              new InputDecoration(labelText: 'O que?', hintText: 'O que?'),
          maxLength: 100,
          validator: _validarTexto,
          onSaved: (String val) {
            setState(() {
              // _paOque = val;
              _atribuiValor(1, val);
            });
          },
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 60),
            ),
          ],
        ),
        // Quem?
        new TextFormField(
          decoration:
              new InputDecoration(labelText: 'Quem?', hintText: 'Quem?'),
          maxLength: 100,
          validator: _validarTexto,
          onSaved: (String val) {
            setState(() {
              // _paQuem = val;
              _atribuiValor(2, val);
            });
          },
        ),
        // Quando?
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 60),
            ),
          ],
        ),
        // Data - Quando
        Row(
          children: <Widget>[
            Text(
              'Quando?  $_dataQuando',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              onPressed: () async {
                final _seldate = await showDatePicker(
                    context: context,
                    initialDate: _dataCorrente,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2025),
                    builder: (context, child) {
                      return SingleChildScrollView(
                        child: child,
                      );
                    });
                if (_seldate != null) {
                  setState(() {
                    _dataCorrente = _seldate;
                  });
                }
              },
              icon: Icon(Icons.calendar_today),
            )
          ],
        ),
        // Linha de espaçamento
        Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(bottom: 60),
            ),
          ],
        ),

        new RaisedButton(
          onPressed: _sendForm,
          child: new Text('Enviar'),
        )
      ],
    );
  }

  String _validarTexto(String value) {
    String patttern = r'(^[a-zA-Z \-_Ããç!,.áÁÉéêÊ?0-9]*$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return "Informe o Texto";
    } else if (!regExp.hasMatch(value)) {
      return "O Texto deve conter apenas caracteres de a-z ou A-Z";
    }
    return null;
  }

  void _atribuiValor(int pCampo, String pValor) {
    setState(() {
      if (pCampo == 1) {
        this._paOque = pValor;
      } else if (pCampo == 2) {
        this._paQuem = pValor;
      }
    });
  }

  void _sendForm() {
    if (_key.currentState.validate()) {
      // Sem erros na validação
      print('insert plano de acao - chamada');
      _insertPlanoAcao();
      _key.currentState.save();
    } else {
      // erro de validação
//      setState(() {
      _validate = true;
//      });
    }
  }

  void _insertPlanoAcao() async {
    //Navigator.pop(context);
    Navigator.pushReplacementNamed(context, "/");

    final DateFormat wData = DateFormat('ddMMyyyy');
    final String wDataAcao = wData.format(_dataCorrente);

    print('Cheguei ! - Save - plano de acao');

    var dataPlanoAcao = await http.get(
        'http://$_host:$_porta/PostPlanoDeAcao/$_idColigada/$_idNaoConformidade/$_paOque/$_paQuem/$wDataAcao/$_idUser');
    var jsonData = json.decode(dataPlanoAcao.body)['PlanoDeAcao'];

    List<PlanoDeAcao> _listPlanoAcao = [];
    int x = 0;

    for (var u in jsonData) {
      PlanoDeAcao documento = PlanoDeAcao(x, u['CODIGO'], u['MENSAGEM']);
      _listPlanoAcao.add(documento);
      x = x + 1;
    }
    _paCodigo = _listPlanoAcao[0].paCodigo;
    _showAlertDialog(context);
    print(_listPlanoAcao[0].paCodigo);
  }

  Future _showAlertDialog(BuildContext context) async {
    Alert(
      context: context,
      // type: AlertType.warning,
      title: "ERROR",
      desc: "AO CRIAR O PLANO DE AÇÃO",
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

class PlanoDeAcao {
  final int index;
  final String paCodigo;
  final String paMensagem;
  PlanoDeAcao(this.index, this.paCodigo, this.paMensagem);
}
