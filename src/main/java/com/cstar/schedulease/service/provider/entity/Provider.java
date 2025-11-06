package com.cstar.schedulease.service.provider.entity;

import com.cstar.schedulease.common.entity.BaseUser;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "provider")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class Provider extends BaseUser {

    @Column(name = "description", columnDefinition = "TEXT")
    private String description;

    @NotNull(message = "Active status cannot be null")
    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @OneToMany(mappedBy = "provider", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<ProviderService> providerServices = new ArrayList<>();
}
