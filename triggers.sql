# TODO: 7, 10
# в 7 непонятно, как реализовать использование двух триггеров (пересоздать, или пользоваться двумя , аписанными ранее в 5 и 6), и какое поле надо обновлять
# в 10 непонятно, что за поле атрибут, + неясно, что должно отображаться в полях "старое значение", "новое значение": как сделано, или только одно измененое поле?
#
#

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
    set new.lastname = UPPER(new.lastname);
    if new.group_num is null then
		set new.group_num = '15';
	end if;
end //
delimiter ;

delete from students where student_id in ('000001', '000002');
insert into students values
('000001', "Иван", "Иванович", "Иванов", 45, 458945),
('000002', "Иван", "Иванович", "Петров", null, 458945);

# 3. Создайте триггер каскадного удаления Before Delete для таблицы Студент. 
#	 Убедитесь, что удаление записей, на которые есть ссылки в таблице Студент_предмет, происходит. Удалите триггер.
drop trigger stud_before_delete_check;
delimiter //
create definer = current_user trigger stud_before_delete_check before delete on students
for each row
begin
    delete from exam where exam.student_id = old.student_id;
end //
delimiter ;

insert into students value
('000003', "Иван", "Иванович", "Иванов", 45, 458945);
insert into exam value
('000003', 1, 5);
delete from students where student_id ='000003';

# 4. Создайте триггер каскадного удаления After Delete для таблицы Студент. Убедитесь, что каскадное удаление не осуществляется.
drop trigger stud_after_delete_check;
delimiter //
create definer = current_user trigger stud_after_delete_check after delete on students
for each row
begin
    delete from exam where exam.student_id = old.student_id;
end //
delimiter ;

insert into students value
('000004', "Пётр", "Иванович", "Иванов", 45, 458945);
insert into exam value
('000004', 1, 5);
delete from students where student_id ='000004';

# 5. Создайте триггер каскадного обновления Before Update для таблицы Студент. 
#	 Убедитесь, что обновления записей, на которые есть ссылки в таблице Студент_предмет, не происходит. Удалите триггер.
drop trigger stud_before_update_check;
delimiter //
create definer = current_user trigger stud_before_update_check before update on students
for each row
begin
    update exam set exam.student_id = new.student_id where exam.student_id = old.student_id;
end //
delimiter ;

insert into students value
('000005', "Василий", "Иванович", "Иванов", 45, 458945);
insert into exam value
('000005', 1, 5);
update students set student_id = '000555' where student_id = '000005';

# 6. Создайте триггер каскадного обновления After Update для таблицы Студент. Убедитесь, что каскадное обновление не осуществляется.
drop trigger stud_after_update_check;
delimiter //
create definer = current_user trigger stud_after_update_check after update on students
for each row
begin
    update exam set exam.student_id = new.student_id where exam.student_id = old.student_id;
end //
delimiter ;

update students set student_id = '000555' where student_id = '000005';

# 7. Используя два триггера Before Update и After Update осуществите каскадное обновление для таблицы Студент.
update students set student_id = '000555' where student_id = '000005';

# 8. Создайте таблицу Стипендия. Создайте триггер Before Insert для таблицы Стипендия, который при начислении студенту социальной стипендии проверяет, 
#	 должен ли студент получать академическую стипендию, и если должен, то назначает стипендию, равную сумме академической и социальной стипендии.
drop table stipends;
create table stipends (
	student_id varchar(6) PRIMARY KEY,
	lastname varchar(20),
	group_num varchar(2),
	stipend int 
)CHARACTER SET = UTF8;   

drop trigger stipend_insert;
delimiter //
create definer = current_user trigger stipend_insert before insert on stipends
for each row
begin
    if (select sum(mark=5) from exam where exam.student_id = new.student_id) = (select count(mark) from exam where exam.student_id = new.student_id) then
		set new.stipend = 2000 + new.stipend;
	elseif (select sum(mark=4)+sum(mark=5) from exam where exam.student_id = new.student_id) = (select count(mark) from exam where exam.student_id = new.student_id) then
		set new.stipend = 1500 + new.stipend;
	end if;
end //
delimiter ;

insert into stipends values
('000005', "Иванов", 45, 5000),
('130080', "Бабушкин", 45, 3000),
('110246', "Стрелков", 13, 5000);

# 9. Создайте триггер Before Insert для таблицы Стипендия, который проверяет, правильно ли указана группа студента, и при необходимости изменяет номер группы.
drop trigger stipend_check;
delimiter //
create definer = current_user trigger stipend_check before insert on stipends
for each row
begin
	set @group_stud = (select group_num from students where student_id = new.student_id);
    if new.group_num != @group_stud then
		set new.group_num = @group_stud;
	end if;
end //
delimiter ;

delete from stipends where student_id in ('000005', '130080', '110246');
insert into stipends values
('000005', "Иванов", 45, 5000),
('130080', "Бабушкин", 45, 3000),
('110246', "Стрелков", 13, 5000);

# 10. Создать триггеры, осуществляющие аудит операций обновления для всех таблиц. 
#	  Данные об операциях записываются в таблицу Аудит с примерным набором атрибутов: (дата, операция, атрибут, старое значение, новое значение).
drop table audit;
drop trigger stipend_update;
drop trigger exam_update;
drop trigger students_update;
drop trigger subjects_update;

create table audit (
	date_operation datetime,
    name_operation varchar(20),
    old_data text,
    new_data text
)CHARACTER SET = UTF8;   

delimiter //
create definer = current_user trigger stipend_update before update on stipends
for each row
begin
	insert into audit value
    (now(), 'Update_row', concat(old.student_id, ', ', old.lastname, ', ', old.group_num, ', ', old.stipend), concat(new.student_id, ', ', new.lastname, ', ', new.group_num, ', ', new.stipend));
end //
delimiter ;
update stipends set stipend = 8500 where student_id = '110246';

delimiter //
create definer = current_user trigger exam_update before update on exam
for each row
begin
	insert into audit value
    (now(), 'Update_row', concat(old.student_id, ', ', old.subject_id, ', ', old.mark), concat(new.student_id, ', ', new.subject_id, ', ', new.mark));
end //
delimiter ;
update exam set mark = 1 where student_id = '110246' and subject_id = 5;

delimiter //
create definer = current_user trigger students_update before update on students
for each row
begin
	insert into audit value
    (now(), 'Update_row', concat(old.student_id, ', ', old.firstname, ', ', old.surname, ', ', old.lastname, ', ', old.group_num, ', ', old.phone_num), concat(new.student_id, ', ', new.firstname, ', ', new.surname, ', ', new.lastname, ', ', new.group_num, ', ', new.phone_num));
end //
delimiter ;
update students set phone_num = '999999' where student_id = '110246';

delimiter //
create definer = current_user trigger subjects_update before update on subjects
for each row
begin
	insert into audit value
    (now(), 'Update_row', concat(old.subject_id, ', ', old.subject_name, ', ', old.teacher_name, ', ', old.teacher_firstname, ', ', old.teacher_midlename), concat(new.subject_id, ', ', new.subject_name, ', ', new.teacher_name, ', ', new.teacher_firstname, ', ', new.teacher_midlename));
end //
delimiter ;
update subjects set teacher_firstname = "Лидочка" where subject_id = 5;


SHOW TRIGGERS;