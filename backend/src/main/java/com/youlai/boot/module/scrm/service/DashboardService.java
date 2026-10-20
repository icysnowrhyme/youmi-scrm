package com.youlai.boot.module.scrm.service;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.youlai.boot.module.scrm.mapper.ContractMapper;
import com.youlai.boot.module.scrm.mapper.CustomerMapper;
import com.youlai.boot.module.scrm.mapper.FollowUpMapper;
import com.youlai.boot.module.scrm.mapper.OpportunityMapper;
import com.youlai.boot.module.scrm.model.bo.SalesRankBO;
import com.youlai.boot.module.scrm.model.bo.StageStatBO;
import com.youlai.boot.module.scrm.model.bo.TrendPointBO;
import com.youlai.boot.module.scrm.model.entity.Contract;
import com.youlai.boot.module.scrm.model.entity.Customer;
import com.youlai.boot.module.scrm.model.entity.FollowUp;
import com.youlai.boot.module.scrm.model.entity.Opportunity;
import com.youlai.boot.module.scrm.model.vo.DashboardVO;
import com.youlai.boot.module.scrm.model.vo.SalesRankVO;
import com.youlai.boot.module.scrm.support.ScrmDataScope;
import com.youlai.boot.system.model.entity.User;
import com.youlai.boot.system.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final CustomerService customerService;
    private final FollowUpService followUpService;
    private final ContractService contractService;
    private final CustomerMapper customerMapper;
    private final FollowUpMapper followUpMapper;
    private final OpportunityMapper opportunityMapper;
    private final ContractMapper contractMapper;
    private final UserService userService;

    public DashboardVO getDashboard(Integer days) {
        int span = days == null ? 30 : Math.min(Math.max(days, 7), 90);
        Long scope = ScrmDataScope.scopeOwnerId();
        LocalDate today = LocalDate.now();
        LocalDateTime trendStart = today.minusDays(span - 1).atStartOfDay();
        LocalDateTime monthStart = today.withDayOfMonth(1).atStartOfDay();

        DashboardVO vo = new DashboardVO();

        vo.setCustomerTotal(customerService.count(customerWrapper(scope)));
        vo.setCustomerNew(customerService.count(customerWrapper(scope)
                .ge(Customer::getCreateTime, monthStart)));
        vo.setPoolCount(customerService.count(new LambdaQueryWrapper<Customer>()
                .isNull(Customer::getOwnerId)));

        LambdaQueryWrapper<FollowUp> followWrapper = new LambdaQueryWrapper<FollowUp>()
                .ge(FollowUp::getCreateTime, monthStart);
        if (scope != null) {
            followWrapper.eq(FollowUp::getCreateBy, scope);
        }
        vo.setFollowUpCount(followUpService.count(followWrapper));

        vo.setOpportunityAmount(opportunityMapper.sumOpenAmount(scope));

        List<Contract> monthContracts = contractService.list(new LambdaQueryWrapper<Contract>()
                .in(Contract::getStatus, 2, 3)
                .ge(Contract::getSignDate, today.withDayOfMonth(1))
                .eq(scope != null, Contract::getOwnerId, scope));
        vo.setContractAmount(monthContracts.stream()
                .map(Contract::getAmount)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add));

        long won = opportunityMapper.selectCount(new LambdaQueryWrapper<Opportunity>()
                .eq(Opportunity::getStage, 5)
                .eq(scope != null, Opportunity::getOwnerId, scope));
        long lost = opportunityMapper.selectCount(new LambdaQueryWrapper<Opportunity>()
                .eq(Opportunity::getStage, 6)
                .eq(scope != null, Opportunity::getOwnerId, scope));
        long closed = won + lost;
        vo.setWinRate(closed == 0 ? 0 : (int) Math.round(won * 100.0 / closed));

        vo.setCustomerTrend(fillTrend(customerMapper.countByDay(trendStart, scope), span));
        vo.setFollowTrend(fillTrend(followUpMapper.countByDay(trendStart, scope), span));
        vo.setSourceStats(customerMapper.countBySource(scope));
        vo.setStageStats(opportunityMapper.stageStats(scope));
        vo.setRecentFollowUps(followUpService.listRecent(8));
        vo.setTodoCustomers(customerService.listTodo(8));
        vo.setSalesRanking(toSalesRank(contractMapper.salesRanking(today.withDayOfMonth(1), scope)));
        return vo;
    }

    private LambdaQueryWrapper<Customer> customerWrapper(Long scope) {
        return new LambdaQueryWrapper<Customer>().eq(scope != null, Customer::getOwnerId, scope);
    }

    private List<TrendPointBO> fillTrend(List<TrendPointBO> points, int span) {
        Map<String, Long> counts = new LinkedHashMap<>();
        LocalDate today = LocalDate.now();
        for (int i = span - 1; i >= 0; i--) {
            counts.put(today.minusDays(i).toString(), 0L);
        }
        for (TrendPointBO point : points) {
            if (counts.containsKey(point.getDate())) {
                counts.put(point.getDate(), point.getCount());
            }
        }
        List<TrendPointBO> result = new ArrayList<>(counts.size());
        counts.forEach((date, count) -> {
            TrendPointBO point = new TrendPointBO();
            point.setDate(date);
            point.setCount(count);
            result.add(point);
        });
        return result;
    }

    private List<SalesRankVO> toSalesRank(List<SalesRankBO> ranks) {
        if (ranks.isEmpty()) {
            return List.of();
        }
        List<Long> ownerIds = ranks.stream().map(SalesRankBO::getOwnerId).filter(Objects::nonNull).distinct().toList();
        Map<Long, String> names = ownerIds.isEmpty() ? Map.of()
                : userService.listByIds(ownerIds).stream()
                .collect(Collectors.toMap(User::getId,
                        u -> StrUtil.blankToDefault(u.getNickname(), u.getUsername())));
        return ranks.stream().map(r -> {
            SalesRankVO vo = new SalesRankVO();
            vo.setOwnerId(r.getOwnerId());
            vo.setOwnerName(names.getOrDefault(r.getOwnerId(), "未分配"));
            vo.setAmount(r.getAmount());
            return vo;
        }).toList();
    }
}
