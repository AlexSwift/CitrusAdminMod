-- phpMyAdmin SQL Dump
-- version 2.11.6
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jun 29, 2008 at 07:44 PM
-- Server version: 5.0.51
-- PHP Version: 5.2.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `kudomiku_citrus`
--

-- --------------------------------------------------------

--
-- Table structure for table `Bans`
--

CREATE TABLE IF NOT EXISTS `Bans` (
  `_Key` int(255) NOT NULL auto_increment,
  `_SteamID` varchar(255) NOT NULL,
  `_IPAddress` varchar(255) NOT NULL,
  `_Enforcer` varchar(255) NOT NULL,
  `_Duration` varchar(255) NOT NULL,
  `_Reason` varchar(255) NOT NULL,
  `_Group` varchar(255) NOT NULL,
  `_Name` varchar(255) NOT NULL,
  `_Status` varchar(255) NOT NULL,
  PRIMARY KEY  (`_Key`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Dumping data for table `Bans`
--

