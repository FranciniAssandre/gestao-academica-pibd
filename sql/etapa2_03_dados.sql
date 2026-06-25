-- ============================================================
-- ETAPA 2 - INSERÇÃO DE DADOS DE TESTE
-- Gestão Acadêmica
--
-- ATENÇÃO:
-- Este script limpa as tabelas e reinsere os dados de teste.
-- Execute depois da criação das tabelas e índices.
-- Execute antes dos triggers que validam pré-requisitos.
-- ============================================================

TRUNCATE TABLE
    DISCIPLINA_EQUIVALENCIA,
    DISCIPLINA_PRE_REQUISITO,
    PROFESSOR_TURMA,
    ALUNO_TURMA,
    CURSO_DISCIPLINA,
    TELEFONE_ALUNO,
    TURMA,
    DISCIPLINA,
    ALUNO,
    PROFESSOR,
    CURSO,
    DEPARTAMENTO
RESTART IDENTITY CASCADE;

-- ============================================================
-- 1. DEPARTAMENTO (10 registros)
-- ============================================================
INSERT INTO DEPARTAMENTO (nome, sigla) VALUES
('Tecnologia da Informação', 'TI'),
('Ciências Humanas', 'CH'),
('Ciências da Saúde', 'CS'),
('Engenharias', 'ENG'),
('Artes e Design', 'ART'),
('Matemática', 'MAT'),
('Física', 'FIS'),
('Química', 'QUI'),
('Letras e Linguística', 'LET'),
('Ciências Sociais', 'SOC');

-- ============================================================
-- 2. CURSO (10 registros)
-- ============================================================
INSERT INTO CURSO (nome, carga_horaria) VALUES
('Sistemas de Informação', 3000),
('Direito', 4000),
('Medicina', 8000),
('Engenharia Civil', 3600),
('Design Gráfico', 2800),
('Ciência da Computação', 3200),
('Matemática Aplicada', 2400),
('Enfermagem', 4000),
('Letras - Português', 2400),
('Engenharia Elétrica', 3600);

-- ============================================================
-- 3. PROFESSOR (10 registros)
-- ============================================================
INSERT INTO PROFESSOR (registro, nome, formacao) VALUES
('P001', 'Ricardo Silva', 'Doutorado em Inteligência Artificial'),
('P002', 'Maria Oliveira', 'Mestrado em Direito Civil'),
('P003', 'Carlos Souza', 'Doutorado em Cardiologia'),
('P004', 'Ana Costa', 'Mestrado em Estruturas'),
('P005', 'Bruno Lima', 'Especialização em UX Design'),
('P006', 'Fernanda Dias', 'Doutorado em Algoritmos'),
('P007', 'Gabriel Mendes', 'Mestrado em História'),
('P008', 'Juliana Moraes', 'Doutorado em Genética'),
('P009', 'Lucas Neto', 'Especialização em Redes'),
('P010', 'Patricia Campos', 'Mestrado em Design Gráfico');

-- ============================================================
-- 4. DISCIPLINA (10 registros)
-- ============================================================
INSERT INTO DISCIPLINA (nome, carga_teoria, carga_pratica, carga_extensao, cod_depar) VALUES
('Algoritmos I', 40, 40, 20, 1),
('Banco de Dados', 40, 40, 0, 1),
('Direito Penal', 60, 0, 20, 2),
('Anatomia Humana', 20, 80, 0, 3),
('Cálculo Estrutural', 60, 20, 20, 4),
('Teoria das Cores', 30, 30, 0, 5),
('Redes de Computadores', 40, 40, 20, 1),
('Ética Médica', 40, 0, 0, 3),
('Processo Civil', 80, 0, 0, 2),
('Sistemas Operacionais', 40, 40, 0, 1);

-- ============================================================
-- 5. ALUNO (10 registros)
-- ============================================================
INSERT INTO ALUNO (nome, data_nasc, logradouro, numero, bairro, cidade, uf, cep, cod_curso) VALUES
('João Pedro', '2002-01-10', 'Rua das Flores', '123', 'Centro', 'São Carlos', 'SP', '13560-000', 1),
('Maria Eduarda', '2003-05-15', 'Av. Brasil', '456', 'Jardim Bela', 'São Carlos', 'SP', '13561-100', 1),
('Lucas Santos', '2001-11-20', 'Rua 7 de Setembro', '78', 'Vila Nova', 'Araraquara', 'SP', '14800-010', 2),
('Beatriz Lima', '2002-08-30', NULL, NULL, NULL, 'Ribeirão Preto', 'SP', NULL, 2),
('Gabriel Ferreira', '2000-03-12', 'Rua das Palmeiras', '99', 'Jardim Europa', 'São Paulo', 'SP', '01310-100', 3),
('Letícia Alves', '2004-07-05', 'Av. Paulista', '1000', 'Bela Vista', 'São Paulo', 'SP', '01310-200', 3),
('Rafael Rocha', '2002-12-25', 'Rua Ipiranga', '55', 'Centro', 'Campinas', 'SP', '13010-050', 4),
('Isabela Souza', '2003-04-18', NULL, NULL, NULL, 'Campinas', 'SP', NULL, 4),
('Matheus Henrique', '2001-09-09', 'Rua da Saudade', '200', 'Pinheiros', 'São Paulo', 'SP', '05422-000', 5),
('Sophia Campos', '2002-06-21', 'Rua Augusta', '300', 'Consolação', 'São Paulo', 'SP', '01304-000', 5);

-- ============================================================
-- 6. TURMA (10 registros)
-- ============================================================
INSERT INTO TURMA (sala, horario, ano_letivo, semestre, cod_disc) VALUES
('Lab 01', 'Segunda 19:00', 2025, 1, 1),
('Lab 02', 'Terça 19:00', 2025, 1, 2),
('Auditório A', 'Quarta 08:00', 2025, 1, 3),
('Lab Anatomia', 'Quinta 14:00', 2025, 1, 4),
('Sala 202', 'Sexta 19:00', 2025, 1, 5),
('Ateliê 1', 'Segunda 08:00', 2025, 2, 6),
('Lab 03', 'Terça 21:00', 2025, 2, 7),
('Sala 105', 'Quarta 14:00', 2025, 2, 8),
('Sala 303', 'Quinta 19:00', 2025, 2, 9),
('Lab 01', 'Sexta 21:00', 2025, 2, 10);

-- ============================================================
-- 7. TELEFONE_ALUNO (12 registros)
-- ============================================================
INSERT INTO TELEFONE_ALUNO (RA_aluno, numero, tipo_tel) VALUES
(1, '(16) 99801-1111', 'Celular'),
(1, '(16) 3307-2222', 'Residencial'),
(2, '(16) 99802-3333', 'Celular'),
(3, '(16) 99803-4444', 'Celular'),
(4, '(16) 99804-5555', 'Celular'),
(5, '(11) 99805-6666', 'Celular'),
(6, '(11) 99806-7777', 'Celular'),
(7, '(19) 99807-8888', 'Celular'),
(8, '(19) 99808-9999', 'Celular'),
(9, '(11) 99809-0000', 'Celular'),
(10, '(11) 99810-1111', 'Celular'),
(10, '(11) 3308-2222', 'Residencial');

-- ============================================================
-- 8. CURSO_DISCIPLINA (10 registros)
-- ============================================================
INSERT INTO CURSO_DISCIPLINA (cod_curso, cod_disc) VALUES
(1, 1),
(1, 2),
(1, 7),
(1, 10),
(2, 3),
(2, 9),
(3, 4),
(3, 8),
(4, 5),
(5, 6);

-- ============================================================
-- 9. ALUNO_TURMA (10 registros)
-- ============================================================
INSERT INTO ALUNO_TURMA (RA_aluno, cod_turma, data_matricula, status, nota_final, faltas, percentual_freq) VALUES
(1, 1, '2025-02-01', 'aprovado', 8.5, 4, 93.33),
(2, 1, '2025-02-01', 'aprovado', 7.0, 6, 90.00),
(3, 2, '2025-02-01', 'ativo', NULL, 2, 96.67),
(4, 3, '2025-02-01', 'reprovado', 3.5, 20, 66.67),
(5, 4, '2025-02-01', 'aprovado', 9.0, 1, 98.33),
(6, 4, '2025-02-01', 'trancado', NULL, 0, 100.00),
(7, 5, '2025-02-01', 'ativo', NULL, 3, 95.00),
(8, 6, '2025-02-01', 'aprovado', 6.0, 5, 91.67),
(9, 7, '2025-02-01', 'ativo', NULL, 0, 100.00),
(10, 8, '2025-02-01', 'reprovado', 4.0, 18, 70.00);

-- ============================================================
-- 10. PROFESSOR_TURMA (10 registros)
-- ============================================================
INSERT INTO PROFESSOR_TURMA (cod_turma, registro_prof, papel) VALUES
(1, 'P001', 'titular'),
(2, 'P006', 'titular'),
(3, 'P002', 'titular'),
(4, 'P003', 'titular'),
(5, 'P004', 'titular'),
(6, 'P005', 'titular'),
(7, 'P009', 'titular'),
(8, 'P008', 'titular'),
(9, 'P002', 'auxiliar'),
(10, 'P001', 'auxiliar');

-- ============================================================
-- 11. DISCIPLINA_PRE_REQUISITO (10 registros)
-- ============================================================
INSERT INTO DISCIPLINA_PRE_REQUISITO (cod_disc, cod_disc_pre) VALUES
(2, 1),
(7, 1),
(10, 1),
(10, 7),
(9, 3),
(8, 4),
(5, 4),
(6, 5),
(2, 7),
(9, 8);

-- ============================================================
-- 12. DISCIPLINA_EQUIVALENCIA (10 registros)
-- ============================================================
INSERT INTO DISCIPLINA_EQUIVALENCIA (cod_disc_a, cod_disc_b) VALUES
(1, 2),
(1, 7),
(1, 10),
(2, 7),
(2, 10),
(3, 9),
(4, 8),
(5, 6),
(6, 7),
(8, 9);
