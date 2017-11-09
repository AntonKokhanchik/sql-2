# 1. Создайте триггер Before Insert для таблицы Предмет, который при вставке записи о предмете проверяет, входит ли предмет в допустимое множество, и если не входит, задает значение поля предмет равным Null.
drop table if exists valid_subjects;
CREATE TABLE valid_subjects (
    subject_name VARCHAR(50)
)CHARACTER SET = UTF8;

LOAD DATA LOCAL INFILE '//edu.tversu.net/dfs-root/Users/Folders/mamamonova/Desktop/AntonMashaDB/sql-2//valid_subjects.txt' REPLACE INTO TABLE valid_subjects 
CHARACTER SET cp1251;

drop trigger insert_check;
delimiter //
create definer = current_user trigger insert_check before insert on subjects
for each row
begin
	if new.subject_name not in (select subject_name from valid_subjects) then
		set new.subject_name = NULL;
	end if;
end //
delimiter ;

delete from subjects where subject_id between 15 and 19;
insert into subjects value
(15, "музыка", "Островитян", "Генрих", "Вениаминович");
insert into subjects value
(16, "рисование", "Островитян", "Генрих", "Вениаминович");
insert into subjects value
(17, "филология", "Островитян", "Генрих", "Вениаминович");


# 2. Создайте триггер Before Insert для таблицы Студент, который при добавлении нового студента преобразует его фамилию, имя и отчество в верхний регистр, 
#    а при добавлении нового студента с номером группы null вставляет его в группу первого курса с номером 15.
drop trigger stud_insert_check;
delimiter //
create definer = current_user trigger stud_insert_check before insert on students
for each row
begin
	if new.group_num = NULL then
		set new.group_num = 15;
	end if;
    set new.lastname = UPPER(new.lastname);
end //
delimiter ;

insert into students values
(000001, "Иван", "Иванович", "Иванов", 45, 458945),
(000002, "Иван", "Иванович", "Петров", NULL, 458945);