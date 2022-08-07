-- ## Problematica 3

-- Seleccionar las cuentas con saldo negativo
SELECT * FROM cuenta WHERE balance < 0;

-- Seleccionar el nombre, apellido y edad de los clientes que tengan en el apellido la letra Z
SELECT customer_name, customer_surname, (strftime('%Y', 'now') - strftime('%Y', dob)) AS age
FROM cliente WHERE customer_surname LIKE "%z%";

-- Seleccionar el nombre, apellido, edad y nombre de sucursal de las personas 
--cuyo nombre sea “Brendan” y el resultado ordenarlo por nombre de sucursal
SELECT customer_name, customer_surname, (strftime('%Y', 'now') - strftime('%Y', dob)) AS age, branch_name 
FROM cliente, sucursal WHERE customer_name LIKE "brendan" ORDER BY branch_name;

-- Seleccionar de la tabla de préstamos, los préstamos con un importe mayor a $80.000 y los préstamos prendarios utilizando la unión de 
--tablas/consultas (recordar que en las bases de datos la moneda se guarda como integer, en este caso con 2 centavos)
SELECT loan_total FROM prestamo WHERE loan_total/100 > 80000 
UNION SELECT loan_type FROM prestamo WHERE loan_type LIKE "prendario";

-- Seleccionar los prestamos cuyo importe sea mayor que el importe medio de todos los prestamos

SELECT * FROM prestamo WHERE loan_total > (SELECT avg(loan_total) FROM prestamo);

-- Contar la cantidad de clientes menores a 50 años
SELECT count(customer_name) AS menores_de_50 FROM cliente 
WHERE (strftime('%Y', 'now') - strftime('%Y', dob)) < 50;

--  Seleccionar las primeras 5 cuentas con saldo mayor a 8.000$
SELECT * FROM cuenta WHERE balance > 8000 LIMIT 5;

-- Seleccionar los préstamos que tengan fecha en abril, junio y agosto, ordenándolos por importe
SELECT * FROM prestamo WHERE (strftime('%m', loan_date)) IN ("04", "06", "08")
ORDER BY loan_total;

--  Obtener el importe total de los prestamos agrupados por tipo de préstamos. 
--Por cada tipo de préstamo de la tabla préstamo, calcular la suma de sus importes. Renombrar la columna como loan_total_accu
SELECT loan_type, sum(loan_total) AS loan_total_accu FROM prestamo 
GROUP BY loan_type;