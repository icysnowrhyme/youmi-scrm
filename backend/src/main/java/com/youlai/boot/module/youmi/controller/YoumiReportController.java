package com.youlai.boot.module.youmi.controller;

import com.youlai.boot.core.web.Result;
import com.youlai.boot.module.youmi.model.vo.PerformanceRowVO;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Tag(name = "20.友米报表")
@RestController
@RequestMapping("/api/v1/youmi/reports")
@RequiredArgsConstructor
public class YoumiReportController {

    private final JdbcTemplate jdbcTemplate;

    @Operation(summary = "员工绩效统计")
    @GetMapping("/performance")
    public Result<List<PerformanceRowVO>> getPerformance(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        LocalDate end = endDate == null || endDate.isBlank() ? LocalDate.now() : LocalDate.parse(endDate);
        LocalDate start = startDate == null || startDate.isBlank() ? end.minusDays(6) : LocalDate.parse(startDate);
        LocalDateTime from = start.atStartOfDay();
        LocalDateTime to = end.plusDays(1).atStartOfDay();

        String sql = """
                SELECT u.id AS user_id,
                       COALESCE(NULLIF(u.nickname, ''), u.username) AS user_name,
                       COALESCE(d.name, '') AS dept_name,
                       (SELECT COUNT(*) FROM biz_customer c
                         WHERE c.owner_id = u.id AND c.is_deleted = 0) AS customer_count,
                       (SELECT COUNT(*) FROM biz_follow_up f
                         WHERE f.create_by = u.id AND f.is_deleted = 0
                           AND f.create_time >= ? AND f.create_time < ?) AS follow_count,
                       (SELECT COUNT(*) FROM biz_contract ct
                         WHERE ct.owner_id = u.id AND ct.is_deleted = 0
                           AND ct.create_time >= ? AND ct.create_time < ?) AS order_count,
                       (SELECT COALESCE(SUM(ct.amount), 0) FROM biz_contract ct
                         WHERE ct.owner_id = u.id AND ct.is_deleted = 0
                           AND ct.create_time >= ? AND ct.create_time < ?) AS order_amount,
                       (SELECT COUNT(*) FROM biz_contract ct
                         WHERE ct.owner_id = u.id AND ct.is_deleted = 0 AND ct.status = 3) AS won_count
                FROM sys_user u
                LEFT JOIN sys_dept d ON d.id = u.dept_id
                WHERE u.is_deleted = 0 AND u.status = 1
                ORDER BY order_amount DESC, u.id
                """;

        List<PerformanceRowVO> rows = jdbcTemplate.query(sql, (rs, rowNum) -> {
            PerformanceRowVO vo = new PerformanceRowVO();
            vo.setUserId(rs.getLong("user_id"));
            vo.setUserName(rs.getString("user_name"));
            vo.setDeptName(rs.getString("dept_name"));
            vo.setCustomerCount(rs.getLong("customer_count"));
            vo.setFollowCount(rs.getLong("follow_count"));
            vo.setOrderCount(rs.getLong("order_count"));
            vo.setOrderAmount(rs.getBigDecimal("order_amount"));
            long won = rs.getLong("won_count");
            long orders = rs.getLong("order_count");
            vo.setWinRate(orders == 0 ? 0 : (int) Math.round(won * 100.0 / orders));
            return vo;
        }, from, to, from, to, from, to);

        return Result.success(rows);
    }
}
