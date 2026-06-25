import streamlit as st

from database import run_query


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
