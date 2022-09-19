--Включить нового человека в таблицу с клиентами. Его имя Попов Илья, его email popov@test, проживает он в Москве.
INSERT INTO client (name_client, city_id, email)
SELECT 'Попов Илья', city.city_id, 'popov@test'
FROM city
WHERE name_city = 'Москва';

--Создать новый заказ для Попова Ильи. Его комментарий для заказа: «Связаться со мной по вопросу доставки».
INSERT INTO buy (buy_description, client_id)
SELECT 'Связаться со мной по вопросу доставки', client.client_id
FROM client
WHERE name_client = 'Попов Илья';

--В таблицу buy_book добавить заказ с номером 5. Этот заказ должен содержать книгу Пастернака «Лирика» в количестве двух экземпляров и книгу Булгакова «Белая гвардия» в одном экземпляре.
INSERT INTO buy_book (buy_id, book_id, amount)
SELECT 5, book.book_id, 2
FROM book
INNER JOIN author
WHERE title = 'Лирика' AND name_author = 'Пастернак Б.Л.';

INSERT INTO buy_book (buy_id, book_id, amount)
SELECT 5, book.book_id, 1
FROM book
INNER JOIN author
WHERE title = 'Белая гвардия' AND name_author = 'Булгаков М.А.';

--Количество тех книг на складе, которые были включены в заказ с номером 5, уменьшить на то количество, которое в заказе с номером 5  указано.
UPDATE book, buy_book
SET book.amount = book.amount - buy_book.amount
WHERE buy_book.buy_id = 5 AND book.book_id=buy_book.book_id;

--Создать счет (таблицу buy_pay) на оплату заказа с номером 5, в который включить название книг, их автора, цену, количество заказанных книг и  стоимость. Последний столбец назвать Стоимость. Информацию в таблицу занести в отсортированном по названиям книг виде.
CREATE TABLE table buy_pay AS
SELECT book.title, author.name_author, book.price, buy_book.amount, book.price * buy_book.amount AS Стоимость
FROM author
INNER JOIN book USING (author_id)
INNER JOIN buy_book USING (book_id)
WHERE buy_id = 5
ORDER BY title;

--Создать общий счет (таблицу buy_pay) на оплату заказа с номером 5. Куда включить номер заказа, количество книг в заказе (название столбца Количество) и его общую стоимость (название столбца Итого). Для решения используйте ОДИН запрос.
CREATE TABLE  buy_pay AS
SELECT buy_id, SUM(buy_book.amount) AS Количество, SUM(book.price * buy_book.amount) AS Итого
FROM book 
INNER JOIN buy_book USING (book_id)
GROUP BY buy_id
HAVING buy_id = 5;

--В таблицу buy_step для заказа с номером 5 включить все этапы из таблицы step, которые должен пройти этот заказ. В столбцы date_step_beg и date_step_end всех записей занести Null.
INSERT INTO buy_step (buy_id, step_id, date_step_beg, date_step_end)
SELECT buy.buy_id, step.step_id, NULL, NULL
FROM buy
LEFT JOIN buy_step ON buy.buy_id = buy_step.buy_id
CROSS JOIN step 
WHERE buy.buy_id = 5;

--В таблицу buy_step занести дату 12.04.2020 выставления счета на оплату заказа с номером 5.
UPDATE buy_step, step
SET date_step_beg = '2020-04-12' 
WHERE buy_step.step_id = step.step_id AND step.name_step = 'Оплата' AND buy_id = 5;

--Завершить этап «Оплата» для заказа с номером 5, вставив в столбец date_step_end дату 13.04.2020, и начать следующий этап («Упаковка»), задав в столбце date_step_beg для этого этапа ту же дату.

Реализовать два запроса для завершения этапа и начала следующего. Они должны быть записаны в общем виде, чтобы его можно было применять для любых этапов, изменив только текущий этап. Для примера пусть это будет этап «Оплата».
UPDATE
  buy_step
SET
  date_step_end = IF(
    step_id = (
      SELECT
        step_id
      FROM
        step
      WHERE
        name_step = "Оплата"
    ),
    '2020-04-13',
    date_step_end
  ),
  date_step_beg = IF(
    step_id = (
      SELECT
        step_id
      FROM
        step
      WHERE
        name_step = "Упаковка"
    ),
    '2020-04-13',
    date_step_beg
  )
WHERE buy_id = 5;
