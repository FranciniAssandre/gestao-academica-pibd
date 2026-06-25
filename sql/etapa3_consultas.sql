-- ETAPA 3 - CONSULTAS SQL INDIVIDUAIS

-- Francini
-- Entidades: ALUNO, CURSO, TELEFONE_ALUNO
-- Relacionamentos: ALUNO pertence a CURSO; ALUNO possui TELEFONE_ALUNO
SELECT
    a.ra,
    a.nome AS aluno,
    c.nome AS curso,
    ta.numero AS telefone,
    ta.tipo_tel
FROM aluno a
JOIN curso c ON c.cod_curso = a.cod_curso
LEFT JOIN telefone_aluno ta ON ta.ra_aluno = a.ra
ORDER BY a.nome, ta.id_tel;

-- Gustavo
-- Entidades: PROFESSOR, PROFESSOR_TURMA, TURMA, DISCIPLINA
-- Relacionamentos: PROFESSOR ministra TURMA; TURMA pertence a DISCIPLINA
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
ORDER BY p.nome, t.cod_turma;

-- Marina
-- Entidades: CURSO, CURSO_DISCIPLINA, DISCIPLINA, DISCIPLINA_PRE_REQUISITO
-- Relacionamentos: CURSO possui DISCIPLINA; DISCIPLINA possui PRE-REQUISITO
SELECT
    c.nome AS curso,
    d.nome AS disciplina,
    pre.nome AS pre_requisito
FROM curso c
JOIN curso_disciplina cd ON cd.cod_curso = c.cod_curso
JOIN disciplina d ON d.cod_disc = cd.cod_disc
LEFT JOIN disciplina_pre_requisito dpr ON dpr.cod_disc = d.cod_disc
LEFT JOIN disciplina pre ON pre.cod_disc = dpr.cod_disc_pre
ORDER BY c.nome, d.nome, pre.nome;

-- Miguel
-- Entidades: ALUNO, CURSO, ALUNO_TURMA, TURMA, DISCIPLINA
-- Relacionamentos: ALUNO pertence a CURSO; ALUNO frequenta TURMA; TURMA pertence a DISCIPLINA
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
ORDER BY a.nome, d.nome;

-- Salvatore
-- Entidades: DEPARTAMENTO, DISCIPLINA, TURMA, ALUNO_TURMA
-- Relacionamentos: DEPARTAMENTO oferece DISCIPLINA; DISCIPLINA gera TURMA; TURMA e frequentada por ALUNOS via ALUNO_TURMA
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
ORDER BY dep.nome, d.nome, t.cod_turma;
