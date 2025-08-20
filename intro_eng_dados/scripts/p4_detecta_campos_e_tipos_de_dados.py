# ==============================================================================
# Nome do Script: p4.py - Exemplo de script para diagnosticar o dataset
# Descrição: Tenta identificar 
#
# Autor: Nome do aluno
# Data de Criação: 
# Hora de Criação: 
#
# Dependências:
#  - csv, sys, itertools, collections, datetime, re
#
# Uso: Coloque o dataset na mesma pasta que este programa
# ==============================================================================

#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import csv
import sys
from itertools import islice
from collections import Counter
from datetime import datetime
import re 
from pathlib import Path

# ======== Configurações ========
ARQUIVO_PADRAO = "K3241.K03200Y0.D50809.ESTABELE"
DELIMITADOR = ';'
LIMITE_LINHAS = 1000
ARQUIVO_RELATORIO = "relatorio_campos.csv"

# ======== Funções de detecção de tipo ========
_bool_truthy = {"true","t","1","sim","s","y","yes"}
_bool_falsy  = {"false","f","0","nao","não","n","no"}

_date_formats = [
    "%Y-%m-%d",
    "%d/%m/%Y",
    "%d/%m/%Y %H:%M",
    "%d/%m/%Y %H:%M:%S",
    "%Y-%m-%d %H:%M",
    "%Y-%m-%d %H:%M:%S",
]
iso_dt_regex = re.compile(r"^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}(:\d{2})?(Z|[+\-]\d{2}:\d{2})?$")

def is_bool(s: str) -> bool:
    v = s.strip().lower()
    return v in _bool_truthy or v in _bool_falsy

def is_int(s: str) -> bool:
    v = s.strip()
    if not v: return False
    v = v.replace('.', '').replace(',', '')
    return v.lstrip("+-").isdigit()

def is_float(s: str) -> bool:
    v = s.strip()
    if not v: return False
    if ',' in v and '.' in v:
        if v.rfind(',') > v.rfind('.'):
            v = v.replace('.', '').replace(',', '.')
        else:
            v = v.replace(',', '')
    elif ',' in v:
        v = v.replace(',', '.')
    try:
        float(v)
        return True
    except ValueError:
        return False

def is_date_or_datetime(s: str):
    v = s.strip()
    if not v:
        return (False, False)
    if iso_dt_regex.match(v):
        return (True, True)
    for fmt in _date_formats:
        try:
            datetime.strptime(v, fmt)
            has_time = any(token in fmt for token in ["%H", "%M", "%S"])
            return (True, has_time)
        except ValueError:
            continue
    return (False, False)

def infer_type(samples):
    non_empty = [s for s in samples if s and str(s).strip() != ""]
    if not non_empty:
        return "empty"

    flags = {"bool": True, "int": True, "float": True, "date": True, "datetime": False}

    for s in non_empty:
        sv = str(s).strip()
        if not is_bool(sv): flags["bool"] = False
        if not is_int(sv): flags["int"] = False
        if not is_float(sv): flags["float"] = False
        is_date, is_dt = is_date_or_datetime(sv)
        if not is_date: flags["date"] = False
        if is_dt: flags["datetime"] = True

    if flags["bool"]: return "bool"
    if flags["int"]: return "int"
    if flags["float"]: return "float"
    if flags["date"]: return "datetime" if flags["datetime"] else "date"
    return "string"

# ======== Relatório ========
def processar_csv(caminho: Path):
    with caminho.open("r", encoding="latin-1", newline="") as f:
        reader = csv.reader(f, delimiter=DELIMITADOR)
        try:
            header = next(reader)
        except StopIteration:
            print("Arquivo vazio.")
            return

        num_campos = len(header)

        amostras = [[] for _ in range(num_campos)]
        vazios = Counter()

        for row in islice(reader, LIMITE_LINHAS):
            if len(row) < num_campos:
                row += [""] * (num_campos - len(row))
            elif len(row) > num_campos:
                row = row[:num_campos]

            for i, val in enumerate(row):
                s = "" if val is None else str(val)
                if s.strip() == "":
                    vazios[i] += 1
                amostras[i].append(s)

        tipos, exemplos = [], []
        for i in range(num_campos):
            t = infer_type(amostras[i])
            tipos.append(t)
            ex = next((v for v in amostras[i] if v and v.strip() != ""), "")
            exemplos.append(ex)

        # ===== Relatório no terminal =====
        print("=" * 70)
        print(f"Arquivo analisado : {caminho}")
        print(f"Linhas analisadas : {sum(len(col) for col in amostras) // num_campos}")
        print(f"Total de campos   : {num_campos}")
        print("=" * 70)
        print("{:<5} {:<35} {:<12} {:<10} {}".format("#", "Campo", "Tipo", "Vazios", "Exemplo"))
        print("-" * 70)
        for i, nome in enumerate(header):
            print("{:<5} {:<35} {:<12} {:<10} {}".format(
                i, nome.strip(), tipos[i], vazios[i], exemplos[i][:50]
            ))
        print("-" * 70)
        print(f"Total de campos: {num_campos}")

        # ===== Exporta relatório em CSV =====
        with open(ARQUIVO_RELATORIO, "w", newline="", encoding="utf-8") as out:
            writer = csv.writer(out, delimiter=";")
            writer.writerow(["Indice", "Campo", "Tipo", "Vazios", "Exemplo"])
            for i, nome in enumerate(header):
                writer.writerow([i, nome.strip(), tipos[i], vazios[i], exemplos[i]])
            # linha final com total de campos
            writer.writerow([])
            writer.writerow(["TOTAL_CAMPOS", num_campos])

        print(f"\nRelatório exportado em: {ARQUIVO_RELATORIO}")

def main():
    caminho = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(ARQUIVO_PADRAO)
    if not caminho.exists():
        print(f"Arquivo não encontrado: {caminho}")
        sys.exit(1)
    processar_csv(caminho)

if __name__ == "__main__":
    main()
