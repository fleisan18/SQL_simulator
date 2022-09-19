--Для книг, которые уже есть на складе (в таблице book), но по другой цене, чем в поставке (supply),  необходимо в таблице book увеличить количество на значение, указанное в поставке,  и пересчитать цену. А в таблице  supply обнулить количество этих книг. 
UPDATE book
INNER JOIN author USING (author_id)
INNER JOIN supply ON book.title = supply.title AND author.name_author = supply.author
SET book.amount = book.amount + supply.amount,
supply.amount = 0,
book.price = (book.price * book.amount + supply.price * supply.amount) / (book.amount + supply.amount)
where book.price != supply.price;

--Включить новых авторов в таблицу author с помощью запроса на добавление, а затем вывести все данные из таблицы author.  Новыми считаются авторы, которые есть в таблице supply, но нет в таблице author.
INSERT INTO author
SELECT author.name_author, supply.author 
FROM author
RIGHT JOIN supply ON author.name_author = supply.author
WHERE author.name_author IS NULL;

--Добавить новые книги из таблицы supply в таблицу book на основе сформированного выше запроса. Затем вывести для просмотра таблицу book.
INSERT INTO book(title, author_id, price, amount)
SELECT supply.title, author.author_id, supply.price, supply.amount
FROM supply
INNER JOIN author ON author.name_author = supply.author
LEFT JOIN book ON supply.title = book.title
WHERE supply.amount <> 0;

-- Занести для книги «Стихотворения и поэмы» Лермонтова жанр «Поэзия», а для книги «Остров сокровищ» Стивенсона - «Приключения». (Использовать два запроса).
UPDATE book
SET genre_id = (SELECT genre_id
     FROM genre
     WHERE name_genre = 'Поэзия')
WHERE title = 'Стихотворения и поэмы';

UPDATE book
SET genre_id = (SELECT genre_id
     FROM genre
     WHERE name_genre = 'Приключения')
WHERE title = 'Остров сокровищ';

--Удалить всех авторов и все их книги, общее количество книг которых меньше 20.
DELETE 
FROM author
WHRE author_id IN
    (SELECT author_id
    FROM book
    GROUP BY author_id
    HAVING SUM(amount) < 20);

--Удалить все жанры, к которым относится меньше 4-х книг. В таблице book для этих жанров установить значение Null.
DELETE FROM genre
WHERE genre_id IN (
SELECT genre_id
FROM book
GROUP BY genre_id
HAVING COUNT(title) < 4);

--Удалить всех авторов, которые пишут в жанре "Поэзия". Из таблицы book удалить все книги этих авторов. В запросе для отбора авторов использовать полное название жанра, а не его id.
DELETE FROM author
USING author
INNER JOIN book ON author.author_id = book.author_id
INNER JOIN genre ON book.genre_id = genre.genre_id
WHERE name_genre = 'Поэзия';
