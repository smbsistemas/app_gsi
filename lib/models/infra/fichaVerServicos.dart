class FichaVerServicos {
  String codColigada;
  String ccuCodigo;
  String desCCU;
  String codServico;
  String codModelo;
  String modelo;
  String ccuNome;
  String servicoInspecionado;
  String localaServVerificado;
  String dataInicio;
  String dataFim;
  String nomeResponsavel;

  FichaVerServicos(
      String codColigada,
      String ccuCodigo,
      String desCCU,
      String codServico,
      String codModelo,
      String modelo,
      String ccuNome,
      String servicoInspecionado,
      String localaServVerificado,
      String dataInicio,
      String dataFim,
      String nomeResponsavel) {
    this.codColigada = codColigada;
    this.ccuCodigo = ccuCodigo;
    this.desCCU = desCCU;
    this.codServico = codServico;
    this.codModelo = codModelo;
    this.modelo = modelo;
    this.ccuNome = ccuNome;
    this.servicoInspecionado = servicoInspecionado;
    this.localaServVerificado = localaServVerificado;
    this.dataInicio = dataInicio;
    this.dataFim = dataFim;
    this.nomeResponsavel = nomeResponsavel;
  }

  FichaVerServicos.fromJson(Map json)
      : codColigada = json['CODCOLIGADA'],
        ccuCodigo = json['CODCCUSTO'],
        desCCU = json['DESCCU'],
        codServico = json['CODIGO'],
        codModelo = json['CODMODELO'],
        modelo = json['MODELO'],
        ccuNome = json['NOME'],
        servicoInspecionado = json['SERVICOINSPECIONADO'],
        localaServVerificado = json['LOCALASERVERIFICADO'],
        dataInicio = json['DTINICIOSERVICO'],
        dataFim = json['DTFIMSERVICO'],
        nomeResponsavel = json['RESPONSAVELSERVICO'];

  Map toJson() {
    return {
      'CODCOLIGADA': codColigada,
      'CODCCUSTO': ccuCodigo,
      'DESCCU': desCCU,
      'CODIGO': codServico,
      'CODMODELO': codModelo,
      'MODELO': codModelo,
      'NOME': ccuNome,
      'SERVICOINSPECIONADO': servicoInspecionado,
      'LOCALASERVERIFICADO': localaServVerificado,
      'DTINICIOSERVICO': dataInicio,
      'DTFIMSERVICO': dataFim,
      'RESPONSAVELSERVICO': nomeResponsavel
    };
  }
}
