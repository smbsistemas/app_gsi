class ModeloFVS {
  String mFVSCodigo;
  String mFVSDescricao;

  ModeloFVS(String mFVSCodigo, String mFVSDescricao) {
    this.mFVSCodigo = mFVSCodigo;
    this.mFVSDescricao = mFVSDescricao;
  }

  ModeloFVS.fromJson(Map json)
      : mFVSCodigo = json['CODIGO'],
        mFVSDescricao = json['NOME'];

  Map toJson() {
    return {'CODIGO': mFVSCodigo, 'NOME': mFVSDescricao};
  }
}
