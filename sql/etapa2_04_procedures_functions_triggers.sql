-- ============================================================
-- ETAPA 2 - PROCEDURES, FUNCTIONS E TRIGGERS
-- Gestão Acadêmica
-- ============================================================

-- ============================================================
-- PROCEDURE 1: Matricular aluno em uma turma
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_matricular_aluno(
    p_ra INTEGER,
    p_cod_turma INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO ALUNO_TURMA (
        RA_aluno,
        cod_turma,
        data_matricula,
        status,
        faltas
    )
    VALUES (
        p_ra,
        p_cod_turma,
        CURRENT_DATE,
        'ativo',
        0
    );

    RAISE NOTICE 'Aluno RA=% matriculado na turma % com sucesso.',
        p_ra, p_cod_turma;

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Aluno RA=% já está matriculado na turma %.',
            p_ra, p_cod_turma;
END;
$$;

-- ============================================================
-- PROCEDURE 2: Registrar telefone para um aluno
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_adicionar_telefone(
    p_ra INTEGER,
    p_numero VARCHAR(20),
    p_tipo VARCHAR(15)
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_tipo NOT IN ('Celular', 'Residencial', 'Comercial') THEN
        RAISE EXCEPTION
            'Tipo de telefone inválido: %. Use Celular, Residencial ou Comercial.',
            p_tipo;
    END IF;

    INSERT INTO TELEFONE_ALUNO (
        RA_aluno,
        numero,
        tipo_tel
    )
    VALUES (
        p_ra,
        p_numero,
        p_tipo
    );

    RAISE NOTICE 'Telefone % (%) adicionado para o aluno RA=%.',
        p_numero, p_tipo, p_ra;
END;
$$;

-- ============================================================
-- PROCEDURE 3: Alocar professor em uma turma
-- ============================================================

CREATE OR REPLACE PROCEDURE sp_alocar_professor(
    p_registro VARCHAR(20),
    p_cod_turma INTEGER,
    p_papel VARCHAR(15) DEFAULT 'titular'
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_papel NOT IN ('titular', 'auxiliar', 'substituto') THEN
        RAISE EXCEPTION
            'Papel inválido: %. Use titular, auxiliar ou substituto.',
            p_papel;
    END IF;

    INSERT INTO PROFESSOR_TURMA (
        cod_turma,
        registro_prof,
        papel
    )
    VALUES (
        p_cod_turma,
        p_registro,
        p_papel
    );

    RAISE NOTICE 'Professor % alocado na turma % como %.',
        p_registro, p_cod_turma, p_papel;

EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE 'Professor % já está alocado na turma %.',
            p_registro, p_cod_turma;
END;
$$;

-- ============================================================
-- FUNCTION 1: Carga horária total de uma disciplina
-- ============================================================

CREATE OR REPLACE FUNCTION fn_carga_total(
    p_cod_disc INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT
        carga_teoria + carga_pratica + carga_extensao
    INTO v_total
    FROM DISCIPLINA
    WHERE cod_disc = p_cod_disc;

    RETURN v_total;
END;
$$;

-- ============================================================
-- FUNCTION 2: Total de alunos ativos em uma turma
-- ============================================================

CREATE OR REPLACE FUNCTION fn_total_alunos_ativos(
    p_cod_turma INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
BEGIN
    SELECT COUNT(*)
    INTO v_total
    FROM ALUNO_TURMA
    WHERE cod_turma = p_cod_turma
      AND status = 'ativo';

    RETURN v_total;
END;
$$;

-- ============================================================
-- FUNCTION 3: Verifica se aluno está aprovado em uma turma
-- ============================================================

CREATE OR REPLACE FUNCTION fn_aluno_aprovado(
    p_ra INTEGER,
    p_cod_turma INTEGER
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_nota NUMERIC(4,1);
    v_freq NUMERIC(5,2);
BEGIN
    SELECT
        nota_final,
        percentual_freq
    INTO
        v_nota,
        v_freq
    FROM ALUNO_TURMA
    WHERE RA_aluno = p_ra
      AND cod_turma = p_cod_turma;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    RETURN (v_nota >= 5.0 AND v_freq >= 75.0);
END;
$$;

-- ============================================================
-- TRIGGER 1: Bloqueia data de nascimento futura
-- ============================================================

CREATE OR REPLACE FUNCTION fn_tg_valida_data_nasc()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.data_nasc > CURRENT_DATE THEN
        RAISE EXCEPTION
            'Data de nascimento inválida: % é uma data futura.',
            NEW.data_nasc;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_valida_data_nasc ON ALUNO;

CREATE TRIGGER tg_valida_data_nasc
BEFORE INSERT OR UPDATE ON ALUNO
FOR EACH ROW
EXECUTE FUNCTION fn_tg_valida_data_nasc();

-- ============================================================
-- TRIGGER 2: Atualiza status automaticamente ao registrar nota
-- ============================================================

CREATE OR REPLACE FUNCTION fn_tg_atualiza_status()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.nota_final IS NOT NULL
       AND NEW.percentual_freq IS NOT NULL THEN

        IF NEW.nota_final >= 5.0
           AND NEW.percentual_freq >= 75.0 THEN
            NEW.status := 'aprovado';
        ELSE
            NEW.status := 'reprovado';
        END IF;

    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_atualiza_status ON ALUNO_TURMA;

CREATE TRIGGER tg_atualiza_status
BEFORE UPDATE ON ALUNO_TURMA
FOR EACH ROW
EXECUTE FUNCTION fn_tg_atualiza_status();

-- ============================================================
-- TRIGGER 3: Impede matrícula sem pré-requisito cumprido
-- ============================================================

CREATE OR REPLACE FUNCTION fn_tg_verifica_pre_requisito()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_cod_disc INTEGER;
    v_cod_disc_pre INTEGER;
BEGIN
    SELECT cod_disc
    INTO v_cod_disc
    FROM TURMA
    WHERE cod_turma = NEW.cod_turma;

    FOR v_cod_disc_pre IN
        SELECT cod_disc_pre
        FROM DISCIPLINA_PRE_REQUISITO
        WHERE cod_disc = v_cod_disc
    LOOP
        PERFORM at.RA_aluno
        FROM ALUNO_TURMA at
        JOIN TURMA t
          ON t.cod_turma = at.cod_turma
        WHERE at.RA_aluno = NEW.RA_aluno
          AND t.cod_disc = v_cod_disc_pre
          AND at.status = 'aprovado'
        LIMIT 1;

        IF NOT FOUND THEN
            RAISE EXCEPTION
                'Pré-requisito não cumprido: aluno RA=% não foi aprovado na disciplina cod=%.',
                NEW.RA_aluno,
                v_cod_disc_pre;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS tg_verifica_pre_requisito ON ALUNO_TURMA;

CREATE TRIGGER tg_verifica_pre_requisito
BEFORE INSERT ON ALUNO_TURMA
FOR EACH ROW
EXECUTE FUNCTION fn_tg_verifica_pre_requisito();
