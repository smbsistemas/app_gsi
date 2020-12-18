import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'dart:async';

class DocEletronico extends StatefulWidget {
  @override
  _DocEletronico createState() {
    return new _DocEletronico();
  }
}

class _DocEletronico extends State<DocEletronico> {
  List _acessoUserList = [];
  String _login = '';
  String _password = '';
  String _nome = '';
  String _codigo = '';
  String _host = '';
  String _porta = '';

  @override
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
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
                          title: Text(snapshot.data[index].codigo),
                          subtitle: Text(snapshot.data[index].descricao),
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

  Future<List<Documento>> _getDocumentos() async {
    print('porta: $_porta');
    var data = await http.get('http://$_host:$_porta/GetListaDocumentos');
    var jsonData = json.decode(data.body)['CatDocumentos'];

    List<Documento> _listDocEle = [];
    int x = 0;

    for (var u in jsonData) {
      Documento documento = Documento(x, u['CODIGO'], u['DESCRICAO'],
          u['CODITEMPAI'], u['CODIGOSEQ'], u['NOMEANEXO'], u['EXTENSAO']);
      _listDocEle.add(documento);
      x = x + 1;
    }
    return _listDocEle;
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

class Documento {
  final int index;
  final String codigo;
  final String descricao;
  final String coditempai;
  final String codsequencia;
  final String nomeanexo;
  final String extensao;

  Documento(this.index, this.codigo, this.descricao, this.coditempai,
      this.codsequencia, this.nomeanexo, this.extensao);
}
