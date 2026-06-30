import streamlit as st

from database import execute_command, run_query


st.title("Relatorios")
st.write("Relatorios consolidados para apoio a demonstracao e a analise academica.")

report_options = {
    "Alunos por curso": """
        SELECT
            c.cod_curso,
            c.nome AS curso,
            COUNT(a.ra) AS total_alunos
        FROM curso c
        LEFT JOIN aluno a ON a.cod_curso = c.cod_curso
        GROUP BY c.cod_curso, c.nome
        ORDER BY c.nome
    """,
    "Alunos por turma": """
        SELECT
            t.cod_turma,
            d.nome AS disciplina,
            COUNT(at.ra_aluno) AS total_alunos
        FROM turma t
        JOIN disciplina d ON d.cod_disc = t.cod_disc
        LEFT JOIN aluno_turma at ON at.cod_turma = t.cod_turma
        GROUP BY t.cod_turma, d.nome
        ORDER BY t.cod_turma
    """,
    "Professores por turma": """
        SELECT
            t.cod_turma,
            d.nome AS disciplina,
            p.nome AS professor,
            pt.papel
        FROM professor_turma pt
        JOIN professor p ON p.registro = pt.registro_prof
        JOIN turma t ON t.cod_turma = pt.cod_turma
        JOIN disciplina d ON d.cod_disc = t.cod_disc
        ORDER BY t.cod_turma, p.nome
    """,
    "Turmas por departamento": """
        SELECT
            dep.nome AS departamento,
            dep.sigla,
            d.nome AS disciplina,
            t.cod_turma,
            t.ano_letivo,
            t.semestre
        FROM departamento dep
        JOIN disciplina d ON d.cod_depar = dep.cod_depar
        LEFT JOIN turma t ON t.cod_disc = d.cod_disc
        ORDER BY dep.nome, d.nome, t.cod_turma
    """,
    "Aprovacao/reprovacao por disciplina": """
        SELECT
            d.cod_disc,
            d.nome AS disciplina,
            COUNT(*) FILTER (WHERE at.status = 'aprovado') AS aprovados,
            COUNT(*) FILTER (WHERE at.status = 'reprovado') AS reprovados,
            COUNT(*) FILTER (WHERE at.status NOT IN ('aprovado', 'reprovado')) AS em_andamento
        FROM disciplina d
        LEFT JOIN turma t ON t.cod_disc = d.cod_disc
        LEFT JOIN aluno_turma at ON at.cod_turma = t.cod_turma
        GROUP BY d.cod_disc, d.nome
        ORDER BY d.nome
    """,
}

selected_report = st.selectbox("Selecione o relatorio", list(report_options.keys()))

try:
    report_df = run_query(report_options[selected_report])
    st.dataframe(report_df, use_container_width=True, hide_index=True)
except Exception as error:
    st.error(f"Erro ao gerar relatorio: {error}")

st.subheader("Gerenciar departamentos")

try:
    departamentos_df = run_query(
        """
        SELECT
            dep.cod_depar,
            dep.nome,
            dep.sigla,
            COUNT(d.cod_disc) AS total_disciplinas
        FROM departamento dep
        LEFT JOIN disciplina d ON d.cod_depar = dep.cod_depar
        GROUP BY dep.cod_depar, dep.nome, dep.sigla
        ORDER BY dep.nome
        """
    )
    st.dataframe(departamentos_df, use_container_width=True, hide_index=True)
except Exception as error:
    st.error(f"Erro ao carregar departamentos: {error}")
    departamentos_df = None

if departamentos_df is not None and not departamentos_df.empty:
    departamento_options = {
        f"{row.nome} ({row.sigla})": row.cod_depar
        for row in departamentos_df.itertuples()
    }

    departamento_label = st.selectbox(
        "Selecione o departamento",
        list(departamento_options.keys()),
    )
    departamento_selecionado = departamentos_df.loc[
        departamentos_df["cod_depar"] == departamento_options[departamento_label]
    ].iloc[0]

    st.write(f"Nome: {departamento_selecionado['nome']}")
    st.write(f"Sigla: {departamento_selecionado['sigla']}")
    st.write(
        "Quantidade de disciplinas vinculadas: "
        f"{departamento_selecionado['total_disciplinas']}"
    )

    with st.form("form_excluir_departamento"):
        confirmar_exclusao = st.checkbox(
            "Confirmo que desejo tentar excluir este departamento."
        )
        excluir_departamento = st.form_submit_button("Excluir departamento")

    if excluir_departamento:
        if not confirmar_exclusao:
            st.error("Confirme a exclusao antes de continuar.")
        else:
            try:
                execute_command(
                    """
                    DELETE FROM DEPARTAMENTO
                    WHERE cod_depar = %s
                    """,
                    [departamento_options[departamento_label]],
                )
                st.success("Departamento excluido com sucesso.")
            except Exception as error:
                st.error(f"Erro ao excluir departamento: {error}")
else:
    st.info("Nao ha departamentos disponiveis para gerenciamento.")
