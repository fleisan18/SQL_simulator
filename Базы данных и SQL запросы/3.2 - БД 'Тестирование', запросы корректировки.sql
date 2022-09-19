--В таблицу attempt включить новую попытку для студента Баранова Павла по дисциплине «Основы баз данных». Установить текущую дату в качестве даты выполнения попытки.
INSERT INTO attempt (student_id, subject_id, date_attempt)
SELECT (SELECT student_id
        FROM student
        WHERE name_student = 'Баранов Павел'), 
        (SELECT subject_id
         FROM subject
         WHERE name_subject = 'Основы баз данных'), 
         CURDATE();
 
--Случайным образом выбрать три вопроса (запрос) по дисциплине, тестирование по которой собирается проходить студент, занесенный в таблицу attempt последним, и добавить их в таблицу testing. id последней попытки получить как максимальное значение id из таблицы attempt.
INSERT INTO testing (attempt_id, question_id)
SELECT attempt_id, question_id
        FROM question 
        JOIN attempt ON question.subject_id = attempt.subject_id
WHERE attempt_id = (SELECT MAX(attempt_id)
                    FROM attempt)
ORDER BY RAND()
LIMIT 3;

--Студент прошел тестирование (то есть все его ответы занесены в таблицу testing), далее необходимо вычислить результат(запрос) и занести его в таблицу attempt для соответствующей попытки.  Результат попытки вычислить как количество правильных ответов, деленное на 3 (количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до целого.
--Будем считать, что мы знаем id попытки,  для которой вычисляется результат, в нашем случае это 8. В таблицу testing занесены следующие ответы пользователя:

+------------+------------+-------------+-----------+
| testing_id | attempt_id | question_id | answer_id |
+------------+------------+-------------+-----------+
| 22         | 8          | 7           | 19        |
| 23         | 8          | 6           | 17        |
| 24         | 8          | 8           | 22        |
+------------+------------+-------------+-----------+
UPDATE attempt 
SET result = (SELECT ROUND(SUM((is_correct) / 3 * 100))
              FROM answer
              LEFT JOIN testing ON answer.answer_id = testing.answer_id
              WHERE attempt_id = 8
              GROUP BY attempt_id)
WHERE attempt_id = 8;

--Удалить из таблицы attempt все попытки, выполненные раньше 1 мая 2020 года. Также удалить и все соответствующие этим попыткам вопросы из таблицы testing, которая создавалась следующим запросом:

CREATE TABLE testing (
    testing_id INT PRIMARY KEY AUTO_INCREMENT, 
    attempt_id INT, 
    question_id INT, 
    answer_id INT,
    FOREIGN KEY (attempt_id)  REFERENCES attempt (attempt_id) ON DELETE CASCADE
);

DELETE FROM attempt
USING attempt
INNER JOIN testing ON attempt.attempt_id = testing.attempt_id
WHERE date_attempt < '2020-05-01';
