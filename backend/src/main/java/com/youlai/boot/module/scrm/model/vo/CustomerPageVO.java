package com.youlai.boot.module.scrm.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class CustomerPageVO {

    private Long id;
    private String name;
    private String shortName;
    private String phone;
    private String company;
    private String wechat;
    private String email;
    private Integer gender;
    private String position;
    private String address;
    private String remark;
    private String level;
    private Integer source;
    private Integer status;
    private Long ownerId;
    private String ownerName;
    private Long deptId;
    private List<TagVO> tags;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime lastFollowTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime nextFollowTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
