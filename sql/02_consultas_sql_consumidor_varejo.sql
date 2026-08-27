/*
Projeto: Radar da Experiência do Consumidor
Tema: Reclamações, SLA e satisfação no varejo brasileiro
Fonte: Consumidor.gov.br
Período: julho de 2026
Banco de dados: PostgreSQL / Supabase

Observação:
O arquivo 01_reclamacoes_varejo_tratadas.csv foi preparado em Python
e importado na tabela public.reclamacoes_varejo.
*/


-- ============================================================
-- 00. ESTRUTURA DA TABELA
-- ============================================================

CREATE TABLE IF NOT EXISTS public.reclamacoes_varejo (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    regiao TEXT,
    uf TEXT,
    cidade TEXT,
    sexo TEXT,
    faixa_etaria TEXT,
    data_finalizacao DATE,
    tempo_resposta NUMERIC(5, 2),
    nome_fantasia TEXT,
    segmento_mercado TEXT,
    area TEXT,
    assunto TEXT,
    grupo_problema TEXT,
    problema TEXT,
    canal_compra TEXT,
    procurou_empresa TEXT,
    respondida TEXT,
    situacao TEXT,
    avaliacao_reclamacao TEXT,
    nota_consumidor NUMERIC(3, 1),
    foi_respondida NUMERIC(2, 1),
    foi_avaliada NUMERIC(2, 1),
    foi_resolvida NUMERIC(2, 1),
    cumpriu_sla NUMERIC(2, 1),
    status_sla TEXT,
    faixa_satisfacao TEXT
);

ALTER TABLE public.reclamacoes_varejo
ENABLE ROW LEVEL SECURITY;

CREATE INDEX IF NOT EXISTS idx_reclamacoes_empresa
    ON public.reclamacoes_varejo (nome_fantasia);

CREATE INDEX IF NOT EXISTS idx_reclamacoes_problema
    ON public.reclamacoes_varejo (problema);

CREATE INDEX IF NOT EXISTS idx_reclamacoes_canal
    ON public.reclamacoes_varejo (canal_compra);

CREATE INDEX IF NOT EXISTS idx_reclamacoes_uf
    ON public.reclamacoes_varejo (uf);

CREATE INDEX IF NOT EXISTS idx_reclamacoes_data
    ON public.reclamacoes_varejo (data_finalizacao);


-- ============================================================
-- 01. VALIDAÇÃO GERAL DA BASE
-- ============================================================

SELECT
    COUNT(*) AS total_registros,
    COUNT(DISTINCT nome_fantasia) AS total_empresas,
    COUNT(DISTINCT uf) AS total_ufs,
    MIN(data_finalizacao) AS data_inicial,
    MAX(data_finalizacao) AS data_final,
    COUNT(*) FILTER (
        WHERE tempo_resposta IS NULL
    ) AS tempo_resposta_ausente,
    COUNT(*) FILTER (
        WHERE nota_consumidor IS NULL
    ) AS nota_consumidor_ausente
FROM public.reclamacoes_varejo;


-- ============================================================
-- 02. KPIs GERAIS DO VAREJO
-- ============================================================

WITH base AS (
    SELECT
        COUNT(*) AS total_reclamacoes,
        SUM(foi_respondida) AS respondidas,
        SUM(cumpriu_sla) AS dentro_sla,
        SUM(foi_avaliada) AS avaliadas,
        SUM(foi_resolvida) AS resolvidas,
        AVG(tempo_resposta) AS tempo_medio,
        AVG(nota_consumidor) AS nota_media,
        COUNT(*) FILTER (
            WHERE nota_consumidor IN (1, 2)
        ) AS consumidores_insatisfeitos,
        COUNT(*) FILTER (
            WHERE canal_compra = 'Internet'
        ) AS reclamacoes_internet
    FROM public.reclamacoes_varejo
),

kpis AS (
    SELECT
        1 AS ordem,
        'Total de reclamações' AS indicador,
        total_reclamacoes::NUMERIC AS valor,
        'reclamações' AS unidade
    FROM base

    UNION ALL

    SELECT
        2,
        'Taxa de resposta',
        100.0 * respondidas / NULLIF(total_reclamacoes, 0),
        '%'
    FROM base

    UNION ALL

    SELECT
        3,
        'Cumprimento do SLA entre respondidas',
        100.0 * dentro_sla / NULLIF(respondidas, 0),
        '%'
    FROM base

    UNION ALL

    SELECT
        4,
        'Tempo médio de resposta',
        tempo_medio,
        'dias'
    FROM base

    UNION ALL

    SELECT
        5,
        'Taxa de avaliação',
        100.0 * avaliadas / NULLIF(total_reclamacoes, 0),
        '%'
    FROM base

    UNION ALL

    SELECT
        6,
        'Resolução entre avaliadas',
        100.0 * resolvidas / NULLIF(avaliadas, 0),
        '%'
    FROM base

    UNION ALL

    SELECT
        7,
        'Índice de solução da plataforma',
        100.0 * (
            total_reclamacoes - avaliadas + resolvidas
        ) / NULLIF(total_reclamacoes, 0),
        '%'
    FROM base

    UNION ALL

    SELECT
        8,
        'Nota média',
        nota_media,
        'nota de 1 a 5'
    FROM base

    UNION ALL

    SELECT
        9,
        'Consumidores insatisfeitos',
        100.0 * consumidores_insatisfeitos
            / NULLIF(avaliadas, 0),
        '%'
    FROM base

    UNION ALL

    SELECT
        10,
        'Participação do canal Internet',
        100.0 * reclamacoes_internet
            / NULLIF(total_reclamacoes, 0),
        '%'
    FROM base
)

SELECT
    indicador,
    ROUND(valor, 2) AS valor,
    unidade
FROM kpis
ORDER BY ordem;


-- ============================================================
-- 03. VIEW E RANKING DE DESEMPENHO DAS EMPRESAS
-- ============================================================

CREATE OR REPLACE VIEW public.vw_desempenho_empresas AS

SELECT
    nome_fantasia,
    COUNT(*) AS total_reclamacoes,
    SUM(foi_respondida) AS respondidas,
    SUM(cumpriu_sla) AS respostas_dentro_sla,
    SUM(foi_avaliada) AS avaliadas,
    SUM(foi_resolvida) AS resolvidas,
    ROUND(
        100.0 * SUM(foi_respondida)
            / NULLIF(COUNT(*), 0),
        2
    ) AS taxa_resposta,
    ROUND(
        100.0 * SUM(cumpriu_sla)
            / NULLIF(SUM(foi_respondida), 0),
        2
    ) AS taxa_sla,
    ROUND(
        AVG(tempo_resposta),
        2
    ) AS tempo_medio_resposta,
    ROUND(
        100.0 * SUM(foi_avaliada)
            / NULLIF(COUNT(*), 0),
        2
    ) AS taxa_avaliacao,
    ROUND(
        100.0 * SUM(foi_resolvida)
            / NULLIF(SUM(foi_avaliada), 0),
        2
    ) AS taxa_resolucao,
    ROUND(
        AVG(nota_consumidor),
        2
    ) AS nota_media
FROM public.reclamacoes_varejo
GROUP BY nome_fantasia;

WITH ranking_empresas AS (
    SELECT
        RANK() OVER (
            ORDER BY total_reclamacoes DESC
        ) AS ranking_volume,
        nome_fantasia,
        total_reclamacoes,
        ROUND(
            100.0 * total_reclamacoes
                / SUM(total_reclamacoes) OVER (),
            2
        ) AS participacao_total,
        taxa_resposta,
        taxa_sla,
        tempo_medio_resposta,
        taxa_avaliacao,
        taxa_resolucao,
        nota_media
    FROM public.vw_desempenho_empresas
)

SELECT *
FROM ranking_empresas
WHERE ranking_volume <= 10
ORDER BY ranking_volume;


-- ============================================================
-- 04. RANKING E ANÁLISE DE PARETO DOS PROBLEMAS
-- ============================================================

WITH desempenho_problemas AS (
    SELECT
        problema,
        COUNT(*) AS total_reclamacoes,
        SUM(foi_avaliada) AS avaliadas,
        SUM(foi_resolvida) AS resolvidas,
        ROUND(
            100.0 * SUM(foi_resolvida)
                / NULLIF(SUM(foi_avaliada), 0),
            2
        ) AS taxa_resolucao,
        ROUND(
            AVG(nota_consumidor),
            2
        ) AS nota_media
    FROM public.reclamacoes_varejo
    GROUP BY problema
),

pareto AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY total_reclamacoes DESC
        ) AS ranking,
        problema,
        total_reclamacoes,
        ROUND(
            100.0 * total_reclamacoes
                / SUM(total_reclamacoes) OVER (),
            2
        ) AS participacao_percentual,
        ROUND(
            100.0
                * SUM(total_reclamacoes) OVER (
                    ORDER BY total_reclamacoes DESC
                    ROWS BETWEEN UNBOUNDED PRECEDING
                    AND CURRENT ROW
                )
                / SUM(total_reclamacoes) OVER (),
            2
        ) AS participacao_acumulada,
        taxa_resolucao,
        nota_media
    FROM desempenho_problemas
)

SELECT *
FROM pareto
WHERE ranking <= 10
ORDER BY ranking;


-- ============================================================
-- 05. SEGMENTAÇÃO DAS EMPRESAS POR DIAGNÓSTICO
-- ============================================================

WITH segmentacao AS (
    SELECT
        nome_fantasia,
        total_reclamacoes,
        taxa_resposta,
        taxa_sla,
        taxa_resolucao,
        nota_media,
        CASE
            WHEN taxa_resposta >= 90
                 AND taxa_resolucao < 40
                THEN 'Responde, mas resolve pouco'

            WHEN taxa_resposta < 70
                THEN 'Baixa cobertura de resposta'

            WHEN taxa_resolucao >= 60
                 AND nota_media >= 3
                THEN 'Melhor experiência'

            WHEN taxa_resolucao < 50
                 OR nota_media < 2.30
                THEN 'Atenção à experiência'

            ELSE 'Desempenho intermediário'
        END AS diagnostico
    FROM public.vw_desempenho_empresas
    WHERE total_reclamacoes >= 500
)

SELECT *
FROM segmentacao
ORDER BY
    CASE diagnostico
        WHEN 'Responde, mas resolve pouco' THEN 1
        WHEN 'Baixa cobertura de resposta' THEN 2
        WHEN 'Atenção à experiência' THEN 3
        WHEN 'Desempenho intermediário' THEN 4
        WHEN 'Melhor experiência' THEN 5
    END,
    total_reclamacoes DESC;


-- ============================================================
-- 06. TOP 3 PROBLEMAS DENTRO DE CADA CANAL RELEVANTE
-- ============================================================

WITH problemas_por_canal AS (
    SELECT
        canal_compra,
        problema,
        COUNT(*) AS total_reclamacoes,
        SUM(foi_avaliada) AS avaliadas,
        SUM(foi_resolvida) AS resolvidas,
        ROUND(
            100.0 * SUM(foi_resolvida)
                / NULLIF(SUM(foi_avaliada), 0),
            2
        ) AS taxa_resolucao,
        ROUND(
            AVG(nota_consumidor),
            2
        ) AS nota_media
    FROM public.reclamacoes_varejo
    GROUP BY
        canal_compra,
        problema
),

ranking_por_canal AS (
    SELECT
        canal_compra,
        problema,
        total_reclamacoes,
        avaliadas,
        taxa_resolucao,
        nota_media,
        SUM(total_reclamacoes) OVER (
            PARTITION BY canal_compra
        ) AS total_do_canal,
        ROW_NUMBER() OVER (
            PARTITION BY canal_compra
            ORDER BY total_reclamacoes DESC
        ) AS ranking_no_canal,
        ROUND(
            100.0 * total_reclamacoes
                / SUM(total_reclamacoes) OVER (
                    PARTITION BY canal_compra
                ),
            2
        ) AS participacao_no_canal
    FROM problemas_por_canal
)

SELECT
    canal_compra,
    ranking_no_canal,
    problema,
    total_reclamacoes,
    participacao_no_canal,
    taxa_resolucao,
    nota_media
FROM ranking_por_canal
WHERE ranking_no_canal <= 3
  AND total_do_canal >= 200
ORDER BY
    total_do_canal DESC,
    ranking_no_canal;

