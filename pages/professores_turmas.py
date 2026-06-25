import streamlit as st

from database import call_procedure, run_query


st.title("Professores e Turmas")
st.write(
    "Consulte professores, veja as turmas disponiveis e aloque docentes com SQL explicito."
)


def load_professores():
    return run_query(
        """
        SELECT registro, nome, formacao
        FROM professor
        ORDER BY nome
        """
    )


def load_turmas():
    return run_query(
        """
        SELECT
            t.cod_turma,
            d.nome AS disciplina,
            t.ano_letivo,
            t.semestre,
            t.sala,
            t.horario
        FROM turma t
        JOIN disciplina d ON d.cod_disc = t.cod_disc
        ORDER BY t.ano_letivo DESC, t.semestre DESC, d.nome
        """
    )


st.subheader("Professores")
try:
    professores_df = load_professores()
    st.dataframe(professores_df, use_container_width=True, hide_index=True)
except Exception as error:
    st.error(f"Erro ao listar professores: {error}")
    professores_df = None

st.subheader("Turmas com disciplinas")
try:
    turmas_df = load_turmas()
    st.dataframe(turmas_df, use_container_width=True, hide_index=True)
except Exception as error:
    st.error(f"Erro ao listar turmas: {error}")
    turmas_df = None

if professores_df is not None and turmas_df is not None and not professores_df.empty and not turmas_df.empty:
    professor_options = {
        f"{row.registro} - {row.nome}": row.registro for row in professores_df.itertuples()
    }
    turma_options = {
        f"{row.cod_turma} - {row.disciplina} / {row.ano_letivo}.{row.semestre}": row.cod_turma
        for row in turmas_df.itertuples()
    }

    st.subheader("Alocar professor em turma")
    with st.form("form_alocacao_professor"):
        professor_label = st.selectbox("Professor", list(professor_options.keys()))
        turma_label = st.selectbox("Turma", list(turma_options.keys()))
        papel = st.selectbox("Papel", ["titular", "auxiliar", "substituto"])
        alocar = st.form_submit_button("Alocar professor")

    if alocar:
        try:
            call_procedure(
                "sp_alocar_professor",
                [professor_options[professor_label], turma_options[turma_label], papel],
            )
            st.success("Professor alocado com sucesso.")
        except Exception as error:
            st.error(f"Erro ao alocar professor: {error}")

st.subheader("Professores alocados por turma")
try:
    alocacoes_df = run_query(
        """
        SELECT
            t.cod_turma,
            d.nome AS disciplina,
            p.registro,
            p.nome AS professor,
            pt.papel
        FROM professor_turma pt
        JOIN professor p ON p.registro = pt.registro_prof
        JOIN turma t ON t.cod_turma = pt.cod_turma
        JOIN disciplina d ON d.cod_disc = t.cod_disc
        ORDER BY t.cod_turma, pt.papel, p.nome
        """
    )
    st.dataframe(alocacoes_df, use_container_width=True, hide_index=True)
except Exception as error:
    st.error(f"Erro ao listar alocacoes: {error}")
