-- ============================================================
-- LIMPEZA OPCIONAL
-- Use somente se o banco ainda não tiver nada importante.
-- ============================================================
DROP TABLE IF EXISTS DISCIPLINA_EQUIVALENCIA CASCADE;
DROP TABLE IF EXISTS DISCIPLINA_PRE_REQUISITO CASCADE;
DROP TABLE IF EXISTS PROFESSOR_TURMA CASCADE;
DROP TABLE IF EXISTS ALUNO_TURMA CASCADE;
DROP TABLE IF EXISTS CURSO_DISCIPLINA CASCADE;
DROP TABLE IF EXISTS TELEFONE_ALUNO CASCADE;
DROP TABLE IF EXISTS TURMA CASCADE;
DROP TABLE IF EXISTS DISCIPLINA CASCADE;
DROP TABLE IF EXISTS ALUNO CASCADE;
DROP TABLE IF EXISTS PROFESSOR CASCADE;
DROP TABLE IF EXISTS CURSO CASCADE;
DROP TABLE IF EXISTS DEPARTAMENTO CASCADE;

-- ============================================================
-- ENTIDADES INDEPENDENTES
-- ============================================================

CREATE TABLE DEPARTAMENTO (
    cod_depar SERIAL NOT NULL,
    nome VARCHAR(100) NOT NULL,
    sigla VARCHAR(10) NOT NULL,
    CONSTRAINT PK_DEPARTAMENTO PRIMARY KEY (cod_depar),
    CONSTRAINT UQ_DEPARTAMENTO_SIGLA UNIQUE (sigla)
);

CREATE TABLE CURSO (
    cod_curso SERIAL NOT NULL,
    nome VARCHAR(100) NOT NULL,
    carga_horaria INTEGER NOT NULL,
    CONSTRAINT PK_CURSO PRIMARY KEY (cod_curso),
    CONSTRAINT CK_CURSO_CARGA CHECK (carga_horaria > 0)
);

CREATE TABLE PROFESSOR (
    registro VARCHAR(20) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    formacao VARCHAR(100) NULL,
    CONSTRAINT PK_PROFESSOR PRIMARY KEY (registro)
);

-- ============================================================
-- ENTIDADES DEPENDENTES
-- ============================================================

CREATE TABLE ALUNO (
    RA SERIAL NOT NULL,
    nome VARCHAR(100) NOT NULL,
    data_nasc DATE NULL,
    logradouro VARCHAR(150) NULL,
    numero VARCHAR(10) NULL,
    bairro VARCHAR(80) NULL,
    cidade VARCHAR(80) NULL,
    uf CHAR(2) NULL,
    cep VARCHAR(9) NULL,
    cod_curso INTEGER NULL,
    CONSTRAINT PK_ALUNO PRIMARY KEY (RA),
    CONSTRAINT FK_ALUNO_CURSO
        FOREIGN KEY (cod_curso)
        REFERENCES CURSO(cod_curso)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE DISCIPLINA (
    cod_disc SERIAL NOT NULL,
    nome VARCHAR(100) NOT NULL,
    carga_teoria INTEGER NOT NULL DEFAULT 0,
    carga_pratica INTEGER NOT NULL DEFAULT 0,
    carga_extensao INTEGER NOT NULL DEFAULT 0,
    cod_depar INTEGER NULL,
    CONSTRAINT PK_DISCIPLINA PRIMARY KEY (cod_disc),
    CONSTRAINT FK_DISCIPLINA_DEPTO
        FOREIGN KEY (cod_depar)
        REFERENCES DEPARTAMENTO(cod_depar)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT CK_DISCIPLINA_TEORIA CHECK (carga_teoria >= 0),
    CONSTRAINT CK_DISCIPLINA_PRATICA CHECK (carga_pratica >= 0),
    CONSTRAINT CK_DISCIPLINA_EXTENSAO CHECK (carga_extensao >= 0)
);

CREATE TABLE TURMA (
    cod_turma SERIAL NOT NULL,
    sala VARCHAR(20) NULL,
    horario VARCHAR(50) NOT NULL,
    ano_letivo SMALLINT NOT NULL,
    semestre SMALLINT NOT NULL,
    cod_disc INTEGER NOT NULL,
    CONSTRAINT PK_TURMA PRIMARY KEY (cod_turma),
    CONSTRAINT FK_TURMA_DISCIPLINA
        FOREIGN KEY (cod_disc)
        REFERENCES DISCIPLINA(cod_disc)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT CK_TURMA_SEMESTRE CHECK (semestre IN (1, 2)),
    CONSTRAINT CK_TURMA_ANO CHECK (ano_letivo >= 2000)
);

-- ============================================================
-- ATRIBUTO MULTIVALORADO
-- ============================================================

CREATE TABLE TELEFONE_ALUNO (
    id_tel SERIAL NOT NULL,
    RA_aluno INTEGER NOT NULL,
    numero VARCHAR(20) NOT NULL,
    tipo_tel VARCHAR(20) NULL,
    CONSTRAINT PK_TELEFONE PRIMARY KEY (id_tel),
    CONSTRAINT FK_TELEFONE_ALUNO
        FOREIGN KEY (RA_aluno)
        REFERENCES ALUNO(RA)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CK_TELEFONE_TIPO
        CHECK (tipo_tel IN ('Celular', 'Residencial', 'Comercial'))
);

-- ============================================================
-- TABELAS DE RELACIONAMENTO N:N
-- ============================================================

CREATE TABLE CURSO_DISCIPLINA (
    cod_curso INTEGER NOT NULL,
    cod_disc INTEGER NOT NULL,
    CONSTRAINT PK_CURSO_DISCIPLINA PRIMARY KEY (cod_curso, cod_disc),
    CONSTRAINT FK_CD_CURSO
        FOREIGN KEY (cod_curso)
        REFERENCES CURSO(cod_curso)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_CD_DISCIPLINA
        FOREIGN KEY (cod_disc)
        REFERENCES DISCIPLINA(cod_disc)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE ALUNO_TURMA (
    RA_aluno INTEGER NOT NULL,
    cod_turma INTEGER NOT NULL,
    data_matricula DATE NOT NULL DEFAULT CURRENT_DATE,
    status VARCHAR(15) NOT NULL DEFAULT 'ativo',
    nota_final NUMERIC(4,1) NULL,
    faltas INTEGER NOT NULL DEFAULT 0,
    percentual_freq NUMERIC(5,2) NULL,
    CONSTRAINT PK_ALUNO_TURMA PRIMARY KEY (RA_aluno, cod_turma),
    CONSTRAINT FK_AT_ALUNO
        FOREIGN KEY (RA_aluno)
        REFERENCES ALUNO(RA)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_AT_TURMA
        FOREIGN KEY (cod_turma)
        REFERENCES TURMA(cod_turma)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CK_AT_NOTA
        CHECK (nota_final BETWEEN 0 AND 10),
    CONSTRAINT CK_AT_FALTAS
        CHECK (faltas >= 0),
    CONSTRAINT CK_AT_FREQ
        CHECK (percentual_freq BETWEEN 0 AND 100),
    CONSTRAINT CK_AT_STATUS
        CHECK (status IN ('ativo', 'trancado', 'aprovado', 'reprovado', 'cancelado'))
);

CREATE TABLE PROFESSOR_TURMA (
    cod_turma INTEGER NOT NULL,
    registro_prof VARCHAR(20) NOT NULL,
    papel VARCHAR(15) NOT NULL DEFAULT 'titular',
    CONSTRAINT PK_PROFESSOR_TURMA PRIMARY KEY (cod_turma, registro_prof),
    CONSTRAINT FK_PT_TURMA
        FOREIGN KEY (cod_turma)
        REFERENCES TURMA(cod_turma)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_PT_PROFESSOR
        FOREIGN KEY (registro_prof)
        REFERENCES PROFESSOR(registro)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CK_PT_PAPEL
        CHECK (papel IN ('titular', 'auxiliar', 'substituto'))
);

CREATE TABLE DISCIPLINA_PRE_REQUISITO (
    cod_disc INTEGER NOT NULL,
    cod_disc_pre INTEGER NOT NULL,
    CONSTRAINT PK_PRE_REQUISITO PRIMARY KEY (cod_disc, cod_disc_pre),
    CONSTRAINT FK_PR_DISC
        FOREIGN KEY (cod_disc)
        REFERENCES DISCIPLINA(cod_disc)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_PR_DISC_PRE
        FOREIGN KEY (cod_disc_pre)
        REFERENCES DISCIPLINA(cod_disc)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CK_PR_AUTO CHECK (cod_disc <> cod_disc_pre)
);

CREATE TABLE DISCIPLINA_EQUIVALENCIA (
    cod_disc_a INTEGER NOT NULL,
    cod_disc_b INTEGER NOT NULL,
    CONSTRAINT PK_EQUIVALENCIA PRIMARY KEY (cod_disc_a, cod_disc_b),
    CONSTRAINT FK_EQ_DISC_A
        FOREIGN KEY (cod_disc_a)
        REFERENCES DISCIPLINA(cod_disc)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_EQ_DISC_B
        FOREIGN KEY (cod_disc_b)
        REFERENCES DISCIPLINA(cod_disc)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT CK_EQ_AUTO CHECK (cod_disc_a <> cod_disc_b),
    CONSTRAINT CK_EQ_ORDEM CHECK (cod_disc_a < cod_disc_b)
);
