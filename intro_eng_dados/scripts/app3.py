# streamlit_app3.py
# ------------------------------------------------------------
# Dashboard de Vendas — APP3 (dataset fixo, sem upload/download)
# - Lê sempre vendas_dashboard.csv (delimitador ;)
# - Filtros no topo (estado, município, loja, categoria, vendedor, período,
#   categoria do cliente e se a venda foi parcelada)
# - KPIs ampliados
# - Gráficos coloridos e variados (barras, pizza, área, histograma, boxplot,
#   treemap, stacked area, scatter)
# - Mapas: Plotly Mapbox + Folium (opcional)
# - Docstrings em cada função de gráfico
# ------------------------------------------------------------

import os
import math
import pandas as pd
import streamlit as st
import plotly.express as px

# Folium opcional (o app funciona sem ele)
try:
    import folium
    from streamlit_folium import st_folium
    HAS_FOLIUM = True
except Exception:
    HAS_FOLIUM = False

st.set_page_config(page_title="Dashboard de Vendas — APP3", page_icon="📊", layout="wide")

# Paletas variadas (cores diferentes entre gráficos)
PALETTES = {
    "bar": px.colors.qualitative.Set2,
    "bar_alt": px.colors.qualitative.Plotly,
    "pie": px.colors.qualitative.Pastel,
    "area": px.colors.qualitative.Vivid,
    "line": px.colors.qualitative.Safe,
    "stacked": px.colors.qualitative.Dark24,
    "hist": px.colors.qualitative.Antique,
    "box": px.colors.qualitative.Bold,
    "treemap": px.colors.qualitative.Prism,
}

# Cores únicas solicitadas
LIGHT_BLUE  = "#66B3FF"  # azul claro
LIGHT_GREEN = "#7ED957"  # verde claro
LIGHT_GRAY  = "#D3D3D3"  # cinza claro

# ------------------------------------------------------------
# Geocódigos aproximados (lat, lon) — cidades comuns no dataset
# ------------------------------------------------------------
CITY_LATLON = {
    # SP
    "São Paulo": (-23.5505, -46.6333), "Campinas": (-22.9056, -47.0608),
    "Sorocaba": (-23.5015, -47.4526), "Ribeirão Preto": (-21.1775, -47.8103),
    "São José dos Campos": (-23.2237, -45.9009),
    # RJ
    "Rio de Janeiro": (-22.9068, -43.1729), "Niterói": (-22.8832, -43.1034),
    "Campos dos Goytacazes": (-21.7622, -41.3181), "Volta Redonda": (-22.5200, -44.0996),
    # MG
    "Belo Horizonte": (-19.9167, -43.9345), "Uberlândia": (-18.9113, -48.2622),
    "Contagem": (-19.9317, -44.0533), "Juiz de Fora": (-21.7619, -43.3496),
    # RS
    "Porto Alegre": (-30.0346, -51.2177), "Caxias do Sul": (-29.1678, -51.1794),
    "Pelotas": (-31.7654, -52.3371), "Santa Maria": (-29.6842, -53.8069),
    # SC
    "Florianópolis": (-27.5949, -48.5482), "Joinville": (-26.3045, -48.8487),
    "Blumenau": (-26.9173, -49.0661), "Chapecó": (-27.1004, -52.6152),
    # PR
    "Curitiba": (-25.4284, -49.2733), "Londrina": (-23.3045, -51.1696),
    "Maringá": (-23.4205, -51.9333), "Cascavel": (-24.9555, -53.4552),
    # MT
    "Cuiabá": (-15.6010, -56.0974), "Várzea Grande": (-15.6467, -56.1322),
    "Rondonópolis": (-16.4708, -54.6356), "Sinop": (-11.8642, -55.5030),
    "Tangará da Serra": (-14.6225, -57.4850), "Lucas do Rio Verde": (-13.0559, -55.9199),
    "Sorriso": (-12.5420, -55.7211), "Barra do Garças": (-15.8931, -52.2569),
    # MS
    "Campo Grande": (-20.4697, -54.6201), "Dourados": (-22.2211, -54.8056),
    "Três Lagoas": (-20.7849, -51.7004), "Corumbá": (-19.0077, -57.6510),
    # PA
    "Belém": (-1.4558, -48.4902), "Ananindeua": (-1.3650, -48.3720),
    "Marabá": (-5.3803, -49.1327), "Santarém": (-2.4390, -54.7009),
    # AM
    "Manaus": (-3.1190, -60.0217), "Itacoatiara": (-3.1386, -58.4449),
    "Parintins": (-2.6283, -56.7358),
    # GO
    "Goiânia": (-16.6869, -49.2648), "Anápolis": (-16.3281, -48.9534),
    "Aparecida de Goiânia": (-16.8193, -49.2473),
    # DF
    "Brasília": (-15.7939, -47.8828),
    # ES
    "Vitória": (-20.3155, -40.3128), "Vila Velha": (-20.3361, -40.2939), "Serra": (-20.1286, -40.3074),
    # RO
    "Porto Velho": (-8.7619, -63.9039), "Ji-Paraná": (-10.8777, -61.9321), "Ariquemes": (-9.9134, -63.0405),
    # TO
    "Palmas": (-10.1842, -48.3336), "Araguaína": (-7.1911, -48.2077), "Gurupi": (-11.7292, -49.0689),
    # MA
    "São Luís": (-2.5387, -44.2825), "Imperatriz": (-5.5185, -47.4784), "Caxias": (-4.8650, -43.3617),
    # PI
    "Teresina": (-5.0919, -42.8034), "Parnaíba": (-2.9059, -41.7760), "Picos": (-7.0768, -41.4679),
    # BA
    "Salvador": (-12.9777, -38.5016), "Feira de Santana": (-12.2664, -38.9663),
    "Vitória da Conquista": (-14.8615, -40.8442), "Ilhéus": (-14.7935, -39.0460),
    # PE
    "Recife": (-8.0476, -34.8770), "Olinda": (-7.9993, -34.8450), "Caruaru": (-8.2835, -35.9759), "Petrolina": (-9.3891, -40.5033),
    # CE
    "Fortaleza": (-3.7319, -38.5267), "Caucaia": (-3.7361, -38.6535), "Juazeiro do Norte": (-7.2131, -39.3155),
    "Sobral": (-3.6891, -40.3482),
}

# ------------------------------------------------------------
# Utilidades
# ------------------------------------------------------------
@st.cache_data
def load_data() -> pd.DataFrame:
    """Carrega e higieniza o dataset fixo `vendas_dashboard.csv` (delimitador ;)"""
    csv_path = "vendas_dashboard.csv"
    if not os.path.exists(csv_path):
        st.error("⚠️ Arquivo vendas_dashboard.csv não encontrado na pasta do aplicativo.")
        st.stop()

    df = pd.read_csv(csv_path, sep=";", encoding="utf-8")
    # Datas e numéricos
    df["data_venda"] = pd.to_datetime(df["data_venda"], errors="coerce")
    if "data_entrega_prevista" in df.columns:
        df["data_entrega_prevista"] = pd.to_datetime(df["data_entrega_prevista"], errors="coerce")

    for col in ["preco_unitario", "preco_total"]:
        if col in df.columns:
            df[col] = df[col].astype(str).str.replace(",", ".", regex=False).astype(float)
    if "quantidade_vendida" in df.columns:
        df["quantidade_vendida"] = pd.to_numeric(df["quantidade_vendida"], errors="coerce").fillna(0).astype(int)

    # Auxiliares
    df["ano"] = df["data_venda"].dt.year
    df["mes"] = df["data_venda"].dt.month
    df["dia"] = df["data_venda"].dt.date
    df["mes_nome"] = df["data_venda"].dt.strftime("%b")
    return df

def fmt_currency(x: float) -> str:
    """Formata valores monetários em BRL (R$) com separador PT-BR."""
    return f"R$ {x:,.2f}".replace(",", "X").replace(".", ",").replace("X", ".")

def safe_pct(a, b) -> float:
    """Retorna a porcentagem (0–100) de a/b com proteção para divisão por zero."""
    return 0.0 if b == 0 else round(100.0 * a / b, 2)

# ------------------------------------------------------------
# Layout — Título e Filtros no topo
# ------------------------------------------------------------
st.title("📊 Dashboard de Vendas — APP3 (Dataset Fixo)")
st.caption("Base: **vendas_dashboard.csv** — upload e download desabilitados.")

df = load_data()

with st.container():
    c1, c2, c3, c4 = st.columns([1, 1, 1, 2])
    with c1:
        estados = ["(Todos)"] + sorted(df["estado"].dropna().unique().tolist())
        estado_sel = st.selectbox("Estado", estados, index=0)
        if estado_sel != "(Todos)":
            municipios_opts = ["(Todos)"] + sorted(df.loc[df["estado"] == estado_sel, "municipio"].dropna().unique().tolist())
        else:
            municipios_opts = ["(Todos)"] + sorted(df["municipio"].dropna().unique().tolist())
        municipio_sel = st.selectbox("Município", municipios_opts, index=0)

    with c2:
        lojas_opts = ["(Todas)"] + sorted(df["loja"].dropna().unique().tolist())
        loja_sel = st.selectbox("Loja", lojas_opts, index=0)

        categorias_opts = ["(Todas)"] + sorted(df["categoria_produto"].dropna().unique().tolist())
        categoria_sel = st.selectbox("Categoria", categorias_opts, index=0)

    with c3:
        vendedores_opts = ["(Todos)"] + sorted(df["nome_vendedor"].dropna().unique().tolist())
        vendedor_sel = st.selectbox("Vendedor", vendedores_opts, index=0)

        cat_cliente_opts = ["(Todas)"] + sorted(df["categoria_cliente"].dropna().unique().tolist())
        cat_cliente_sel = st.selectbox("Categoria do Cliente", cat_cliente_opts, index=0)

    with c4:
        min_date, max_date = df["data_venda"].min(), df["data_venda"].max()
        data_ini, data_fim = st.date_input(
            "Período (Data da Venda)",
            (min_date.date(), max_date.date())
        )

        parcelada_opts = ["(Todas)", "sim", "não"]
        parcelada_sel = st.selectbox("Venda Parcelada", parcelada_opts, index=0)

# Aplicação dos filtros
filtered = df.copy()
if estado_sel != "(Todos)":
    filtered = filtered[filtered["estado"] == estado_sel]
if municipio_sel != "(Todos)":
    filtered = filtered[filtered["municipio"] == municipio_sel]
if loja_sel != "(Todas)":
    filtered = filtered[filtered["loja"] == loja_sel]
if categoria_sel != "(Todas)":
    filtered = filtered[filtered["categoria_produto"] == categoria_sel]
if vendedor_sel != "(Todos)":
    filtered = filtered[filtered["nome_vendedor"] == vendedor_sel]
if cat_cliente_sel != "(Todas)":
    filtered = filtered[filtered["categoria_cliente"] == cat_cliente_sel]
if parcelada_sel != "(Todas)":
    filtered = filtered[filtered["venda_parcelada"].str.lower() == parcelada_sel]

filtered = filtered[
    (filtered["data_venda"] >= pd.to_datetime(data_ini)) &
    (filtered["data_venda"] <= pd.to_datetime(data_fim))
]

# ------------------------------------------------------------
# KPIs
# ------------------------------------------------------------
st.header("📈 KPIs")

fat = filtered["preco_total"].sum() if not filtered.empty else 0.0
n_vendas = len(filtered)
ticket = fat / n_vendas if n_vendas > 0 else 0.0
itens = filtered["quantidade_vendida"].sum() if "quantidade_vendida" in filtered.columns else 0
itens_por_venda = itens / n_vendas if n_vendas > 0 else 0.0
clientes_unicos = filtered["nome_cliente"].nunique() if "nome_cliente" in filtered.columns else 0
parc_sim = (filtered["venda_parcelada"].str.lower() == "sim").sum() if "venda_parcelada" in filtered.columns else 0
pct_parc = safe_pct(parc_sim, n_vendas)

if "estado" in filtered.columns and n_vendas > 0:
    por_estado = filtered.groupby("estado", as_index=False)["preco_total"].sum().sort_values("preco_total", ascending=False)
    estado_lider = por_estado.iloc[0]["estado"]
    part_lider = safe_pct(por_estado.iloc[0]["preco_total"], fat)
else:
    estado_lider, part_lider = "—", 0.0

k1, k2, k3, k4, k5, k6 = st.columns(6)
with k1: st.metric("Faturamento", fmt_currency(fat))
with k2: st.metric("Nº de Vendas", f"{n_vendas}")
with k3: st.metric("Ticket Médio", fmt_currency(ticket))
with k4: st.metric("% Parceladas", f"{pct_parc:.2f}%")
with k5: st.metric("Estado Líder", f"{estado_lider} — {part_lider:.2f}%")
with k6: st.metric("Clientes Únicos / Itens/Venda", f"{clientes_unicos} / {itens_por_venda:.2f}")

st.divider()

# ------------------------------------------------------------
# Funções de gráficos (cada uma com docstring)
# ------------------------------------------------------------
def chart_vendas_por_cliente(df_plot: pd.DataFrame):
    """Barra: Faturamento total por cliente no período/recorte filtrado."""
    base = df_plot.groupby("nome_cliente", as_index=False)["preco_total"].sum().sort_values("preco_total", ascending=False)
    fig = px.bar(base, x="nome_cliente", y="preco_total",
                 color="nome_cliente", color_discrete_sequence=PALETTES["bar"],
                 labels={"preco_total": "Faturamento (R$)", "nome_cliente": "Cliente"},
                 title="Faturamento por Cliente")
    fig.update_layout(xaxis_tickangle=-45, yaxis_tickformat=",")
    st.plotly_chart(fig, use_container_width=True, key="app3_clientes")


def chart_vendas_por_vendedor(df_plot: pd.DataFrame):
    """Barra: Faturamento total por vendedor no período/recorte filtrado."""
    base = df_plot.groupby("nome_vendedor", as_index=False)["preco_total"].sum().sort_values("preco_total", ascending=False)
    fig = px.bar(
        base, x="nome_vendedor", y="preco_total",
        labels={"preco_total": "Faturamento (R$)", "nome_vendedor": "Vendedor"},
        title="Faturamento por Vendedor"
    )
    # Cor única (azul claro)
    fig.update_traces(marker_color=LIGHT_BLUE)
    fig.update_layout(xaxis_tickangle=-45, yaxis_tickformat=",")
    st.plotly_chart(fig, use_container_width=True, key="app3_vendedores")


def chart_categorias_qtd(df_plot: pd.DataFrame):
    """Barra: Quantidade vendida por categoria de produto."""
    base = df_plot.groupby("categoria_produto", as_index=False)["quantidade_vendida"].sum().sort_values("quantidade_vendida", ascending=False)
    fig = px.bar(
        base, x="categoria_produto", y="quantidade_vendida",
        labels={"quantidade_vendida": "Quantidade", "categoria_produto": "Categoria"},
        title="Quantidade Vendida por Categoria"
    )
    # Cor única (verde claro)
    fig.update_traces(marker_color=LIGHT_GREEN)
    fig.update_layout(xaxis_tickangle=-30)
    st.plotly_chart(fig, use_container_width=True, key="app3_cat_qtd")


def chart_vendas_por_mes(df_plot: pd.DataFrame):
    """Área: Contagem de vendas por mês e ano (série temporal agregada)."""
    por_mes = (df_plot.assign(mes_ord=df_plot["data_venda"].dt.month)
               .groupby(["ano", "mes_ord"], as_index=False)
               .agg(qtd_vendas=("id_venda", "count")))
    por_mes["mes_label"] = pd.to_datetime(por_mes["mes_ord"], format="%m").dt.strftime("%b")
    por_mes = por_mes.sort_values(["ano", "mes_ord"])
    fig = px.area(por_mes, x="mes_label", y="qtd_vendas", color="ano",
                  color_discrete_sequence=PALETTES["area"],
                  labels={"mes_label": "Mês", "qtd_vendas": "Qtd. Vendas", "ano": "Ano"},
                  title="Quantidade de Vendas por Mês (Área)")
    st.plotly_chart(fig, use_container_width=True, key="app3_area_mes")


def chart_top5_clientes(df_plot: pd.DataFrame):
    """Barra: Top 5 clientes por faturamento."""
    top = df_plot.groupby("nome_cliente", as_index=False)["preco_total"].sum().sort_values("preco_total", ascending=False).head(5)
    fig = px.bar(top, x="nome_cliente", y="preco_total",
                 color="nome_cliente", color_discrete_sequence=PALETTES["bar_alt"],
                 labels={"preco_total": "Faturamento (R$)", "nome_cliente": "Cliente"},
                 title="Top 5 Clientes por Faturamento")
    fig.update_layout(xaxis_tickangle=-45, yaxis_tickformat=",")
    st.plotly_chart(fig, use_container_width=True, key="app3_top5_cli")


def chart_top5_vendedores(df_plot: pd.DataFrame):
    """Barra: Top 5 vendedores por faturamento."""
    top = df_plot.groupby("nome_vendedor", as_index=False)["preco_total"].sum().sort_values("preco_total", ascending=False).head(5)
    fig = px.bar(top, x="nome_vendedor", y="preco_total",
                 color="nome_vendedor", color_discrete_sequence=PALETTES["bar"],
                 labels={"preco_total": "Faturamento (R$)", "nome_vendedor": "Vendedor"},
                 title="Top 5 Vendedores por Faturamento")
    fig.update_layout(xaxis_tickangle=-45, yaxis_tickformat=",")
    st.plotly_chart(fig, use_container_width=True, key="app3_top5_vend")


def chart_lojas_fat(df_plot: pd.DataFrame):
    """Barra: Faturamento total por loja."""
    base = df_plot.groupby("loja", as_index=False)["preco_total"].sum().sort_values("preco_total", ascending=False)
    fig = px.bar(
        base, x="loja", y="preco_total",
        labels={"preco_total": "Faturamento (R$)", "loja": "Loja"},
        title="Faturamento por Loja"
    )
    # Cor única (cinza claro)
    fig.update_traces(marker_color=LIGHT_GRAY)
    fig.update_layout(yaxis_tickformat=",")
    st.plotly_chart(fig, use_container_width=True, key="app3_lojas")


def chart_participacao_estado(df_plot: pd.DataFrame):
    """Pizza: Participação do faturamento por estado."""
    base = df_plot.groupby("estado", as_index=False)["preco_total"].sum().sort_values("preco_total", ascending=False)
    fig = px.pie(base, names="estado", values="preco_total",
                 color_discrete_sequence=PALETTES["pie"],
                 title="Participação do Faturamento por Estado")
    fig.update_layout(height=650)  # aumenta altura
    st.plotly_chart(fig, use_container_width=True, key="app3_pizza_estado")


def chart_parceladas_pizza(df_plot: pd.DataFrame):
    """Pizza: Distribuição de vendas parceladas vs. não parceladas."""
    base = (
        df_plot.assign(parcelada=df_plot["venda_parcelada"].str.lower())
               .groupby("parcelada", as_index=False)["id_venda"].count()
               .rename(columns={"id_venda": "vendas"})
    )
    fig = px.pie(base, names="parcelada", values="vendas",
                 color_discrete_sequence=PALETTES["pie"],
                 title="Distribuição de Vendas Parceladas")
    fig.update_layout(height=650)  # aumenta altura
    st.plotly_chart(fig, use_container_width=True, key="app3_pizza_parc")


def chart_treemap_estado_municipio(df_plot: pd.DataFrame):
    """Treemap: Hierarquia Estado → Município pelo faturamento."""
    base = df_plot.groupby(["estado", "municipio"], as_index=False)["preco_total"].sum()
    fig = px.treemap(base, path=["estado", "municipio"], values="preco_total",
                     color="estado", color_discrete_sequence=PALETTES["treemap"],
                     title="Treemap — Faturamento por Estado/Município")
    fig.update_layout(height=750)  # aumenta altura
    st.plotly_chart(fig, use_container_width=True, key="app3_treemap")


def chart_boxplot_preco_por_categoria(df_plot: pd.DataFrame):
    """Boxplot: Distribuição do preço total por categoria de produto."""
    fig = px.box(df_plot, x="categoria_produto", y="preco_total",
                 color="categoria_produto", color_discrete_sequence=PALETTES["box"],
                 labels={"preco_total": "Preço Total (R$)", "categoria_produto": "Categoria"},
                 title="Boxplot — Preço Total por Categoria")
    fig.update_layout(xaxis_tickangle=-30)
    st.plotly_chart(fig, use_container_width=True, key="app3_box_preco_cat")
    st.caption("O boxplot resume a variação do preço total por categoria (mediana, quartis e possíveis outliers).")


def chart_hist_ticket(df_plot: pd.DataFrame):
    """Histograma: Distribuição do valor de venda (ticket) no recorte filtrado."""
    fig = px.histogram(df_plot, x="preco_total", nbins=20,
                       color_discrete_sequence=PALETTES["hist"],
                       labels={"preco_total": "Preço Total (R$)"},
                       title="Distribuição por Ticket (Preço Total por Venda)")
    st.plotly_chart(fig, use_container_width=True, key="app3_hist_ticket")
    st.caption("Este histograma mostra como os valores de venda (tickets) se distribuem: concentrações indicam faixas de preço mais recorrentes.")


def chart_stacked_area_fat_categoria_mensal(df_plot: pd.DataFrame):
    """Stacked Area: Faturamento mensal por categoria (séries empilhadas)."""
    base = (df_plot.assign(mes_ord=df_plot["data_venda"].dt.to_period("M").astype(str))
            .groupby(["mes_ord", "categoria_produto"], as_index=False)["preco_total"].sum())
    base = base.sort_values("mes_ord")
    fig = px.area(base, x="mes_ord", y="preco_total", color="categoria_produto",
                  color_discrete_sequence=PALETTES["stacked"],
                  labels={"mes_ord": "Mês", "preco_total": "Faturamento (R$)", "categoria_produto": "Categoria"},
                  title="Faturamento Mensal por Categoria (Empilhado)")
    st.plotly_chart(fig, use_container_width=True, key="app3_stack_area_cat")


def chart_scatter_qty_vs_preco_unit(df_plot: pd.DataFrame):
    """Scatter: Relação entre quantidade vendida e preço unitário (por categoria)."""
    fig = px.scatter(df_plot, x="preco_unitario", y="quantidade_vendida",
                     color="categoria_produto", size="preco_total",
                     color_discrete_sequence=PALETTES["line"],
                     labels={"preco_unitario": "Preço Unitário (R$)", "quantidade_vendida": "Quantidade"},
                     title="Dispersão: Quantidade vs. Preço Unitário (tamanho ~ Preço Total)")
    st.plotly_chart(fig, use_container_width=True, key="app3_scatter_qty_preco")


def map_plotly_faturamento_por_cidade(df_plot: pd.DataFrame):
    """Mapa Plotly: Pontos por cidade (tamanho ~ faturamento; cor = estado)."""
    agg = (df_plot.groupby(["estado", "municipio"], as_index=False)
           .agg(faturamento=("preco_total", "sum"), vendas=("id_venda", "count")))
    agg["lat"] = agg["municipio"].map(lambda m: CITY_LATLON.get(str(m), (None, None))[0])
    agg["lon"] = agg["municipio"].map(lambda m: CITY_LATLON.get(str(m), (None, None))[1])
    agg = agg.dropna(subset=["lat", "lon"])
    if agg.empty:
        st.warning("Não há geocódigos disponíveis para as cidades filtradas.")
        return
    fig = px.scatter_mapbox(
        agg, lat="lat", lon="lon",
        size="faturamento", color="estado",
        hover_name="municipio",
        hover_data={"faturamento": ":.2f", "vendas": True, "lat": False, "lon": False},
        zoom=3.2, height=520,
        title="Faturamento por Cidade (Plotly Mapbox)"
    )
    fig.update_layout(mapbox_style="open-street-map", margin=dict(l=0, r=0, t=50, b=0))
    st.plotly_chart(fig, use_container_width=True, key="app3_map_plotly")


def map_folium_circles(df_plot: pd.DataFrame):
    """Mapa Folium: Círculos proporcionais por cidade (raio ~ faturamento)."""
    if not HAS_FOLIUM:
        st.info("Instale `folium` e `streamlit-folium` para este mapa:  pip install folium streamlit-folium")
        return
    agg = (df_plot.groupby(["estado", "municipio"], as_index=False)
           .agg(faturamento=("preco_total", "sum"), vendas=("id_venda", "count")))
    agg["lat"] = agg["municipio"].map(lambda m: CITY_LATLON.get(str(m), (None, None))[0])
    agg["lon"] = agg["municipio"].map(lambda m: CITY_LATLON.get(str(m), (None, None))[1])
    agg = agg.dropna(subset=["lat", "lon"])
    if agg.empty:
        st.warning("Não há geocódigos disponíveis para as cidades filtradas.")
        return

    m = folium.Map(location=[-14.2350, -51.9253], zoom_start=4, tiles="CartoDB positron")
    for _, row in agg.iterrows():
        valor = float(row["faturamento"])
        radius = max(4, min(30, math.sqrt(valor) / 8))  # escala suave
        folium.CircleMarker(
            location=[row["lat"], row["lon"]],
            radius=radius,
            popup=folium.Popup(
                f"<b>{row['municipio']}/{row['estado']}</b><br/>"
                f"Vendas: {int(row['vendas'])}<br/>"
                f"Faturamento: {fmt_currency(valor)}",
                max_width=250
            ),
            color="#2a7ae2",
            fill=True,
            fill_opacity=0.45
        ).add_to(m)

    st_folium(m, width=None, height=540, returned_objects=[])

# ------------------------------------------------------------
# Renderização — Um gráfico abaixo do outro (rolagem)
# ------------------------------------------------------------
if filtered.empty:
    st.info("Sem dados para os filtros selecionados.")
else:
    st.subheader("🔹 Vendas por Cliente / Vendedor / Categoria / Loja")
    chart_vendas_por_cliente(filtered)
    chart_vendas_por_vendedor(filtered)           # azul claro
    chart_categorias_qtd(filtered)                 # verde claro
    chart_lojas_fat(filtered)                      # cinza claro

    st.subheader("🔹 Séries Temporais e Rankings")
    chart_vendas_por_mes(filtered)                 # (série temporal por mês — área)
    chart_stacked_area_fat_categoria_mensal(filtered)  # (stacked area por categoria)
    chart_top5_clientes(filtered)
    chart_top5_vendedores(filtered)

    st.subheader("🔹 Distribuições e Hierarquias")
    chart_hist_ticket(filtered)                    # com explicação
    chart_boxplot_preco_por_categoria(filtered)    # com explicação
    chart_participacao_estado(filtered)            # pizza maior
    chart_parceladas_pizza(filtered)               # pizza maior
    chart_treemap_estado_municipio(filtered)       # treemap maior
    chart_scatter_qty_vs_preco_unit(filtered)

    st.subheader("🔹 Mapas")
    map_plotly_faturamento_por_cidade(filtered)
    map_folium_circles(filtered)

st.divider()
st.caption("Execução:  streamlit run streamlit_app3.py  •  Dataset fixo: vendas_dashboard.csv  •  Upload/Download desabilitados.")
