-- ETAPA 3 - TRIGGERS

-- Francini
-- Objetivo: validar a UF do aluno.
-- Tabela: ALUNO
-- Evento: BEFORE INSERT OR UPDATE
-- Como testar: inserir aluno com UF = 'SP' deve funcionar; UF = 'SAO' deve falhar.
CREATE OR REPLACE FUNCTION fn_valida_uf_aluno()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.uf IS NOT NULL AND char_length(trim(NEW.uf)) <> 2 THEN
        RAISE EXCEPTION 'UF invalida. Informe exatamente 2 caracteres.';
    END IF;

    IF NEW.uf IS NOT NULL THEN
        NEW.uf := upper(trim(NEW.uf));
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_valida_uf_aluno ON aluno;
CREATE TRIGGER tg_valida_uf_aluno
BEFORE INSERT OR UPDATE ON aluno
FOR EACH ROW
EXECUTE FUNCTION fn_valida_uf_aluno();


-- Gustavo
-- Objetivo: impedir mais de um professor titular por turma.
-- Tabela: PROFESSOR_TURMA
-- Evento: BEFORE INSERT OR UPDATE
-- Como testar: inserir um titular em turma sem titular deve funcionar; inserir segundo titular na mesma turma deve falhar.
CREATE OR REPLACE FUNCTION fn_valida_papel_professor_turma()
RETURNS TRIGGER AS $$
BEGIN
    IF lower(coalesce(NEW.papel, '')) = 'titular' THEN
        IF EXISTS (
            SELECT 1
            FROM professor_turma pt
            WHERE pt.cod_turma = NEW.cod_turma
              AND lower(pt.papel) = 'titular'
              AND pt.registro_prof <> NEW.registro_prof
        ) THEN
            RAISE EXCEPTION 'A turma % ja possui professor titular.', NEW.cod_turma;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_valida_papel_professor_turma ON professor_turma;
CREATE TRIGGER tg_valida_papel_professor_turma
BEFORE INSERT OR UPDATE ON professor_turma
FOR EACH ROW
EXECUTE FUNCTION fn_valida_papel_professor_turma();


-- Marina
-- Objetivo: impedir pre-requisito circular simples e auto-relacao.
-- Tabela: DISCIPLINA_PRE_REQUISITO
-- Evento: BEFORE INSERT OR UPDATE
-- Como testar: inserir A -> B deve funcionar; inserir B -> A ou A -> A deve falhar.
CREATE OR REPLACE FUNCTION fn_impede_pre_requisito_circular_simples()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cod_disc = NEW.cod_disc_pre THEN
        RAISE EXCEPTION 'Uma disciplina nao pode ser pre-requisito dela mesma.';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM disciplina_pre_requisito dpr
        WHERE dpr.cod_disc = NEW.cod_disc_pre
          AND dpr.cod_disc_pre = NEW.cod_disc
    ) THEN
        RAISE EXCEPTION 'Pre-requisito circular simples detectado entre % e %.', NEW.cod_disc, NEW.cod_disc_pre;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_impede_pre_requisito_circular_simples ON disciplina_pre_requisito;
CREATE TRIGGER tg_impede_pre_requisito_circular_simples
BEFORE INSERT OR UPDATE ON disciplina_pre_requisito
FOR EACH ROW
EXECUTE FUNCTION fn_impede_pre_requisito_circular_simples();


-- Miguel
-- Objetivo: calcular automaticamente o percentual de frequencia.
-- Tabela: ALUNO_TURMA
-- Evento: BEFORE INSERT OR UPDATE
-- Como testar: alterar faltas em ALUNO_TURMA e observar o campo percentual_freq sendo recalculado.
CREATE OR REPLACE FUNCTION fn_calcula_percentual_frequencia()
RETURNS TRIGGER AS $$
DECLARE
    v_carga_total NUMERIC;
BEGIN
    SELECT fn_carga_total(t.cod_disc)
      INTO v_carga_total
    FROM turma t
    WHERE t.cod_turma = NEW.cod_turma;

    IF v_carga_total IS NULL OR v_carga_total <= 0 THEN
        NEW.percentual_freq := 0;
        RETURN NEW;
    END IF;

    NEW.percentual_freq := 100 - ((coalesce(NEW.faltas, 0)::NUMERIC / v_carga_total) * 100);

    IF NEW.percentual_freq < 0 THEN
        NEW.percentual_freq := 0;
    ELSIF NEW.percentual_freq > 100 THEN
        NEW.percentual_freq := 100;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_calcula_percentual_frequencia ON aluno_turma;
CREATE TRIGGER tg_calcula_percentual_frequencia
BEFORE INSERT OR UPDATE ON aluno_turma
FOR EACH ROW
EXECUTE FUNCTION fn_calcula_percentual_frequencia();


-- Salvatore
-- Objetivo: impedir exclusao de departamento com disciplinas vinculadas.
-- Tabela: DEPARTAMENTO
-- Evento: BEFORE DELETE
-- Como testar: excluir um departamento vazio deve funcionar; excluir um departamento com disciplinas deve falhar.
CREATE OR REPLACE FUNCTION fn_impede_exclusao_departamento_com_disciplinas()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM disciplina d
        WHERE d.cod_depar = OLD.cod_depar
    ) THEN
        RAISE EXCEPTION 'Nao e possivel excluir o departamento %. Existem disciplinas associadas.', OLD.cod_depar;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tg_impede_exclusao_departamento_com_disciplinas ON departamento;
CREATE TRIGGER tg_impede_exclusao_departamento_com_disciplinas
BEFORE DELETE ON departamento
FOR EACH ROW
EXECUTE FUNCTION fn_impede_exclusao_departamento_com_disciplinas();
