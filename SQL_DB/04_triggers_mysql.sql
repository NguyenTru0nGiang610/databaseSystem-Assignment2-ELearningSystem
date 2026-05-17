USE LMS_BTL2;

DROP TRIGGER IF EXISTS trg_enroll_check_prerequisite_bi;
DROP TRIGGER IF EXISTS trg_enroll_check_prerequisite_bu;

DROP TRIGGER IF EXISTS trg_attempt_validate_bi;
DROP TRIGGER IF EXISTS trg_attempt_validate_bu;

DROP TRIGGER IF EXISTS trg_answer_validate_bi;
DROP TRIGGER IF EXISTS trg_answer_validate_bu;

DROP TRIGGER IF EXISTS trg_answer_update_attempt_total_ai;
DROP TRIGGER IF EXISTS trg_answer_update_attempt_total_au;
DROP TRIGGER IF EXISTS trg_answer_update_attempt_total_ad;

DELIMITER //

-- =========================================================
-- 2.2.1 TRIGGER KIỂM TRA RÀNG BUỘC NGHIỆP VỤ
-- Ràng buộc: Sinh viên chỉ được đăng ký khóa học nếu đã hoàn thành
-- tất cả môn học tiên quyết của môn học thuộc khóa học đó.
--
-- DML có thể gây vi phạm:
-- INSERT vào ENROLL
-- UPDATE Student_ID hoặc Course_ID hoặc Enroll_status trong ENROLL
-- =========================================================

CREATE TRIGGER trg_enroll_check_prerequisite_bi
BEFORE INSERT ON ENROLL
FOR EACH ROW
BEGIN
    DECLARE v_advanced_subject_id INT;
    DECLARE v_missing_subjects VARCHAR(500);
    DECLARE v_error_message VARCHAR(600);

    IF NOT EXISTS (
        SELECT 1
        FROM STUDENT
        WHERE User_ID = NEW.Student_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student_ID không tồn tại trong bảng STUDENT.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM COURSE
        WHERE Course_ID = NEW.Course_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Course_ID không tồn tại trong bảng COURSE.';
    END IF;

    IF NEW.Enroll_status <> 'Dropped' THEN
        SELECT Subject_ID
        INTO v_advanced_subject_id
        FROM COURSE
        WHERE Course_ID = NEW.Course_ID;

        SELECT GROUP_CONCAT(s.Subject_name SEPARATOR ', ')
        INTO v_missing_subjects
        FROM PREREQUISITE p
        JOIN SUBJECT s
            ON s.Subject_ID = p.Prerequisite_subject_ID
        WHERE p.Advanced_subject_ID = v_advanced_subject_id
          AND NOT EXISTS (
              SELECT 1
              FROM ENROLL e
              JOIN COURSE c
                  ON c.Course_ID = e.Course_ID
              WHERE e.Student_ID = NEW.Student_ID
                AND c.Subject_ID = p.Prerequisite_subject_ID
                AND e.Enroll_status = 'Completed'
          );

        IF v_missing_subjects IS NOT NULL THEN
            SET v_error_message = CONCAT(
                'Không thể đăng ký khóa học. Sinh viên chưa hoàn thành môn tiên quyết: ',
                v_missing_subjects
            );

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = v_error_message;
        END IF;
    END IF;
END //


CREATE TRIGGER trg_enroll_check_prerequisite_bu
BEFORE UPDATE ON ENROLL
FOR EACH ROW
BEGIN
    DECLARE v_advanced_subject_id INT;
    DECLARE v_missing_subjects VARCHAR(500);
    DECLARE v_error_message VARCHAR(600);

    IF NOT EXISTS (
        SELECT 1
        FROM STUDENT
        WHERE User_ID = NEW.Student_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student_ID không tồn tại trong bảng STUDENT.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM COURSE
        WHERE Course_ID = NEW.Course_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Course_ID không tồn tại trong bảng COURSE.';
    END IF;

    IF NEW.Enroll_status <> 'Dropped' THEN
        SELECT Subject_ID
        INTO v_advanced_subject_id
        FROM COURSE
        WHERE Course_ID = NEW.Course_ID;

        SELECT GROUP_CONCAT(s.Subject_name SEPARATOR ', ')
        INTO v_missing_subjects
        FROM PREREQUISITE p
        JOIN SUBJECT s
            ON s.Subject_ID = p.Prerequisite_subject_ID
        WHERE p.Advanced_subject_ID = v_advanced_subject_id
          AND NOT EXISTS (
              SELECT 1
              FROM ENROLL e
              JOIN COURSE c
                  ON c.Course_ID = e.Course_ID
              WHERE e.Student_ID = NEW.Student_ID
                AND c.Subject_ID = p.Prerequisite_subject_ID
                AND e.Enroll_status = 'Completed'
          );

        IF v_missing_subjects IS NOT NULL THEN
            SET v_error_message = CONCAT(
                'Không thể cập nhật đăng ký khóa học. Sinh viên chưa hoàn thành môn tiên quyết: ',
                v_missing_subjects
            );

            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = v_error_message;
        END IF;
    END IF;
END //


-- =========================================================
-- TRIGGER BỔ SUNG: KIỂM TRA LƯỢT LÀM BÀI
-- Ràng buộc:
-- 1. Attempt_order không được vượt quá Quiz.Max_attempts.
-- 2. Start_time và Submit_time phải nằm trong Open_time - Close_time.
-- 3. Total_score không được vượt quá Max_score.
--  
-- DML có thể gây vi phạm:
-- INSERT vào ATTEMPT
-- UPDATE ATTEMPT
-- =========================================================

CREATE TRIGGER trg_attempt_validate_bi
BEFORE INSERT ON ATTEMPT
FOR EACH ROW
BEGIN
    DECLARE v_open_time DATETIME;
    DECLARE v_close_time DATETIME;
    DECLARE v_max_attempts INT;
    DECLARE v_max_score DECIMAL(6,2);

    IF NOT EXISTS (
        SELECT 1
        FROM QUIZ
        WHERE Quiz_ID = NEW.Quiz_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quiz_ID không tồn tại trong bảng QUIZ.';
    END IF;

    SELECT Open_time, Close_time, Max_attempts, Max_score
    INTO v_open_time, v_close_time, v_max_attempts, v_max_score
    FROM QUIZ
    WHERE Quiz_ID = NEW.Quiz_ID;

    IF NEW.Attempt_order > v_max_attempts THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Số thứ tự lượt làm bài vượt quá số lần làm bài tối đa của Quiz.';
    END IF;

    IF NEW.Start_time < v_open_time OR NEW.Start_time > v_close_time THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Thời gian bắt đầu làm bài phải nằm trong thời gian mở và đóng của Quiz.';
    END IF;

    IF NEW.Submit_time IS NOT NULL
       AND (NEW.Submit_time < v_open_time OR NEW.Submit_time > v_close_time) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Thời gian nộp bài phải nằm trong thời gian mở và đóng của Quiz.';
    END IF;

    IF NEW.Total_score > v_max_score THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tổng điểm của lượt làm bài không được vượt quá điểm tối đa của Quiz.';
    END IF;
END //


CREATE TRIGGER trg_attempt_validate_bu
BEFORE UPDATE ON ATTEMPT
FOR EACH ROW
BEGIN
    DECLARE v_open_time DATETIME;
    DECLARE v_close_time DATETIME;
    DECLARE v_max_attempts INT;
    DECLARE v_max_score DECIMAL(6,2);

    IF NOT EXISTS (
        SELECT 1
        FROM QUIZ
        WHERE Quiz_ID = NEW.Quiz_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quiz_ID không tồn tại trong bảng QUIZ.';
    END IF;

    SELECT Open_time, Close_time, Max_attempts, Max_score
    INTO v_open_time, v_close_time, v_max_attempts, v_max_score
    FROM QUIZ
    WHERE Quiz_ID = NEW.Quiz_ID;

    IF NEW.Attempt_order > v_max_attempts THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Số thứ tự lượt làm bài vượt quá số lần làm bài tối đa của Quiz.';
    END IF;

    IF NEW.Start_time < v_open_time OR NEW.Start_time > v_close_time THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Thời gian bắt đầu làm bài phải nằm trong thời gian mở và đóng của Quiz.';
    END IF;

    IF NEW.Submit_time IS NOT NULL
       AND (NEW.Submit_time < v_open_time OR NEW.Submit_time > v_close_time) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Thời gian nộp bài phải nằm trong thời gian mở và đóng của Quiz.';
    END IF;

    IF NEW.Total_score > v_max_score THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tổng điểm của lượt làm bài không được vượt quá điểm tối đa của Quiz.';
    END IF;
END //


-- =========================================================
-- TRIGGER KIỂM TRA ĐIỂM CÂU TRẢ LỜI
-- Ràng buộc:
-- ANSWER.Earned_score không được vượt quá điểm của câu hỏi.
--
-- DML có thể gây vi phạm:
-- INSERT vào ANSWER
-- UPDATE Earned_score trong ANSWER
-- =========================================================

CREATE TRIGGER trg_answer_validate_bi
BEFORE INSERT ON ANSWER
FOR EACH ROW
BEGIN
    DECLARE v_question_type VARCHAR(20);
    DECLARE v_question_score DECIMAL(6,2);

    IF NOT EXISTS (
        SELECT 1
        FROM QUESTION
        WHERE Quiz_ID = NEW.Quiz_ID
          AND Question_ID = NEW.Question_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Câu hỏi không tồn tại trong bảng QUESTION.';
    END IF;

    SELECT Question_type
    INTO v_question_type
    FROM QUESTION
    WHERE Quiz_ID = NEW.Quiz_ID
      AND Question_ID = NEW.Question_ID;

    IF v_question_type = 'MCQ' THEN
        SELECT Score
        INTO v_question_score
        FROM MULTIPLE_CHOICE
        WHERE Quiz_ID = NEW.Quiz_ID
          AND Question_ID = NEW.Question_ID;
    ELSE
        SELECT Score
        INTO v_question_score
        FROM FILL_IN_THE_BLANKS
        WHERE Quiz_ID = NEW.Quiz_ID
          AND Question_ID = NEW.Question_ID;
    END IF;

    IF NEW.Earned_score > v_question_score THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Điểm đạt được của câu trả lời không được vượt quá điểm tối đa của câu hỏi.';
    END IF;
END //


CREATE TRIGGER trg_answer_validate_bu
BEFORE UPDATE ON ANSWER
FOR EACH ROW
BEGIN
    DECLARE v_question_type VARCHAR(20);
    DECLARE v_question_score DECIMAL(6,2);

    IF NOT EXISTS (
        SELECT 1
        FROM QUESTION
        WHERE Quiz_ID = NEW.Quiz_ID
          AND Question_ID = NEW.Question_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Câu hỏi không tồn tại trong bảng QUESTION.';
    END IF;

    SELECT Question_type
    INTO v_question_type
    FROM QUESTION
    WHERE Quiz_ID = NEW.Quiz_ID
      AND Question_ID = NEW.Question_ID;

    IF v_question_type = 'MCQ' THEN
        SELECT Score
        INTO v_question_score
        FROM MULTIPLE_CHOICE
        WHERE Quiz_ID = NEW.Quiz_ID
          AND Question_ID = NEW.Question_ID;
    ELSE
        SELECT Score
        INTO v_question_score
        FROM FILL_IN_THE_BLANKS
        WHERE Quiz_ID = NEW.Quiz_ID
          AND Question_ID = NEW.Question_ID;
    END IF;

    IF NEW.Earned_score > v_question_score THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Điểm đạt được của câu trả lời không được vượt quá điểm tối đa của câu hỏi.';
    END IF;
END //


-- =========================================================
-- 2.2.2 TRIGGER TÍNH THUỘC TÍNH DẪN XUẤT
-- Thuộc tính dẫn xuất: ATTEMPT.Total_score
--
-- Công thức:
-- ATTEMPT.Total_score = SUM(ANSWER.Earned_score)
--
-- DML làm thay đổi Total_score:
-- INSERT ANSWER
-- UPDATE ANSWER.Earned_score
-- DELETE ANSWER
-- =========================================================

CREATE TRIGGER trg_answer_update_attempt_total_ai
AFTER INSERT ON ANSWER
FOR EACH ROW
BEGIN
    UPDATE ATTEMPT
    SET Total_score = Total_score + NEW.Earned_score
    WHERE Student_ID = NEW.Student_ID
      AND Quiz_ID = NEW.Quiz_ID
      AND Attempt_order = NEW.Attempt_order;
END //


CREATE TRIGGER trg_answer_update_attempt_total_au
AFTER UPDATE ON ANSWER
FOR EACH ROW
BEGIN
    UPDATE ATTEMPT
    SET Total_score = Total_score - OLD.Earned_score + NEW.Earned_score
    WHERE Student_ID = NEW.Student_ID
      AND Quiz_ID = NEW.Quiz_ID
      AND Attempt_order = NEW.Attempt_order;
END //


CREATE TRIGGER trg_answer_update_attempt_total_ad
AFTER DELETE ON ANSWER
FOR EACH ROW
BEGIN
    UPDATE ATTEMPT
    SET Total_score = GREATEST(Total_score - OLD.Earned_score, 0)
    WHERE Student_ID = OLD.Student_ID
      AND Quiz_ID = OLD.Quiz_ID
      AND Attempt_order = OLD.Attempt_order;
END //

DELIMITER ;


-- =========================================================
-- ĐỒNG BỘ LẠI TOTAL_SCORE CHO DỮ LIỆU ĐÃ INSERT TRƯỚC KHI TẠO TRIGGER
-- Nếu bạn chạy trigger sau file insert mẫu, câu này giúp đảm bảo Total_score đúng.
-- =========================================================

SET SQL_SAFE_UPDATES = 0;

UPDATE ATTEMPT a
LEFT JOIN (
    SELECT
        Student_ID,
        Quiz_ID,
        Attempt_order,
        SUM(Earned_score) AS Sum_score
    FROM ANSWER
    GROUP BY Student_ID, Quiz_ID, Attempt_order
) x
    ON x.Student_ID = a.Student_ID
   AND x.Quiz_ID = a.Quiz_ID
   AND x.Attempt_order = a.Attempt_order
SET a.Total_score = IFNULL(x.Sum_score, 0);

SET SQL_SAFE_UPDATES = 1;