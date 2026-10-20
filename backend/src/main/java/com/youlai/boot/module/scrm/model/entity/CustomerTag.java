package com.youlai.boot.module.scrm.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.youlai.boot.common.base.BaseEntity;
import lombok.Getter;
import lombok.Setter;

import java.io.Serial;

@Getter
@Setter
@TableName("biz_customer_tag")
public class CustomerTag extends BaseEntity {

    @Serial
    private static final long serialVersionUID = 1L;

    private String name;
    private String color;
    private Integer sort;
    private Long createBy;
    private Long updateBy;
    private Integer isDeleted;
}
