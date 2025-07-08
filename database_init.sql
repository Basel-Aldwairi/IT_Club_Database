CREATE DATABASE it_club;
USE it_club;

CREATE TABLE mentors(
mentor_id BIGINT NOT NULL,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(50) NOT NULL,
phone VARCHAR(50) NOT NULL,
is_student BOOL NOT NULL,
student_id_if_student BIGINT NULL,
git_hub VARCHAR(255) NULL,
linkedin VARCHAR(255) NULL,
portfolio VARCHAR(255) NULL,
remarks VARCHAR(2550) NULL,
CONSTRAINT mentors_pk PRIMARY KEY(mentor_id)
);

CREATE TABLE students(
student_id BIGINT NOT NULL,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(50) NOT NULL,
phone VARCHAR(20) NOT NULL,
study_year INT NOT NULL, 
major VARCHAR(50) NOT NULL,
major_track CHAR(50) NULL,
hours_passed INT NOT NULL,
git_hub VARCHAR(255) NULL,
linkedin VARCHAR(255) NULL,
mentor_id BIGINT NULL,
student_resume VARCHAR(255) NULL,
remarks VARCHAR(1023) NULL, 
CONSTRAINT students_pk PRIMARY KEY(student_id),
CONSTRAINT students_mentors_fk FOREIGN KEY(mentor_id)
REFERENCES mentors(mentor_id)
ON UPDATE CASCADE
ON DELETE NO ACTION,
#CONSTRAINT students_check_major CHECK(major IN ('CS','CE','EE')),
CONSTRAINT students_check_year CHECK(study_year >= 1));

ALTER TABLE MENTORS
ADD CONSTRAINT mentors_students_if_student_fk FOREIGN KEY(student_id_if_student)
REFERENCES students(student_id)
ON UPDATE CASCADE
ON DELETE NO ACTION;


CREATE TABLE club_teams(
team_id INT NOT NULL,
team_name VARCHAR(255) NOT NULL,
team_leader BIGINT NOT NULL,
remarks VARCHAR(1023) NULL,
CONSTRAINT club_teams_pk PRIMARY KEY(team_id),
CONSTRAINT club_teams_unique_team_name UNIQUE(team_name),
CONSTRAINT club_teams_team_leader_students FOREIGN KEY(team_leader)
REFERENCES students(student_id)
ON UPDATE CASCADE
ON DELETE NO ACTION
);

CREATE TABLE club_events(
event_id INT NOT NULL,
event_name VARCHAR(255) NOT NULL,
event_leader BIGINT NOT NULL,
event_team INT NOT NULL,
event_type VARCHAR(50) NOT NULL,
num_of_max_students INT NULL,
num_of_attended_students INT NULL,
remarks VARCHAR(1023) NULL,
CONSTRAINT club_events_pk PRIMARY KEY(event_id),
CONSTRAINT club_events_unique_name UNIQUE(event_name),
CONSTRAINT club_events_leader_students_fk FOREIGN KEY(event_leader)
REFERENCES students(student_id)
ON UPDATE CASCADE
ON DELETE NO ACTION,
CONSTRAINT club_events_event_team_fk FOREIGN KEY(event_team)
REFERENCES club_teams(team_id)
ON UPDATE CASCADE
ON DELETE NO ACTION
);


CREATE TABLE students_teams_intersection(
student_id BIGINT NOT NULL,
team_id INT NOT NULL,
date_joined DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
student_title VARCHAR(50) NULL DEFAULT 'Member',
CONSTRAINT students_teams_intersection_pk PRIMARY KEY(student_id,team_id),
CONSTRAINT students_teams_intersection_students_fk FOREIGN KEY(student_id)
REFERENCES students(student_id)
ON UPDATE CASCADE
ON DELETE NO ACTION,
CONSTRAINT students_teams_intersection_teams_fk FOREIGN KEY(team_id)
REFERENCES club_teams(team_id)
ON UPDATE CASCADE
ON DELETE NO ACTION
);

CREATE TABLE students_events_intersection(
student_id BIGINT NOT NULL,
event_id INT NOT NULL,
date_attended DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
CONSTRAINT students_events_intersection_pk PRIMARY KEY(student_id,event_id),
CONSTRAINT students_events_intersection_students_fk FOREIGN KEY(student_id)
REFERENCES students(student_id)
ON UPDATE CASCADE
ON DELETE NO ACTION,
CONSTRAINT students_events_intersection_events_fk FOREIGN KEY(event_id)
REFERENCES club_events(event_id)
ON UPDATE CASCADE
ON DELETE NO ACTION
);

CREATE TABLE student_certificates(
student_id BIGINT NOT NULL,
certificate VARCHAR(255) NOT NULL,
date_aquired DATE NULL,
remarks VARCHAR(1023) NULL,
CONSTRAINT student_certificates_pk PRIMARY KEY(student_id,certificate),
CONSTRAINT student_certificates_students_fk FOREIGN KEY(student_id)
REFERENCES students(student_id)
ON UPDATE CASCADE
ON DELETE NO ACTION
);

CREATE VIEW v_club_students AS
SELECT T.team_name AS Team, concat(S.first_name, S.last_name) AS Member, ST.student_title AS Title
FROM students S JOIN students_teams_intersection ST
ON S.student_id = ST.student_id
JOIN club_teams T
ON T.team_id = ST.team_id
ORDER BY T.team_id;

CREATE VIEW v_team_events AS
SELECT T.team_name AS Team, E.event_name AS 'Event'
FROM club_teams T JOIN club_events E
ON T.team_id = E.event_team
ORDER BY T.team_id;

DELIMITER //
CREATE PROCEDURE insert_student_from_sheets(
	IN p_student_id BIGINT,
	IN p_first_name VARCHAR(50),
	IN last_name VARCHAR(50),
	IN p_email VARCHAR(50),
    IN p_phone VARCHAR(20),
	IN p_study_year INT, 
	IN p_major VARCHAR(50),
	IN p_major_track CHAR(50),
	IN p_hours_passed INT,
	IN p_git_hub VARCHAR(255),
	IN p_linkedin VARCHAR(255),
	IN p_student_resume VARCHAR(255),
    IN p_remarks VARCHAR(1023)
)
BEGIN
	DECLARE student_exists INT DEFAULT 0;
    
    SELECT count(*) INTO student_exists
    FROM students
    WHERE student_id = p_student_id;
    
	IF	student_exists = 0 THEN
		INSERT INTO students(student_id, first_name, last_name, email, phone, study_year, major, major_track, hours_passed, git_hub, linkedin, student_resume, remarks)
        VALUES(p_student_id, p_first_name, last_name, p_email, p_phone, p_study_year, p_major, p_major_track, p_hours_passed, p_git_hub, p_linkedin, p_student_resume, p_remarks);
	ELSE 
		SELECT "USER ALREADY IN DATABASE" AS MESSAGE;
    END IF;
END//
DELIMITER ;

