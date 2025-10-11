-- =======================================================
-- 1) CRIAÇÃO DO BANCO DE DADOS (executar fora da conexão atual, se preciso)
-- =======================================================
-- Necessita permissão de superusuário ou usuário com CREATEDB
-- CREATE DATABASE cafe;

-- No psql, conecte:
-- \c cafe

-- =======================================================
-- 2) CRIAÇÃO DA TABELA ALUNOS
-- =======================================================

-- Observação: usamos o schema padrão "public"
DROP TABLE IF EXISTS public.tblpresencas;
DROP TABLE IF EXISTS public.tblturmas;
DROP TABLE IF EXISTS public.tblpets;
DROP TABLE IF EXISTS public.tblsituacao;
DROP TABLE IF EXISTS public.tblcursos;
DROP TABLE IF EXISTS public.tblalunos;

CREATE TABLE public.tblalunos
(
    idaluno      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nome         VARCHAR(100) NOT NULL,
    aniversario  DATE NOT NULL,
    sexo         VARCHAR(1) NOT NULL, -- 'M' ou 'F'
    salario      NUMERIC(10,2) NOT NULL
);

-- =======================================================
-- 3) INSERINDO DADOS NA TABELA ALUNOS
-- =======================================================

-- No Postgres, recomenda-se SEMPRE nomear as colunas
INSERT INTO public.tblalunos (nome, aniversario, sexo, salario) VALUES
('ANA',     DATE '1997-12-31', 'F', 5000.00),
('BOB',     DATE '1998-05-22', 'M', 2500.50),
('BILL',    DATE '1995-07-15', 'M', 3500.50),
('CLARA',   DATE '1981-08-17', 'F', 4000.50),
('DANIEL',  DATE '2003-11-25', 'M', 3500.00),
('DANIELA', DATE '2003-12-20', 'F', 5500.00);

-- TOP (SQL Server) -> LIMIT (PostgreSQL)
SELECT idaluno, nome, aniversario, sexo, salario
FROM public.tblalunos
ORDER BY idaluno
LIMIT 1000;

SELECT * FROM public.tblalunos;

-- =======================================================
-- 4) TABELA SITUAÇÃO (STATUS DO ALUNO)
-- =======================================================

CREATE TABLE public.tblsituacao
(
    idsituacao INTEGER PRIMARY KEY,
    situacao   VARCHAR(30) NOT NULL
);

INSERT INTO public.tblsituacao (idsituacao, situacao) VALUES
(1, 'MATRICULADO'),
(2, 'CURSANDO'),
(3, 'APROVADO'),
(4, 'REPROVADO'),
(5, 'SUSPENSO'),
(6, 'CANCELADO');

SELECT * FROM public.tblsituacao;

-- =======================================================
-- 5) TABELA CURSOS
-- =======================================================

CREATE TABLE public.tblcursos
(
    idcurso   INTEGER PRIMARY KEY,
    nomecurso VARCHAR(50) NOT NULL
);

INSERT INTO public.tblcursos (idcurso, nomecurso) VALUES
(1, 'PROGRAMACAO C++'),
(2, 'BANCO DE DADOS 1'),
(3, 'SISTEMAS OPERACIONAIS'),
(4, 'REDES 2');

SELECT * FROM public.tblcursos;

-- =======================================================
-- 6) TABELA TURMAS
-- =======================================================

CREATE TABLE public.tblturmas
(
    idturma        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    idaluno        INTEGER NOT NULL,
    idcurso        INTEGER NOT NULL,
    descricaoturma VARCHAR(50) NOT NULL,
    precoturma     NUMERIC(15,2) NOT NULL,
    datainicio     DATE NOT NULL,
    datafim        DATE NULL
);

INSERT INTO public.tblturmas (idaluno, idcurso, descricaoturma, precoturma, datainicio, datafim) VALUES
(1, 1, 'C++ DE FÉRIAS', 1250.50, DATE '2023-10-25', DATE '2023-10-29'),
(1, 2, 'C++ DE FÉRIAS', 1250.50, DATE '2023-10-25', DATE '2023-10-29'),
(1, 3, 'C++ DE FÉRIAS',    0.00, DATE '2023-10-25', DATE '2023-10-29');

SELECT * FROM public.tblturmas;

-- =======================================================
-- 7) TABELA PRESENÇAS
-- =======================================================

CREATE TABLE public.tblpresencas
(
    idturma      INTEGER NOT NULL,
    idaluno      INTEGER NOT NULL,
    idsituacao   INTEGER NOT NULL,
    datapresenca DATE NOT NULL
);

INSERT INTO public.tblpresencas (idturma, idaluno, idsituacao, datapresenca) VALUES
(1, 1, 2, DATE '2023-10-26'),
(1, 2, 2, DATE '2023-10-26'),
(1, 3, 2, DATE '2023-10-26');

-- =======================================================
-- 8) RELACIONAMENTOS (FOREIGN KEYS)
-- =======================================================

ALTER TABLE public.tblturmas
  ADD CONSTRAINT fk_turmas_alunos
  FOREIGN KEY (idaluno) REFERENCES public.tblalunos(idaluno);

ALTER TABLE public.tblturmas
  ADD CONSTRAINT fk_turmas_cursos
  FOREIGN KEY (idcurso) REFERENCES public.tblcursos(idcurso);

ALTER TABLE public.tblpresencas
  ADD CONSTRAINT fk_presenca_turma
  FOREIGN KEY (idturma) REFERENCES public.tblturmas(idturma);

ALTER TABLE public.tblpresencas
  ADD CONSTRAINT fk_presenca_aluno
  FOREIGN KEY (idaluno) REFERENCES public.tblalunos(idaluno);

ALTER TABLE public.tblpresencas
  ADD CONSTRAINT fk_presenca_sit
  FOREIGN KEY (idsituacao) REFERENCES public.tblsituacao(idsituacao);

-- =======================================================
-- 9) CONSULTAS AGREGADAS
-- =======================================================

SELECT COUNT(idturma) AS qtde_turma FROM public.tblturmas;
SELECT SUM(precoturma) AS soma_preco FROM public.tblturmas;
SELECT AVG(salario)    AS media_salario FROM public.tblalunos;
SELECT MAX(salario)    AS max_salario   FROM public.tblalunos;
SELECT MIN(salario)    AS min_salario   FROM public.tblalunos;

-- =======================================================
-- 10) TABELA PETS (EXERCÍCIO DE RELACIONAMENTO)
-- =======================================================

CREATE TABLE public.tblpets
(
    idpet   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    apelido VARCHAR(50)   NOT NULL,
    raca    VARCHAR(50)   NOT NULL,
    idaluno INTEGER       NULL,
    valor   NUMERIC(18,2) NULL
);

ALTER TABLE public.tblpets
  ADD CONSTRAINT fk_pets_alunos
  FOREIGN KEY (idaluno) REFERENCES public.tblalunos(idaluno);

INSERT INTO public.tblpets (apelido, raca, idaluno, valor) VALUES
('DOG1', 'MASTIN',   1, 1500.00),
('DOG2', 'FILA',     2, 2500.00),
('DOG3', 'BULDOGUE', 3, 3500.00),
('CAT1', 'PERSA',    2, 1800.00),
('CAT2', 'ANGORA',   2, 2300.00),
('CAT3', 'SIAMES',   3,  990.00);

-- IdAluno omitido (NULL permitido)
INSERT INTO public.tblpets (apelido, raca, valor) VALUES
('CAT4', 'SIAMES', 1000.00),
('DOG4', 'FILA',   2000.00);

-- =======================================================
-- 11) CONSULTAS COM JOIN E CÁLCULOS
-- =======================================================

SELECT apelido, raca, idaluno AS dono, valor, (valor * 0.90) AS valor_venda_a_vista
FROM public.tblpets;

SELECT p.apelido, p.raca, p.valor, a.nome AS dono
FROM public.tblpets AS p
JOIN public.tblalunos AS a ON p.idaluno = a.idaluno;

SELECT *
FROM public.tblalunos a
INNER JOIN public.tblpets b ON a.idaluno = b.idaluno;

SELECT *
FROM public.tblalunos a
LEFT JOIN public.tblpets b ON a.idaluno = b.idaluno;

-- Postgres suporta FULL OUTER JOIN
SELECT *
FROM public.tblalunos a
FULL OUTER JOIN public.tblpets b ON a.idaluno = b.idaluno;

-- =======================================================
-- 12) AGRUPAMENTO, HAVING E ORDER
-- =======================================================

SELECT raca, AVG(valor) AS media_preco, COUNT(*) AS qtde_raca
FROM public.tblpets
GROUP BY raca
ORDER BY raca;

SELECT raca, SUM(valor) AS soma_valor
FROM public.tblpets
GROUP BY raca
HAVING SUM(valor) > 1800
ORDER BY soma_valor ASC;

-- =======================================================
-- 13) FUNÇÕES NUMÉRICAS E DE DATA
-- =======================================================

SELECT 500/2 AS valor;         -- divisão inteira se ambos inteiros; use 500.0/2 para decimal
SELECT POWER(2,2) AS valor;
SELECT SQRT(35) AS valor;
SELECT PI() AS valor_pi;

SELECT NOW() AS data_hora_atual;   -- equivalente ao GETDATE()

-- =======================================================
-- 14) VIEW, "BACKUP" (comentários) E TRIGGER
-- =======================================================

DROP VIEW IF EXISTS public.minha_view;
CREATE VIEW public.minha_view AS
SELECT p.apelido, p.raca, p.valor, a.nome AS dono
FROM public.tblpets AS p
JOIN public.tblalunos AS a ON p.idaluno = a.idaluno;

-- BACKUP no PostgreSQL:
-- Não existe "BACKUP DATABASE" via SQL. Use ferramentas externas:
--  - pg_dump (lógico) / pg_dumpall
--  - pg_basebackup (físico, com réplica e permissões de sistema)
-- Vide seção 15 para criar um papel com privilégios de leitura para pg_dump.

-- Trigger que dispara mensagem ao alterar tblpets
-- Em Postgres, triggers chamam uma FUNCTION em PL/pgSQL:
DROP TRIGGER IF EXISTS aviso ON public.tblpets;
DROP FUNCTION IF EXISTS public.aviso_trigger();

CREATE FUNCTION public.aviso_trigger()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    -- Para se comportar como erro (RAISERROR nível 16), usamos EXCEPTION:
    RAISE EXCEPTION 'Avisar o usuario';
    RETURN NULL;
END;
$$;

CREATE TRIGGER aviso
AFTER INSERT OR UPDATE OR DELETE ON public.tblpets
FOR EACH STATEMENT
EXECUTE FUNCTION public.aviso_trigger();

-- Teste do trigger (vai gerar EXCEPTION e abortar a transação)
-- INSERT INTO public.tblpets (apelido, raca, valor) VALUES ('DOG5', 'FILA', 2300.00);

-- =======================================================
-- 15) PAPEL/USUÁRIO PARA "BACKUP" (equivalente lógico via pg_dump)
-- =======================================================
-- Em Postgres, pg_dump precisa de:
--   - CONNECT ao banco
--   - USAGE no schema
--   - SELECT nas tabelas (e demais objetos)
-- Opcional: adicionar ao papel "pg_read_all_data" (PG 14+) para leitura ampla.

-- Execute na base "postgres" ou em qualquer conexão com privilégio suficiente:
-- CREATE ROLE backup_cafe LOGIN PASSWORD 'Troque_Esta_Senha!123';
-- GRANT CONNECT ON DATABASE cafe TO backup_cafe;

-- Conecte-se a "cafe" e conceda privilégios:
-- \c cafe
-- GRANT USAGE ON SCHEMA public TO backup_cafe;
-- GRANT SELECT ON ALL TABLES IN SCHEMA public TO backup_cafe;
-- ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO backup_cafe;

-- (Opcional, se disponível)
-- GRANT pg_read_all_data TO backup_cafe;

-- Exemplos de backup (executados no SO, não em SQL):
-- pg_dump -U backup_cafe -d cafe -Fc -f /caminho/cafe.dump
-- pg_dump -U backup_cafe -d cafe -f /caminho/cafe.sql

-- =======================================================
-- 16) TAMANHO DO BANCO "cafe" (por objeto e total)
-- =======================================================

-- Tamanho total do banco
SELECT
  current_database() AS database_name,
  pg_size_pretty(pg_database_size(current_database())) AS size_total;

-- Tamanho por tabela (heap + indexes + TOAST)
SELECT
  schemaname,
  relname AS table_name,
  pg_size_pretty(pg_total_relation_size(format('%I.%I', schemaname, relname))) AS total_size,
  pg_size_pretty(pg_relation_size(format('%I.%I', schemaname, relname)))       AS table_heap_size,
  pg_size_pretty(pg_indexes_size(format('%I.%I', schemaname, relname)))         AS indexes_size
FROM pg_stat_user_tables
ORDER BY pg_total_relation_size(format('%I.%I', schemaname, relname)) DESC;

-- =======================================================
-- 17) TABELAS, COLUNAS E TIPOS DE DADOS (BANCO "cafe")
-- =======================================================

-- Metadados das colunas (information_schema)
SELECT
    c.table_schema,
    c.table_name,
    c.ordinal_position AS column_id,
    c.column_name,
    c.data_type,
    c.character_maximum_length AS max_length,
    c.numeric_precision        AS precision,
    c.numeric_scale            AS scale,
    c.is_nullable,
    c.identity_generation      AS identity_generation -- 'ALWAYS' / 'BY DEFAULT' / NULL
FROM information_schema.columns c
WHERE c.table_schema = 'public'
ORDER BY c.table_schema, c.table_name, c.ordinal_position;

-- Colunas indexadas (lista de índices por tabela)
SELECT
  tab.relname   AS table_name,
  idx.relname   AS index_name,
  i.indisunique AS is_unique,
  i.indisprimary AS is_primary,
  array_to_string(ARRAY(
    SELECT pg_get_indexdef(i.indexrelid, k + 1, true)
    FROM generate_subscripts(i.indkey, 1) AS k
    ORDER BY k
  ), ', ') AS index_columns
FROM pg_index i
JOIN pg_class idx ON idx.oid = i.indexrelid
JOIN pg_class tab ON tab.oid = i.indrelid
JOIN pg_namespace n ON n.oid = tab.relnamespace
WHERE n.nspname = 'public'
ORDER BY tab.relname, idx.relname;

-- =======================================================
-- 18) RECURSOS: CPU, MEMÓRIA E DISCO (aproximações no Postgres)
-- =======================================================
-- O PostgreSQL não expõe CPU/Memória/Disco como as DMVs do SQL Server.
-- Alternativas:
--   - pg_stat_database: métricas de I/O lógico e atividade
--   - pg_statio_*: estatísticas de I/O por relação
--   - pg_stat_statements (extensão): tempo total por query (não CPU)

-- 18.1) Atividade por banco (estatísticas gerais)
SELECT
  datname,
  numbackends,
  xact_commit,
  xact_rollback,
  blks_read,
  blks_hit,
  tup_returned,
  tup_fetched,
  tup_inserted,
  tup_updated,
  tup_deleted
FROM pg_stat_database
WHERE datname = current_database();

-- 18.2) I/O por tabela (usuário)
SELECT
  schemaname,
  relname AS table_name,
  heap_blks_read,
  heap_blks_hit,
  idx_blks_read,
  idx_blks_hit,
  toast_blks_read,
  toast_blks_hit,
  tidx_blks_read,
  tidx_blks_hit
FROM pg_statio_user_tables
ORDER BY (heap_blks_read + idx_blks_read) DESC;

-- 18.3) (Opcional) Se pg_stat_statements estiver instalada:
-- CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
-- SELECT
--   dbid,
--   queryid,
--   calls,
--   total_time,         -- ms consumidos (tempo total de execução)
--   mean_time,          -- ms médios por chamada
--   rows
-- FROM pg_stat_statements
-- WHERE dbid = (SELECT oid FROM pg_database WHERE datname = current_database())
-- ORDER BY total_time DESC
-- LIMIT 50;
