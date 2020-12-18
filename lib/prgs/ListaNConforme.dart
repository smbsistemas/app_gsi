import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:rgti_gsi/prgs/showNConformidade.dart';

class ListaNConforme extends StatefulWidget {
  @override
  _ListaNConforme createState() {
    return new _ListaNConforme();
  }
}

class _ListaNConforme extends State<ListaNConforme> {
  List _acessoUserList = [];
  String _login = '';
  String _password = '';
  String _nome = '';
  String _codigo = '';
  String _host = '';
  String _porta = '';

  void initState() {
    super.initState();

    _readData().then((data) {
      setState(() {
        _acessoUserList = json.decode(data);
        _login = _acessoUserList[0]['login'];
        _password = _acessoUserList[0]['senha'];
        _nome = _acessoUserList[0]['nome'];
        _codigo = _acessoUserList[0]['codigo'];
        _host = _acessoUserList[0]['host'];
        _porta = _acessoUserList[0]['porta'];
      });
    });
  }

  Future<List<NaoConformidade>> _getDocumentos() async {
    print('codigo: $_codigo');
    var data =
        await http.get('http://$_host:$_porta/GetListaNConforme/$_codigo');
    var jsonData = json.decode(data.body)['NaoConformidade'];

    List<NaoConformidade> _listNaoConforme = [];
    int x = 0;

    for (var u in jsonData) {
      NaoConformidade documento = NaoConformidade(
          x,
          u['CODCOLIGADA'],
          u['CODCCUSTO'],
          u['CODNCONFORM'],
          u['TPACAO'],
          u['CLASSIFICACAO'],
          u['NCONFREALPONTENCIAL'],
          u['DATAABERTURANC'],
          u['DESCCCU']);
      _listNaoConforme.add(documento);
      x = x + 1;
    }

    return _listNaoConforme;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 10.0, 17.0, 3.0),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getDocumentos(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data == null) {
                  return Container(child: Center(child: Text("Loading...")));
                } else {
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          leading: Text(snapshot.data[index].codnconform +
                              ' - ' +
                              snapshot.data[index].desCCU),
//                          title: Text(snapshot.data[index].codccusto +
//                              ' - ' +
//                              snapshot.data[index].desCCU),
                          title: Text(snapshot.data[index].nconfrealpontencial),
                          subtitle: Text(snapshot.data[index].tpacao +
                              ' - ' +
                              snapshot.data[index].classificacao +
                              ' - ' +
                              snapshot.data[index].dataaberturanc),
                          //      onLongPress: _showNConformidade(
                          //          snapshot.data[index].codnconform),
                        );
                      });
                }
              },
            ),
          )
        ],
      ),
    );
  }

  _showNConformidade(String pcodnconform) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => showNConformidade()));
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/gsiacesso.json");
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}

class NaoConformidade {
  final int index;
  final String codcoligada;
  final String codccusto;
  final String codnconform;
  final String tpacao;
  final String classificacao;
  final String nconfrealpontencial;
  final String dataaberturanc;
  final String desCCU;

  NaoConformidade(
      this.index,
      this.codcoligada,
      this.codccusto,
      this.codnconform,
      this.tpacao,
      this.classificacao,
      this.nconfrealpontencial,
      this.dataaberturanc,
      this.desCCU);
}
