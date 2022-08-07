--  Listar la cantidad de clientes por nombre de sucursal ordenando de mayor a menor
SELECT branch_name, count(customer_name) AS cantidad_clientes 
FROM sucursal, cliente WHERE sucursal.branch_id = cliente.branch_id 
GROUP BY branch_name ORDER BY count(customer_name) DESC;

-- Obtener la cantidad de empleados por cliente por sucursal en un número real
SELECT branch_name, count(DISTINCT employee_id)/count(DISTINCT customer_id) AS cantidad_empleados_por_cliente 
FROM sucursal 
INNER JOIN empleado ON sucursal.branch_id = empleado.branch_id
INNER JOIN cliente ON sucursal.branch_id = cliente.branch_id
GROUP BY sucursal.branch_id 
ORDER BY count(DISTINCT empleado.employee_id)/count(DISTINCT cliente.customer_id) DESC;

--  Obtener la cantidad de tarjetas de crédito por tipo por sucursal
SELECT branch_name, count(card_type) AS cantidad_tarjetas_credito FROM tarjeta 
INNER JOIN cliente ON tarjeta.customer_id = cliente.customer_id 
INNER JOIN sucursal ON cliente.branch_id = sucursal.branch_id 
GROUP BY branch_name ORDER BY branch_name;

-- Obtener el promedio de créditos otorgado por sucursal
SELECT branch_name, loan_type, avg(loan_total) AS promedio_creditos FROM prestamo 
INNER JOIN cliente ON prestamo.customer_id = cliente.customer_id 
INNER JOIN sucursal ON cliente.branch_id = sucursal.branch_id 
GROUP BY branch_name ORDER BY branch_name;

-- La información de las cuentas resulta critica para la compañía, por eso es  necesario crear una tabla denominada “auditoria_cuenta"
CREATE TABLE auditoria_cuenta (
    old_id INTEGER,
    new_id INTEGER,
    old_balance REAL,
    new_balance REAL,
    old_iban VARCHAR(50),
    new_iban VARCHAR(50),
    old_type TEXT,
    new_type TEXT,
    user_action VARCHAR(50),
    create_at TIMESTAMP
);


-- Crear un trigger que después de actualizar en la tabla cuentas los campos balance, IBAN o tipo de cuenta registre en la tabla auditoria 
CREATE TRIGGER actualizar_auditoria 
	AFTER UPDATE ON cuenta
	WHEN old.balance <> new.balance
		OR old.iban <> new.iban
		OR old.balance <> new.balance
BEGIN INSERT INTO auditoria_cuenta(
	old_id,
	new_id,
	old_balance,
	new_balance,
	old_iban,
	new_iban,
	old_type,
	new_type,
	user_action,
	create_at
	)
VALUES(
	old.account_id,
	new.account_id,
	old.balance,
	new.balance,
	old.iban,
	new.iban,
	old.account_type_id,
	new.account_type_id,
	'UPDATE',
	DATETIME('NOW')
	);
	
END;
--Restar $100 a las cuentas 10,11,12,13,14	
UPDATE cuenta SET balance = balance - 100 WHERE account_id IN (10,11,12,13,14);

--Mediante índices mejorar la performance la búsqueda de clientes por DNI
CREATE INDEX dni_cliente ON cliente (customer_DNI);

--Crear la tabla “movimientos” 
CREATE TABLE movimientos (
    movimiento_id INTEGER PRIMARY KEY AUTOINCREMENT,
    num_cuenta INTEGER,
    monto REAL,
    tipo TEXT,
    hora TEXT
);
--Mediante el uso de transacciones, hacer una transferencia de 1000$ desde la cuenta 200 a la cuenta 400 y registrarlo
BEGIN TRANSACTION;
    INSERT INTO movimientos (num_cuenta, monto, tipo, hora) VALUES (400, -1000, 'retiro', strftime('%Y.%m%d', 'now'));
    UPDATE cuenta SET balance = balance - 1000 WHERE account_id = 400;
	INSERT INTO movimientos (num_cuenta, monto, tipo, hora) VALUES (200, 1000, 'deposito', strftime('%Y.%m%d', 'now'));
    UPDATE cuenta SET balance = balance + 1000 WHERE account_id = 200;

COMMIT; 

-- En caso de no poder realizar la operación de forma completa, realizar un ROLLBACK

BEGIN TRANSACTION;
    INSERT INTO movimientos (num_cuenta, monto, tipo, hora) VALUES (400, -1000, 'retiro', strftime('%Y.%m%d', 'now'));
    UPDATE cuenta SET balance = balance - 1000 WHERE account_id = 400;
	INSERT INTO movimientos (num_cuenta, monto, tipo, hora) VALUES (200, 1000, 'deposito', strftime('%Y.%m%d', 'now'));
    UPDATE cuenta SET balance = balance + 1000 WHERE account_id = 200;

ROLLBACK;

--No estamos seguros de como realizar el rollback correctamente en el caso de que no funcione la transaccion