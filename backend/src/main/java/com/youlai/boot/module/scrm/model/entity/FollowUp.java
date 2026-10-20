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
@TableName("biz_follow_up")
public class FollowUp extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long customerId;
    private Integer type;
    private String content;
    private String result;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime nextFollowTime;

    private Long createBy;
    private Long updateBy;
    private Integer isDeleted;
}
