# 1. Создать процедуру для получения экзаменационной ведомости по математике группы 11.
create procedure Ведомость_математика(in s varchar(50) character set UTF8)
	select * from students natural join exam natural join subjects where group_num = 11 and subject_name = s;
    
call Ведомость_математика("математика");
drop procedure Ведомость_математика;

# 2. Создать процедуру с параметрами для изменения оценки заданного студента по заданной дисциплине после пересдачи экзамена.
create procedure Пересдача(student varchar(6), subj varchar(50) character set UTF8, new_mark varchar(4))
	update exam set mark = new_mark where student_id = student and subject_id in 
		(select subject_id from sub0jects where subject_name = subj);
        
call Пересдача (130056, 'математика', 4);
drop procedure Пересдача;

# 3. Создать процедуру для определения предметов с самой низкой успеваемостью.
# вспомогательная вьюха
create view avgMark as
	select avg(mark) as m, subject_id from exam group by subject_id;
select * from avgMark;

# сама процедура
create procedure Успеваемость()
	select * from subjects where subject_id in 
		(select subject_id from avgMark where m =
			(select min(m) from avgMark));
            
call Успеваемость();
drop procedure Успеваемость;

# 4. Создать процедуру с параметрами для определения числа задолжников в группе, в которой учится данный студент.
create procedure задолжники_согрупники (student varchar(6))
	select count(student_id) from students 
		where group_num = (select group_num from students where student_id = student)
        and student_id in (select student_id from exam where mark < 3 group by student_id);

call задолжники_согрупники(130056);
drop procedure задолжники_согрупники;

# 5. Для предыдущего задания создать функцию с параметром.
delimiter //
create function задолжники_той_же_группы (student varchar(6))
returns int
comment 'Возвращает количество задолжников той же группы, что заданный студент'
begin
	declare count_zadol int;
    select count(student_id) into count_zadol from students 
		where group_num = (select group_num from students where student_id = student)
        and student_id in (select student_id from exam where mark < 3 group by student_id);
	return count_zadol;
end//
delimiter ;

select задолжники_той_же_группы(130056);
    
# 6. Создать процедуру с параметрами для определения числа студентов в заданной группе, которые имеют оценку по заданной дисциплине выше средней в группе.
create procedure средний_балл_в_группе_по_предмету(group_n varchar(2), subj varchar(50) character set UTF8, out _mark varchar(4))
	select avg(mark) into _mark from students natural join exam natural join subjects where group_num = group_n and subject_name = subj;
call средний_балл_в_группе_по_предмету(11, "математика", @lalal);
select @lalal;

delimiter //
create procedure количество_сутдентов_выше_среднего (group_n varchar(2), subj varchar(50) character set UTF8)
begin
	call средний_балл_в_группе_по_предмету(group_n, subj, @avg_mark);
	select count(student_id) from students natural join exam natural join subjects where group_num = group_n and subject_name = subj and mark > @avg_mark;
end//
delimiter ;
call количество_сутдентов_выше_среднего(11, "математика");
drop procedure количество_сутдентов_выше_среднего;

# 7. Для предыдущего задания создать функцию с параметрами.
delimiter //
create function то_же_количество_сутдентов_выше_среднего(group_n varchar(2), subj varchar(50) character set UTF8)
returns int
comment 'Возвращает количество студентов в заданной группе, которые имеют оценку по заданной дисциплине выше средней в группе'
begin
	declare count_this_students int;
	call средний_балл_в_группе_по_предмету(group_n, subj, @avg_mark);
	select count(student_id) into count_this_students from students natural join exam natural join subjects where group_num = group_n and subject_name = subj and mark > @avg_mark;
    return count_this_students;
end//
delimiter ;
select то_же_количество_сутдентов_выше_среднего(11, "математика");

# 8. Создать процедуру, которая переводит студентов на следующий курс по итогам сессии. Если курс последний, запись удаляется. Использовать условный оператор и курсор.
create procedure количество_плохих_оценок (student varchar(6), out bad_marks int)
	select count(mark) into bad_marks from exam where student_id = student and mark <= 2;
drop procedure количество_плохих_оценок;
    
delimiter //
create procedure перевод_на_следующий_курс ()
begin
	declare done int default 0;
    declare s varchar(6);
    declare g varchar(2);
    declare bad_marks int;
	declare i_stud cursor for select student_id, group_num from students;
    declare continue handler for sqlstate '02000' set done=1;
    open i_stud;
    fetch i_stud into s, g;
    repeat
		call количество_плохих_оценок(s, bad_marks);
        if bad_marks = 0 then
			if g >= 50 then
				delete from exam where student_id = s;
				delete from students where student_id = s;
			else
				update students set group_num = group_num + 10 where student_id = s;
			end if;
		end if;
        fetch i_stud into s, g;
	until done
	end repeat;
end //
delimiter ;
drop procedure перевод_на_следующий_курс;
call перевод_на_следующий_курс();

# 9. Создать процедуру, которая выводит либо оценки студентов по заданной дисциплине, либо баллы в зависимости от значения входного параметра С. Использовать условный оператор.
delimiter //
create procedure баллы_или_оценка (C varchar(6), subj varchar(50) character set UTF8)
begin
	if (C='оценка') then
		select student_id, lastname, mark as оценка from students natural join exam natural join subjects where subject_name=subj;
	else if (C='баллы') then
		select student_id, lastname, mark*20 as баллы from students natural join exam natural join subjects where subject_name=subj;
	end if;
    end if;
end //
delimiter ;
drop procedure баллы_или_оценка;
call баллы_или_оценка('баллы', 'математика');
call баллы_или_оценка('оценка', 'математика');

#10. Написать процедуру, которая создает новую таблицу 
# Результаты сессии: (Номер_зачетки, Фамилия_студента, Номер_группы, количество экзаменов, количество оценок 5, 4, 3 и задолженностей (не сданных и не сдававшихся экзаменов)); 
# и таблицу Стипендиальная ведомость: (Номер_зачетки, Фамилия_студента, Номер_группы, стипендия). 
# Стипендия начисляется из условия: одна 5, остальные – 4 – 1500 руб., все 5 – 2000 руб. Использовать курсор.
delimiter //
create procedure результаты_экзаменов_и_стипендиальная_ведомость()
begin
	begin
		drop table if exists exam_results;
		drop table if exists stipends;
		create table exam_results (
			stud_id varchar(6) PRIMARY KEY,
			stud_name varchar(20),
			group_n varchar(2),
			count_exams int,
			count_mark_3 int,
			count_mark_4 int,
			count_mark_5 int,
			count_debt int 
		)CHARACTER SET = UTF8;
		create table stipends (
			student_id varchar(6) PRIMARY KEY,
			lastname varchar(20),
			group_num varchar(2),
			stipend int 
		)CHARACTER SET = UTF8;    
	end;
    begin
		declare done int default 0;
		declare s varchar(6);
		declare l varchar(20);
		declare g varchar(2);
		declare c_exams, c_mark_3, c_mark_4, c_mark_5, c_debt int;
		declare i cursor for 
			select student_id, lastname, group_num, count(mark), sum(mark=3), sum(mark=4), sum(mark=5), count(mark)-sum(mark=3)-sum(mark=4)-sum(mark=5) from students natural join exam group by student_id;
		declare continue handler for sqlstate '02000' set done=1;
		open i;
		fetch i into s, l, g, c_exams, c_mark_3, c_mark_4, c_mark_5, c_debt; 
		repeat
			insert into exam_results values (s, l, g, c_exams, c_mark_3, c_mark_4, c_mark_5, c_debt);
            if(c_mark_5 = c_exams) then
				insert into stipends values(s, l, g, 2000);
			else if (c_mark_5 = 1 and c_mark_4 = c_exams-1) then
				insert into stipends values(s, l, g, 1500);
            end if;
            end if;
			fetch i into s, l, g, c_exams, c_mark_3, c_mark_4, c_mark_5, c_debt; 
		until done
		end repeat;
	end;
end //
delimiter ;
drop procedure результаты_экзаменов_и_стипендиальная_ведомость;
call результаты_экзаменов_и_стипендиальная_ведомость;

# 11. Создать процедуру, которая изменяет регистр фамилий студентов на верхний. Использовать курсоры.
delimiter //
create procedure фамилии_в_верхний_регистр()
begin
	declare done int default 0;
    declare id varchar(6);
	declare i cursor for select student_id from students;
    declare continue handler for sqlstate '02000' set done=1;
    open i;
    repeat
        fetch i into id;
        update students set lastname = UPPER(lastname) where student_id = id;
	until done
	end repeat;
end //
delimiter ;

drop procedure фамилии_в_верхний_регистр;
call фамилии_в_верхний_регистр();

# 12. Создать процедуру, которая генерирует пароли студентов для теста и помещает их в создаваемую таблицу Пароли. 
# Использовать курсоры.
delimiter //
create procedure generate_passwords()
begin
	declare done int default 0;
    declare id varchar(6);
	declare i cursor for select student_id from students;
    declare continue handler for sqlstate '02000' set done=1;
    
    create table if not exists passwords (
		student_id varchar(6) primary key, 
        pass varchar(32),
          FOREIGN KEY(student_id) REFERENCES students(student_id)
	)CHARACTER SET = UTF8;
    
    open i;
    fetch i into id;
    repeat
        insert INTO passwords (student_id, pass) 
        VALUES(id, cast(RAND()*(999999999999-10000000)+10000000 as unsigned)) 
			ON DUPLICATE KEY UPDATE pass=cast(RAND()*(999999999999-10000000)+10000000 as unsigned);
        fetch i into id;
	until done
	end repeat;
end //
delimiter ;

drop table passwords;
drop procedure generate_passwords;
call generate_passwords();