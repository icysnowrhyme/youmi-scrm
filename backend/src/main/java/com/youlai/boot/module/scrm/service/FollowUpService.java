package com.youlai.boot.module.scrm.service;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youlai.boot.core.exception.BusinessException;
import com.youlai.boot.module.scrm.mapper.FollowUpMapper;
import com.youlai.boot.module.scrm.model.entity.Customer;
import com.youlai.boot.module.scrm.model.entity.FollowUp;
import com.youlai.boot.module.scrm.model.form.FollowUpForm;
import com.youlai.boot.module.scrm.model.query.FollowUpQuery;
import com.youlai.boot.module.scrm.model.vo.FollowUpVO;
import com.youlai.boot.module.scrm.support.ScrmDataScope;
import com.youlai.boot.security.util.SecurityUtils;
import com.youlai.boot.system.model.entity.User;
import com.youlai.boot.system.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FollowUpService extends ServiceImpl<FollowUpMapper, FollowUp> {

    private final CustomerService customerService;
    private final UserService userService;

    public IPage<FollowUpVO> getPage(FollowUpQuery query) {
        LambdaQueryWrapper<FollowUp> wrapper = new LambdaQueryWrapper<>();
        Long scope = ScrmDataScope.scopeOwnerId();
        if (scope != null) {
            wrapper.inSql(FollowUp::getCustomerId,
                    "SELECT id FROM biz_customer WHERE is_deleted = 0 AND owner_id = " + scope);
        }
        wrapper.eq(query.getCustomerId() != null, FollowUp::getCustomerId, query.getCustomerId())
                .eq(query.getType() != null, FollowUp::getType, query.getType())
                .eq(query.getCreatorId() != null, FollowUp::getCreateBy, query.getCreatorId());
        if (StrUtil.isNotBlank(query.getKeyword())) {
            String kw = query.getKeyword().trim();
            wrapper.and(w -> w.like(FollowUp::getContent, kw).or().like(FollowUp::getResult, kw));
        }
        if (StrUtil.isNotBlank(query.getStartDate())) {
            wrapper.ge(FollowUp::getCreateTime, LocalDate.parse(query.getStartDate()).atStartOfDay());
        }
        if (StrUtil.isNotBlank(query.getEndDate())) {
            wrapper.lt(FollowUp::getCreateTime, LocalDate.parse(query.getEndDate()).plusDays(1).atStartOfDay());
        }
        wrapper.orderByDesc(FollowUp::getCreateTime);
        Page<FollowUp> page = this.page(new Page<>(query.getPageNum(), query.getPageSize()), wrapper);
        Page<FollowUpVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(toVoList(page.getRecords()));
        return voPage;
    }

    public List<FollowUpVO> listByCustomer(Long customerId) {
        customerService.getDetail(customerId);
        List<FollowUp> list = this.list(new LambdaQueryWrapper<FollowUp>()
                .eq(FollowUp::getCustomerId, customerId)
                .orderByDesc(FollowUp::getCreateTime));
        return toVoList(list);
    }

    @Transactional(rollbackFor = Exception.class)
    public boolean saveFollowUp(FollowUpForm form) {
        Customer customer = customerService.getById(form.getCustomerId());
        if (customer == null) {
            throw new BusinessException("客户不存在");
        }
        customerService.getDetail(form.getCustomerId());
        FollowUp followUp = BeanUtil.copyProperties(form, FollowUp.class);
        followUp.setCreateBy(SecurityUtils.getUserId());
        followUp.setUpdateBy(SecurityUtils.getUserId());
        boolean saved = this.save(followUp);

        Customer update = new Customer();
        update.setId(customer.getId());
        update.setLastFollowTime(LocalDateTime.now());
        update.setNextFollowTime(form.getNextFollowTime());
        update.setUpdateBy(SecurityUtils.getUserId());
        if (Objects.equals(customer.getStatus(), 1)) {
            update.setStatus(2);
        }
        customerService.updateById(update);
        return saved;
    }

    public boolean updateFollowUp(Long id, FollowUpForm form) {
        FollowUp followUp = getEditable(id);
        BeanUtil.copyProperties(form, followUp, "id", "createBy", "createTime", "isDeleted");
        followUp.setUpdateBy(SecurityUtils.getUserId());
        return this.updateById(followUp);
    }

    public boolean deleteFollowUps(String ids) {
        List<Long> idList = StrUtil.split(ids, ',').stream().filter(StrUtil::isNotBlank)
                .map(s -> Long.valueOf(s.trim())).toList();
        if (CollUtil.isEmpty(idList)) {
            return false;
        }
        idList.forEach(this::getEditable);
        return this.removeByIds(idList);
    }

    public List<FollowUpVO> listRecent(int limit) {
        LambdaQueryWrapper<FollowUp> wrapper = new LambdaQueryWrapper<FollowUp>()
                .orderByDesc(FollowUp::getCreateTime)
                .last("LIMIT " + Math.max(1, limit));
        Long scope = ScrmDataScope.scopeOwnerId();
        if (scope != null) {
            wrapper.eq(FollowUp::getCreateBy, scope);
        }
        return toVoList(this.list(wrapper));
    }

    public List<FollowUpVO> toVoList(List<FollowUp> followUps) {
        if (CollUtil.isEmpty(followUps)) {
            return List.of();
        }
        List<Long> customerIds = followUps.stream().map(FollowUp::getCustomerId).distinct().toList();
        Map<Long, Customer> customers = customerService.listByIds(customerIds).stream()
                .collect(Collectors.toMap(Customer::getId, c -> c));
        Map<Long, String> creators = userNames(followUps.stream().map(FollowUp::getCreateBy).toList());
        return followUps.stream().map(f -> {
            FollowUpVO vo = BeanUtil.copyProperties(f, FollowUpVO.class);
            Customer customer = customers.get(f.getCustomerId());
            if (customer != null) {
                vo.setCustomerName(customer.getName());
                vo.setCustomerCompany(customer.getCompany());
            }
            vo.setCreatorName(f.getCreateBy() == null ? null : creators.get(f.getCreateBy()));
            return vo;
        }).toList();
    }

    private FollowUp getEditable(Long id) {
        FollowUp followUp = this.getById(id);
        if (followUp == null) {
            throw new BusinessException("跟进记录不存在");
        }
        if (!ScrmDataScope.canViewAll() && !Objects.equals(followUp.getCreateBy(), SecurityUtils.getUserId())) {
            throw new BusinessException("无权操作该跟进记录");
        }
        return followUp;
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
