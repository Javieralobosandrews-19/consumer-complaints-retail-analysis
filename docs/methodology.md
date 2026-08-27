# Metodologia

## 1. Entendimento do negócio

O projeto parte da hipótese de que alta taxa de resposta e cumprimento de SLA não garantem resolução nem satisfação. Por isso, os indicadores foram organizados em três camadas:

1. **Cobertura:** volume, respostas e taxa de resposta.
2. **Eficiência:** cumprimento do SLA e tempo médio de resposta.
3. **Experiência:** avaliação, resolução, nota média e insatisfação.

## 2. Preparação da base

- seleção do recorte de varejo;
- padronização dos nomes das colunas em `snake_case`;
- conversão de datas e números com configuração regional adequada;
- preservação de valores ausentes quando não equivalem a zero;
- criação de indicadores binários de resposta, avaliação, resolução e SLA;
- criação das faixas de satisfação;
- validação do total de 25.691 linhas e 25 colunas.

## 3. Modelagem e SQL

No PostgreSQL/Supabase foram criados:

- tabela analítica com tipos explícitos;
- índices para empresa, problema, canal, UF e data;
- consultas de validação e KPIs;
- view de desempenho das empresas;
- ranking Top 10;
- análise de Pareto dos problemas;
- segmentação diagnóstica das empresas;
- ranking dos três principais problemas por canal relevante.

## 4. Modelo no Power BI

O modelo utiliza uma tabela fato (`fato_reclamacoes`) ligada à dimensão de datas (`dim_calendario`) por uma relação ativa `1:*`:

```text
dim_calendario[Data]  1 ─── *  fato_reclamacoes[data_finalizacao]
```

A dimensão calendário cobre todos os dias entre a menor e a maior data de finalização. As medidas ficam organizadas em uma tabela exclusiva chamada `Medidas`.

## 5. Validação

Os resultados do Power BI foram comparados com as consultas SQL e com as validações da etapa de preparação. As verificações incluíram:

- contagem total de linhas;
- ausência de erros de conversão;
- preservação de nulos;
- consistência dos denominadores;
- conferência de KPIs, rankings e filtros cruzados.

## 6. Regra robusta de resolução

Durante a importação, a configuração regional poderia interpretar `1.0` como `10`. Para impedir distorção no dashboard, a medida final de reclamações resolvidas usa diretamente a classificação categórica confiável:

```DAX
Reclamações Resolvidas =
CALCULATE(
    COUNTROWS(fato_reclamacoes),
    fato_reclamacoes[avaliacao_reclamacao] = "Resolvida"
)
```

