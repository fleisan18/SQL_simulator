--Вывести все заказы Баранова Павла (id заказа, какие книги, по какой цене и в каком количестве он заказал) в отсортированном по номеру заказа и названиям книг виде.
SELECT buy.buy_id AS buy_id, title, price, buy_book.amount
FROM client 
INNER JOIN buy ON client.client_id = buy.client_id
INNER JOIN buy_book ON buy.buy_id = buy_book.buy_id
INNER JOIN book ON buy_book.book_id = book.book_id
WHERE name_client = 'Баранов Павел'
ORDER BY buy.buy_id, title;

--Посчитать, сколько раз была заказана каждая книга, для книги вывести ее автора (нужно посчитать, в каком количестве заказов фигурирует каждая книга).  Вывести фамилию и инициалы автора, название книги, последний столбец назвать Количество. Результат отсортировать сначала  по фамилиям авторов, а потом по названиям книг.
SELECT name_author, title, COUNT(buy_book.buy_id) AS Количество
FROM book
INNER JOIN author ON book.author_id = author.author_id
LEFT JOIN buy_book ON book.book_id = buy_book.book_id
GROUP BY title, name_author
ORDER BY name_author, title;

--Вывести города, в которых живут клиенты, оформлявшие заказы в интернет-магазине. Указать количество заказов в каждый город, этот столбец назвать Количество. Информацию вывести по убыванию количества заказов, а затем в алфавитном порядке по названию городов.
SELECT name_city, count(buy.client_id) AS Количество
FROM city
INNER JOIN client ON city.city_id = client.city_id
INNER JOIN buy ON client.client_id = buy.client_id
GROUP BY name_city
ORDER BY Количество DESC, name_city;

--Вывести номера всех оплаченных заказов и даты, когда они были оплачены.
SELECT buy_id, date_step_end
FROM buy_step
INNER JOIN step ON buy_step.step_id = step.step_id
WHRE name_step = 'Оплата' AND date_step_end IS NOT NULL;

--Вывести информацию о каждом заказе: его номер, кто его сформировал (фамилия пользователя) и его стоимость (сумма произведений количества заказанных книг и их цены), в отсортированном по номеру заказа виде. Последний столбец назвать Стоимость.
SELECT buy.buy_id, name_client, SUM(buy_book.amount * book.price) AS Стоимость
FROM book
INNER JOIN buy_book ON buy_book.book_id = book.book_id
INNER JOIN buy ON buy.buy_id = buy_book.buy_id
INNER JOIN client ON client.client_id = buy.client_id
GROUP BY name_client, buy.buy_id
ORDER BY buy.buy_id;

--Вывести номера заказов (buy_id) и названия этапов,  на которых они в данный момент находятся. Если заказ доставлен –  информацию о нем не выводить. Информацию отсортировать по возрастанию buy_id.
SELECT buy_id, name_step
FROM step
INNER JOIN buy_step ON step.step_id = buy_step.step_id
WHERE date_step_end IS NULL AND date_step_beg IS NOT NULL;

--В таблице city для каждого города указано количество дней, за которые заказ может быть доставлен в этот город (рассматривается только этап Транспортировка). Для тех заказов, которые прошли этап транспортировки, вывести количество дней за которое заказ реально доставлен в город. А также, если заказ доставлен с опозданием, указать количество дней задержки, в противном случае вывести 0. В результат включить номер заказа (buy_id), а также вычисляемые столбцы Количество_дней и Опоздание. Информацию вывести в отсортированном по номеру заказа виде.
SELECT buy_id, 
    SUM(DATEDIFF(date_step_end, date_step_beg)) AS Количество_дней, 
    SUM(IF(DATEDIFF(date_step_end, date_step_beg) > city.days_delivery, DATEDIFF(date_step_end, date_step_beg) - city.days_delivery, 0)) AS Опоздание
FROM step
INNER JOIN buy_step USING (step_id)
INNER JOIN buy USING (buy_id)
INNER JOIN client USING (client_id)
INNER JOIN city USING (city_id)
WHERE name_step = 'Транспортировка' AND date_step_end IS NOT NULL
GROUP BY buy_id;

--Выбрать всех клиентов, которые заказывали книги Достоевского, информацию вывести в отсортированном по алфавиту виде. В решении используйте фамилию автора, а не его id.
SELECT DISTINCT name_client
FROM client
INNER JOIN buy ON client.client_id = buy.client_id
INNER JOIN buy_book ON buy.buy_id = buy_book.buy_id
INNER JOIN book ON book.book_id = buy_book.book_id
INNER JOIN author ON book.author_id = author.author_id
WHERE name_author = 'Достоевский Ф.М.'
ORDER BY name_client;

--Вывести жанр (или жанры), в котором было заказано больше всего экземпляров книг, указать это количество. Последний столбец назвать Количество.
SELECT name_genre, SUM(buy_book.amount) AS Количество
FROM buy_book
INNER JOIN book ON book.book_id = buy_book.book_id
INNER JOIN genre ON genre.genre_id = book.genre_id
GROUP BY name_genre
HAVING Количество = (
         SELECT SUM(buy_book.amount) AS Количество
         FROM buy_book
         INNER JOIN book ON book.book_id = buy_book.book_id
         INNER JOIN genre ON genre.genre_id = book.genre_id
         GROUP BY name_genre
         ORDER BY Количество desc
         LIMIT 1);
         
--Сравнить ежемесячную выручку от продажи книг за текущий и предыдущий годы. Для этого вывести год, месяц, сумму выручки в отсортированном сначала по возрастанию месяцев, затем по возрастанию лет виде. Название столбцов: Год, Месяц, Сумма.
SELECT EXTRACT(YEAR FROM buy_step.date_step_end) AS Год, MONTHNAME(buy_step.date_step_end) AS Месяц, SUM(buy_book.amount * book.price) AS Сумма
FROM step
INNER JOIN buy_step USING (step_id)
INNER JOIN buy USING (buy_id)
INNER JOIN buy_book USING (buy_id)
INNER JOIN book USING (book_id)
WHERE EXTRACT(YEAR FROM buy_step.date_step_end) IS NOT NULL AND name_step = 'Оплата'
GROUP BY Год, Месяц 
UNION
SELECT EXTRACT(YEAR FROM date_payment) AS Год, MONTHNAME(date_payment) AS Месяц, SUM(amount * price) AS Сумма
FROM buy_archive
GROUP BY Год, Месяц
ORDER BY Месяц, Год;

--Для каждой отдельной книги необходимо вывести информацию о количестве проданных экземпляров и их стоимости за текущий и предыдущий год . Вычисляемые столбцы назвать Количество и Сумма. Информацию отсортировать по убыванию стоимости.
SELECT subquery.title AS title, SUM(subquery.Количество) AS Количество, SUM(subquery.Сумма) AS Сумма
FROM 
(SELECT title, SUM(buy_book.amount) AS Количество, SUM(book.price * buy_book.amount) AS Сумма
FROM book
INNER JOIN buy_book USING (book_id)
INNER JOIN buy USING (buy_id)
INNER JOIN buy_step USING (buy_id)
INNER JOIN step USING (step_id)
WHERE buy_step.date_step_end IS NOT NULL AND step.name_step = 'Оплата'
GROUP BY title
 
UNION ALL
 
SELECT title, SUM(buy_archive.amount) AS Количество, SUM(buy_archive.price * buy_archive.amount) AS Сумма
FROM book
INNER JOIN buy_archive USING (book_id)
GROUP BY title) subquery
GROUP BY title
ORDER BY Сумма DESC;

