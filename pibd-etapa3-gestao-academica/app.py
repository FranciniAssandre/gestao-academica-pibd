import streamlit as st

from database import get_connection, get_connection_settings, run_query


st.set_page_config(
    page_title="PIBD Etapa 3 - Gestao Academica",
    page_icon="🎓",
    layout="wide",
    initial_sidebar_state="expanded",
)


def check_database_connection():
    try:
        connection = get_connection()
        connection.close()
        return True, "Conexao com PostgreSQL realizada com sucesso."
    except Exception as error:
        return False, f"Falha ao conectar ao banco: {error}"


st.title("Sistema de Gestao Academica")
st.write(
    "Aplicacao Streamlit da Etapa 3 do projeto final de PIBD com foco em alunos, "
    "matriculas, turmas, notas, grade curricular e relatorios."
)

ok, message = check_database_connection()
if ok:
    st.success(message)
else:
    st.error(message)
    st.caption("Configuracao atual de conexao:")
    st.json(get_connection_settings(), expanded=False)

st.sidebar.title("Menu")
st.sidebar.info(
    "Use o menu lateral do Streamlit para navegar entre as paginas da aplicacao."
)

st.subheader("Visao Geral")
col1, col2 = st.columns(2)

with col1:
    st.markdown(
        """
        - Cadastro e listagem de alunos e telefones.
        - Matricula de aluno em turma usando procedure.
        - Lancamento de nota final, faltas e frequencia.
        - Alocacao de professores em turmas.
        - Consulta de grade curricular e relatorios.
        """
    )

with col2:
    try:
        summary = run_query(
            """
            SELECT
                (SELECT COUNT(*) FROM aluno) AS total_alunos,
                (SELECT COUNT(*) FROM professor) AS total_professores,
                (SELECT COUNT(*) FROM turma) AS total_turmas,
                (SELECT COUNT(*) FROM disciplina) AS total_disciplinas
            """
        )
        st.dataframe(summary, use_container_width=True, hide_index=True)
    except Exception as error:
        st.warning(f"Nao foi possivel carregar o resumo inicial: {error}")

st.subheader("Fluxo recomendado para a demonstracao geral")
st.markdown(
    """
    1. Acesse **Alunos** para cadastrar ou listar alunos.
    2. Abra **Matriculas e Notas** para matricular um aluno em uma turma.
    3. Lance nota, faltas e frequencia na mesma pagina.
    4. Va para **Professores e Turmas** para alocar um professor.
    5. Finalize em **Relatorios** ou **Demonstracoes Individuais**.
    """
)
