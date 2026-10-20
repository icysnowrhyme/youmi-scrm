package com.youlai.boot.module.scrm.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youlai.boot.common.base.BaseEntity;
import lombok.Getter;
import lombok.Setter;

import java.io.Serial;
import java.time.LocalDateTime;

@Getter
@Setter
@TableName("biz_customer")
public class Customer extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private String name;
    private String shortName;
    private String phone;
    private String wechat;
    private String email;
    private Integer gender;
    private String company;
    private String position;
    private String industry;
    private String level;
    private Integer source;
    private Integer status;
    private Long ownerId;
    private Long deptId;
    private String address;
    private String remark;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lastFollowTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime nextFollowTime;

    private Long createBy;
    private Long updateBy;
    private Integer isDeleted;
}
