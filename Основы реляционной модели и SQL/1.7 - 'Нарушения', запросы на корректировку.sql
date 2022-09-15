CREATE TABLE fine
(
    fine_id        INT PRIMARY KEY GENERATED ALWAYS AS identity,
    name           TEXT,
    number_plate   TEXT,
    violation      TEXT,
    sum_fine       DECIMAL(8, 2),
    date_violation DATE,
    date_payment   DATE
);

INSERT INTO fine (name, number_plate, violation, sum_fine, date_violation, date_payment)
VALUES ('Баранов П.Е.', 'P523BT', 'Превышение скорости(от 40 до 60)', NULL, '2020-02-14 ', NULL),
       ('Абрамова К.А.', 'О111AB', 'Проезд на запрещающий сигнал', NULL, '2020-02-23', NULL),
       ('Яковлев Г.Р.', 'T330TT', 'Проезд на запрещающий сигнал', NULL, '2020-03-03', NULL),
       ('Баранов П.Е.', 'P523BT', 'Превышение скорости(от 40 до 60)', 500.00, '2020-01-12', '2020-01-17'),
       ('Абрамова К.А.', 'О111AB', 'Проезд на запрещающий сигнал', 1000.00, '2020-01-14', '2020-02-27'),
       ('Яковлев Г.Р.', 'T330TT', 'Превышение скорости(от 20 до 40)', 500.00, '2020-01-23', '2020-02-23'),
       ('Яковлев Г.Р.', 'M701AA', 'Превышение скорости(от 20 до 40)', NULL, '2020-01-12', NULL),
       ('Колесов С.П.', 'K892AX', 'Превышение скорости(от 20 до 40)', NULL, '2020-02-01', NULL);

DROP TABLE IF EXISTS traffic_violation CASCADE;

CREATE TABLE traffic_violation
(
    violation_id INT PRIMARY KEY GENERATED ALWAYS AS identity,
    violation    TEXT,
    sum_fine     DECIMAL(8, 2)
);

INSERT INTO traffic_violation (violation, sum_fine)
VALUES ('Превышение скорости(от 20 до 40)', 500),
       ('Превышение скорости(от 40 до 60)', 1000),
       ('Проезд на запрещающий сигнал', 1000);

--Создать таблицу fine следующей структуры:
CREATE TABLE fine(fine_id int primary key AUTO_INCREMENT, 
                  name varchar(30), 
                  number_plate varchar(6), 
                  violation varchar(60), 
                  sum_fine   decimal(8,2), 
                  date_violation date, 
                  date_payment date);
                  
-- В таблицу fine первые 5 строк уже занесены. Добавить в таблицу записи с ключевыми значениями 6, 7, 8.
INSERT INTO fine(name, number_plate, violation, sum_fine, date_violation, date_payment)
VALUES
('Баранов П.Е.',	'Р523ВТ',	'Превышение скорости(от 40 до 60)',	500.00,	'2020-01-12',	'2020-01-17'),
('Абрамова К.А.',	'О111АВ',	'Проезд на запрещающий сигнал',	1000.00,	'2020-01-14',	'2020-02-27'),
('Яковлев Г.Р.',	'Т330ТТ',	'Превышение скорости (от 20 до 40)',	500.00,	'2020-01-23',	'2020-02-23'),
('Яковлев Г.Р.',	'М701АА',	'Превышение скорости(от 20 до 40), null, '2020-01-12', null),
('Колесов С.П.',	'К892АХ',	'Превышение скорости(от 20 до 40)' null, '2020-02-01', null),
('Баранов П.Е.', 'Р523ВТ', 'Превышение скорости(от 40 до 60)', null, '2020-02-14', null),
('Абрамова К.А.',	'О111АВ',	'Проезд на запрещающий сигнал', null, '2020-02-23', null),
('Яковлев Г.Р.', 'Т330ТТ',	'Проезд на запрещающий сигнал', null, '2020-03-03', null);

--Занести в таблицу fine суммы штрафов, которые должен оплатить водитель, в соответствии с данными из таблицы traffic_violation. При этом суммы заносить только в пустые поля столбца  sum_fine.
UPDATE fine f, traffic_violation tv
SET f.sum_fine = tv.sum_fine 
WHERE f.sum_fine IS NULL AND f.violation = tv.violation;

--Вывести фамилию, номер машины и нарушение только для тех водителей, которые на одной машине нарушили одно и то же правило   два и более раз. При этом учитывать все нарушения, независимо от того оплачены они или нет. Информацию отсортировать в алфавитном порядке, сначала по фамилии водителя, потом по номеру машины и, наконец, по нарушению.
SELECT name, number_plate, violation
FROM fine
GROUP BY name, number_plate, violation
HAVING COUNT(*) >= 2
ORDER BY name, number_plate, violation;

--В таблице fine увеличить в два раза сумму неоплаченных штрафов для отобранных на предыдущем шаге записей. 
UPDATE fine, (SELECT name, number_plate, violation
                FROM fine
                GROUP BY name, number_plate, violation
                HAVING COUNT(*) >= 2
                ORDER BY name, number_plate, violation) query_in
SET sum_fine = 2 * sum_fine
WHERE fine.name = query_in.name AND fine.date_payment IS NULL;

--Водители оплачивают свои штрафы. В таблице payment занесены даты их оплаты:
--Необходимо:
--в таблицу fine занести дату оплаты соответствующего штрафа из таблицы payment; 
--уменьшить начисленный штраф в таблице fine в два раза  (только для тех штрафов, информация о которых занесена в таблицу payment) , если оплата произведена не позднее 20 дней со дня нарушения.
UPDATE fine, payment
SET
fine.date_payment = IF(fine.date_payment IS NULL, payment.date_payment, fine.date_payment),
fine.sum_fine = IFf(datediff(payment.date_payment, payment.date_violation) <= 20, 
                 fine.sum_fine / 2, fine.sum_fine)
WHERE (fine.name, fine.violation, fine.date_violation) = (payment.name, payment.violation, payment.date_violation);

--Создать новую таблицу back_payment, куда внести информацию о неоплаченных штрафах (Фамилию и инициалы водителя, номер машины, нарушение, сумму штрафа  и  дату нарушения) из таблицы fine.
CREATE TABLE back_payment AS
SELECT name, number_plate, violation, sum_fine, date_violation  FROM fine 
WHERE date_payment IS NULL;

