use mydb;
show tables;
select * from exam;
insert into exam value ('000005', 2, 5);
update exam set mark=3 where student_id = '000005' and subject_id = 2;
delete from exam where student_id = '000005' and subject_id = 2;

select * from students;

select subject_name from subjects;
create procedure test_proc()
	select sibject_name from subjects;
create view test_view as select * from exam;

select * into outfile 'C:/ProgramData/MySQL/MySQL Server 5.7/Uploads/Student.txt' from students;
SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 5.7/Uploads/Student.txt' REPLACE INTO TABLE Student1;