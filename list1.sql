/*Questão 1
Faça uma consulta que retorne o nome dos empregados que são graduados e têm salário entre R$
3000 e R$ 4000.*/
SELECT e.name FROM employees e
WHERE (wage BETWEEN 3000 AND 400)
      AND study_level = "Undergraduated";

/*Questão 2
Seja MIN_SALARIO o menor dos salários e MAX_SALARIO o maior dos salários. Retorne o nome, cpf
e salário dos empregados que tem o salário entre [MIN_SALARIO + 1000, MAX_SALARIO - 1000].*/
SELECT e.name, cpf, wage FROM employees e
WHERE wage BETWEEN (SELECT min(wage) + 1000 FROM employees)
      AND (SELECT max(wage) - 1000 FROM employees);

/*Questão 3
Retorne, sem usar junção, o cpf dos graduados, sem repetição, que participam de um projeto com
valor maior que a média dos valores dos projetos.*/
SELECT DISTINCT cpf FROM employees e, projects p
WHERE e.cpf = p.partcipant_cpf
AND p.project_value > (SELECT avg(project_value) FROM projects);

/*Questão 4
Exiba o código dos projetos de valor maior que R$8000 que possuam mais empregados do que a
quantidade de líderes, bem, como a quantidade de empregados envolvidos em cada um desses
projetos.*/
SELECT project_code, count(cpf) FROM projects
WHERE project_value > 8000
      AND (SELECT count(cpf) FROM projects) > (SELECT count(leader_cpf) FROM projects);

/*Questão 5
Faça uma consulta que retorne o nome dos empregados técnicos, do sexo feminino, que passaram
da oitava série e trabalharam no departamento de código 2, entre os anos de 2005 e 2010, sem
receber gratificações. Não faça junções. Use EXISTS.*/
SELECT e.name FROM employees e
WHERE e.sex = "F" AND study_level = "Technician" AND reached_grade > 8
AND exists(
  SELECT e.cpf FROM departments d
  WHERE d.code = 2 AND e.cpf = d.cpf AND (worked_year BETWEEN 2005 AND 2010)
      AND rewards IS NULL);

/*Questão 6
Crie uma consulta que retorne os nomes dos empregados e a data de nascimento, cujos nomes
começam com 'J’, que possuem líderes, e retorne também os nomes dos líderes. Ordene os
empregados por suas datas de nascimento.*/
SELECT e.name, e.birthdate, e.leader FROM employees
WHERE e.name LIKE 'J%' AND e.leader IS NOT NULL
ORDER BY e.birthdate;

/*Questão 7
Insira, remova ou atualize linhas em tabelas do banco de modo a refletir as seguintes situações:
a) Todos os empregados do departamento de Vendas, perderam seus direitos a gratificações.*/
UPDATE employees e SET e.rewards = NULL
WHERE exists(
    SELECT * FROM departments d
    WHERE d.name = 'Sales' AND e.cpf = d.employee_cpf
);

/*b) Houve um assalto na IES FIFA e todos os empregados com graduação da FIFA, perderam seus
telefones.*/
UPDATE fifa SET phone_number = NULL;

/*Questão 8
Retorne os CPF's dos empregados que recebem mais do que o salário de qualquer chefe de
departamento, sem eles mesmos serem chefes, juntamente com os CPF's dos empregados que
recebem menos do que a média.*/
SELECT e.cpf FROM employees e
WHERE (e.wage > ANY (
  SELECT e1.wage FROM employees e1
  WHERE e.cpf = e1.boss_cpf) AND NOT exists(
    SELECT e.cpf FROM employees e2
    WHERE e.cpf = e2.boss_cpf)) OR (e.wage < (SELECT avg(wage) FROM employees));

/*Questão 9
Crie um trigger que, se um empregado tenha mais de 60 anos de idade, não permita que o seu
salário seja menor do que R$ 4000.*/
CREATE OR REPLACE TRIGGER elder_wage_check BEFORE INSERT OR UPDATE ON employees
 FOR EACH ROW WHEN (wage < 4000)
  BEGIN
    raise_application_error(-20000, 'The elders'' wages cannot be below R$4000,00.');
  END elder_wage_check;


/*Questão 10
Crie um procedimento que recebe o CPF de um funcionário e imprima na tela o seu nome.
Adicionalmente, o procedimento deve calcular e retornar a idade do empregado por parâmetro.*/
CREATE OR REPLACE PROCEDURE name_wage_from_cpf (cpf employees.cpf%ROWTYPE, age OUT INTEGER) AS
name employees.name%ROWTYPE;
BEGIN
  SELECT e.name INTO "name" FROM employees
    WHERE e.cpf = cpf;

  dbms_output.put_line(name);

  SELECT extract(YEAR FROM (
    SELECT birthdate FROM employees
  )) INTO age FROM employees;
END name_wage_from_cpf;

/*Questão 11
Crie uma função que receba o código de uma atividade e imprima os CPF's e nomes de todos os
empregados que participaram dessa atividade. A função deve retornar o número de funcionários
que participaram da atividade.*/
CREATE OR REPLACE FUNCTION print_cpf_name_from_activity_return_number(code activity.code%ROWTYPE, employees_number_in_activity OUT INTEGER)
RETURN employees_number_in_activity%ROWTYPE AS
  cpf employees.cpf%ROWTYPE;
  name employees.name%ROWTYPE;
BEGIN
  SELECT e.cpf, e.name, count(e.cpf) INTO cpf, name, employees_number_in_activity FROM employees e, activity a
    WHERE a.code = code AND e.cpf = a.participant_cpf;

  dbms_output.put_line(name || to_char(cpf));
END print_cpf_name_from_activity_return_number;

/*Questão 12
Crie um procedimento que receba o código de um departamento e o CPF de um empregado e
coloque esse empregado como novo chefe do departamento. Deve-se retornar, usando o parâmetro
CPF do procedimento, o CPF do antigo chefe. Feito isso, crie um bloco que faça com que o
empregado de CPF 7777 torne-se o novo chefe do departamento 1, o antigo chefe do departamento
1 se torne o novo do departmento 2, e o antigo do departamento 2 se torne o novo do
departamento 3. Use um WHILE LOOP.*/


/*Questão 13
Crie um trigger que, após inserir ou deletar empregados, imprima na tela a nova quantidade de
empregados da tabela. Isso só precisa ser feito uma vez por comando, mesmo que mais de uma
linha tenha sido inserida ou deletada.*/

/*Questão 14
Selecione o NOME dos empregados que são técnicos e cuidam da parte de desenvolvimento de um
projeto, que não tem valor maior que 8000. (UTILIZE OPERAÇÕES DE CONJUNTOS)*/

/*Questão 15
Crie um cursor que imprima na tela os nomes dos empregados que tem como líder, o empregado de
CPF = 1111, e que tenham salário superior a 3.500,00.*/

/*Questão 16
Crie um trigger que não permita a inserção (ou atualização) de projetos com valores acima de
100.000,00 ou abaixo de 1.500,00.*/

/*Questão 17
Crie um procedimento que receba como parâmetro o valor de um projeto e imprima a descrição dos
projetos e o total de projetos com este valor.*/

/*Questão 18
Crie um procedimento que atualize os telefones de todos os empregados (atualize na tabela fone)
inserindo o dígito 9 (Nove) antes de cada telefone. Obs.: Para essa questão considere que o campo
fone é varchar2(10) para que caiba os 9 dígitos além do “–“ (hífen).*/

/*Questão 19
Crie uma VIEW com os supervisionados de João da Silva*/

/*Questão 20
Liste qual gratificação, cada empregado do departamento de Vendas recebeu. (UTILIZE JOIN)*/

/*Questão 21
Liste quantos empregados graduados de cada IES receberam gratificação.*/

/*Questão 22
Crie um PACKAGE composto de:
Uma função que recebe o código de um Projeto e retorna os dados dele;
Um procedimento que receba os dados de um Projeto e imprima na tela a sua descrição;*/

/*Questão 23
Crie um TRIGGER que, após inserir empregados, imprima na tela quantos funcionários do sexo
masculino existem.*/

/*Questão 24
Crie um PROCEDURE que receba o CPF de um Funcionário e imprima na tela o seu nome, sexo e
salário.*/

/*Questão 25
Crie um TRIGGER para inserção, que atualize o valor do salário de um empregado(adicione R$50,00
ao salário do empregado), todas as vezes que um empregado se envolver em um novo projeto.*/

/*
Questão 26
Precisamos dividir todos os empregados em 2 grupos, para isso decidimos que vamos dividir pelo
numero do CPF, para isso, crie um procedimento que diga se os CPFs são impar ou par, para que
eles sejam divididos no grupo do CPF impar e o grupo do CPF par.*/