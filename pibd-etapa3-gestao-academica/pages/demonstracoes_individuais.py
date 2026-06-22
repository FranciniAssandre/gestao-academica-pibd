import streamlit as st

from database import run_query


st.title("Demonstracoes Individuais")
st.write(
    "Apoio para a gravacao dos videos individuais com consulta SQL, explicacao e teste de trigger."
)

consultas = {
    "Francini": {
        "query": """
            SELECT
                a.ra,
                a.nome AS aluno,
                c.nome AS curso,
                ta.numero AS telefone,
                ta.tipo_tel
            FROM aluno a
            JOIN curso c ON c.cod_curso = a.cod_curso
            LEFT JOIN telefone_aluno ta ON ta.ra_aluno = a.ra
            ORDER BY a.nome, ta.id_tel
        """,
        "explicacao": "Usa as entidades ALUNO, CURSO e TELEFONE_ALUNO. Os relacionamentos mostrados sao aluno pertence a curso e aluno possui telefone.",
        "trigger": "Trigger da integrante: tg_valida_uf_aluno. Ele valida se a UF do aluno tem exatamente 2 caracteres em INSERT ou UPDATE.",
        "teste": "Teste sugerido: na pagina Alunos, cadastre ou edite um aluno usando UF = 'SP' para sucesso e UF = 'SAO' para falha.",
    },
    "Gustavo": {
        "query": """
            SELECT
                p.registro,
                p.nome AS professor,
                t.cod_turma,
                d.nome AS disciplina,
                pt.papel
            FROM professor p
            JOIN professor_turma pt ON pt.registro_prof = p.registro
            JOIN turma t ON t.cod_turma = pt.cod_turma
            JOIN disciplina d ON d.cod_disc = t.cod_disc
            ORDER BY p.nome, t.cod_turma
        """,
        "explicacao": "Usa PROFESSOR, PROFESSOR_TURMA, TURMA e DISCIPLINA. Os relacionamentos sao professor ministra turma e turma pertence a disciplina.",
        "trigger": "Trigger do integrante: tg_valida_papel_professor_turma. Ele impede mais de um professor titular na mesma turma.",
        "teste": "Teste sugerido: aloque um professor como titular em uma turma sem titular e depois tente alocar outro titular na mesma turma para provocar a excecao.",
    },
    "Marina": {
        "query": """
            SELECT
                c.nome AS curso,
                d.nome AS disciplina,
                pre.nome AS pre_requisito
            FROM curso c
            JOIN curso_disciplina cd ON cd.cod_curso = c.cod_curso
            JOIN disciplina d ON d.cod_disc = cd.cod_disc
            LEFT JOIN disciplina_pre_requisito dpr ON dpr.cod_disc = d.cod_disc
            LEFT JOIN disciplina pre ON pre.cod_disc = dpr.cod_disc_pre
            ORDER BY c.nome, d.nome, pre.nome
        """,
        "explicacao": "Usa CURSO, CURSO_DISCIPLINA, DISCIPLINA e DISCIPLINA_PRE_REQUISITO. Os relacionamentos sao curso possui disciplina e disciplina possui pre-requisito.",
        "trigger": "Trigger da integrante: tg_impede_pre_requisito_circular_simples. Ele bloqueia auto-relacao e ciclo simples A-B / B-A.",
        "teste": "Teste sugerido: insira um pre-requisito valido e depois tente cadastrar a relacao inversa ou a mesma disciplina como pre-requisito dela mesma.",
    },
    "Miguel": {
        "query": """
            SELECT
                a.ra,
                a.nome AS aluno,
                c.nome AS curso,
                d.nome AS disciplina,
                t.cod_turma,
                at.nota_final,
                at.faltas,
                at.percentual_freq,
                at.status
            FROM aluno a
            JOIN curso c ON c.cod_curso = a.cod_curso
            JOIN aluno_turma at ON at.ra_aluno = a.ra
            JOIN turma t ON t.cod_turma = at.cod_turma
            JOIN disciplina d ON d.cod_disc = t.cod_disc
            ORDER BY a.nome, d.nome
        """,
        "explicacao": "Usa ALUNO, CURSO, ALUNO_TURMA, TURMA e DISCIPLINA. Os relacionamentos sao aluno pertence a curso, aluno frequenta turma e turma pertence a disciplina.",
        "trigger": "Trigger do integrante: tg_calcula_percentual_frequencia. Ele calcula automaticamente a frequencia a partir das faltas e da carga total da disciplina.",
        "teste": "Teste sugerido: na pagina Matriculas e Notas, atualize as faltas de uma matricula e mostre que o campo percentual_freq foi recalculado automaticamente.",
    },
    "Salvatore": {
        "query": """
            SELECT
                dep.nome AS departamento,
                d.nome AS disciplina,
                t.cod_turma,
                COUNT(at.ra_aluno) AS total_matriculados
            FROM departamento dep
            JOIN disciplina d ON d.cod_depar = dep.cod_depar
            LEFT JOIN turma t ON t.cod_disc = d.cod_disc
            LEFT JOIN aluno_turma at ON at.cod_turma = t.cod_turma
            GROUP BY dep.nome, d.nome, t.cod_turma
            ORDER BY dep.nome, d.nome, t.cod_turma
        """,
        "explicacao": "Usa DEPARTAMENTO, DISCIPLINA, TURMA e ALUNO_TURMA. Os relacionamentos sao departamento oferece disciplina, disciplina gera turma e turma recebe alunos por ALUNO_TURMA.",
        "trigger": "Trigger do integrante: tg_impede_exclusao_departamento_com_disciplinas. Ele bloqueia a exclusao de um departamento que ainda possui disciplinas.",
        "teste": "Teste sugerido: tente excluir um departamento sem disciplinas para sucesso e depois um departamento com disciplinas vinculadas para ver a excecao.",
    },
}

for integrante, dados in consultas.items():
    with st.expander(integrante, expanded=integrante == "Francini"):
        if st.button(f"Rodar consulta SQL de {integrante}", key=f"btn_{integrante}"):
            try:
                consulta_df = run_query(dados["query"])
                st.dataframe(consulta_df, use_container_width=True, hide_index=True)
            except Exception as error:
                st.error(f"Erro ao executar consulta de {integrante}: {error}")

        st.write(dados["explicacao"])
        st.info(dados["trigger"])
        st.code(dados["teste"], language="text")
