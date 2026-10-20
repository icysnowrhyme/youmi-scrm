package com.youlai.boot.module.scrm.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.youlai.boot.module.scrm.model.bo.NameValueBO;
import com.youlai.boot.module.scrm.model.bo.TrendPointBO;
import com.youlai.boot.module.scrm.model.entity.Customer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface CustomerMapper extends BaseMapper<Customer> {

    @Select("""
            <script>
            SELECT DATE_FORMAT(create_time, '%Y-%m-%d') AS date, COUNT(*) AS count
            FROM biz_customer
            WHERE is_deleted = 0 AND create_time &gt;= #{start}
            <if test="ownerId != null"> AND owner_id = #{ownerId}</if>
            GROUP BY DATE_FORMAT(create_time, '%Y-%m-%d')
            ORDER BY date
            </script>
            """)
    List<TrendPointBO> countByDay(@Param("start") LocalDateTime start, @Param("ownerId") Long ownerId);

    @Select("""
            <script>
            SELECT CAST(source AS CHAR) AS name, COUNT(*) AS value
            FROM biz_customer
            WHERE is_deleted = 0
            <if test="ownerId != null"> AND owner_id = #{ownerId}</if>
            GROUP BY source
            ORDER BY source
            </script>
            """)
    List<NameValueBO> countBySource(@Param("ownerId") Long ownerId);
}
