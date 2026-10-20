package com.youlai.boot.module.scrm.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.youlai.boot.module.scrm.model.bo.StageStatBO;
import com.youlai.boot.module.scrm.model.entity.Opportunity;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
import java.util.List;

@Mapper
public interface OpportunityMapper extends BaseMapper<Opportunity> {

    @Select("""
            <script>
            SELECT stage, COUNT(*) AS count, IFNULL(SUM(amount), 0) AS amount
            FROM biz_opportunity
            WHERE is_deleted = 0
            <if test="ownerId != null"> AND owner_id = #{ownerId}</if>
            GROUP BY stage
            ORDER BY stage
            </script>
            """)
    List<StageStatBO> stageStats(@Param("ownerId") Long ownerId);

    @Select("""
            <script>
            SELECT IFNULL(SUM(amount), 0)
            FROM biz_opportunity
            WHERE is_deleted = 0 AND stage &lt; 5
            <if test="ownerId != null"> AND owner_id = #{ownerId}</if>
            </script>
            """)
    BigDecimal sumOpenAmount(@Param("ownerId") Long ownerId);
}
