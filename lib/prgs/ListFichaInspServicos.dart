import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:rgti_gsi/prgs/FichaVerServicoEdit.dart';
import 'package:rgti_gsi/models/infra/data.dart';
import 'package:rgti_gsi/models/infra/appconfig.dart';

import 'dart:async';

class ListFichaInspServicos extends StatefulWidget {
  @override
  _ListFichaInspServicos createState() {
    return new _ListFichaInspServicos();
  }
}

class _ListFichaInspServicos extends State<ListFichaInspServicos> {
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

  final data = Data();
  final dataConfig = AppConfig();

  Future<List<FichaDeServicos>> _getDocumentos() async {
    print('codigo: $_codigo');
    var data =
        await http.get('http://$_host:$_porta/GetListaFichaServ/$_codigo');
    var jsonData = json.decode(data.body)['ListaFichaServicos'];

    List<FichaDeServicos> _listFichaServicos = [];
    int x = 0;

    for (var u in jsonData) {
      FichaDeServicos documento = FichaDeServicos(
          x,
          u['CODCOLIGADA'],
          u['CODCCUSTO'],
          u['CODIGO'],
          u['CODMODELO'],
          u['NOME'],
          u['SERVICOINSPECIONADO'],
          u['LOCALASERVERIFICADO'],
          u['DTINICIOSERVICO'],
          u['DTFIMSERVICO'],
          u['RESPONSAVELSERVICO']);
      _listFichaServicos.add(documento);
      x = x + 1;
    }

    return _listFichaServicos;
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
                          leading: Text(snapshot.data[index].codigo),
                          title: Text(snapshot.data[index].servicoInspecionado),
                          subtitle: Text(snapshot.data[index].nomeCCU +
                              ' - ' +
                              snapshot.data[index].codModelo +
                              ' - ' +
                              snapshot.data[index].responsavelServico +
                              ' - ' +
                              snapshot.data[index].dataInicio),
                          onTap: () => _editFichaVerServico(
                              snapshot.data[index].codColigada,
                              snapshot.data[index].codCCusto,
                              snapshot.data[index].codigo,
                              snapshot.data[index].codModelo,
                              snapshot.data[index].nomeCCU,
                              snapshot.data[index].servicoInspecionado,
                              snapshot.data[index].localServico,
                              snapshot.data[index].dataInicio,
                              snapshot.data[index].dataFim,
                              snapshot.data[index].responsavelServico),
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

  _editFichaVerServico(
      String pCodColigada,
      String pCodCCusto,
      String pCodigo,
      String pcodModelo,
      String pnomeCCU,
      String pservicoInspecionado,
      String plocalServico,
      String pdataInicio,
      String pdataFim,
      String presponsavelServico) {
    if (pCodColigada != null) {
      data.idColigada = pCodColigada;
      data.idCCU = pCodCCusto;
      data.codFVS = pCodigo;
      data.codModelo = pcodModelo;
      data.nomeCCU = pnomeCCU;
      data.servicoInspecionado = pservicoInspecionado;
      data.localServico = plocalServico;
      data.dataInicio = pdataInicio;
      data.dataFim = pdataFim;
      data.responsavelServico = presponsavelServico;

      dataConfig.auIdUser = _codigo;
      dataConfig.auHost = _host;
      dataConfig.auLogin = _login;
      dataConfig.auPorta = _porta;

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                FichaVerServicoEdit(data: data, dataConfig: dataConfig)),
      );
    }
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

class FichaDeServicos {
  final int index;
  final String codColigada;
  final String codCCusto;
  final String codigo;
  final String codModelo;
  final String nomeCCU;
  final String servicoInspecionado;
  final String localServico;
  final String dataInicio;
  final String dataFim;
  final String responsavelServico;

  FichaDeServicos(
      this.index,
      this.codColigada,
      this.codCCusto,
      this.codigo,
      this.codModelo,
      this.nomeCCU,
      this.servicoInspecionado,
      this.localServico,
      this.dataInicio,
      this.dataFim,
      this.responsavelServico);
}
