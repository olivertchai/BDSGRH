-- Criando os tipos ENUM
CREATE TYPE sexo AS ENUM (
    'F', 
    'M', 
    'O'
);

CREATE TYPE status AS ENUM (
    'Ativo', 
    'Inativo', 
    'Demitido'
);

CREATE TYPE nome_Beneficio AS ENUM (
    'Plano Saúde',
    'Vale Refeição',
    'Plano Odontológico'
);

CREATE TYPE eventos AS ENUM (
    'Promoção', 
    'Transferência',
    'Advertência',
    'Afastamento Médico',
    'Reconhecimento'

);

-- Criando tabela cargos
CREATE TABLE cargos (
    Id SERIAL PRIMARY KEY,
    cargos VARCHAR(100) NOT NULL,
    descricao TEXT,
    salarios DECIMAL(10,2) NOT NULL,
    criado_Em TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Criando tabela departamentos
CREATE TABLE departamentos (
    id SERIAL PRIMARY KEY,
    nome_Departamento VARCHAR(100) NOT NULL,
    criado_Em TIMESTAMP NOT NULL DEFAULT NOW(),
    id_Cargo INT,
    FOREIGN KEY (id_Cargo) REFERENCES cargos(Id)
);

-- Criando tabela funcionarios
CREATE TABLE funcionarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    CPF VARCHAR(14) NOT NULL,
    data_Nasc DATE NOT NULL,
    telefone VARCHAR(14) NOT NULL,
    email VARCHAR(100) NOT NULL,
    sexo sexo NOT NULL,
    status status NOT NULL,
    data_Admissao DATE NOT NULL,
    data_Demissao DATE,
    criado_Em TIMESTAMP NOT NULL DEFAULT NOW(),
    atualizado_Em TIMESTAMP,
    id_Cargo INT,
    FOREIGN KEY (id_Cargo) REFERENCES cargos(Id),
    id_Departamento INT,
    FOREIGN KEY (id_Departamento) REFERENCES departamentos(id)
);

-- Criando tabela historicoFuncionario
CREATE TABLE historicoFuncionario (
    id SERIAL PRIMARY KEY,
    tipo_Evento eventos NOT NULL,
    descricao TEXT,
    data_Evento DATE NOT NULL,
    id_Funcionario INT,
    FOREIGN KEY (id_Funcionario) REFERENCES funcionarios(id)
);

-- Criando tabela beneficios
CREATE TABLE beneficios (
    id SERIAL PRIMARY KEY ,
    nome_Beneficio nome_Beneficio NOT NULL, 
    descricao TEXT ,
	data_Inicio DATE NOT NULL,
	data_Fim DATE NOT NULL,
    id_Funcionario INT , 
	FOREIGN KEY (id_Funcionario) REFERENCES funcionarios(id)
);

-- Criando tabela bancoDeHoras
CREATE TABLE bancoDeHoras (
    id SERIAL PRIMARY KEY,
    horas_Trabalhadas_Mes INTERVAL NOT NULL,
    criado_Em TIMESTAMP NOT NULL DEFAULT NOW(),
    id_Funcionario INT,
    FOREIGN KEY (id_Funcionario) REFERENCES funcionarios(id)
);

-- Inserindo dados em cargos
INSERT INTO cargos (cargos, descricao, salarios) VALUES
('Analista de Sistemas', 'Responsável por analisar, desenvolver e implementar sistemas.', 5500.00),
('Gerente de Projetos', 'Coordena equipes e prazos em projetos estratégicos.', 8500.00),
('Assistente Administrativo', 'Apoio administrativo às rotinas da empresa.', 3200.00),
('Desenvolvedor Backend', 'Desenvolvimento e manutenção de APIs e banco de dados.', 7000.00),
('Diretor Financeiro', 'Supervisiona e planeja finanças corporativas.', 12000.00),
('Estagiário', 'realiza atividades práticas com o objetivo de aprender', 1000.00),
('Limpeza', 'Mantém o local de trabalho limpo', 2000.00);

-- Inserindo dados em departamentos
INSERT INTO departamentos (nome_Departamento, id_Cargo) VALUES
('Tecnologia da Informação', 1),
('Gerenciamento de Projetos', 2),
('Administrativo', 3),
('Desenvolvimento de Software', 4),
('Financeiro', 5),
('Limpeza', 6),
('Coordenação de estagios ', 5);

-- Inserindo dados em funcionarios
INSERT INTO funcionarios (nome, CPF, data_nasc, telefone, email, sexo, status, data_Admissao, data_Demissao, atualizado_Em, id_Cargo, id_Departamento) VALUES
('João Paulo', '132.654.987-58', '2000-05-08', '(42)99955-6688', 'jp@alunos.utfpr.edu.br', 'M', 'Ativo', '2020-03-02', NULL, NULL, 1, 2),
('Ana Paula Santos', '123.456.789-00', '1990-05-15', '(11)91234-5678', 'ana.santos@email.com', 'F', 'Ativo', '2022-01-10', NULL, NULL, 2, 1),
('Wagner Oliveira', '122.917.679-92', '2001-11-16', '(42)99924-9528', 'wagnero@alunos.utfpr.edu.br', 'M', 'Demitido', '2022-11-10', '2023-10-10', NULL, 1, 3),
('Carlos Eduardo Lima', '987.654.321-00', '1985-11-22', '(21)99876-5432', 'carlos.lima@email.com', 'M', 'Ativo', '2021-03-01', NULL, NULL, 2, 1),
('Mariana Alves Rocha', '321.654.987-00', '1992-08-09', '(31)93456-7890', 'mariana.rocha@email.com', 'F', 'Inativo', '2020-07-15', '2023-12-20', NOW(), 6, 3);

-- Inserindo dados em historicoFuncionario
INSERT INTO historicoFuncionario (tipo_Evento, descricao, data_Evento, id_Funcionario) VALUES
('Promoção', 'Promoção para o cargo de Analista Pleno', '2024-04-06', 1),
('Advertência', 'Advertência por atrasos frequentes.', '2023-09-03', 2),
('Transferência', 'Transferido para o departamento de Desenvolvimento.', '2024-01-04', 3),
('Afastamento Médico', 'Afastamento por licença médica de 15 dias.', '2024-03-04', 1),
('Reconhecimento', 'Reconhecido como funcionário do mês.', '2024-05-02', 2);

-- Inserindo dados em beneficios
INSERT INTO beneficios (nome_Beneficio, descricao, data_Inicio, data_Fim, id_Funcionario) VALUES
('Plano Saúde', 'Cobertura médica completa com rede nacional.', '01-01-2023', '31-12-2023', 1),
('Vale Refeição', 'Crédito mensal para alimentação em restaurantes.', '01-01-2023', '31-12-2023', 1),
('Plano Odontológico', 'Plano de assistência odontológica.','05-05-2023', '31-12-2024', 2),
('Plano Saúde', 'Plano médico premium com reembolso.','01-01-2024', '30-06-2024', 3),
('Vale Refeição Extra', 'Crédito extra para eventos e plantões.','03-03-2025', '31-12-2024', 2),
('Vale Refeição Extra ', 'Crédito extra para eventos e plantões.','03-03-2025', '31-12-2024', 2);


-- Inserindo dados em bancoDeHoras
INSERT INTO bancoDeHoras (horas_Trabalhadas_Mes, id_Funcionario) VALUES
(INTERVAL '160 hours', 1),
(INTERVAL '172 hours', 3),
(INTERVAL '150 hours', 2),
(INTERVAL '180 hours', 5),
(INTERVAL '165 hours', 4);