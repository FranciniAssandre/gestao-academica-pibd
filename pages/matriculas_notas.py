import streamlit as st

from database import call_procedure, execute_command, run_query


st.title("Matriculas e Notas")
st.write(
    "Matricule alunos em turmas, lance notas e acompanhe o historico academico."
)


def load_alunos():
    return run_query(
        """
        SELECT a.ra, a.nome, c.nome AS curso
        FROM aluno a
        JOIN curso c ON c.cod_curso = a.cod_curso
        ORDER BY a.nome
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
            t.horario,
            fn_total_alunos_ativos(t.cod_turma) AS alunos_ativos
        FROM turma t
        JOIN disciplina d ON d.cod_disc = t.cod_disc
        ORDER BY t.ano_letivo DESC, t.semestre DESC, d.nome
        """
    )


def load_matriculas():
    return run_query(
        """
        SELECT
            at.ra_aluno,
            a.nome AS aluno,
            at.cod_turma,
            d.nome AS disciplina,
            at.status,
            at.nota_final,
            at.faltas,
            at.percentual_freq
        FROM aluno_turma at
        JOIN aluno a ON a.ra = at.ra_aluno
        JOIN turma t ON t.cod_turma = at.cod_turma
        JOIN disciplina d ON d.cod_disc = t.cod_disc
        ORDER BY a.nome, d.nome
        """
    )


st.subheader("Alunos")
try:
    alunos_df = load_alunos()
    st.dataframe(alunos_df, use_container_width=True, hide_index=True)
    aluno_options = {
        f"{row.ra} - {row.nome} ({row.curso})": row.ra for row in alunos_df.itertuples()
    }
except Exception as error:
    st.error(f"Erro ao listar alunos: {error}")
    alunos_df = None
    aluno_options = {}

st.subheader("Turmas disponiveis")
try:
    turmas_df = load_turmas()
    st.dataframe(turmas_df, use_container_width=True, hide_index=True)
except Exception as error:
    st.error(f"Erro ao listar turmas: {error}")
    turmas_df = None

if alunos_df is not None and turmas_df is not None and not alunos_df.empty and not turmas_df.empty:
    turma_options = {
        f"{row.cod_turma} - {row.disciplina} / {row.ano_letivo}.{row.semestre}": row.cod_turma
        for row in turmas_df.itertuples()
    }

    st.subheader("Matricular aluno em turma")
    with st.form("form_matricula"):
        aluno_label = st.selectbox("Aluno", list(aluno_options.keys()))
        turma_label = st.selectbox("Turma", list(turma_options.keys()))
        matricular = st.form_submit_button("Matricular aluno")

    if matricular:
        try:
            call_procedure(
                "sp_matricular_aluno",
                [aluno_options[aluno_label], turma_options[turma_label]],
            )
            st.success("Matricula realizada com sucesso.")
        except Exception as error:
            st.error(f"Erro ao matricular aluno: {error}")

st.subheader("Lancamento de nota e frequencia")
try:
    matriculas_df = load_matriculas()
    if matriculas_df.empty:
        st.info("Nao ha matriculas registradas.")
    else:
        matricula_options = {
            f"{row.ra_aluno} - {row.aluno} / Turma {row.cod_turma} / {row.disciplina}": (
                row.ra_aluno,
                row.cod_turma,
            )
            for row in matriculas_df.itertuples()
        }
        with st.form("form_notas"):
            matricula_label = st.selectbox("Matricula", list(matricula_options.keys()))
            nota_final = st.number_input("Nota final", min_value=0.0, max_value=10.0, step=0.1)
            faltas = st.number_input("Faltas", min_value=0, step=1)
            status = st.selectbox(
                "Status",
                ["matriculado", "cursando", "aprovado", "reprovado", "trancado"],
            )
            salvar_nota = st.form_submit_button("Salvar dados academicos")

        if salvar_nota:
            ra_aluno, cod_turma = matricula_options[matricula_label]
            try:
                execute_command(
                    """
                    UPDATE aluno_turma
                    SET nota_final = %s,
                        faltas = %s,
                        status = %s
                    WHERE ra_aluno = %s
                      AND cod_turma = %s
                    """,
                    (nota_final, int(faltas), status, ra_aluno, cod_turma),
                )
                st.success(
                    "Dados atualizados com sucesso. O percentual de frequencia sera recalculado pelo trigger."
                )
            except Exception as error:
                st.error(f"Erro ao lancar nota/frequencia: {error}")
except Exception as error:
    st.error(f"Erro ao carregar matriculas: {error}")

st.subheader("Historico academico do aluno")
if alunos_df is not None and not alunos_df.empty:
    aluno_historico = st.selectbox(
        "Selecione o aluno",
        list(aluno_options.keys()),
        key="historico_aluno",
    )
    try:
        historico_df = run_query(
            """
            SELECT
                a.ra,
                a.nome AS aluno,
                c.nome AS curso,
                d.nome AS disciplina,
                t.cod_turma,
                t.ano_letivo,
                t.semestre,
                at.status,
                at.nota_final,
                at.faltas,
                at.percentual_freq,
                fn_aluno_aprovado(a.ra, t.cod_turma) AS aprovado
            FROM aluno a
            JOIN curso c ON c.cod_curso = a.cod_curso
            LEFT JOIN aluno_turma at ON at.ra_aluno = a.ra
            LEFT JOIN turma t ON t.cod_turma = at.cod_turma
            LEFT JOIN disciplina d ON d.cod_disc = t.cod_disc
            WHERE a.ra = %s
            ORDER BY t.ano_letivo DESC NULLS LAST, t.semestre DESC NULLS LAST, d.nome
            """,
            [aluno_options[aluno_historico]],
        )
        st.dataframe(historico_df, use_container_width=True, hide_index=True)
    except Exception as error:
        st.error(f"Erro ao carregar historico: {error}")
