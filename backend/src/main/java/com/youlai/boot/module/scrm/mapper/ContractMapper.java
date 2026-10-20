package com.youlai.boot.module.scrm.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.youlai.boot.module.scrm.model.bo.SalesRankBO;
import com.youlai.boot.module.scrm.model.entity.Contract;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDate;
import java.util.List;

@Mapper
public interface ContractMapper extends BaseMapper<Contract> {

    @Select("""
            <script>
            SELECT owner_id AS ownerId, SUM(amount) AS amount
            FROM biz_contract
            WHERE is_deleted = 0 AND status IN (2, 3) AND sign_date &gt;= #{start}
            <if test="ownerId != null"> AND owner_id = #{ownerId}</if>
            GROUP BY owner_id
            ORDER BY amount DESC
            LIMIT 5
            </script>
            """)
    List<SalesRankBO> salesRanking(@Param("start") LocalDate start, @Param("ownerId") Long ownerId);
}
