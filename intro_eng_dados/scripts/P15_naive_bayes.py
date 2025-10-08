# -*- coding: utf-8 -*-
# ==============================================================================
# Nome do Script: naive_bayes_classificacao.py - Classificacao com Naive Bayes
# Descrição: Este script aplica o algoritmo Naive Bayes ao dataset
# Autor: Nome do aluno
# Data de Criação: 
# Hora de Criação: 
#
# Dependências:
# - pandas
# - scikit-learn
# - matplotlib
# - time
# Uso: Coloque o dataset na mesma pasta que este programa
# ==============================================================================

import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.naive_bayes import GaussianNB
from sklearn.metrics import classification_report, ConfusionMatrixDisplay
import matplotlib.pyplot as plt
import time
import datetime

# Início
inicio = time.time()
print("Início do processamento:", datetime.datetime.now())

# Carregar dataset
arquivo_csv = 'dataset_para_classificacao_v2.csv'
df = pd.read_csv(arquivo_csv, sep=';')

# Separar variáveis independentes e alvo
X = df[['idade', 'salario_anual', 'tempo_empresa', 'score_credito']]
y = df['classe']

# Padronizar os dados
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Dividir em treino e teste
X_train, X_test, y_train, y_test = train_test_split(X_scaled, y, test_size=0.3, random_state=42)

# Treinar o modelo Naive Bayes
modelo = GaussianNB()
modelo.fit(X_train, y_train)

# Predição
y_pred = modelo.predict(X_test)

# Relatório
report = classification_report(y_test, y_pred, output_dict=True)
df_report = pd.DataFrame(report).transpose()
df_report.to_csv("resultado_naive_bayes.csv", sep=';', index=True)

# Gráfico
disp = ConfusionMatrixDisplay.from_estimator(modelo, X_test, y_test)
plt.title("Matriz de Confusão - Naive Bayes")
plt.savefig("grafico_naive_bayes.png")
plt.close()

# Fim
fim = time.time()
print("Fim do processamento:", datetime.datetime.now())
print("Tempo total: {:.2f} segundos".format(fim - inicio))
