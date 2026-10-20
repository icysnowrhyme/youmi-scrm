package com.youlai.boot.module.scrm.service;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youlai.boot.core.exception.BusinessException;
import com.youlai.boot.module.scrm.mapper.OpportunityMapper;
import com.youlai.boot.module.scrm.model.entity.Customer;
import com.youlai.boot.module.scrm.model.entity.Opportunity;
import com.youlai.boot.module.scrm.model.form.OpportunityForm;
import com.youlai.boot.module.scrm.model.query.OpportunityQuery;
import com.youlai.boot.module.scrm.model.vo.OpportunityVO;
import com.youlai.boot.module.scrm.support.ScrmDataScope;
import com.youlai.boot.security.util.SecurityUtils;
import com.youlai.boot.system.model.entity.User;
import com.youlai.boot.system.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OpportunityService extends ServiceImpl<OpportunityMapper, Opportunity> {

    private final CustomerService customerService;
    private final UserService userService;

    public IPage<OpportunityVO> getPage(OpportunityQuery query) {
        LambdaQueryWrapper<Opportunity> wrapper = new LambdaQueryWrapper<>();
        Long scope = ScrmDataScope.scopeOwnerId();
        if (scope != null) {
            wrapper.eq(Opportunity::getOwnerId, scope);
        } else if (query.getOwnerId() != null) {
            wrapper.eq(Opportunity::getOwnerId, query.getOwnerId());
        }
        wrapper.eq(query.getCustomerId() != null, Opportunity::getCustomerId, query.getCustomerId())
                .eq(query.getStage() != null, Opportunity::getStage, query.getStage());
        if (StrUtil.isNotBlank(query.getKeyword())) {
            String kw = query.getKeyword().trim();
            List<Long> matchedCustomerIds = customerService.list(new LambdaQueryWrapper<Customer>()
                            .select(Customer::getId)
                            .and(w -> w.like(Customer::getName, kw).or().like(Customer::getCompany, kw)))
                    .stream().map(Customer::getId).toList();
            wrapper.and(w -> {
                w.like(Opportunity::getName, kw);
                if (!matchedCustomerIds.isEmpty()) {
                    w.or().in(Opportunity::getCustomerId, matchedCustomerIds);
                }
            });
        }
        wrapper.orderByDesc(Opportunity::getCreateTime);
        Page<Opportunity> page = this.page(new Page<>(query.getPageNum(), query.getPageSize()), wrapper);
        Page<OpportunityVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(toVoList(page.getRecords()));
        return voPage;
    }

    public List<OpportunityVO> listByCustomer(Long customerId) {
        customerService.getDetail(customerId);
        List<Opportunity> list = this.list(new LambdaQueryWrapper<Opportunity>()
                .eq(Opportunity::getCustomerId, customerId)
                .orderByDesc(Opportunity::getCreateTime));
        return toVoList(list);
    }

    public OpportunityVO getDetail(Long id) {
        Opportunity opportunity = getAccessible(id);
        return toVoList(List.of(opportunity)).get(0);
    }

    public boolean saveOpportunity(OpportunityForm form) {
        customerService.getDetail(form.getCustomerId());
        Opportunity entity = BeanUtil.copyProperties(form, Opportunity.class);
        Long userId = SecurityUtils.getUserId();
        entity.setOwnerId(ScrmDataScope.canViewAll() && form.getOwnerId() != null ? form.getOwnerId() : userId);
        entity.setStage(form.getStage() == null ? 1 : form.getStage());
        entity.setProbability(form.getProbability() == null ? 10 : form.getProbability());
        entity.setCreateBy(userId);
        entity.setUpdateBy(userId);
        return this.save(entity);
    }

    public boolean updateOpportunity(Long id, OpportunityForm form) {
        Opportunity entity = getAccessible(id);
        BeanUtil.copyProperties(form, entity, "id", "createBy", "createTime", "isDeleted", "ownerId");
        if (!ScrmDataScope.canViewAll()) {
            entity.setOwnerId(SecurityUtils.getUserId());
        } else if (form.getOwnerId() != null) {
            entity.setOwnerId(form.getOwnerId());
        }
        entity.setUpdateBy(SecurityUtils.getUserId());
        return this.updateById(entity);
    }

    public boolean deleteOpportunities(String ids) {
        List<Long> idList = StrUtil.split(ids, ',').stream().filter(StrUtil::isNotBlank)
                .map(s -> Long.valueOf(s.trim())).toList();
        if (CollUtil.isEmpty(idList)) {
            return false;
        }
        idList.forEach(this::getAccessible);
        return this.removeByIds(idList);
    }

    public List<OpportunityVO> toVoList(List<Opportunity> opportunities) {
        if (CollUtil.isEmpty(opportunities)) {
            return List.of();
        }
        List<Long> customerIds = opportunities.stream().map(Opportunity::getCustomerId).distinct().toList();
        Map<Long, Customer> customers = customerService.listByIds(customerIds).stream()
                .collect(Collectors.toMap(Customer::getId, c -> c));
        Map<Long, String> owners = userNames(opportunities.stream().map(Opportunity::getOwnerId).toList());
        return opportunities.stream().map(o -> {
            OpportunityVO vo = BeanUtil.copyProperties(o, OpportunityVO.class);
            Customer customer = customers.get(o.getCustomerId());
            if (customer != null) {
                vo.setCustomerName(customer.getName());
                vo.setCustomerCompany(customer.getCompany());
            }
            vo.setOwnerName(o.getOwnerId() == null ? null : owners.get(o.getOwnerId()));
            return vo;
        }).toList();
    }

    private Opportunity getAccessible(Long id) {
        Opportunity opportunity = this.getById(id);
        if (opportunity == null) {
            throw new BusinessException("商机不存在");
        }
        if (!ScrmDataScope.canViewAll() && !Objects.equals(opportunity.getOwnerId(), SecurityUtils.getUserId())) {
            throw new BusinessException("无权操作该商机");
        }
        return opportunity;
    }

    private Map<Long, String> userNames(Collection<Long> ids) {
        List<Long> userIds = ids.stream().filter(Objects::nonNull).distinct().toList();
        if (userIds.isEmpty()) {
            return Map.of();
        }
        return userService.listByIds(userIds).stream()
                .collect(Collectors.toMap(User::getId,
                        u -> StrUtil.blankToDefault(u.getNickname(), u.getUsername())));
    }
}
