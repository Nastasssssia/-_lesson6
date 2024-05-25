
/* Создайте таблицу users_old, аналогичную таблице users. Создайте процедуру, с помощью которой можно переместить любого (одного)
 пользователя из таблицы users в таблицу users_old. (использование транзакции с выбором commit или rollback – обязательно). */ 
 
 -- Создание таблицы users_old
 DROP TABLE IF EXISTS users_old;
 CREATE TABLE users_old LIKE users;

-- Создание процедуры
DROP PROCEDURE IF EXISTS move_user_to_old;
DELIMITER //
CREATE PROCEDURE move_user_to_old(IN user_id INT)
BEGIN
    DECLARE rollback_flag BOOLEAN DEFAULT FALSE;
    DECLARE user_exists INT DEFAULT 0;
    -- Обработчик исключений 
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET rollback_flag = TRUE;
        ROLLBACK;
    END;
    -- Проверка существования пользователя
    SELECT COUNT(*) INTO user_exists FROM users WHERE id = user_id;
    IF user_exists = 0 THEN
        SELECT 'Ошибка! Пользователь с таким id не существует.' AS status;
    ELSE
        -- Начало транзакции
        START TRANSACTION;
        -- Перемещение пользователя из users в users_old
        INSERT INTO users_old 
        SELECT * FROM users WHERE id = user_id;
        -- Удаление пользователя из users
        DELETE FROM users WHERE id = user_id;
        -- Проверка флага ошибки и выполнение коммита или отката
        IF rollback_flag THEN
            -- Если произошла ошибка, уже выполнен ROLLBACK в обработчике
            SELECT 'Ошибка! Пользователь не был перемещен.' AS status;
        ELSE
            COMMIT;
            SELECT 'Пользователь успешно перемещен в таблицу users_old.' AS status;
        END IF;
    END IF;
END //
DELIMITER ;
-- Вызов процедуры
CALL move_user_to_old(4);

-- Проверка таблицы users_old, users
SELECT * FROM users;
SELECT * FROM users_old;


/* Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. 
С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
 с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи". */
 
DELIMITER //

CREATE FUNCTION hello() RETURNS VARCHAR(50) READS SQL DATA
BEGIN
    DECLARE current_hour INT;
    DECLARE greeting VARCHAR(50);
    SET current_hour = HOUR(NOW());
    IF current_hour >= 6 AND current_hour < 12 THEN
        SET greeting = 'Доброе утро';
    ELSEIF current_hour >= 12 AND current_hour < 18 THEN
        SET greeting = 'Добрый день';
    ELSEIF current_hour >= 18 AND current_hour < 24 THEN
        SET greeting = 'Добрый вечер';
    ELSE
        SET greeting = 'Доброй ночи';
    END IF;
    RETURN greeting;
END//
DELIMITER ;

-- вызов функции
SELECT hello();




