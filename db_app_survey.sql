-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Jul 02, 2025 at 03:24 PM
-- Server version: 8.0.41
-- PHP Version: 8.4.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `db_app_survey`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `HitungSkorKelayakan` (IN `p_id_penerima` INT)   BEGIN
    DECLARE skor_rumah INT DEFAULT 0;
    DECLARE skor_kend INT DEFAULT 0;
    DECLARE skor_income INT DEFAULT 0;
    DECLARE skor_asset INT DEFAULT 0;
    DECLARE skor_kel INT DEFAULT 0;
    DECLARE total INT DEFAULT 0;
    DECLARE kategori VARCHAR(20);
    
    -- Skor Rumah dan Tanah (0-25)
    SELECT 
        CASE 
            WHEN status_kepemilikan_rumah IN ('Menumpang', 'Kontrak/Sewa') THEN 25
            WHEN status_kepemilikan_rumah = 'Bebas Sewa' THEN 20
            WHEN status_kepemilikan_rumah = 'Rumah Dinas' THEN 15
            WHEN status_kepemilikan_rumah = 'Milik Sendiri' AND jenis_lantai = 'Tanah' THEN 15
            WHEN status_kepemilikan_rumah = 'Milik Sendiri' AND jenis_lantai IN ('Semen/Tegel', 'Kayu') THEN 10
            ELSE 5
        END INTO skor_rumah
    FROM status_rumah_tanah WHERE id_penerima = p_id_penerima;
    
    -- Skor Kendaraan (0-20)
    SELECT 
        CASE 
            WHEN jenis_kendaraan = 'Tidak Ada' THEN 20
            WHEN jenis_kendaraan IN ('Sepeda', 'Becak', 'Gerobak') THEN 15
            WHEN jenis_kendaraan = 'Sepeda Motor' AND tahun_pembuatan < YEAR(CURDATE()) - 10 THEN 10
            WHEN jenis_kendaraan = 'Sepeda Motor' AND tahun_pembuatan >= YEAR(CURDATE()) - 10 THEN 5
            WHEN jenis_kendaraan = 'Mobil' THEN 0
            ELSE 10
        END INTO skor_kend
    FROM kepemilikan_kendaraan WHERE id_penerima = p_id_penerima LIMIT 1;
    
    -- Skor Pendapatan (0-30)
    SELECT 
        CASE 
            WHEN total_pendapatan_bulanan <= 1000000 THEN 30
            WHEN total_pendapatan_bulanan <= 2000000 THEN 25
            WHEN total_pendapatan_bulanan <= 3000000 THEN 20
            WHEN total_pendapatan_bulanan <= 4000000 THEN 15
            WHEN total_pendapatan_bulanan <= 5000000 THEN 10
            ELSE 5
        END INTO skor_income
    FROM profesi_pendapatan WHERE id_penerima = p_id_penerima;
    
    -- Skor Aset (0-15)
    SELECT 
        CASE 
            WHEN COALESCE(SUM(nilai_estimasi), 0) <= 5000000 THEN 15
            WHEN COALESCE(SUM(nilai_estimasi), 0) <= 10000000 THEN 10
            WHEN COALESCE(SUM(nilai_estimasi), 0) <= 20000000 THEN 5
            ELSE 0
        END INTO skor_asset
    FROM aset_harta WHERE id_penerima = p_id_penerima;
    
    -- Skor Keluarga (0-10)
    SELECT 
        CASE 
            WHEN COUNT(*) >= 5 THEN 10
            WHEN COUNT(*) = 4 THEN 8
            WHEN COUNT(*) = 3 THEN 6
            WHEN COUNT(*) = 2 THEN 4
            ELSE 2
        END INTO skor_kel
    FROM data_keluarga WHERE id_kepala_keluarga = p_id_penerima;
    
    SET total = COALESCE(skor_rumah, 0) + COALESCE(skor_kend, 0) + COALESCE(skor_income, 0) + COALESCE(skor_asset, 0) + COALESCE(skor_kel, 0);
    
    -- Tentukan Kategori
    SET kategori = CASE 
        WHEN total >= 80 THEN 'Sangat Layak'
        WHEN total >= 65 THEN 'Layak'
        WHEN total >= 50 THEN 'Cukup Layak'
        WHEN total >= 35 THEN 'Kurang Layak'
        ELSE 'Tidak Layak'
    END;
    
    -- Insert atau Update Penilaian
    INSERT INTO penilaian_kelayakan (
        id_penerima, skor_rumah_tanah, skor_kendaraan, skor_pendapatan, 
        skor_aset, skor_keluarga, kategori_kelayakan, tanggal_survei
    ) VALUES (
        p_id_penerima, skor_rumah, skor_kend, skor_income, skor_asset, skor_kel, kategori, CURDATE()
    ) ON DUPLICATE KEY UPDATE
        skor_rumah_tanah = skor_rumah,
        skor_kendaraan = skor_kend,
        skor_pendapatan = skor_income,
        skor_aset = skor_asset,
        skor_keluarga = skor_kel,
        kategori_kelayakan = kategori,
        tanggal_survei = CURDATE();
        
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `aset_harta`
--

CREATE TABLE `aset_harta` (
  `id_aset` int NOT NULL,
  `id_penerima` int DEFAULT NULL,
  `jenis_aset` enum('Emas/Perhiasan','Tabungan/Deposito','Ternak','Kebun/Sawah','Elektronik','Lainnya') NOT NULL,
  `deskripsi_aset` varchar(100) DEFAULT NULL,
  `nilai_estimasi` decimal(12,2) DEFAULT '0.00',
  `satuan` varchar(20) DEFAULT NULL,
  `jumlah` int DEFAULT '1',
  `kondisi_aset` enum('Baik','Sedang','Rusak') DEFAULT 'Baik'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `aset_harta`
--

INSERT INTO `aset_harta` (`id_aset`, `id_penerima`, `jenis_aset`, `deskripsi_aset`, `nilai_estimasi`, `satuan`, `jumlah`, `kondisi_aset`) VALUES
(1, 1, 'Elektronik', 'TV 21 inch', 800000.00, 'unit', 1, 'Sedang'),
(2, 1, 'Elektronik', 'HP Android', 1200000.00, 'unit', 2, 'Baik'),
(3, 2, 'Ternak', 'Ayam Kampung', 750000.00, 'ekor', 15, 'Baik'),
(4, 2, 'Elektronik', 'TV 32 inch', 1500000.00, 'unit', 1, 'Baik'),
(5, 2, 'Kebun/Sawah', 'Sawah', 15000000.00, 'm2', 120, 'Baik'),
(6, 3, 'Elektronik', 'Laptop', 4000000.00, 'unit', 1, 'Baik'),
(7, 3, 'Emas/Perhiasan', 'Cincin Emas', 2500000.00, 'gram', 5, 'Baik'),
(8, 4, 'Elektronik', 'TV LED 43 inch', 3500000.00, 'unit', 1, 'Baik'),
(9, 4, 'Tabungan/Deposito', 'Tabungan Bank', 5000000.00, 'rupiah', 1, 'Baik'),
(10, 5, 'Ternak', 'Kambing', 2000000.00, 'ekor', 2, 'Baik'),
(11, 5, 'Elektronik', 'Radio', 150000.00, 'unit', 1, 'Sedang'),
(12, 6, 'Ternak', 'Sapi', 12000000.00, 'ekor', 1, 'Baik'),
(13, 6, 'Kebun/Sawah', 'Sawah', 20000000.00, 'm2', 200, 'Baik'),
(14, 6, 'Elektronik', 'TV 40 inch', 2500000.00, 'unit', 1, 'Baik'),
(15, 7, 'Elektronik', 'Laptop', 8000000.00, 'unit', 1, 'Baik'),
(16, 7, 'Tabungan/Deposito', 'Tabungan Bank', 15000000.00, 'rupiah', 1, 'Baik'),
(17, 7, 'Emas/Perhiasan', 'Kalung Emas', 3000000.00, 'gram', 3, 'Baik'),
(18, 8, 'Elektronik', 'Kulkas', 2000000.00, 'unit', 1, 'Baik'),
(19, 8, 'Elektronik', 'TV 32 inch', 1800000.00, 'unit', 1, 'Baik'),
(20, 9, 'Elektronik', 'HP Smartphone', 3000000.00, 'unit', 1, 'Baik'),
(21, 9, 'Tabungan/Deposito', 'Tabungan Bank', 8000000.00, 'rupiah', 1, 'Baik'),
(22, 10, 'Ternak', 'Ayam', 500000.00, 'ekor', 10, 'Baik'),
(23, 10, 'Elektronik', 'TV 24 inch', 1000000.00, 'unit', 1, 'Sedang');

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `calon_penerima`
--

CREATE TABLE `calon_penerima` (
  `id_penerima` int NOT NULL,
  `nik` varchar(16) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `tempat_lahir` varchar(50) DEFAULT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `jenis_kelamin` enum('L','P') NOT NULL,
  `agama` varchar(20) DEFAULT NULL,
  `pendidikan_terakhir` varchar(30) DEFAULT NULL,
  `no_telepon` varchar(15) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `status_perkawinan` enum('Belum Kawin','Kawin','Cerai Hidup','Cerai Mati') DEFAULT NULL,
  `alamat_lengkap` text,
  `rt` varchar(3) DEFAULT NULL,
  `rw` varchar(3) DEFAULT NULL,
  `kelurahan` varchar(50) DEFAULT NULL,
  `kecamatan` varchar(50) DEFAULT NULL,
  `kabupaten_kota` varchar(50) DEFAULT NULL,
  `provinsi` varchar(50) DEFAULT NULL,
  `kode_pos` varchar(5) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `calon_penerima`
--

INSERT INTO `calon_penerima` (`id_penerima`, `nik`, `nama_lengkap`, `tempat_lahir`, `tanggal_lahir`, `jenis_kelamin`, `agama`, `pendidikan_terakhir`, `no_telepon`, `email`, `status_perkawinan`, `alamat_lengkap`, `rt`, `rw`, `kelurahan`, `kecamatan`, `kabupaten_kota`, `provinsi`, `kode_pos`, `created_at`, `updated_at`) VALUES
(1, '3327154512850001', 'Siti Aisyah', 'Purbalingga', '1985-12-05', 'P', 'Islam', 'SMP', '081234567001', 'siti.aisyah@gmail.com', 'Kawin', 'Jl. Mawar No. 12', '001', '002', 'Purbalingga Lor', 'Purbalingga', 'Purbalingga', 'Jawa Tengah', '53311', '2025-06-10 16:25:47', '2025-07-02 07:37:11'),
(2, '3327156708780002', 'Bambang Sutrisno', 'Purbalingga', '1978-08-27', 'L', 'Islam', 'SMP', '081234567002', 'bambang.sutrisno@gmail.com', 'Kawin', 'Jl. Melati No. 5', '002', '001', 'Purbalingga Lor', 'Purbalingga', 'Purbalingga', 'Jawa Tengah', '53311', '2025-06-10 16:25:47', '2025-06-10 16:25:47'),
(3, '3327152301920003', 'Rini Handayani', 'Banyumas', '1992-01-23', 'P', 'Islam', 'SMA', '081234567003', 'rini.handayani@gmail.com', 'Cerai Hidup', 'Jl. Anggrek No. 8', '003', '002', 'Purbalingga Kidul', 'Purbalingga', 'Purbalingga', 'Jawa Tengah', '53312', '2025-06-10 16:25:47', '2025-06-10 16:25:47'),
(4, '3327151105880004', 'Agus Priyanto', 'Purbalingga', '1988-05-11', 'L', 'Islam', 'SMP', '081234567004', 'agus.priyanto@gmail.com', 'Kawin', 'Jl. Kenanga No. 15', '004', '002', 'Purbalingga Kidul', 'Purbalingga', 'Purbalingga', 'Jawa Tengah', '53312', '2025-06-10 16:25:47', '2025-06-10 16:25:47'),
(5, '3327153009750005', 'Dewi Sartika', 'Cilacap', '1975-09-30', 'P', 'Islam', 'Tidak Tamat SD', '081234567005', 'dewi.sartika@gmail.com', 'Kawin', 'Jl. Cempaka No. 3', '005', '003', 'Kembaran', 'Kembaran', 'Purbalingga', 'Jawa Tengah', '53313', '2025-06-10 16:25:47', '2025-06-10 16:25:47'),
(6, '3327152707820006', 'Joko Susilo', 'Purbalingga', '1982-07-27', 'L', 'Islam', 'SD', '081234567006', 'joko.susilo@gmail.com', 'Kawin', 'Jl. Dahlia No. 20', '006', '003', 'Kembaran', 'Kembaran', 'Purbalingga', 'Jawa Tengah', '53313', '2025-06-10 16:25:47', '2025-06-10 16:25:47'),
(7, '3327154411900007', 'Sri Wahyuni', 'Banjarnegara', '1990-11-04', 'P', 'Islam', 'SMA', '081234567007', 'sri.wahyuni@gmail.com', 'Kawin', 'Jl. Tulip No. 7', '001', '004', 'Bojongsari', 'Bojongsari', 'Purbalingga', 'Jawa Tengah', '53314', '2025-06-10 16:25:47', '2025-06-10 16:25:47'),
(8, '3327151508870008', 'Budi Santoso', 'Purbalingga', '1987-08-15', 'L', 'Islam', 'SMP', '081234567008', 'budi.santoso@gmail.com', 'Kawin', 'Jl. Sakura No. 11', '002', '004', 'Bojongsari', 'Bojongsari', 'Purbalingga', 'Jawa Tengah', '53314', '2025-06-10 16:25:47', '2025-06-10 16:25:47'),
(9, '3327156612950009', 'Lastri Wulandari', 'Purbalingga', '1995-12-26', 'P', 'Kristen', 'SMA', '081234567009', 'lastri.wulandari@gmail.com', 'Belum Kawin', 'Jl. Seruni No. 4', '003', '005', 'Kaligondang', 'Kaligondang', 'Purbalingga', 'Jawa Tengah', '53315', '2025-06-10 16:25:47', '2025-06-10 16:25:47'),
(10, '3327152203840010', 'Wahyu Hidayat', 'Kebumen', '1984-03-22', 'L', 'Islam', 'SD', '081234567010', 'wahyu.hidayat@gmail.com', 'Kawin', 'Jl. Kamboja No. 18', '004', '005', 'Kaligondang', 'Kaligondang', 'Purbalingga', 'Jawa Tengah', '53315', '2025-06-10 16:25:47', '2025-06-10 16:25:47');

-- --------------------------------------------------------

--
-- Table structure for table `data_keluarga`
--

CREATE TABLE `data_keluarga` (
  `id_keluarga` int NOT NULL,
  `id_kepala_keluarga` int DEFAULT NULL,
  `hubungan_keluarga` enum('Kepala Keluarga','Istri','Anak','Menantu','Cucu','Orang Tua','Mertua','Saudara','Lainnya') NOT NULL,
  `nama_anggota` varchar(100) NOT NULL,
  `nik_anggota` varchar(16) DEFAULT NULL,
  `jenis_kelamin` enum('L','P') NOT NULL,
  `tanggal_lahir` date DEFAULT NULL,
  `umur` int DEFAULT NULL,
  `status_kawin` enum('Belum Kawin','Kawin','Cerai Hidup','Cerai Mati') DEFAULT NULL,
  `pendidikan` enum('Tidak Sekolah','Belum Sekolah','TK','Tidak Tamat SD','SD','SMP','SMA','Diploma','S1','S2','S3') DEFAULT NULL,
  `pekerjaan` varchar(50) DEFAULT NULL,
  `status_kesehatan` enum('Sehat','Sakit Kronis','Disabilitas','Lainnya') DEFAULT 'Sehat',
  `kepemilikan_kartu_identitas` enum('Ada','Tidak Ada','Sedang Proses') DEFAULT 'Ada'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `data_keluarga`
--

INSERT INTO `data_keluarga` (`id_keluarga`, `id_kepala_keluarga`, `hubungan_keluarga`, `nama_anggota`, `nik_anggota`, `jenis_kelamin`, `tanggal_lahir`, `umur`, `status_kawin`, `pendidikan`, `pekerjaan`, `status_kesehatan`, `kepemilikan_kartu_identitas`) VALUES
(79, 1, 'Kepala Keluarga', 'Siti Aisyah', '3327154512850001', 'P', '1985-12-05', 39, 'Kawin', 'SD', 'Ibu Rumah Tangga', 'Sehat', 'Ada'),
(80, 1, 'Istri', 'Ahmad Wijaya', '3327151203810001', 'L', '1981-03-12', 44, 'Kawin', 'SMP', 'Buruh Bangunan', 'Sehat', 'Ada'),
(81, 1, 'Anak', 'Rina Wijaya', '3327154508050001', 'P', '2005-08-05', 19, 'Belum Kawin', 'SMA', 'Pelajar', 'Sehat', 'Ada'),
(82, 1, 'Anak', 'Doni Wijaya', '3327151209080001', 'L', '2008-09-12', 16, 'Belum Kawin', 'SMP', 'Pelajar', 'Sehat', 'Ada'),
(83, 1, 'Anak', 'Sari Wijaya', '3327152506120001', 'P', '2012-06-25', 12, 'Belum Kawin', 'SD', 'Pelajar', 'Sehat', 'Ada'),
(84, 2, 'Kepala Keluarga', 'Bambang Sutrisno', '3327156708780002', 'L', '1978-08-27', 46, 'Kawin', 'SMP', 'Buruh Tani', 'Sehat', 'Ada'),
(85, 2, 'Istri', 'Wati Susilowati', '3327154405820002', 'P', '1982-05-04', 43, 'Kawin', 'SD', 'Ibu Rumah Tangga', 'Sehat', 'Ada'),
(86, 2, 'Anak', 'Edi Sutrisno', '3327151107040002', 'L', '2004-07-11', 20, 'Belum Kawin', 'SMA', 'Pelajar', 'Sehat', 'Ada'),
(87, 2, 'Anak', 'Nina Sutrisno', '3327152208070002', 'P', '2007-08-22', 17, 'Belum Kawin', 'SMP', 'Pelajar', 'Sehat', 'Ada'),
(88, 3, 'Kepala Keluarga', 'Rini Handayani', '3327152301920003', 'P', '1992-01-23', 33, 'Cerai Hidup', 'SMA', 'Karyawan Toko', 'Sehat', 'Ada'),
(89, 3, 'Anak', 'Kevin Handayani', '3327151509130003', 'L', '2013-09-15', 11, 'Belum Kawin', 'SD', 'Pelajar', 'Sehat', 'Ada'),
(90, 3, 'Anak', 'Kiara Handayani', '3327152712160003', 'P', '2016-12-27', 8, 'Belum Kawin', 'TK', 'Pelajar', 'Sehat', 'Ada'),
(91, 4, 'Kepala Keluarga', 'Agus Priyanto', '3327151105880004', 'L', '1988-05-11', 37, 'Kawin', 'SMP', 'Tukang Ojek', 'Sehat', 'Ada'),
(92, 4, 'Istri', 'Lia Sari', '3327154410900004', 'P', '1990-10-04', 34, 'Kawin', 'SMA', 'Ibu Rumah Tangga', 'Sehat', 'Ada'),
(93, 4, 'Anak', 'Dimas Priyanto', '3327151801140004', 'L', '2014-01-18', 11, 'Belum Kawin', 'SD', 'Pelajar', 'Sehat', 'Ada'),
(94, 4, 'Anak', 'Dina Priyanto', '3327152905170004', 'P', '2017-05-29', 8, 'Belum Kawin', 'TK', 'Pelajar', 'Sehat', 'Ada'),
(95, 5, 'Kepala Keluarga', 'Dewi Sartika', '3327153009750005', 'P', '1975-09-30', 49, 'Kawin', 'Tidak Tamat SD', 'Buruh Cuci', 'Sakit Kronis', 'Ada'),
(96, 5, 'Istri', 'Suparman', '3327151407720005', 'L', '1972-07-14', 52, 'Kawin', 'SD', 'Buruh Bangunan', 'Sehat', 'Ada'),
(97, 5, 'Anak', 'Tono Suparman', '3327152203020005', 'L', '2002-03-22', 23, 'Belum Kawin', 'SMA', 'Pengangguran', 'Sehat', 'Ada'),
(98, 5, 'Anak', 'Tini Suparman', '3327151606060005', 'P', '2006-06-16', 18, 'Belum Kawin', 'SMP', 'Pelajar', 'Sehat', 'Ada'),
(99, 5, 'Anak', 'Tuti Suparman', '3327152409100005', 'P', '2010-09-24', 14, 'Belum Kawin', 'SD', 'Pelajar', 'Sehat', 'Ada'),
(100, 5, 'Cucu', 'Budi Kecil', '3327151208200005', 'L', '2020-08-12', 4, 'Belum Kawin', 'Belum Sekolah', 'Belum Bekerja', 'Sehat', 'Ada'),
(101, 6, 'Kepala Keluarga', 'Joko Susilo', '3327152707820006', 'L', '1982-07-27', 42, 'Kawin', 'SD', 'Petani', 'Sehat', 'Ada'),
(102, 6, 'Istri', 'Susi Rahayu', '3327152108840006', 'P', '1984-08-21', 40, 'Kawin', 'SMP', 'Ibu Rumah Tangga', 'Sehat', 'Ada'),
(103, 6, 'Anak', 'Jihan Susilo', '3327151103090006', 'P', '2009-03-11', 16, 'Belum Kawin', 'SMP', 'Pelajar', 'Sehat', 'Ada'),
(104, 6, 'Anak', 'Joko Jr', '3327152007120006', 'L', '2012-07-20', 12, 'Belum Kawin', 'SD', 'Pelajar', 'Sehat', 'Ada'),
(105, 7, 'Kepala Keluarga', 'Sri Wahyuni', '3327154411900007', 'P', '1990-11-04', 34, 'Kawin', 'SMA', 'Guru Honorer', 'Sehat', 'Ada'),
(106, 7, 'Istri', 'Hendra Kusuma', '3327151208870007', 'L', '1987-08-12', 37, 'Kawin', 'S1', 'Karyawan Swasta', 'Sehat', 'Ada'),
(107, 7, 'Anak', 'Aira Kusuma', '3327152505150007', 'P', '2015-05-25', 10, 'Belum Kawin', 'SD', 'Pelajar', 'Sehat', 'Ada'),
(108, 7, 'Anak', 'Arjun Kusuma', '3327151211180007', 'L', '2018-11-12', 6, 'Belum Kawin', 'TK', 'Pelajar', 'Sehat', 'Ada'),
(109, 8, 'Kepala Keluarga', 'Budi Santoso', '3327151508870008', 'L', '1987-08-15', 37, 'Kawin', 'SMP', 'Penjual Bakso', 'Sehat', 'Ada'),
(110, 8, 'Istri', 'Indah Permata', '3327152909880008', 'P', '1988-09-29', 36, 'Kawin', 'SMA', 'Ibu Rumah Tangga', 'Sehat', 'Ada'),
(111, 8, 'Anak', 'Bayu Santoso', '3327151605110008', 'L', '2011-05-16', 14, 'Belum Kawin', 'SMP', 'Pelajar', 'Sehat', 'Ada'),
(112, 9, 'Kepala Keluarga', 'Lastri Wulandari', '3327156612950009', 'P', '1995-12-26', 29, 'Belum Kawin', 'SMA', 'Kasir Minimarket', 'Sehat', 'Ada'),
(113, 10, 'Kepala Keluarga', 'Wahyu Hidayat', '3327152203840010', 'L', '1984-03-22', 41, 'Kawin', 'SD', 'Tukang Becak', 'Sehat', 'Ada'),
(114, 10, 'Istri', 'Ratna Sari', '3327154507860010', 'P', '1986-07-05', 38, 'Kawin', 'SD', 'Ibu Rumah Tangga', 'Sehat', 'Ada'),
(115, 10, 'Anak', 'Gilang Hidayat', '3327151409080010', 'L', '2008-09-14', 16, 'Belum Kawin', 'SMP', 'Pelajar', 'Sehat', 'Ada'),
(116, 10, 'Anak', 'Gita Hidayat', '3327152011110010', 'P', '2011-11-20', 13, 'Belum Kawin', 'SD', 'Pelajar', 'Sehat', 'Ada'),
(117, 10, 'Anak', 'Gina Hidayat', '3327151708150010', 'P', '2015-08-17', 9, 'Belum Kawin', 'TK', 'Pelajar', 'Sehat', 'Ada');

-- --------------------------------------------------------

--
-- Table structure for table `kepemilikan_kendaraan`
--

CREATE TABLE `kepemilikan_kendaraan` (
  `id_kendaraan` int NOT NULL,
  `id_penerima` int DEFAULT NULL,
  `jenis_kendaraan` enum('Sepeda Motor','Mobil','Sepeda','Becak','Gerobak','Tidak Ada') NOT NULL,
  `merek` varchar(30) DEFAULT NULL,
  `tahun_pembuatan` year DEFAULT NULL,
  `status_kepemilikan` enum('Milik Sendiri','Kredit/Cicilan','Pinjaman','Sewa') DEFAULT 'Milik Sendiri',
  `kondisi_kendaraan` enum('Baik','Sedang','Rusak') DEFAULT NULL,
  `digunakan_untuk` enum('Pribadi','Usaha','Keduanya') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `kepemilikan_kendaraan`
--

INSERT INTO `kepemilikan_kendaraan` (`id_kendaraan`, `id_penerima`, `jenis_kendaraan`, `merek`, `tahun_pembuatan`, `status_kepemilikan`, `kondisi_kendaraan`, `digunakan_untuk`) VALUES
(1, 1, 'Tidak Ada', NULL, NULL, NULL, NULL, NULL),
(2, 2, 'Sepeda Motor', 'Honda', '2015', 'Milik Sendiri', 'Sedang', 'Keduanya'),
(3, 3, 'Sepeda', 'Polygon', '2020', 'Milik Sendiri', 'Baik', 'Pribadi'),
(4, 4, 'Sepeda Motor', 'Yamaha', '2018', 'Kredit/Cicilan', 'Baik', 'Keduanya'),
(5, 5, 'Sepeda', 'United', '2019', 'Milik Sendiri', 'Sedang', 'Pribadi'),
(6, 6, 'Sepeda Motor', 'Honda', '2012', 'Milik Sendiri', 'Sedang', 'Usaha'),
(7, 7, 'Mobil', 'Toyota', '2010', 'Kredit/Cicilan', 'Baik', 'Pribadi'),
(8, 8, 'Sepeda Motor', 'Suzuki', '2016', 'Milik Sendiri', 'Baik', 'Keduanya'),
(9, 9, 'Sepeda Motor', 'Honda', '2021', 'Kredit/Cicilan', 'Baik', 'Pribadi'),
(10, 10, 'Becak', 'Lokal', '2018', 'Milik Sendiri', 'Baik', 'Usaha');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pengeluaran_bulanan`
--

CREATE TABLE `pengeluaran_bulanan` (
  `id_pengeluaran` int NOT NULL,
  `id_penerima` int DEFAULT NULL,
  `makanan_pokok` decimal(10,2) DEFAULT '0.00',
  `listrik` decimal(10,2) DEFAULT '0.00',
  `air` decimal(10,2) DEFAULT '0.00',
  `gas` decimal(10,2) DEFAULT '0.00',
  `transportasi` decimal(10,2) DEFAULT '0.00',
  `pendidikan` decimal(10,2) DEFAULT '0.00',
  `kesehatan` decimal(10,2) DEFAULT '0.00',
  `komunikasi` decimal(10,2) DEFAULT '0.00',
  `lain_lain` decimal(10,2) DEFAULT '0.00',
  `total_pengeluaran` decimal(12,2) GENERATED ALWAYS AS (((((((((`makanan_pokok` + `listrik`) + `air`) + `gas`) + `transportasi`) + `pendidikan`) + `kesehatan`) + `komunikasi`) + `lain_lain`)) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `pengeluaran_bulanan`
--

INSERT INTO `pengeluaran_bulanan` (`id_pengeluaran`, `id_penerima`, `makanan_pokok`, `listrik`, `air`, `gas`, `transportasi`, `pendidikan`, `kesehatan`, `komunikasi`, `lain_lain`) VALUES
(1, 1, 800000.00, 75000.00, 25000.00, 35000.00, 100000.00, 150000.00, 50000.00, 50000.00, 100000.00),
(2, 2, 1200000.00, 100000.00, 30000.00, 40000.00, 150000.00, 200000.00, 75000.00, 75000.00, 150000.00),
(3, 3, 900000.00, 120000.00, 80000.00, 45000.00, 200000.00, 300000.00, 100000.00, 100000.00, 200000.00),
(4, 4, 1000000.00, 90000.00, 35000.00, 40000.00, 180000.00, 250000.00, 80000.00, 80000.00, 120000.00),
(5, 5, 700000.00, 50000.00, 20000.00, 30000.00, 80000.00, 100000.00, 150000.00, 30000.00, 80000.00),
(6, 6, 1100000.00, 85000.00, 25000.00, 35000.00, 120000.00, 180000.00, 100000.00, 60000.00, 140000.00),
(7, 7, 1500000.00, 150000.00, 100000.00, 60000.00, 250000.00, 400000.00, 150000.00, 120000.00, 300000.00),
(8, 8, 850000.00, 80000.00, 30000.00, 35000.00, 120000.00, 200000.00, 70000.00, 70000.00, 100000.00),
(9, 9, 1200000.00, 100000.00, 60000.00, 45000.00, 150000.00, 0.00, 80000.00, 100000.00, 150000.00),
(10, 10, 750000.00, 60000.00, 25000.00, 30000.00, 100000.00, 180000.00, 80000.00, 50000.00, 100000.00);

-- --------------------------------------------------------

--
-- Table structure for table `penilaian_kelayakan`
--

CREATE TABLE `penilaian_kelayakan` (
  `id_penilaian` int NOT NULL,
  `id_penerima` int DEFAULT NULL,
  `skor_rumah_tanah` int DEFAULT '0',
  `skor_kendaraan` int DEFAULT '0',
  `skor_pendapatan` int DEFAULT '0',
  `skor_aset` int DEFAULT '0',
  `skor_keluarga` int DEFAULT '0',
  `total_skor` int GENERATED ALWAYS AS (((((`skor_rumah_tanah` + `skor_kendaraan`) + `skor_pendapatan`) + `skor_aset`) + `skor_keluarga`)) STORED,
  `kategori_kelayakan` enum('Sangat Layak','Layak','Cukup Layak','Kurang Layak','Tidak Layak') DEFAULT NULL,
  `rekomendasi` text,
  `status_verifikasi` enum('Belum Diverifikasi','Sedang Diverifikasi','Terverifikasi','Ditolak') DEFAULT 'Belum Diverifikasi',
  `tanggal_survei` date DEFAULT NULL,
  `surveyor` varchar(100) DEFAULT NULL,
  `catatan_surveyor` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `penilaian_kelayakan`
--

INSERT INTO `penilaian_kelayakan` (`id_penilaian`, `id_penerima`, `skor_rumah_tanah`, `skor_kendaraan`, `skor_pendapatan`, `skor_aset`, `skor_keluarga`, `kategori_kelayakan`, `rekomendasi`, `status_verifikasi`, `tanggal_survei`, `surveyor`, `catatan_surveyor`) VALUES
(1, 1, 25, 20, 30, 15, 10, 'Sangat Layak', 'Sangat membutuhkan bantuan. Keluarga menumpang dan pendapatan sangat rendah.', 'Terverifikasi', '2025-06-11', 'Tim Survei Desa A', 'Keluarga tinggal menumpang di rumah saudara, pekerjaan tidak tetap, memiliki 3 anak sekolah.'),
(2, 2, 15, 5, 25, 5, 8, 'Cukup Layak', 'Layak mendapat bantuan. Rumah sederhana dan pendapatan rendah.', 'Terverifikasi', '2025-06-11', 'Tim Survei Desa A', 'Rumah milik sendiri kondisi sederhana, buruh tani dengan penghasilan tidak menentu.'),
(3, 3, 25, 15, 25, 10, 6, 'Sangat Layak', 'Perlu bantuan pendidikan anak. Single parent dengan beban keluarga.', 'Terverifikasi', '2025-06-11', 'Tim Survei Desa B', 'Ibu tunggal dengan 2 anak, bekerja sebagai karyawan toko dengan gaji pas-pasan.'),
(4, 4, 10, 5, 25, 10, 8, 'Cukup Layak', 'Layak mendapat bantuan. Penghasilan tidak stabil sebagai tukang ojek.', 'Terverifikasi', '2025-06-11', 'Tim Survei Desa B', 'Tukang ojek dengan penghasilan harian tidak menentu, memiliki 2 anak kecil.'),
(5, 5, 15, 15, 30, 15, 10, 'Sangat Layak', 'Sangat membutuhkan bantuan kesehatan dan pendidikan. Kondisi rumah sangat sederhana.', 'Terverifikasi', '2025-06-11', 'Tim Survei Desa C', 'Kepala keluarga sakit kronis, rumah sangat sederhana, banyak tanggungan keluarga.'),
(6, 6, 10, 10, 25, 0, 8, 'Cukup Layak', 'Layak bantuan modal usaha tani. Petani dengan lahan terbatas.', 'Terverifikasi', '2025-06-11', 'Tim Survei Desa C', 'Petani dengan lahan sendiri, namun hasil panen bergantung musim.'),
(7, 7, 20, 0, 20, 0, 8, 'Kurang Layak', 'Kurang prioritas. Pendapatan cukup stabil sebagai guru.', 'Terverifikasi', '2025-06-11', 'Tim Survei Desa D', 'Guru honorer dengan penghasilan tetap, kondisi rumah dan aset cukup baik.'),
(8, 8, 10, 5, 30, 15, 6, 'Layak', 'Layak bantuan modal usaha. Penjual bakso dengan penghasilan tidak stabil.', 'Terverifikasi', '2025-06-11', 'Tim Survei Desa D', 'Penjual bakso keliling, penghasilan bergantung cuaca dan kondisi pasar.'),
(9, 9, 25, 5, 25, 5, 2, 'Cukup Layak', 'Kurang prioritas. Belum berkeluarga dan bekerja tetap.', 'Terverifikasi', '2025-06-11', 'Tim Survei Desa E', 'Masih lajang, bekerja sebagai kasir dengan gaji tetap.'),
(10, 10, 15, 15, 30, 15, 10, 'Sangat Layak', 'Sangat membutuhkan bantuan. Tukang becak dengan banyak tanggungan.', 'Terverifikasi', '2025-06-11', 'Tim Survei Desa E', 'Tukang becak dengan 3 anak, penghasilan harian tidak menentu.');

-- --------------------------------------------------------

--
-- Table structure for table `profesi_pendapatan`
--

CREATE TABLE `profesi_pendapatan` (
  `id_profesi` int NOT NULL,
  `id_penerima` int DEFAULT NULL,
  `pekerjaan_utama` varchar(50) NOT NULL,
  `jenis_pekerjaan` enum('Tetap','Tidak Tetap','Musiman','Harian') NOT NULL,
  `pendapatan_bulanan` decimal(12,2) DEFAULT '0.00',
  `pekerjaan_sampingan` varchar(50) DEFAULT NULL,
  `pendapatan_sampingan` decimal(12,2) DEFAULT '0.00',
  `total_pendapatan_bulanan` decimal(12,2) GENERATED ALWAYS AS ((`pendapatan_bulanan` + `pendapatan_sampingan`)) STORED,
  `sektor_usaha` enum('Pertanian','Perikanan','Peternakan','Industri','Perdagangan','Jasa','Lainnya') DEFAULT NULL,
  `lokasi_kerja` varchar(100) DEFAULT NULL,
  `jam_kerja_per_hari` int DEFAULT '8',
  `hari_kerja_per_minggu` int DEFAULT '6'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `profesi_pendapatan`
--

INSERT INTO `profesi_pendapatan` (`id_profesi`, `id_penerima`, `pekerjaan_utama`, `jenis_pekerjaan`, `pendapatan_bulanan`, `pekerjaan_sampingan`, `pendapatan_sampingan`, `sektor_usaha`, `lokasi_kerja`, `jam_kerja_per_hari`, `hari_kerja_per_minggu`) VALUES
(1, 1, 'Ibu Rumah Tangga', 'Tidak Tetap', 0.00, 'Jualan Gorengan', 300000.00, 'Perdagangan', 'Rumah', 4, 7),
(2, 2, 'Buruh Tani', 'Harian', 800000.00, 'Tukang Bangunan', 400000.00, 'Pertanian', 'Sawah Desa', 8, 6),
(3, 3, 'Karyawan Toko', 'Tetap', 1500000.00, NULL, 0.00, 'Perdagangan', 'Pasar Tradisional', 10, 6),
(4, 4, 'Tukang Ojek', 'Harian', 1200000.00, 'Cuci Motor', 200000.00, 'Jasa', 'Terminal', 12, 7),
(5, 5, 'Buruh Cuci', 'Tidak Tetap', 600000.00, 'Penjual Sayur', 250000.00, 'Jasa', 'Rumah Tangga', 6, 5),
(6, 6, 'Petani', 'Musiman', 1000000.00, 'Ternak Ayam', 300000.00, 'Pertanian', 'Sawah Sendiri', 8, 7),
(7, 7, 'Guru Honorer', 'Tetap', 2500000.00, 'Les Privat', 500000.00, 'Jasa', 'SD Negeri', 8, 5),
(8, 8, 'Penjual Bakso', 'Harian', 900000.00, NULL, 0.00, 'Perdagangan', 'Keliling', 10, 7),
(9, 9, 'Kasir Minimarket', 'Tetap', 1800000.00, NULL, 0.00, 'Perdagangan', 'Indomaret', 8, 6),
(10, 10, 'Tukang Becak', 'Harian', 700000.00, 'Kuli Panggul', 200000.00, 'Jasa', 'Pasar', 10, 7);

-- --------------------------------------------------------

--
-- Table structure for table `riwayat_bantuan`
--

CREATE TABLE `riwayat_bantuan` (
  `id_bantuan` int NOT NULL,
  `id_penerima` int DEFAULT NULL,
  `nama_program` varchar(100) NOT NULL,
  `tahun_terima` year NOT NULL,
  `nilai_bantuan` decimal(12,2) DEFAULT NULL,
  `status_bantuan` enum('Sedang Berjalan','Selesai','Dihentikan') DEFAULT 'Selesai',
  `sumber_bantuan` enum('Pemerintah Pusat','Pemerintah Daerah','Swasta','NGO','Lainnya') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `riwayat_bantuan`
--

INSERT INTO `riwayat_bantuan` (`id_bantuan`, `id_penerima`, `nama_program`, `tahun_terima`, `nilai_bantuan`, `status_bantuan`, `sumber_bantuan`) VALUES
(1, 1, 'Program Keluarga Harapan (PKH)', '2023', 3000000.00, 'Sedang Berjalan', 'Pemerintah Pusat'),
(2, 1, 'Bantuan Langsung Tunai (BLT)', '2022', 1200000.00, 'Selesai', 'Pemerintah Daerah'),
(3, 2, 'Bantuan Pangan Non Tunai (BPNT)', '2023', 1800000.00, 'Sedang Berjalan', 'Pemerintah Pusat'),
(4, 3, 'Program Indonesia Pintar (PIP)', '2023', 2250000.00, 'Sedang Berjalan', 'Pemerintah Pusat'),
(5, 4, 'Bantuan Langsung Tunai (BLT)', '2022', 1200000.00, 'Selesai', 'Pemerintah Daerah'),
(6, 5, 'Program Keluarga Harapan (PKH)', '2023', 3750000.00, 'Sedang Berjalan', 'Pemerintah Pusat'),
(7, 5, 'Bantuan Sosial Tunai', '2021', 2400000.00, 'Selesai', 'Pemerintah Daerah'),
(8, 6, 'Bantuan Pupuk Bersubsidi', '2023', 800000.00, 'Sedang Berjalan', 'Pemerintah Pusat'),
(9, 8, 'Bantuan Modal Usaha Mikro', '2022', 5000000.00, 'Selesai', 'Pemerintah Daerah'),
(10, 10, 'Program Keluarga Harapan (PKH)', '2023', 3000000.00, 'Sedang Berjalan', 'Pemerintah Pusat');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('9UYn4c6f2GflmySxIvFs6ONKDvXbagwkFqPiQIq3', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', 'YTozOntzOjk6Il9wcmV2aW91cyI7YToxOntzOjM6InVybCI7czoyNzoiaHR0cDovLzEyNy4wLjAuMTo4MDAwL2xvZ2luIjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo2OiJfdG9rZW4iO3M6NDA6ImhZeUllRktFdmVhQmVWUnRVaUpmbjRVc3FMSm1Rd0Z2bFRzY1JHVDgiO30=', 1751468317),
('bX33GtdGjZvYMzY77r6wbElcd3R6SyXG0fhUTZmx', 1, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36', 'YTo0OntzOjk6Il9wcmV2aW91cyI7YToxOntzOjM6InVybCI7czozMToiaHR0cDovLzEyNy4wLjAuMTo4MDAwL2Rhc2hib2FyZCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NjoiX3Rva2VuIjtzOjQwOiIxZjZ6RTdIYnJIT1JJRm01eUk5ak9ScUJtYjVTdlJYaVlLQk45ZFkyIjtzOjUwOiJsb2dpbl93ZWJfNTliYTM2YWRkYzJiMmY5NDAxNTgwZjAxNGM3ZjU4ZWE0ZTMwOTg5ZCI7aToxO30=', 1751454721);

-- --------------------------------------------------------

--
-- Table structure for table `status_rumah_tanah`
--

CREATE TABLE `status_rumah_tanah` (
  `id_rumah_tanah` int NOT NULL,
  `id_penerima` int DEFAULT NULL,
  `status_kepemilikan_rumah` enum('Milik Sendiri','Kontrak/Sewa','Menumpang','Bebas Sewa','Rumah Dinas') NOT NULL,
  `luas_rumah` decimal(10,2) DEFAULT NULL,
  `jenis_lantai` enum('Tanah','Semen/Tegel','Keramik','Kayu','Lainnya') DEFAULT NULL,
  `jenis_dinding` enum('Bambu','Kayu','Tembok Batako','Tembok Batu Bata','Lainnya') DEFAULT NULL,
  `jenis_atap` enum('Rumbia/Ilalang','Seng','Genteng','Beton/Cor','Lainnya') DEFAULT NULL,
  `sumber_air` enum('PDAM','Sumur Bor','Sumur Gali','Mata Air','Air Hujan','Lainnya') DEFAULT NULL,
  `sumber_penerangan` enum('PLN','Non PLN','Tidak Ada') DEFAULT NULL,
  `bahan_bakar_memasak` enum('Gas 3kg','Gas 12kg','Kayu Bakar','Minyak Tanah','Listrik','Lainnya') DEFAULT NULL,
  `fasilitas_buang_air` enum('Sendiri','Bersama','Umum','Tidak Ada') DEFAULT NULL,
  `status_kepemilikan_tanah` enum('Milik Sendiri','Milik Orang Lain','Tanah Negara','Lainnya') DEFAULT NULL,
  `luas_tanah` decimal(10,2) DEFAULT NULL,
  `bukti_kepemilikan` enum('SHM','SHGB','Girik','Petok D','Tidak Ada','Lainnya') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `status_rumah_tanah`
--

INSERT INTO `status_rumah_tanah` (`id_rumah_tanah`, `id_penerima`, `status_kepemilikan_rumah`, `luas_rumah`, `jenis_lantai`, `jenis_dinding`, `jenis_atap`, `sumber_air`, `sumber_penerangan`, `bahan_bakar_memasak`, `fasilitas_buang_air`, `status_kepemilikan_tanah`, `luas_tanah`, `bukti_kepemilikan`) VALUES
(1, 1, 'Menumpang', 36.00, 'Semen/Tegel', 'Tembok Batako', 'Genteng', 'Sumur Gali', 'PLN', 'Kayu Bakar', 'Bersama', 'Milik Orang Lain', 0.00, 'Tidak Ada'),
(2, 2, 'Milik Sendiri', 45.00, 'Tanah', 'Bambu', 'Seng', 'Sumur Gali', 'PLN', 'Kayu Bakar', 'Sendiri', 'Milik Sendiri', 120.00, 'Girik'),
(3, 3, 'Kontrak/Sewa', 54.00, 'Semen/Tegel', 'Tembok Batako', 'Genteng', 'PDAM', 'PLN', 'Gas 3kg', 'Sendiri', 'Milik Orang Lain', 0.00, 'Tidak Ada'),
(4, 4, 'Milik Sendiri', 42.00, 'Semen/Tegel', 'Tembok Batu Bata', 'Genteng', 'Sumur Bor', 'PLN', 'Gas 3kg', 'Sendiri', 'Milik Sendiri', 150.00, 'Petok D'),
(5, 5, 'Milik Sendiri', 30.00, 'Tanah', 'Bambu', 'Rumbia/Ilalang', 'Mata Air', 'Non PLN', 'Kayu Bakar', 'Umum', 'Milik Sendiri', 80.00, 'Girik'),
(6, 6, 'Milik Sendiri', 48.00, 'Semen/Tegel', 'Tembok Batako', 'Seng', 'Sumur Gali', 'PLN', 'Kayu Bakar', 'Sendiri', 'Milik Sendiri', 200.00, 'SHM'),
(7, 7, 'Bebas Sewa', 60.00, 'Keramik', 'Tembok Batu Bata', 'Genteng', 'PDAM', 'PLN', 'Gas 12kg', 'Sendiri', 'Milik Orang Lain', 0.00, 'Tidak Ada'),
(8, 8, 'Milik Sendiri', 38.00, 'Semen/Tegel', 'Tembok Batako', 'Genteng', 'Sumur Gali', 'PLN', 'Gas 3kg', 'Sendiri', 'Milik Sendiri', 100.00, 'Girik'),
(9, 9, 'Kontrak/Sewa', 50.00, 'Keramik', 'Tembok Batu Bata', 'Genteng', 'PDAM', 'PLN', 'Gas 3kg', 'Sendiri', 'Milik Orang Lain', 0.00, 'Tidak Ada'),
(10, 10, 'Milik Sendiri', 35.00, 'Tanah', 'Kayu', 'Seng', 'Sumur Gali', 'PLN', 'Kayu Bakar', 'Bersama', 'Milik Sendiri', 90.00, 'Petok D');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Admin Survey 1', 'admin@survey.com', '2025-07-02 02:12:36', '$2y$12$uGo3PWA03jHfNws4PNh8YOAohwTUdmRBO1xP.OQAbkLFJRdqrll.e', 'nqWynsuh3dycI6LIdfkOV5ktI1f49fZb9aASbLIsLRnssfX5MD3rbqnrtgVa', '2025-07-02 02:12:37', '2025-07-02 02:12:37');

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_ringkasan_penerima`
-- (See below for the actual view)
--
CREATE TABLE `view_ringkasan_penerima` (
`id_penerima` int
,`nik` varchar(16)
,`nama_lengkap` varchar(100)
,`alamat_lengkap` text
,`kelurahan` varchar(50)
,`kecamatan` varchar(50)
,`umur` varchar(27)
,`status_kepemilikan_rumah` enum('Milik Sendiri','Kontrak/Sewa','Menumpang','Bebas Sewa','Rumah Dinas')
,`jenis_lantai` enum('Tanah','Semen/Tegel','Keramik','Kayu','Lainnya')
,`sumber_air` enum('PDAM','Sumur Bor','Sumur Gali','Mata Air','Air Hujan','Lainnya')
,`pekerjaan_utama` varchar(50)
,`total_pendapatan_bulanan` decimal(12,2)
,`jumlah_anggota_keluarga` bigint
,`jumlah_anak` bigint
,`total_skor` int
,`kategori_kelayakan` enum('Sangat Layak','Layak','Cukup Layak','Kurang Layak','Tidak Layak')
,`status_verifikasi` enum('Belum Diverifikasi','Sedang Diverifikasi','Terverifikasi','Ditolak')
);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `aset_harta`
--
ALTER TABLE `aset_harta`
  ADD PRIMARY KEY (`id_aset`),
  ADD KEY `id_penerima` (`id_penerima`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`);

--
-- Indexes for table `calon_penerima`
--
ALTER TABLE `calon_penerima`
  ADD PRIMARY KEY (`id_penerima`),
  ADD UNIQUE KEY `nik` (`nik`),
  ADD KEY `idx_penerima_nik` (`nik`),
  ADD KEY `idx_penerima_nama` (`nama_lengkap`);

--
-- Indexes for table `data_keluarga`
--
ALTER TABLE `data_keluarga`
  ADD PRIMARY KEY (`id_keluarga`),
  ADD KEY `idx_keluarga_kepala` (`id_kepala_keluarga`);

--
-- Indexes for table `kepemilikan_kendaraan`
--
ALTER TABLE `kepemilikan_kendaraan`
  ADD PRIMARY KEY (`id_kendaraan`),
  ADD KEY `id_penerima` (`id_penerima`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `pengeluaran_bulanan`
--
ALTER TABLE `pengeluaran_bulanan`
  ADD PRIMARY KEY (`id_pengeluaran`),
  ADD KEY `id_penerima` (`id_penerima`);

--
-- Indexes for table `penilaian_kelayakan`
--
ALTER TABLE `penilaian_kelayakan`
  ADD PRIMARY KEY (`id_penilaian`),
  ADD KEY `id_penerima` (`id_penerima`),
  ADD KEY `idx_penilaian_skor` (`total_skor`),
  ADD KEY `idx_penilaian_kategori` (`kategori_kelayakan`);

--
-- Indexes for table `profesi_pendapatan`
--
ALTER TABLE `profesi_pendapatan`
  ADD PRIMARY KEY (`id_profesi`),
  ADD KEY `id_penerima` (`id_penerima`);

--
-- Indexes for table `riwayat_bantuan`
--
ALTER TABLE `riwayat_bantuan`
  ADD PRIMARY KEY (`id_bantuan`),
  ADD KEY `id_penerima` (`id_penerima`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `status_rumah_tanah`
--
ALTER TABLE `status_rumah_tanah`
  ADD PRIMARY KEY (`id_rumah_tanah`),
  ADD KEY `id_penerima` (`id_penerima`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `aset_harta`
--
ALTER TABLE `aset_harta`
  MODIFY `id_aset` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `calon_penerima`
--
ALTER TABLE `calon_penerima`
  MODIFY `id_penerima` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `data_keluarga`
--
ALTER TABLE `data_keluarga`
  MODIFY `id_keluarga` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT for table `kepemilikan_kendaraan`
--
ALTER TABLE `kepemilikan_kendaraan`
  MODIFY `id_kendaraan` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `pengeluaran_bulanan`
--
ALTER TABLE `pengeluaran_bulanan`
  MODIFY `id_pengeluaran` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `penilaian_kelayakan`
--
ALTER TABLE `penilaian_kelayakan`
  MODIFY `id_penilaian` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `profesi_pendapatan`
--
ALTER TABLE `profesi_pendapatan`
  MODIFY `id_profesi` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `riwayat_bantuan`
--
ALTER TABLE `riwayat_bantuan`
  MODIFY `id_bantuan` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `status_rumah_tanah`
--
ALTER TABLE `status_rumah_tanah`
  MODIFY `id_rumah_tanah` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

-- --------------------------------------------------------

--
-- Structure for view `view_ringkasan_penerima`
--
DROP TABLE IF EXISTS `view_ringkasan_penerima`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_ringkasan_penerima`  AS SELECT `cp`.`id_penerima` AS `id_penerima`, `cp`.`nik` AS `nik`, `cp`.`nama_lengkap` AS `nama_lengkap`, `cp`.`alamat_lengkap` AS `alamat_lengkap`, `cp`.`kelurahan` AS `kelurahan`, `cp`.`kecamatan` AS `kecamatan`, concat(timestampdiff(YEAR,`cp`.`tanggal_lahir`,curdate()),' tahun') AS `umur`, `srt`.`status_kepemilikan_rumah` AS `status_kepemilikan_rumah`, `srt`.`jenis_lantai` AS `jenis_lantai`, `srt`.`sumber_air` AS `sumber_air`, `pp`.`pekerjaan_utama` AS `pekerjaan_utama`, `pp`.`total_pendapatan_bulanan` AS `total_pendapatan_bulanan`, (select count(0) from `data_keluarga` `dk` where (`dk`.`id_kepala_keluarga` = `cp`.`id_penerima`)) AS `jumlah_anggota_keluarga`, (select count(0) from `data_keluarga` `dk` where ((`dk`.`id_kepala_keluarga` = `cp`.`id_penerima`) and (`dk`.`umur` < 18))) AS `jumlah_anak`, `pk`.`total_skor` AS `total_skor`, `pk`.`kategori_kelayakan` AS `kategori_kelayakan`, `pk`.`status_verifikasi` AS `status_verifikasi` FROM (((`calon_penerima` `cp` left join `status_rumah_tanah` `srt` on((`cp`.`id_penerima` = `srt`.`id_penerima`))) left join `profesi_pendapatan` `pp` on((`cp`.`id_penerima` = `pp`.`id_penerima`))) left join `penilaian_kelayakan` `pk` on((`cp`.`id_penerima` = `pk`.`id_penerima`))) ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `aset_harta`
--
ALTER TABLE `aset_harta`
  ADD CONSTRAINT `aset_harta_ibfk_1` FOREIGN KEY (`id_penerima`) REFERENCES `calon_penerima` (`id_penerima`);

--
-- Constraints for table `data_keluarga`
--
ALTER TABLE `data_keluarga`
  ADD CONSTRAINT `data_keluarga_ibfk_1` FOREIGN KEY (`id_kepala_keluarga`) REFERENCES `calon_penerima` (`id_penerima`);

--
-- Constraints for table `kepemilikan_kendaraan`
--
ALTER TABLE `kepemilikan_kendaraan`
  ADD CONSTRAINT `kepemilikan_kendaraan_ibfk_1` FOREIGN KEY (`id_penerima`) REFERENCES `calon_penerima` (`id_penerima`);

--
-- Constraints for table `pengeluaran_bulanan`
--
ALTER TABLE `pengeluaran_bulanan`
  ADD CONSTRAINT `pengeluaran_bulanan_ibfk_1` FOREIGN KEY (`id_penerima`) REFERENCES `calon_penerima` (`id_penerima`);

--
-- Constraints for table `penilaian_kelayakan`
--
ALTER TABLE `penilaian_kelayakan`
  ADD CONSTRAINT `penilaian_kelayakan_ibfk_1` FOREIGN KEY (`id_penerima`) REFERENCES `calon_penerima` (`id_penerima`);

--
-- Constraints for table `profesi_pendapatan`
--
ALTER TABLE `profesi_pendapatan`
  ADD CONSTRAINT `profesi_pendapatan_ibfk_1` FOREIGN KEY (`id_penerima`) REFERENCES `calon_penerima` (`id_penerima`);

--
-- Constraints for table `riwayat_bantuan`
--
ALTER TABLE `riwayat_bantuan`
  ADD CONSTRAINT `riwayat_bantuan_ibfk_1` FOREIGN KEY (`id_penerima`) REFERENCES `calon_penerima` (`id_penerima`);

--
-- Constraints for table `status_rumah_tanah`
--
ALTER TABLE `status_rumah_tanah`
  ADD CONSTRAINT `status_rumah_tanah_ibfk_1` FOREIGN KEY (`id_penerima`) REFERENCES `calon_penerima` (`id_penerima`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
