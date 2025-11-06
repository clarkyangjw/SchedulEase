package com.cstar.schedulease.service.provider.entity;

import com.cstar.schedulease.service.services.entity.Service;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "provider_service")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ProviderService {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id", nullable = false)
    private Provider provider;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "service_id", nullable = false)
    private Service service;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;
}

