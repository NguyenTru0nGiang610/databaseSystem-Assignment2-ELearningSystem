USE LMS_BTL2;
SET NAMES utf8mb4;

START TRANSACTION;

-- =========================================================
-- 1. USER_ACCOUNT
-- User_ID 1-5: Student
-- User_ID 6-10: Lecturer
-- =========================================================

INSERT INTO USER_ACCOUNT
(User_ID, Username, Password, Email, User_role, SSN, Full_name, Address)
VALUES
(1, 'student01', 'Stud@12345678', 'student01@lms.edu.vn', 'Student', '012345678901', 'Nguyễn An Bình', 'TP. Hồ Chí Minh'),
(2, 'student02', 'Stud@22345678', 'student02@lms.edu.vn', 'Student', '012345678902', 'Trần Minh Châu', 'Đồng Nai'),
(3, 'student03', 'Stud@32345678', 'student03@lms.edu.vn', 'Student', '012345678903', 'Lê Quốc Dũng', 'Bình Dương'),
(4, 'student04', 'Stud@42345678', 'student04@lms.edu.vn', 'Student', '012345678904', 'Phạm Ngọc Hà', 'Long An'),
(5, 'student05', 'Stud@52345678', 'student05@lms.edu.vn', 'Student', '012345678905', 'Võ Gia Huy', 'Tiền Giang'),

(6, 'lecturer01', 'Lect@12345678', 'lecturer01@lms.edu.vn', 'Lecturer', '112345678901', 'Nguyễn Văn Minh', 'TP. Hồ Chí Minh'),
(7, 'lecturer02', 'Lect@22345678', 'lecturer02@lms.edu.vn', 'Lecturer', '112345678902', 'Trần Thị Lan', 'TP. Hồ Chí Minh'),
(8, 'lecturer03', 'Lect@32345678', 'lecturer03@lms.edu.vn', 'Lecturer', '112345678903', 'Lê Hoàng Nam', 'TP. Hồ Chí Minh'),
(9, 'lecturer04', 'Lect@42345678', 'lecturer04@lms.edu.vn', 'Lecturer', '112345678904', 'Phạm Quỳnh Anh', 'TP. Hồ Chí Minh'),
(10, 'lecturer05', 'Lect@52345678', 'lecturer05@lms.edu.vn', 'Lecturer', '112345678905', 'Võ Minh Khoa', 'TP. Hồ Chí Minh'),

(11, 'student06', 'Stud@62345678', 'student06@lms.edu.vn', 'Student', '012345678906', 'Đặng Minh Tâm', 'Cần Thơ'),
(12, 'student07', 'Stud@72345678', 'student07@lms.edu.vn', 'Student', '012345678907', 'Huỳnh Gia Bảo', 'Vũng Tàu'),
(13, 'student08', 'Stud@82345678', 'student08@lms.edu.vn', 'Student', '012345678908', 'Ngô Thanh Vy', 'Đà Nẵng'),
(14, 'student09', 'Stud@92345678', 'student09@lms.edu.vn', 'Student', '012345678909', 'Bùi Khánh Linh', 'Huế'),
(15, 'student10', 'Stud@10345678', 'student10@lms.edu.vn', 'Student', '012345678910', 'Phan Đức Long', 'Khánh Hòa'),

(16, 'lecturer06', 'Lect@62345678', 'lecturer06@lms.edu.vn', 'Lecturer', '112345678906', 'Đỗ Thành Công', 'TP. Hồ Chí Minh'),
(17, 'lecturer07', 'Lect@72345678', 'lecturer07@lms.edu.vn', 'Lecturer', '112345678907', 'Nguyễn Thu Hà', 'TP. Hồ Chí Minh'),
(18, 'lecturer08', 'Lect@82345678', 'lecturer08@lms.edu.vn', 'Lecturer', '112345678908', 'Trương Nhật Quang', 'TP. Hồ Chí Minh'),
(19, 'lecturer09', 'Lect@92345678', 'lecturer09@lms.edu.vn', 'Lecturer', '112345678909', 'Lý Hải Yến', 'TP. Hồ Chí Minh'),
(20, 'lecturer10', 'Lect@10345678', 'lecturer10@lms.edu.vn', 'Lecturer', '112345678910', 'Mai Quốc Việt', 'TP. Hồ Chí Minh');



-- =========================================================
-- 2. DEPARTMENT, MAJOR
-- =========================================================

INSERT INTO DEPARTMENT
(Dept_ID, Dept_name, Founding_date)
VALUES
(1, 'Khoa Khoa học và Kỹ thuật Máy tính', '1995-09-01'),
(2, 'Khoa Điện - Điện tử', '1994-09-01'),
(3, 'Khoa Cơ khí', '1993-09-01'),
(4, 'Khoa Quản lý Công nghiệp', '1998-09-01'),
(5, 'Khoa Kỹ thuật Xây dựng', '1992-09-01');

INSERT INTO MAJOR
(Dept_ID, Major_ID, Major_name)
VALUES
(1, 1, 'Khoa học Máy tính'),
(1, 2, 'Kỹ thuật Máy tính'),
(2, 1, 'Kỹ thuật Điện tử'),
(3, 1, 'Cơ điện tử'),
(4, 1, 'Quản trị Công nghiệp'),
(5, 1, 'Kỹ thuật Xây dựng');


-- =========================================================
-- 3. LECTURER, STUDENT
-- =========================================================

INSERT INTO LECTURER
(User_ID, Teaching_experience, Academic_degree, Academic_title)
VALUES
(6, 12, 'TS', NULL),
(7, 8, 'ThS', NULL),
(8, 15, 'TS', 'PGS'),
(9, 6, 'ThS', NULL),
(10, 10, 'TS', 'GS'),
(16, 7, 'ThS', NULL),
(17, 11, 'TS', NULL),
(18, 9, 'TS', 'PGS'),
(19, 5, 'ThS', NULL),
(20, 14, 'TS', 'GS');

INSERT INTO STUDENT
(User_ID, Dept_ID, Major_ID)
VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 1),
(4, 3, 1),
(5, 4, 1),
(11, 1, 1),
(12, 1, 2),
(13, 2, 1),
(14, 3, 1),
(15, 5, 1);


-- =========================================================
-- 4. PHONE_NUMBERS, DEGREES
-- =========================================================

INSERT INTO PHONE_NUMBERS
(User_ID, Phone_number)
VALUES
(1, '0900000001'),
(2, '0900000002'),
(3, '0900000003'),
(4, '0900000004'),
(5, '0900000005'),
(6, '0910000001'),
(7, '0910000002'),
(8, '0910000003'),
(9, '0910000004'),
(10, '0910000005'),
(11, '0900000006'),
(12, '0900000007'),
(13, '0900000008'),
(14, '0900000009'),
(15, '0900000010'),
(16, '0910000006'),
(17, '0910000007'),
(18, '0910000008'),
(19, '0910000009'),
(20, '0910000010');


INSERT INTO DEGREES
(Lecturer_ID, Degree)
VALUES
(6, 'Tiến sĩ Khoa học Máy tính'),
(6, 'Thạc sĩ Công nghệ Phần mềm'),
(7, 'Thạc sĩ Kỹ thuật Điện tử'),
(8, 'Tiến sĩ Cơ khí'),
(9, 'Thạc sĩ Quản lý Công nghiệp'),
(10, 'Tiến sĩ Kỹ thuật Xây dựng'),
(16, 'Thạc sĩ Trí tuệ Nhân tạo'),
(17, 'Tiến sĩ Khoa học Dữ liệu'),
(18, 'Tiến sĩ Hệ thống nhúng'),
(19, 'Thạc sĩ Quản lý Dự án'),
(20, 'Tiến sĩ Kỹ thuật Phần mềm');


-- =========================================================
-- 5. WORK_FOR, TERMS
-- TERMS lưu trưởng khoa và nhiệm kỳ.
-- =========================================================

INSERT INTO WORK_FOR
(Lecturer_ID, Dept_ID)
VALUES
(6, 1),
(7, 2),
(8, 3),
(9, 4),
(10, 5),
(16, 1),
(17, 1),
(18, 2),
(19, 4),
(20, 1);

INSERT INTO TERMS
(Dept_ID, Lecturer_ID, Start_date, End_date)
VALUES
(1, 6, '2024-01-01', '2028-01-01'),
(2, 7, '2024-01-01', '2028-01-01'),
(3, 8, '2024-01-01', '2028-01-01'),
(4, 9, '2024-01-01', '2028-01-01'),
(5, 10, '2024-01-01', '2028-01-01');

-- Cập nhật Head_ID cho các khoa dựa trên dữ liệu từ bảng TERMS
UPDATE DEPARTMENT SET Head_ID = 6 WHERE Dept_ID = 1;
UPDATE DEPARTMENT SET Head_ID = 7 WHERE Dept_ID = 2;
UPDATE DEPARTMENT SET Head_ID = 8 WHERE Dept_ID = 3;
UPDATE DEPARTMENT SET Head_ID = 9 WHERE Dept_ID = 4;
UPDATE DEPARTMENT SET Head_ID = 10 WHERE Dept_ID = 5;

-- =========================================================
-- 6. SUBJECT, PREREQUISITE
-- =========================================================

INSERT INTO SUBJECT
(Subject_ID, Subject_name, Credits, Syllabus, Dept_ID)
VALUES
(1, 'Nhập môn Lập trình', 3, 'https://lms.edu.vn/syllabus/CO1001.pdf', 1),
(2, 'Cấu trúc Dữ liệu và Giải thuật', 4, 'https://lms.edu.vn/syllabus/CO2003.pdf', 1),
(3, 'Hệ Cơ sở Dữ liệu', 4, 'https://lms.edu.vn/syllabus/CO2013.pdf', 1),
(4, 'Mạch Điện Cơ Bản', 3, 'https://lms.edu.vn/syllabus/EE2001.pdf', 2),
(5, 'Quản trị Dự án', 3, 'https://lms.edu.vn/syllabus/IM3001.pdf', 4),
(6, 'Lập trình Hướng đối tượng', 4, 'https://lms.edu.vn/syllabus/CO2001.pdf', 1),
(7, 'Trí tuệ Nhân tạo', 4, 'https://lms.edu.vn/syllabus/CO3005.pdf', 1),
(8, 'Hệ điều hành', 4, 'https://lms.edu.vn/syllabus/CO2011.pdf', 1),
(9, 'Mạng máy tính', 3, 'https://lms.edu.vn/syllabus/CO2015.pdf', 1),
(10, 'Phân tích dữ liệu', 3, 'https://lms.edu.vn/syllabus/CO4001.pdf', 1);

INSERT INTO PREREQUISITE
(Prerequisite_subject_ID, Advanced_subject_ID)
VALUES
(1, 2),
(2, 3),
(1, 4),
(1, 5),
(3, 5),
(1, 6),
(2, 7),
(2, 8),
(3, 10),
(1, 9);


-- =========================================================
-- 7. COURSE, ENROLL
-- Để Student 1, 2, 3, 4 có trạng thái 'Completed' cho Course 1 hợp lý,
-- họ phải thi qua Quiz 1 và xem hết Bài giảng 1.
-- =========================================================

INSERT INTO COURSE
(Course_ID, Course_name, Description, Start_date, End_date, Subject_ID, Lecturer_ID)
VALUES
(1, 'Nhập môn lập trình', 'Khóa học nhập môn lập trình cho sinh viên năm nhất.', '2026-02-01', '2026-06-30', 1, 6),
(2, 'Cấu trúc dữ liệu và Giải thuật', 'Khóa học về cấu trúc dữ liệu và giải thuật.', '2026-02-01', '2026-06-30', 2, 6),
(3, 'Hệ Cơ sở Dữ liệu', 'Khóa học thiết kế và hiện thực cơ sở dữ liệu.', '2026-02-01', '2026-06-30', 3, 6),
(4, 'Mạch điện cơ bản', 'Khóa học nền tảng cho sinh viên điện tử.', '2026-02-01', '2026-06-30', 4, 7),
(5, 'Quản trị dự án', 'Khóa học quản lý dự án trong kỹ thuật.', '2026-02-01', '2026-06-30', 5, 9),
(6, 'Lập trình hướng đối tượng', 'Khóa học OOP với Java/C++.', '2026-02-01', '2026-06-30', 6, 16),
(7, 'Trí tuệ nhân tạo', 'Khóa học nền tảng AI.', '2026-02-01', '2026-06-30', 7, 17),
(8, 'Hệ điều hành', 'Khóa học về tiến trình và bộ nhớ.', '2026-02-01', '2026-06-30', 8, 20),
(9, 'Mạng máy tính', 'Khóa học mạng căn bản.', '2026-02-01', '2026-06-30', 9, 18),
(10, 'Phân tích dữ liệu', 'Khóa học xử lý dữ liệu.', '2026-02-01', '2026-06-30', 10, 17);


INSERT INTO ENROLL
(Student_ID, Course_ID, Enrolled_at, Enroll_status, Final_score, Completed_at)
VALUES
(1, 1, '2026-02-05 08:00:00', 'Completed', 10.00, '2026-06-20 10:00:00'),
(2, 1, '2026-02-06 08:00:00', 'Completed', 10.00, '2026-06-20 10:00:00'),
(3, 1, '2026-02-07 08:00:00', 'Completed', 10.00, '2026-06-20 10:00:00'),
(4, 1, '2026-02-08 08:00:00', 'Completed', 6.00, '2026-06-20 10:00:00'),
(5, 1, '2026-02-09 08:00:00', 'Enrolled', NULL, NULL),

(1, 2, '2026-02-10 08:00:00', 'Completed', 10.00, '2026-06-21 10:00:00'),
(2, 2, '2026-02-11 08:00:00', 'Enrolled', NULL, NULL),
(1, 3, '2026-02-12 08:00:00', 'Completed', 10.00, '2026-06-22 10:00:00'),
(3, 4, '2026-02-13 08:00:00', 'Enrolled', NULL, NULL),
(1, 5, '2026-02-14 08:00:00', 'Completed', 10.00, '2026-06-23 10:00:00'),
(11, 6, '2026-02-10 08:00:00', 'Completed', 9.00, '2026-06-20 10:00:00'),
(12, 6, '2026-02-11 08:00:00', 'Completed', 8.50, '2026-06-20 10:00:00'),
(13, 7, '2026-02-12 08:00:00', 'Enrolled', NULL, NULL),
(14, 8, '2026-02-13 08:00:00', 'Completed', 7.50, '2026-06-21 10:00:00'),
(15, 9, '2026-02-14 08:00:00', 'Enrolled', NULL, NULL),

(11, 10, '2026-02-15 08:00:00', 'Completed', 9.50, '2026-06-22 10:00:00'),
(12, 7, '2026-02-16 08:00:00', 'Completed', 8.00, '2026-06-22 10:00:00'),
(13, 9, '2026-02-17 08:00:00', 'Completed', 7.00, '2026-06-22 10:00:00');


-- =========================================================
-- 8. SECTION, LECTURE
-- =========================================================

INSERT INTO SECTION
(Course_ID, Section_order, Section_name, Num_of_lectures, Creator_ID)
VALUES
(1, 1, 'Tổng quan lập trình', 1, 6),
(2, 1, 'Danh sách liên kết', 1, 6),
(3, 1, 'Mô hình ER và EER', 1, 6),
(4, 1, 'Khái niệm mạch điện', 1, 7),
(5, 1, 'Tổng quan quản trị dự án', 1, 9),
(6, 1, 'Khái niệm OOP', 1, 16),
(7, 1, 'Tổng quan AI', 1, 17),
(8, 1, 'Quản lý tiến trình', 1, 20),
(9, 1, 'Mô hình OSI', 1, 18),
(10, 1, 'Tiền xử lý dữ liệu', 1, 17);

INSERT INTO LECTURE
(Lecture_ID, Title, Created_at, Course_ID, Section_order, Creator_ID)
VALUES
(1, 'Bài 1: Biến và kiểu dữ liệu', '2026-02-01 08:00:00', 1, 1, 6),
(2, 'Bài 1: Danh sách liên kết đơn', '2026-02-02 08:00:00', 2, 1, 6),
(3, 'Bài 1: Thực thể và liên kết', '2026-02-03 08:00:00', 3, 1, 6),
(4, 'Bài 1: Dòng điện và điện áp', '2026-02-04 08:00:00', 4, 1, 7),
(5, 'Bài 1: Chu kỳ sống dự án', '2026-02-05 08:00:00', 5, 1, 9),
(6, 'Bài 1: Class và Object', '2026-02-06 08:00:00', 6, 1, 16),
(7, 'Bài 1: Giới thiệu AI', '2026-02-07 08:00:00', 7, 1, 17),
(8, 'Bài 1: Process và Thread', '2026-02-08 08:00:00', 8, 1, 20),
(9, 'Bài 1: Kiến trúc mạng', '2026-02-09 08:00:00', 9, 1, 18),
(10, 'Bài 1: Data Cleaning', '2026-02-10 08:00:00', 10, 1, 17);


-- =========================================================
-- 9. INTERACT, MATERIAL_LINKS
-- Để logic đúng, Student 1,2,3,4 phải Completed Lecture 1 của Course 1
-- =========================================================

INSERT INTO INTERACT
(Student_ID, Lecture_ID, Status, Interacted_at)
VALUES
(1, 1, 'Completed', '2026-02-10 09:00:00'),
(2, 1, 'Completed', '2026-02-11 09:00:00'),
(3, 1, 'Completed', '2026-02-12 09:00:00'),
(4, 1, 'Completed', '2026-02-13 09:00:00'),
(5, 1, 'In Progress', '2026-02-14 09:00:00'),
(1, 2, 'Completed', '2026-02-15 09:00:00'),
(1, 3, 'Completed', '2026-02-16 09:00:00'),
(1, 5, 'Completed', '2026-02-17 09:00:00'),
(11, 6, 'Completed', '2026-02-20 09:00:00'),
(12, 6, 'Completed', '2026-02-20 10:00:00'),
(13, 7, 'In Progress', '2026-02-21 09:00:00'),
(14, 8, 'Completed', '2026-02-21 10:00:00'),
(15, 9, 'In Progress', '2026-02-22 09:00:00');

INSERT INTO MATERIAL_LINKS
(Lecture_ID, Link)
VALUES
(1, 'https://lms.edu.vn/materials/lecture1-programming.pdf'),
(2, 'https://lms.edu.vn/materials/lecture1-linkedlist.pdf'),
(3, 'https://lms.edu.vn/materials/lecture1-eer.pdf'),
(4, 'https://lms.edu.vn/materials/lecture1-circuit.pdf'),
(5, 'https://lms.edu.vn/materials/lecture1-project.pdf'),
(1, 'https://lms.edu.vn/videos/lecture1-programming.mp4'),
(6, 'https://lms.edu.vn/materials/oop.pdf'),
(7, 'https://lms.edu.vn/materials/ai.pdf'),
(8, 'https://lms.edu.vn/materials/os.pdf'),
(9, 'https://lms.edu.vn/materials/network.pdf'),
(10, 'https://lms.edu.vn/materials/data-analysis.pdf');



-- =========================================================
-- 10. QUIZ
-- =========================================================

INSERT INTO QUIZ
(Quiz_ID, Quiz_title, Max_attempts, Pass_score, Duration, Max_score, Close_time, Open_time, Creator_ID, Course_ID)
VALUES
(1, 'Quiz 1', 2, 5.00, 45, 10.00, '2026-03-30 23:59:00', '2026-03-01 08:00:00', 6, 1),
(2, 'Quiz 2', 2, 5.00, 45, 10.00, '2026-03-30 23:59:00', '2026-03-01 08:00:00', 6, 2),
(3, 'Quiz 3', 3, 5.00, 60, 10.00, '2026-03-30 23:59:00', '2026-03-01 08:00:00', 6, 3),
(4, 'Quiz 4', 2, 5.00, 45, 10.00, '2026-03-30 23:59:00', '2026-03-01 08:00:00', 7, 4),
(5, 'Quiz 5', 2, 5.00, 45, 10.00, '2026-03-30 23:59:00', '2026-03-01 08:00:00', 9, 5),
(6, 'Quiz OOP', 2, 5.00, 45, 10.00, '2026-04-01 23:59:00', '2026-03-01 08:00:00', 16, 6),
(7, 'Quiz AI', 2, 5.00, 45, 10.00, '2026-04-01 23:59:00', '2026-03-01 08:00:00', 17, 7),
(8, 'Quiz OS', 2, 5.00, 60, 10.00, '2026-04-01 23:59:00', '2026-03-01 08:00:00', 20, 8),
(9, 'Quiz Network', 2, 5.00, 45, 10.00, '2026-04-01 23:59:00', '2026-03-01 08:00:00', 18, 9),
(10, 'Quiz Data', 2, 5.00, 45, 10.00, '2026-04-01 23:59:00', '2026-03-01 08:00:00', 17, 10);


-- =========================================================
-- 11. QUESTION
-- Mỗi quiz có 1 câu MCQ và 1 câu FILL_BLANK.
-- =========================================================

INSERT INTO QUESTION
(Quiz_ID, Question_ID, Creator_ID, Content, Question_type)
VALUES
(1, 1, 6, 'Kiểu dữ liệu nào dùng để lưu số nguyên trong C?', 'MCQ'),
(1, 2, 6, 'Từ khóa dùng để khai báo biến nguyên là {blank}.', 'FILL_BLANK'),

(2, 1, 6, 'Cấu trúc dữ liệu nào gồm các node liên kết với nhau?', 'MCQ'),
(2, 2, 6, 'Con trỏ trỏ đến node kế tiếp thường được gọi là {blank}.', 'FILL_BLANK'),

(3, 1, 6, 'Trong ERD, hình chữ nhật biểu diễn thành phần nào?', 'MCQ'),
(3, 2, 6, 'Khóa chính dùng để {blank} một bản ghi.', 'FILL_BLANK'),

(4, 1, 7, 'Đơn vị của cường độ dòng điện là gì?', 'MCQ'),
(4, 2, 7, 'Định luật Ohm có dạng U = {blank}.', 'FILL_BLANK'),

(5, 1, 9, 'Giai đoạn đầu tiên của quản trị dự án là gì?', 'MCQ'),
(5, 2, 9, 'Một dự án thường có phạm vi, thời gian và {blank}.', 'FILL_BLANK'),

(6, 1, 16, 'Tính đóng gói thuộc tính nào của OOP?', 'MCQ'),
(6, 2, 16, 'Từ khóa tạo đối tượng trong Java là {blank}.', 'FILL_BLANK'),

(7, 1, 17, 'AI là viết tắt của cụm từ nào?', 'MCQ'),
(7, 2, 17, 'Machine Learning là một nhánh của {blank}.', 'FILL_BLANK'),

(8, 1, 20, 'Tiến trình nhẹ được gọi là gì?', 'MCQ'),
(8, 2, 20, 'CPU scheduling dùng để {blank} tiến trình.', 'FILL_BLANK'),

(9, 1, 18, 'OSI có bao nhiêu tầng?', 'MCQ'),
(9, 2, 18, 'HTTP hoạt động trên giao thức {blank}.', 'FILL_BLANK'),

(10, 1, 17, 'Pandas thường dùng cho tác vụ gì?', 'MCQ'),
(10, 2, 17, 'Thiếu dữ liệu thường được gọi là dữ liệu {blank}.', 'FILL_BLANK');


-- =========================================================
-- 12. MULTIPLE_CHOICE, MC_OPTIONS
-- =========================================================

INSERT INTO MULTIPLE_CHOICE
(Quiz_ID, Question_ID, MC_correct_answer, Score, Shuffle_flag)
VALUES
(1, 1, 'int', 6.00, TRUE),
(2, 1, 'Linked list', 6.00, TRUE),
(3, 1, 'Thực thể', 6.00, FALSE),
(4, 1, 'Ampere', 6.00, TRUE),
(5, 1, 'Khởi động dự án', 6.00, FALSE),
(6, 1, 'Encapsulation', 6.00, TRUE),
(7, 1, 'Artificial Intelligence', 6.00, TRUE),
(8, 1, 'Thread', 6.00, TRUE),
(9, 1, '7', 6.00, FALSE),
(10, 1, 'Phân tích dữ liệu', 6.00, TRUE);

INSERT INTO MC_OPTIONS
(Quiz_ID, Question_ID, Option_text)
VALUES
(1, 1, 'int'),
(1, 1, 'float'),
(1, 1, 'char'),

(2, 1, 'Linked list'),
(2, 1, 'Array'),
(2, 1, 'Stack'),

(3, 1, 'Thực thể'),
(3, 1, 'Thuộc tính'),
(3, 1, 'Mối liên kết'),

(4, 1, 'Ampere'),
(4, 1, 'Volt'),
(4, 1, 'Ohm'),

(5, 1, 'Khởi động dự án'),
(5, 1, 'Kết thúc dự án'),
(5, 1, 'Đóng dự án'),

(6, 1, 'Encapsulation'),
(6, 1, 'Inheritance'),
(6, 1, 'Polymorphism'),

(7, 1, 'Artificial Intelligence'),
(7, 1, 'Automatic Internet'),
(7, 1, 'Advanced Information'),

(8, 1, 'Thread'),
(8, 1, 'Pointer'),
(8, 1, 'Semaphore'),

(9, 1, '7'),
(9, 1, '5'),
(9, 1, '9'),

(10, 1, 'Phân tích dữ liệu'),
(10, 1, 'Thiết kế web'),
(10, 1, 'Lập trình game');



-- =========================================================
-- 13. FILL_IN_THE_BLANKS, FITB_ANSWERS
-- =========================================================

INSERT INTO FILL_IN_THE_BLANKS
(Quiz_ID, Question_ID, Score)
VALUES
(1, 2, 4.00),
(2, 2, 4.00),
(3, 2, 4.00),
(4, 2, 4.00),
(5, 2, 4.00),
(6, 2, 4.00),
(7, 2, 4.00),
(8, 2, 4.00),
(9, 2, 4.00),
(10, 2, 4.00);


INSERT INTO FITB_ANSWERS
(Quiz_ID, Question_ID, Answer_text)
VALUES
(1, 2, 'int'),
(2, 2, 'next'),
(3, 2, 'định danh'),
(3, 2, 'nhận diện'),
(4, 2, 'I*R'),
(4, 2, 'IR'),
(5, 2, 'chi phí'),
(6, 2, 'new'),
(7, 2, 'AI'),
(8, 2, 'điều phối'),
(9, 2, 'TCP'),
(10, 2, 'missing');


-- =========================================================
-- 14. ATTEMPT
-- Để khớp với Final_score trong bảng ENROLL, ta cần khớp Total_score.
-- Student 1, 2, 3 (Course 1) = 10.00 đ
-- Student 4 (Course 1) = 6.00 đ
-- Student 1 (Course 2, 3, 5) = 10.00 đ
-- =========================================================

INSERT INTO ATTEMPT
(Student_ID, Quiz_ID, Attempt_order, Start_time, Submit_time, Total_score)
VALUES
-- Course 1: Quiz 1
(1, 1, 1, '2026-03-05 08:00:00', '2026-03-05 08:30:00', 10.00),
(2, 1, 1, '2026-03-05 08:15:00', '2026-03-05 08:45:00', 10.00),
(3, 1, 1, '2026-03-05 08:30:00', '2026-03-05 09:00:00', 10.00),
(4, 1, 1, '2026-03-05 09:00:00', '2026-03-05 09:40:00', 6.00),
-- Course 2: Quiz 2
(1, 2, 1, '2026-03-06 08:00:00', '2026-03-06 08:35:00', 10.00),
-- Course 3: Quiz 3
(1, 3, 1, '2026-03-07 08:00:00', '2026-03-07 08:40:00', 10.00),
-- Course 5: Quiz 5
(1, 5, 1, '2026-03-09 08:00:00', '2026-03-09 08:30:00', 10.00),

(11, 6, 1, '2026-03-10 08:00:00', '2026-03-10 08:35:00', 9.00),
(12, 6, 1, '2026-03-10 09:00:00', '2026-03-10 09:40:00', 8.50),
(14, 8, 1, '2026-03-11 08:00:00', '2026-03-11 08:50:00', 7.50),
(11, 10, 1, '2026-03-12 08:00:00', '2026-03-12 08:40:00', 9.50),
(12, 7, 1, '2026-03-13 08:00:00', '2026-03-13 08:40:00', 8.00);


-- =========================================================
-- 15. ANSWER
-- Khớp điểm chi tiết cho từng câu hỏi với ATTEMPT.
-- =========================================================

INSERT INTO ANSWER
(Student_ID, Quiz_ID, Attempt_order, Question_ID, Student_answer, Earned_score)
VALUES
-- Student 1 (Quiz 1) -> 10.00đ
(1, 1, 1, 1, 'int', 6.00),
(1, 1, 1, 2, 'int', 4.00),

-- Student 2 (Quiz 1) -> 10.00đ
(2, 1, 1, 1, 'int', 6.00),
(2, 1, 1, 2, 'int', 4.00),

-- Student 3 (Quiz 1) -> 10.00đ
(3, 1, 1, 1, 'int', 6.00),
(3, 1, 1, 2, 'int', 4.00),

-- Student 4 (Quiz 1) -> 6.00đ (Đúng MCQ, Sai FITB)
(4, 1, 1, 1, 'int', 6.00),
(4, 1, 1, 2, 'float', 0.00),

-- Student 1 (Quiz 2) -> 10.00đ
(1, 2, 1, 1, 'Linked list', 6.00),
(1, 2, 1, 2, 'next', 4.00),

-- Student 1 (Quiz 3) -> 10.00đ
(1, 3, 1, 1, 'Thực thể', 6.00),
(1, 3, 1, 2, 'định danh', 4.00),

-- Student 1 (Quiz 5) -> 10.00đ
(1, 5, 1, 1, 'Khởi động dự án', 6.00),
(1, 5, 1, 2, 'chi phí', 4.00),

(11, 6, 1, 1, 'Encapsulation', 6.00),
(11, 6, 1, 2, 'new', 3.00),

(12, 6, 1, 1, 'Encapsulation', 6.00),
(12, 6, 1, 2, 'create', 2.50),

(14, 8, 1, 1, 'Thread', 6.00),
(14, 8, 1, 2, 'quản lý', 1.50),

(11, 10, 1, 1, 'Phân tích dữ liệu', 6.00),
(11, 10, 1, 2, 'missing', 3.50),

(12, 7, 1, 1, 'Artificial Intelligence', 6.00),
(12, 7, 1, 2, 'AI', 2.00);


COMMIT;


-- =========================================================
-- 16. KIỂM TRA SỐ DÒNG SAU KHI INSERT
-- =========================================================

SELECT 'USER_ACCOUNT' AS Table_name, COUNT(*) AS Total_rows FROM USER_ACCOUNT
UNION ALL SELECT 'LECTURER', COUNT(*) FROM LECTURER
UNION ALL SELECT 'STUDENT', COUNT(*) FROM STUDENT
UNION ALL SELECT 'DEPARTMENT', COUNT(*) FROM DEPARTMENT
UNION ALL SELECT 'MAJOR', COUNT(*) FROM MAJOR
UNION ALL SELECT 'PHONE_NUMBERS', COUNT(*) FROM PHONE_NUMBERS
UNION ALL SELECT 'DEGREES', COUNT(*) FROM DEGREES
UNION ALL SELECT 'WORK_FOR', COUNT(*) FROM WORK_FOR
UNION ALL SELECT 'TERMS', COUNT(*) FROM TERMS
UNION ALL SELECT 'SUBJECT', COUNT(*) FROM SUBJECT
UNION ALL SELECT 'PREREQUISITE', COUNT(*) FROM PREREQUISITE
UNION ALL SELECT 'COURSE', COUNT(*) FROM COURSE
UNION ALL SELECT 'ENROLL', COUNT(*) FROM ENROLL
UNION ALL SELECT 'SECTION', COUNT(*) FROM SECTION
UNION ALL SELECT 'LECTURE', COUNT(*) FROM LECTURE
UNION ALL SELECT 'INTERACT', COUNT(*) FROM INTERACT
UNION ALL SELECT 'MATERIAL_LINKS', COUNT(*) FROM MATERIAL_LINKS
UNION ALL SELECT 'QUIZ', COUNT(*) FROM QUIZ
UNION ALL SELECT 'QUESTION', COUNT(*) FROM QUESTION
UNION ALL SELECT 'MULTIPLE_CHOICE', COUNT(*) FROM MULTIPLE_CHOICE
UNION ALL SELECT 'MC_OPTIONS', COUNT(*) FROM MC_OPTIONS
UNION ALL SELECT 'FILL_IN_THE_BLANKS', COUNT(*) FROM FILL_IN_THE_BLANKS
UNION ALL SELECT 'FITB_ANSWERS', COUNT(*) FROM FITB_ANSWERS
UNION ALL SELECT 'ATTEMPT', COUNT(*) FROM ATTEMPT
UNION ALL SELECT 'ANSWER', COUNT(*) FROM ANSWER;