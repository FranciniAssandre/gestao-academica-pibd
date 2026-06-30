import streamlit as st

from database import call_procedure, execute_command, run_query


st.title("Alunos")
st.write("Cadastre alunos, associe telefones e consulte o curso de cada registro.")


def load_cursos():
    return run_query(
        """
        SELECT cod_curso, nome
        FROM curso
        ORDER BY nome
        """
    )


def load_alunos():
    return run_query(
        """
        SELECT
            a.ra,
            a.nome AS aluno,
            a.data_nasc,
            a.cidade,
            a.uf,
            c.nome AS curso
        FROM aluno a
        JOIN curso c ON c.cod_curso = a.cod_curso
        ORDER BY a.nome
        """
    )


st.subheader("Listagem de alunos com curso")
try:
    alunos_df = load_alunos()
    st.dataframe(alunos_df, use_container_width=True, hide_index=True)
except Exception as error:
    st.error(f"Erro ao listar alunos: {error}")
    alunos_df = None

st.subheader("Cadastrar novo aluno")
try:
    cursos_df = load_cursos()
    curso_options = {
        f"{row.cod_curso} - {row.nome}": row.cod_curso for row in cursos_df.itertuples()
    }
except Exception as error:
    st.error(f"Erro ao carregar cursos: {error}")
    curso_options = {}

with st.form("form_novo_aluno"):
    col1, col2 = st.columns(2)
    with col1:
        ra = st.number_input("RA", min_value=1, step=1)
        nome = st.text_input("Nome")
        data_nasc = st.date_input("Data de nascimento")
        logradouro = st.text_input("Logradouro")
        numero = st.text_input("Numero")
    with col2:
        bairro = st.text_input("Bairro")
        cidade = st.text_input("Cidade")
        uf = st.text_input("UF", max_chars=2)
        cep = st.text_input("CEP")
        curso_label = st.selectbox(
            "Curso",
            list(curso_options.keys()) if curso_options else ["Nenhum curso disponivel"],
        )
    submitted = st.form_submit_button("Cadastrar aluno")

if submitted:
    if not curso_options:
        st.error("Nao ha cursos cadastrados para vincular ao aluno.")
    elif not nome.strip():
        st.error("Informe o nome do aluno.")
    else:
        try:
            execute_command(
                """
                INSERT INTO aluno (
                    ra, nome, data_nasc, logradouro, numero, bairro, cidade, uf, cep, cod_curso
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    int(ra),
                    nome.strip(),
                    data_nasc,
                    logradouro.strip() or None,
                    numero.strip() or None,
                    bairro.strip() or None,
                    cidade.strip() or None,
                    uf.strip().upper() or None,
                    cep.strip() or None,
                    curso_options[curso_label],
                ),
            )
            st.success("Aluno cadastrado com sucesso.")
        except Exception as error:
            st.error(f"Erro ao cadastrar aluno: {error}")

st.subheader("Adicionar telefone ao aluno")
if alunos_df is not None and not alunos_df.empty:
    aluno_options = {
        f"{row.ra} - {row.aluno}": row.ra for row in alunos_df.itertuples()
    }
    with st.form("form_telefone_aluno"):
        aluno_label = st.selectbox("Aluno", list(aluno_options.keys()))
        numero_tel = st.text_input("Numero do telefone")
        tipo_tel = st.selectbox("Tipo", ["Celular", "Residencial", "Comercial"])
        add_phone = st.form_submit_button("Adicionar telefone")

    if add_phone:
        try:
            call_procedure(
                "sp_adicionar_telefone",
                [aluno_options[aluno_label], numero_tel.strip(), tipo_tel],
            )
            st.success("Telefone adicionado com sucesso.")
        except Exception as error:
            st.error(f"Erro ao adicionar telefone: {error}")

    st.subheader("Listar telefones de um aluno")
    selected_student = st.selectbox(
        "Selecione o aluno para ver os telefones",
        list(aluno_options.keys()),
        key="telefones_aluno",
    )
    try:
        telefones_df = run_query(
            """
            SELECT id_tel, numero, tipo_tel
            FROM telefone_aluno
            WHERE ra_aluno = %s
            ORDER BY id_tel
            """,
            [aluno_options[selected_student]],
        )
        st.dataframe(telefones_df, use_container_width=True, hide_index=True)
    except Exception as error:
        st.error(f"Erro ao listar telefones: {error}")
else:
    st.info("Cadastre ou carregue alunos para habilitar o cadastro de telefones.")
