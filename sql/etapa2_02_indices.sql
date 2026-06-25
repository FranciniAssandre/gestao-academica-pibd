-- ============================================================
-- ETAPA 2 - CRIAÇÃO DE ÍNDICES
-- Gestão Acadêmica
-- Execute depois da criação das tabelas.
-- ============================================================

-- ÍNDICE 1: Busca de aluno por nome
CREATE INDEX IF NOT EXISTS idx_aluno_nome
ON ALUNO (nome);

-- ÍNDICE 2: Alunos por curso
CREATE INDEX IF NOT EXISTS idx_aluno_cod_curso
ON ALUNO (cod_curso);

-- ÍNDICE 3: Turmas por disciplina, ano e semestre
CREATE INDEX IF NOT EXISTS idx_turma_disc_periodo
ON TURMA (cod_disc, ano_letivo, semestre);

-- ÍNDICE 4: Matrículas por status
CREATE INDEX IF NOT EXISTS idx_aluno_turma_status
ON ALUNO_TURMA (status);

-- ÍNDICE 5: Matrículas por aluno
CREATE INDEX IF NOT EXISTS idx_aluno_turma_ra
ON ALUNO_TURMA (RA_aluno);

-- ÍNDICE 6: Disciplinas por departamento
CREATE INDEX IF NOT EXISTS idx_disciplina_depto
ON DISCIPLINA (cod_depar);

-- ÍNDICE 7: Professor por nome
CREATE INDEX IF NOT EXISTS idx_professor_nome
ON PROFESSOR (nome);
