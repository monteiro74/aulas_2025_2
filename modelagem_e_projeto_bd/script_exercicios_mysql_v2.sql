-- =======================================================
-- 1) CRIAÇÃO DO BANCO DE DADOS E CONFIGURAÇÃO
-- =======================================================

-- Cria um novo banco de dados chamado "aula3" com charset padrão utf8mb4
CREATE DATABASE IF NOT EXISTS aula3
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

-- Lista todos os bancos de dados disponíveis
SHOW DATABASES;

-- Seleciona o banco "aula3" para ser usado
USE aula3;

-- =======================================================
-- 2) CONSULTAS DE INFORMAÇÃO DO SERVIDOR
-- =======================================================

-- Mostra os processos ativos no servidor MySQL
-- (consultas em execução, conexões abertas, usuários etc.)
SHOW PROCESSLIST;

-- Mostra os privilégios/permissões concedidos ao usuário atual
SHOW GRANTS;

-- Lista todas as collations (regras de ordenação de caracteres) suportadas
SHOW COLLATION;

-- Lista todas as collations do charset utf8mb4
SHOW COLLATION WHERE Charset = 'utf8mb4';

-- Mostra apenas a collation padrão
SHOW COLLATION WHERE `Default` = 'Yes';

-- Consulta o charset padrão do banco "aula3"
SELECT default_character_set_name 
FROM information_schema.SCHEMATA  
WHERE schema_name = "aula3";

-- Exibe a variável global com o charset do banco em uso
SHOW VARIABLES LIKE "character_set_database";

-- Mostra informações sobre charset e collation dos schemas existentes
SELECT SCHEMA_NAME       AS schema_name, 
       default_character_set_name AS charset, 
       DEFAULT_COLLATION_NAME     AS collation 
FROM information_schema.SCHEMATA;

-- =======================================================
-- 3) CRIAÇÃO DE TABELAS BÁSICAS
-- =======================================================

-- Mostra informações sobre tabelas (se houver)
SHOW TABLE STATUS;

-- Lista todas as tabelas do banco em uso
SHOW TABLES;

-- Cria tabela "pet" para armazenar animais de estimação
CREATE TABLE pet (
  apelido    VARCHAR(20) NOT NULL,
  dono       VARCHAR(20) NOT NULL,
  especie    VARCHAR(20) NOT NULL,
  sexo       CHAR(1),
  nascimento DATE,
  morte      DATE
);

-- Cria tabela "pessoas" para armazenar dados pessoais
CREATE TABLE pessoas (
  IDPessoa    INT AUTO_INCREMENT PRIMARY KEY,
  Nome        VARCHAR(100) NOT NULL,
  Nascimento  DATE,
  Bairro      VARCHAR(50),
  UF          CHAR(2),
  Cidade      VARCHAR(255)
);

-- Verifica estrutura das tabelas criadas
DESCRIBE pessoas;
DESCRIBE pet;

-- Lista novamente as tabelas criadas
SHOW TABLES;

-- =======================================================
-- 4) INSERÇÃO DE DADOS DE EXEMPLO
-- =======================================================

-- Insere registros na tabela "pet"
INSERT INTO pet (apelido, dono, especie, sexo, nascimento) 
VALUES 
('REX','ANA','CAO','M','2010-10-26'),
('SNOOPY','BOB','CAO','M','2014-11-22'),
('GARFIELD','CLARA','GATO','M','2013-12-27'),
('BIDU','ANA','CAO','M','2011-05-10'),
('TOM','CLARA','GATO','M','2012-07-15'),
('LASSIE','BOB','CAO','F','2016-08-01'),
('NINA','ANA','CACHORRA','F','2018-03-20'),
('MIMI','CLARA','GATA','F','2019-06-11'),
('BOLINHA','DANIEL','COELHO','M','2020-02-28'),
('SPIKE','DANIELA','CAO','M','2017-09-09'),
('PRETA','ANA','GATA','F','2015-11-05'),
('MAX','BOB','CAO','M','2013-04-18'),
('LUNA','CLARA','GATA','F','2021-01-23');

-- Insere registros na tabela "pessoas"
INSERT INTO pessoas (Nome, Nascimento, Bairro, UF, Cidade)
VALUES
('ANA','2015-10-23','Centro','SP','Rancharia'),
('BOB','2015-11-25','Porto','MT','Cuiaba'),
('CLARA','2014-12-21','Porto','MT','Vacaria'),
('DANIEL','2010-02-15','Centro','PR','Curitiba'),
('DANIELA','2009-08-09','Boa Vista','MG','Belo Horizonte'),
('PAULO','2005-12-30','Jardins','SP','São Paulo'),
('MARTA','2007-04-11','Santa Luzia','RJ','Rio de Janeiro'),
('CARLOS','2012-07-07','Cidade Alta','MT','Cuiaba'),
('FERNANDA','2011-03-18','Centro','RS','Porto Alegre'),
('RAFAEL','2013-05-22','Coqueiros','SC','Florianópolis'),
('LUCAS','2008-09-29','São José','GO','Goiânia'),
('JULIA','2016-11-14','Bela Vista','SP','Campinas'),
('RODRIGO','2006-06-06','Santa Cruz','BA','Salvador');


-- =======================================================
-- 5) CONSULTAS BÁSICAS
-- =======================================================

-- Seleciona todos os registros da tabela "pet"
SELECT * FROM pet;

-- Seleciona apenas apelido e dono dos pets
SELECT apelido, dono FROM pet;

-- Filtra os pets cujo dono é 'ANA'
SELECT apelido, sexo, nascimento 
FROM pet 
WHERE dono='ANA';

-- Seleciona pets nascidos após 26/10/2010
SELECT apelido, nascimento 
FROM pet 
WHERE nascimento > '2010-10-26';

-- Filtra pets do dono 'BOB' e do sexo masculino
SELECT * 
FROM pet 
WHERE dono='BOB' AND sexo='M';

-- =======================================================
-- 6) UPDATE, DELETE E DROP
-- =======================================================

-- Atualiza a espécie e data de morte do pet chamado 'REX'
UPDATE pet 
SET especie='LAGARTO', morte='2016-01-27' 
WHERE apelido='REX';

-- Verifica dados atualizados
SELECT * FROM pet;

-- Deleta o registro do pet 'REX'
DELETE FROM pet WHERE apelido='REX';

-- Deleta todos os registros da tabela "pet"
DELETE FROM pet;

-- Remove completamente a tabela "pet"
DROP TABLE pet;

-- Confirma a exclusão
SHOW TABLES;

-- =======================================================
-- 7) RELACIONAMENTOS E CHAVES ESTRANGEIRAS
-- =======================================================

-- Cria tabela "dependentes"
CREATE TABLE dependentes(
  IDDependente INT AUTO_INCREMENT PRIMARY KEY,
  NomeD        VARCHAR(100) NOT NULL,
  IDPessoa     INT,
  FOREIGN KEY (IDPessoa) REFERENCES pessoas(IDPessoa)
);

-- Estrutura da tabela dependentes
DESCRIBE dependentes;

-- Cria índice na tabela "pessoas" para a coluna UF
ALTER TABLE pessoas ADD INDEX UF_idx (UF);

-- =======================================================
-- 8) INSERÇÃO E TESTE DE INTEGRIDADE REFERENCIAL
-- =======================================================

-- Insere dependentes vinculados a pessoas existentes
INSERT INTO dependentes (NomeD, IDPessoa) VALUES ('Filho1',2),('Filho2',2);

-- Lista todos os dependentes
SELECT * FROM dependentes;

-- Tentativa de inserir dependente com IDPessoa inexistente → gera erro
-- INSERT INTO dependentes (NomeD, IDPessoa) VALUES ('Filho3',5);

-- =======================================================
-- 9) CONSULTAS FINAIS DE VERIFICAÇÃO
-- =======================================================

-- Mostra dependentes
SELECT * FROM dependentes;

-- Mostra pessoas e dependentes (JOIN)
SELECT p.Nome, d.NomeD
FROM pessoas p
LEFT JOIN dependentes d ON p.IDPessoa = d.IDPessoa;




-- =======================================================
-- 10) Exemplos de TRIGGERS (auditoria básica de pet)
-- =======================================================


-- =======================================================
-- A) TRIGGERS DE EXEMPLO (AUDITORIA DA TABELA pet)
--  - Cria tabela de auditoria
--  - AFTER INSERT: registra novas linhas
--  - BEFORE UPDATE: normaliza dados e registra mudança
--  - AFTER DELETE: registra exclusões
-- =======================================================

-- Tabela de auditoria
CREATE TABLE IF NOT EXISTS audit_pet (
  id_audit     BIGINT AUTO_INCREMENT PRIMARY KEY,
  operacao     ENUM('INSERT','UPDATE','DELETE') NOT NULL,
  apelido_old  VARCHAR(20) NULL,
  dono_old     VARCHAR(20) NULL,
  especie_old  VARCHAR(20) NULL,
  sexo_old     CHAR(1) NULL,
  nascimento_old DATE NULL,
  morte_old      DATE NULL,
  apelido_new  VARCHAR(20) NULL,
  dono_new     VARCHAR(20) NULL,
  especie_new  VARCHAR(20) NULL,
  sexo_new     CHAR(1) NULL,
  nascimento_new DATE NULL,
  morte_new      DATE NULL,
  user_exec    VARCHAR(100) NOT NULL DEFAULT (CURRENT_USER()),
  ts_exec      TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- (Opcional) adicionar colunas de auditoria na pet (se quiser carimbar UPDATE)
ALTER TABLE pet
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- Troca de delimitador para triggers
DELIMITER $$

-- AFTER INSERT: registra nova linha
CREATE TRIGGER trg_pet_ai
AFTER INSERT ON pet
FOR EACH ROW
BEGIN
  INSERT INTO audit_pet
    (operacao, apelido_new, dono_new, especie_new, sexo_new, nascimento_new, morte_new)
  VALUES
    ('INSERT', NEW.apelido, NEW.dono, NEW.especie, NEW.sexo, NEW.nascimento, NEW.morte);
END$$

-- BEFORE UPDATE: normaliza especie/sexo e registra mudança
CREATE TRIGGER trg_pet_bu
BEFORE UPDATE ON pet
FOR EACH ROW
BEGIN
  -- Normalização simples (maiúsculas)
  SET NEW.especie = UPPER(NEW.especie);
  SET NEW.sexo    = UPPER(NEW.sexo);
  SET NEW.updated_at = CURRENT_TIMESTAMP;

  INSERT INTO audit_pet
    (operacao,
     apelido_old, dono_old, especie_old, sexo_old, nascimento_old, morte_old,
     apelido_new, dono_new, especie_new, sexo_new, nascimento_new, morte_new)
  VALUES
    ('UPDATE',
     OLD.apelido, OLD.dono, OLD.especie, OLD.sexo, OLD.nascimento, OLD.morte,
     NEW.apelido, NEW.dono, NEW.especie, NEW.sexo, NEW.nascimento, NEW.morte);
END$$

-- AFTER DELETE: registra linha excluída
CREATE TRIGGER trg_pet_ad
AFTER DELETE ON pet
FOR EACH ROW
BEGIN
  INSERT INTO audit_pet
    (operacao, apelido_old, dono_old, especie_old, sexo_old, nascimento_old, morte_old)
  VALUES
    ('DELETE', OLD.apelido, OLD.dono, OLD.especie, OLD.sexo, OLD.nascimento, OLD.morte);
END$$

DELIMITER ;




-- =======================================================
-- 11) CONTA DE BACKUP PARA O BANCO aula3
--    (pensada para mysqldump lógico)
-- =======================================================

-- Cria usuário de backup (ajuste o host conforme seu cenário: '%' ou 'localhost')
CREATE USER IF NOT EXISTS 'backup_aula3'@'localhost'
  IDENTIFIED BY 'Troque_Esta_Senha!123';

-- Permissões no schema aula3 (dump completo e consistente)
GRANT SELECT, SHOW VIEW, TRIGGER, LOCK TABLES, EVENT
  ON aula3.* TO 'backup_aula3'@'localhost';

-- Permissões globais úteis para operações de flush/diagnóstico em backup
GRANT RELOAD, PROCESS
  ON *.* TO 'backup_aula3'@'localhost';

FLUSH PRIVILEGES;

-- Exemplo de uso (linha de comando):
-- mysqldump -u backup_aula3 -p --single-transaction --routines --triggers aula3 > aula3_backup.sql



-- =======================================================
-- 12) TAMANHO DO BANCO aula3 (dados, índices e total)
-- =======================================================
SELECT
  t.table_schema                                     AS schema_name,
  ROUND(SUM(t.data_length)/1024/1024, 2)            AS data_mb,
  ROUND(SUM(t.index_length)/1024/1024, 2)           AS index_mb,
  ROUND(SUM(t.data_length + t.index_length)/1024/1024, 2) AS total_mb,
  COUNT(*)                                          AS tables_count
FROM information_schema.TABLES t
WHERE t.table_schema = 'aula3'
GROUP BY t.table_schema;


-- =======================================================
-- 13) TABELAS E COLUNAS (TIPOS, NULLABILITY, DEFAULT, EXTRA)
-- =======================================================
SELECT
  c.table_name,
  c.ordinal_position,
  c.column_name,
  c.column_type,
  c.is_nullable,
  c.column_default,
  c.column_key,
  c.extra
FROM information_schema.COLUMNS c
WHERE c.table_schema = 'aula3'
ORDER BY c.table_name, c.ordinal_position;


-- =======================================================
-- 14) RESUMO VIA SYS (SE DISPONÍVEL)
-- =======================================================

-- Visão geral por host (threads/conexões/latências)
SELECT * FROM sys.host_summary;

-- Memória agregada (buffers, caches, etc.)
SELECT * FROM sys.memory_global_total;

-- Top arquivos por I/O (bytes) – indica "quentez" de disco
SELECT file, total, write_pct, read_pct
FROM sys.io_global_by_file_by_bytes
ORDER BY total DESC
LIMIT 20;

-- (Opcional) Visão por schema/tabela (leituras, gravações, latências)
SELECT *
FROM sys.schema_table_statistics
WHERE rows_fetched + rows_read + rows_inserted + rows_updated + rows_deleted > 0
ORDER BY (rows_read + rows_fetched + rows_inserted + rows_updated + rows_deleted) DESC
LIMIT 20;
