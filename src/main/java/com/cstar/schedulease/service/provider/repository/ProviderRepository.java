package com.cstar.schedulease.service.provider.repository;

import com.cstar.schedulease.service.provider.entity.Provider;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ProviderRepository extends JpaRepository<Provider, Long> {
    List<Provider> findByIsActiveTrue();

    List<Provider> findByIsActive(Boolean isActive);

    boolean existsByIdAndIsActiveTrue(Long id);
}
