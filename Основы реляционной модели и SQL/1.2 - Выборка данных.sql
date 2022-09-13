-- Выбрать все названия книг и их количества из таблицы book , для столбца title задать новое имя Название.
SELECT title AS Название, amount 
FROM book;

-- В конце года цену всех книг на складе пересчитывают – снижают ее на 30%. Написать SQL запрос, который из таблицы book выбирает названия, авторов, количества и вычисляет новые цены книг. Столбец с новой ценой назвать new_price, цену округлить до 2-х знаков после запятой.
SELECT title, author, amount, ROUND(price*0.7, 2) AS new_price
FROM book;

-- При анализе продаж книг выяснилось, что наибольшей популярностью пользуются книги Михаила Булгакова, на втором месте книги Сергея Есенина. Исходя из этого решили поднять цену книг Булгакова на 10%, а цену книг Есенина - на 5%. Написать запрос, куда включить автора, название книги и новую цену, последний столбец назвать new_price. Значение округлить до двух знаков после запятой.
SELECT author, title,
ROUND(if (author = 'Булгаков М.А.', price*1.1, 
    if (author = 'Есенин С.А.', 
     price*1.05, 
     price)),2) AS new_price
FROM book;

-- Вывести автора, название  и цены тех книг, количество которых меньше 10.
SELECT author, title, price
FROM book
WHERE amount < 10;

-- Вывести название и автора тех книг, название которых состоит из двух и более слов, а инициалы автора содержат букву «С». Считать, что в названии слова отделяются друг от друга пробелами и не содержат знаков препинания, между фамилией автора и инициалами обязателен пробел, инициалы записываются без пробела в формате: буква, точка, буква, точка. Информацию отсортировать по названию книги в алфавитном порядке.
SELECT title, author
FROM book
WHERE (title LIKE '_% _%' or title LIKE '_% _% _%')
and (author LIKE '%С.%')
ORDER BY title;
