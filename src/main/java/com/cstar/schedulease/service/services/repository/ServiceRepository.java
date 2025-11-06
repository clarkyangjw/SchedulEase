package com.cstar.schedulease.service.services.repository;

import com.cstar.schedulease.common.enums.Category;
import com.cstar.schedulease.service.services.entity.Service;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ServiceRepository extends JpaRepository<Service, Long> {

    List<Service> findByIsActiveTrue();

    List<Service> findByIsActive(Boolean isActive);

    List<Service> findByCategory(Category category);

    List<Service> findByCategoryAndIsActiveTrue(Category category);

    Optional<Service> findByName(String name);
    
    boolean existsByName(String name);
}

