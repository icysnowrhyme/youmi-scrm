package com.youlai.boot.module.scrm.service;

import cn.hutool.core.bean.BeanUtil;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.util.RandomUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.youlai.boot.core.exception.BusinessException;
import com.youlai.boot.module.scrm.mapper.ContractMapper;
import com.youlai.boot.module.scrm.model.entity.Contract;
import com.youlai.boot.module.scrm.model.entity.Customer;
import com.youlai.boot.module.scrm.model.form.ContractForm;
import com.youlai.boot.module.scrm.model.query.ContractQuery;
import com.youlai.boot.module.scrm.model.vo.ContractVO;
import com.youlai.boot.module.scrm.support.ScrmDataScope;
import com.youlai.boot.security.util.SecurityUtils;
import com.youlai.boot.system.model.entity.User;
import com.youlai.boot.system.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ContractService extends ServiceImpl<ContractMapper, Contract> {

    private final CustomerService customerService;
    private final UserService userService;

    public IPage<ContractVO> getPage(ContractQuery query) {
        LambdaQueryWrapper<Contract> wrapper = new LambdaQueryWrapper<>();
        Long scope = ScrmDataScope.scopeOwnerId();
        if (scope != null) {
            wrapper.eq(Contract::getOwnerId, scope);
        } else if (query.getOwnerId() != null) {
            wrapper.eq(Contract::getOwnerId, query.getOwnerId());
        }
        wrapper.eq(query.getCustomerId() != null, Contract::getCustomerId, query.getCustomerId())
                .eq(query.getStatus() != null, Contract::getStatus, query.getStatus());
        if (StrUtil.isNotBlank(query.getKeyword())) {
            String kw = query.getKeyword().trim();
            List<Long> matchedCustomerIds = customerService.list(new LambdaQueryWrapper<Customer>()
                            .select(Customer::getId)
                            .and(w -> w.like(Customer::getName, kw).or().like(Customer::getCompany, kw)))
                    .stream().map(Customer::getId).toList();
            wrapper.and(w -> {
                w.like(Contract::getName, kw).or().like(Contract::getContractNo, kw);
                if (!matchedCustomerIds.isEmpty()) {
                    w.or().in(Contract::getCustomerId, matchedCustomerIds);
                }
            });
        }
        wrapper.orderByDesc(Contract::getCreateTime);
        Page<Contract> page = this.page(new Page<>(query.getPageNum(), query.getPageSize()), wrapper);
        Page<ContractVO> voPage = new Page<>(page.getCurrent(), page.getSize(), page.getTotal());
        voPage.setRecords(toVoList(page.getRecords()));
        return voPage;
    }

    public List<ContractVO> listByCustomer(Long customerId) {
        customerService.getDetail(customerId);
        List<Contract> list = this.list(new LambdaQueryWrapper<Contract>()
                .eq(Contract::getCustomerId, customerId)
                .orderByDesc(Contract::getCreateTime));
        return toVoList(list);
    }

    public ContractVO getDetail(Long id) {
        return toVoList(List.of(getAccessible(id))).get(0);
    }

    public boolean saveContract(ContractForm form) {
        customerService.getDetail(form.getCustomerId());
        Contract entity = BeanUtil.copyProperties(form, Contract.class);
        if (StrUtil.isBlank(entity.getContractNo())) {
            entity.setContractNo(generateContractNo());
        }
        Long userId = SecurityUtils.getUserId();
        entity.setOwnerId(ScrmDataScope.canViewAll() && form.getOwnerId() != null ? form.getOwnerId() : userId);
        entity.setStatus(form.getStatus() == null ? 1 : form.getStatus());
        entity.setCreateBy(userId);
        entity.setUpdateBy(userId);
        return this.save(entity);
    }

    public boolean updateContract(Long id, ContractForm form) {
        Contract entity = getAccessible(id);
        BeanUtil.copyProperties(form, entity, "id", "createBy", "createTime", "isDeleted", "ownerId");
        if (!ScrmDataScope.canViewAll()) {
            entity.setOwnerId(SecurityUtils.getUserId());
        } else if (form.getOwnerId() != null) {
            entity.setOwnerId(form.getOwnerId());
        }
        entity.setUpdateBy(SecurityUtils.getUserId());
        return this.updateById(entity);
    }

    public boolean deleteContracts(String ids) {
        List<Long> idList = StrUtil.split(ids, ',').stream().filter(StrUtil::isNotBlank)
                .map(s -> Long.valueOf(s.trim())).toList();
        if (CollUtil.isEmpty(idList)) {
            return false;
        }
        idList.forEach(this::getAccessible);
        return this.removeByIds(idList);
    }

    public List<ContractVO> toVoList(List<Contract> contracts) {
        if (CollUtil.isEmpty(contracts)) {
            return List.of();
        }
        List<Long> customerIds = contracts.stream().map(Contract::getCustomerId).distinct().toList();
        Map<Long, Customer> customers = customerService.listByIds(customerIds).stream()
                .collect(Collectors.toMap(Customer::getId, c -> c));
        Map<Long, String> owners = userNames(contracts.stream().map(Contract::getOwnerId).toList());
        return contracts.stream().map(c -> {
            ContractVO vo = BeanUtil.copyProperties(c, ContractVO.class);
            Customer customer = customers.get(c.getCustomerId());
            if (customer != null) {
                vo.setCustomerName(customer.getName());
                vo.setCustomerCompany(customer.getCompany());
            }
            vo.setOwnerName(c.getOwnerId() == null ? null : owners.get(c.getOwnerId()));
            return vo;
        }).toList();
    }

    private String generateContractNo() {
        String prefix = "HT" + LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        for (int i = 0; i < 20; i++) {
            String no = prefix + RandomUtil.randomNumbers(4);
            if (!this.exists(new LambdaQueryWrapper<Contract>().eq(Contract::getContractNo, no))) {
                return no;
            }
        }
        throw new BusinessException("合同编号生成失败，请稍后重试");
    }

    private Contract getAccessible(Long id) {
        Contract contract = this.getById(id);
        if (contract == null) {
            throw new BusinessException("合同不存在");
        }
        if (!ScrmDataScope.canViewAll() && !Objects.equals(contract.getOwnerId(), SecurityUtils.getUserId())) {
            throw new BusinessException("无权操作该合同");
        }
        return contract;
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
