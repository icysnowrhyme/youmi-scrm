-- MySQL dump 10.13  Distrib 8.0.39, for Linux (x86_64)
--
-- Host: localhost    Database: youmi_scrm
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `youmi_scrm`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `youmi_scrm` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `youmi_scrm`;

--
-- Table structure for table `biz_campaign`
--

DROP TABLE IF EXISTS `biz_campaign`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_campaign` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(128) NOT NULL COMMENT '活动名称',
  `type` tinyint DEFAULT '1' COMMENT '类型(1-线上活动 2-线下活动 3-广告投放 4-内容营销)',
  `channel` varchar(64) DEFAULT NULL COMMENT '投放渠道',
  `budget` decimal(12,2) DEFAULT '0.00' COMMENT '活动预算',
  `start_date` date DEFAULT NULL COMMENT '开始日期',
  `end_date` date DEFAULT NULL COMMENT '结束日期',
  `status` tinyint DEFAULT '0' COMMENT '状态(0-未开始 1-进行中 2-已结束)',
  `target_count` int DEFAULT '0' COMMENT '目标线索数',
  `lead_count` int DEFAULT '0' COMMENT '实际线索数',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人ID',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='营销活动表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_campaign`
--

LOCK TABLES `biz_campaign` WRITE;
/*!40000 ALTER TABLE `biz_campaign` DISABLE KEYS */;
INSERT INTO `biz_campaign` VALUES (1,'2025 夏季私域增长峰会',2,'线下会议',50000.00,'2026-09-05','2026-09-10',2,200,236,1,'线索转化率 18%',1,'2026-08-11 10:27:23',1,'2026-09-10 10:27:23',0),(2,'SCRM 免费试用直播课',1,'视频号直播',12000.00,'2026-09-30','2026-09-30',2,500,682,2,'回放持续获客',2,'2026-09-20 10:27:23',2,'2026-09-30 10:27:23',0),(3,'百度 SEM 品牌词投放',3,'百度推广',80000.00,'2026-10-08','2026-11-07',1,300,154,2,'线索成本 128 元',2,'2026-10-08 10:27:23',2,'2026-10-19 10:27:23',0),(4,'客户成功案例拆解专栏',4,'公众号',8000.00,'2026-08-21','2026-11-19',1,150,97,4,'每周一篇',4,'2026-08-21 10:27:23',4,'2026-10-18 10:27:23',0),(5,'秋季行业客户答谢会',2,'线下晚宴',120000.00,'2026-11-19','2026-11-19',0,100,0,1,'筹备中',1,'2026-10-15 10:27:23',1,'2026-10-15 10:27:23',0);
/*!40000 ALTER TABLE `biz_campaign` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_contract`
--

DROP TABLE IF EXISTS `biz_contract`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_contract` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `contract_no` varchar(50) NOT NULL COMMENT '合同编号',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `opportunity_id` bigint DEFAULT NULL COMMENT '关联商机ID',
  `name` varchar(128) NOT NULL COMMENT '合同名称',
  `amount` decimal(12,2) DEFAULT '0.00' COMMENT '合同金额',
  `sign_date` date DEFAULT NULL COMMENT '签订日期',
  `start_date` date DEFAULT NULL COMMENT '服务开始日期',
  `end_date` date DEFAULT NULL COMMENT '服务结束日期',
  `status` tinyint DEFAULT '1' COMMENT '状态(1-草稿 2-执行中 3-已完成 4-已终止)',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人ID',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_contract_no` (`contract_no`) USING BTREE,
  KEY `idx_customer` (`customer_id`) USING BTREE,
  KEY `idx_owner` (`owner_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='销售合同表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_contract`
--

LOCK TABLES `biz_contract` WRITE;
/*!40000 ALTER TABLE `biz_contract` DISABLE KEYS */;
INSERT INTO `biz_contract` VALUES (1,'HT2025-0001',6,3,'云启软件 SCRM 年度服务合同',98000.00,'2026-07-12','2026-07-17','2027-07-17',2,1,'二期扩容另行签署',1,'2026-07-12 10:27:23',1,'2026-10-10 10:27:23',0),(2,'HT2025-0002',16,7,'卓越教育会员系统续费合同',48000.00,'2026-10-12','2026-10-15','2027-10-15',2,4,'含两个新增校区',4,'2026-10-12 10:27:23',4,'2026-10-15 10:27:23',0),(3,'HT2025-0003',21,9,'天翼通信年度客户运营服务合同',240000.00,'2026-10-05','2026-10-08','2027-10-08',2,1,'年度框架合同',1,'2026-10-05 10:27:23',1,'2026-10-08 10:27:23',0),(4,'HT2024-0012',11,NULL,'优品电商会员服务合同',36000.00,'2026-04-03','2026-04-08','2026-10-05',3,4,'已完成验收',4,'2026-04-03 10:27:23',4,'2026-10-05 10:27:23',0),(5,'HT2024-0015',1,NULL,'海川科技试点服务合同',28000.00,'2026-05-23','2026-05-28','2026-09-30',3,2,'试点验收通过',2,'2026-05-23 10:27:23',2,'2026-09-30 10:27:23',0),(6,'HT2025-0004',23,NULL,'风行汽车门店协同服务合同',68000.00,'2026-10-18','2026-10-25','2027-10-25',1,2,'草稿待盖章',2,'2026-10-18 10:27:23',2,'2026-10-18 10:27:23',0),(7,'HT2024-0008',7,NULL,'康泰医疗数据服务合同',42000.00,'2025-12-24','2026-01-03','2026-09-20',4,4,'客户提前终止',4,'2025-12-24 10:27:23',4,'2026-09-20 10:27:23',0),(8,'HT2025-0005',9,NULL,'花间集会员运营试点合同',30000.00,'2026-10-14','2026-10-17','2027-01-15',2,2,'试点三个月',2,'2026-10-14 10:27:23',2,'2026-10-17 10:27:23',0);
/*!40000 ALTER TABLE `biz_contract` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_customer`
--

DROP TABLE IF EXISTS `biz_customer`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_customer` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '客户姓名',
  `short_name` varchar(50) DEFAULT NULL COMMENT '简称',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `wechat` varchar(64) DEFAULT NULL COMMENT '微信号',
  `email` varchar(128) DEFAULT NULL COMMENT '邮箱',
  `gender` tinyint DEFAULT '0' COMMENT '性别(1-男 2-女 0-保密)',
  `company` varchar(128) DEFAULT NULL COMMENT '公司名称',
  `position` varchar(64) DEFAULT NULL COMMENT '职位',
  `industry` varchar(64) DEFAULT NULL COMMENT '所属行业',
  `level` char(1) DEFAULT 'C' COMMENT '客户等级(A/B/C/D)',
  `source` tinyint DEFAULT '6' COMMENT '来源(1-官网 2-转介绍 3-活动 4-广告 5-主动开发 6-其他)',
  `status` tinyint DEFAULT '1' COMMENT '状态(1-潜在 2-跟进中 3-已成交 4-已流失)',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人ID(NULL为公海客户)',
  `dept_id` bigint DEFAULT NULL COMMENT '归属部门ID',
  `address` varchar(255) DEFAULT NULL COMMENT '地址',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `last_follow_time` datetime DEFAULT NULL COMMENT '最近跟进时间',
  `next_follow_time` datetime DEFAULT NULL COMMENT '下次跟进时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_phone` (`phone`) USING BTREE,
  KEY `idx_owner` (`owner_id`) USING BTREE,
  KEY `idx_status` (`status`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='客户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_customer`
--

LOCK TABLES `biz_customer` WRITE;
/*!40000 ALTER TABLE `biz_customer` DISABLE KEYS */;
INSERT INTO `biz_customer` VALUES (1,'张伟','海川科技','13800001001','zhangwei_hc','zhangwei@haichuan.cn',1,'杭州海川科技有限公司','采购总监','企业服务','A',2,3,2,1,'杭州市滨江区江南大道 588 号','重点客户，年度采购预算充足','2026-10-20 11:06:57','2026-10-23 10:27:23',2,'2026-07-26 10:27:23',1,'2026-10-20 11:06:57',0),(2,'李娜','星辰传媒','13800001002','lina_star','lina@xingchen.com',2,'星辰文化传媒有限公司','市场总监','文化传媒','B',1,2,4,1,'上海市徐汇区漕溪北路 88 号','关注内容营销方案','2026-10-18 10:27:23','2026-10-22 10:27:23',4,'2026-08-08 10:27:23',4,'2026-10-18 10:27:23',0),(3,'王强','恒信建材','13800001003','wangqiang_jc',NULL,1,'恒信建材集团','总经理','建筑建材','B',5,2,5,1,'南京市江宁区将军大道 12 号','通过行业展会认识','2026-10-15 10:27:23','2026-10-21 10:27:23',5,'2026-08-16 10:27:23',5,'2026-10-20 10:52:23',0),(4,'刘洋','极客网络','13800001004','liuyang_geek','liuyang@geeknet.cn',1,'极客网络科技有限公司','技术负责人','互联网','A',3,2,2,1,'深圳市南山区科技园南区','对接口集成能力要求高','2026-10-19 10:27:23','2026-10-24 10:27:23',2,'2026-08-23 10:27:23',2,'2026-10-19 10:27:23',0),(5,'陈静','悦享餐饮','13800001005','chenjing_yx',NULL,2,'悦享餐饮管理有限公司','运营经理','餐饮连锁','C',3,1,5,1,'成都市武侯区天府三街 66 号','门店会员管理需求','2026-10-11 10:27:23','2026-10-26 10:27:23',5,'2026-08-30 10:27:23',5,'2026-10-11 10:27:23',0),(6,'杨磊','云启软件','13800001006','yanglei_yq','yanglei@yunqi.com',1,'云启软件股份有限公司','副总裁','软件服务','A',2,3,1,1,'北京市海淀区中关村软件园','已签约，等待二期扩容','2026-10-17 10:27:23','2026-10-30 10:27:23',1,'2026-06-22 10:27:23',1,'2026-10-17 10:27:23',0),(7,'赵敏','康泰医疗','13800001007','zhaomin_kt','zhaomin@kangtai.cn',2,'康泰医疗器械有限公司','信息部经理','医疗健康','B',4,2,4,1,'苏州市工业园区星湖街 218 号','数据合规要求严格','2026-10-16 10:27:23','2026-10-23 10:27:23',4,'2026-09-03 10:27:23',4,'2026-10-16 10:27:23',0),(8,'周杰','恒达物流','13800001008','zhoujie_hd',NULL,1,'恒达物流有限公司','业务经理','物流仓储','C',5,1,NULL,NULL,'广州市白云区机场路 1100 号','公海客户，待分配',NULL,NULL,1,'2026-09-10 10:27:23',NULL,NULL,0),(9,'吴芳','花间集','13800001009','wufang_hj','wufang@huajianji.com',2,'花间集美妆有限公司','创始人','美妆零售','A',3,2,2,1,'杭州市余杭区文一西路 969 号','重视私域运营与会员复购','2026-10-19 10:27:23','2026-10-22 10:27:23',2,'2026-09-12 10:27:23',2,'2026-10-19 10:27:23',0),(10,'徐鹏','远景新能源','13800001010','xupeng_yj',NULL,1,'远景新能源科技有限公司','采购经理','新能源','B',2,2,5,1,'合肥市高新区望江西路 5089 号','正在比较三家供应商','2026-10-14 10:27:23','2026-10-25 10:27:23',5,'2026-09-14 10:27:23',5,'2026-10-14 10:27:23',0),(11,'孙丽','优品电商','13800001011','sunli_yp','sunli@youpin.com',2,'优品电子商务有限公司','运营总监','电子商务','A',1,3,4,1,'上海市浦东新区张江高科','官网留资，转化快','2026-10-13 10:27:23','2026-11-09 10:27:23',4,'2026-09-16 10:27:23',4,'2026-10-13 10:27:23',0),(12,'马超','蓝鲸体育','13800001012','machao_lj',NULL,1,'蓝鲸体育文化有限公司','市场经理','体育文化','C',4,1,NULL,NULL,'武汉市洪山区光谷大道 77 号','公海客户，线索质量待核实',NULL,NULL,1,'2026-09-19 10:27:23',NULL,NULL,0),(13,'朱琳','万邦咨询','13800001013','zhulin_wb','zhulin@wanbang.cn',2,'万邦管理咨询有限公司','合伙人','企业咨询','B',2,2,5,1,'北京市朝阳区建国路 93 号','希望先做小范围试点','2026-10-12 10:27:23','2026-10-24 10:27:23',5,'2026-09-21 10:27:23',5,'2026-10-12 10:27:23',0),(14,'胡军','华宇地产','13800001014','hujun_hy','hujun@huayu.com',1,'华宇地产集团有限公司','营销副总','房地产','A',3,2,2,1,'重庆市渝北区金开大道 100 号','集团层面决策，周期较长','2026-10-18 10:27:23','2026-10-27 10:27:23',2,'2026-09-23 10:27:23',2,'2026-10-18 10:27:23',0),(15,'郭婷','拾光咖啡','13800001015','guoting_sg',NULL,2,'拾光咖啡连锁','品牌经理','餐饮连锁','C',3,1,5,1,'厦门市思明区环岛东路 18 号','新开门店，预算有限','2026-10-08 10:27:23','2026-10-28 10:27:23',5,'2026-09-25 10:27:23',5,'2026-10-08 10:27:23',0),(16,'何伟','卓越教育','13800001016','hewei_zy','hewei@zhuoyue.cn',1,'卓越教育科技有限公司','校长','教育培训','B',1,3,4,1,'西安市雁塔区高新路 25 号','已成交，续费意愿强','2026-10-15 10:27:23','2026-11-19 10:27:23',4,'2026-09-27 10:27:23',4,'2026-10-15 10:27:23',0),(17,'高翔','峰云智能','13800001017','gaoxiang_fy','gaoxiang@fengyun.ai',1,'峰云智能科技有限公司','CEO','人工智能','A',2,2,2,1,'深圳市南山区粤海街道','意向明确，等待方案评审','2026-10-19 10:27:23','2026-10-22 10:27:23',2,'2026-09-29 10:27:23',2,'2026-10-19 10:27:23',0),(18,'林雪','雅诗服饰','13800001018','linxue_ys',NULL,2,'雅诗服饰有限公司','电商负责人','服装零售','B',4,2,4,1,'杭州市萧山区钱江世纪城','关注会员标签体系','2026-10-14 10:27:23','2026-10-23 10:27:23',4,'2026-10-01 10:27:23',4,'2026-10-14 10:27:23',0),(19,'罗刚','中科环保','13800001019','luogang_zk',NULL,1,'中科环保科技有限公司','项目经理','环保科技','C',5,1,NULL,NULL,'天津市滨海新区华苑产业区','公海客户，待电话核实',NULL,NULL,1,'2026-10-03 10:27:23',1,'2026-10-20 11:04:28',0),(20,'梁静','宜家装饰','13800001020','liangjing_yj','liangjing@yijia.com',2,'宜家装饰工程有限公司','设计总监','家装设计','B',3,2,5,1,'长沙市岳麓区梅溪湖路 1 号','对移动端体验要求高','2026-10-17 10:27:23','2026-10-25 10:27:23',5,'2026-10-05 10:27:23',5,'2026-10-17 10:27:23',0),(21,'宋涛','天翼通信','13800001021','songtao_ty','songtao@tianyi.cn',1,'天翼通信服务有限公司','政企客户经理','通信服务','A',1,3,1,1,'北京市西城区金融大街 33 号','集团采购，已签约年度服务','2026-10-16 10:27:23','2026-11-04 10:27:23',1,'2026-10-07 10:27:23',1,'2026-10-16 10:27:23',0),(22,'谢娜','米粒母婴','13800001022','xiena_ml',NULL,2,'米粒母婴用品有限公司','社群运营','母婴零售','C',4,1,4,1,'武汉市江汉区解放大道 688 号','已有社群，希望工具化','2026-10-06 10:27:23','2026-10-29 10:27:23',4,'2026-10-09 10:27:23',4,'2026-10-06 10:27:23',0),(23,'唐磊','风行汽车','13800001023','tanglei_fx','tanglei@fengxing.com',1,'风行汽车服务集团','区域经理','汽车服务','B',5,2,2,1,'郑州市金水区农业路 100 号','多门店协同需求','2026-10-18 10:27:23','2026-10-26 10:27:23',2,'2026-10-12 10:27:23',2,'2026-10-18 10:27:23',0),(24,'韩梅','四季酒店','13800001024','hanmei_sj',NULL,2,'四季酒店管理有限公司','销售总监','酒店旅游','C',3,1,5,1,'三亚市海棠区海棠北路 88 号','淡季预算审批中','2026-10-10 10:27:00','2026-11-01 10:27:23',5,'2026-10-15 10:27:23',1,'2026-10-20 11:01:15',0);
/*!40000 ALTER TABLE `biz_customer` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_customer_tag`
--

DROP TABLE IF EXISTS `biz_customer_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_customer_tag` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(32) NOT NULL COMMENT '标签名称',
  `color` varchar(20) DEFAULT '#409EFF' COMMENT '标签颜色',
  `sort` int DEFAULT '0' COMMENT '排序',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_name` (`name`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='客户标签表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_customer_tag`
--

LOCK TABLES `biz_customer_tag` WRITE;
/*!40000 ALTER TABLE `biz_customer_tag` DISABLE KEYS */;
INSERT INTO `biz_customer_tag` VALUES (1,'高意向','#F56C6C',1,1,'2026-10-20 10:27:23',1,'2026-10-20 10:27:23',0),(2,'价格敏感','#E6A23C',2,1,'2026-10-20 10:27:23',1,'2026-10-20 10:27:23',0),(3,'关键决策人','#409EFF',3,1,'2026-10-20 10:27:23',1,'2026-10-20 10:27:23',0),(4,'老客户','#67C23A',4,1,'2026-10-20 10:27:23',1,'2026-10-20 10:27:23',0),(5,'待回访','#909399',5,1,'2026-10-20 10:27:23',1,'2026-10-20 10:27:23',0),(6,'已报价','#9B59B6',6,1,'2026-10-20 10:27:23',1,'2026-10-20 10:27:23',0),(7,'展会线索','#16A085',7,1,'2026-10-20 10:27:23',1,'2026-10-20 10:27:23',0),(8,'转介绍','#D35400',8,1,'2026-10-20 10:27:23',1,'2026-10-20 10:27:23',0);
/*!40000 ALTER TABLE `biz_customer_tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_follow_up`
--

DROP TABLE IF EXISTS `biz_follow_up`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_follow_up` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `type` tinyint DEFAULT '1' COMMENT '跟进方式(1-电话 2-微信 3-拜访 4-邮件 5-其他)',
  `content` varchar(1000) NOT NULL COMMENT '跟进内容',
  `result` varchar(255) DEFAULT NULL COMMENT '跟进结果',
  `next_follow_time` datetime DEFAULT NULL COMMENT '下次跟进时间',
  `create_by` bigint DEFAULT NULL COMMENT '跟进人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer` (`customer_id`) USING BTREE,
  KEY `idx_create_by` (`create_by`) USING BTREE,
  KEY `idx_create_time` (`create_time`) USING BTREE,
  KEY `idx_next_follow_time` (`next_follow_time`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='客户跟进记录表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_follow_up`
--

LOCK TABLES `biz_follow_up` WRITE;
/*!40000 ALTER TABLE `biz_follow_up` DISABLE KEYS */;
INSERT INTO `biz_follow_up` VALUES (1,1,1,'电话沟通年度框架采购事宜，客户确认预算已审批通过，希望本周看到最终报价。','意向明确','2026-10-23 10:27:23',2,'2026-10-19 10:27:23',2,'2026-10-19 10:27:23',0),(2,1,3,'到客户公司拜访，与技术团队确认对接方案，重点讨论了数据同步频率。','方案待细化','2026-10-25 10:27:23',2,'2026-10-12 10:27:23',2,'2026-10-12 10:27:23',0),(3,1,4,'发送产品介绍与成功案例邮件，客户已阅读。','等待反馈','2026-10-30 10:27:23',2,'2026-09-30 10:27:23',2,'2026-09-30 10:27:23',0),(4,2,2,'微信沟通内容营销合作方案，客户对短视频投放感兴趣。','需求确认中','2026-10-22 10:27:23',4,'2026-10-18 10:27:23',4,'2026-10-18 10:27:23',0),(5,2,1,'电话回访，确认下周三安排产品演示。','已约演示','2026-10-25 10:27:23',4,'2026-10-11 10:27:23',4,'2026-10-11 10:27:23',0),(6,3,3,'上门拜访总经理，介绍会员运营整体解决方案。','待内部讨论','2026-10-21 10:27:23',5,'2026-10-15 10:27:23',5,'2026-10-15 10:27:23',0),(7,3,1,'电话确认需求范围，客户关注门店导购使用体验。','需求补充','2026-10-26 10:27:23',5,'2026-10-05 10:27:23',5,'2026-10-05 10:27:23',0),(8,4,2,'微信发送 API 文档，客户技术团队正在评估集成成本。','技术评估','2026-10-24 10:27:23',2,'2026-10-19 10:27:23',2,'2026-10-19 10:27:23',0),(9,4,1,'电话沟通并发量需求，预计日活 5 万。','待报价','2026-10-27 10:27:23',2,'2026-10-08 10:27:23',2,'2026-10-08 10:27:23',0),(10,5,2,'微信推送会员小程序案例，客户希望了解餐饮行业版本。','资料已发','2026-10-26 10:27:23',5,'2026-10-11 10:27:23',5,'2026-10-11 10:27:23',0),(11,6,3,'季度业务复盘，确认二期扩容 200 个账号。','扩容意向','2026-10-30 10:27:23',1,'2026-10-17 10:27:23',1,'2026-10-17 10:27:23',0),(12,6,4,'发送续费与扩容报价单。','已报价','2026-10-28 10:27:23',1,'2026-10-04 10:27:23',1,'2026-10-04 10:27:23',0),(13,7,1,'电话沟通医疗数据合规要求，客户关注本地化部署。','合规评估','2026-10-23 10:27:23',4,'2026-10-16 10:27:23',4,'2026-10-16 10:27:23',0),(14,7,2,'微信补充等保三级相关材料。','资料已发','2026-10-29 10:27:23',4,'2026-10-02 10:27:23',4,'2026-10-02 10:27:23',0),(15,9,3,'到店沟通私域运营方案，客户已有 8 万会员。','方案认可','2026-10-22 10:27:23',2,'2026-10-19 10:27:23',2,'2026-10-19 10:27:23',0),(16,9,2,'微信确认标签体系设计稿，客户提出按消费频次分层。','设计调整','2026-10-24 10:27:23',2,'2026-10-13 10:27:23',2,'2026-10-13 10:27:23',0),(17,10,1,'电话跟进，客户正在对比三家供应商，强调交付周期。','竞争中','2026-10-25 10:27:23',5,'2026-10-14 10:27:23',5,'2026-10-14 10:27:23',0),(18,10,4,'发送实施计划与交付里程碑。','已报价','2026-10-31 10:27:23',5,'2026-10-07 10:27:23',5,'2026-10-07 10:27:23',0),(19,11,1,'官网留资后首次电话，客户希望一周内上线试用。','高意向','2026-11-09 10:27:23',4,'2026-10-13 10:27:23',4,'2026-10-13 10:27:23',0),(20,11,2,'微信发送试用账号与操作指南。','试用中','2026-11-03 10:27:23',4,'2026-10-09 10:27:23',4,'2026-10-09 10:27:23',0),(21,13,2,'微信沟通试点范围，先覆盖 20 人销售团队。','试点确认','2026-10-24 10:27:23',5,'2026-10-12 10:27:23',5,'2026-10-12 10:27:23',0),(22,13,4,'发送试点方案与验收标准。','待审批','2026-10-30 10:27:23',5,'2026-10-04 10:27:23',5,'2026-10-04 10:27:23',0),(23,14,3,'拜访集团营销中心，确认由总部统一选型。','决策链梳理','2026-10-27 10:27:23',2,'2026-10-18 10:27:23',2,'2026-10-18 10:27:23',0),(24,14,1,'电话沟通项目立项进度，预计下月进入招标。','等待立项','2026-11-04 10:27:23',2,'2026-10-06 10:27:23',2,'2026-10-06 10:27:23',0),(25,15,2,'微信沟通新店会员活动方案，客户预算约 3 万。','预算有限','2026-10-28 10:27:23',5,'2026-10-08 10:27:23',5,'2026-10-08 10:27:23',0),(26,16,3,'到校回访，确认续费与新增两个校区。','续费意向','2026-11-19 10:27:23',4,'2026-10-15 10:27:23',4,'2026-10-15 10:27:23',0),(27,16,1,'电话确认续费合同条款。','合同确认','2026-11-09 10:27:23',4,'2026-10-01 10:27:23',4,'2026-10-01 10:27:23',0),(28,17,1,'电话沟通 AI 客服场景，客户希望接入现有知识库。','需求明确','2026-10-22 10:27:23',2,'2026-10-19 10:27:23',2,'2026-10-19 10:27:23',0),(29,17,4,'发送方案评审材料与报价。','待评审','2026-10-26 10:27:23',2,'2026-10-11 10:27:23',2,'2026-10-11 10:27:23',0),(30,18,2,'微信沟通会员标签体系，客户关注复购分析。','需求确认','2026-10-23 10:27:23',4,'2026-10-14 10:27:23',4,'2026-10-14 10:27:23',0),(31,18,1,'电话演示标签分组功能。','演示完成','2026-10-30 10:27:23',4,'2026-10-03 10:27:23',4,'2026-10-03 10:27:23',0),(32,20,3,'上门沟通移动端体验要求，现场演示小程序。','体验认可','2026-10-25 10:27:23',5,'2026-10-17 10:27:23',5,'2026-10-17 10:27:23',0),(33,20,2,'微信发送报价与实施周期。','已报价','2026-11-01 10:27:23',5,'2026-09-30 10:27:23',5,'2026-09-30 10:27:23',0),(34,21,1,'集团采购部电话确认年度服务范围。','已签约','2026-11-04 10:27:23',1,'2026-10-16 10:27:23',1,'2026-10-16 10:27:23',0),(35,21,4,'发送年度服务报告。','客户满意','2026-11-14 10:27:23',1,'2026-09-29 10:27:23',1,'2026-09-29 10:27:23',0),(36,22,2,'微信了解社群规模，目前 12 个群约 5000 人。','待方案','2026-10-29 10:27:23',4,'2026-10-06 10:27:23',4,'2026-10-06 10:27:23',0),(37,23,3,'到店沟通多门店协同，客户有 18 家门店。','需求明确','2026-10-26 10:27:23',2,'2026-10-18 10:27:23',2,'2026-10-18 10:27:23',0),(38,23,1,'电话确认总部与门店权限划分。','方案调整','2026-10-28 10:27:23',2,'2026-10-09 10:27:23',2,'2026-10-09 10:27:23',0),(39,24,2,'微信跟进淡季预算审批进度。','等待审批','2026-11-01 10:27:23',5,'2026-10-10 10:27:23',5,'2026-10-10 10:27:23',0),(40,8,1,'公海线索首次外呼，未接通。','未接通','2026-10-21 10:27:23',1,'2026-10-14 10:27:23',1,'2026-10-14 10:27:23',0),(41,12,1,'公海线索外呼，客户表示暂无需求。','暂缓','2026-11-19 10:27:23',1,'2026-10-12 10:27:23',1,'2026-10-12 10:27:23',0),(42,19,2,'微信添加好友未通过。','待触达','2026-10-23 10:27:23',1,'2026-10-09 10:27:23',1,'2026-10-09 10:27:23',0),(43,1,2,'微信发送合同草稿，等待法务确认。','合同审核','2026-10-23 10:27:23',2,'2026-10-20 08:27:23',2,'2026-10-20 08:27:23',0),(44,4,1,'电话确认最终报价折扣。','商务谈判','2026-10-24 10:27:23',2,'2026-10-20 05:27:23',2,'2026-10-20 05:27:23',0),(45,9,4,'邮件发送年度合作方案。','待反馈','2026-10-22 10:27:23',2,'2026-10-20 02:27:23',2,'2026-10-20 02:27:23',0),(46,11,2,'微信沟通试用反馈，客户满意度较高。','准备签约','2026-10-23 10:27:23',4,'2026-10-19 10:27:23',4,'2026-10-19 10:27:23',0),(47,17,1,'电话确认评审会时间。','评审排期','2026-10-22 10:27:23',2,'2026-10-20 07:27:23',2,'2026-10-20 07:27:23',0),(48,23,4,'邮件发送多门店权限方案。','待确认','2026-10-26 10:27:23',2,'2026-10-20 04:27:23',2,'2026-10-20 04:27:23',0);
/*!40000 ALTER TABLE `biz_follow_up` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `biz_opportunity`
--

DROP TABLE IF EXISTS `biz_opportunity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `biz_opportunity` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `name` varchar(128) NOT NULL COMMENT '商机名称',
  `amount` decimal(12,2) DEFAULT '0.00' COMMENT '预计金额',
  `stage` tinyint DEFAULT '1' COMMENT '阶段(1-初步接洽 2-需求确认 3-方案报价 4-商务谈判 5-赢单 6-输单)',
  `probability` tinyint DEFAULT '10' COMMENT '赢单概率(%)',
  `expected_close_date` date DEFAULT NULL COMMENT '预计成交日期',
  `owner_id` bigint DEFAULT NULL COMMENT '负责人ID',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_customer` (`customer_id`) USING BTREE,
  KEY `idx_owner` (`owner_id`) USING BTREE,
  KEY `idx_stage` (`stage`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='销售商机表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `biz_opportunity`
--

LOCK TABLES `biz_opportunity` WRITE;
/*!40000 ALTER TABLE `biz_opportunity` DISABLE KEYS */;
INSERT INTO `biz_opportunity` VALUES (1,1,'海川科技年度 SCRM 采购',180000.00,4,80,'2026-11-04',2,'合同条款审核中',2,'2026-08-21 10:27:23',2,'2026-10-19 10:27:23',0),(2,4,'极客网络 API 集成项目',96000.00,3,60,'2026-11-14',2,'等待最终报价',2,'2026-09-10 10:27:23',2,'2026-10-18 10:27:23',0),(3,6,'云启软件二期扩容',60000.00,5,100,'2026-10-10',1,'已赢单',1,'2026-08-26 10:27:23',1,'2026-10-10 10:27:23',0),(4,9,'花间集私域会员运营',128000.00,3,65,'2026-11-09',2,'标签体系方案已确认',2,'2026-09-20 10:27:23',2,'2026-10-17 10:27:23',0),(5,11,'优品电商试用转正式',72000.00,4,85,'2026-10-30',4,'试用反馈良好',4,'2026-09-30 10:27:23',4,'2026-10-19 10:27:23',0),(6,14,'华宇地产集团会员平台',350000.00,2,40,'2026-12-19',2,'等待集团立项',2,'2026-09-25 10:27:23',2,'2026-10-18 10:27:23',0),(7,16,'卓越教育续费及校区扩展',48000.00,5,100,'2026-10-15',4,'已赢单',4,'2026-09-10 10:27:23',4,'2026-10-15 10:27:23',0),(8,17,'峰云智能 AI 客服接入',156000.00,3,60,'2026-11-07',2,'方案评审中',2,'2026-10-02 10:27:23',2,'2026-10-19 10:27:23',0),(9,21,'天翼通信年度服务续约',240000.00,5,100,'2026-10-08',1,'已赢单',1,'2026-08-31 10:27:23',1,'2026-10-08 10:27:23',0),(10,10,'远景新能源供应商选型',88000.00,2,35,'2026-11-24',5,'与两家竞品对比中',5,'2026-09-28 10:27:23',5,'2026-10-14 10:27:23',0),(11,23,'风行汽车多门店协同',110000.00,3,55,'2026-11-17',2,'权限方案待确认',2,'2026-10-05 10:27:23',2,'2026-10-20 04:27:23',0),(12,20,'宜家装饰移动端升级',56000.00,2,40,'2026-11-29',5,'报价已发',5,'2026-10-08 10:27:23',5,'2026-10-17 10:27:23',0),(13,7,'康泰医疗本地化部署',168000.00,1,20,'2027-01-03',4,'合规评估阶段',4,'2026-10-10 10:27:23',4,'2026-10-16 10:27:23',0),(14,2,'星辰传媒内容营销合作',36000.00,6,0,'2026-10-17',4,'客户选择竞品',4,'2026-10-04 10:27:23',4,'2026-10-17 10:27:23',0);
/*!40000 ALTER TABLE `biz_opportunity` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table`
--

DROP TABLE IF EXISTS `gen_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `table_name` varchar(100) NOT NULL COMMENT '表名',
  `module_name` varchar(100) DEFAULT NULL COMMENT '模块名',
  `package_name` varchar(255) NOT NULL COMMENT '包名',
  `business_name` varchar(100) NOT NULL COMMENT '业务名',
  `entity_name` varchar(100) NOT NULL COMMENT '实体类名',
  `author` varchar(50) NOT NULL COMMENT '作者',
  `parent_menu_id` bigint DEFAULT NULL COMMENT '上级菜单ID，对应sys_menu的id ',
  `remove_table_prefix` varchar(20) DEFAULT NULL COMMENT '要移除的表前缀，如: sys_',
  `page_type` varchar(20) DEFAULT NULL COMMENT '页面类型(classic|curd)',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT '0' COMMENT '是否删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tablename` (`table_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代码生成配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table`
--

LOCK TABLES `gen_table` WRITE;
/*!40000 ALTER TABLE `gen_table` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gen_table_column`
--

DROP TABLE IF EXISTS `gen_table_column`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table_column` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `table_id` bigint NOT NULL COMMENT '关联的表配置ID',
  `column_name` varchar(100) DEFAULT NULL,
  `column_type` varchar(50) DEFAULT NULL,
  `column_length` int DEFAULT NULL,
  `field_name` varchar(100) NOT NULL COMMENT '字段名称',
  `field_type` varchar(100) DEFAULT NULL COMMENT '字段类型',
  `field_sort` int DEFAULT NULL COMMENT '字段排序',
  `field_comment` varchar(255) DEFAULT NULL COMMENT '字段描述',
  `max_length` int DEFAULT NULL,
  `is_required` tinyint(1) DEFAULT NULL COMMENT '是否必填',
  `is_show_in_list` tinyint(1) DEFAULT '0' COMMENT '是否在列表显示',
  `is_show_in_form` tinyint(1) DEFAULT '0' COMMENT '是否在表单显示',
  `is_show_in_query` tinyint(1) DEFAULT '0' COMMENT '是否在查询条件显示',
  `query_type` tinyint DEFAULT NULL COMMENT '查询方式',
  `form_type` tinyint DEFAULT NULL COMMENT '表单类型',
  `dict_type` varchar(50) DEFAULT NULL COMMENT '字典类型',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_table_id` (`table_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代码生成字段配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gen_table_column`
--

LOCK TABLES `gen_table_column` WRITE;
/*!40000 ALTER TABLE `gen_table_column` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_table_column` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rel_customer_tag`
--

DROP TABLE IF EXISTS `rel_customer_tag`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `rel_customer_tag` (
  `customer_id` bigint NOT NULL COMMENT '客户ID',
  `tag_id` bigint NOT NULL COMMENT '标签ID',
  PRIMARY KEY (`customer_id`,`tag_id`) USING BTREE,
  KEY `idx_tag_id` (`tag_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='客户标签关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rel_customer_tag`
--

LOCK TABLES `rel_customer_tag` WRITE;
/*!40000 ALTER TABLE `rel_customer_tag` DISABLE KEYS */;
INSERT INTO `rel_customer_tag` VALUES (1,1),(2,1),(4,1),(7,1),(9,1),(11,1),(14,1),(17,1),(20,1),(23,1),(3,2),(5,2),(10,2),(13,2),(15,2),(23,2),(1,3),(6,3),(7,3),(9,3),(14,3),(21,3),(1,4),(6,4),(11,4),(16,4),(21,4),(5,5),(7,5),(8,5),(12,5),(13,5),(15,5),(18,5),(19,5),(22,5),(24,5),(4,6),(10,6),(17,6),(3,7),(2,8),(16,8);
/*!40000 ALTER TABLE `rel_customer_tag` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_config`
--

DROP TABLE IF EXISTS `sys_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_config` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `config_name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置名称',
  `config_key` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置key',
  `config_value` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '配置值',
  `remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人ID',
  `is_deleted` tinyint NOT NULL DEFAULT '0' COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='系统配置表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_config`
--

LOCK TABLES `sys_config` WRITE;
/*!40000 ALTER TABLE `sys_config` DISABLE KEYS */;
INSERT INTO `sys_config` VALUES (1,'系统限流QPS','IP_QPS_THRESHOLD_LIMIT','10','单个IP请求的最大每秒查询数（QPS）阈值Key','2026-10-20 10:24:22',1,NULL,NULL,0);
/*!40000 ALTER TABLE `sys_config` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dept`
--

DROP TABLE IF EXISTS `sys_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dept` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '部门名称',
  `code` varchar(100) NOT NULL COMMENT '部门编号',
  `parent_id` bigint DEFAULT '0' COMMENT '父节点id',
  `tree_path` varchar(255) NOT NULL COMMENT '父节点id路径',
  `sort` smallint DEFAULT '0' COMMENT '显示顺序',
  `status` tinyint DEFAULT '1' COMMENT '状态(1-正常 0-禁用)',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除标识(1-已删除 0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_code` (`code`) USING BTREE COMMENT '部门编号唯一索引'
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='部门管理表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dept`
--

LOCK TABLES `sys_dept` WRITE;
/*!40000 ALTER TABLE `sys_dept` DISABLE KEYS */;
INSERT INTO `sys_dept` VALUES (1,'有来技术','YOULAI',0,'0',1,1,1,NULL,1,'2026-10-20 10:24:21',0),(2,'研发部门','RD001',1,'0,1',1,1,2,NULL,2,'2026-10-20 10:24:21',0),(3,'测试部门','QA001',1,'0,1',1,1,2,NULL,2,'2026-10-20 10:24:21',0);
/*!40000 ALTER TABLE `sys_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict`
--

DROP TABLE IF EXISTS `sys_dict`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键 ',
  `dict_code` varchar(50) DEFAULT NULL COMMENT '类型编码',
  `name` varchar(50) DEFAULT NULL COMMENT '类型名称',
  `status` tinyint(1) DEFAULT '0' COMMENT '状态(0:正常;1:禁用)',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `is_deleted` tinyint DEFAULT '0' COMMENT '是否删除(1-删除，0-未删除)',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_dict_code` (`dict_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='数据字典类型表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict`
--

LOCK TABLES `sys_dict` WRITE;
/*!40000 ALTER TABLE `sys_dict` DISABLE KEYS */;
INSERT INTO `sys_dict` VALUES (1,'gender','性别',1,NULL,'2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1,0),(2,'notice_type','通知类型',1,NULL,'2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1,0),(3,'notice_level','通知级别',1,NULL,'2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1,0);
/*!40000 ALTER TABLE `sys_dict` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_dict_item`
--

DROP TABLE IF EXISTS `sys_dict_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_item` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `dict_code` varchar(50) DEFAULT NULL COMMENT '关联字典编码，与sys_dict表中的dict_code对应',
  `value` varchar(50) DEFAULT NULL COMMENT '字典项值',
  `label` varchar(100) DEFAULT NULL COMMENT '字典项标签',
  `tag_type` varchar(50) DEFAULT NULL COMMENT '标签类型，用于前端样式展示（如success、warning等）',
  `status` tinyint DEFAULT '0' COMMENT '状态（1-正常，0-禁用）',
  `sort` int DEFAULT '0' COMMENT '排序',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='数据字典项表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_dict_item`
--

LOCK TABLES `sys_dict_item` WRITE;
/*!40000 ALTER TABLE `sys_dict_item` DISABLE KEYS */;
INSERT INTO `sys_dict_item` VALUES (1,'gender','1','男','primary',1,1,NULL,'2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1),(2,'gender','2','女','danger',1,2,NULL,'2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1),(3,'gender','0','保密','info',1,3,NULL,'2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1),(4,'notice_type','1','系统升级','success',1,1,'','2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1),(5,'notice_type','2','系统维护','primary',1,2,'','2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1),(6,'notice_type','3','安全警告','danger',1,3,'','2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1),(7,'notice_type','4','假期通知','success',1,4,'','2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1),(8,'notice_type','5','公司新闻','primary',1,5,'','2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1),(9,'notice_type','99','其他','info',1,99,'','2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1),(10,'notice_level','L','低','info',1,1,'','2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1),(11,'notice_level','M','中','warning',1,2,'','2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1),(12,'notice_level','H','高','danger',1,3,'','2026-10-20 10:24:21',1,'2026-10-20 10:24:21',1);
/*!40000 ALTER TABLE `sys_dict_item` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_log`
--

DROP TABLE IF EXISTS `sys_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `module` varchar(50) NOT NULL COMMENT '日志模块',
  `request_method` varchar(64) NOT NULL COMMENT '请求方式',
  `request_params` text COMMENT '请求参数(批量请求参数可能会超过text)',
  `response_content` mediumtext COMMENT '返回参数',
  `content` varchar(255) NOT NULL COMMENT '日志内容',
  `request_uri` varchar(255) DEFAULT NULL COMMENT '请求路径',
  `method` varchar(255) DEFAULT NULL COMMENT '方法名',
  `ip` varchar(45) DEFAULT NULL COMMENT 'IP地址',
  `province` varchar(100) DEFAULT NULL COMMENT '省份',
  `city` varchar(100) DEFAULT NULL COMMENT '城市',
  `execution_time` bigint DEFAULT NULL COMMENT '执行时间(ms)',
  `browser` varchar(100) DEFAULT NULL COMMENT '浏览器',
  `browser_version` varchar(100) DEFAULT NULL COMMENT '浏览器版本',
  `os` varchar(100) DEFAULT NULL COMMENT '终端系统',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `idx_create_time` (`create_time`)
) ENGINE=MyISAM AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统操作日志表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_log`
--

LOCK TABLES `sys_log` WRITE;
/*!40000 ALTER TABLE `sys_log` DISABLE KEYS */;
INSERT INTO `sys_log` VALUES (1,'LOGIN','POST','{\"username\":\"root\",\"password\":\"123456\",\"captchaId\":\"f8dfefa3c2134701aabc76de5ecbc41c\",\"captchaCode\":\"0\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',1331,'Unknown',NULL,'Unknown',NULL,'2026-10-20 10:30:08'),(2,'LOGIN','POST','{\"username\":\"employee\",\"password\":\"123456\",\"captchaId\":\"a19064698ef845bc84e2111b133a4a00\",\"captchaCode\":\"9\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',81,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:32:24'),(3,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',62,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',6,'2026-10-20 10:32:25'),(4,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":10}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',31,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',6,'2026-10-20 10:34:25'),(5,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',42,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',6,'2026-10-20 10:34:32'),(6,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":10}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',23,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',6,'2026-10-20 10:34:36'),(7,'LOGIN','POST','{\"username\":\"root\",\"password\":\"123456\",\"captchaId\":\"af687ba155a049118c4c914f9fe6c19a\",\"captchaCode\":\"18\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',1135,'Unknown',NULL,'Unknown',NULL,'2026-10-20 10:36:26'),(8,'LOGIN','POST','{\"username\":\"dept_manager\",\"password\":\"123456\",\"captchaId\":\"7868dbf6d9f643cba955fdbde56be8dd\",\"captchaCode\":\"14\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',192,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:40:06'),(9,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',63,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:40:06'),(10,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":10}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',59,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:40:15'),(11,'ROLE','GET','{\"keywords\":\"\",\"pageNum\":1,\"pageSize\":20}',NULL,'角色分页列表','/api/v1/roles','getRolePage','192.168.1.198','0','内网IP',16,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:40:18'),(12,'MENU','GET','{}',NULL,'菜单列表','/api/v1/menus','getMenus','192.168.1.198','0','内网IP',54,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:40:18'),(13,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',25,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:41:40'),(14,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',30,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:41:49'),(15,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',29,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:41:53'),(16,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',21,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:42:05'),(17,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',28,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:43:12'),(18,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',19,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:43:25'),(19,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',26,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:43:39'),(20,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',29,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:43:47'),(21,'LOGIN','DELETE','{}',NULL,'退出登录','/api/v1/auth/logout','logout','192.168.1.198','0','内网IP',3,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',4,'2026-10-20 10:43:51'),(22,'LOGIN','POST','{\"username\":\"clerk\",\"password\":\"123456\",\"captchaId\":\"ee00a8023d9b4572a085bb2dc99b4729\",\"captchaCode\":\"1\"}','[\"org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider.authenticate(AbstractUserDetailsAuthenticationProvider.java:152)\",\"org.springframework.security.authentication.ProviderManager.authenticate(ProviderManager.java:183)\",\"com.youlai.boot.auth.service.impl.AuthServiceImpl.login(AuthServiceImpl.java:75)\",\"com.youlai.boot.auth.controller.AuthController.login(AuthController.java:44)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.support.AopUtils.invokeJoinpointUsingReflection(AopUtils.java:359)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.invokeJoinpoint(ReflectiveMethodInvocation.java:190)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:158)\",\"org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:85)\",\"com.youlai.boot.core.aspect.LogAspect.doAround(LogAspect.java:70)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:648)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:630)\",\"org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:70)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:168)\",\"org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:96)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:179)\",\"org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy','登录（失败：Bad credentials）','/api/v1/auth/login','login','192.168.1.198','0','内网IP',68,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:44:03'),(23,'LOGIN','POST','{\"username\":\"youlai\",\"password\":\"123456\",\"captchaId\":\"c93fbd1b32a14f7f82e797bbfcc4c316\",\"captchaCode\":\"5\"}','[\"org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider.authenticate(AbstractUserDetailsAuthenticationProvider.java:152)\",\"org.springframework.security.authentication.ProviderManager.authenticate(ProviderManager.java:183)\",\"com.youlai.boot.auth.service.impl.AuthServiceImpl.login(AuthServiceImpl.java:75)\",\"com.youlai.boot.auth.controller.AuthController.login(AuthController.java:44)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.support.AopUtils.invokeJoinpointUsingReflection(AopUtils.java:359)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.invokeJoinpoint(ReflectiveMethodInvocation.java:190)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:158)\",\"org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:85)\",\"com.youlai.boot.core.aspect.LogAspect.doAround(LogAspect.java:70)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:648)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:630)\",\"org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:70)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:168)\",\"org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:96)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:179)\",\"org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy','登录（失败：Bad credentials）','/api/v1/auth/login','login','192.168.1.198','0','内网IP',69,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:44:14'),(24,'LOGIN','POST','{\"username\":\"youlai\",\"password\":\"123456\",\"captchaId\":\"e0055a58206940e69bb21bddc91edfcc\",\"captchaCode\":\"3\"}','[\"org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider.authenticate(AbstractUserDetailsAuthenticationProvider.java:152)\",\"org.springframework.security.authentication.ProviderManager.authenticate(ProviderManager.java:183)\",\"com.youlai.boot.auth.service.impl.AuthServiceImpl.login(AuthServiceImpl.java:75)\",\"com.youlai.boot.auth.controller.AuthController.login(AuthController.java:44)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.support.AopUtils.invokeJoinpointUsingReflection(AopUtils.java:359)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.invokeJoinpoint(ReflectiveMethodInvocation.java:190)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:158)\",\"org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:85)\",\"com.youlai.boot.core.aspect.LogAspect.doAround(LogAspect.java:70)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:648)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:630)\",\"org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:70)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:168)\",\"org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:96)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:179)\",\"org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy','登录（失败：Bad credentials）','/api/v1/auth/login','login','192.168.1.198','0','内网IP',67,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:44:24'),(25,'LOGIN','POST','{\"username\":\"youlai\",\"password\":\"123456\",\"captchaId\":\"3a562ca328d94773a296f1e546b9da06\",\"captchaCode\":\"6\"}','[\"org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider.authenticate(AbstractUserDetailsAuthenticationProvider.java:152)\",\"org.springframework.security.authentication.ProviderManager.authenticate(ProviderManager.java:183)\",\"com.youlai.boot.auth.service.impl.AuthServiceImpl.login(AuthServiceImpl.java:75)\",\"com.youlai.boot.auth.controller.AuthController.login(AuthController.java:44)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.support.AopUtils.invokeJoinpointUsingReflection(AopUtils.java:359)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.invokeJoinpoint(ReflectiveMethodInvocation.java:190)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:158)\",\"org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:85)\",\"com.youlai.boot.core.aspect.LogAspect.doAround(LogAspect.java:70)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:648)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:630)\",\"org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:70)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:168)\",\"org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:96)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:179)\",\"org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy','登录（失败：Bad credentials）','/api/v1/auth/login','login','192.168.1.198','0','内网IP',63,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:44:28'),(26,'LOGIN','POST','{\"username\":\"clerk\",\"password\":\"123456\",\"captchaId\":\"2c3a74495d7147cab629875e7914f5c6\",\"captchaCode\":\"8\"}','[\"org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider.authenticate(AbstractUserDetailsAuthenticationProvider.java:152)\",\"org.springframework.security.authentication.ProviderManager.authenticate(ProviderManager.java:183)\",\"com.youlai.boot.auth.service.impl.AuthServiceImpl.login(AuthServiceImpl.java:75)\",\"com.youlai.boot.auth.controller.AuthController.login(AuthController.java:44)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.support.AopUtils.invokeJoinpointUsingReflection(AopUtils.java:359)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.invokeJoinpoint(ReflectiveMethodInvocation.java:190)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:158)\",\"org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:85)\",\"com.youlai.boot.core.aspect.LogAspect.doAround(LogAspect.java:70)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:648)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:630)\",\"org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:70)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:168)\",\"org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:96)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:179)\",\"org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy','登录（失败：Bad credentials）','/api/v1/auth/login','login','192.168.1.198','0','内网IP',71,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:44:35'),(27,'LOGIN','POST','{\"username\":\"youlai\",\"password\":\"123456\",\"captchaId\":\"3702dd5fb4cb44929ff188bc5fcc2316\",\"captchaCode\":\"5\"}','[\"org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider.authenticate(AbstractUserDetailsAuthenticationProvider.java:152)\",\"org.springframework.security.authentication.ProviderManager.authenticate(ProviderManager.java:183)\",\"com.youlai.boot.auth.service.impl.AuthServiceImpl.login(AuthServiceImpl.java:75)\",\"com.youlai.boot.auth.controller.AuthController.login(AuthController.java:44)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.support.AopUtils.invokeJoinpointUsingReflection(AopUtils.java:359)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.invokeJoinpoint(ReflectiveMethodInvocation.java:190)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:158)\",\"org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:85)\",\"com.youlai.boot.core.aspect.LogAspect.doAround(LogAspect.java:70)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:648)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:630)\",\"org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:70)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:168)\",\"org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:96)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:179)\",\"org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy','登录（失败：Bad credentials）','/api/v1/auth/login','login','192.168.1.198','0','内网IP',72,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:46:38'),(28,'LOGIN','POST','{\"username\":\"youlai\",\"password\":\"123456\",\"captchaId\":\"e0ea8e36a8f94128a526e29e05109c5a\",\"captchaCode\":\"8\"}','[\"org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider.authenticate(AbstractUserDetailsAuthenticationProvider.java:152)\",\"org.springframework.security.authentication.ProviderManager.authenticate(ProviderManager.java:183)\",\"com.youlai.boot.auth.service.impl.AuthServiceImpl.login(AuthServiceImpl.java:75)\",\"com.youlai.boot.auth.controller.AuthController.login(AuthController.java:44)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.support.AopUtils.invokeJoinpointUsingReflection(AopUtils.java:359)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.invokeJoinpoint(ReflectiveMethodInvocation.java:190)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:158)\",\"org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:85)\",\"com.youlai.boot.core.aspect.LogAspect.doAround(LogAspect.java:70)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:648)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:630)\",\"org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:70)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:168)\",\"org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:96)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:179)\",\"org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy','登录（失败：Bad credentials）','/api/v1/auth/login','login','192.168.1.198','0','内网IP',67,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:46:48'),(29,'LOGIN','POST','{\"username\":\"youlai\",\"password\":\"123456\",\"captchaId\":\"00f23533adc042c0824551fbdab9537d\",\"captchaCode\":\"6\"}','[\"org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider.authenticate(AbstractUserDetailsAuthenticationProvider.java:152)\",\"org.springframework.security.authentication.ProviderManager.authenticate(ProviderManager.java:183)\",\"com.youlai.boot.auth.service.impl.AuthServiceImpl.login(AuthServiceImpl.java:75)\",\"com.youlai.boot.auth.controller.AuthController.login(AuthController.java:44)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.support.AopUtils.invokeJoinpointUsingReflection(AopUtils.java:359)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.invokeJoinpoint(ReflectiveMethodInvocation.java:190)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:158)\",\"org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:85)\",\"com.youlai.boot.core.aspect.LogAspect.doAround(LogAspect.java:70)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:648)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:630)\",\"org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:70)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:168)\",\"org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:96)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:179)\",\"org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy','登录（失败：Bad credentials）','/api/v1/auth/login','login','192.168.1.198','0','内网IP',74,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:46:58'),(30,'LOGIN','POST','{\"username\":\"root\",\"password\":\"123456\",\"captchaId\":\"d3dade3255f0428ea6461f8d1acce04c\",\"captchaCode\":\"28\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',1130,'Unknown',NULL,'Unknown',NULL,'2026-10-20 10:49:07'),(31,'LOGIN','POST','{\"username\":\"dept_manager\",\"password\":\"123456\",\"captchaId\":\"ec88abeb35b849afb12ee66f19d21dc0\",\"captchaCode\":\"9\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',79,'Unknown',NULL,'Unknown',NULL,'2026-10-20 10:49:08'),(32,'LOGIN','POST','{\"username\":\"dept_member\",\"password\":\"123456\",\"captchaId\":\"ddc79b8248cb43ff847203b44f63dff9\",\"captchaCode\":\"0\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',84,'Unknown',NULL,'Unknown',NULL,'2026-10-20 10:49:09'),(33,'LOGIN','POST','{\"username\":\"dept_manager\",\"password\":\"123456\",\"captchaId\":\"5530f4be06bd4537add5a4b8d1b5f5cc\",\"captchaCode\":\"0\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',74,'Unknown',NULL,'Unknown',NULL,'2026-10-20 10:49:19'),(34,'LOGIN','POST','{\"username\":\"dept_manager\",\"password\":\"123456\",\"captchaId\":\"c7a38c14c8df4151a3e78ec4391a85d7\",\"captchaCode\":\"10\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',74,'Unknown',NULL,'Unknown',NULL,'2026-10-20 10:49:45'),(35,'LOGIN','POST','{\"username\":\"dept_member\",\"password\":\"123456\",\"captchaId\":\"12af28dfffaf48acb9c9adbd57dd8cc1\",\"captchaCode\":\"2\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',80,'Unknown',NULL,'Unknown',NULL,'2026-10-20 10:51:29'),(36,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',27,'Chrome','150.0.7871.114','Windows 10 or Windows Server 2016',1,'2026-10-20 10:54:46'),(37,'LOGIN','POST','{\"username\":\"manager\",\"password\":\"123456\",\"captchaId\":\"ee74ffcc84bf4b7391b14592a0f238f9\",\"captchaCode\":\"18\"}','[\"org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider.authenticate(AbstractUserDetailsAuthenticationProvider.java:152)\",\"org.springframework.security.authentication.ProviderManager.authenticate(ProviderManager.java:183)\",\"com.youlai.boot.auth.service.impl.AuthServiceImpl.login(AuthServiceImpl.java:75)\",\"com.youlai.boot.auth.controller.AuthController.login(AuthController.java:44)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.support.AopUtils.invokeJoinpointUsingReflection(AopUtils.java:359)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.invokeJoinpoint(ReflectiveMethodInvocation.java:190)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:158)\",\"org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:85)\",\"com.youlai.boot.core.aspect.LogAspect.doAround(LogAspect.java:70)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:648)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:630)\",\"org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:70)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:168)\",\"org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:96)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:179)\",\"org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy','登录（失败：Bad credentials）','/api/v1/auth/login','login','192.168.1.198','0','内网IP',65,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:56:35'),(38,'LOGIN','POST','{\"username\":\"manager\",\"password\":\"123456\",\"captchaId\":\"dd56f121b96c43cc9532e89e3f6aa7a3\",\"captchaCode\":\"56\"}','[\"org.springframework.security.authentication.dao.AbstractUserDetailsAuthenticationProvider.authenticate(AbstractUserDetailsAuthenticationProvider.java:152)\",\"org.springframework.security.authentication.ProviderManager.authenticate(ProviderManager.java:183)\",\"com.youlai.boot.auth.service.impl.AuthServiceImpl.login(AuthServiceImpl.java:75)\",\"com.youlai.boot.auth.controller.AuthController.login(AuthController.java:44)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.support.AopUtils.invokeJoinpointUsingReflection(AopUtils.java:359)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.invokeJoinpoint(ReflectiveMethodInvocation.java:190)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:158)\",\"org.springframework.aop.aspectj.MethodInvocationProceedingJoinPoint.proceed(MethodInvocationProceedingJoinPoint.java:85)\",\"com.youlai.boot.core.aspect.LogAspect.doAround(LogAspect.java:70)\",\"java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)\",\"java.base/java.lang.reflect.Method.invoke(Method.java:580)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethodWithGivenArgs(AbstractAspectJAdvice.java:648)\",\"org.springframework.aop.aspectj.AbstractAspectJAdvice.invokeAdviceMethod(AbstractAspectJAdvice.java:630)\",\"org.springframework.aop.aspectj.AspectJAroundAdvice.invoke(AspectJAroundAdvice.java:70)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:168)\",\"org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:96)\",\"org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:179)\",\"org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy','登录（失败：Bad credentials）','/api/v1/auth/login','login','192.168.1.198','0','内网IP',66,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 10:56:42'),(39,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',12,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',1,'2026-10-20 10:57:09'),(40,'USER','GET','{\"isRoot\":true,\"pageNum\":1,\"pageSize\":10}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',28,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',1,'2026-10-20 10:57:51'),(41,'ROLE','GET','{\"keywords\":\"\",\"pageNum\":1,\"pageSize\":20}',NULL,'角色分页列表','/api/v1/roles','getRolePage','192.168.1.198','0','内网IP',11,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',1,'2026-10-20 10:57:52'),(42,'MENU','GET','{}',NULL,'菜单列表','/api/v1/menus','getMenus','192.168.1.198','0','内网IP',18,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',1,'2026-10-20 10:57:52'),(43,'DEPT','GET','{\"keywords\":\"\"}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',9,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',1,'2026-10-20 10:57:56'),(44,'DICT','GET','{\"keywords\":\"\",\"pageNum\":1,\"pageSize\":20}',NULL,'字典分页列表','/api/v1/dicts','getDictPage','192.168.1.198','0','内网IP',23,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',1,'2026-10-20 10:57:58'),(45,'SETTING','GET','{\"keywords\":\"\",\"pageNum\":1,\"pageSize\":10}',NULL,'系统配置分页列表','/api/v1/configs','page','192.168.1.198','0','内网IP',14,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',1,'2026-10-20 10:58:02'),(46,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',13,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',1,'2026-10-20 10:58:13'),(47,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',10,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',1,'2026-10-20 11:10:28'),(48,'LOGIN','POST','{\"username\":\"admin\",\"password\":\"123456\",\"captchaId\":\"d4e7831228a94380984e5697838875d5\",\"captchaCode\":\"11\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',1207,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 12:01:00'),(49,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',79,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:01:00'),(50,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',44,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:01:03'),(51,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":100}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',41,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:01:13'),(52,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',13,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:01:14'),(53,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":10}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',18,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:01:14'),(54,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":100}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',22,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:01:16'),(55,'LOGIN','POST','{\"username\":\"admin\",\"password\":\"123456\",\"captchaId\":\"a7f830f6627b4667882681730549aa33\",\"captchaCode\":\"10\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',73,'Unknown',NULL,'Unknown',NULL,'2026-10-20 12:01:29'),(56,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',6,'Unknown',NULL,'Unknown',2,'2026-10-20 12:01:37'),(57,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":10}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',14,'Unknown',NULL,'Unknown',2,'2026-10-20 12:01:37'),(58,'ROLE','GET','{\"pageNum\":1,\"pageSize\":10}',NULL,'角色分页列表','/api/v1/roles','getRolePage','192.168.1.198','0','内网IP',15,'Unknown',NULL,'Unknown',2,'2026-10-20 12:01:37'),(59,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',4,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:02:15'),(60,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',5,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:03:10'),(61,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":10}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',15,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:03:10'),(62,'ROLE','GET','{\"pageNum\":1,\"pageSize\":10}',NULL,'角色分页列表','/api/v1/roles','getRolePage','192.168.1.198','0','内网IP',12,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:03:20'),(63,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',4,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:04:29'),(64,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":10}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',10,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:04:29'),(65,'USER','GET','{\"deptId\":3,\"isRoot\":false,\"pageNum\":1,\"pageSize\":10}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',16,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:04:34'),(66,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":100}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',12,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:05:17'),(67,'LOGIN','POST','{\"username\":\"admin\",\"password\":\"123456\",\"captchaId\":\"2ca788ae035e4688919efc29ff97788b\",\"captchaCode\":\"2\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',139,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 12:41:06'),(68,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',13,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:41:06'),(69,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',9,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:41:06'),(70,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',5,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:41:12'),(71,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":100}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',30,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 12:41:13'),(72,'LOGIN','POST','{\"username\":\"admin\",\"password\":\"123456\",\"captchaId\":\"b59e030544704e00962ca5f9dd92fb8f\",\"captchaCode\":\"16\"}',NULL,'登录','/api/v1/auth/login','login','192.168.1.198','0','内网IP',141,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',NULL,'2026-10-20 13:12:42'),(73,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',16,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 13:12:42'),(74,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',7,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 13:12:43'),(75,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',7,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 13:13:21'),(76,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":100}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',24,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 13:13:25'),(77,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":100}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',15,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 13:13:27'),(78,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":100}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',16,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 13:13:30'),(79,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',6,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 13:13:30'),(80,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":10}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',10,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 13:13:30'),(81,'USER','GET','',NULL,'获取当前登录用户信息','/api/v1/users/me','getCurrentUser','192.168.1.198','0','内网IP',18,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 13:14:27'),(82,'DEPT','GET','{}',NULL,'部门列表','/api/v1/depts','getDeptList','192.168.1.198','0','内网IP',8,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 13:14:28'),(83,'USER','GET','{\"isRoot\":false,\"pageNum\":1,\"pageSize\":10}',NULL,'用户列表','/api/v1/users','getUserList','192.168.1.198','0','内网IP',17,'MSEdge','155.0.0.0','Windows 10 or Windows Server 2016',2,'2026-10-20 13:14:28');
/*!40000 ALTER TABLE `sys_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_menu`
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `parent_id` bigint NOT NULL COMMENT '父菜单ID',
  `tree_path` varchar(255) DEFAULT NULL COMMENT '父节点ID路径',
  `name` varchar(64) NOT NULL COMMENT '菜单名称',
  `type` char(1) NOT NULL COMMENT '菜单类型（C-目录 M-菜单 B-按钮）',
  `route_name` varchar(255) DEFAULT NULL COMMENT '路由名称（Vue Router 中用于命名路由）',
  `route_path` varchar(128) DEFAULT NULL COMMENT '路由路径（Vue Router 中定义的 URL 路径）',
  `component` varchar(128) DEFAULT NULL COMMENT '组件路径（组件页面完整路径，相对于 src/views/，缺省后缀 .vue）',
  `perm` varchar(128) DEFAULT NULL COMMENT '【按钮】权限标识',
  `always_show` tinyint DEFAULT '0' COMMENT '【目录】只有一个子路由是否始终显示（1-是 0-否）',
  `keep_alive` tinyint DEFAULT '0' COMMENT '【菜单】是否开启页面缓存（1-是 0-否）',
  `visible` tinyint(1) DEFAULT '1' COMMENT '显示状态（1-显示 0-隐藏）',
  `sort` int DEFAULT '0' COMMENT '排序',
  `icon` varchar(64) DEFAULT NULL COMMENT '菜单图标',
  `redirect` varchar(128) DEFAULT NULL COMMENT '跳转路径',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `params` json DEFAULT NULL COMMENT '路由参数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=3015 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统菜单表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_menu`
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` VALUES (1,0,'0','系统管理','C','','/system','Layout',NULL,NULL,NULL,1,1,'system','/system/user','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2,0,'0','代码生成','C','','/codegen','Layout',NULL,NULL,NULL,0,2,'code','/codegen/index','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(4,0,'0','平台文档','C','','/doc','Layout',NULL,NULL,NULL,0,4,'document','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(5,0,'0','接口文档','C','','/api','Layout',NULL,NULL,NULL,0,5,'api','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(6,0,'0','组件封装','C','','/component','Layout',NULL,NULL,NULL,0,6,'menu','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(7,0,'0','功能演示','C','','/function','Layout',NULL,NULL,NULL,0,7,'menu','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(8,0,'0','多级菜单','C',NULL,'/multi-level','Layout',NULL,1,NULL,0,8,'cascader','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(9,0,'0','路由参数','C','','/route-param','Layout',NULL,NULL,NULL,0,9,'el-icon-ElementPlus','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(210,1,'0,1','用户管理','M','User','user','system/user/index',NULL,NULL,1,1,1,'el-icon-User',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(220,1,'0,1','角色管理','M','Role','role','system/role/index',NULL,NULL,1,1,2,'role',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(230,1,'0,1','菜单管理','M','SysMenu','menu','system/menu/index',NULL,NULL,1,1,3,'menu',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(240,1,'0,1','部门管理','M','Dept','dept','system/dept/index',NULL,NULL,1,1,4,'tree',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(250,1,'0,1','字典管理','M','Dict','dict','system/dict/index',NULL,NULL,1,1,5,'dict',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(251,1,'0,1','字典项','M','DictItem','dict-item','system/dict/dict-item',NULL,0,1,0,6,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(260,1,'0,1','系统日志','M','Log','log','system/log/index',NULL,0,1,1,7,'document',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(270,1,'0,1','系统配置','M','Config','config','system/config/index',NULL,0,1,1,8,'setting',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(280,1,'0,1','通知公告','M','Notice','notice','system/notice/index',NULL,NULL,NULL,1,9,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(310,2,'0,2','代码生成','M','Codegen','codegen','codegen/index',NULL,NULL,1,1,1,'code',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(501,4,'0,4','平台文档(外链)','M',NULL,'https://juejin.cn/post/7228990409909108793','',NULL,NULL,NULL,1,1,'document','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(502,4,'0,4','后端文档','M',NULL,'https://youlai.blog.csdn.net/article/details/145178880','',NULL,NULL,NULL,1,2,'document','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(503,4,'0,4','移动端文档','M',NULL,'https://youlai.blog.csdn.net/article/details/143222890','',NULL,NULL,NULL,1,3,'document','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(504,4,'0,4','内部文档','M',NULL,'internal-doc','demo/internal-doc',NULL,NULL,NULL,1,4,'document','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(601,5,'0,5','Apifox','M','Apifox','apifox','demo/api/apifox',NULL,NULL,1,1,1,'api','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(701,6,'0,6','富文本编辑器','M','WangEditor','wang-editor','demo/wang-editor',NULL,NULL,1,1,2,'','','2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(702,6,'0,6','图片上传','M','Upload','upload','demo/upload',NULL,NULL,1,1,3,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(703,6,'0,6','图标选择器','M','IconSelect','icon-select','demo/icon-select',NULL,NULL,1,1,4,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(704,6,'0,6','字典组件','M','DictDemo','dict-demo','demo/dictionary',NULL,NULL,1,1,4,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(705,6,'0,6','增删改查','M','Curd','curd','demo/curd/index',NULL,NULL,1,1,0,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(706,6,'0,6','列表选择器','M','TableSelect','table-select','demo/table-select/index',NULL,NULL,1,1,1,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(707,6,'0,6','拖拽组件','M','Drag','drag','demo/drag',NULL,NULL,NULL,1,5,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(708,6,'0,6','滚动文本','M','TextScroll','text-scroll','demo/text-scroll',NULL,NULL,NULL,1,6,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(709,6,'0,6','自适应表格操作列','M','AutoOperationColumn','operation-column','demo/auto-operation-column',NULL,NULL,1,1,1,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(801,7,'0,7','Icons','M','IconDemo','icon-demo','demo/icons',NULL,NULL,1,1,2,'el-icon-Notification','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(802,7,'0,7','字典实时同步','M','DictSync','dict-sync','demo/dict-sync',NULL,NULL,NULL,1,3,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(803,7,'0,7','VxeTable','M','VxeTable','vxe-table','demo/vxe-table/index',NULL,NULL,1,1,4,'el-icon-MagicStick','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(804,7,'0,7','CURD单文件','M','CurdSingle','curd-single','demo/curd-single',NULL,NULL,1,1,5,'el-icon-Reading','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(910,8,'0,8','菜单一级','C',NULL,'multi-level1','Layout',NULL,1,NULL,1,1,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(911,910,'0,8,910','菜单二级','C',NULL,'multi-level2','Layout',NULL,0,NULL,1,1,'',NULL,'2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(912,911,'0,8,910,911','菜单三级-1','M',NULL,'multi-level3-1','demo/multi-level/children/children/level3-1',NULL,0,1,1,1,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(913,911,'0,8,910,911','菜单三级-2','M',NULL,'multi-level3-2','demo/multi-level/children/children/level3-2',NULL,0,1,1,2,'','','2026-10-20 10:24:22','2026-10-20 10:24:22',NULL),(1000,0,'0','客户管理','C','','/customer','Layout',NULL,0,0,1,1,'el-icon-User','/customer/list','2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1001,9,'0,9','参数(type=1)','M','RouteParamType1','route-param-type1','demo/route-param',NULL,0,1,1,1,'el-icon-Star',NULL,'2026-10-20 10:24:22','2026-10-20 10:24:22','{\"type\": \"1\"}'),(1002,9,'0,9','参数(type=2)','M','RouteParamType2','route-param-type2','demo/route-param',NULL,0,1,1,2,'el-icon-StarFilled',NULL,'2026-10-20 10:24:22','2026-10-20 10:24:22','{\"type\": \"2\"}'),(1010,1000,'0,1000','客户列表','M','Customer','list','customer/index',NULL,0,1,1,1,'el-icon-User',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1011,1010,'0,1000,1010','客户查询','B',NULL,'','','scrm:customer:list',0,0,1,1,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1012,1010,'0,1000,1010','客户新增','B',NULL,'','','scrm:customer:create',0,0,1,2,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1013,1010,'0,1000,1010','客户编辑','B',NULL,'','','scrm:customer:update',0,0,1,3,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1014,1010,'0,1000,1010','客户删除','B',NULL,'','','scrm:customer:delete',0,0,1,4,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1015,1010,'0,1000,1010','客户分配','B',NULL,'','','scrm:customer:assign',0,0,1,5,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1016,1010,'0,1000,1010','客户导出','B',NULL,'','','scrm:customer:export',0,0,1,6,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1020,1000,'0,1000','客户公海','M','CustomerPool','pool','customer/pool',NULL,0,1,1,2,'el-icon-Box',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1021,1020,'0,1000,1020','领取客户','B',NULL,'','','scrm:customer:claim',0,0,1,1,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1030,1000,'0,1000','标签管理','M','CustomerTag','tag','customer/tag/index',NULL,0,1,1,3,'el-icon-CollectionTag',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1031,1030,'0,1000,1030','标签查询','B',NULL,'','','scrm:tag:list',0,0,1,1,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1032,1030,'0,1000,1030','标签新增','B',NULL,'','','scrm:tag:create',0,0,1,2,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1033,1030,'0,1000,1030','标签编辑','B',NULL,'','','scrm:tag:update',0,0,1,3,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(1034,1030,'0,1000,1030','标签删除','B',NULL,'','','scrm:tag:delete',0,0,1,4,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2000,0,'0','销售管理','C','','/sales','Layout',NULL,0,0,1,2,'el-icon-Money','/sales/opportunity','2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2010,2000,'0,2000','跟进记录','M','FollowUp','follow-up','sales/follow-up/index',NULL,0,1,1,1,'el-icon-ChatDotRound',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2011,2010,'0,2000,2010','跟进查询','B',NULL,'','','scrm:follow-up:list',0,0,1,1,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2012,2010,'0,2000,2010','跟进新增','B',NULL,'','','scrm:follow-up:create',0,0,1,2,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2013,2010,'0,2000,2010','跟进编辑','B',NULL,'','','scrm:follow-up:update',0,0,1,3,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2014,2010,'0,2000,2010','跟进删除','B',NULL,'','','scrm:follow-up:delete',0,0,1,4,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2020,2000,'0,2000','商机管理','M','Opportunity','opportunity','sales/opportunity/index',NULL,0,1,1,2,'el-icon-TrendCharts',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2021,2020,'0,2000,2020','商机查询','B',NULL,'','','scrm:opportunity:list',0,0,1,1,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2022,2020,'0,2000,2020','商机新增','B',NULL,'','','scrm:opportunity:create',0,0,1,2,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2023,2020,'0,2000,2020','商机编辑','B',NULL,'','','scrm:opportunity:update',0,0,1,3,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2024,2020,'0,2000,2020','商机删除','B',NULL,'','','scrm:opportunity:delete',0,0,1,4,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2030,2000,'0,2000','合同管理','M','Contract','contract','sales/contract/index',NULL,0,1,1,3,'el-icon-Document',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2031,2030,'0,2000,2030','合同查询','B',NULL,'','','scrm:contract:list',0,0,1,1,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2032,2030,'0,2000,2030','合同新增','B',NULL,'','','scrm:contract:create',0,0,1,2,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2033,2030,'0,2000,2030','合同编辑','B',NULL,'','','scrm:contract:update',0,0,1,3,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2034,2030,'0,2000,2030','合同删除','B',NULL,'','','scrm:contract:delete',0,0,1,4,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(2101,210,'0,1,210','用户查询','B',NULL,'',NULL,'sys:user:list',NULL,NULL,1,1,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2102,210,'0,1,210','用户新增','B',NULL,'',NULL,'sys:user:create',NULL,NULL,1,2,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2103,210,'0,1,210','用户编辑','B',NULL,'',NULL,'sys:user:update',NULL,NULL,1,3,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2104,210,'0,1,210','用户删除','B',NULL,'',NULL,'sys:user:delete',NULL,NULL,1,4,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2105,210,'0,1,210','重置密码','B',NULL,'',NULL,'sys:user:reset-password',NULL,NULL,1,5,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2106,210,'0,1,210','用户导入','B',NULL,'',NULL,'sys:user:import',NULL,NULL,1,6,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2107,210,'0,1,210','用户导出','B',NULL,'',NULL,'sys:user:export',NULL,NULL,1,7,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2201,220,'0,1,220','角色查询','B',NULL,'',NULL,'sys:role:list',NULL,NULL,1,1,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2202,220,'0,1,220','角色新增','B',NULL,'',NULL,'sys:role:create',NULL,NULL,1,2,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2203,220,'0,1,220','角色编辑','B',NULL,'',NULL,'sys:role:update',NULL,NULL,1,3,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2204,220,'0,1,220','角色删除','B',NULL,'',NULL,'sys:role:delete',NULL,NULL,1,4,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2205,220,'0,1,220','角色分配权限','B',NULL,'',NULL,'sys:role:assign',NULL,NULL,1,5,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2301,230,'0,1,230','菜单查询','B',NULL,'',NULL,'sys:menu:list',NULL,NULL,1,1,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2302,230,'0,1,230','菜单新增','B',NULL,'',NULL,'sys:menu:create',NULL,NULL,1,2,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2303,230,'0,1,230','菜单编辑','B',NULL,'',NULL,'sys:menu:update',NULL,NULL,1,3,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2304,230,'0,1,230','菜单删除','B',NULL,'',NULL,'sys:menu:delete',NULL,NULL,1,4,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2401,240,'0,1,240','部门查询','B',NULL,'',NULL,'sys:dept:list',NULL,NULL,1,1,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2402,240,'0,1,240','部门新增','B',NULL,'',NULL,'sys:dept:create',NULL,NULL,1,2,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2403,240,'0,1,240','部门编辑','B',NULL,'',NULL,'sys:dept:update',NULL,NULL,1,3,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2404,240,'0,1,240','部门删除','B',NULL,'',NULL,'sys:dept:delete',NULL,NULL,1,4,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2501,250,'0,1,250','字典查询','B',NULL,'',NULL,'sys:dict:list',NULL,NULL,1,1,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2502,250,'0,1,250','字典新增','B',NULL,'',NULL,'sys:dict:create',NULL,NULL,1,2,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2503,250,'0,1,250','字典编辑','B',NULL,'',NULL,'sys:dict:update',NULL,NULL,1,3,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2504,250,'0,1,250','字典删除','B',NULL,'',NULL,'sys:dict:delete',NULL,NULL,1,4,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2511,251,'0,1,251','字典项查询','B',NULL,'',NULL,'sys:dict-item:list',NULL,NULL,1,1,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2512,251,'0,1,251','字典项新增','B',NULL,'',NULL,'sys:dict-item:create',NULL,NULL,1,2,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2513,251,'0,1,251','字典项编辑','B',NULL,'',NULL,'sys:dict-item:update',NULL,NULL,1,3,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2514,251,'0,1,251','字典项删除','B',NULL,'',NULL,'sys:dict-item:delete',NULL,NULL,1,4,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2601,260,'0,1,260','日志查询','B',NULL,'',NULL,'sys:log:list',NULL,NULL,1,1,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2701,270,'0,1,270','系统配置查询','B',NULL,'',NULL,'sys:config:list',0,1,1,1,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2702,270,'0,1,270','系统配置新增','B',NULL,'',NULL,'sys:config:create',0,1,1,2,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2703,270,'0,1,270','系统配置修改','B',NULL,'',NULL,'sys:config:update',0,1,1,3,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2704,270,'0,1,270','系统配置删除','B',NULL,'',NULL,'sys:config:delete',0,1,1,4,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2705,270,'0,1,270','系统配置刷新','B',NULL,'',NULL,'sys:config:refresh',0,1,1,5,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2801,280,'0,1,280','通知查询','B',NULL,'',NULL,'sys:notice:list',NULL,NULL,1,1,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2802,280,'0,1,280','通知新增','B',NULL,'',NULL,'sys:notice:create',NULL,NULL,1,2,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2803,280,'0,1,280','通知编辑','B',NULL,'',NULL,'sys:notice:update',NULL,NULL,1,3,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2804,280,'0,1,280','通知删除','B',NULL,'',NULL,'sys:notice:delete',NULL,NULL,1,4,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2805,280,'0,1,280','通知发布','B',NULL,'',NULL,'sys:notice:publish',0,1,1,5,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(2806,280,'0,1,280','通知撤回','B',NULL,'',NULL,'sys:notice:revoke',0,1,1,6,'',NULL,'2026-10-20 10:24:21','2026-10-20 10:24:21',NULL),(3000,0,'0','营销管理','C','','/marketing','Layout',NULL,0,0,1,3,'el-icon-Promotion','/marketing/campaign','2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(3010,3000,'0,3000','活动管理','M','Campaign','campaign','marketing/campaign/index',NULL,0,1,1,1,'el-icon-Tickets',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(3011,3010,'0,3000,3010','活动查询','B',NULL,'','','scrm:campaign:list',0,0,1,1,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(3012,3010,'0,3000,3010','活动新增','B',NULL,'','','scrm:campaign:create',0,0,1,2,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(3013,3010,'0,3000,3010','活动编辑','B',NULL,'','','scrm:campaign:update',0,0,1,3,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL),(3014,3010,'0,3000,3010','活动删除','B',NULL,'','','scrm:campaign:delete',0,0,1,4,'',NULL,'2026-10-20 10:27:23','2026-10-20 10:27:23',NULL);
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_notice`
--

DROP TABLE IF EXISTS `sys_notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_notice` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(50) DEFAULT NULL COMMENT '通知标题',
  `content` text COMMENT '通知内容',
  `type` tinyint NOT NULL COMMENT '通知类型（关联字典编码：notice_type）',
  `level` varchar(5) NOT NULL COMMENT '通知等级（字典code：notice_level）',
  `target_type` tinyint NOT NULL COMMENT '目标类型（1: 全体, 2: 指定）',
  `target_user_ids` varchar(255) DEFAULT NULL COMMENT '目标人ID集合（多个使用英文逗号,分割）',
  `publisher_id` bigint DEFAULT NULL COMMENT '发布人ID',
  `publish_status` tinyint DEFAULT '0' COMMENT '发布状态（0: 未发布, 1: 已发布, -1: 已撤回）',
  `publish_time` datetime DEFAULT NULL COMMENT '发布时间',
  `revoke_time` datetime DEFAULT NULL COMMENT '撤回时间',
  `create_by` bigint NOT NULL COMMENT '创建人ID',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '是否删除（0: 未删除, 1: 已删除）',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统通知公告表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_notice`
--

LOCK TABLES `sys_notice` WRITE;
/*!40000 ALTER TABLE `sys_notice` DISABLE KEYS */;
INSERT INTO `sys_notice` VALUES (1,'v3.0.0 版本发布 - 多租户功能上线','<p>🎉 新版本发布，主要更新内容：</p><p>1. 新增多租户功能，支持租户隔离和数据管理</p><p>2. 优化系统性能，提升响应速度</p><p>3. 完善权限管理，增强安全性</p><p>4. 修复已知问题，提升系统稳定性</p>',1,'H',1,NULL,1,1,'2024-12-15 10:00:00',NULL,1,'2024-12-15 10:00:00',1,'2024-12-15 10:00:00',0),(2,'系统维护通知 - 2024年12月20日','<p>⏰ 系统维护通知</p><p>系统将于 <strong>2024年12月20日（本周五）凌晨 2:00-4:00</strong> 进行例行维护升级。</p><p>维护期间系统将暂停服务，请提前做好数据备份工作。</p><p>给您带来的不便，敬请谅解！</p>',2,'H',1,NULL,1,1,'2024-12-18 14:30:00',NULL,1,'2024-12-18 14:30:00',1,'2024-12-18 14:30:00',0),(3,'安全提醒 - 防范钓鱼邮件','<p>⚠️ 安全提醒</p><p>近期发现有不法分子通过钓鱼邮件进行网络攻击，请大家提高警惕：</p><p>1. 不要点击来源不明的邮件链接</p><p>2. 不要下载可疑附件</p><p>3. 遇到可疑邮件请及时联系IT部门</p><p>4. 定期修改密码，使用强密码策略</p>',3,'H',1,NULL,1,1,'2024-12-10 09:00:00',NULL,1,'2024-12-10 09:00:00',1,'2024-12-10 09:00:00',0),(4,'元旦假期安排通知','<p>📅 元旦假期安排</p><p>根据国家法定节假日安排，公司元旦假期时间为：</p><p><strong>2024年12月30日（周一）至 2025年1月1日（周三）</strong>，共3天。</p><p>2024年12月29日（周日）正常上班。</p><p>祝大家元旦快乐，假期愉快！</p>',4,'M',1,NULL,1,1,'2024-12-25 16:00:00',NULL,1,'2024-12-25 16:00:00',1,'2024-12-25 16:00:00',0),(5,'新产品发布会邀请','<p>🎊 新产品发布会邀请</p><p>公司将于 <strong>2025年1月15日下午14:00</strong> 在总部会议室举办新产品发布会。</p><p>届时将展示最新研发的产品和技术成果，欢迎全体员工参加。</p><p>请各部门提前安排好工作，准时参加。</p>',5,'M',1,NULL,1,1,'2024-12-28 11:00:00',NULL,1,'2024-12-28 11:00:00',1,'2024-12-28 11:00:00',0),(6,'v2.16.1 版本更新','<p>✨ 版本更新</p><p>v2.16.1 版本已发布，主要修复内容：</p><p>1. 修复 WebSocket 重复连接导致的后台线程阻塞问题</p><p>2. 优化通知公告功能，提升用户体验</p><p>3. 修复部分已知bug</p><p>建议尽快更新到最新版本。</p>',1,'M',1,NULL,1,1,'2024-12-05 15:30:00',NULL,1,'2024-12-05 15:30:00',1,'2024-12-05 15:30:00',0),(7,'年终总结会议通知','<p>📋 年终总结会议通知</p><p>各部门年终总结会议将于 <strong>2024年12月30日上午9:00</strong> 召开。</p><p>请各部门负责人提前准备好年度工作总结和下年度工作计划。</p><p>会议地点：总部大会议室</p>',5,'M',2,'1,2',1,1,'2024-12-22 10:00:00',NULL,1,'2024-12-22 10:00:00',1,'2024-12-22 10:00:00',0),(8,'系统功能优化完成','<p>✅ 系统功能优化</p><p>已完成以下功能优化：</p><p>1. 优化用户管理界面，提升操作体验</p><p>2. 增强数据导出功能，支持更多格式</p><p>3. 优化搜索功能，提升查询效率</p><p>4. 修复部分界面显示问题</p>',1,'L',1,NULL,1,1,'2024-12-12 14:20:00',NULL,1,'2024-12-12 14:20:00',1,'2024-12-12 14:20:00',0),(9,'员工培训计划','<p>📚 员工培训计划</p><p>为提升员工专业技能，公司将于 <strong>2025年1月8日-10日</strong> 组织技术培训。</p><p>培训内容：</p><p>1. 新技术框架应用</p><p>2. 代码规范与最佳实践</p><p>3. 系统架构设计</p><p>请各部门合理安排工作，确保培训顺利进行。</p>',5,'M',1,NULL,1,1,'2024-12-20 09:30:00',NULL,1,'2024-12-20 09:30:00',1,'2024-12-20 09:30:00',0),(10,'数据备份提醒','<p>💾 数据备份提醒</p><p>请各部门注意定期备份重要数据，建议每周至少备份一次。</p><p>备份方式：</p><p>1. 使用系统自带备份功能</p><p>2. 手动导出重要数据</p><p>3. 联系IT部门协助备份</p><p>数据安全，人人有责！</p>',3,'L',1,NULL,1,1,'2024-12-08 08:00:00',NULL,1,'2024-12-08 08:00:00',1,'2024-12-08 08:00:00',0);
/*!40000 ALTER TABLE `sys_notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role`
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL COMMENT '角色名称',
  `code` varchar(32) NOT NULL COMMENT '角色编码',
  `sort` int DEFAULT NULL COMMENT '显示顺序',
  `status` tinyint(1) DEFAULT '1' COMMENT '角色状态(1-正常 0-停用)',
  `data_scope` tinyint DEFAULT NULL COMMENT '数据权限(1-所有数据 2-部门及子部门数据 3-本部门数据 4-本人数据 5-自定义部门数据)',
  `create_by` bigint DEFAULT NULL COMMENT '创建人 ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `update_by` bigint DEFAULT NULL COMMENT '更新人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_name` (`name`) USING BTREE COMMENT '角色名称唯一索引',
  UNIQUE KEY `uk_code` (`code`) USING BTREE COMMENT '角色编码唯一索引'
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统角色表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role`
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` VALUES (1,'超级管理员','ROOT',1,1,1,NULL,'2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',0),(2,'系统管理员','ADMIN',2,1,1,NULL,'2026-10-20 10:24:22',NULL,NULL,0),(3,'访问游客','GUEST',3,1,3,NULL,'2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',0),(4,'部门主管','DEPT_MANAGER',4,1,2,NULL,'2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',0),(5,'部门成员','DEPT_MEMBER',5,1,3,NULL,'2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',0),(6,'普通员工','EMPLOYEE',6,1,4,NULL,'2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',0),(7,'自定义权限用户','CUSTOM_USER',7,1,5,NULL,'2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',0);
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_dept`
--

DROP TABLE IF EXISTS `sys_role_dept`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_dept` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `dept_id` bigint NOT NULL COMMENT '部门ID',
  UNIQUE KEY `uk_roleid_deptid` (`role_id`,`dept_id`) USING BTREE COMMENT '角色部门唯一索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色部门关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_dept`
--

LOCK TABLES `sys_role_dept` WRITE;
/*!40000 ALTER TABLE `sys_role_dept` DISABLE KEYS */;
INSERT INTO `sys_role_dept` VALUES (7,1),(7,2);
/*!40000 ALTER TABLE `sys_role_dept` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_role_menu`
--

DROP TABLE IF EXISTS `sys_role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menu` (
  `role_id` bigint NOT NULL COMMENT '角色ID',
  `menu_id` bigint NOT NULL COMMENT '菜单ID',
  UNIQUE KEY `uk_roleid_menuid` (`role_id`,`menu_id`) USING BTREE COMMENT '角色菜单唯一索引'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色菜单关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_role_menu`
--

LOCK TABLES `sys_role_menu` WRITE;
/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;
INSERT INTO `sys_role_menu` VALUES (2,1),(2,2),(2,4),(2,5),(2,6),(2,7),(2,8),(2,9),(2,210),(2,220),(2,230),(2,240),(2,250),(2,251),(2,260),(2,270),(2,280),(2,310),(2,501),(2,502),(2,503),(2,504),(2,601),(2,701),(2,702),(2,703),(2,704),(2,705),(2,706),(2,707),(2,708),(2,709),(2,801),(2,802),(2,803),(2,804),(2,910),(2,911),(2,912),(2,913),(2,1000),(2,1001),(2,1002),(2,1010),(2,1011),(2,1012),(2,1013),(2,1014),(2,1015),(2,1016),(2,1020),(2,1021),(2,1030),(2,1031),(2,1032),(2,1033),(2,1034),(2,2000),(2,2010),(2,2011),(2,2012),(2,2013),(2,2014),(2,2020),(2,2021),(2,2022),(2,2023),(2,2024),(2,2030),(2,2031),(2,2032),(2,2033),(2,2034),(2,2101),(2,2102),(2,2103),(2,2104),(2,2105),(2,2106),(2,2107),(2,2201),(2,2202),(2,2203),(2,2204),(2,2205),(2,2301),(2,2302),(2,2303),(2,2304),(2,2401),(2,2402),(2,2403),(2,2404),(2,2501),(2,2502),(2,2503),(2,2504),(2,2511),(2,2512),(2,2513),(2,2514),(2,2601),(2,2701),(2,2702),(2,2703),(2,2704),(2,2705),(2,2801),(2,2802),(2,2803),(2,2804),(2,2805),(2,2806),(2,3000),(2,3010),(2,3011),(2,3012),(2,3013),(2,3014),(4,1),(4,210),(4,220),(4,1000),(4,1010),(4,1011),(4,1012),(4,1013),(4,1014),(4,1015),(4,1016),(4,1020),(4,1021),(4,1030),(4,1031),(4,1032),(4,1033),(4,1034),(4,2000),(4,2010),(4,2011),(4,2012),(4,2013),(4,2014),(4,2020),(4,2021),(4,2022),(4,2023),(4,2024),(4,2030),(4,2031),(4,2032),(4,2033),(4,2034),(4,2101),(4,2102),(4,2103),(4,2104),(4,2105),(4,2106),(4,2107),(4,2201),(4,2202),(4,2203),(4,2204),(4,2205),(4,3000),(4,3010),(4,3011),(4,3012),(4,3013),(4,3014),(5,1),(5,210),(5,220),(5,1000),(5,1010),(5,1011),(5,1012),(5,1013),(5,1014),(5,1020),(5,1021),(5,1030),(5,1031),(5,2000),(5,2010),(5,2011),(5,2012),(5,2013),(5,2014),(5,2020),(5,2021),(5,2022),(5,2023),(5,2024),(5,2030),(5,2031),(5,2032),(5,2033),(5,2034),(5,2101),(5,2102),(5,2103),(5,2104),(5,2105),(5,2106),(5,2107),(5,2201),(5,2202),(5,2203),(5,2204),(5,2205),(5,3000),(5,3010),(5,3011),(5,3012),(5,3013),(5,3014),(6,1),(6,210),(6,220),(6,1000),(6,1010),(6,1011),(6,1012),(6,1013),(6,1014),(6,1020),(6,1021),(6,1030),(6,1031),(6,2000),(6,2010),(6,2011),(6,2012),(6,2013),(6,2014),(6,2020),(6,2021),(6,2022),(6,2023),(6,2024),(6,2030),(6,2031),(6,2032),(6,2033),(6,2034),(6,2101),(6,2102),(6,2103),(6,2104),(6,2105),(6,2106),(6,2107),(6,2201),(6,2202),(6,2203),(6,2204),(6,2205),(6,3000),(6,3010),(6,3011),(6,3012),(6,3013),(6,3014),(7,1),(7,210),(7,220),(7,2101),(7,2102),(7,2103),(7,2104),(7,2105),(7,2106),(7,2107),(7,2201),(7,2202),(7,2203),(7,2204),(7,2205);
/*!40000 ALTER TABLE `sys_role_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user`
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(64) DEFAULT NULL COMMENT '用户名',
  `nickname` varchar(64) DEFAULT NULL COMMENT '昵称',
  `gender` tinyint(1) DEFAULT '1' COMMENT '性别((1-男 2-女 0-保密)',
  `password` varchar(100) DEFAULT NULL COMMENT '密码',
  `dept_id` int DEFAULT NULL COMMENT '部门ID',
  `avatar` varchar(255) DEFAULT NULL COMMENT '用户头像',
  `mobile` varchar(20) DEFAULT NULL COMMENT '联系方式',
  `status` tinyint(1) DEFAULT '1' COMMENT '状态(1-正常 0-禁用)',
  `email` varchar(128) DEFAULT NULL COMMENT '用户邮箱',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `create_by` bigint DEFAULT NULL COMMENT '创建人ID',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `update_by` bigint DEFAULT NULL COMMENT '修改人ID',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除标识(0-未删除 1-已删除)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统用户表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user`
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` VALUES (1,'root','有来技术',0,'$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq',NULL,'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif','18812345677',1,'youlaitech@163.com','2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',NULL,0),(2,'admin','系统管理员',1,'$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq',1,'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif','18812345678',1,'youlaitech@163.com','2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',NULL,0),(3,'test','测试小用户',1,'$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq',3,'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif','18812345679',1,'youlaitech@163.com','2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',NULL,0),(4,'dept_manager','部门主管',1,'$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq',1,'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif','18812345680',1,'manager@youlaitech.com','2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',NULL,0),(5,'dept_member','部门成员',1,'$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq',1,'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif','18812345681',1,'member@youlaitech.com','2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',NULL,0),(6,'employee','普通员工',1,'$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq',2,'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif','18812345682',1,'employee@youlaitech.com','2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',NULL,0),(7,'custom_user','自定义权限用户',1,'$2a$10$xVWsNOhHrCxh5UbpCE7/HuJ.PAOKcYAqRxD2CO2nVnJS.IAXkr5aq',3,'https://foruda.gitee.com/images/1723603502796844527/03cdca2a_716974.gif','18812345683',1,'custom@youlaitech.com','2026-10-20 10:24:22',NULL,'2026-10-20 10:24:22',NULL,0);
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_notice`
--

DROP TABLE IF EXISTS `sys_user_notice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_notice` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `notice_id` bigint NOT NULL COMMENT '公共通知id',
  `user_id` bigint NOT NULL COMMENT '用户id',
  `is_read` tinyint DEFAULT '0' COMMENT '读取状态（0: 未读, 1: 已读）',
  `read_time` datetime DEFAULT NULL COMMENT '阅读时间',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `is_deleted` tinyint DEFAULT '0' COMMENT '逻辑删除(0: 未删除, 1: 已删除)',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户通知公告关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_notice`
--

LOCK TABLES `sys_user_notice` WRITE;
/*!40000 ALTER TABLE `sys_user_notice` DISABLE KEYS */;
INSERT INTO `sys_user_notice` VALUES (1,1,2,1,NULL,'2026-10-20 10:24:23','2026-10-20 10:24:23',0),(2,2,2,1,NULL,'2026-10-20 10:24:23','2026-10-20 10:24:23',0),(3,3,2,1,NULL,'2026-10-20 10:24:23','2026-10-20 10:24:23',0),(4,4,2,1,NULL,'2026-10-20 10:24:23','2026-10-20 10:24:23',0),(5,5,2,1,NULL,'2026-10-20 10:24:23','2026-10-20 10:24:23',0),(6,6,2,1,NULL,'2026-10-20 10:24:23','2026-10-20 10:24:23',0),(7,7,2,1,NULL,'2026-10-20 10:24:23','2026-10-20 10:24:23',0),(8,8,2,1,NULL,'2026-10-20 10:24:23','2026-10-20 10:24:23',0),(9,9,2,1,NULL,'2026-10-20 10:24:23','2026-10-20 10:24:23',0),(10,10,2,1,NULL,'2026-10-20 10:24:23','2026-10-20 10:24:23',0);
/*!40000 ALTER TABLE `sys_user_notice` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_role`
--

DROP TABLE IF EXISTS `sys_user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_role` (
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `role_id` bigint NOT NULL COMMENT '角色ID',
  PRIMARY KEY (`user_id`,`role_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户角色关联表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_role`
--

LOCK TABLES `sys_user_role` WRITE;
/*!40000 ALTER TABLE `sys_user_role` DISABLE KEYS */;
INSERT INTO `sys_user_role` VALUES (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7);
/*!40000 ALTER TABLE `sys_user_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sys_user_social`
--

DROP TABLE IF EXISTS `sys_user_social`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_social` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint NOT NULL COMMENT '用户ID',
  `platform` varchar(20) NOT NULL COMMENT '平台类型(WECHAT_MINI/WECHAT_MP/ALIPAY/QQ/APPLE)',
  `openid` varchar(64) NOT NULL COMMENT '平台openid',
  `unionid` varchar(64) DEFAULT NULL COMMENT '微信unionid',
  `nickname` varchar(64) DEFAULT NULL COMMENT '第三方昵称',
  `avatar` varchar(255) DEFAULT NULL COMMENT '第三方头像URL',
  `session_key` varchar(128) DEFAULT NULL COMMENT '微信session_key',
  `verified` tinyint(1) DEFAULT '1' COMMENT '是否已验证(1-已验证 0-未验证)',
  `create_time` datetime DEFAULT NULL COMMENT '绑定时间',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_platform_openid` (`platform`,`openid`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_unionid` (`unionid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户第三方账号绑定表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sys_user_social`
--

LOCK TABLES `sys_user_social` WRITE;
/*!40000 ALTER TABLE `sys_user_social` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_user_social` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'youmi_scrm'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-20 14:21:48
