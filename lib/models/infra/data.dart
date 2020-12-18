class Data {
  String idNaoConformidade;
  String idColigada;
  String idCCU;
  String desNaoConfomidade;
  String tipoAcao;
  String idModeloFVS;
  String temPlanoAcao;
  // Ficha de Verificacao de Servicos
  String codFVS;
  String codModelo;
  String nomeCCU;
  String servicoInspecionado;
  String localServico;
  String dataInicio;
  String dataFim;
  String responsavelServico;

  Data(
      {this.idNaoConformidade,
      this.idColigada,
      this.idCCU,
      this.desNaoConfomidade,
      this.tipoAcao,
      this.idModeloFVS,
      this.temPlanoAcao,
      this.codFVS,
      this.codModelo,
      this.nomeCCU,
      this.servicoInspecionado,
      this.localServico,
      this.dataInicio,
      this.dataFim,
      this.responsavelServico});
}
