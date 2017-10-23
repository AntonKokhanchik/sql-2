#чтобы незаполненное значение в файле (пустая строчка) считалась как NULL, или false-значением
SET SESSION sql_mode = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';

LOAD DATA LOCAL INFILE 'D:/tmp//students.txt' REPLACE INTO TABLE students 
CHARACTER SET cp1251;

LOAD DATA LOCAL INFILE 'D:/tmp//subjects.txt' REPLACE INTO TABLE subjects 
CHARACTER SET cp1251;

LOAD DATA LOCAL INFILE 'D:/tmp//exam.txt' REPLACE INTO TABLE exam 
CHARACTER SET cp1251