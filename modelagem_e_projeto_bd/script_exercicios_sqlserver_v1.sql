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
