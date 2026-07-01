# PIBD Etapa 3 - Gestao Academica

Aplicacao funcional em Python + Streamlit para a Etapa 3 do projeto final de Projeto Integrador de Banco de Dados. O sistema consome diretamente o banco PostgreSQL `gestao_academica` com SQL explicito e cobre alunos, matriculas, turmas, professores, grade curricular, relatorios e demonstracoes individuais.

## Tecnologias usadas

- Python
- Streamlit
- PostgreSQL
- psycopg2-binary
- python-dotenv
- pandas

## Pre-requisitos

- Python 3.10 ou superior
- PostgreSQL em execucao
- Banco `gestao_academica` ja criado com as tabelas, procedures e functions da Etapa 2

## Configuracao do `.env`

1. Copie `.env.example` para `.env`.
2. Preencha as credenciais do seu PostgreSQL.

Exemplo:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=gestao_academica
DB_USER=postgres
DB_PASSWORD=sua_senha
```

## Ambiente virtual `.venv`

Antes de instalar as dependencias e iniciar a aplicacao, crie e ative o ambiente virtual:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Depois de ativado, o terminal deve indicar que o ambiente `.venv` esta em uso.

## Instalacao das dependencias

Com o ambiente virtual ativado, instale as dependencias:

```bash
pip install -r requirements.txt
```

## Execucao da aplicacao

Para iniciar a aplicacao, mantenha o ambiente virtual ativado e execute:

```bash
python3 -m streamlit run app.py
```

## Como rodar os scripts SQL da Etapa 3

Dentro do PostgreSQL, execute os arquivos na ordem:

1. `sql/etapa3_triggers.sql`
2. `sql/etapa3_consultas.sql`

Exemplo com `psql`:

```bash
psql -U postgres -d gestao_academica -f sql/etapa3_triggers.sql
psql -U postgres -d gestao_academica -f sql/etapa3_consultas.sql
```

## Estrutura do projeto

```text
.
├── app.py
├── database.py
├── requirements.txt
├── README.md
├── .env.example
├── sql/
│   ├── etapa2_01_tabelas.sql
│   ├── etapa2_02_indices.sql
│   ├── etapa2_03_dados.sql
│   ├── etapa2_04_procedures_functions_triggers.sql
│   ├── etapa3_consultas.sql
│   └── etapa3_triggers.sql
└── pages/
    ├── alunos.py
    ├── matriculas_notas.py
    ├── professores_turmas.py
    ├── grade_curricular.py
    ├── relatorios.py
    └── demonstracoes_individuais.py
```

## Descricao das paginas

- `app.py`: pagina inicial com resumo da aplicacao, status de conexao e roteiro rapido da demonstracao geral.
- `pages/alunos.py`: listagem de alunos com curso, cadastro de aluno, adicao de telefone com `CALL sp_adicionar_telefone` e consulta de telefones.
- `pages/matriculas_notas.py`: listagem de alunos e turmas, matricula com `CALL sp_matricular_aluno`, lancamento de nota/faltas e historico academico.
- `pages/professores_turmas.py`: listagem de professores e turmas, alocacao com `CALL sp_alocar_professor` e consulta das alocacoes.
- `pages/grade_curricular.py`: consulta de disciplinas por curso, carga total por `fn_carga_total`, pre-requisitos e equivalencias.
- `pages/relatorios.py`: relatorios de alunos por curso, alunos por turma, professores por turma, turmas por departamento e aprovacao por disciplina.
- `pages/demonstracoes_individuais.py`: apoio para os videos individuais com consultas SQL, explicacoes e instrucoes para testes de trigger.

## Responsabilidades individuais

- Francini: pagina Alunos, consulta individual de alunos com curso e telefones, trigger `tg_valida_uf_aluno`.
- Gustavo: pagina Professores e Turmas, consulta individual de professores, turmas e disciplinas, trigger `tg_valida_papel_professor_turma`.
- Marina: pagina Grade Curricular, consulta individual de cursos, disciplinas e pre-requisitos, trigger `tg_impede_pre_requisito_circular_simples`.
- Miguel: pagina Matriculas e Notas, integracao geral da aplicacao, consulta de historico academico, trigger `tg_calcula_percentual_frequencia`.
- Salvatore: pagina Relatorios, documentacao e consulta por departamento, trigger `tg_impede_exclusao_departamento_com_disciplinas`.

## Funcionalidades principais para o video geral

1. Cadastro e listagem de aluno.
2. Matricula de aluno em turma.
3. Lancamento de nota, faltas e frequencia.
4. Alocacao de professor em turma.
5. Exibicao de relatorio academico.

## Roteiro sugerido para o video geral

1. Mostrar a pagina inicial e confirmar a conexao com o banco.
2. Abrir `Alunos` e cadastrar um novo aluno.
3. Adicionar um telefone ao aluno e listar os telefones.
4. Abrir `Matriculas e Notas`, selecionar o aluno e matricular em uma turma.
5. Lancar nota e faltas para demonstrar o recalculo de frequencia.
6. Abrir `Professores e Turmas` e alocar um professor.
7. Finalizar com `Relatorios` mostrando um relatorio consolidado.

## Roteiro sugerido para os videos individuais

### Francini

1. Explicar o DER envolvendo ALUNO, CURSO e TELEFONE_ALUNO.
2. Rodar a consulta individual de alunos, curso e telefones.
3. Explicar o trigger `tg_valida_uf_aluno`.
4. Testar UF valida e UF invalida.
5. Mostrar a funcionalidade de cadastro de aluno ou telefone.

### Gustavo

1. Explicar o DER envolvendo PROFESSOR, PROFESSOR_TURMA, TURMA e DISCIPLINA.
2. Rodar a consulta individual de professores, turmas, disciplinas e papel.
3. Explicar o trigger `tg_valida_papel_professor_turma`.
4. Demonstrar uma alocacao valida e uma tentativa de segundo titular.
5. Mostrar a funcionalidade de alocacao de professor.

### Marina

1. Explicar o DER envolvendo CURSO, CURSO_DISCIPLINA, DISCIPLINA e DISCIPLINA_PRE_REQUISITO.
2. Rodar a consulta individual de cursos, disciplinas e pre-requisitos.
3. Explicar o trigger `tg_impede_pre_requisito_circular_simples`.
4. Demonstrar um cadastro valido e uma tentativa circular.
5. Mostrar a funcionalidade da pagina Grade Curricular.

### Miguel

1. Explicar o DER envolvendo ALUNO, CURSO, ALUNO_TURMA, TURMA e DISCIPLINA.
2. Rodar a consulta individual de historico academico.
3. Explicar o trigger `tg_calcula_percentual_frequencia`.
4. Atualizar faltas de uma matricula e mostrar o percentual recalculado.
5. Mostrar a funcionalidade de matricula ou lancamento de notas.

### Salvatore

1. Explicar o DER envolvendo DEPARTAMENTO, DISCIPLINA, TURMA e ALUNO_TURMA.
2. Rodar a consulta individual por departamento.
3. Explicar o trigger `tg_impede_exclusao_departamento_com_disciplinas`.
4. Demonstrar uma exclusao valida e uma exclusao bloqueada.
5. Mostrar a funcionalidade da pagina Relatorios.

## Observacoes

- A aplicacao usa SQL explicito e nao utiliza ORM.
- Todas as operacoes de escrita passam por commit/rollback dentro de `database.py`.
- As consultas sao exibidas com `pandas` em tabelas Streamlit.
- Para os prints da entrega, prefira registrar a tela inicial, uma pagina operacional e a pagina de demonstracoes individuais.
