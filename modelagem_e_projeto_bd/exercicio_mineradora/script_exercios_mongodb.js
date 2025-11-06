// =======================================================
// 1) SELEÇÃO DO BANCO E INFORMAÇÕES BÁSICAS
// =======================================================

// Em MongoDB, o comando use troca o "database" em uso.
// Se o banco ainda não existir, ele será criado quando
// gravarmos a primeira coleção nele.
use('aula3')

// Lista todos os bancos existentes no servidor MongoDB
show dbs

// Lista as coleções (equivalente às tabelas) do banco atual
show collections

// Estatísticas gerais do banco "aula3":
// - tamanho de dados, armazenamento, número de coleções, etc.
db.stats()

// =======================================================
// 2) CRIAÇÃO DAS COLEÇÕES (E ESQUEMA BÁSICO)
// =======================================================

// Em MongoDB não precisamos criar a coleção antes de inserir,
// mas aqui fazemos explicitamente e adicionamos validação de esquema,
// para ficar mais próximo do mundo relacional.

// Cria a coleção "pessoas" com validação simples de campos
db.createCollection("pessoas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: [ "IDPessoa", "Nome" ],
      properties: {
        IDPessoa: {
          bsonType: "int",
          description: "Identificador numérico da pessoa (similar a PK)"
        },
        Nome: {
          bsonType: "string",
          description: "Nome da pessoa"
        },
        Nascimento: {
          bsonType: [ "date", "null" ],
          description: "Data de nascimento (opcional)"
        },
        Bairro: {
          bsonType: [ "string", "null" ]
        },
        UF: {
          bsonType: [ "string", "null" ]
        },
        Cidade: {
          bsonType: [ "string", "null" ]
        }
      }
    }
  },
  validationLevel: "moderate"
})

// Cria a coleção "pet" (sem validação rígida para simplificar)
db.createCollection("pet")

// Cria a coleção "dependentes" com validação simples
// (não há FK real, mas validamos o tipo do campo IDPessoa)
db.createCollection("dependentes", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: [ "IDDependente", "NomeD", "IDPessoa" ],
      properties: {
        IDDependente: { bsonType: "int" },
        NomeD:        { bsonType: "string" },
        IDPessoa:     { bsonType: "int" } // referência lógica para pessoas.IDPessoa
      }
    }
  },
  validationLevel: "moderate"
})

// Confere as coleções criadas
show collections

// =======================================================
// 3) INSERÇÃO DE DADOS DE EXEMPLO (PESSOAS E PETS)
// =======================================================

// Em MongoDB, cada documento tem um _id gerado automaticamente,
// mas podemos ter também um campo IDPessoa para simular a PK.

// Insere pessoas (equivalente aos INSERTs do MySQL)
db.pessoas.insertMany([
  { IDPessoa: 1, Nome: 'ANA',     Nascimento: ISODate('2015-10-23'), Bairro: 'Centro',     UF: 'SP', Cidade: 'Rancharia' },
  { IDPessoa: 2, Nome: 'BOB',     Nascimento: ISODate('2015-11-25'), Bairro: 'Porto',      UF: 'MT', Cidade: 'Cuiaba' },
  { IDPessoa: 3, Nome: 'CLARA',   Nascimento: ISODate('2014-12-21'), Bairro: 'Porto',      UF: 'MT', Cidade: 'Vacaria' },
  { IDPessoa: 4, Nome: 'DANIEL',  Nascimento: ISODate('2010-02-15'), Bairro: 'Centro',     UF: 'PR', Cidade: 'Curitiba' },
  { IDPessoa: 5, Nome: 'DANIELA', Nascimento: ISODate('2009-08-09'), Bairro: 'Boa Vista',  UF: 'MG', Cidade: 'Belo Horizonte' },
  { IDPessoa: 6, Nome: 'PAULO',   Nascimento: ISODate('2005-12-30'), Bairro: 'Jardins',    UF: 'SP', Cidade: 'São Paulo' },
  { IDPessoa: 7, Nome: 'MARTA',   Nascimento: ISODate('2007-04-11'), Bairro: 'Santa Luzia',UF: 'RJ', Cidade: 'Rio de Janeiro' },
  { IDPessoa: 8, Nome: 'CARLOS',  Nascimento: ISODate('2012-07-07'), Bairro: 'Cidade Alta',UF: 'MT', Cidade: 'Cuiaba' },
  { IDPessoa: 9, Nome: 'FERNANDA',Nascimento: ISODate('2011-03-18'), Bairro: 'Centro',     UF: 'RS', Cidade: 'Porto Alegre' },
  { IDPessoa:10, Nome: 'RAFAEL',  Nascimento: ISODate('2013-05-22'), Bairro: 'Coqueiros',  UF: 'SC', Cidade: 'Florianópolis' },
  { IDPessoa:11, Nome: 'LUCAS',   Nascimento: ISODate('2008-09-29'), Bairro: 'São José',   UF: 'GO', Cidade: 'Goiânia' },
  { IDPessoa:12, Nome: 'JULIA',   Nascimento: ISODate('2016-11-14'), Bairro: 'Bela Vista', UF: 'SP', Cidade: 'Campinas' },
  { IDPessoa:13, Nome: 'RODRIGO', Nascimento: ISODate('2006-06-06'), Bairro: 'Santa Cruz', UF: 'BA', Cidade: 'Salvador' }
])

// Insere pets (apelido, dono, espécie etc.)
// Aqui "dono" é apenas uma string com o nome da pessoa (não usamos _id aqui).
db.pet.insertMany([
  { apelido: 'REX',      dono: 'ANA',     especie: 'CAO',     sexo: 'M', nascimento: ISODate('2010-10-26'), morte: null },
  { apelido: 'SNOOPY',   dono: 'BOB',     especie: 'CAO',     sexo: 'M', nascimento: ISODate('2014-11-22'), morte: null },
  { apelido: 'GARFIELD', dono: 'CLARA',   especie: 'GATO',    sexo: 'M', nascimento: ISODate('2013-12-27'), morte: null },
  { apelido: 'BIDU',     dono: 'ANA',     especie: 'CAO',     sexo: 'M', nascimento: ISODate('2011-05-10'), morte: null },
  { apelido: 'TOM',      dono: 'CLARA',   especie: 'GATO',    sexo: 'M', nascimento: ISODate('2012-07-15'), morte: null },
  { apelido: 'LASSIE',   dono: 'BOB',     especie: 'CAO',     sexo: 'F', nascimento: ISODate('2016-08-01'), morte: null },
  { apelido: 'NINA',     dono: 'ANA',     especie: 'CACHORRA',sexo: 'F', nascimento: ISODate('2018-03-20'), morte: null },
  { apelido: 'MIMI',     dono: 'CLARA',   especie: 'GATA',    sexo: 'F', nascimento: ISODate('2019-06-11'), morte: null },
  { apelido: 'BOLINHA',  dono: 'DANIEL',  especie: 'COELHO',  sexo: 'M', nascimento: ISODate('2020-02-28'), morte: null },
  { apelido: 'SPIKE',    dono: 'DANIELA', especie: 'CAO',     sexo: 'M', nascimento: ISODate('2017-09-09'), morte: null },
  { apelido: 'PRETA',    dono: 'ANA',     especie: 'GATA',    sexo: 'F', nascimento: ISODate('2015-11-05'), morte: null },
  { apelido: 'MAX',      dono: 'BOB',     especie: 'CAO',     sexo: 'M', nascimento: ISODate('2013-04-18'), morte: null },
  { apelido: 'LUNA',     dono: 'CLARA',   especie: 'GATA',    sexo: 'F', nascimento: ISODate('2021-01-23'), morte: null }
])

// Insere dependentes vinculados a pessoas por IDPessoa
db.dependentes.insertMany([
  { IDDependente: 1, NomeD: 'Filho1', IDPessoa: 2 },
  { IDDependente: 2, NomeD: 'Filho2', IDPessoa: 2 },
  { IDDependente: 3, NomeD: 'Filha1', IDPessoa: 1 }
])

// =======================================================
// 4) CONSULTAS BÁSICAS (EQUIVALENTES A SELECTs SIMPLES)
// =======================================================

// Seleciona todos os documentos da coleção pet
db.pet.find()

// Seleciona apenas apelido e dono (projeção de campos)
db.pet.find({}, { _id: 0, apelido: 1, dono: 1 })

// Filtra pets cujo dono é 'ANA'
db.pet.find({ dono: 'ANA' }, { _id: 0, apelido: 1, sexo: 1, nascimento: 1 })

// Seleciona pets nascidos após 26/10/2010
db.pet.find(
  { nascimento: { $gt: ISODate('2010-10-26') } },
  { _id: 0, apelido: 1, nascimento: 1 }
)

// Filtra pets do dono 'BOB' e sexo masculino
db.pet.find(
  { dono: 'BOB', sexo: 'M' }
)

// =======================================================
// 5) UPDATE, DELETE E "DROP" EM MONGODB
// =======================================================

// Atualiza espécie e data de morte do pet chamado 'REX'
db.pet.updateOne(
  { apelido: 'REX' },
  { $set: { especie: 'LAGARTO', morte: ISODate('2016-01-27') } }
)

// Verifica o registro atualizado
db.pet.find({ apelido: 'REX' })

// Deleta o documento do pet 'REX'
db.pet.deleteOne({ apelido: 'REX' })

// Deleta todos os documentos da coleção pet (equivalente a DELETE sem WHERE)
db.pet.deleteMany({})

// Verifica que a coleção está vazia (a coleção ainda existe)
db.pet.find()

// Remove completamente a coleção "pet" (equivalente a DROP TABLE)
db.pet.drop()

// Confere as coleções existentes
show collections

// =======================================================
// 6) "TRIGGERS" EM MONGODB (EXEMPLO COM CHANGE STREAM)
// =======================================================
// MongoDB não tem TRIGGER no estilo SQL Server/MySQL,
// mas temos Change Streams, que permitem "escutar" mudanças
// em coleções e reagir a elas na aplicação ou em Atlas Triggers.

// Primeiro recriamos a coleção pet e inserimos alguns dados
db.createCollection("pet")
db.pet.insertMany([
  { apelido: 'REX',   dono: 'ANA', especie: 'CAO', sexo: 'M', nascimento: ISODate('2010-10-26') },
  { apelido: 'LUNA',  dono: 'CLARA', especie: 'GATA', sexo: 'F', nascimento: ISODate('2021-01-23') }
])

// Coleção de auditoria (similar ao audit_pet do MySQL)
db.createCollection("audit_pet")

// Exemplo de "trigger" via changeStream em mongosh:
// ATENÇÃO: este código fica "esperando" eventos; é algo que você
// rodaria em uma aplicação ou sessão dedicada.
const changeStream = db.pet.watch()

// Em outra aba/cliente, faça operações em db.pet (insert/update/delete).
// Aqui lemos alguns eventos e gravamos na coleção de auditoria:
let counter = 0
while (changeStream.hasNext() && counter < 5) {
  const change = changeStream.next()
  print("Evento de mudança em pet:")
  printjson(change)
  db.audit_pet.insertOne({
    changeDocumentKey: change.documentKey,
    operationType: change.operationType,
    fullDocument: change.fullDocument,
    ts: new Date()
  })
  counter++
}
changeStream.close()

// Agora podemos ver o log de auditoria
db.audit_pet.find()

// =======================================================
// 7) CRIAÇÃO DE UMA CONTA PARA BACKUP DO BANCO aula3
// =======================================================
// Em MongoDB, usuários são criados no banco "admin".
// Usamos o papel "backup" para permitir mongodump,
// e "read" no banco aula3.

use('admin')

db.createUser({
  user: "backup_aula3",
  pwd:  "Troque_Esta_Senha!123",        // troque em produção!
  roles: [
    { role: "backup", db: "admin" },    // permite backup lógico
    { role: "read",   db: "aula3" }     // leitura dos dados do schema aula3
  ]
})

// Exemplo (linha de comando) para fazer dump:
//   mongodump --uri "mongodb://backup_aula3:Troque_Esta_Senha!123@localhost:27017/aula3" \
//             --out ./backup_aula3

// =======================================================
// 8) CONSULTA: TAMANHO DO BANCO DE DADOS aula3
// =======================================================

use('aula3')

// db.stats() mostra várias métricas do database, incluindo tamanho.
const stats = db.stats()
print("Resumo do banco aula3:")
printjson({
  db: stats.db,
  collections: stats.collections,
  objects: stats.objects,
  dataSize_bytes: stats.dataSize,
  storageSize_bytes: stats.storageSize,
  indexSize_bytes: stats.indexSize
})

// =======================================================
// 9) CONSULTA: CADA COLEÇÃO E SEUS CAMPOS (TIPOS VIA AMOSTRA)
// =======================================================
// MongoDB é schema-less, então não temos um "dicionário de dados"
// fixo como no MySQL. Aqui vamos listar as coleções e mostrar
// um documento de exemplo de cada uma para inspecionar estrutura.

const collections = db.getCollectionNames()
collections.forEach(function (coll) {
  print("=======================================")
  print("Coleção:", coll)
  const sample = db[coll].findOne()
  if (sample) {
    print("Documento de exemplo:")
    printjson(sample)
  } else {
    print("Coleção vazia (sem documentos).")
  }
})

// (Alternativa mais avançada seria usar agregação + $type para inferir tipos.)

// =======================================================
// 10) CONSULTA: USO DE CPU, MEMÓRIA E DISCO (VISÃO DO SERVIDOR)
// =======================================================
// MongoDB não retorna %CPU direto, mas o serverStatus dá visões
// de conexões, memória usada, cache, IO, contadores de operações etc.

use('admin')

const server = db.serverStatus()

// Informações gerais do servidor
print("=== INFO GERAL ===")
printjson({
  host: server.host,
  version: server.version,
  process: server.process,
  uptime_seconds: server.uptime
})

// Conexões atuais (proxy para carga de acesso)
print("=== CONEXÕES ===")
printjson(server.connections)

// Memória usada pelo processo mongod
print("=== MEMÓRIA ===")
printjson(server.mem)

// Contadores de operações (aproxima uso de CPU por tipo de operação)
print("=== OPCOUNTERS (nº de operações desde o start) ===")
printjson(server.opcounters)

// Se estiver usando WiredTiger, temos dados de cache (ligados a RAM/IO)
if (server.wiredTiger && server.wiredTiger.cache) {
  print("=== WIREDTIGER CACHE (memória e disco do engine) ===")
  printjson(server.wiredTiger.cache)
}

// Para disco, é comum olhar também dataSize/storage via db.stats()
// e/ou métricas externas (sistema operacional/monitoria).
