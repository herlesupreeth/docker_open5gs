CREATE TABLE `messages` (
    `id` INT(10) UNSIGNED AUTO_INCREMENT PRIMARY KEY NOT NULL,
    `caller` VARCHAR(255) NOT NULL,
    `callee` VARCHAR(255) NOT NULL,
    `text` VARCHAR(512),
    `dcs` INT(1),
    `valid` datetime NOT NULL
);

INSERT INTO version (table_name, table_version) values ('messages','1');
