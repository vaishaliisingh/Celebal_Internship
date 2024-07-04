CREATE TABLE StudentDetails (
    StudentId INT PRIMARY KEY,
    StudentName VARCHAR(100),
    GPA FLOAT,
    Branch VARCHAR(10),
    Section CHAR(1)
);
INSERT INTO StudentDetails (StudentId, StudentName, GPA, Branch, Section) VALUES 
(159103036, 'Mohit Agarwal', 8.9, 'CCE', 'A'),
(159103037, 'Rohit Agarwal', 9.2, 'CCE', 'A'),
(159103038, 'Shohit Garg', 5.2, 'CCE', 'A'),
(159103039, 'Mrinal Malhotra', 7.1, 'CCE', 'B'),
(159103040, 'Mehreet Singh', 7.9, 'CCE', 'A'),
(159103041, 'Arjun Tehlan', 5.6, 'CCE', 'A');

CREATE TABLE SubjectDetails (
    SubjectId VARCHAR(10) PRIMARY KEY,
    SubjectName VARCHAR(100),
    MaxSeats INT,
    RemainingSeats INT
);
INSERT INTO SubjectDetails (SubjectId, SubjectName, MaxSeats, RemainingSeats) VALUES 
('PO1491', 'Basics of Political Science', 60, 60),
('PO1492', 'Basics of Accounting', 120, 120),
('PO1493', 'Basics of Financial Markets', 90, 90),
('PO1494', 'Eco philosophy', 60, 60),
('PO1495', 'Automotive Trends', 50, 50);

CREATE TABLE StudentPreference (
    StudentId INT,
    SubjectId VARCHAR(10),
    Preference INT,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId),
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId),
    CONSTRAINT PK_StudentPreference PRIMARY KEY (StudentId, SubjectId)
);

INSERT INTO StudentPreference (StudentId, SubjectId, Preference) VALUES
(159103036, 'PO1491', 1),
(159103036, 'PO1492', 2),
(159103036, 'PO1493', 3),
(159103036, 'PO1494', 4),
(159103036, 'PO1495', 5),
(159103037, 'PO1492', 1),
(159103037, 'PO1491', 2),
(159103038, 'PO1494', 1),
(159103038, 'PO1495', 2),
(159103039, 'PO1493', 1),
(159103040, 'PO1495', 1),
(159103041, 'PO1494', 1);

CREATE TABLE Allotments (
    SubjectId VARCHAR(10),
    StudentId INT,
    FOREIGN KEY (SubjectId) REFERENCES SubjectDetails(SubjectId),
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);
CREATE TABLE UnallotedStudents (
    StudentId INT PRIMARY KEY,
    FOREIGN KEY (StudentId) REFERENCES StudentDetails(StudentId)
);
-- Execute the procedure
CALL AllocateSubjects();

-- Check the results
SELECT * FROM Allotments;
SELECT * FROM UnallotedStudents;
DELIMITER $$

CREATE PROCEDURE AllocateSubjects()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE cur_student INT;
    DECLARE cur_preference INT;
    DECLARE cur_subject VARCHAR(10);

    DECLARE student_cursor CURSOR FOR 
    SELECT StudentId FROM StudentDetails ORDER BY GPA DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN student_cursor;

    read_loop: LOOP
        FETCH student_cursor INTO cur_student;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET cur_preference = 1;
        
        preference_loop: LOOP
            IF cur_preference > 5 THEN
                INSERT INTO UnallotedStudents (StudentId) VALUES (cur_student);
                LEAVE read_loop;
            END IF;

            -- Get the subject for the current preference
            SELECT SubjectId INTO cur_subject 
            FROM StudentPreference 
            WHERE StudentId = cur_student AND Preference = cur_preference;

            -- If a subject is found
            IF cur_subject IS NOT NULL THEN
                -- Check if the subject has remaining seats
                IF (SELECT RemainingSeats FROM SubjectDetails WHERE SubjectId = cur_subject) > 0 THEN
                    -- Allocate the subject to the student
                    UPDATE SubjectDetails 
                    SET RemainingSeats = RemainingSeats - 1 
                    WHERE SubjectId = cur_subject;

                    INSERT INTO Allotments (SubjectId, StudentId) VALUES (cur_subject, cur_student);
                    LEAVE read_loop;
                END IF;
            END IF;

            SET cur_preference = cur_preference + 1;
        END LOOP preference_loop;
    END LOOP read_loop;

    CLOSE student_cursor;
END$$

DELIMITER ;






