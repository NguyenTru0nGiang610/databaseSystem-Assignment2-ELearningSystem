USE LMS_BTL2;

DROP FUNCTION IF EXISTS fn_calculate_student;
DROP FUNCTION IF EXISTS fn_calculate_course_completion_rate;

DELIMITER //

-- =========================================================
-- 2.4.1 FUNCTION 1
-- Tên hàm: fn_calculate_student

-- Mục tiêu:
-- Tính GPA trung bình có trọng số theo tín chỉ của một sinh viên
-- dựa trên các khóa học đã hoàn thành.
--
-- Công thức:
-- GPA = SUM(Final_score * Credits) / SUM(Credits)
--
-- Yêu cầu đã thỏa:
-- - Có tham số đầu vào: p_student_id
-- - Có kiểm tra tham số đầu vào
-- - Có IF
-- - Có LOOP
-- - Có CURSOR
-- - Có SELECT truy vấn dữ liệu để tính toán
-- =========================================================

CREATE FUNCTION fn_calculate_student (
    p_student_id INT
)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_credit INT DEFAULT 0;
    DECLARE v_score DECIMAL(5,2) DEFAULT 0;

    DECLARE v_total_credits INT DEFAULT 0;
    DECLARE v_total_weighted_score DECIMAL(10,2) DEFAULT 0;
    DECLARE v_result DECIMAL(5,2) DEFAULT 0;

    DECLARE cur_completed_courses CURSOR FOR
        SELECT
            s.Credits,
            e.Final_score
        FROM ENROLL e
        JOIN COURSE c
            ON c.Course_ID = e.Course_ID
        JOIN SUBJECT s
            ON s.Subject_ID = c.Subject_ID
        WHERE e.Student_ID = p_student_id
          AND e.Enroll_status = 'Completed'
          AND e.Final_score IS NOT NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    -- Validate tham số đầu vào
    IF p_student_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student_ID không được để trống.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM STUDENT
        WHERE User_ID = p_student_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student_ID không tồn tại trong bảng STUDENT.';
    END IF;

    -- Duyệt các khóa học đã hoàn thành bằng cursor
    OPEN cur_completed_courses;

    read_loop: LOOP
        FETCH cur_completed_courses INTO v_credit, v_score;

        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET v_total_credits = v_total_credits + v_credit;
        SET v_total_weighted_score = v_total_weighted_score + (v_credit * v_score);
    END LOOP;

    CLOSE cur_completed_courses;

    -- Nếu sinh viên chưa hoàn thành khóa học nào thì trả về 0
    IF v_total_credits = 0 THEN
        SET v_result = 0;
    ELSE
        SET v_result = ROUND(v_total_weighted_score / v_total_credits, 2);
    END IF;

    RETURN v_result;
END //


-- =========================================================
-- 2.4.2 FUNCTION 2
-- Tên hàm: fn_calculate_course_completion_rate
--
-- Mục tiêu:
-- Tính tỷ lệ hoàn thành của một khóa học.
--
-- Công thức:
-- CompletionRate = số sinh viên Completed / tổng số sinh viên đăng ký * 100
--
-- Yêu cầu đã thỏa:
-- - Có tham số đầu vào: p_course_id
-- - Có kiểm tra tham số đầu vào
-- - Có IF
-- - Có LOOP
-- - Có CURSOR
-- - Có SELECT truy vấn dữ liệu để tính toán
-- =========================================================

CREATE FUNCTION fn_calculate_course_completion_rate (
    p_course_id INT
)
RETURNS DECIMAL(5,2)
READS SQL DATA
BEGIN
    DECLARE v_done INT DEFAULT 0;
    DECLARE v_status VARCHAR(20);

    DECLARE v_total_students INT DEFAULT 0;
    DECLARE v_completed_students INT DEFAULT 0;
    DECLARE v_result DECIMAL(5,2) DEFAULT 0;

    DECLARE cur_enrollments CURSOR FOR
        SELECT Enroll_status
        FROM ENROLL
        WHERE Course_ID = p_course_id;

    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    -- Validate tham số đầu vào
    IF p_course_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Course_ID không được để trống.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM COURSE
        WHERE Course_ID = p_course_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Course_ID không tồn tại trong bảng COURSE.';
    END IF;

    -- Duyệt danh sách đăng ký của khóa học bằng cursor
    OPEN cur_enrollments;

    read_loop: LOOP
        FETCH cur_enrollments INTO v_status;

        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        SET v_total_students = v_total_students + 1;

        IF v_status = 'Completed' THEN
            SET v_completed_students = v_completed_students + 1;
        END IF;
    END LOOP;

    CLOSE cur_enrollments;

    -- Nếu chưa có sinh viên đăng ký thì tỷ lệ hoàn thành = 0
    IF v_total_students = 0 THEN
        SET v_result = 0;
    ELSE
        SET v_result = ROUND(v_completed_students * 100.0 / v_total_students, 2);
    END IF;

    RETURN v_result;
END //

DELIMITER ;