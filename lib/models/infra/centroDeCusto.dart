class CentroDeCusto {
  String ccuCodigo;
  String ccuNome;
  String ccuDescricao;

  CentroDeCusto(String ccuCodigo, String ccuNome, String ccuDescricao) {
    this.ccuCodigo = ccuCodigo;
    this.ccuNome = ccuNome;
    this.ccuDescricao = ccuDescricao;
  }

  CentroDeCusto.fromJson(Map json)
      : ccuCodigo = json['CODIGO'],
        ccuNome = json['NOME'],
        ccuDescricao = json['DESCRICAO'];

  Map toJson() {
    return {'CODIGO': ccuCodigo, 'NOME': ccuNome, 'DESCRICAO': ccuDescricao};
  }
}
