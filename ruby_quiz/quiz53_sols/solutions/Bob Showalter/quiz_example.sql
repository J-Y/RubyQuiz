CREATE TABLE `authors` (
  `id` int(11) NOT NULL auto_increment,
  `firstname` varchar(50) NOT NULL default '',
  `name` varchar(50) NOT NULL default '',
  `nickname` varchar(50) NOT NULL default '',
  `contact` varchar(50) NOT NULL default '',
  `password` varchar(50) NOT NULL default '',
  `description` text NOT NULL,
  PRIMARY KEY  (`id`)
) TYPE=MyISAM AUTO_INCREMENT=3 ;
  
CREATE TABLE `categories` (
  `id` int(11) NOT NULL auto_increment,
  `name` varchar(20) NOT NULL default '',
  `description` varchar(70) NOT NULL default '',
  PRIMARY KEY  (`id`)
) TYPE=MyISAM AUTO_INCREMENT=3 ;
  
CREATE TABLE `categories_documents` (
  `category_id` int(11) NOT NULL default '0',
  `document_id` int(11) NOT NULL default '0',
) TYPE=MyISAM ;
  
CREATE TABLE `documents` (
  `id` int(11) NOT NULL auto_increment,
  `title` varchar(50) NOT NULL default '',
  `description` text NOT NULL,
  `author_id` int(11) NOT NULL default '0',
  `date` date NOT NULL default '0000-00-00',
  `filename` varchar(50) NOT NULL default '',
  PRIMARY KEY  (`id`),
  KEY `document` (`title`)
) TYPE=MyISAM AUTO_INCREMENT=14 ;
