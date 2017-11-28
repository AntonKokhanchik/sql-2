# 1. Просмотреть таблицу пользователей и их паролей.
select host, user, authentication_string from mysql.user;
select * from mysql.user;

# 2. Создать пользователя Stud без пароля.
create user Stud;

# 3. Осуществить авторизацию пользователя Stud.

# 4. Задать пароль пользователя Stud, совпадающий с именем, без использования функции Password.
set password for 'Stud'@'%' = 'Stud';

# 5. Создать пользователей Stud1 и Stud2 с паролями, совпадающими с их именами с использованием функции Password.
create user Stud1 identified by 'Stud1';
create user Stud2;
set password for 'Stud2'@'%' = password('Stud2');

# 6. Переименовать пользователя Stud в FirstStud с помощью оператора переименования.
rename user Stud to FirstStud;

# 7. Переименовать пользователя FirstStud в SecondStud, используя прямой доступ к таблице User.
update mysql.user set user='SecondStud' where user='FirstStud';

# 8. Удалить пользователя SecondStud.
drop user SecondStud;

# 9. Наделить пользователя Stud1 привилегиями просмотра, вставки, обновления и удаления по работе с таблицей StudentPredmet.
grant delete, insert, update, select on exam to Stud1;

# 10. Отозвать у пользователя Stud1 две последние привилегии.
revoke delete, update on exam from Stud1;

# 11. Наделить пользователя Stud2 привилегиями просмотра таблицы Student с возможностью передачи этой привилегии другому пользователю.
grant grant option, select on students to Stud2;

# 12. Осуществить авторизацию пользователя Stud2 и наделить привилегией просмотра таблицы Student пользователя Stud1 от Stud2
grant select on students to Stud1;

# 13. Предоставить пользователю Stud1 привилегии просмотра столбца с названиями предметов в таблице Predmet, 
#	  создание представления и создание хранимой процедуры.
grant select(subject_name) on subjects to Stud1;
grant create routine, create view on mydb.* to Stud1;
drop procedure test_proc; 
drop view test_view;

# 14. Создать Superuser и предоставить ему все привилегии.
create user Super identified by 'Super';
grant all privileges on * to Super;

# 15. Наделить пользователя Stud1 привилегией работы с файлами.
grant file on *.* to Stud1;

# 16. Записать данные из таблицы Student в файл Student.txt.

# 17. Создать копию Student1 таблицы Student и загрузить в нее данные из файла Student.txt.
CREATE TABLE Student1 LIKE students;
drop table Student1;
grant delete, insert on Student1 to Stud1;
revoke delete, insert on Student1 from Stud1;

# 18. Показать привилегии всех пользователей.
show grants for Stud1;
show grants for Stud2;
show grants for Super;
select * from mysql.tables_priv;
select * from mysql.db;

# 19. Отозвать все привилегии у пользователей Stud1 и Stud2.
revoke grant option on *.* from Stud1, Stud2;
revoke all on *.* from Stud1, Stud2;
FLUSH PRIVILEGES;

# 20. Удалить пользователей Stud1, Stud2 и Superuser.
drop user 'Stud1'@'%', 'Stud2'@'%', 'Super'@'%';