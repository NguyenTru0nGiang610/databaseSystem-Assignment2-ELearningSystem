USE LMS_BTL2;
 
DROP PROCEDURE IF EXISTS sp_search_courses;
DROP PROCEDURE IF EXISTS sp_report_course_learning_result;
 
DELIMITER //
 
-- =========================================================
-- 2.3.1 PROCEDURE 1
-- Mục tiêu:
-- Hiển thị danh sách khóa học theo từ khóa, khoa, giảng viên, số tín chỉ.
--
-- Yêu cầu đề bài thỏa mãn:
-- - Truy vấn từ 2 bảng trở lên
-- - Có WHERE
-- - Có ORDER BY
-- - Tham số đầu vào nằm trong mệnh đề WHERE
-- - Có liên quan bảng COURSE ở câu 2.1
-- =========================================================
 
CREATE PROCEDURE sp_search_courses (
    IN p_keyword VARCHAR(150),
    IN p_dept_id INT,
    IN p_lecturer_id INT,
    IN p_min_credits INT,
    IN p_max_credits INT,
    IN p_sort_option VARCHAR(30)
)
BEGIN
    SELECT
        c.Course_ID,
        c.Course_name,
        c.Description,
        c.Start_date,
        c.End_date,
		c.Lecturer_ID,
        s.Subject_ID,
        s.Subject_name,
        s.Credits,
 
        d.Dept_ID,
        d.Dept_name,
 
        l.User_ID AS Lecturer_ID,
        ua.Full_name AS Lecturer_name,
 
        COUNT(DISTINCT e.Student_ID) AS Number_of_students
    FROM COURSE c
    JOIN SUBJECT s
        ON s.Subject_ID = c.Subject_ID
    JOIN DEPARTMENT d
        ON d.Dept_ID = s.Dept_ID
    JOIN LECTURER l
        ON l.User_ID = c.Lecturer_ID
    JOIN USER_ACCOUNT ua
        ON ua.User_ID = l.User_ID
    LEFT JOIN ENROLL e
        ON e.Course_ID = c.Course_ID
    WHERE
        (
            p_keyword IS NULL
            OR TRIM(p_keyword) = ''
            OR c.Course_name LIKE CONCAT('%', TRIM(p_keyword), '%')
            OR s.Subject_name LIKE CONCAT('%', TRIM(p_keyword), '%')
            OR ua.Full_name LIKE CONCAT('%', TRIM(p_keyword), '%')
        )
        AND
        (
            p_dept_id IS NULL
            OR d.Dept_ID = p_dept_id
        )
        AND
        (
            p_lecturer_id IS NULL
            OR l.User_ID = p_lecturer_id
        )
        AND
        (
            p_min_credits IS NULL
            OR s.Credits >= p_min_credits
        )
        AND
        (
            p_max_credits IS NULL
            OR s.Credits <= p_max_credits
        )
    GROUP BY
        c.Course_ID,
        c.Course_name,
        c.Description,
        c.Start_date,
        c.End_date,
        s.Subject_ID,
        s.Subject_name,
        s.Credits,
        d.Dept_ID,
        d.Dept_name,
        l.User_ID,
        ua.Full_name
    ORDER BY
        CASE
            WHEN p_sort_option = 'COURSE_NAME_ASC' THEN c.Course_name
        END ASC,
 
        CASE
            WHEN p_sort_option = 'COURSE_NAME_DESC' THEN c.Course_name
        END DESC,
 
        CASE
            WHEN p_sort_option = 'START_DATE_ASC' THEN c.Start_date
        END ASC,
 
        CASE
            WHEN p_sort_option = 'START_DATE_DESC' THEN c.Start_date
        END DESC,
 
        CASE
            WHEN p_sort_option = 'STUDENTS_ASC' THEN COUNT(DISTINCT e.Student_ID)
        END ASC,
 
        CASE
            WHEN p_sort_option = 'STUDENTS_DESC' THEN COUNT(DISTINCT e.Student_ID)
        END DESC,
 
        c.Course_ID ASC;
END //
 
 
-- =========================================================
-- 2.3.2 PROCEDURE 2
-- Mục tiêu:
-- Báo cáo kết quả học tập theo từng khóa học.
--
-- Yêu cầu đề bài thỏa mãn:
-- - Có aggregate function: COUNT, AVG, SUM
-- - Có GROUP BY
-- - Có HAVING
-- - Có WHERE
-- - Có ORDER BY
-- - Liên kết từ 2 bảng trở lên
-- - Có liên quan bảng COURSE ở câu 2.1
-- =========================================================
 
CREATE PROCEDURE sp_report_course_learning_result (
    IN p_dept_id INT,
    IN p_from_date DATE,
    IN p_to_date DATE,
    IN p_min_students INT,
    IN p_min_avg_final_score DECIMAL(5,2)
)
BEGIN
    SELECT
        c.Course_ID,
        c.Course_name,
 
        s.Subject_ID,
        s.Subject_name,
        s.Credits,
 
        d.Dept_ID,
        d.Dept_name,
 
        ua.Full_name AS Lecturer_name,
 
        COUNT(DISTINCT e.Student_ID) AS Total_enrolled_students,
 
        COUNT(
            DISTINCT CASE
                WHEN e.Enroll_status = 'Completed' THEN e.Student_ID
            END
        ) AS Total_completed_students,
 
        ROUND(
            COUNT(
                DISTINCT CASE
                    WHEN e.Enroll_status = 'Completed' THEN e.Student_ID
                END
            ) * 100.0 / NULLIF(COUNT(DISTINCT e.Student_ID), 0),
            2
        ) AS Completion_rate_percent,
 
        ROUND(AVG(e.Final_score), 2) AS Avg_final_score,
 
        COUNT(DISTINCT q.Quiz_ID) AS Total_quizzes,
 
        COUNT(DISTINCT CONCAT(a.Student_ID, '-', a.Quiz_ID, '-', a.Attempt_order)) AS Total_attempts,
 
        ROUND(AVG(a.Total_score), 2) AS Avg_quiz_attempt_score
    FROM COURSE c
    JOIN SUBJECT s
        ON s.Subject_ID = c.Subject_ID
    JOIN DEPARTMENT d
        ON d.Dept_ID = s.Dept_ID
    JOIN LECTURER l
        ON l.User_ID = c.Lecturer_ID
    JOIN USER_ACCOUNT ua
        ON ua.User_ID = l.User_ID
    LEFT JOIN ENROLL e
        ON e.Course_ID = c.Course_ID
    LEFT JOIN QUIZ q
        ON q.Course_ID = c.Course_ID
    LEFT JOIN ATTEMPT a
        ON a.Quiz_ID = q.Quiz_ID
    WHERE
        (
            p_dept_id IS NULL
            OR d.Dept_ID = p_dept_id
        )
        AND
        (
            p_from_date IS NULL
            OR c.Start_date >= p_from_date
        )
        AND
        (
            p_to_date IS NULL
            OR c.End_date <= p_to_date
        )
    GROUP BY
        c.Course_ID,
        c.Course_name,
        s.Subject_ID,
        s.Subject_name,
        s.Credits,
        d.Dept_ID,
        d.Dept_name,
        ua.Full_name
    HAVING
        COUNT(DISTINCT e.Student_ID) >= IFNULL(p_min_students, 0)
        AND
        (
            p_min_avg_final_score IS NULL
            OR IFNULL(AVG(e.Final_score), 0) >= p_min_avg_final_score
        )
    ORDER BY
        Completion_rate_percent DESC,
        Avg_final_score DESC,
        Total_enrolled_students DESC,
        c.Course_ID ASC;
END //
 
 
-- Các PROCEDURES khác trong Backend
-- =========================================================
-- 2.3.3 PROCEDURE 3
-- Mục tiêu:
-- Lấy chi tiết thông tin khóa học (Basic Info, Prerequisites, Sections & Lectures, Quizzes)
-- Dùng ở chỗ những khóa học chưa đăng ký, sinh viên có thể coi trước thông tin khóa học sau đó mới đăng ký
-- =========================================================
CREATE PROCEDURE sp_get_course_details (
    IN p_course_id INT
)
BEGIN
    -- 1. Basic Info
    SELECT
        c.Course_ID,
        c.Course_name,
        c.Description,
        c.Start_date,
        c.End_date,
        s.Subject_name,
        s.Credits,
        d.Dept_name,
        ua.Full_name AS Lecturer_name
    FROM COURSE c
    JOIN SUBJECT s ON s.Subject_ID = c.Subject_ID
    JOIN DEPARTMENT d ON d.Dept_ID = s.Dept_ID
    JOIN USER_ACCOUNT ua ON ua.User_ID = c.Lecturer_ID
    WHERE c.Course_ID = p_course_id;
 
    -- 2. Prerequisites
    SELECT s.Subject_name
    FROM PREREQUISITE p
    JOIN SUBJECT s ON s.Subject_ID = p.Prerequisite_subject_ID
    JOIN COURSE c ON c.Subject_ID = p.Advanced_subject_ID
    WHERE c.Course_ID = p_course_id;
 
    -- 3. Sections & Lectures
    SELECT
        sec.Section_order,
        sec.Section_name,
        l.Title AS Lecture_title
    FROM SECTION sec
    LEFT JOIN LECTURE l ON l.Course_ID = sec.Course_ID AND l.Section_order = sec.Section_order
    WHERE sec.Course_ID = p_course_id
    ORDER BY sec.Section_order ASC, l.Lecture_ID ASC;
 
    -- 4. Quizzes
    SELECT Quiz_title, Max_score, Duration
    FROM QUIZ
    WHERE Course_ID = p_course_id
    ORDER BY Quiz_ID ASC;
END //
 
-- =========================================================
-- 2.3.4 PROCEDURE 4
-- Mục tiêu:
-- Lấy dữ liệu cho Student Dashboard (khóa học đã đăng ký & khóa học có thể đăng ký)
-- Sử dụng cho Dashboard của student: lấy thông tin để hiện thị tất cả các khóa học hiện có trên hệ thống.
-- =========================================================
 
CREATE PROCEDURE sp_get_student_dashboard (
    IN p_student_id INT
)
BEGIN
    -- 1. Các khóa học đã đăng ký (kèm tiến độ)
    SELECT
        c.Course_ID,
        c.Course_name,
        c.Description,
        c.Start_date,
        c.End_date,
        s.Subject_name,
        s.Credits,
        d.Dept_name,
        ua.Full_name AS Lecturer_name,
        e.Enroll_status,
        e.Final_score,
        e.Completed_at,
 
        (
          SELECT COUNT(*)
          FROM LECTURE l
          WHERE l.Course_ID = c.Course_ID
        ) AS Total_lectures,
 
        (
          SELECT COUNT(*)
          FROM LECTURE l
          JOIN INTERACT i
            ON i.Lecture_ID = l.Lecture_ID
          WHERE l.Course_ID = c.Course_ID
            AND i.Student_ID = p_student_id
            AND i.Status = 'Completed'
        ) AS Completed_lectures,
 
        (
          SELECT COUNT(*)
          FROM QUIZ q
          WHERE q.Course_ID = c.Course_ID
        ) AS Total_quizzes,
 
        (
          SELECT COUNT(*)
          FROM QUIZ q
          WHERE q.Course_ID = c.Course_ID
            AND EXISTS (
              SELECT 1
              FROM ATTEMPT a
              WHERE a.Student_ID = p_student_id
                AND a.Quiz_ID = q.Quiz_ID
                AND a.Total_score >= q.Pass_score
            )
        ) AS Passed_quizzes
 
    FROM ENROLL e
    JOIN COURSE c
        ON c.Course_ID = e.Course_ID
    JOIN SUBJECT s
        ON s.Subject_ID = c.Subject_ID
    JOIN DEPARTMENT d
        ON d.Dept_ID = s.Dept_ID
    JOIN LECTURER l
        ON l.User_ID = c.Lecturer_ID
    JOIN USER_ACCOUNT ua
        ON ua.User_ID = l.User_ID
    WHERE e.Student_ID = p_student_id
    ORDER BY c.Start_date DESC, c.Course_ID DESC;
 
    -- 2. Các khóa học có thể đăng ký (chưa đăng ký)
    SELECT
        c.Course_ID,
        c.Course_name,
        c.Description,
        c.Start_date,
        c.End_date,
        s.Subject_name,
        s.Credits,
        d.Dept_name,
        ua.Full_name AS Lecturer_name
    FROM COURSE c
    JOIN SUBJECT s
        ON s.Subject_ID = c.Subject_ID
    JOIN DEPARTMENT d
        ON d.Dept_ID = s.Dept_ID
    JOIN LECTURER l
        ON l.User_ID = c.Lecturer_ID
    JOIN USER_ACCOUNT ua
        ON ua.User_ID = l.User_ID
    WHERE NOT EXISTS (
        SELECT 1
        FROM ENROLL e
        WHERE e.Student_ID = p_student_id
          AND e.Course_ID = c.Course_ID
    )
    ORDER BY c.Start_date DESC, c.Course_ID DESC;
END //
 
 
 
-- =========================================================
-- 2.3.5 PROCEDURE 5
-- Mục tiêu:
-- Lấy dữ liệu chi tiết của 1 khóa học cho sinh viên (course info, lectures, materials, quizzes)
-- =========================================================
 
CREATE PROCEDURE sp_get_student_course_progress (
    IN p_student_id INT,
    IN p_course_id INT
)
BEGIN
    -- 1. Course Info & Enroll Status
    SELECT
        c.Course_ID,
        c.Course_name,
        c.Description,
        c.Start_date,
        c.End_date,
        s.Subject_name,
        s.Credits,
        d.Dept_name,
        ua.Full_name AS Lecturer_name,
        e.Enroll_status,
        e.Final_score,
        e.Completed_at
    FROM COURSE c
    JOIN SUBJECT s
        ON s.Subject_ID = c.Subject_ID
    JOIN DEPARTMENT d
        ON d.Dept_ID = s.Dept_ID
    JOIN LECTURER l
        ON l.User_ID = c.Lecturer_ID
    JOIN USER_ACCOUNT ua
        ON ua.User_ID = l.User_ID
    JOIN ENROLL e
        ON e.Course_ID = c.Course_ID
       AND e.Student_ID = p_student_id
    WHERE c.Course_ID = p_course_id;
 
    -- 2. Lectures & Interaction
    SELECT
        l.Lecture_ID,
        l.Title,
        l.Created_at,
        sec.Section_order,
        sec.Section_name,
        COALESCE(i.Status, 'Not Started') AS Interaction_status,
        i.Interacted_at
    FROM LECTURE l
    JOIN SECTION sec
        ON sec.Course_ID = l.Course_ID
       AND sec.Section_order = l.Section_order
    LEFT JOIN INTERACT i
        ON i.Lecture_ID = l.Lecture_ID
       AND i.Student_ID = p_student_id
    WHERE l.Course_ID = p_course_id
    ORDER BY sec.Section_order ASC, l.Lecture_ID ASC;
 
    -- 3. Materials
    SELECT ml.Lecture_ID, ml.Link
    FROM MATERIAL_LINKS ml
    JOIN LECTURE l
        ON l.Lecture_ID = ml.Lecture_ID
    WHERE l.Course_ID = p_course_id
    ORDER BY ml.Lecture_ID ASC;
 
    -- 4. Quizzes & Progress
    SELECT
        q.Quiz_ID,
        q.Quiz_title,
        q.Open_time,
        q.Close_time,
        q.Duration,
        q.Max_attempts,
        q.Max_score,
        q.Pass_score,
 
        COUNT(a.Attempt_order) AS Attempt_count,
        MAX(a.Total_score) AS Best_score,
 
        CASE
          WHEN MAX(a.Total_score) >= q.Pass_score THEN 'Passed'
          WHEN COUNT(a.Attempt_order) > 0 THEN 'Attempted'
          ELSE 'Not Attempted'
        END AS Quiz_status
 
    FROM QUIZ q
    LEFT JOIN ATTEMPT a
        ON a.Quiz_ID = q.Quiz_ID
       AND a.Student_ID = p_student_id
    WHERE q.Course_ID = p_course_id
    GROUP BY
        q.Quiz_ID,
        q.Quiz_title,
        q.Open_time,
        q.Close_time,
        q.Duration,
        q.Max_attempts,
        q.Max_score,
        q.Pass_score
    ORDER BY q.Quiz_ID ASC;
 
    -- 5. Questions for all Quizzes in Course
    SELECT
      q.Quiz_ID,
      q.Question_ID,
      q.Content,
      q.Question_type,
      mc.Score AS MCQ_score,
      mc.MC_correct_answer,
      fb.Score AS FITB_score,
      CASE
        WHEN q.Question_type = 'MCQ' THEN mc.Score
        ELSE fb.Score
      END AS Question_score,
      (
        SELECT COUNT(*)
        FROM MC_OPTIONS mo
        WHERE mo.Quiz_ID = q.Quiz_ID
          AND mo.Question_ID = q.Question_ID
      ) AS Option_count,
      (
        SELECT GROUP_CONCAT(mo.Option_text ORDER BY mo.Option_text SEPARATOR ' | ')
        FROM MC_OPTIONS mo
        WHERE mo.Quiz_ID = q.Quiz_ID
          AND mo.Question_ID = q.Question_ID
      ) AS MCQ_options,
      (
        SELECT GROUP_CONCAT(fa.Answer_text ORDER BY fa.Answer_text SEPARATOR ' | ')
        FROM FITB_ANSWERS fa
        WHERE fa.Quiz_ID = q.Quiz_ID
          AND fa.Question_ID = q.Question_ID
      ) AS FITB_correct_answers
    FROM QUESTION q
    LEFT JOIN MULTIPLE_CHOICE mc
      ON mc.Quiz_ID = q.Quiz_ID
     AND mc.Question_ID = q.Question_ID
    LEFT JOIN FILL_IN_THE_BLANKS fb
      ON fb.Quiz_ID = q.Quiz_ID
     AND fb.Question_ID = q.Question_ID
    JOIN QUIZ quiz
      ON quiz.Quiz_ID = q.Quiz_ID
    WHERE quiz.Course_ID = p_course_id
    ORDER BY q.Quiz_ID ASC, q.Question_ID ASC;
END //
 
-- =========================================================
-- 2.3.6 PROCEDURE 6
-- Mục tiêu:
-- Lấy dữ liệu để sinh viên bắt đầu làm bài Quiz
-- =========================================================
-- Chưa được sử dụng
CREATE PROCEDURE sp_get_quiz_to_take (
    IN p_student_id INT,
    IN p_quiz_id INT
)
BEGIN
    -- 1. Quiz Info & Auth Check
    SELECT
        q.*,
        c.Course_ID,
        c.Course_name
    FROM QUIZ q
    JOIN COURSE c
        ON c.Course_ID = q.Course_ID
    JOIN ENROLL e
        ON e.Course_ID = c.Course_ID
       AND e.Student_ID = p_student_id
    WHERE q.Quiz_ID = p_quiz_id;
 
    -- 2. Attempt Count
    SELECT COUNT(*) AS attempt_count
    FROM ATTEMPT
    WHERE Student_ID = p_student_id
      AND Quiz_ID = p_quiz_id;
 
    -- 3. Questions
    SELECT
        q.Quiz_ID,
        q.Question_ID,
        q.Content,
        q.Question_type,
        mc.Score AS MCQ_score,
        fb.Score AS FITB_score
    FROM QUESTION q
    LEFT JOIN MULTIPLE_CHOICE mc
        ON mc.Quiz_ID = q.Quiz_ID
       AND mc.Question_ID = q.Question_ID
    LEFT JOIN FILL_IN_THE_BLANKS fb
        ON fb.Quiz_ID = q.Quiz_ID
       AND fb.Question_ID = q.Question_ID
    WHERE q.Quiz_ID = p_quiz_id
    ORDER BY q.Question_ID ASC;
 
    -- 4. Options
    SELECT Quiz_ID, Question_ID, Option_text
    FROM MC_OPTIONS
    WHERE Quiz_ID = p_quiz_id
    ORDER BY Question_ID ASC, Option_text ASC;
END //




DROP PROCEDURE IF EXISTS sp_get_student_quiz_results;

DELIMITER //

CREATE PROCEDURE sp_get_student_quiz_results (
    IN p_Student_ID    INT,
    IN p_Quiz_ID       INT,
    IN p_Attempt_order INT   -- NULL nếu chưa có attempt nào
)
BEGIN
    -- ── 1. Quiz info + kiểm tra quyền truy cập ───────────────
    IF NOT EXISTS (
        SELECT 1
        FROM QUIZ q
        JOIN COURSE c  ON c.Course_ID  = q.Course_ID
        JOIN ENROLL e  ON e.Course_ID  = c.Course_ID
                      AND e.Student_ID = p_Student_ID
        WHERE q.Quiz_ID = p_Quiz_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bạn chưa đăng ký khóa học chứa bài kiểm tra này.';
    END IF;

    SELECT
        q.*,
        c.Course_ID,
        c.Course_name
    FROM QUIZ q
    JOIN COURSE c ON c.Course_ID = q.Course_ID
    JOIN ENROLL e ON e.Course_ID  = c.Course_ID
                 AND e.Student_ID = p_Student_ID
    WHERE q.Quiz_ID = p_Quiz_ID;

    -- ── 2. Danh sách attempts ────────────────────────────────
    SELECT
        Student_ID,
        Quiz_ID,
        Attempt_order,
        Start_time,
        Submit_time,
        Total_score,
        CASE
            WHEN Total_score >= (
                SELECT Pass_score FROM QUIZ WHERE Quiz_ID = p_Quiz_ID
            ) THEN 'Passed'
            ELSE 'Failed'
        END AS Result_status
    FROM ATTEMPT
    WHERE Student_ID = p_Student_ID
      AND Quiz_ID    = p_Quiz_ID
    ORDER BY Attempt_order DESC;

    -- ── 3-6. Chi tiết attempt (chỉ chạy nếu có attempt) ─────
    IF p_Attempt_order IS NOT NULL THEN

        -- 3. Questions + answers
        SELECT
            q.Question_ID,
            q.Content,
            q.Question_type,
            ans.Student_answer,
            ans.Earned_score,
            mc.MC_correct_answer,
            mc.Score AS MCQ_score,
            fb.Score AS FITB_score
        FROM QUESTION q
        LEFT JOIN ANSWER ans
            ON ans.Quiz_ID       = q.Quiz_ID
           AND ans.Question_ID   = q.Question_ID
           AND ans.Student_ID    = p_Student_ID
           AND ans.Attempt_order = p_Attempt_order
        LEFT JOIN MULTIPLE_CHOICE mc
            ON mc.Quiz_ID      = q.Quiz_ID
           AND mc.Question_ID  = q.Question_ID
        LEFT JOIN FILL_IN_THE_BLANKS fb
            ON fb.Quiz_ID     = q.Quiz_ID
           AND fb.Question_ID = q.Question_ID
        WHERE q.Quiz_ID = p_Quiz_ID
        ORDER BY q.Question_ID ASC;

        -- 4. MC options
        SELECT Quiz_ID, Question_ID, Option_text
        FROM MC_OPTIONS
        WHERE Quiz_ID = p_Quiz_ID
        ORDER BY Question_ID ASC, Option_text ASC;

        -- 5. FITB answers
        SELECT Quiz_ID, Question_ID, Answer_text
        FROM FITB_ANSWERS
        WHERE Quiz_ID = p_Quiz_ID
        ORDER BY Question_ID ASC, Answer_text ASC;

    END IF;
END //

DELIMITER ;
 

DROP PROCEDURE IF EXISTS sp_get_lecturer_dashboard;

DELIMITER //

CREATE PROCEDURE sp_get_lecturer_dashboard (
    IN p_Lecturer_ID INT
)
BEGIN
    -- Validate lecturer tồn tại
    IF NOT EXISTS (
        SELECT 1 FROM LECTURER WHERE User_ID = p_Lecturer_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không tìm thấy giảng viên.';
    END IF;

    -- ── 1. Danh sách courses ──────────────────────────────────
    SELECT
        c.Course_ID,
        c.Course_name,
        c.Description,
        c.Start_date,
        c.End_date,
        c.Subject_ID,
        c.Lecturer_ID,
        s.Subject_name,
        s.Credits,
        d.Dept_name,
        (
            SELECT COUNT(DISTINCT e.Student_ID)
            FROM ENROLL e
            WHERE e.Course_ID = c.Course_ID
        ) AS Total_students,
        (
            SELECT COUNT(DISTINCT l.Lecture_ID)
            FROM LECTURE l
            WHERE l.Course_ID = c.Course_ID
        ) AS Total_lectures,
        (
            SELECT COUNT(DISTINCT q.Quiz_ID)
            FROM QUIZ q
            WHERE q.Course_ID = c.Course_ID
        ) AS Total_quizzes
    FROM COURSE c
    JOIN SUBJECT s    ON s.Subject_ID = c.Subject_ID
    JOIN DEPARTMENT d ON d.Dept_ID    = s.Dept_ID
    WHERE c.Lecturer_ID = p_Lecturer_ID
    ORDER BY c.Start_date DESC, c.Course_ID DESC;

    -- ── 2. Dashboard summary (1 row) ─────────────────────────
    SELECT
        COUNT(DISTINCT c.Course_ID)  AS Total_courses,
        COUNT(DISTINCT e.Student_ID) AS Total_students,
        COUNT(DISTINCT l.Lecture_ID) AS Total_lectures,
        COUNT(DISTINCT q.Quiz_ID)    AS Total_quizzes
    FROM COURSE c
    LEFT JOIN ENROLL  e ON e.Course_ID = c.Course_ID 
    LEFT JOIN LECTURE l ON l.Course_ID = c.Course_ID
    LEFT JOIN QUIZ    q ON q.Course_ID = c.Course_ID
    WHERE c.Lecturer_ID = p_Lecturer_ID;
END //

DELIMITER ;



-- =========================================================
-- sp_get_lecturer_course_detail
-- Trả về 6 result sets theo thứ tự:
--   1. sections
--   2. lectures
--   3. materials
--   4. quizzes
--   5. questions
--   6. students
-- =========================================================

DROP PROCEDURE IF EXISTS sp_get_lecturer_course_detail;

DELIMITER //

CREATE PROCEDURE sp_get_lecturer_course_detail (
    IN p_Lecturer_ID INT,
    IN p_Course_ID   INT
)
BEGIN
    -- Validate: lecturer có sở hữu course này không
    IF NOT EXISTS (
        SELECT 1
        FROM COURSE
        WHERE Course_ID  = p_Course_ID
          AND Lecturer_ID = p_Lecturer_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bạn không có quyền xem hoặc quản lý khóa học này.';
    END IF;

    -- ── 1. Sections ──────────────────────────────────────────
    SELECT
        sec.Course_ID,
        sec.Section_order,
        sec.Section_name,
        sec.Num_of_lectures,
        COUNT(l.Lecture_ID) AS Actual_lecture_count
    FROM SECTION sec
    LEFT JOIN LECTURE l
        ON l.Course_ID      = sec.Course_ID
       AND l.Section_order  = sec.Section_order
    WHERE sec.Course_ID = p_Course_ID
    GROUP BY
        sec.Course_ID,
        sec.Section_order,
        sec.Section_name,
        sec.Num_of_lectures
    ORDER BY sec.Section_order ASC;

    -- ── 2. Lectures ──────────────────────────────────────────
    SELECT
        l.Lecture_ID,
        l.Title,
        l.Created_at,
        l.Section_order,
        sec.Section_name,
        COUNT(ml.Link) AS Material_count
    FROM LECTURE l
    JOIN SECTION sec
        ON sec.Course_ID     = l.Course_ID
       AND sec.Section_order = l.Section_order
    LEFT JOIN MATERIAL_LINKS ml
        ON ml.Lecture_ID = l.Lecture_ID
    WHERE l.Course_ID = p_Course_ID
    GROUP BY
        l.Lecture_ID,
        l.Title,
        l.Created_at,
        l.Section_order,
        sec.Section_name
    ORDER BY l.Section_order ASC, l.Lecture_ID ASC;

    -- ── 3. Materials ─────────────────────────────────────────
    SELECT
        ml.Lecture_ID,
        ml.Link
    FROM MATERIAL_LINKS ml
    JOIN LECTURE l ON l.Lecture_ID = ml.Lecture_ID
    WHERE l.Course_ID = p_Course_ID
    ORDER BY ml.Lecture_ID ASC, ml.Link ASC;

    -- ── 4. Quizzes ───────────────────────────────────────────
    SELECT
        q.Quiz_ID,
        q.Quiz_title,
        q.Open_time,
        q.Close_time,
        q.Duration,
        q.Max_attempts,
        q.Max_score,
        q.Pass_score,
        COUNT(DISTINCT ques.Question_ID)                          AS Total_questions,
        COUNT(DISTINCT CONCAT(a.Student_ID, '-', a.Attempt_order)) AS Total_attempts
    FROM QUIZ q
    LEFT JOIN QUESTION ques ON ques.Quiz_ID = q.Quiz_ID
    LEFT JOIN ATTEMPT  a    ON a.Quiz_ID    = q.Quiz_ID
    WHERE q.Course_ID = p_Course_ID
    GROUP BY
        q.Quiz_ID, q.Quiz_title,
        q.Open_time, q.Close_time,
        q.Duration, q.Max_attempts,
        q.Max_score, q.Pass_score
    ORDER BY q.Quiz_ID ASC;

    -- ── 5. Questions ─────────────────────────────────────────
    SELECT
        q.Quiz_ID,
        q.Question_ID,
        q.Content,
        q.Question_type,
        mc.Score                 AS MCQ_score,
        mc.MC_correct_answer,
        fb.Score                 AS FITB_score,
        CASE
            WHEN q.Question_type = 'MCQ' THEN mc.Score
            ELSE fb.Score
        END                      AS Question_score,
        (
            SELECT COUNT(*)
            FROM MC_OPTIONS mo
            WHERE mo.Quiz_ID     = q.Quiz_ID
              AND mo.Question_ID = q.Question_ID
        )                        AS Option_count,
        (
            SELECT GROUP_CONCAT(mo.Option_text ORDER BY mo.Option_text SEPARATOR ' | ')
            FROM MC_OPTIONS mo
            WHERE mo.Quiz_ID     = q.Quiz_ID
              AND mo.Question_ID = q.Question_ID
        )                        AS MCQ_options,
        (
            SELECT GROUP_CONCAT(fa.Answer_text ORDER BY fa.Answer_text SEPARATOR ' | ')
            FROM FITB_ANSWERS fa
            WHERE fa.Quiz_ID     = q.Quiz_ID
              AND fa.Question_ID = q.Question_ID
        )                        AS FITB_correct_answers
    FROM QUESTION q
    LEFT JOIN MULTIPLE_CHOICE mc
        ON mc.Quiz_ID     = q.Quiz_ID
       AND mc.Question_ID = q.Question_ID
    LEFT JOIN FILL_IN_THE_BLANKS fb
        ON fb.Quiz_ID     = q.Quiz_ID
       AND fb.Question_ID = q.Question_ID
    JOIN QUIZ quiz ON quiz.Quiz_ID = q.Quiz_ID
    WHERE quiz.Course_ID = p_Course_ID
    ORDER BY q.Quiz_ID ASC, q.Question_ID ASC;

    -- ── 6. Students ──────────────────────────────────────────
    SELECT
        ua.User_ID        AS Student_ID,
        ua.Full_name,
        ua.Email,
        e.Enroll_status,
        e.Final_score,
        e.Completed_at,
        (
            SELECT COUNT(*)
            FROM QUIZ q
            WHERE q.Course_ID = e.Course_ID
        )                 AS Total_quizzes,
        (
            SELECT COUNT(DISTINCT q.Quiz_ID)
            FROM QUIZ q
            JOIN ATTEMPT a
                ON a.Quiz_ID    = q.Quiz_ID
               AND a.Student_ID = e.Student_ID
            WHERE q.Course_ID = e.Course_ID
        )                 AS Attempted_quizzes,
        (
            SELECT COUNT(DISTINCT q.Quiz_ID)
            FROM QUIZ q
            JOIN ATTEMPT a
                ON a.Quiz_ID    = q.Quiz_ID
               AND a.Student_ID = e.Student_ID
               AND a.Total_score >= q.Pass_score
            WHERE q.Course_ID = e.Course_ID
        )                 AS Passed_quizzes,
        (
            SELECT ROUND(AVG(best_score), 2)
            FROM (
                SELECT MAX(a2.Total_score) AS best_score
                FROM QUIZ q2
                JOIN ATTEMPT a2
                    ON a2.Quiz_ID    = q2.Quiz_ID
                   AND a2.Student_ID = e.Student_ID
                WHERE q2.Course_ID = e.Course_ID
                GROUP BY q2.Quiz_ID
            ) x
        )                 AS Avg_best_quiz_score,
        CASE
            WHEN (SELECT COUNT(*) FROM QUIZ q WHERE q.Course_ID = e.Course_ID) = 0
                THEN 'NO_QUIZ'
            WHEN (
                SELECT COUNT(*)
                FROM ATTEMPT a
                JOIN QUIZ q ON q.Quiz_ID = a.Quiz_ID
                WHERE q.Course_ID   = e.Course_ID
                  AND a.Student_ID  = e.Student_ID
            ) = 0
                THEN 'NOT_ATTEMPTED'
            WHEN (
                SELECT COUNT(DISTINCT q.Quiz_ID)
                FROM QUIZ q
                JOIN ATTEMPT a
                    ON a.Quiz_ID    = q.Quiz_ID
                   AND a.Student_ID = e.Student_ID
                   AND a.Total_score >= q.Pass_score
                WHERE q.Course_ID = e.Course_ID
            ) = (SELECT COUNT(*) FROM QUIZ q WHERE q.Course_ID = e.Course_ID)
                THEN 'PASSED'
            ELSE 'FAILED'
        END               AS Quiz_learning_status
    FROM ENROLL e
    JOIN USER_ACCOUNT ua ON ua.User_ID = e.Student_ID
    WHERE e.Course_ID = p_Course_ID
    ORDER BY ua.Full_name ASC;
END //

DELIMITER ;