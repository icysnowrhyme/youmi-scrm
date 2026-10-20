package com.youlai.boot.module.scrm.service;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youlai.boot.core.exception.BusinessException;
import com.youlai.boot.module.scrm.mapper.CustomerMapper;
import com.youlai.boot.module.scrm.mapper.CustomerTagMapper;
import com.youlai.boot.module.scrm.mapper.CustomerTagRelMapper;
import com.youlai.boot.module.scrm.model.entity.Customer;
import com.youlai.boot.module.scrm.model.entity.CustomerTag;
import com.youlai.boot.module.scrm.model.entity.CustomerTagRel;
import com.youlai.boot.module.scrm.model.form.CustomerForm;
import com.youlai.boot.module.scrm.model.query.CustomerQuery;
import com.youlai.boot.module.scrm.model.vo.CustomerDetailVO;
import com.youlai.boot.module.scrm.model.vo.CustomerOptionVO;
import com.youlai.boot.module.scrm.model.vo.CustomerPageVO;
import com.youlai.boot.module.scrm.model.vo.TagVO;
import com.youlai.boot.module.scrm.support.ScrmDataScope;
import com.youlai.boot.security.util.SecurityUtils;
import com.youlai.boot.system.model.entity.User;
import com.youlai.boot.system.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CustomerService extends ServiceImpl<CustomerMapper, Customer> {

    private final CustomerTagMapper tagMapper;
    private final CustomerTagRelMapper tagRelMapper;
    private final UserService userService;

    public IPage<CustomerPageVO> getPage(CustomerQuery query) {
        LambdaQueryWrapper<Customer> wrapper = buildWrapper(query, Boolean.TRUE.equals(query.getPool()));
        Page<Customer> page = this.page(new Page<>(query.getPageNum(), query.getPageSize()), wrapper);
        return toVoPage(page);
    }

    public IPage<CustomerPageVO> getPoolPage(CustomerQuery query) {
        query.setPool(true);
        query.setOwnerId(null);
        return getPage(query);
    }

    public CustomerDetailVO getDetail(Long id) {
        Customer customer = getAccessibleCustomer(id);
        CustomerDetailVO vo = BeanUtil.copyProperties(customer, CustomerDetailVO.class);
        fillOwnerAndTags(List.of(vo), Map.of(), Map.of());
        User creator = customer.getCreateBy() == null ? null : userService.getById(customer.getCreateBy());
        vo.setCreatorName(creator == null ? null : displayName(creator));
        return vo;
    }

    @Transactional(rollbackFor = Exception.class)
    public boolean saveCustomer(CustomerForm form) {
        Customer customer = BeanUtil.copyProperties(form, Customer.class);
        Long currentUserId = SecurityUtils.getUserId();
        if (customer.getOwnerId() == null) {
            customer.setOwnerId(currentUserId);
        }
        if (!ScrmDataScope.canViewAll()) {
            customer.setOwnerId(currentUserId);
        }
        customer.setDeptId(deptIdOf(customer.getOwnerId()));
        customer.setCreateBy(currentUserId);
        customer.setUpdateBy(currentUserId);
        customer.setStatus(customer.getStatus() == null ? 1 : customer.getStatus());
        customer.setSource(customer.getSource() == null ? 6 : customer.getSource());
        customer.setLevel(StrUtil.blankToDefault(customer.getLevel(), "C"));
        boolean saved = this.save(customer);
        replaceTags(customer.getId(), form.getTagIds());
        return saved;
    }

    @Transactional(rollbackFor = Exception.class)
    public boolean updateCustomer(Long id, CustomerForm form) {
        Customer customer = getAccessibleCustomer(id);
        checkWritable(customer);
        BeanUtil.copyProperties(form, customer, "id", "createBy", "createTime", "isDeleted", "ownerId");
        if (!ScrmDataScope.canViewAll()) {
            customer.setOwnerId(SecurityUtils.getUserId());
        } else if (form.getOwnerId() != null) {
            customer.setOwnerId(form.getOwnerId());
        }
        customer.setDeptId(deptIdOf(customer.getOwnerId()));
        customer.setUpdateBy(SecurityUtils.getUserId());
        boolean updated = this.updateById(customer);
        if (form.getTagIds() != null) {
            replaceTags(id, form.getTagIds());
        }
        return updated;
    }

    @Transactional(rollbackFor = Exception.class)
    public boolean deleteCustomers(String ids) {
        List<Long> idList = parseIds(ids);
        if (idList.isEmpty()) {
            return false;
        }
        for (Long id : idList) {
            Customer customer = getById(id);
            if (customer != null) {
                checkWritable(customer);
            }
        }
        tagRelMapper.delete(new LambdaQueryWrapper<CustomerTagRel>().in(CustomerTagRel::getCustomerId, idList));
        return this.removeByIds(idList);
    }

    @Transactional(rollbackFor = Exception.class)
    public boolean assignCustomers(String ids, Long ownerId) {
        List<Long> idList = parseIds(ids);
        if (idList.isEmpty()) {
            return false;
        }
        if (ownerId != null && userService.getById(ownerId) == null) {
            throw new BusinessException("负责人不存在");
        }
        Long deptId = deptIdOf(ownerId);
        return this.update(new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<Customer>()
                .in(Customer::getId, idList)
                .set(Customer::getOwnerId, ownerId)
                .set(Customer::getDeptId, deptId)
                .set(Customer::getUpdateBy, SecurityUtils.getUserId()));
    }

    public boolean claimCustomer(Long id) {
        Customer customer = getById(id);
        if (customer == null) {
            throw new BusinessException("客户不存在");
        }
        if (customer.getOwnerId() != null) {
            throw new BusinessException("该客户已被领取");
        }
        Long userId = SecurityUtils.getUserId();
        Customer update = new Customer();
        update.setId(id);
        update.setOwnerId(userId);
        update.setDeptId(deptIdOf(userId));
        update.setUpdateBy(userId);
        if (Objects.equals(customer.getStatus(), 1)) {
            update.setStatus(2);
        }
        return this.updateById(update);
    }

    public List<CustomerOptionVO> listOptions(String keyword) {
        LambdaQueryWrapper<Customer> wrapper = new LambdaQueryWrapper<Customer>()
                .select(Customer::getId, Customer::getName, Customer::getCompany, Customer::getPhone);
        Long scope = ScrmDataScope.scopeOwnerId();
        if (scope != null) {
            wrapper.eq(Customer::getOwnerId, scope);
        }
        if (StrUtil.isNotBlank(keyword)) {
            wrapper.and(w -> w.like(Customer::getName, keyword)
                    .or().like(Customer::getCompany, keyword)
                    .or().like(Customer::getPhone, keyword));
        }
        wrapper.orderByDesc(Customer::getCreateTime).last("LIMIT 30");
        return this.list(wrapper).stream()
                .map(c -> BeanUtil.copyProperties(c, CustomerOptionVO.class))
                .toList();
    }

    public List<CustomerPageVO> listTodo(int limit) {
        LocalDateTime deadline = LocalDateTime.now().plusDays(7);
        LambdaQueryWrapper<Customer> wrapper = new LambdaQueryWrapper<Customer>()
                .isNotNull(Customer::getNextFollowTime)
                .le(Customer::getNextFollowTime, deadline)
                .orderByAsc(Customer::getNextFollowTime);
        Long scope = ScrmDataScope.scopeOwnerId();
        if (scope != null) {
            wrapper.eq(Customer::getOwnerId, scope);
        }
        Page<Customer> page = new Page<>(1, Math.max(1, limit));
        Page<Customer> result = this.page(page, wrapper);
        return toVoPage(result).getRecords();
    }

    public List<CustomerPageVO> toVoList(List<Customer> customers) {
        if (CollUtil.isEmpty(customers)) {
            return List.of();
        }
        List<CustomerPageVO> vos = customers.stream()
                .map(c -> BeanUtil.copyProperties(c, CustomerPageVO.class))
                .toList();
        Map<Long, String> names = userNames(customers.stream().map(Customer::getOwnerId).toList());
        Map<Long, List<TagVO>> tags = tagsByCustomer(customers.stream().map(Customer::getId).toList());
        vos.forEach(vo -> {
            vo.setOwnerName(vo.getOwnerId() == null ? null : names.get(vo.getOwnerId()));
            vo.setTags(tags.getOrDefault(vo.getId(), List.of()));
        });
        return vos;
    }

    private LambdaQueryWrapper<Customer> buildWrapper(CustomerQuery query, boolean pool) {
        LambdaQueryWrapper<Customer> wrapper = new LambdaQueryWrapper<>();
        if (pool || Boolean.TRUE.equals(query.getPool())) {
            wrapper.isNull(Customer::getOwnerId);
        } else {
            Long scope = ScrmDataScope.scopeOwnerId();
            if (scope != null) {
                wrapper.eq(Customer::getOwnerId, scope);
            } else if (query.getOwnerId() != null) {
                wrapper.eq(Customer::getOwnerId, query.getOwnerId());
            }
        }
        if (StrUtil.isNotBlank(query.getKeyword())) {
            String kw = query.getKeyword().trim();
            wrapper.and(w -> w.like(Customer::getName, kw)
                    .or().like(Customer::getCompany, kw)
                    .or().like(Customer::getPhone, kw));
        }
        wrapper.eq(StrUtil.isNotBlank(query.getLevel()), Customer::getLevel, query.getLevel());
        if (StrUtil.isNotBlank(query.getStatuses())) {
            wrapper.in(Customer::getStatus, StrUtil.split(query.getStatuses(), ",").stream()
                    .map(String::trim)
                    .filter(StrUtil::isNotBlank)
                    .map(Integer::valueOf)
                    .toList());
        } else {
            wrapper.eq(query.getStatus() != null, Customer::getStatus, query.getStatus());
        }
        wrapper.eq(query.getSource() != null, Customer::getSource, query.getSource());
        if (query.getTagId() != null) {
            wrapper.inSql(Customer::getId,
                    "SELECT customer_id FROM rel_customer_tag WHERE tag_id = " + query.getTagId());
        }
        if (StrUtil.isNotBlank(query.getStartDate())) {
            wrapper.ge(Customer::getCreateTime, LocalDate.parse(query.getStartDate()).atStartOfDay());
        }
        if (StrUtil.isNotBlank(query.getEndDate())) {
            wrapper.lt(Customer::getCreateTime, LocalDate.parse(query.getEndDate()).plusDays(1).atStartOfDay());
        }
        wrapper.orderByDesc(Customer::getCreateTime);
        return wrapper;
    }

    private IPage<CustomerPageVO> toVoPage(Page<Customer> page) {
        List<CustomerPageVO> records = toVoList(page.getRecords());
        Page<CustomerPageVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(records);
        return voPage;
    }

    private void fillOwnerAndTags(List<CustomerPageVO> vos, Map<Long, String> names, Map<Long, List<TagVO>> tags) {
        if (CollUtil.isEmpty(vos)) {
            return;
        }
        Map<Long, String> nameMap = names.isEmpty()
                ? userNames(vos.stream().map(CustomerPageVO::getOwnerId).toList())
                : names;
        Map<Long, List<TagVO>> tagMap = tags.isEmpty()
                ? tagsByCustomer(vos.stream().map(CustomerPageVO::getId).toList())
                : tags;
        vos.forEach(vo -> {
            vo.setOwnerName(vo.getOwnerId() == null ? null : nameMap.get(vo.getOwnerId()));
            vo.setTags(tagMap.getOrDefault(vo.getId(), List.of()));
        });
    }

    private Map<Long, List<TagVO>> tagsByCustomer(Collection<Long> customerIds) {
        List<Long> ids = customerIds.stream().filter(Objects::nonNull).distinct().toList();
        if (ids.isEmpty()) {
            return Map.of();
        }
        List<CustomerTagRel> relations = tagRelMapper.selectList(
                new LambdaQueryWrapper<CustomerTagRel>().in(CustomerTagRel::getCustomerId, ids));
        if (relations.isEmpty()) {
            return Map.of();
        }
        Set<Long> tagIds = relations.stream().map(CustomerTagRel::getTagId).collect(Collectors.toSet());
        Map<Long, CustomerTag> tagMap = tagMapper.selectBatchIds(tagIds).stream()
                .collect(Collectors.toMap(CustomerTag::getId, Function.identity()));
        Map<Long, List<TagVO>> result = new HashMap<>();
        for (CustomerTagRel relation : relations) {
            CustomerTag tag = tagMap.get(relation.getTagId());
            if (tag == null) {
                continue;
            }
            TagVO vo = new TagVO();
            vo.setId(tag.getId());
            vo.setName(tag.getName());
            vo.setColor(tag.getColor());
            result.computeIfAbsent(relation.getCustomerId(), k -> new ArrayList<>()).add(vo);
        }
        return result;
    }

    private Map<Long, String> userNames(Collection<Long> userIds) {
        List<Long> ids = userIds.stream().filter(Objects::nonNull).distinct().toList();
        if (ids.isEmpty()) {
            return Map.of();
        }
        return userService.listByIds(ids).stream()
                .collect(Collectors.toMap(User::getId, CustomerService::displayName));
    }

    private static String displayName(User user) {
        return StrUtil.blankToDefault(user.getNickname(), user.getUsername());
    }

    private Long deptIdOf(Long ownerId) {
        if (ownerId == null) {
            return null;
        }
        User user = userService.getById(ownerId);
        return user == null ? null : user.getDeptId();
    }

    private Customer getAccessibleCustomer(Long id) {
        Customer customer = this.getById(id);
        if (customer == null) {
            throw new BusinessException("客户不存在");
        }
        if (!ScrmDataScope.canViewAll()
                && customer.getOwnerId() != null
                && !Objects.equals(customer.getOwnerId(), SecurityUtils.getUserId())) {
            throw new BusinessException("无权查看该客户");
        }
        return customer;
    }

    private void checkWritable(Customer customer) {
        if (!ScrmDataScope.canViewAll() && !Objects.equals(customer.getOwnerId(), SecurityUtils.getUserId())) {
            throw new BusinessException("无权操作该客户");
        }
    }

    private void replaceTags(Long customerId, List<Long> tagIds) {
        tagRelMapper.delete(new LambdaQueryWrapper<CustomerTagRel>().eq(CustomerTagRel::getCustomerId, customerId));
        if (CollUtil.isEmpty(tagIds)) {
            return;
        }
        for (Long tagId : new LinkedHashSet<>(tagIds)) {
            if (tagId == null) {
                continue;
            }
            CustomerTagRel rel = new CustomerTagRel();
            rel.setCustomerId(customerId);
            rel.setTagId(tagId);
            tagRelMapper.insert(rel);
        }
    }

    private List<Long> parseIds(String ids) {
        if (StrUtil.isBlank(ids)) {
            return List.of();
        }
        return StrUtil.split(ids, ',').stream().map(String::trim).filter(StrUtil::isNotBlank)
                .map(Long::valueOf).toList();
    }
}
