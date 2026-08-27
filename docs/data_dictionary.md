# Dicionário de dados

A tabela analítica `reclamacoes_varejo` contém 25 campos provenientes da base tratada. O campo `id` é gerado apenas no banco de dados.

| Campo | Tipo | Descrição |
|---|---|---|
| `regiao` | texto | Região brasileira associada à reclamação. |
| `uf` | texto | Unidade federativa do consumidor. |
| `cidade` | texto | Município informado. |
| `sexo` | texto | Sexo informado pelo consumidor. |
| `faixa_etaria` | texto | Faixa etária do consumidor. |
| `data_finalizacao` | data | Data de finalização da reclamação. |
| `tempo_resposta` | decimal | Quantidade de dias até a resposta da empresa. |
| `nome_fantasia` | texto | Nome comercial da empresa reclamada. |
| `segmento_mercado` | texto | Segmento de mercado da empresa. |
| `area` | texto | Área temática da reclamação. |
| `assunto` | texto | Assunto principal. |
| `grupo_problema` | texto | Agrupamento do problema. |
| `problema` | texto | Descrição categórica do problema. |
| `canal_compra` | texto | Canal usado na compra ou contratação. |
| `procurou_empresa` | texto | Indica se o consumidor procurou a empresa antes de registrar a reclamação. |
| `respondida` | texto | Situação textual da resposta. |
| `situacao` | texto | Situação final da reclamação. |
| `avaliacao_reclamacao` | texto | Classificação da reclamação como resolvida, não resolvida ou não avaliada. |
| `nota_consumidor` | decimal | Nota atribuída pelo consumidor, de 1 a 5. |
| `foi_respondida` | inteiro | Indicador binário: 1 para respondida e 0 para não respondida. |
| `foi_avaliada` | inteiro | Indicador binário: 1 para avaliada e 0 para não avaliada. |
| `foi_resolvida` | inteiro | Indicador binário de resolução na base tratada. |
| `cumpriu_sla` | inteiro | Indicador binário de resposta dentro do prazo de 10 dias. |
| `status_sla` | texto | Classificação textual do cumprimento do SLA. |
| `faixa_satisfacao` | texto | Faixa derivada da nota: insatisfeito, neutro ou satisfeito. |

## Denominadores dos indicadores

| Indicador | Fórmula |
|---|---|
| Taxa de resposta | reclamações respondidas / total de reclamações |
| Taxa de SLA | respostas dentro do prazo / reclamações respondidas |
| Taxa de avaliação | reclamações avaliadas / total de reclamações |
| Taxa de resolução | reclamações resolvidas / reclamações avaliadas |
| Taxa de insatisfação | reclamações insatisfeitas / reclamações avaliadas |

