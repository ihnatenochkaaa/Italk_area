DROP DATABASE IF EXISTS italk;
CREATE DATABASE italk;
USE italk;

CREATE TABLE IF NOT EXISTS `users` (
  `user_id` int AUTO_INCREMENT NOT NULL,
  `wp_user_id` bigint,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20),
  role ENUM('student', 'teacher', 'admin') NOT NULL DEFAULT 'student',
  `bio` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  CONSTRAINT `uq_users_email` UNIQUE (email),
  CONSTRAINT `uq_users_wp_user_id` UNIQUE (wp_user_id)
);

CREATE TABLE IF NOT EXISTS `languages` (
  `language_id` smallint AUTO_INCREMENT NOT NULL,
  `language_name` varchar(100) NOT NULL,
  `language_code` char(2) NOT NULL,
  PRIMARY KEY (`language_id`),
  CONSTRAINT `uq_languages_language_name` UNIQUE (language_name),
  CONSTRAINT `uq_languages_language_code` UNIQUE (language_code)
);
CREATE TABLE IF NOT EXISTS `course_levels` (
  `level_id` tinyint AUTO_INCREMENT NOT NULL,
  `level_code` varchar(5) NOT NULL,
  `level_name` varchar(100) NOT NULL,
  `sort_order` tinyint NOT NULL,
  PRIMARY KEY (`level_id`),
  CONSTRAINT `uq_course_levels_level_code` UNIQUE (level_code)
);
CREATE TABLE IF NOT EXISTS `courses` (
  `course_id` int AUTO_INCREMENT NOT NULL,
  `language_id` smallint NOT NULL,
  `level_id` tinyint NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `duration_hours` smallint,
  `is_published` tinyint NOT NULL DEFAULT 1,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`course_id`),
  CONSTRAINT `uq_courses_language_id_level_id_title` UNIQUE (language_id, level_id, title),
  CONSTRAINT `chk_course_price` CHECK (price >= 0)
);
CREATE TABLE IF NOT EXISTS `course_tutors` (
  `course_id` int NOT NULL,
  `tutor_id` int NOT NULL,
  `is_lead` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`course_id`, `tutor_id`)
);
CREATE TABLE IF NOT EXISTS `lessons` (
  `lesson_id` int AUTO_INCREMENT NOT NULL,
  `course_id` int NOT NULL,
  `lesson_number` smallint NOT NULL,
  lesson_type ENUM('theory', 'practice') NOT NULL DEFAULT 'theory',
  `title` varchar(255) NOT NULL,
  `content` text,
  `duration_min` smallint,
  PRIMARY KEY (`lesson_id`),
  CONSTRAINT `uq_lessons_course_id_lesson_number` UNIQUE (course_id, lesson_number)
);
CREATE TABLE IF NOT EXISTS `enrollments` (
  `enrollment_id` int AUTO_INCREMENT NOT NULL,
  `student_id` int NOT NULL,
  `course_id` int NOT NULL,
  status ENUM('active', 'completed', 'dropped') NOT NULL DEFAULT 'active',
  `progress_percent` tinyint NOT NULL DEFAULT 0,
  `price_paid` decimal(10,2) NOT NULL DEFAULT 0.00,
  `enrolled_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `completed_at` datetime,
  PRIMARY KEY (`enrollment_id`),
  CONSTRAINT `uq_enrollments_student_id_course_id` UNIQUE (student_id, course_id),
  CONSTRAINT `chk_progress` CHECK (progress_percent between 0 and 100)
);
CREATE TABLE IF NOT EXISTS `reviews` (
  `review_id` int AUTO_INCREMENT NOT NULL,
  `enrollment_id` int NOT NULL,
  `rating` tinyint NOT NULL,
  `review_text` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  CONSTRAINT `uq_reviews_enrollment_id` UNIQUE (enrollment_id),
  CONSTRAINT `chk_rating` CHECK (rating between 1 and 5)
);
CREATE TABLE IF NOT EXISTS `call_requests` (
  `request_id` int AUTO_INCREMENT NOT NULL,
  `user_id` int,
  `course_id` int,
  `manager_id` int,
  `name` varchar(150) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `email` varchar(255),
  `message` text,
  status ENUM('new', 'in_progress', 'completed', 'cancelled') NOT NULL DEFAULT 'new',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `processed_at` datetime,
  PRIMARY KEY (`request_id`)
);
CREATE TABLE IF NOT EXISTS `test_results` (
  `result_id` int AUTO_INCREMENT NOT NULL,
  `enrollment_id` int NOT NULL,
  `lesson_id` int NOT NULL,
  `score` tinyint NOT NULL,
  `is_passed` tinyint NOT NULL DEFAULT 0,
  `attempt_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`result_id`),
  CONSTRAINT `chk_test_score` CHECK (score between 0 and 100)
);
ALTER TABLE courses ADD CONSTRAINT fk_courses_language FOREIGN KEY (language_id) REFERENCES languages (language_id);
ALTER TABLE courses ADD CONSTRAINT fk_courses_level FOREIGN KEY (level_id) REFERENCES course_levels (level_id);
ALTER TABLE course_tutors ADD CONSTRAINT fk_ct_course FOREIGN KEY (course_id) REFERENCES courses (course_id);
ALTER TABLE course_tutors ADD CONSTRAINT fk_ct_tutor FOREIGN KEY (tutor_id) REFERENCES users (user_id);
ALTER TABLE lessons ADD CONSTRAINT fk_lessons_course FOREIGN KEY (course_id) REFERENCES courses (course_id);
ALTER TABLE enrollments ADD CONSTRAINT fk_enroll_student FOREIGN KEY (student_id) REFERENCES users (user_id);
ALTER TABLE enrollments ADD CONSTRAINT fk_enroll_course FOREIGN KEY (course_id) REFERENCES courses (course_id);
ALTER TABLE reviews ADD CONSTRAINT fk_reviews_enrollment FOREIGN KEY (enrollment_id) REFERENCES enrollments (enrollment_id);
ALTER TABLE call_requests ADD CONSTRAINT fk_cr_user FOREIGN KEY (user_id) REFERENCES users (user_id);
ALTER TABLE call_requests ADD CONSTRAINT fk_cr_course FOREIGN KEY (course_id) REFERENCES courses (course_id);
ALTER TABLE call_requests ADD CONSTRAINT fk_cr_manager FOREIGN KEY (manager_id) REFERENCES users (user_id);
ALTER TABLE test_results ADD CONSTRAINT fk_test_enrollment FOREIGN KEY (enrollment_id) REFERENCES enrollments (enrollment_id);
ALTER TABLE test_results ADD CONSTRAINT fk_test_lesson FOREIGN KEY (lesson_id) REFERENCES lessons (lesson_id);

CREATE INDEX idx_users_role USING BTREE ON users (role);
CREATE INDEX idx_courses_catalog USING BTREE ON courses (language_id, level_id, is_published);
CREATE INDEX idx_enroll_course_status USING BTREE ON enrollments (course_id, status);
CREATE INDEX idx_cr_status_created USING BTREE ON call_requests (status, created_at);
CREATE INDEX idx_cr_manager_status USING BTREE ON call_requests (manager_id, status);
CREATE INDEX idx_test_enrollment_lesson USING BTREE ON test_results (enrollment_id, lesson_id);
