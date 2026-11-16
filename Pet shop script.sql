DROP DATABASE IF EXISTS pet_shop;
CREATE DATABASE pet_shop
	DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_0900_ai_ci;
    
USE pet_shop;

CREATE TABLE clientes (
	id		INT			NOT NULL AUTO_INCREMENT,
    nome	VARCHAR(80) NOT NULL,
    telefone	VARCHAR(15) NOT NULL,
    email	VARCHAR(100) NULL,
    endereco	VARCHAR(255) NULL,
	criado_em	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em 	DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
		PRIMARY KEY (id),
        INDEX idx_clientes_nome		(nome),
        INDEX idx_clientes_telefone (telefone)
)ENGINE=InnoDB
 DEFAULT CHARSET=utf8mb4
 COLLATE=utf8mb4_0900_ai_ci;
 
CREATE TABLE pets (
	id		INT		NOT NULL AUTO_INCREMENT,
    cliente_id INT 	NOT NULL,
    nome	VARCHAR(35) NOT NULL,
    especie	VARCHAR(20) NOT NULL,
    raca	VARCHAR(40) NULL,
    porte	ENUM('pequeno', 'medio', 'grande') NULL,
    alertas	TEXT	NULL,
    criado_em	DATETIME	NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_pets_cliente (cliente_id),
    INDEX idx_pets_nome	(nome),
    CONSTRAINT fk_pets_cliente FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON DELETE CASCADE ON UPDATE CASCADE
)ENGINE=InnoDB
 DEFAULT CHARSET=utf8mb4
 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE funcionarios (
	id		int		NOT NULL AUTO_INCREMENT,
    nome	VARCHAR(80) NOT NULL,
    cargo	VARCHAR(30) NULL,
    registro_profissional	VARCHAR(20) NULL,
    telefone	VARCHAR(15) NULL,
    atendimentos_simultaneos INT 	NOT NULL DEFAULT 1,
    crado_em	DATETIME	NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uk_funcionarios_registro (registro_profissional),
    CONSTRAINT chk_funcionarios_atend CHECK (atendimentos_simultaneos >= 1)
)ENGINE=InnoDB
 DEFAULT CHARSET=utf8mb4
 COLLATE=utf8mb4_0900_ai_ci;
 
CREATE TABLE disponibilidade_funcionarios (
	id		INT 	NOT NULL AUTO_INCREMENT,
    funcionario_id INT 	NOT NULL,
    dia_semana		TINYINT NOT NULL COMMENT '0=DOM, 1=SEG,..., 6=SÁB',
    hora_inicio		TIME 	NOT NULL,
    hora_fim		TIME 	NOT NULL,
    ativo			BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id),
    INDEX idx_disp_funcionario (funcionario_id),
    CONSTRAINT fk_disp_funcionario FOREIGN KEY (funcionario_id) REFERENCES funcionarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT chk_disp_dia CHECK (dia_semana BETWEEN 0 AND 6),
    CONSTRAINT chk_disp_horas CHECK (hora_fim > hora_inicio)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;
  
CREATE TABLE servicos (
	id			INT 		NOT NULL AUTO_INCREMENT,
    nome_servico 	VARCHAR(50) NOT NULL,
    preco_base		DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    duracao_minutos	INT 		  NOT NULL DEFAULT 30,
    PRIMARY KEY (id),
    CONSTRAINT chk_servicos_preco	CHECK (preco_base >= 0),
    CONSTRAINT chk_servicos_duracao CHECK (duracao_minutos > 0)
)ENGINE=InnoDB
 DEFAULT CHARSET= utf8mb4
 COLLATE=utf8mb4_0900_ai_ci;
 
CREATE TABLE agendamentos (
	id 		INT		NOT NULL AUTO_INCREMENT,
    pet_id	INT 	NOT NULL,
    servico_id INT 	NOT NULL,
    funcionario_id	int		NOT NULL,
    data_hora_inicio	DATETIME	NOT NULL,
    data_hora_fim		DATETIME 	NOT NULL,
    status		ENUM('pendente', 'concluido', 'cancelado') NOT NULL DEFAULT 'pendente',
    criado_em	DATETIME 	NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_agend_status		(status),
    CONSTRAINT fk_agend_pet 	FOREIGN KEY (pet_id) REFERENCES pets (id) 	ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_agend_servico FOREIGN KEY  (servico_id) REFERENCES servicos (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_agend_funcionario FOREIGN KEY (funcionario_id) REFERENCES funcionarios (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_agend_horas 	CHECK (data_hora_fim > data_hora_inicio)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;
  
CREATE TABLE produtos (
	id		INT 	NOT NULL AUTO_INCREMENT,
    nome_produto	VARCHAR(80) NOT NULL,
    preco	DECIMAL(10,2) NOT NULL,
    quantidade_estoque	INT	NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    INDEX idx_produtos_nome (nome_produto),
    CONSTRAINT	chk_produtos_preco 	CHECK (preco >= 0),
    CONSTRAINT  chk_produtos_estoque CHECK (quantidade_estoque >= 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;
  
CREATE TABLE vendas (
	id		INT 	NOT NULL AUTO_INCREMENT,
    cliente_id	INT NOT NULL,
    funcionario_id INT NOT NULL,
    data_venda  DATETIME	NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_total	DECIMAL (10,2) NOT NULL DEFAULT 0.00,
    forma_pagamento 	ENUM('dinheiro', 'PIX','debito', 'credito') NULL,
    PRIMARY KEY (id),
    INDEX idx_vendas_cliente (cliente_id),
    INDEX idx_vendas_data     (data_venda),
    CONSTRAINT	fk_vendas_cliente FOREIGN KEY (cliente_id) REFERENCES clientes (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT  fk_vendas_funcionario FOREIGN KEY (funcionario_id) REFERENCES funcionarios (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_vendas_valor CHECK (valor_total >= 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;
  
CREATE TABLE itens_venda (
	id 		INT 	NOT NULL AUTO_INCREMENT,
    venda_id INT	NOT NULL,
    produto_id INT 	NOT NULL,
    quantidade	INT NOT NULL,
    preco_unitario DECIMAL (10,2) NOT NULL,
    PRIMARY KEY (id),
    INDEX idx_itens_venda  (venda_id),
    INDEX idx_itens_produto (produto_id),
    CONSTRAINT uk_itens_venda_produto UNIQUE (venda_id, produto_id),
    CONSTRAINT fk_itens_venda FOREIGN KEY (venda_id) REFERENCES vendas (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_itens_produto FOREIGN KEY (produto_id) REFERENCES produtos (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_itens_qtd CHECK (quantidade > 0),
    CONSTRAINT chk_itens_preco CHECK (preco_unitario >= 0)
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_0900_ai_ci;


DELIMITER $$

CREATE TRIGGER trg_itens_ai
AFTER INSERT ON itens_venda
FOR EACH ROW
BEGIN
    UPDATE vendas
       SET valor_total = (
           SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
             FROM itens_venda
            WHERE venda_id = NEW.venda_id
       )
     WHERE id = NEW.venda_id;
END$$

CREATE TRIGGER trg_itens_au
AFTER UPDATE ON itens_venda
FOR EACH ROW
BEGIN
    UPDATE vendas
       SET valor_total = (
           SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
             FROM itens_venda
            WHERE venda_id = NEW.venda_id
       )
     WHERE id = NEW.venda_id;
END$$

CREATE TRIGGER trg_itens_ad
AFTER DELETE ON itens_venda
FOR EACH ROW
BEGIN
    UPDATE vendas
       SET valor_total = (
           SELECT COALESCE(SUM(quantidade * preco_unitario), 0)
             FROM itens_venda
            WHERE venda_id = OLD.venda_id
       )
     WHERE id = OLD.venda_id;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_baixa_estoque
AFTER INSERT ON itens_venda
FOR EACH ROW
BEGIN
    UPDATE produtos
       SET quantidade_estoque = quantidade_estoque - NEW.quantidade
     WHERE id = NEW.produto_id;
END$$

DELIMITER ;

INSERT INTO clientes (nome, telefone, email, endereco) VALUES
('Ana Souza',    '(11) 99999-1111', 'ana@email.com',   'Rua A, 100'),
('Bruno Lima',   '(11) 99999-2222', 'bruno@email.com', 'Rua B, 200'),
('Carla Mendes', '(11) 99999-3333', 'carla@email.com', 'Rua C, 300');

INSERT INTO pets (cliente_id, nome, especie, raca, porte, alertas) VALUES
(1, 'Rex',  'cachorro', 'Labrador', 'grande',  'Alergia a frango'),
(1, 'Mimi', 'gato',     'Siamês',   'pequeno', NULL),
(2, 'Thor', 'cachorro', 'Poodle',   'pequeno', 'Medo de secador'),
(3, 'Luna', 'gato',     'Persa',    'pequeno', NULL);

INSERT INTO funcionarios (nome, cargo, registro_profissional, telefone, atendimentos_simultaneos) VALUES
('Dr. João Silva', 'Veterinário', 'CRMV-SP 12345', '(11) 98888-1111', 2),
('Maria Tosa',     'Tosadora',    NULL,            '(11) 98888-2222', 1),
('Pedro Banho',    'Banhista',    NULL,            '(11) 98888-3333', 2);

INSERT INTO disponibilidade_funcionarios (funcionario_id, dia_semana, hora_inicio, hora_fim, ativo) VALUES
(1, 1, '08:00:00', '18:00:00', TRUE),
(1, 2, '08:00:00', '18:00:00', TRUE),
(2, 1, '09:00:00', '17:00:00', TRUE),
(3, 3, '08:00:00', '12:00:00', TRUE);

INSERT INTO servicos (nome_servico, preco_base, duracao_minutos) VALUES
('Banho',        50.00,  45),
('Tosa',         70.00,  60),
('Consulta',    120.00,  30),
('Banho + Tosa',100.00,  90);

INSERT INTO agendamentos (pet_id, servico_id, funcionario_id, data_hora_inicio, data_hora_fim, status) VALUES
(1, 4, 2, '2025-10-15 09:00:00', '2025-10-15 10:30:00', 'pendente'),
(2, 3, 1, '2025-10-15 10:00:00', '2025-10-15 10:30:00', 'concluido'),
(3, 1, 3, '2025-10-16 08:00:00', '2025-10-16 08:45:00', 'pendente');

INSERT INTO produtos (nome_produto, preco, quantidade_estoque) VALUES
('Ração Premium 3kg',  89.90,  50),
('Brinquedo Bolinha',  19.90, 100),
('Vermífugo 10ml',     35.00,  40),
('Coleira Antipulgas', 45.00,  30);

INSERT INTO vendas (cliente_id, funcionario_id, data_venda, forma_pagamento) VALUES
(1, 1, '2025-10-10 14:30:00', 'pix'),
(2, 3, '2025-10-11 10:00:00', 'credito'),
(1, 1, '2025-10-12 16:45:00', 'dinheiro');

INSERT INTO itens_venda (venda_id, produto_id, quantidade, preco_unitario) VALUES
(1, 1, 1, 89.90),
(1, 2, 2, 19.90),
(2, 3, 1, 35.00),
(2, 4, 1, 45.00),
(3, 1, 2, 89.90);

SELECT p.nome AS pet, p.especie, c.nome AS
dono, c.telefone
	FROM pets p
    JOIN clientes c ON c.id = p.cliente_id
ORDER BY c.nome, p.nome;

SELECT a.data_hora_inicio, p.nome AS pet,
s.nome_servico,
		f.nome AS funcionario, a.status
    FROM agendamentos a
    JOIN pets p 	ON p.id = a.pet_id
    JOIN servicos s ON s.id = a.servico_id
    JOIN funcionarios f ON f.id = a.funcionario_id
    ORDER BY a.data_hora_inicio;
    
SELECT c.nome, COUNT(v.id) AS qtd, SUM(v.valor_total) AS total
	FROM clientes c
    JOIN bendas v ON v.cliente_id = c.id
GROUP BY c.id, c.nome
ORDER BY total DESC;

SELECT nome_produto, quantidade_estoque
	FROM produtos
WHERE quantidade_estoque < 10
ORDER BY quantidade_estoque;
    