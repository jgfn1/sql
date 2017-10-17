Questão 1
SELECT E.nome
FROM empregado E, graduado G
WHERE E.cpf = G. cpf
AND E.salario BETWEEN 3000 AND 4000;
--solução alternativa: sem junção, com
SELECT E.nome
FROM empregado E
WHERE EXISTS (SELECT * FROM graduado G WHERE E.cpf = G.cpf)
AND E.salario BETWEEN 3000 AND 4000;

Questão 2
SELECT E.nome, E.cpf, E.salario
FROM empregado E
WHERE E.salario BETWEEN
(SELECT (MIN(E.salario)+1000) FROM empregado E)
AND (SELECT (MAX(E.salario)-1000) FROM empregado E);

Questão 3
SELECT DISTINCT cpf FROM graduado G --Exibe os cpfs sem repetir
WHERE cpf IN ( --Retorna os cpf que participaram dos projetos com valor menor que a média
SELECT cpf
FROM participa
WHERE codigo_projeto IN ( --Retorna o código dos projetos com valor menor que a média
SELECT codigo
FROM projeto
WHERE valor >= (SELECT AVG(valor) FROM projeto)));

Questão 4
SELECT P.codigo_projeto, COUNT(P.cpf)
FROM participa P, projeto Pr
WHERE P.codigo_projeto = Pr.codigo
AND Pr.valor > 8000
GROUP BY P.codigo_projeto
HAVING COUNT(P.cpf) > (SELECT COUNT(DISTINCT cpf_lider) FROM empregado-- conta a
quantidade de líderes);

Questão 5
SELECT E.nome
FROM empregado E
WHERE E.sexo = 'F'
AND EXISTS (SELECT * -- retorna os tecnicos que passaram da oitava serie
FROM tecnico T
WHERE T.cpf = E.cpf
AND T.ultima_serie > 8)
AND EXISTS (SELECT * --retorna os tecnicos que trabalharam entre 2005 e 2010
FROM trabalha Tr
WHERE Tr.cpf = E.cpf
AND Tr.codigo_depto = 2
AND Tr.data_trabalha BETWEEN to_date ('2005', 'yyyy') AND to_date ('2010',
'yyyy')
AND codigo_gratif IS NULL);

Questão 6
SELECT DISTINCT E.nome AS Empregado, C.nome AS Lider, E.dt_nasc
FROM Empregado E INNER JOIN (SELECT e1.cpf_lider AS cpf, e2.nome AS nome

FROM empregado e1, empregado e2
WHERE e1.cpf_lider = e2.cpf) C -- cria uma view implícita com o

nome e cpf’s dos líderes
ON E.cpf_lider = C.cpf
WHERE E.nome LIKE 'J%'
ORDER BY E.dt_nasc;
--usando junção implícita
SELECT DISTINCT E.nome AS Empregado, C.nome AS Lider, E.dt_nasc
FROM Empregado E, (SELECT e1.cpf_lider AS cpf, e2.nome AS nome
FROM empregado e1, empregado e2
WHERE e1.cpf_lider = e2.cpf) C

WHERE E.cpf_lider = C.cpf
AND E.nome LIKE 'J%'
ORDER BY E.dt_nasc;

Questão 7
--situação a)
UPDATE trabalha SET codigo_gratif = NULL
WHERE codigo_depto = (SELECT codigo FROM departamento WHERE descricao = 'Vendas');
--situação b)
DELETE FROM fone WHERE fone.cpf IN (SELECT T.cpf FROM titulacao_empregado T, IES I
WHERE T.codigo_ies = I.codigo AND I.sigla = 'FIFA');

Questão8
SELECT E.cpf
FROM empregado E
WHERE E.salario > ANY (SELECT E1.salario FROM empregado E1, departamento D WHERE E1.cpf
= D.cpf_chefe
AND E.cpf NOT IN (SELECT cpf_chefe FROM departamento))
UNION
(SELECT E.cpf FROM empregado E WHERE E.salario < (SELECT AVG(salario) FROM
empregado));

Questão 9
CREATE OR REPLACE TRIGGER salarioSenior
BEFORE INSERT OR UPDATE ON empregado
FOR EACH ROW
WHEN ((SYSDATE - NEW.dt_nasc)/365 > 60)
BEGIN
IF :NEW.salario < 4000 THEN
RAISE_APPLICATION_ERROR(-20011, 'Salario muito baixo');
END IF;
END;
/
--teste
INSERT INTO empregado (cpf, cpf_lider, nome, dt_nasc, sexo, salario, cep)VALUES (8888, NULL,
'Gilmar Pedrosa', to_date ('21/02/1940', 'dd/mm/yyyy'), 'M', 3000.00, 123451);

Questão 10
CREATE OR REPLACE PROCEDURE imprimeNome (cpfEmp IN NUMBER, idadeEmp OUT
NUMBER) IS
nomeEmp VARCHAR2(30);
BEGIN
SELECT ((SYSDATE - dt_nasc)/365), nome INTO idadeEmp, nomeEmp
FROM empregado
WHERE cpf = cpfEmp;
DBMS_OUTPUT.PUT_LINE ('Nome: ' || nomeEmp);
END;
/

Questão 11
CREATE OR REPLACE FUNCTION empAtividade (cod_at NUMBER) RETURN NUMBER IS
CURSOR c_participa (codigo_ativid NUMBER) IS
SELECT E.cpf, E.nome
FROM empregado E JOIN participa P
ON E.cpf = P.cpf
WHERE P.codigo_atividade = codigo_ativid;
reg_participa c_participa%rowtype;
n NUMBER;
BEGIN
n := 0;
FOR reg_participa IN c_participa(cod_at) LOOP
DBMS_OUTPUT.PUT_LINE ('Cpf: ' || reg_participa.cpf || '| Nome: ' ||

reg_participa.nome);
n := n + 1;
END LOOP;
RETURN n;
END;
/
--teste
SELECT empAtividade (4) FROM dual;

Questão 12
CREATE OR REPLACE PROCEDURE trocaChefe (codDep IN NUMBER, cpfChefe IN OUT NUMBER)
IS
temp NUMBER;
BEGIN
SELECT cpf_chefe INTO temp FROM departamento WHERE codigo = codDep;
UPDATE departamento SET cpf_chefe = cpfChefe WHERE codigo = codDep;
cpfChefe := temp;
END;
/
--bloco
DECLARE
i NUMBER := 1;
chefe NUMBER := 7777;
BEGIN
WHILE i <= 3 LOOP
trocaChefe (i, chefe);
i := i + 1;
END LOOP;
END;
/

Questão 13
CREATE OR REPLACE TRIGGER nEmp
BEFORE INSERT OR DELETE ON empregado
DECLARE
n NUMBER;
BEGIN
SELECT COUNT(cpf) INTO n
FROM empregado;
DBMS_OUTPUT.PUT_LINE ('Quantidade atual de empregados: ' || n);
END;
/

--teste
INSERT INTO empregado (cpf, cpf_lider, nome, dt_nasc, sexo, salario, cep) VALUES (1010, NULL,
'Teago', to_date ('21/02/1980', 'dd/mm/yyyy'), 'M', 5000.00, 111111);
DELETE FROM empregado WHERE cpf = 1010;

Questão 14
((SELECT nome FROM tecnico T, empregado Emp
WHERE T.cpf = Emp.cpf AND T.ultima_serie > 7)
INTERSECT
(SELECT nome FROM participa P, empregado Emp
WHERE P.cpf = Emp.cpf AND codigo_atividade = 3) )
MINUS
(SELECT nome FROM participa P, projeto PJ, empregado Emp
WHERE Emp.cpf = P.cpf AND P.codigo_projeto = PJ.codigo AND PJ.valor > 8000);

Questão 15
DECLARE
CURSOR empregado1111 IS
SELECT * FROM empregado;
umEmpregado empregado%ROWTYPE;
BEGIN
OPEN empregado1111;
FETCH empregado1111 INTO umEmpregado;
WHILE empregado1111%FOUND
LOOP
IF umEmpregado.cpf_lider=1111 AND umEmpregado.salario>3500 THEN
DBMS_OUTPUT.PUT_LINE(umEmpregado.nome);
END IF;
FETCH empregado1111 INTO umEmpregado;
END LOOP;
CLOSE empregado1111;
END;
/

Questão 16
CREATE OR REPLACE TRIGGER limiteProjeto
BEFORE INSERT OR UPDATE OF valor ON Projeto
FOR EACH ROW
BEGIN
IF :NEW.valor > 100000 OR :NEW.valor < 1500 THEN
RAISE_APPLICATION_ERROR (
num => -20000,
msg => 'Os projetos não podem custar menos que 1.500,00 ou mais que
100.000,00');
END IF;
END;
/

Questão 17
CREATE OR REPLACE PROCEDURE projeto_salario(valorIn IN Projeto.valor%TYPE)
IS i NUMBER;
CURSOR projetos IS
SELECT * FROM Projeto;
umProjeto Projeto%ROWTYPE;

BEGIN
i:=0;
OPEN projetos;
LOOP
FETCH projetos INTO umProjeto;
EXIT WHEN projetos%NOTFOUND;
IF umProjeto.valor = valorIn THEN
DBMS_OUTPUT.PUT_LINE(umProjeto.descricao);
i:=i+1;
END IF;
END LOOP;
CLOSE projetos;
DBMS_OUTPUT.PUT_LINE(i || ' projetos no valor de ' || valorIn);
END;
/

Questão 18
CREATE OR REPLACE PROCEDURE digito9 IS
CURSOR fones IS SELECT * FROM fone;
umFone fone%ROWTYPE;
BEGIN
OPEN fones;
LOOP
FETCH fones INTO umFone;
EXIT WHEN fones%NOTFOUND;
UPDATE fone F SET F.fone='9'||umFone.fone WHERE F.fone=umFone.fone;
END LOOP;
CLOSE fones;
END;
/

Questão 19
CREATE VIEW supervisa as SELECT cpf FROM empregado WHERE cpf_lider = 1111;

Questão 20
SELECT T.cpf, G.descricao
FROM trabalha T LEFT OUTER JOIN gratificacao G
ON T.codigo_gratif = G.codigo
WHERE T.codigo_depto = 1;

Questão 21
SELECT TE.codigo_ies, COUNT (DISTINCT T.cpf) AS QTD_PREMIADOS
FROM titulacao_empregado TE, trabalha T
WHERE T.codigo_gratif IS NOT NULL AND T.cpf = TE.cpf
GROUP BY TE.codigo_ies;

Questão 22
CREATE OR REPLACE PACKAGE projetoPacote AS
FUNCTION getCodigoProjeto(codProj NUMBER) RETURN projeto%ROWTYPE;
PROCEDURE descProjeto (p projeto%ROWTYPE);
END;
/
CREATE OR REPLACE PACKAGE BODY projetoPacote AS
FUNCTION getCodigoProjeto (codProj NUMBER) RETURN projeto%ROWTYPE IS
p projeto%ROWTYPE;
BEGIN
SELECT * INTO p FROM projeto WHERE codigo = codProj;

RETURN p;
END;
PROCEDURE descProjeto (p projeto%ROWTYPE) IS
BEGIN
DBMS_OUTPUT.PUT_LINE ('Descricao: ' || p.descricao);
END;
END;
/

Questão 23
CREATE OR REPLACE TRIGGER salarioEmp
AFTER INSERT ON empregado
DECLARE n NUMBER;
DECLARE sexo CHAR;
BEGIN
SELECT COUNT(*) INTO n FROM empregado WHERE sexo = 'M';
DBMS_OUTPUT.PUT_LINE ('Quantidade de empregados do sexo masculino: ' || n);
END;
/

Questão 24
CREATE OR REPLACE PROCEDURE Funcionario (cfpF IN NUMBER) IS
nomeF VARCHAR2(30), salarioF DECIMAL(6,2), sexoF CHAR(1);
BEGIN
SELECT nome, salario, sexo INTO nomeF
FROM empregado
WHERE cpf = cpfF;
DBMS_OUTPUT.PUT_LINE ('Nome: ' || nomeF , 'Sexo: ' || sexo, 'Salario: ' || salario);
END;
/

Questão 25
CREATE OR REPLACE TRIGGER update_salario
BEFORE INSERT ON participa
FOR EACH ROW
DECLARE new_salario NUMBER;
BEGIN
SELECT E.salario INTO new_salario FROM empregado E WHERE E.cpf = :NEW.cpf;
new_salario := new_salario + 50.00;
UPDATE empregado SET salario = new_salario
WHERE cpf = :NEW.cpf;
END;
/

Questão 26
CREATE OR REPLACE PROCEDURE cpfIMPAR IS
CURSOR empregados_c IS
SELECT * from empregados;
empregados_v empregados_c%ROWTYPE;
BEGIN
OPEN empregados_c;
LOOP
FETCH empregados_c INTO empregados_v;
EXIT WHEN empregados_c%NOTFOUND;

IF MOD(empregados_v.cpf,2) = 0 THEN
DBMS_OUTPUT.PUT_LINE ('O CPF ' || empregados_v.cpf || 'eh par!');
ELSE
DBMS_OUTPUT.PUT_LINE ('O CPF ' || empregados_v.cpf || 'eh impar!');
END IF;
END LOOP;
CLOSE empreagos_c;
END;
/