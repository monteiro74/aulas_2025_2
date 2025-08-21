-- Cria um novo banco de dados chamado "aula3"
CREATE DATABASE aula3;

-- Lista todos os bancos de dados disponíveis
SHOW DATABASES;

-- Seleciona o banco "aula3" para ser usado
USE aula3;

-- Mostra os processos ativos no servidor MySQL (consultas em execução, conexões etc.)
SHOW PROCESSLIST;

-- Mostra os privilégios/ permissões concedidos ao usuário atual
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
SELECT SCHEMA_NAME 'aula3', 
       default_character_set_name 'charset', 
       DEFAULT_COLLATION_NAME 'collation' 
FROM information_schema.SCHEMATA;

-- Mostra informações detalhadas sobre as tabelas (se houver)
SHOW TABLE STATUS;

-- Lista todas as tabelas do banco em uso
SHOW TABLES;

-- Cria tabela "pet" para armazenar animais de estimação
CREATE TABLE pet (
  apelido VARCHAR(20),
  dono VARCHAR(20),
  especie VARCHAR(20),
  sexo CHAR(1),
  nascimento DATE,
  morte DATE
);

-- Lista as tabelas novamente para verificar criação
SHOW TABLES;

-- Cria tabela "pessoas" para armazenar dados pessoais
CREATE TABLE pessoas (
  IDPessoa int,
  Nome varchar(100),
  Nascimento date,
  Bairro varchar(50),
  UF varchar(2),
  Cidade varchar(255)
);

-- Exibe a estrutura da tabela "pessoas"
DESCRIBE pessoas;

-- Exibe a estrutura da tabela "pet"
DESCRIBE pet;

-- Lista novamente as tabelas criadas
SHOW TABLES;

-- Mostra as colunas da tabela "pessoas"
SHOW COLUMNS FROM pessoas;

-- Insere registros na tabela "pet"
INSERT INTO pet (apelido, dono, especie, sexo, nascimento) 
VALUES ('REX','ANA','CAO','M','2010-10-26');
INSERT INTO pet (apelido, dono, especie, sexo, nascimento) 
VALUES ('SNOOPY','BOB','CAO','M','2014-11-22');
INSERT INTO pet (apelido, dono, especie, sexo, nascimento) 
VALUES ('GARFIELD','CLARA','GATO','M','2013-12-27');

-- Insere registros na tabela "pessoas"
INSERT INTO pessoas (IDPessoa, Nome, Nascimento, Bairro, UF, Cidade)
VALUES ('1','ANA','2015-10-23','Centro','SP','Rancharia');
INSERT INTO pessoas (IDPessoa, Nome, Nascimento, Bairro, UF, Cidade) 
VALUES ('2','BOB','2015-11-25','Porto','MT','Cuiaba');
INSERT INTO pessoas (IDPessoa, Nome, Nascimento, Bairro, UF, Cidade) 
VALUES ('3','Clara','2014-12-21','Porto','MT','Vacaria');

-- Seleciona todos os registros da tabela "pet"
SELECT * FROM pet;

-- Seleciona apenas apelido e dono dos pets
SELECT apelido, dono FROM pet;

-- Filtra os pets cujo dono é 'ANA'
SELECT apelido, sexo, nascimento FROM pet WHERE dono='ANA';

-- Seleciona pets nascidos após 26/10/2010
SELECT apelido, nascimento FROM pet WHERE nascimento > '2010-10-26';

-- Filtra pets do dono 'BOB' e do sexo masculino
SELECT * FROM pet WHERE dono='BOB' AND sexo='M';

-- Atualiza a espécie e data de morte do pet chamado 'REX'
UPDATE pet SET especie='LAGARTO', morte='2016-01-27' WHERE apelido='REX';

-- Verifica os dados atualizados
SELECT * FROM pet;

-- Deleta o registro do pet 'REX'
DELETE FROM pet WHERE apelido='REX';

-- Mostra os pets restantes
SELECT * FROM pet;

-- Deleta todos os registros da tabela "pet"
DELETE FROM pet;

-- Verifica tabela "pet" (agora vazia)
SELECT * FROM pet;

-- Remove completamente a tabela "pet"
DROP TABLE pet;

-- Lista tabelas (para confirmar remoção de "pet")
SHOW TABLES;

-- Cria tabela "dependentes"
CREATE TABLE dependentes(
  IDDependente int,
  NomeD varchar(100)
);

-- Lista tabelas criadas
SHOW TABLES;

-- Adiciona coluna IDPessoa na tabela "dependentes"
ALTER TABLE dependentes ADD IDPessoa Int;

-- Mostra colunas da tabela "dependentes"
SHOW COLUMNS FROM dependentes;

-- Descreve a tabela "dependentes"
DESCRIBE dependentes;

-- Adiciona chave estrangeira vinculando dependentes a pessoas
-- (cada dependente deve estar associado a um IDPessoa existente)
ALTER TABLE dependentes 
ADD FOREIGN KEY (IDPessoa) REFERENCES pessoas(IDPessoa);

-- Mostra novamente as colunas da tabela "dependentes"
SHOW COLUMNS FROM dependentes;

-- Descreve a tabela dependentes (agora com chave estrangeira)
DESCRIBE dependentes;

-- Cria índice na tabela "pessoas" para a coluna IDPessoa
ALTER TABLE pessoas ADD INDEX IDPessoa_idx (IDPessoa);

-- Cria índice na tabela "pessoas" para a coluna UF
ALTER TABLE pessoas ADD INDEX UF_idx (UF);

-- Verifica a tabela "pessoas" após criação dos índices
DESCRIBE pessoas;

-- Insere dependentes vinculados a pessoas existentes
INSERT INTO dependentes (IDDependente, NomeD, IDPessoa) VALUES ('1','Filho1','2');
INSERT INTO dependentes (IDDependente, NomeD, IDPessoa) VALUES ('2','Filho2','2');

-- Lista todos os dependentes
SELECT * FROM dependentes;

-- Tenta inserir dependente com IDPessoa inexistente (5) → erro por integridade referencial
INSERT INTO dependentes (IDDependente, NomeD, IDPessoa) VALUES ('3','Filho3','5');

-- Mostra os dependentes novamente
SELECT * FROM dependentes;
