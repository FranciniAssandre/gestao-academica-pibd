import streamlit as st

from database import execute_command, run_query


st.title("Grade Curricular")
st.write(
    "Consulte as disciplinas de cada curso, a carga total, os pre-requisitos e equivalencias."
)

try:
    cursos_df = run_query(
        """
        SELECT cod_curso, nome, carga_horaria
        FROM curso
        ORDER BY nome
        """
    )
except Exception as error:
    st.error(f"Erro ao carregar cursos: {error}")
    cursos_df = None

try:
    disciplinas_cadastro_df = run_query(
        """
        SELECT cod_disc, nome
        FROM disciplina
        ORDER BY nome
        """
    )
except Exception as error:
    st.error(f"Erro ao carregar disciplinas para cadastro de pre-requisito: {error}")
    disciplinas_cadastro_df = None

if cursos_df is not None and not cursos_df.empty:
    curso_options = {
        f"{row.cod_curso} - {row.nome}": row.cod_curso for row in cursos_df.itertuples()
    }
    curso_label = st.selectbox("Selecione o curso", list(curso_options.keys()))
    curso_id = curso_options[curso_label]

    st.subheader("Disciplinas do curso")
    try:
        disciplinas_df = run_query(
            """
            SELECT
                c.nome AS curso,
                d.cod_disc,
                d.nome AS disciplina,
                d.carga_teoria,
                d.carga_pratica,
                d.carga_extensao,
                fn_carga_total(d.cod_disc) AS carga_total
            FROM curso c
            JOIN curso_disciplina cd ON cd.cod_curso = c.cod_curso
            JOIN disciplina d ON d.cod_disc = cd.cod_disc
            WHERE c.cod_curso = %s
            ORDER BY d.nome
            """,
            [curso_id],
        )
        st.dataframe(disciplinas_df, use_container_width=True, hide_index=True)
    except Exception as error:
        st.error(f"Erro ao listar disciplinas do curso: {error}")

    st.subheader("Pre-requisitos das disciplinas")
    try:
        prereq_df = run_query(
            """
            SELECT
                d.nome AS disciplina,
                pre.nome AS pre_requisito
            FROM curso_disciplina cd
            JOIN disciplina d ON d.cod_disc = cd.cod_disc
            LEFT JOIN disciplina_pre_requisito dpr ON dpr.cod_disc = d.cod_disc
            LEFT JOIN disciplina pre ON pre.cod_disc = dpr.cod_disc_pre
            WHERE cd.cod_curso = %s
            ORDER BY d.nome, pre.nome
            """,
            [curso_id],
        )
        st.dataframe(prereq_df, use_container_width=True, hide_index=True)
    except Exception as error:
        st.error(f"Erro ao listar pre-requisitos: {error}")

    st.subheader("Equivalencias entre disciplinas")
    try:
        equivalencias_df = run_query(
            """
            SELECT
                d1.nome AS disciplina,
                d2.nome AS disciplina_equivalente
            FROM curso_disciplina cd
            JOIN disciplina d1 ON d1.cod_disc = cd.cod_disc
            JOIN disciplina_equivalencia de ON de.cod_disc_a = d1.cod_disc
            JOIN disciplina d2 ON d2.cod_disc = de.cod_disc_b
            WHERE cd.cod_curso = %s
            ORDER BY d1.nome, d2.nome
            """,
            [curso_id],
        )
        st.dataframe(equivalencias_df, use_container_width=True, hide_index=True)
    except Exception as error:
        st.error(f"Erro ao listar equivalencias: {error}")
else:
    st.info("Nao ha cursos disponiveis para consulta.")

st.subheader("Cadastrar pre-requisito")
st.write(
    'Para testar o bloqueio do trigger, selecione "Algoritmos I" como disciplina e '
    '"Banco de Dados" como pre-requisito.'
)
st.write(
    "Como ja existe Banco de Dados exigindo Algoritmos I, o trigger deve impedir o "
    "relacionamento inverso."
)

if disciplinas_cadastro_df is not None and not disciplinas_cadastro_df.empty:
    disciplina_options = {
        f"{row.nome} ({row.cod_disc})": row.cod_disc
        for row in disciplinas_cadastro_df.itertuples()
    }
    disciplina_labels = ["Selecione uma disciplina", *disciplina_options.keys()]
    pre_requisito_labels = [
        "Selecione um pre-requisito",
        *disciplina_options.keys(),
    ]

    with st.form("form_cadastro_pre_requisito"):
        disciplina_label = st.selectbox("Disciplina", disciplina_labels, index=0)
        pre_requisito_label = st.selectbox(
            "Disciplina pre-requisito", pre_requisito_labels, index=0
        )
        cadastrar_pre_requisito = st.form_submit_button("Cadastrar pre-requisito")

    if cadastrar_pre_requisito:
        try:
            execute_command(
                """
                INSERT INTO DISCIPLINA_PRE_REQUISITO (cod_disc, cod_disc_pre)
                VALUES (%s, %s)
                """,
                [
                    None
                    if disciplina_label == "Selecione uma disciplina"
                    else disciplina_options[disciplina_label],
                    None
                    if pre_requisito_label == "Selecione um pre-requisito"
                    else disciplina_options[pre_requisito_label],
                ],
            )
            st.success("Pre-requisito cadastrado com sucesso.")
        except Exception as error:
            st.error(f"Erro ao cadastrar pre-requisito: {error}")
else:
    st.info("Nao ha disciplinas disponiveis para cadastrar pre-requisitos.")
