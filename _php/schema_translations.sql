-- Table to store available languages
CREATE TABLE IF NOT EXISTS `languages` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(10) NOT NULL UNIQUE COMMENT 'Language code (e.g., vi, en, ja)',
  `name` VARCHAR(100) NOT NULL COMMENT 'English name',
  `native_name` VARCHAR(100) NOT NULL COMMENT 'Native language name',
  `flag_code` VARCHAR(10) DEFAULT NULL COMMENT 'Country code for flag (e.g., VN, US)',
  `is_active` TINYINT(1) DEFAULT 1 COMMENT '1 = active, 0 = inactive',
  `display_order` INT DEFAULT 0 COMMENT 'Display order in list',
  `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_code` (`code`),
  INDEX `idx_is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table to store translations
CREATE TABLE IF NOT EXISTS `translations` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `language_code` VARCHAR(10) NOT NULL COMMENT 'FK to languages.code',
  `translation_key` VARCHAR(255) NOT NULL COMMENT 'Translation key (e.g., appTitle)',
  `translation_value` TEXT NOT NULL COMMENT 'Translated text',
  `is_active` TINYINT(1) DEFAULT 1 COMMENT '1 = active, 0 = inactive',
  `last_updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `unique_translation` (`language_code`, `translation_key`),
  INDEX `idx_language_code` (`language_code`),
  INDEX `idx_translation_key` (`translation_key`),
  INDEX `idx_is_active` (`is_active`),
  FOREIGN KEY (`language_code`) REFERENCES `languages`(`code`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default languages
INSERT INTO `languages` (`code`, `name`, `native_name`, `flag_code`, `display_order`) VALUES
('vi', 'Vietnamese', 'Tiếng Việt', 'VN', 1),
('en', 'English', 'English', 'US', 2),
('ja', 'Japanese', '日本語', 'JP', 3),
('ko', 'Korean', '한국어', 'KR', 4),
('fr', 'French', 'Français', 'FR', 5),
('de', 'German', 'Deutsch', 'DE', 6),
('es', 'Spanish', 'Español', 'ES', 7)
ON DUPLICATE KEY UPDATE 
  `name` = VALUES(`name`),
  `native_name` = VALUES(`native_name`),
  `flag_code` = VALUES(`flag_code`);

-- Example: Insert some sample translations (optional)
INSERT INTO `translations` (`language_code`, `translation_key`, `translation_value`) VALUES
('vi', 'appTitle', 'Monitor App (From Server)'),
('vi', 'appError', 'Lỗi (Server)'),
('vi', 'appSuccess', 'Thành công (Server)'),
('en', 'appTitle', 'Monitor App (From Server)'),
('en', 'appError', 'Error (Server)'),
('en', 'appSuccess', 'Success (Server)')
ON DUPLICATE KEY UPDATE 
  `translation_value` = VALUES(`translation_value`);

-- Add comment to explain usage
-- To add new language: INSERT INTO languages (code, name, native_name, flag_code, display_order)
-- To add/update translation: INSERT INTO translations (language_code, translation_key, translation_value)
