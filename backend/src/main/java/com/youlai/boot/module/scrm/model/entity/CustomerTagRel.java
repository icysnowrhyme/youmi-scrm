package com.youlai.boot.module.scrm.model.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;

@Getter
@Setter
@TableName("rel_customer_tag")
public class CustomerTagRel implements Serializable {

    private Long customerId;
    private Long tagId;
}
