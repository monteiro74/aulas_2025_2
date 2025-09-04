-- =======================================================
-- 1) CRIAÇÃO DO BANCO DE DADOS
-- =======================================================

-- Cria um banco de dados chamado "cafe"
CREATE DATABASE cafe;

-- O comando USE define qual banco será usado para os próximos comandos
USE cafe;

-- O comando GO é usado no SQL Server para separar lotes de instruções
-- O lote é enviado ao servidor quando o GO é encontrado
GO;


-- =======================================================
-- 2) CRIAÇÃO DA TABELA ALUNOS
-- =======================================================

-- Cria a tabela "tblAlunos" com:
--  IdAluno   → chave primária, autoincremento (IDENTITY)
--  Nome      → nome do aluno
--  Aniversario → data de nascimento
--  Sexo      → 'M' ou 'F'
--  Salario   → salário decimal com 2 casas
CREATE TABLE tblAlunos 
(
 IdAluno int IDENTITY(1,1) PRIMARY KEY NOT NULL,  -- Identity(1,1): inicia em 1 e incrementa de 1 em 1
 Nome varchar(100) NOT NULL,
 Aniversario date NOT NULL,
 Sexo varchar(1) NOT NULL, -- M ou F
 Salario decimal(10,2) NOT NULL,
);

-- Observações úteis:
--   DROP TABLE tblAlunos        → remove a tabela
--   ALTER TABLE DROP/ADD COLUMN → altera colunas
--   IDENTITY(seed, increment)   → gera valores automáticos
--   seed = valor inicial, increment = quanto aumenta


-- =======================================================
-- 3) INSERINDO DADOS NA TABELA ALUNOS
-- =======================================================

-- Ao inserir sem especificar colunas, é necessário seguir a ordem definida na criação da tabela
INSERT INTO tblAlunos VALUES ('ANA', '19971231', 'F', 5000);
INSERT INTO tblAlunos VALUES ('BOB', '19980522', 'M', 2500.50);
INSERT INTO tblAlunos VALUES ('BILL', '19950715', 'M', 3500.50);
INSERT INTO tblAlunos VALUES ('CLARA', '19810817', 'F', 4000.50);
INSERT INTO tblAlunos VALUES ('DANIEL', '20031125', 'M', 3500);
INSERT INTO dbo.tblAlunos VALUES ('DANIELA', '20031220', 'F', 5500);

-- Seleciona os 1000 primeiros registros (útil em bases grandes)
SELECT TOP (1000) [IdAluno], [Nome], [Aniversario], [Sexo], [Salario]
FROM [escola2].[dbo].[tblAlunos];

-- Seleciona todos os registros da tabela Alunos
SELECT * FROM tblAlunos;

-- Exemplo de erro: tentar inserir um IdAluno manualmente em campo IDENTITY
-- Isso gera erro pois o campo é autoincrementado
INSERT INTO tblAlunos VALUES (2, 'DANIEL', '20031125', 'F', 3670);


-- =======================================================
-- 4) TABELA SITUAÇÃO (STATUS DO ALUNO)
-- =======================================================

-- Cria a tabela de situação acadêmica do aluno
CREATE TABLE tblSituacao
(
 IdSituacao int PRIMARY KEY NOT NULL, -- chave primária
 Situacao varchar(30) NOT NULL        -- descrição (matriculado, aprovado etc.)
);

-- Inserindo status de exemplo
INSERT INTO tblSituacao VALUES (1, 'MATRICULADO');
INSERT INTO tblSituacao VALUES (2, 'CURSANDO');
INSERT INTO tblSituacao VALUES (3, 'APROVADO');
INSERT INTO tblSituacao VALUES (4, 'REPROVADO');
INSERT INTO tblSituacao VALUES (5, 'SUSPENSO');
INSERT INTO tblSituacao VALUES (6, 'CANCELADO');

-- Consultar todos os status
SELECT * FROM tblSituacao;


-- =======================================================
-- 5) TABELA CURSOS
-- =======================================================

-- Cria tabela de cursos
CREATE TABLE tblCursos
(
 IdCurso int PRIMARY KEY NOT NULL,
 NomeCurso varchar(50) NOT NULL
);

-- Inserindo cursos
INSERT INTO tblCursos VALUES (1, 'PROGRAMACAO C++');
INSERT INTO tblCursos VALUES (2, 'BANCO DE DADOS 1');
INSERT INTO tblCursos VALUES (3, 'SISTEMAS OPERACIONAIS');
INSERT INTO tblCursos VALUES (4, 'REDES 2');

-- Consultar cursos cadastrados
SELECT * FROM tblCursos;


-- =======================================================
-- 6) TABELA TURMAS
-- =======================================================

-- Cada turma está associada a um curso e a alunos
-- Inclui preço e datas de início/fim
CREATE TABLE tblTurmas
(
 IdTurma int IDENTITY(1,1) PRIMARY KEY NOT NULL,
 IdAluno int NOT NULL,
 IdCurso int NOT NULL,
 DescricaoTurma varchar(50) NOT NULL,
 PrecoTurma numeric(15,2) NOT NULL,
 DataInicio date NOT NULL,
 DataFim date
);

-- Inserindo registros de exemplo
INSERT INTO tblTurmas VALUES (1, 1, 'C++ DE FÉRIAS', 1250.50, '20231025', '20231029');
INSERT INTO tblTurmas VALUES (1, 2, 'C++ DE FÉRIAS', 1250.50, '20231025', '20231029');
INSERT INTO tblTurmas VALUES (1, 3, 'C++ DE FÉRIAS', 0, '20231025', '20231029');

-- Consultar turmas
SELECT * FROM tblTurmas;


-- =======================================================
-- 7) TABELA PRESENÇAS
-- =======================================================

-- Registra presença de alunos em turmas
CREATE TABLE tblPresencas
(
 IdTurma int NOT NULL,     -- FK para turma
 IdAluno int NOT NULL,     -- FK para aluno
 IdSituacao int NOT NULL,  -- FK para status
 DataPresenca date NOT NULL
);

-- Inserindo presenças de exemplo
INSERT INTO tblPresencas VALUES (1, 1, 2, '20231026');
INSERT INTO tblPresencas VALUES (1, 2, 2, '20231026');
INSERT INTO tblPresencas VALUES (1, 3, 2, '20231026');


-- =======================================================
-- 8) RELACIONAMENTOS (FOREIGN KEYS)
-- =======================================================

-- Relaciona turma ↔ alunos
ALTER TABLE tblTurmas
  ADD CONSTRAINT fk_TurmasAlunos FOREIGN KEY (IdAluno) REFERENCES tblAlunos(IdAluno);

-- Relaciona turma ↔ cursos
ALTER TABLE tblTurmas
  ADD CONSTRAINT fk_TurmasCursos FOREIGN KEY (IdCurso) REFERENCES tblCursos(IdCurso);

-- Relaciona presenças ↔ turmas
ALTER TABLE tblPresencas
  ADD CONSTRAINT fk_PresencaTurma FOREIGN KEY (IdTurma) REFERENCES tblTurmas(IdTurma);

-- Relaciona presenças ↔ alunos
ALTER TABLE tblPresencas
  ADD CONSTRAINT fk_PresencaAluno FOREIGN KEY (IdAluno) REFERENCES tblAlunos(IdAluno);

-- Relaciona presenças ↔ situação
ALTER TABLE tblPresencas
  ADD CONSTRAINT fk_PresencaSituacao FOREIGN KEY (IdSituacao) REFERENCES tblSituacao(IdSituacao);


-- =======================================================
-- 9) CONSULTAS AGREGADAS
-- =======================================================

-- Conta quantas turmas existem
SELECT COUNT(IdTurma) as qtdeTurma FROM tblTurmas;

-- Soma dos preços das turmas
SELECT SUM(PrecoTurma) AS somaPreco FROM tblTurmas;

-- Média dos salários dos alunos
SELECT AVG(Salario) AS mediaSalario FROM tblAlunos;

-- Valor máximo e mínimo de salários
SELECT MAX(Salario) AS maxSalario FROM tblAlunos;
SELECT MIN(Salario) AS minSalario FROM tblAlunos;


-- =======================================================
-- 10) TABELA PETS (EXERCÍCIO DE RELACIONAMENTO)
-- =======================================================

-- Criação com ANSI_NULLS e QUOTED_IDENTIFIER (boas práticas no SQL Server)
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblPets](
	[IdPet] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	  NULL,
	  NULL,
	[IdAluno] [int] NULL,              -- FK para Alunos
	[Valor] [decimal](18, 0) NULL      -- Preço/valor do pet
) ON [PRIMARY];

-- Inserindo dados de exemplo
INSERT INTO tblPets ([Apelido],[Raca],[IdAluno],[Valor]) VALUES('DOG1', 'MASTIN', 1 ,1500.00);
INSERT INTO tblPets ([Apelido],[Raca],[IdAluno],[Valor]) VALUES('DOG2', 'FILA', 2 ,2500.00);
INSERT INTO tblPets ([Apelido],[Raca],[IdAluno],[Valor]) VALUES('DOG3', 'BULDOGUE', 3 ,3500.00);
INSERT INTO tblPets ([Apelido],[Raca],[IdAluno],[Valor]) VALUES('CAT1', 'PERSA', 2 ,1800.00);
INSERT INTO tblPets ([Apelido],[Raca],[IdAluno],[Valor]) VALUES('CAT2', 'ANGORA', 2 ,2300.00);
INSERT INTO tblPets ([Apelido],[Raca],[IdAluno],[Valor]) VALUES('CAT3', 'SIAMES', 3 ,990.00);
-- Aqui omitimos IdAluno (permitido porque é NULL)
INSERT INTO tblPets ([Apelido],[Raca],[Valor]) VALUES('CAT4', 'SIAMES',1000.00);
INSERT INTO tblPets ([Apelido],[Raca],[Valor]) VALUES('DOG4', 'FILA',2000.00);


-- =======================================================
-- 11) CONSULTAS COM JOIN E CÁLCULOS
-- =======================================================

-- Desconto de 10% no valor dos pets
SELECT Apelido, Raca, IdAluno AS Dono, Valor, (Valor*0.90) AS valorVendaAVista 
FROM tblPets;

-- Join de Pets com Alunos para mostrar dono
SELECT p.Apelido, p.Raca, p.Valor, a.Nome as Dono
FROM tblAlunos AS a, tblPets AS p
WHERE p.IdAluno = a.IdAluno;

-- INNER JOIN (mostra só correspondências)
SELECT *
FROM tblAlunos a
INNER JOIN tblPets b ON a.IdAluno = b.IdAluno;

-- LEFT JOIN (mostra todos alunos, mesmo sem pet)
SELECT *
FROM tblAlunos a
LEFT JOIN tblPets b ON a.IdAluno = b.IdAluno;

-- FULL OUTER JOIN (mostra todos alunos e todos pets)
SELECT *
FROM tblAlunos a
FULL OUTER JOIN tblPets b ON a.IdAluno = b.IdAluno;


-- =======================================================
-- 12) AGRUPAMENTO, HAVING E ORDER
-- =======================================================

-- Média e quantidade de pets por raça
SELECT Raca, AVG(Valor) AS mediaPreco, COUNT(Raca) AS qtdeRaca
FROM tblPets
GROUP BY Raca
ORDER BY Raca;

-- Filtrar grupos com soma de valor > 1800
SELECT Raca, Valor
FROM tblPets
GROUP BY Raca, Valor
HAVING SUM(Valor) > 1800
ORDER BY Valor ASC;


-- =======================================================
-- 13) FUNÇÕES NUMÉRICAS E DE DATA
-- =======================================================

-- Exemplos de cálculos matemáticos
SELECT 500/2 AS valor;
SELECT POWER(2,2) AS valor;
SELECT SQRT(35) AS valor;
SELECT PI() AS valorPI;

-- Mostrar data e hora atual do servidor
SELECT GETDATE() AS data_hora_atual;


-- =======================================================
-- 14) VIEW, BACKUP E TRIGGER
-- =======================================================

-- Criação de uma VIEW para simplificar consultas
CREATE VIEW minhaView AS
SELECT p.Apelido, p.Raca, p.Valor, a.Nome as Dono
FROM tblAlunos AS a, tblPets AS p
WHERE p.IdAluno = a.IdAluno;

-- Backup de banco de dados (necessário permissões de sysadmin)
BACKUP DATABASE escola2
TO DISK = 'D:\bd\backup\backup1.bak';

-- Criar trigger para disparar mensagem quando houver alteração na tabela pets
CREATE TRIGGER aviso
ON tblPets
AFTER INSERT, UPDATE, DELETE  
AS RAISERROR ('Avisar o usuario', 16, 10);

-- Testar o trigger
INSERT INTO tblPets ([Apelido],[Raca],[Valor]) VALUES('DOG5', 'FILA', 2300.00);


-- =======================================================
-- 15) USUÁRIO/ROLE EXCLUSIVO PARA BACKUP DO BANCO "cafe"
-- =======================================================
-- Observação:
--  - Para gravar o arquivo .BAK, a conta do serviço do SQL Server
--    precisa ter permissão NTFS na pasta de destino.

USE master;
GO

-- 15.1) Criar LOGIN no servidor (substitua a senha por uma forte)
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_backup_cafe')
BEGIN
    CREATE LOGIN login_backup_cafe WITH PASSWORD = 'Troque_Esta_Senha!123', CHECK_POLICY = ON, CHECK_EXPIRATION = ON;
END
GO

-- 15.2) Criar USER no banco "cafe" para esse login
USE cafe;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'user_backup_cafe')
BEGIN
    CREATE USER user_backup_cafe FOR LOGIN login_backup_cafe;
END
GO

-- 15.3) Criar uma ROLE somente para backup e conceder permissões de BACKUP
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'db_backuponly')
BEGIN
    CREATE ROLE db_backuponly AUTHORIZATION dbo;
END
GO

-- Conceder apenas as permissões necessárias para backup neste banco
GRANT BACKUP DATABASE TO db_backuponly;
GRANT BACKUP LOG      TO db_backuponly;
GO

-- 15.4) Adicionar o usuário à role de backup
EXEC sp_addrolemember @rolename = N'db_backuponly', @membername = N'user_backup_cafe';
GO

-- (Opcional de endurecimento) Garantir que o usuário não esteja em roles amplas:
-- EXEC sp_droprolemember 'db_datareader',  'user_backup_cafe';
-- EXEC sp_droprolemember 'db_datawriter',  'user_backup_cafe';
-- EXEC sp_droprolemember 'db_owner',       'user_backup_cafe';
-- (Use apenas se tiver certeza de que ele não deve estar nessas roles.)
GO

-- 15.5) Exemplo de uso: realizar backup do banco "cafe"
-- (Execute com o login_backup_cafe e a pasta com permissão NTFS)
-- BACKUP DATABASE cafe TO DISK = 'D:\bd\backup\cafe_full_YYYYMMDD.bak' WITH INIT, STATS = 10;
-- BACKUP LOG cafe TO DISK = 'D:\bd\backup\cafe_log_YYYYMMDD.trn' WITH INIT, STATS = 10;
GO


-- =======================================================
-- 16) CONSULTA: TAMANHO DO BANCO DE DADOS "cafe"
-- =======================================================
-- Mostra tamanho por tipo de arquivo e total (MB/GB)
USE master;
GO
SELECT
    d.name                                            AS database_name,
    mf.type_desc                                      AS file_type,
    SUM(mf.size) * 8.0 / 1024                         AS size_mb,
    SUM(mf.size) * 8.0 / 1024 / 1024                  AS size_gb
FROM sys.databases AS d
JOIN sys.master_files AS mf
    ON d.database_id = mf.database_id
WHERE d.name = N'cafe'
GROUP BY d.name, mf.type_desc
WITH ROLLUP;  -- a linha de ROLLUP mostra o total geral
GO


-- =======================================================
-- 17) CONSULTA: TABELAS, COLUNAS E TIPOS DE DADOS (BANCO "cafe")
-- =======================================================
USE cafe;
GO
SELECT
    s.name                              AS schema_name,
    t.name                              AS table_name,
    c.column_id,
    c.name                              AS column_name,
    ty.name                             AS data_type,
    c.max_length,
    c.precision,
    c.scale,
    c.is_nullable,
    CASE WHEN ic.index_column_id IS NOT NULL THEN 1 ELSE 0 END AS is_indexed,
    CASE WHEN c.is_identity = 1 THEN 1 ELSE 0 END AS is_identity
FROM sys.tables t
JOIN sys.schemas s       ON s.schema_id = t.schema_id
JOIN sys.columns c       ON c.object_id = t.object_id
JOIN sys.types ty        ON ty.user_type_id = c.user_type_id
LEFT JOIN sys.indexes i  ON i.object_id = t.object_id AND i.is_hypothetical = 0
LEFT JOIN sys.index_columns ic
    ON ic.object_id = t.object_id AND ic.column_id = c.column_id AND ic.index_id = i.index_id
WHERE t.is_ms_shipped = 0
ORDER BY s.name, t.name, c.column_id;
GO


-- =======================================================
-- 18) CONSULTAS DE RECURSOS: CPU, MEMÓRIA E DISCO
--      (Visão prática por banco; execute como sysadmin para melhor cobertura)
-- =======================================================

-- 18.1) CPU por banco (acumulado pelas últimas execuções em cache)
-- Observação: total_worker_time está em microssegundos (µs)
USE master;
GO
SELECT
    DB_NAME(st.dbid)                                            AS database_name,
    SUM(qs.total_worker_time) / 1000.0                          AS total_cpu_ms,
    SUM(qs.execution_count)                                     AS exec_count,
    (SUM(qs.total_worker_time) / NULLIF(SUM(qs.execution_count),0)) / 1000.0 AS avg_cpu_ms_per_exec
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE st.dbid IS NOT NULL
GROUP BY DB_NAME(st.dbid)
ORDER BY total_cpu_ms DESC;
GO

-- 18.2) Memória (Buffer Pool) por banco
-- Mostra quanto cada banco ocupa no Buffer Pool (MB)
-- Obs.: exclui ResourceDB (database_id = 32767)
SELECT
    DB_NAME(database_id)                 AS database_name,
    COUNT(*) * 8.0 / 1024                AS buffer_pool_mb
FROM sys.dm_os_buffer_descriptors
WHERE database_id <> 32767
GROUP BY database_id
ORDER BY buffer_pool_mb DESC;
GO

-- 18.3) Disco (I/O) por banco/arquivo
-- Leitura/Escrita, bytes e latência média (ms) por arquivo
SELECT
    DB_NAME(mf.database_id)                          AS database_name,
    mf.type_desc                                     AS file_type,
    mf.physical_name,
    vfs.num_of_reads,
    vfs.num_of_writes,
    vfs.num_of_bytes_read,
    vfs.num_of_bytes_written,
    CASE WHEN (vfs.num_of_reads) = 0 THEN 0
         ELSE (vfs.io_stall_read_ms * 1.0 / vfs.num_of_reads) END  AS avg_read_ms,
    CASE WHEN (vfs.num_of_writes) = 0 THEN 0
         ELSE (vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes) END AS avg_write_ms
FROM sys.dm_io_virtual_file_stats(NULL,NULL) AS vfs
JOIN sys.master_files AS mf
  ON mf.database_id = vfs.database_id AND mf.file_id = vfs.file_id
ORDER BY database_name, file_type;
GO

-- (Opcional) Visão resumida de I/O por banco
SELECT
    DB_NAME(mf.database_id)                          AS database_name,
    SUM(vfs.num_of_reads)                            AS total_reads,
    SUM(vfs.num_of_writes)                           AS total_writes,
    SUM(vfs.num_of_bytes_read)                       AS total_bytes_read,
    SUM(vfs.num_of_bytes_written)                    AS total_bytes_written
FROM sys.dm_io_virtual_file_stats(NULL,NULL) AS vfs
JOIN sys.master_files AS mf
  ON mf.database_id = vfs.database_id AND mf.file_id = vfs.file_id
GROUP BY mf.database_id
ORDER BY total_bytes_read + total_bytes_written DESC;
GO

-- 18A) Versões “safe” (apenas o banco cafe)
-- =======================================================
-- versão "safe" somente o banco cafe
-- CPU SOMENTE DO BANCO "cafe"
--  - total_worker_time em µs (convertido para ms)
--  - média por execução
-- =======================================================
USE master;
GO
SELECT
    DB_NAME(st.dbid) AS database_name,
    SUM(qs.total_worker_time) / 1000.0 AS total_cpu_ms,
    SUM(qs.execution_count)            AS exec_count,
    (SUM(qs.total_worker_time) / NULLIF(SUM(qs.execution_count),0)) / 1000.0 AS avg_cpu_ms_per_exec
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
WHERE st.dbid = DB_ID(N'cafe')
GROUP BY DB_NAME(st.dbid)
ORDER BY total_cpu_ms DESC;
GO


-- =======================================================
-- MEMÓRIA (BUFFER POOL) SOMENTE DO BANCO "cafe"
--  - quantidade aproximada ocupada no buffer pool (MB)
-- =======================================================
SELECT
    DB_NAME(database_id)  AS database_name,
    COUNT(*) * 8.0 / 1024 AS buffer_pool_mb
FROM sys.dm_os_buffer_descriptors
WHERE database_id = DB_ID(N'cafe')
GROUP BY database_id
ORDER BY buffer_pool_mb DESC;
GO


-- =======================================================
-- DISCO (I/O) SOMENTE DO BANCO "cafe"
--  - leituras/escritas, bytes e latência média (ms) por arquivo
-- =======================================================
SELECT
    DB_NAME(mf.database_id) AS database_name,
    mf.type_desc            AS file_type,
    mf.physical_name,
    vfs.num_of_reads,
    vfs.num_of_writes,
    vfs.num_of_bytes_read,
    vfs.num_of_bytes_written,
    CASE WHEN vfs.num_of_reads  = 0 THEN 0 ELSE (vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads)  END AS avg_read_ms,
    CASE WHEN vfs.num_of_writes = 0 THEN 0 ELSE (vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes) END AS avg_write_ms
FROM sys.dm_io_virtual_file_stats(DB_ID(N'cafe'), NULL) AS vfs
JOIN sys.master_files AS mf
  ON mf.database_id = vfs.database_id AND mf.file_id = vfs.file_id
ORDER BY file_type, mf.physical_name;
GO


-- 19) Mini-Dashboard consolidado (CPU, Memória, Disco + Tamanho)
-- =======================================================
-- DASHBOARD SNAPSHOT DO BANCO "cafe"
--  - Info geral + tamanho
--  - CPU agregada
--  - Memória (Buffer Pool)
--  - Disco (I/O por arquivo)
-- =======================================================
USE master;
GO

IF OBJECT_ID('dbo.usp_cafe_health_snapshot') IS NOT NULL
    DROP PROCEDURE dbo.usp_cafe_health_snapshot;
GO

CREATE PROCEDURE dbo.usp_cafe_health_snapshot
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @dbid INT = DB_ID(N'cafe');

    ------------------------------------------------------
    -- (1) INFO GERAL E TAMANHO DO BANCO
    ------------------------------------------------------
    ;WITH tamanhos AS
    (
        SELECT
            mf.type_desc                                      AS file_type,
            SUM(mf.size) * 8.0 / 1024                         AS size_mb,
            SUM(mf.size) * 8.0 / 1024 / 1024                  AS size_gb
        FROM sys.master_files mf
        WHERE mf.database_id = @dbid
        GROUP BY mf.type_desc
    )
    SELECT
        DB_NAME(@dbid)                                        AS database_name,
        SYSDATETIME()                                         AS snapshot_datetime,
        (SELECT COALESCE(SUM(size_mb),0) FROM tamanhos)       AS total_size_mb,
        (SELECT COALESCE(SUM(size_gb),0) FROM tamanhos)       AS total_size_gb,
        (SELECT COALESCE(SUM(CASE WHEN file_type='ROWS'     THEN size_mb END),0) FROM tamanhos) AS data_size_mb,
        (SELECT COALESCE(SUM(CASE WHEN file_type='LOG'      THEN size_mb END),0) FROM tamanhos) AS log_size_mb
    ;

    ------------------------------------------------------
    -- (2) CPU AGREGADA (últimos planos em cache)
    ------------------------------------------------------
    SELECT
        DB_NAME(st.dbid) AS database_name,
        SUM(qs.total_worker_time) / 1000.0 AS total_cpu_ms,
        SUM(qs.execution_count)            AS exec_count,
        (SUM(qs.total_worker_time) / NULLIF(SUM(qs.execution_count),0)) / 1000.0 AS avg_cpu_ms_per_exec
    FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
    WHERE st.dbid = @dbid
    GROUP BY st.dbid;

    ------------------------------------------------------
    -- (3) MEMÓRIA (BUFFER POOL) DO BANCO
    ------------------------------------------------------
    SELECT
        DB_NAME(database_id)  AS database_name,
        COUNT(*) * 8.0 / 1024 AS buffer_pool_mb
    FROM sys.dm_os_buffer_descriptors
    WHERE database_id = @dbid
    GROUP BY database_id;

    ------------------------------------------------------
    -- (4) DISCO (I/O) POR ARQUIVO
    ------------------------------------------------------
    SELECT
        DB_NAME(mf.database_id) AS database_name,
        mf.type_desc            AS file_type,
        mf.physical_name,
        vfs.num_of_reads,
        vfs.num_of_writes,
        vfs.num_of_bytes_read,
        vfs.num_of_bytes_written,
        CASE WHEN vfs.num_of_reads  = 0 THEN 0 ELSE (vfs.io_stall_read_ms  * 1.0 / vfs.num_of_reads)  END AS avg_read_ms,
        CASE WHEN vfs.num_of_writes = 0 THEN 0 ELSE (vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes) END AS avg_write_ms
    FROM sys.dm_io_virtual_file_stats(@dbid, NULL) AS vfs
    JOIN sys.master_files AS mf
      ON mf.database_id = vfs.database_id AND mf.file_id = vfs.file_id
    ORDER BY file_type, mf.physical_name;

END
GO

-- Executar o dashboard
EXEC dbo.usp_cafe_health_snapshot;
GO
