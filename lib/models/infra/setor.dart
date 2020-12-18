class Setor {
  String setorCodigo;
  String setorDescricao;

  Setor(String setorCodigo, String setorDescricao) {
    this.setorCodigo = setorCodigo;
    this.setorDescricao = setorDescricao;
  }

  Setor.fromJson(Map json)
      : setorCodigo = json['CODIGO'],
        setorDescricao = json['DESCRICAO'];

  Map toJson() {
    return {'CODIGO': setorCodigo, 'DESCRICAO': setorDescricao};
  }
}
