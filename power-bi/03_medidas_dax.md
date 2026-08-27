# Medidas DAX e tabela calendário

## Tabela calendário

```DAX
dim_calendario =
CALENDAR(
    MIN(fato_reclamacoes[data_finalizacao]),
    MAX(fato_reclamacoes[data_finalizacao])
)
```

```DAX
Ano = YEAR(dim_calendario[Data])
Mes_Num = MONTH(dim_calendario[Data])
Mes = FORMAT(dim_calendario[Data], "MMM")
Dia = DAY(dim_calendario[Data])
Mes_Ano = FORMAT(dim_calendario[Data], "MMM/yyyy")
```

## Volume, resposta e SLA

```DAX
Total Reclamações =
COUNTROWS(fato_reclamacoes)
```

```DAX
Reclamações Respondidas =
SUM(fato_reclamacoes[foi_respondida])
```

```DAX
Taxa de Resposta =
DIVIDE(
    [Reclamações Respondidas],
    [Total Reclamações],
    0
)
```

```DAX
Respostas no Prazo =
SUM(fato_reclamacoes[cumpriu_sla])
```

```DAX
Taxa de SLA =
DIVIDE(
    [Respostas no Prazo],
    [Reclamações Respondidas],
    0
)
```

```DAX
Tempo Médio de Resposta =
AVERAGE(fato_reclamacoes[tempo_resposta])
```

## Avaliação, resolução e satisfação

```DAX
Reclamações Avaliadas =
SUM(fato_reclamacoes[foi_avaliada])
```

```DAX
Taxa de Avaliação =
DIVIDE(
    [Reclamações Avaliadas],
    [Total Reclamações],
    0
)
```

```DAX
Reclamações Resolvidas =
CALCULATE(
    COUNTROWS(fato_reclamacoes),
    fato_reclamacoes[avaliacao_reclamacao] = "Resolvida"
)
```

```DAX
Taxa de Resolução =
DIVIDE(
    [Reclamações Resolvidas],
    [Reclamações Avaliadas],
    0
)
```

```DAX
Nota Média =
AVERAGE(fato_reclamacoes[nota_consumidor])
```

```DAX
Reclamações Insatisfeitas =
CALCULATE(
    COUNTROWS(fato_reclamacoes),
    fato_reclamacoes[faixa_satisfacao] = "Insatisfeito"
)
```

```DAX
Taxa de Insatisfação =
DIVIDE(
    [Reclamações Insatisfeitas],
    [Reclamações Avaliadas],
    0
)
```

## Formatação

- Taxas: percentual com duas casas decimais.
- Tempo médio e nota média: número decimal com duas casas.
- Contagens: número inteiro com separador de milhares e sem abreviação automática.

