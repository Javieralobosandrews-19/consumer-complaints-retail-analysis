# Dados

Os dados brutos não são armazenados neste repositório.

## Fonte

- Portal: [Dados Abertos do Consumidor.gov.br](https://www.consumidor.gov.br/pages/dadosabertos/externo/)
- Recurso analisado: reclamações finalizadas em julho de 2026
- Granularidade: uma linha por reclamação

## Base tratada

Após limpeza, tipagem e aplicação da regra de recorte do varejo, a base utilizada no projeto contém:

- 25.691 registros;
- 25 colunas analíticas;
- datas entre 01/07/2026 e 31/07/2026;
- valores ausentes preservados quando não representam zero;
- indicadores binários para resposta, avaliação, resolução e cumprimento do SLA.

Para reproduzir a análise, baixe o arquivo no portal oficial, trate-o conforme a metodologia e importe o CSV resultante como `public.reclamacoes_varejo` no PostgreSQL/Supabase.

