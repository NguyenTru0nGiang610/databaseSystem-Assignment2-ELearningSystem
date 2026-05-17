USE LMS_BTL2;

DROP PROCEDURE IF EXISTS sp_insert_course;
DROP PROCEDURE IF EXISTS sp_update_course;
DROP PROCEDURE IF EXISTS sp_delete_course;

DELIMITER //

-- =======================================
-- 2.1.1 PROCEDURE: THÊM COURSE
-- =======================================

CREATE PROCEDURE sp_insert_course (
    IN p_Course_name VARCHAR(150),
    IN p_Description VARCHAR(1000),
    IN p_Start_date DATE,
    IN p_End_date DATE,
    IN p_Subject_ID INT,
    IN p_Lecturer_ID INT
)
BEGIN
    DECLARE v_new_course_id INT;

    -- Validate tên khóa học
    IF p_Course_name IS NULL OR TRIM(p_Course_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tên khóa học không được để trống.';
    END IF;

    -- Validate ngày bắt đầu
    IF p_Start_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ngày bắt đầu khóa học không được để trống.';
    END IF;

    -- Validate ngày kết thúc
    IF p_End_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ngày kết thúc khóa học không được để trống.';
    END IF;

    -- Validate logic thời gian
    IF p_End_date < p_Start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ngày kết thúc khóa học phải lớn hơn hoặc bằng ngày bắt đầu.';
    END IF;

    -- Validate môn học tồn tại
    IF NOT EXISTS (
        SELECT 1
        FROM SUBJECT
        WHERE Subject_ID = p_Subject_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Subject_ID không tồn tại trong bảng SUBJECT.';
    END IF;

    -- Validate giảng viên tồn tại
    IF NOT EXISTS (
        SELECT 1
        FROM LECTURER
        WHERE User_ID = p_Lecturer_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lecturer_ID không tồn tại hoặc không phải là giảng viên.';
    END IF;

    -- Validate trùng khóa học
    IF EXISTS (
        SELECT 1
        FROM COURSE
        WHERE Subject_ID = p_Subject_ID
          AND Lecturer_ID = p_Lecturer_ID
          AND Course_name = TRIM(p_Course_name)
          AND Start_date = p_Start_date
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Khóa học đã tồn tại với cùng môn học, giảng viên, tên khóa học và ngày bắt đầu.';
    END IF;

    INSERT INTO COURSE (
        Course_name,
        Description,
        Start_date,
        End_date,
        Subject_ID,
        Lecturer_ID
    )
    VALUES (
        TRIM(p_Course_name),
        p_Description,
        p_Start_date,
        p_End_date,
        p_Subject_ID,
        p_Lecturer_ID
    );

    SET v_new_course_id = LAST_INSERT_ID();

    SELECT
        v_new_course_id AS New_Course_ID,
        'Thêm khóa học thành công.' AS Message;
END //




-- =========================================================
-- 2.1.2 PROCEDURE: SỬA COURSE
-- =========================================================

CREATE PROCEDURE sp_update_course (
    IN p_Course_ID INT,
    IN p_Course_name VARCHAR(150),
    IN p_Description VARCHAR(1000),
    IN p_Start_date DATE,
    IN p_End_date DATE,
    IN p_Subject_ID INT,
    IN p_Lecturer_ID INT
)
BEGIN
    DECLARE v_old_subject_id INT;
    DECLARE v_old_lecturer_id INT;

    -- Validate Course_ID
    IF p_Course_ID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Course_ID không được để trống.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM COURSE
        WHERE Course_ID = p_Course_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không tìm thấy khóa học cần cập nhật.';
    END IF;

    SELECT Subject_ID, Lecturer_ID
    INTO v_old_subject_id, v_old_lecturer_id
    FROM COURSE
    WHERE Course_ID = p_Course_ID;

    -- Validate tên khóa học
    IF p_Course_name IS NULL OR TRIM(p_Course_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tên khóa học không được để trống.';
    END IF;

    -- Validate ngày
    IF p_Start_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ngày bắt đầu khóa học không được để trống.';
    END IF;

    IF p_End_date IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ngày kết thúc khóa học không được để trống.';
    END IF;

    IF p_End_date < p_Start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ngày kết thúc khóa học phải lớn hơn hoặc bằng ngày bắt đầu.';
    END IF;

    -- Validate Subject_ID
    IF NOT EXISTS (
        SELECT 1
        FROM SUBJECT
        WHERE Subject_ID = p_Subject_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Subject_ID không tồn tại trong bảng SUBJECT.';
    END IF;

    -- Validate Lecturer_ID
    IF NOT EXISTS (
        SELECT 1
        FROM LECTURER
        WHERE User_ID = p_Lecturer_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lecturer_ID không tồn tại hoặc không phải là giảng viên.';
    END IF;

    -- Không cho đổi môn học nếu khóa học đã có sinh viên đăng ký
    IF p_Subject_ID <> v_old_subject_id
       AND EXISTS (
           SELECT 1
           FROM ENROLL
           WHERE Course_ID = p_Course_ID
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể đổi môn học vì khóa học đã có sinh viên đăng ký.';
    END IF;

    -- Không cho đổi giảng viên nếu khóa học đã có học phần hoặc quiz
    IF p_Lecturer_ID <> v_old_lecturer_id
       AND (
           EXISTS (
               SELECT 1
               FROM SECTION
               WHERE Course_ID = p_Course_ID
           )
           OR
           EXISTS (
               SELECT 1
               FROM QUIZ
               WHERE Course_ID = p_Course_ID
           )
       ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể đổi giảng viên vì khóa học đã có học phần hoặc bài kiểm tra.';
    END IF;

    -- Validate trùng khóa học sau cập nhật
    IF EXISTS (
        SELECT 1
        FROM COURSE
        WHERE Course_ID <> p_Course_ID
          AND Subject_ID = p_Subject_ID
          AND Lecturer_ID = p_Lecturer_ID
          AND Course_name = TRIM(p_Course_name)
          AND Start_date = p_Start_date
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Thông tin cập nhật bị trùng với một khóa học khác.';
    END IF;

    UPDATE COURSE
    SET
        Course_name = TRIM(p_Course_name),
        Description = p_Description,
        Start_date = p_Start_date,
        End_date = p_End_date,
        Subject_ID = p_Subject_ID,
        Lecturer_ID = p_Lecturer_ID
    WHERE Course_ID = p_Course_ID;

    SELECT
        p_Course_ID AS Updated_Course_ID,
        'Cập nhật khóa học thành công.' AS Message;
END //


-- =========================================================
-- 2.1.3 PROCEDURE: XÓA COURSE
-- =========================================================
-- Quy tắc xóa:
-- 1. Chỉ được xóa khóa học chưa phát sinh dữ liệu học tập.
-- 2. Không được xóa nếu đã có sinh viên đăng ký.
-- 3. Không được xóa nếu đã có học phần.
-- 4. Không được xóa nếu đã có quiz.
-- Mục đích: tránh mất lịch sử học tập, bài giảng, bài kiểm tra và kết quả học.

CREATE PROCEDURE sp_delete_course (
    IN p_Course_ID INT
)
BEGIN
    -- Validate Course_ID
    IF p_Course_ID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Course_ID không được để trống.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM COURSE
        WHERE Course_ID = p_Course_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không tìm thấy khóa học cần xóa.';
    END IF;

    -- Không cho xóa nếu đã có sinh viên đăng ký
    IF EXISTS (
        SELECT 1
        FROM ENROLL
        WHERE Course_ID = p_Course_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể xóa khóa học vì đã có sinh viên đăng ký.';
    END IF;

    -- Không cho xóa nếu đã có học phần
    IF EXISTS (
        SELECT 1
        FROM SECTION
        WHERE Course_ID = p_Course_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể xóa khóa học vì đã có học phần/bài giảng.';
    END IF;

    -- Không cho xóa nếu đã có quiz
    IF EXISTS (
        SELECT 1
        FROM QUIZ
        WHERE Course_ID = p_Course_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể xóa khóa học vì đã có bài kiểm tra.';
    END IF;

    DELETE FROM COURSE
    WHERE Course_ID = p_Course_ID;

    SELECT
        p_Course_ID AS Deleted_Course_ID,
        'Xóa khóa học thành công.' AS Message;
END //

DELIMITER ;


-- =========================================================
-- 2.1.4 PROCEDURE: CẬP NHẬT HỒ SƠ CÁ NHÂN (UPDATE PROFILE)
-- =========================================================
-- Logic phân chia:
--   Node.js (trước khi gọi): validate regex SSN, phone, password strength,
--                             so sánh new_password vs confirm_password,
--                             split phone string thành danh sách.
--   Procedure (dưới đây)   : validate business rules, toàn bộ DML
--                             (UPDATE USER_ACCOUNT, UPDATE LECTURER,
--                              DELETE/INSERT PHONE_NUMBERS, UPDATE password).
--
-- Tham số:
--   p_User_ID            : ID người dùng đang đăng nhập
--   p_Role               : 'Student' | 'Lecturer' | 'Admin'
--   p_Email              : email mới
--   p_Full_name          : họ tên mới
--   p_Address            : địa chỉ (có thể NULL)
--   p_SSN                : số CCCD (đã validate 12 chữ số ở Node)
--   p_Phone_csv          : danh sách SĐT phân cách bằng ',' (đã validate ở Node),
--                          chuỗi rỗng = xóa hết số điện thoại
--   p_Academic_degree    : học vị giảng viên (NULL nếu không phải Lecturer)
--   p_Academic_title     : học hàm giảng viên (NULL nếu không có / không phải Lecturer)
--   p_Teaching_experience: số năm kinh nghiệm (NULL nếu không phải Lecturer)
--   p_Old_password       : mật khẩu cũ (NULL nếu không đổi mật khẩu)
--   p_New_password       : mật khẩu mới (NULL nếu không đổi mật khẩu)
-- =========================================================

DROP PROCEDURE IF EXISTS sp_update_profile;

DELIMITER //

CREATE PROCEDURE sp_update_profile (
    IN p_User_ID             INT,
    IN p_Role                VARCHAR(20),
    IN p_Email               VARCHAR(150),
    IN p_Full_name           VARCHAR(150),
    IN p_Address             VARCHAR(300),
    IN p_SSN                 VARCHAR(12),
    IN p_Phone_csv           TEXT,          -- danh sách SĐT phân cách ','
    IN p_Academic_degree     VARCHAR(10),   -- NULL nếu không phải Lecturer
    IN p_Academic_title      VARCHAR(10),   -- NULL nếu không có
    IN p_Teaching_experience INT,           -- NULL nếu không phải Lecturer
    IN p_Old_password        VARCHAR(255),  -- NULL nếu không đổi mật khẩu
    IN p_New_password        VARCHAR(255)   -- NULL nếu không đổi mật khẩu
)
BEGIN
    -- ── biến nội bộ ──────────────────────────────────────────
    DECLARE v_current_password VARCHAR(255);
    DECLARE v_phone            VARCHAR(20);
    DECLARE v_csv_remaining    TEXT;
    DECLARE v_comma_pos        INT;

    -- ── 1. Validate bắt buộc ─────────────────────────────────
    IF p_User_ID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User_ID không được để trống.';
    END IF;

    IF p_Email IS NULL OR TRIM(p_Email) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email không được để trống.';
    END IF;

    IF p_Full_name IS NULL OR TRIM(p_Full_name) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Họ tên không được để trống.';
    END IF;

    IF p_SSN IS NULL OR TRIM(p_SSN) = '' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'SSN/CCCD không được để trống.';
    END IF;

    -- ── 2. Kiểm tra user tồn tại ─────────────────────────────
    IF NOT EXISTS (
        SELECT 1 FROM USER_ACCOUNT WHERE User_ID = p_User_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không tìm thấy tài khoản người dùng.';
    END IF;

    -- ── 3. Kiểm tra email trùng với người khác ───────────────
    IF EXISTS (
        SELECT 1
        FROM USER_ACCOUNT
        WHERE LOWER(TRIM(Email)) = LOWER(TRIM(p_Email))
          AND User_ID <> p_User_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email này đã được sử dụng bởi tài khoản khác.';
    END IF;

    -- ── 4. Validate học vị / học hàm nếu là Lecturer ─────────
    IF p_Role = 'Lecturer' THEN
        IF p_Academic_degree NOT IN ('CN', 'KS', 'ThS', 'TS') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Học vị không hợp lệ. Chỉ chấp nhận: CN, KS, ThS, TS.';
        END IF;

        IF p_Academic_title IS NOT NULL
           AND p_Academic_title NOT IN ('PGS', 'GS') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Học hàm không hợp lệ. Chỉ chấp nhận: PGS, GS.';
        END IF;
    END IF;

    -- ── 5. Validate mật khẩu (nếu có yêu cầu đổi) ───────────
    IF p_Old_password IS NOT NULL OR p_New_password IS NOT NULL THEN
        IF p_Old_password IS NULL OR p_New_password IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Vui lòng nhập đầy đủ mật khẩu cũ và mật khẩu mới.';
        END IF;

        SELECT Password
        INTO   v_current_password
        FROM   USER_ACCOUNT
        WHERE  User_ID = p_User_ID;

        IF v_current_password <> p_Old_password THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Mật khẩu hiện tại không chính xác.';
        END IF;
    END IF;

    -- ════════════════════════════════════════════════════════
    -- DML – tất cả nằm trong một transaction ngầm định
    -- ════════════════════════════════════════════════════════

    -- ── 6. Cập nhật USER_ACCOUNT ─────────────────────────────
    UPDATE USER_ACCOUNT
    SET Email     = TRIM(p_Email),
        Full_name = TRIM(p_Full_name),
        Address   = p_Address,
        SSN       = TRIM(p_SSN)
    WHERE User_ID = p_User_ID;

    -- ── 7. Cập nhật bảng LECTURER (nếu là Lecturer) ──────────
    IF p_Role = 'Lecturer' THEN
        UPDATE LECTURER
        SET Academic_degree     = p_Academic_degree,
            Academic_title      = p_Academic_title,
            Teaching_experience = IFNULL(p_Teaching_experience, 0)
        WHERE User_ID = p_User_ID;
    END IF;

    -- ── 8. Làm mới danh sách số điện thoại ───────────────────
    --   Node đã validate từng số; ở đây chỉ split theo ',' và insert.
    DELETE FROM PHONE_NUMBERS WHERE User_ID = p_User_ID;

    IF p_Phone_csv IS NOT NULL AND TRIM(p_Phone_csv) <> '' THEN
        SET v_csv_remaining = CONCAT(TRIM(p_Phone_csv), ',');

        WHILE LENGTH(v_csv_remaining) > 0 DO
            SET v_comma_pos = LOCATE(',', v_csv_remaining);

            IF v_comma_pos = 0 THEN
                SET v_csv_remaining = '';
            ELSE
                SET v_phone = TRIM(SUBSTRING(v_csv_remaining, 1, v_comma_pos - 1));
                SET v_csv_remaining = SUBSTRING(v_csv_remaining, v_comma_pos + 1);

                IF v_phone <> '' THEN
                    INSERT INTO PHONE_NUMBERS (User_ID, Phone_number)
                    VALUES (p_User_ID, v_phone);
                END IF;
            END IF;
        END WHILE;
    END IF;

    -- ── 9. Đổi mật khẩu (nếu có) ─────────────────────────────
    IF p_New_password IS NOT NULL THEN
        UPDATE USER_ACCOUNT
        SET Password = p_New_password
        WHERE User_ID = p_User_ID;
    END IF;

    -- ── 10. Trả kết quả ──────────────────────────────────────
    SELECT
        p_User_ID        AS Updated_User_ID,
        TRIM(p_Full_name) AS Full_name,
        TRIM(p_Email)     AS Email,
        'Cập nhật thông tin cá nhân thành công.' AS Message;
END //

DELIMITER ;





-- =========================================================
-- sp_delete_quiz
-- Chỉ xóa quiz khi chưa có học sinh nào làm (không có ATTEMPT)
-- =========================================================

DROP PROCEDURE IF EXISTS sp_delete_quiz;

DELIMITER //

CREATE PROCEDURE sp_delete_quiz (
    IN p_Quiz_ID     INT,
    IN p_Lecturer_ID INT
)
BEGIN
    -- Validate: quiz tồn tại và thuộc khóa học của giảng viên này
    IF NOT EXISTS (
        SELECT 1
        FROM QUIZ q
        JOIN COURSE c ON c.Course_ID = q.Course_ID
        WHERE q.Quiz_ID    = p_Quiz_ID
          AND c.Lecturer_ID = p_Lecturer_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quiz không tồn tại hoặc bạn không có quyền xóa quiz này.';
    END IF;

    -- Chỉ xóa khi chưa có học sinh nào làm
    IF EXISTS (
        SELECT 1
        FROM ATTEMPT
        WHERE Quiz_ID = p_Quiz_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể xóa quiz vì đã có học sinh làm bài. Hãy tắt quiz thay vì xóa (đang cập nhật).';
    END IF;

    -- Xóa các dữ liệu liên quan theo đúng thứ tự FK
    DELETE FROM FITB_ANSWERS  WHERE Quiz_ID = p_Quiz_ID;
    DELETE FROM MC_OPTIONS     WHERE Quiz_ID = p_Quiz_ID;
    DELETE FROM MULTIPLE_CHOICE WHERE Quiz_ID = p_Quiz_ID;
    DELETE FROM FILL_IN_THE_BLANKS WHERE Quiz_ID = p_Quiz_ID;
    DELETE FROM QUESTION       WHERE Quiz_ID = p_Quiz_ID;
    DELETE FROM QUIZ           WHERE Quiz_ID = p_Quiz_ID;

    SELECT p_Quiz_ID AS Deleted_Quiz_ID, 'Xóa quiz thành công.' AS Message;
END //

DELIMITER ;


-- =========================================================
-- Xóa bài giảng và cập nhật các logic liên quan:
--   1. Xóa MATERIAL_LINKS của bài giảng
--   2. Xóa INTERACT của bài giảng (lịch sử học sinh đã xem)
--   3. Xóa LECTURE
--   4. Cập nhật lại Num_of_lectures trong SECTION
-- =========================================================

DROP PROCEDURE IF EXISTS sp_delete_lecture;

DELIMITER //

CREATE PROCEDURE sp_delete_lecture (
    IN p_Lecture_ID  INT,
    IN p_Lecturer_ID INT
)
BEGIN
    DECLARE v_Course_ID    INT;
    DECLARE v_Section_order INT;

    -- Validate: lecture thuộc khóa học của giảng viên
    SELECT l.Course_ID, l.Section_order
    INTO   v_Course_ID, v_Section_order
    FROM   LECTURE l
    JOIN   COURSE  c ON c.Course_ID = l.Course_ID
    WHERE  l.Lecture_ID  = p_Lecture_ID
      AND  c.Lecturer_ID = p_Lecturer_ID
    LIMIT 1;

    IF v_Course_ID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Bài giảng không tồn tại hoặc bạn không có quyền xóa bài giảng này.';
    END IF;

    -- 1. Xóa tài liệu đính kèm
    DELETE FROM MATERIAL_LINKS WHERE Lecture_ID = p_Lecture_ID;

    -- 2. Xóa lịch sử tương tác của sinh viên với bài giảng này
    DELETE FROM INTERACT WHERE Lecture_ID = p_Lecture_ID;

    -- 3. Xóa bài giảng
    DELETE FROM LECTURE WHERE Lecture_ID = p_Lecture_ID;

    -- 4. Cập nhật lại Num_of_lectures trong Section
    UPDATE SECTION
    SET Num_of_lectures = (
        SELECT COUNT(*)
        FROM LECTURE
        WHERE Course_ID     = v_Course_ID
          AND Section_order = v_Section_order
    )
    WHERE Course_ID     = v_Course_ID
      AND Section_order = v_Section_order;

    SELECT p_Lecture_ID AS Deleted_Lecture_ID, 'Xóa bài giảng thành công.' AS Message;
END //

DELIMITER ;


-- =========================================================
-- Xóa học phần (section) và cascade xóa toàn bộ bài giảng
-- cùng các logic liên quan:
--   1. Xóa MATERIAL_LINKS của tất cả lectures trong section
--   2. Xóa INTERACT của tất cả lectures trong section
--   3. Xóa LECTURE thuộc section
--   4. Xóa SECTION
-- =========================================================

DROP PROCEDURE IF EXISTS sp_delete_section;

DELIMITER //

CREATE PROCEDURE sp_delete_section (
    IN p_Course_ID     INT,
    IN p_Section_order INT,
    IN p_Lecturer_ID   INT
)
BEGIN
    -- Validate: section tồn tại và thuộc khóa học của giảng viên
    IF NOT EXISTS (
        SELECT 1
        FROM SECTION sec
        JOIN COURSE  c ON c.Course_ID = sec.Course_ID
        WHERE sec.Course_ID     = p_Course_ID
          AND sec.Section_order = p_Section_order
          AND c.Lecturer_ID     = p_Lecturer_ID
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Học phần không tồn tại hoặc bạn không có quyền xóa học phần này.';
    END IF;

    -- 1. Xóa tài liệu đính kèm của tất cả lectures trong section
    DELETE ml
    FROM MATERIAL_LINKS ml
    JOIN LECTURE l ON l.Lecture_ID = ml.Lecture_ID
    WHERE l.Course_ID     = p_Course_ID
      AND l.Section_order = p_Section_order;

    -- 2. Xóa lịch sử tương tác của sinh viên với các lectures trong section
    DELETE i
    FROM INTERACT i
    JOIN LECTURE l ON l.Lecture_ID = i.Lecture_ID
    WHERE l.Course_ID     = p_Course_ID
      AND l.Section_order = p_Section_order;

    -- 3. Xóa tất cả lectures thuộc section
    DELETE FROM LECTURE
    WHERE Course_ID     = p_Course_ID
      AND Section_order = p_Section_order;

    -- 4. Xóa section
    DELETE FROM SECTION
    WHERE Course_ID     = p_Course_ID
      AND Section_order = p_Section_order;

    SELECT p_Section_order AS Deleted_Section_order,
           p_Course_ID     AS Course_ID,
           'Xóa học phần và toàn bộ bài giảng thành công.' AS Message;
END //

DELIMITER ;


-- =========================================================
-- sp_create_quiz
-- Mục tiêu:
-- Giảng viên tạo 1 quiz mới cho khóa học
-- =========================================================
DROP PROCEDURE IF EXISTS sp_create_quiz
DELIMITER //
CREATE PROCEDURE sp_create_quiz (
    IN  p_quiz_title    VARCHAR(255),
    IN  p_open_time     DATETIME,
    IN  p_close_time    DATETIME,
    IN  p_duration      INT,
    IN  p_max_attempts  INT,
    IN  p_max_score     DECIMAL(10,2),
    IN  p_pass_score    DECIMAL(10,2),
    IN  p_creator_id    INT,
    IN  p_course_id     INT,
    OUT p_new_quiz_id   INT
)
BEGIN
    -- Validation
    IF p_quiz_title IS NULL OR TRIM(p_quiz_title) = '' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Tên quiz không được để trống.';
    END IF;
 
    IF p_open_time IS NULL OR p_close_time IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Thời gian mở và đóng quiz không được để trống.';
    END IF;
 
    IF p_open_time >= p_close_time THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Thời gian đóng quiz phải sau thời gian mở quiz.';
    END IF;
 
    IF p_duration <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Thời lượng làm bài phải lớn hơn 0.';
    END IF;
 
    IF p_max_attempts < 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Số lần làm bài tối đa phải lớn hơn hoặc bằng 1.';
    END IF;
 
    IF p_max_score <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Max score phải lớn hơn 0.';
    END IF;
 
    IF p_pass_score < 0 OR p_pass_score > p_max_score THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Pass score phải nằm trong khoảng từ 0 đến Max score.';
    END IF;
 
    -- Validate: thời gian quiz phải nằm trong thời gian khóa học
    IF NOT EXISTS (
        SELECT 1
        FROM COURSE
        WHERE Course_ID  = p_course_id
          AND DATE(p_open_time)  >= Start_date
          AND DATE(p_close_time) <= End_date
    ) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Thời gian mở/đóng quiz phải nằm trong thời gian của khóa học (Start_date – End_date).';
    END IF;
 
    -- Insert
    INSERT INTO QUIZ
        (Quiz_title, Open_time, Close_time, Duration, Max_attempts, Max_score, Pass_score, Creator_ID, Course_ID)
    VALUES
        (TRIM(p_quiz_title), p_open_time, p_close_time, p_duration, p_max_attempts, p_max_score, p_pass_score, p_creator_id, p_course_id);
 
    SET p_new_quiz_id = LAST_INSERT_ID();
END //
DELIMITER ;