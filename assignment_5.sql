-- Create the SubjectAllotments table
CREATE TABLE SubjectAllotments (
    StudentID VARCHAR(50) NOT NULL,
    SubjectID VARCHAR(50) NOT NULL,
    Is_Valid BIT NOT NULL,
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (StudentID, SubjectID)
);

-- Create the SubjectRequest table
CREATE TABLE SubjectRequest (
    StudentID VARCHAR(50) NOT NULL,
    SubjectID VARCHAR(50) NOT NULL,
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE PROCEDURE UpdateSubjectAllotment
AS
BEGIN
    -- Declare a cursor to iterate through each request in the SubjectRequest table
    DECLARE @StudentID VARCHAR(50), @SubjectID VARCHAR(50);

    DECLARE request_cursor CURSOR FOR
    SELECT StudentID, SubjectID
    FROM SubjectRequest;

    OPEN request_cursor;
    FETCH NEXT FROM request_cursor INTO @StudentID, @SubjectID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the student exists in the SubjectAllotments table
        IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = @StudentID)
        BEGIN
            -- Check if the requested subject is different from the current valid subject
            DECLARE @CurrentSubjectID VARCHAR(50);
            SELECT @CurrentSubjectID = SubjectID
            FROM SubjectAllotments
            WHERE StudentID = @StudentID AND Is_Valid = 1;

            IF @CurrentSubjectID <> @SubjectID
            BEGIN
                -- Mark the current valid subject as invalid
                UPDATE SubjectAllotments
                SET Is_Valid = 0, Timestamp = CURRENT_TIMESTAMP
                WHERE StudentID = @StudentID AND Is_Valid = 1;

                -- Insert the new subject as valid
                INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid, Timestamp)
                VALUES (@StudentID, @SubjectID, 1, CURRENT_TIMESTAMP);
            END
        END
        ELSE
        BEGIN
            -- Insert the new subject as valid since the student does not exist in the SubjectAllotments table
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid, Timestamp)
            VALUES (@StudentID, @SubjectID, 1, CURRENT_TIMESTAMP);
        END

        -- Fetch the next request
        FETCH NEXT FROM request_cursor INTO @StudentID, @SubjectID;
    END

    -- Close and deallocate the cursor
    CLOSE request_cursor;
    DEALLOCATE request_cursor;

    -- Clear the SubjectRequest table after processing
    DELETE FROM SubjectRequest;
END;
