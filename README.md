# Sincronização de schemas Oracle
Compartilhando conhecimento e conquistas: Automatizando o sincronismo de schemas Oracle 🌟

Após muita correria para disponibilizar ambientes de homologação/QA, criei um script shell que faz exatamente isso. Ele bloqueia o schema atual, remove completamente os objetos, busca a versão mais recente do dump, importa e, então, corrige tudo para deixar o ambiente pronto para novos testes, mas tem algumas particularidades:

- Ser o mais ágil possível.
- Não mexer na estrutura de outros schemas, a não ser um específico.
- Ambiente totalmente diferente, outra máquina, outra instalação DBOracle, etc.
- Utilizar um "backup" lógico (dump).

Alguns detalhes do processo:

- Bloqueio e Limpeza: O script bloqueia o acesso ao schema desejado (o shut/start é para garantir que não hajam sessões conectadas do schema na hora do drop), em seguida, realiza uma limpeza completa, dropando o schema atual para garantir que não haja vestígios de dados antigos.
- Atualização de Schema: Com a área limpa, o script busca o dump mais recente do schema (pode ser em outro ambiente!) e o importa para seu banco de dados, trazendo todas as atualizações necessárias para o QA.
- Correções: Também coloquei o próprio script nativo do Oracle "utlrp" para recompilar todos os objetos após a importação, tratando exceções de erro no fim do processo.
- Flexibilidade: Coloquei algumas condições para tratar os formatos de compressão em que o arquivo dump possa estar e ignorar caso não esteja comprimido.

Na prática, como Funciona?

O script inicia bloqueando o acesso ao schema e preparando o banco de dados para receber a nova versão. Em seguida, conecta-se a um servidor remoto para buscar o dump mais recente do schema. O arquivo é transferido para o ambiente local, descompactado (quando necessário) e importado para o banco de dados Oracle, utilizando as melhores práticas e garantindo a integridade dos dados. Por fim, o script realiza a limpeza dos arquivos já utilizados (economizando espaço, já que os ambientes de QA costumam não ter muito à disposição) e desbloqueia o acesso ao schema, deixando o ambiente pronto para uso.

Por que usar esse processo?

O principal ponto que me fez pensar nesse script é a economia de tempo, mas abre um bom campo de opções! Por exemplo: você pode rodar manualmente o script ou agendar via CRONTAB ou outro agente... mantendo o ambiente sempre o mais atualizado possível sem precisar perder tempo 😉

Sei que há diversas outras formas de realizar processos parecidos com esse, mas no cenário que me foi entregue, foi a melhor forma que encontrei até aqui. Adoraria receber o feedback de vocês, além de dicas que serão muito bem utilizadas!

Sintam-se à vontade para usar esse processo se entenderem que cabe no ambiente de vocês.
