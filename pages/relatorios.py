import streamlit as st

from database import run_query


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
