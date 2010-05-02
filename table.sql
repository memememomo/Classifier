CREATE TABLE `category_count` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `category` varchar(255) DEFAULT NULL,
  `count` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `category_idx` (`category`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


CREATE TABLE `term_count` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `term` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `count` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `term_idx` (`term`),
  KEY `category_idx` (`category`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
